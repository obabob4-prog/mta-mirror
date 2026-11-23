--[[
    luxury_graphics / client
    ------------------------
    Visual layer for Liberty City:
      * UV-mapped HD sky dome (equirectangular CC0 panoramas + generated night sky)
      * two-texture sky cross-fade and time-of-day sun rotation
      * single-pass cinematic grade (saturation/contrast/tint/vignette/sharpen/bloom/grain)
      * rain streaks, wet-road shader, rain loop and delayed thunder
      * LOW / MEDIUM / HIGH / ULTRA quality with FPS auto-scaling
      * every optional effect has a failure path back to the stock renderer

    Draw order matters:
      high+30 update, high+10 sky, high+8 rain, high+5 post, high+2 flash.
      Later (normal-priority) resources draw HUD/CEF on top, so the post pass
      never touches CEF. The pass is also gated to the open world only.
]]

local QUALITY = {
    low =    { post = false, skyRes = 1, rain = 0,   wet = false, puddles = 0.00, far = 0.52, fog = 0.65, postScale = 0.00 },
    medium = { post = true,  skyRes = 1, rain = 90,  wet = true,  puddles = 0.35, far = 0.75, fog = 0.85, postScale = 0.80 },
    high =   { post = true,  skyRes = 2, rain = 220, wet = true,  puddles = 0.75, far = 1.00, fog = 1.00, postScale = 1.00 },
    ultra =  { post = true,  skyRes = 2, rain = 360, wet = true,  puddles = 1.00, far = 1.12, fog = 1.10, postScale = 1.15 },
}
local QUALITY_ORDER = { "low", "medium", "high", "ultra" }
local AUTO_MAX_INDEX = 3 -- HIGH; ULTRA is manual only

local DEFAULT_STATE = {
    key = "sunny",
    label = "Sunny",
    weather = 0,
    rain = 0.0,
    fog = 2600,
    farClip = 3800,
    sky = "sunny",
    tint = { 1.00, 1.00, 1.00 },
    haze = 0.03,
    hazeColor = { 0.78, 0.88, 0.98 },
    post = { saturation = 1.06, contrast = 1.04, brightness = 1.00, tint = { 1.00, 1.00, 1.00 }, vignette = 0.08, grain = 0.002, sharpen = 0.14, bloom = 0.06 },
    lightning = false,
    night = false,
    transition = 0,
}

local SKY_KEYS = {
    sunny = true, cloudy = true, overcast = true, mist = true,
    night = true, dawn = true, sunset = true, alt = true,
}
local WHITE = tocolor(255, 255, 255, 255)

local screenW, screenH = guiGetScreenSize()
local nowTick = getTickCount()

-- environment
local weatherState = DEFAULT_STATE
local currentHour = 12.0
local outside = false
local spawned = false
local effectiveQuality = "medium"
local autoMode = true

-- quality / fps
local frames = 0
local fpsWindowStart = getTickCount()
local fps = 60
local lowWindows = 0
local highWindows = 0

-- sky
local skyShader, skyReady = false, false
local skyFallback = false
local skyDrawFailures = 0
local skyTextures = {}
local skyA, skyB
local skyBlend = 0
local skyTransStart = 0
local skyTransDuration = 0
local targetSkyKey = nil
local skyRes = 1
local currentTint = { 1, 1, 1 }
local targetTint = { 1, 1, 1 }
local currentHaze = 0.03
local targetHaze = 0.03
local currentHazeColor = { 0.78, 0.88, 0.98 }
local targetHazeColor = { 0.78, 0.88, 0.98 }
local uOffset = 0
local lastTimeCheck = 0
local lastCloudState = nil

-- environment transition
local envStart = 0
local envDuration = 0
local envFrom = nil
local envTo = nil
local currentFog = 2600
local currentFar = 3800
local lastAppliedFog = -1
local lastAppliedFar = -1

-- post
local postShader, screenSource
local postReady = false
local postFailed = false
local postEnabled = false
local currentPost = { saturation = 1.06, contrast = 1.04, brightness = 1.0, tint = { 1, 1, 1 }, vignette = 0.08, grain = 0.002, sharpen = 0.14, bloom = 0.06 }
local targetPost = { saturation = 1.06, contrast = 1.04, brightness = 1.0, tint = { 1, 1, 1 }, vignette = 0.08, grain = 0.002, sharpen = 0.14, bloom = 0.06 }

-- wet roads
local wetShader
local wetActive = false
local wetApplied = {}
local wetUnsupported = false
local WET_TEXTURES = { "road*", "asphalt*", "tarmac*", "highway*", "pave*", "pavement*", "sidewalk*", "kerb*", "curb*" }
-- Server-authoritative rain drives a target; the ramp itself is eased locally so
-- the city wets gradually, stays wet for a while, then dries back to normal.
-- Every client runs the same constants against the same synced rain value.
local wetLevel = 0
local wetTarget = 0
local wetLastTick = getTickCount()
local wetOptions = { wet = true, reflections = true, rain = true }
local wetTime = 0

-- rain
local rainDrops = {}
local rainCount = 0
local lastRainTick = getTickCount()
local rainSound
local rainVolume = 0
local rainVolumeTarget = 0

-- lightning
local lightningEnabled = false
local nextLightning = 0
local flashStart = 0
local wasLightning = false

-- camera / clock caches
local lastWorldCheck = 0

local function clamp(n, lo, hi)
    n = tonumber(n) or lo
    if n < lo then return lo end
    if n > hi then return hi end
    return n
end

local function smoothstep(t)
    t = clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

local function copy3(t)
    return { tonumber(t and t[1]) or 0, tonumber(t and t[2]) or 0, tonumber(t and t[3]) or 0 }
end

local function copyPost(p)
    p = p or {}
    return {
        saturation = tonumber(p.saturation) or 1.0,
        contrast = tonumber(p.contrast) or 1.0,
        brightness = tonumber(p.brightness) or 1.0,
        tint = copy3(p.tint),
        vignette = tonumber(p.vignette) or 0.0,
        grain = tonumber(p.grain) or 0.0,
        sharpen = tonumber(p.sharpen) or 0.0,
        bloom = tonumber(p.bloom) or 0.0,
    }
end

local function copyPostTable(p)
    p = p or {}
    return {
        saturation = p.saturation,
        contrast = p.contrast,
        brightness = p.brightness,
        tint = copy3(p.tint),
        vignette = p.vignette,
        grain = p.grain,
        sharpen = p.sharpen,
        bloom = p.bloom,
    }
end

local function log(msg)
    outputDebugString("[luxury_graphics] " .. tostring(msg), 2)
end

local function validState(s)
    return type(s) == "table"
        and type(s.key) == "string"
        and tonumber(s.fog) ~= nil
        and tonumber(s.farClip) ~= nil
end

local function readRootWeather()
    local raw = getElementData(root, "luxury.weather")
    if type(raw) ~= "string" or raw == "" then return nil end
    local ok, s = pcall(fromJSON, raw)
    if ok and validState(s) then return s end
    return nil
end

local function isSpawned()
    if not isElement(localPlayer) then return false end
    return getElementData(localPlayer, "char.spawned") == true
end

local function inOpenWorld()
    if not isSpawned() then return false end
    if getElementInterior(localPlayer) ~= 0 then return false end
    if getElementDimension(localPlayer) ~= 0 then return false end
    return true
end

-- ============================================================
--  Sky textures / dome
-- ============================================================

local function texturePath(key, res)
    local ext = (key == "night") and "png" or "jpg"
    return string.format("textures/sky_%s_%dk.%s", key, res, ext)
end

local function getSkyTexture(key, res)
    if not SKY_KEYS[key] then key = "sunny" end
    local id = key .. ":" .. tostring(res)
    local entry = skyTextures[id]
    if entry and isElement(entry.tex) then
        entry.used = nowTick
        return entry.tex
    end

    local tex = dxCreateTexture(texturePath(key, res))
    if not tex then
        log("could not load " .. texturePath(key, res))
        return nil
    end
    skyTextures[id] = { tex = tex, used = nowTick }

    -- keep memory bounded: at most four decoded skies, never the ones in use
    local count = 0
    for _ in pairs(skyTextures) do count = count + 1 end
    if count > 4 then
        local oldestId, oldest = nil, nil
        for k, e in pairs(skyTextures) do
            if e.tex ~= skyA and e.tex ~= skyB then
                if not oldest or e.used < oldest.used then
                    oldestId, oldest = k, e
                end
            end
        end
        if oldestId then
            if isElement(oldest.tex) then destroyElement(oldest.tex) end
            skyTextures[oldestId] = nil
        end
    end
    return tex
end

local function setSkyTarget(key, seconds)
    if not skyReady or not isElement(skyShader) then return end
    if not SKY_KEYS[key] then key = "sunny" end
    targetSkyKey = key
    local tex = getSkyTexture(key, skyRes)
    if not tex then
        skyFallback = true
        log("sky texture failed; falling back to the stock sky")
        return
    end

    if not skyA or not isElement(skyA) then
        skyA, skyB, skyBlend = tex, tex, 0
        dxSetShaderValue(skyShader, "texA", skyA)
        dxSetShaderValue(skyShader, "texB", skyB)
        dxSetShaderValue(skyShader, "blend", 0)
        return
    end

    local visible = skyA
    if skyB and isElement(skyB) and skyBlend > 0.5 then visible = skyB end

    if tex == visible then
        skyA, skyB, skyBlend = tex, tex, 0
        dxSetShaderValue(skyShader, "texA", skyA)
        dxSetShaderValue(skyShader, "texB", skyB)
        dxSetShaderValue(skyShader, "blend", 0)
        return
    end

    skyA = visible
    skyB = tex
    skyBlend = 0
    skyTransStart = getTickCount()
    skyTransDuration = math.max(0, (tonumber(seconds) or 20) * 1000)
    dxSetShaderValue(skyShader, "texA", skyA)
    dxSetShaderValue(skyShader, "texB", skyB)
    if skyTransDuration <= 0 then
        skyA, skyBlend = skyB, 0
        dxSetShaderValue(skyShader, "texA", skyA)
        dxSetShaderValue(skyShader, "blend", 0)
    end
end

-- The nine weather states + time of day choose the actual panorama.
local function effectiveSkyKey(s, hour)
    if type(s) ~= "table" then return "sunny" end
    if s.night then return "night" end
    if hour >= 20 or hour < 5 then return "night" end
    local base = s.sky or "sunny"
    if base == "sunny" or base == "cloudy" then
        -- Keep the warm panoramas to a short sliver around the horizon.
        -- They used to cover 5-7 and 17-20, so a 19:01 session rendered the
        -- whole city through an orange sunset sky. Outside these windows the
        -- neutral sunny/cloudy panorama with a 1:1 tint is used.
        if hour >= 5.0 and hour < 5.75 then return "dawn" end
        if hour >= 19.33 and hour < 20.0 then return "sunset" end
    end
    return base
end

-- Geometry: practical UVs for the top half of an equirectangular panorama.
-- v=0 is the zenith, v=1 is the horizon; values below the horizon clamp to 1.
local DOME_SEGMENTS = 64
local DOME_RINGS = 14
local DOME_MIN_ELEV = math.rad(-10.0)
local DOME_MAX_ELEV = math.rad(90.0)
local domeStrips = {}

do
    for r = 0, DOME_RINGS - 1 do
        local e0 = DOME_MIN_ELEV + (DOME_MAX_ELEV - DOME_MIN_ELEV) * (r / DOME_RINGS)
        local e1 = DOME_MIN_ELEV + (DOME_MAX_ELEV - DOME_MIN_ELEV) * ((r + 1) / DOME_RINGS)
        local c0, s0 = math.cos(e0), math.sin(e0)
        local c1, s1 = math.cos(e1), math.sin(e1)
        local verts, units = {}, {}
        for s = 0, DOME_SEGMENTS do
            local az = (s / DOME_SEGMENTS) * math.pi * 2
            local ca, sa = math.cos(az), math.sin(az)
            local u = s / DOME_SEGMENTS
            local v0 = clamp(1 - (e0 / (math.pi / 2)), 0, 1)
            local v1 = clamp(1 - (e1 / (math.pi / 2)), 0, 1)
            verts[#verts + 1] = { 0, 0, 0, WHITE, u, v0 }
            units[#units + 1] = { ca * c0, sa * c0, s0 }
            verts[#verts + 1] = { 0, 0, 0, WHITE, u, v1 }
            units[#units + 1] = { ca * c1, sa * c1, s1 }
        end
        domeStrips[#domeStrips + 1] = { verts = verts, units = units }
    end
end

local function setCloudsDisabled(disabled)
    if lastCloudState == disabled then return end
    lastCloudState = disabled
    setCloudsEnabled(not disabled)
end

-- ============================================================
--  Post-process
-- ============================================================

local function destroyPost()
    if isElement(postShader) then destroyElement(postShader) end
    if isElement(screenSource) then destroyElement(screenSource) end
    postShader, screenSource = nil, nil
    postReady = false
end

local function createPost()
    if postReady and isElement(postShader) and isElement(screenSource) then return true end
    if postFailed then return false end
    if not screenW or screenW <= 0 then screenW, screenH = guiGetScreenSize() end

    postShader = dxCreateShader("cinematic.fx")
    if not postShader then
        postFailed = true
        log("cinematic.fx failed to compile; post-process disabled")
        return false
    end

    screenSource = dxCreateScreenSource(screenW, screenH)
    if not screenSource then
        postFailed = true
        destroyElement(postShader)
        postShader = nil
        log("screen source failed; post-process disabled")
        return false
    end

    dxSetShaderValue(postShader, "ScreenTexture", screenSource)
    dxSetShaderValue(postShader, "texelW", 1.0 / screenW)
    dxSetShaderValue(postShader, "texelH", 1.0 / screenH)
    postReady = true
    return true
end

local function syncScreenSize()
    local w, h = guiGetScreenSize()
    if w == screenW and h == screenH then return end
    screenW, screenH = w, h
    if postReady then
        if isElement(screenSource) then destroyElement(screenSource) end
        screenSource = dxCreateScreenSource(screenW, screenH)
        if isElement(screenSource) then
            dxSetShaderValue(postShader, "ScreenTexture", screenSource)
            dxSetShaderValue(postShader, "texelW", 1.0 / screenW)
            dxSetShaderValue(postShader, "texelH", 1.0 / screenH)
        else
            destroyPost()
            postFailed = true
        end
    end
end

-- ============================================================
--  Wet-road shader
-- ============================================================

local function removeWet()
    if isElement(wetShader) then
        for name in pairs(wetApplied) do
            engineRemoveShaderFromWorldTexture(wetShader, name)
        end
    end
    wetApplied = {}
    wetActive = false
end

-- Prefer the server-published rain value so all players see the same weather.
local function syncedRain()
    local rain = tonumber(weatherState.rain)
    if rain == nil then rain = tonumber(getRainLevel()) or 0 end
    return clamp(rain, 0, 1)
end

-- Wetness ramp: rain soaks the road faster than the road dries afterwards.
local function updateWetRamp()
    local now = getTickCount()
    local dt = clamp((now - wetLastTick) / 1000, 0, 0.25)
    wetLastTick = now
    wetTime = wetTime + dt

    local rain = syncedRain()
    if not wetOptions.wet then rain = 0 end
    wetTarget = clamp(rain, 0, 1)

    local rate
    if wetTarget > wetLevel then
        -- wetting: ~9s from dry to fully soaked in steady heavy rain
        rate = 0.115 * (0.55 + 0.45 * wetTarget)
    else
        -- drying: ~55s after the rain stops, slower when it was very wet
        rate = 0.018 + 0.008 * wetLevel
    end
    local diff = wetTarget - wetLevel
    local step = rate * dt
    if math.abs(diff) <= step then
        wetLevel = wetTarget
    else
        wetLevel = wetLevel + (diff > 0 and step or -step)
    end
    wetLevel = clamp(wetLevel, 0, 1)
end

local function updateWet(active)
    if wetUnsupported then return end
    local q = QUALITY[effectiveQuality] or QUALITY.medium
    active = active and q.wet and outside and wetOptions.wet

    if not active then
        removeWet()
        return
    end

    if not isElement(wetShader) then
        wetShader = dxCreateShader("wet.fx")
        if not wetShader then
            wetUnsupported = true
            log("wet.fx failed to compile; wet roads disabled")
            return
        end
        dxSetShaderValue(wetShader, "wetness", 0.0)
    end

    if not wetActive then
        local applied = 0
        for _, name in ipairs(WET_TEXTURES) do
            if engineApplyShaderToWorldTexture(wetShader, name) then
                wetApplied[name] = true
                applied = applied + 1
            end
        end
        if applied == 0 then
            wetUnsupported = true
            removeWet()
            return
        end
        wetActive = true
    end

    local q = QUALITY[effectiveQuality] or QUALITY.medium
    local night = (tonumber(currentHour) or 12) >= 19 or (tonumber(currentHour) or 12) < 6
    dxSetShaderValue(wetShader, "wetness", wetLevel)
    dxSetShaderValue(wetShader, "puddles", wetOptions.reflections and (q.puddles or 0) or 0)
    dxSetShaderValue(wetShader, "night", night and 1 or 0)
    dxSetShaderValue(wetShader, "timeSec", wetTime)
end

-- ============================================================
--  Rain / thunder
-- ============================================================

local function resetDrop(d)
    d.x = (math.random() - 0.5) * 70
    d.y = (math.random() - 0.5) * 70
    d.z = 12 + math.random() * 20
    d.speed = 28 + math.random() * 32
    d.len = 1.4 + math.random() * 2.6
end

local function ensureRainDrops(count)
    count = math.max(0, math.floor(tonumber(count) or 0))
    if count > #rainDrops then
        for i = #rainDrops + 1, count do
            local d = { x = 0, y = 0, z = 0, speed = 35, len = 2 }
            resetDrop(d)
            rainDrops[i] = d
        end
    elseif count < #rainDrops then
        for i = #rainDrops, count + 1, -1 do
            rainDrops[i] = nil
        end
    end
    rainCount = count
end

local function ensureRainSound()
    if isElement(rainSound) then return end
    rainSound = playSound("sounds/rain_loop.wav", true)
    if rainSound then
        setSoundVolume(rainSound, 0)
    end
end

local function stopThunderSound(sound)
    if isElement(sound) then stopSound(sound) end
end

local function playThunder()
    local s = playSound("sounds/thunder.wav", false)
    if s then
        setSoundVolume(s, 0.45 + math.random() * 0.22)
    end
end

-- ============================================================
--  Environment / quality
-- ============================================================

local function applyFogNow(force)
    if not outside then return end
    local q = QUALITY[effectiveQuality] or QUALITY.medium
    local far = clamp(currentFar * q.far, 900, 4200)
    local fog = clamp(currentFog * q.fog, 80, far - 50)
    if force or math.abs(far - lastAppliedFar) >= 3 then
        setFarClipDistance(far)
        lastAppliedFar = far
    end
    if force or math.abs(fog - lastAppliedFog) >= 3 then
        setFogDistance(fog)
        lastAppliedFog = fog
    end
end

local function applyEnvironmentTarget(s, transition)
    local secs = tonumber(transition) or tonumber(s.transition) or 20
    envFrom = {
        tint = copy3(currentTint),
        haze = currentHaze,
        hazeColor = copy3(currentHazeColor),
        post = copyPostTable(currentPost),
        fog = currentFog,
        far = currentFar,
    }
    envTo = {
        tint = copy3(s.tint),
        haze = tonumber(s.haze) or 0.1,
        hazeColor = copy3(s.hazeColor),
        post = copyPostTable(s.post),
        fog = tonumber(s.fog) or 2400,
        far = tonumber(s.farClip) or 3400,
    }
    envStart = getTickCount()
    envDuration = math.max(0, secs * 1000)

    if envDuration <= 0 then
        currentTint = copy3(envTo.tint)
        currentHaze = envTo.haze
        currentHazeColor = copy3(envTo.hazeColor)
        currentPost = copyPostTable(envTo.post)
        currentFog, currentFar = envTo.fog, envTo.far
        envFrom, envTo = nil, nil
        applyFogNow(true)
    end
end

local function applyWeatherState(s)
    if not validState(s) then return end
    local old = weatherState
    weatherState = s

    local secs = tonumber(s.transition) or 20
    applyEnvironmentTarget(s, secs)

    local h = currentHour
    setSkyTarget(effectiveSkyKey(s, h), secs)

    local was = lightningEnabled
    lightningEnabled = (s.lightning == true) and outside
    if lightningEnabled and not was then
        nextLightning = getTickCount() + math.random(4000, 9000)
    elseif not lightningEnabled then
        nextLightning = 0
    end

    rainVolumeTarget = outside and (tonumber(s.rain) or 0) * 0.45 or 0
    ensureRainSound()
    ensureRainDrops((QUALITY[effectiveQuality] or QUALITY.medium).rain)
    updateWet((tonumber(s.rain) or 0) > 0.05)
end

local function applyQuality(forceRetry)
    local q = QUALITY[effectiveQuality] or QUALITY.medium
    if forceRetry and postFailed then
        postFailed = false
    end

    postEnabled = q.post and not postFailed
    if postEnabled then
        createPost()
    else
        destroyPost()
    end

    local newSkyRes = q.skyRes
    if newSkyRes ~= skyRes then
        skyRes = newSkyRes
        if targetSkyKey then setSkyTarget(targetSkyKey, 2) end
    end

    ensureRainDrops(q.rain)
    if not q.wet then removeWet() end
    applyFogNow(true)

    if isElement(localPlayer) then
        setElementData(localPlayer, "luxury.quality.effective", effectiveQuality)
    end
end

local function setQuality(quality, auto, silent)
    quality = tostring(quality or ""):lower()
    if not QUALITY[quality] then quality = "medium" end
    if auto and QUALITY_ORDER[1] then
        -- automatic mode never reaches ULTRA
        local idx = 1
        for i, name in ipairs(QUALITY_ORDER) do
            if name == quality then idx = i; break end
        end
        if idx > AUTO_MAX_INDEX then quality = QUALITY_ORDER[AUTO_MAX_INDEX] end
    end

    effectiveQuality = quality
    autoMode = auto and true or false
    applyQuality(true)

    if not silent then
        outputChatBox(string.format("#d4af37[Luxury Graphics] #ffffffQuality: #d4af37%s#ffffff%s   (FPS %.0f)",
            quality:upper(), autoMode and " (auto)" or " (manual)", fps), 255, 255, 255, true)
    end
end

local function sendQuality(quality, auto)
    triggerServerEvent("luxuryGraphics:setQuality", localPlayer, quality, auto and true or false)
end

local function maybeAutoAdjust()
    if not autoMode then return end
    local idx = 1
    for i, name in ipairs(QUALITY_ORDER) do
        if name == effectiveQuality then idx = i; break end
    end

    if fps < 24 then
        lowWindows = lowWindows + 1
        highWindows = 0
    elseif fps > 52 then
        highWindows = highWindows + 1
        lowWindows = 0
    else
        lowWindows, highWindows = 0, 0
    end

    if lowWindows >= 2 and idx > 1 then
        local q = QUALITY_ORDER[idx - 1]
        setQuality(q, true, true)
        sendQuality(q, true)
        outputChatBox(string.format("#d4af37[Luxury Graphics] #ffffffAuto quality: #d4af37%s #ffffff(low FPS %.0f).", q:upper(), fps), 255, 255, 255, true)
        lowWindows = 0
    elseif highWindows >= 4 and idx < AUTO_MAX_INDEX then
        local q = QUALITY_ORDER[idx + 1]
        setQuality(q, true, true)
        sendQuality(q, true)
        outputChatBox(string.format("#d4af37[Luxury Graphics] #ffffffAuto quality: #d4af37%s #ffffff(high FPS %.0f).", q:upper(), fps), 255, 255, 255, true)
        highWindows = 0
    end
end

-- ============================================================
--  Uniform updates
-- ============================================================

local function updateEnvironment(now)
    if envFrom and envTo then
        local t = 1
        if envDuration > 0 then
            t = clamp((now - envStart) / envDuration, 0, 1)
        end
        local e = smoothstep(t)
        currentTint = {
            envFrom.tint[1] + (envTo.tint[1] - envFrom.tint[1]) * e,
            envFrom.tint[2] + (envTo.tint[2] - envFrom.tint[2]) * e,
            envFrom.tint[3] + (envTo.tint[3] - envFrom.tint[3]) * e,
        }
        currentHaze = envFrom.haze + (envTo.haze - envFrom.haze) * e
        currentHazeColor = {
            envFrom.hazeColor[1] + (envTo.hazeColor[1] - envFrom.hazeColor[1]) * e,
            envFrom.hazeColor[2] + (envTo.hazeColor[2] - envFrom.hazeColor[2]) * e,
            envFrom.hazeColor[3] + (envTo.hazeColor[3] - envFrom.hazeColor[3]) * e,
        }
        currentPost = {
            saturation = envFrom.post.saturation + (envTo.post.saturation - envFrom.post.saturation) * e,
            contrast = envFrom.post.contrast + (envTo.post.contrast - envFrom.post.contrast) * e,
            brightness = envFrom.post.brightness + (envTo.post.brightness - envFrom.post.brightness) * e,
            tint = {
                envFrom.post.tint[1] + (envTo.post.tint[1] - envFrom.post.tint[1]) * e,
                envFrom.post.tint[2] + (envTo.post.tint[2] - envFrom.post.tint[2]) * e,
                envFrom.post.tint[3] + (envTo.post.tint[3] - envFrom.post.tint[3]) * e,
            },
            vignette = envFrom.post.vignette + (envTo.post.vignette - envFrom.post.vignette) * e,
            grain = envFrom.post.grain + (envTo.post.grain - envFrom.post.grain) * e,
            sharpen = envFrom.post.sharpen + (envTo.post.sharpen - envFrom.post.sharpen) * e,
            bloom = envFrom.post.bloom + (envTo.post.bloom - envFrom.post.bloom) * e,
        }
        currentFog = envFrom.fog + (envTo.fog - envFrom.fog) * e
        currentFar = envFrom.far + (envTo.far - envFrom.far) * e
        if t >= 1 then
            envFrom, envTo = nil, nil
        end
    end

    if isElement(skyShader) then
        dxSetShaderValue(skyShader, "tintR", currentTint[1])
        dxSetShaderValue(skyShader, "tintG", currentTint[2])
        dxSetShaderValue(skyShader, "tintB", currentTint[3])
        dxSetShaderValue(skyShader, "haze", currentHaze)
        dxSetShaderValue(skyShader, "hazeR", currentHazeColor[1])
        dxSetShaderValue(skyShader, "hazeG", currentHazeColor[2])
        dxSetShaderValue(skyShader, "hazeB", currentHazeColor[3])
        dxSetShaderValue(skyShader, "uOffset", uOffset)
    end

    if postReady and isElement(postShader) then
        local q = QUALITY[effectiveQuality] or QUALITY.medium
        local full = (effectiveQuality ~= "medium")
        local scale = q.postScale
        dxSetShaderValue(postShader, "time", (now % 100000) / 1000)
        dxSetShaderValue(postShader, "saturation", currentPost.saturation)
        dxSetShaderValue(postShader, "contrast", currentPost.contrast)
        dxSetShaderValue(postShader, "brightness", currentPost.brightness)
        dxSetShaderValue(postShader, "tintR", currentPost.tint[1])
        dxSetShaderValue(postShader, "tintG", currentPost.tint[2])
        dxSetShaderValue(postShader, "tintB", currentPost.tint[3])
        dxSetShaderValue(postShader, "vignette", currentPost.vignette * (full and scale or 0.70))
        dxSetShaderValue(postShader, "sharpen", full and currentPost.sharpen * scale or 0.0)
        dxSetShaderValue(postShader, "bloom", full and currentPost.bloom * scale or 0.0)
        dxSetShaderValue(postShader, "grain", full and currentPost.grain * scale or 0.0)
    end
end

-- ============================================================
--  Rendering
-- ============================================================

local function updateFrame()
    nowTick = getTickCount()
    updateEnvironment(nowTick)

    -- smooth rain ambience
    rainVolume = rainVolume + (rainVolumeTarget - rainVolume) * 0.10
    if isElement(rainSound) then
        setSoundVolume(rainSound, clamp(rainVolume, 0, 1))
    end

    if outside and skyReady and not skyFallback then
        setCloudsDisabled(true)
    else
        setCloudsDisabled(false)
    end

    if outside and nowTick - lastTimeCheck >= 500 then
        applyFogNow(false)
        lastTimeCheck = nowTick
    end

    updateWetRamp()
    if wetActive and isElement(wetShader) then
        local q = QUALITY[effectiveQuality] or QUALITY.medium
        local night = (tonumber(currentHour) or 12) >= 19 or (tonumber(currentHour) or 12) < 6
        dxSetShaderValue(wetShader, "wetness", wetLevel)
        dxSetShaderValue(wetShader, "puddles", wetOptions.reflections and (q.puddles or 0) or 0)
        dxSetShaderValue(wetShader, "night", night and 1 or 0)
        dxSetShaderValue(wetShader, "timeSec", wetTime)
    end
end

local function renderSky()
    if not outside or not skyReady or skyFallback then return end
    if not isElement(skyShader) then return end

    local cx, cy, cz = getCameraMatrix()
    if not cx then return end

    local radius = clamp(currentFar * 0.90, 600, 4800)
    local okAny = false

    for i = 1, #domeStrips do
        local strip = domeStrips[i]
        local verts, units = strip.verts, strip.units
        for j = 1, #verts do
            local v, u = verts[j], units[j]
            v[1] = cx + u[1] * radius
            v[2] = cy + u[2] * radius
            v[3] = cz + u[3] * radius
        end
        local ok = dxDrawMaterialPrimitive3D("trianglestrip", skyShader, "prefx", unpack(verts))
        if ok then okAny = true end
    end

    if okAny then
        skyDrawFailures = 0
    else
        skyDrawFailures = skyDrawFailures + 1
        if skyDrawFailures >= 3 then
            skyFallback = true
            log("sky primitive rejected; falling back to the stock sky")
        end
    end

    -- advance the two-texture blend
    if skyTransDuration > 0 then
        local t = clamp((getTickCount() - skyTransStart) / skyTransDuration, 0, 1)
        skyBlend = smoothstep(t)
        dxSetShaderValue(skyShader, "blend", skyBlend)
        if t >= 1 then
            skyA, skyB, skyBlend = skyB, skyB, 0
            dxSetShaderValue(skyShader, "texA", skyA)
            dxSetShaderValue(skyShader, "texB", skyB)
            dxSetShaderValue(skyShader, "blend", 0)
            skyTransDuration = 0
        end
    end
end

local function renderRain()
    if not wetOptions.rain or not outside or rainCount <= 0 then return end
    local rain = tonumber(getRainLevel()) or 0
    if rain < 0.02 then return end

    local cx, cy, cz = getCameraMatrix()
    if not cx then return end
    local wx, wy = getWindVelocity()
    wx, wy = tonumber(wx) or 0, tonumber(wy) or 0

    local now = getTickCount()
    local dt = (now - lastRainTick) / 1000
    lastRainTick = now
    if dt < 0 or dt > 0.2 then dt = 0.033 end

    local active = math.floor(rainCount * math.min(1, rain * 1.35))
    if active < 1 then return end
    local col = tocolor(185, 205, 225, math.floor(60 + 120 * math.min(1, rain)))

    for i = 1, active do
        local d = rainDrops[i]
        if not d then break end
        d.z = d.z - d.speed * dt
        if d.z < -12 then
            resetDrop(d)
        end
        local x, y, z = cx + d.x, cy + d.y, cz + d.z
        dxDrawLine3D(x, y, z, x - wx * 0.06, y - wy * 0.06, z - d.len, col, 1, false)
    end
end

local function renderPost()
    if not outside or not postEnabled or not postReady then return end
    if not isElement(postShader) or not isElement(screenSource) then return end
    syncScreenSize()
    dxUpdateScreenSource(screenSource, true)
    dxDrawImage(0, 0, screenW, screenH, postShader)
end

local function renderLightning()
    if not outside then return end
    local now = getTickCount()

    if lightningEnabled and (tonumber(getRainLevel()) or 0) > 0.35 then
        if nextLightning <= 0 then
            nextLightning = now + math.random(4000, 9000)
        elseif now >= nextLightning then
            flashStart = now
            nextLightning = now + math.random(9000, 18000)
            setTimer(playThunder, math.random(500, 1700), 1)
        end
    end

    local age = now - flashStart
    if flashStart > 0 and age >= 0 and age < 420 then
        local a = 1 - (age / 420)
        a = a * a
        if age < 70 then a = 0.95 elseif age < 110 then a = 0.55 end
        dxDrawRectangle(0, 0, screenW, screenH, tocolor(225, 235, 255, math.floor(210 * a)))
    end
end

local function countFrame()
    frames = frames + 1
    local now = getTickCount()
    local elapsed = (now - fpsWindowStart) / 1000
    if elapsed >= 3 then
        fps = frames / elapsed
        frames = 0
        fpsWindowStart = now
        maybeAutoAdjust()
    end
end

-- ============================================================
--  World / clock checks
-- ============================================================

local function requestAll()
    if isElement(localPlayer) then
        triggerServerEvent("luxuryGraphics:request", localPlayer)
        triggerServerEvent("luxuryWeather:request", localPlayer)
    end
end

local function onWorldChanged(isOutside)
    if isOutside then
        applyFogNow(true)
        setSkyTarget(effectiveSkyKey(weatherState, currentHour), 3)
        ensureRainDrops((QUALITY[effectiveQuality] or QUALITY.medium).rain)
        updateWet(syncedRain() > 0.01 or wetLevel > 0.05)
        requestAll()
    else
        removeWet()
        setCloudsDisabled(false)
        rainVolumeTarget = 0
        lastAppliedFog, lastAppliedFar = -1, -1
    end
end

local function checkWorld()
    local value = inOpenWorld()
    if value ~= outside then
        outside = value
        onWorldChanged(outside)
    end
    spawned = isSpawned()

    local h, m = getTime()
    currentHour = (tonumber(h) or 12) + (tonumber(m) or 0) / 60.0

    -- rotate the panorama so the photographed sun follows the GTA clock
    local desiredAzimuth = (90 + (currentHour - 6) * 15) % 360
    uOffset = 0.62 - (desiredAzimuth / 360)

    local key = effectiveSkyKey(weatherState, currentHour)
    if key ~= targetSkyKey then
        setSkyTarget(key, 25)
    end
end

local function updateWeatherFromRoot()
    local s = readRootWeather()
    if s then applyWeatherState(s) end
end

-- ============================================================
--  Events / commands
-- ============================================================

addEvent("luxuryGraphics:quality", true)
addEvent("luxuryGraphics:request", false)
addEvent("luxuryGraphics:setQuality", false)
addEvent("luxuryGraphics:setOption", true)

addEventHandler("luxuryGraphics:quality", root, function(quality, auto)
    setQuality(quality, auto == true, true)
end)

-- Options are driven by the standalone graphics panel. They only switch
-- effects this resource already owns; no second shader/weather authority.
addEventHandler("luxuryGraphics:setOption", root, function(key, value)
    local on = (value == true)
    if key == "wet" then
        wetOptions.wet = on
        if not on then removeWet() end
    elseif key == "reflections" then
        wetOptions.reflections = on
    elseif key == "rain" then
        wetOptions.rain = on
        if not on then
            rainVolumeTarget = 0
            if isElement(rainSound) then setSoundVolume(rainSound, 0) end
        end
    end
end)

-- The weather resource owns the "luxuryWeather:state" event registration.
-- We only attach a handler here; this resource is started after it.
addEventHandler("luxuryWeather:state", root, function(s)
    if validState(s) then applyWeatherState(s) end
end)

addEventHandler("onClientElementDataChange", root, function(key)
    if source ~= root then return end
    if key == "luxury.weather" then
        updateWeatherFromRoot()
    end
end)

addEventHandler("onClientElementDataChange", root, function(key, oldValue, newValue)
    if source ~= localPlayer then return end
    if key == "char.spawned" then
        outside = inOpenWorld()
        onWorldChanged(outside)
        requestAll()
    elseif key == "luxury.quality" then
        local auto = getElementData(localPlayer, "luxury.qualityAuto") == true
        setQuality(newValue, auto, true)
    end
end)

local function qualityCommand(_, _, arg)
    if not arg or arg == "" or arg == "status" then
        local q = QUALITY[effectiveQuality] or QUALITY.medium
        outputChatBox(string.format("#d4af37[Luxury Graphics] #ffffff%s%s | FPS %.0f | post %s | sky %dK | rain %d | wet roads %s",
            effectiveQuality:upper(), autoMode and " (auto)" or " (manual)", fps,
            q.post and (postFailed and "failed" or "on") or "off", q.skyRes, q.rain, q.wet and "on" or "off"),
            255, 255, 255, true)
        outputChatBox("#d4af37[Luxury Graphics] #ffffffUsage: /lquality low|medium|high|ultra|auto", 255, 255, 255, true)
        return
    end

    arg = arg:lower()
    if arg == "auto" then
        setQuality("medium", true, true)
        sendQuality("medium", true)
        outputChatBox("#d4af37[Luxury Graphics] #ffffffAutomatic quality enabled (caps at HIGH).", 255, 255, 255, true)
    elseif QUALITY[arg] then
        setQuality(arg, false, true)
        sendQuality(arg, false)
        outputChatBox(string.format("#d4af37[Luxury Graphics] #ffffffQuality locked to #d4af37%s#ffffff.", arg:upper()), 255, 255, 255, true)
    else
        outputChatBox("#d4af37[Luxury Graphics] #ffffffUnknown level. Use low, medium, high, ultra or auto.", 255, 255, 255, true)
    end
end

addCommandHandler("lquality", qualityCommand)
addCommandHandler("lgfx", qualityCommand)
addCommandHandler("graphicsquality", qualityCommand)

addEventHandler("onClientResourceStart", resourceRoot, function()
    screenW, screenH = guiGetScreenSize()
    nowTick = getTickCount()

    skyShader = dxCreateShader("sky.fx")
    if skyShader then
        skyReady = true
        dxSetShaderValue(skyShader, "blend", 0)
        dxSetShaderValue(skyShader, "uOffset", 0)
        dxSetShaderValue(skyShader, "tintR", 1)
        dxSetShaderValue(skyShader, "tintG", 1)
        dxSetShaderValue(skyShader, "tintB", 1)
        dxSetShaderValue(skyShader, "haze", 0.1)
        dxSetShaderValue(skyShader, "hazeR", 0.72)
        dxSetShaderValue(skyShader, "hazeG", 0.83)
        dxSetShaderValue(skyShader, "hazeB", 0.95)
    else
        skyFallback = true
        log("sky.fx failed to compile; stock sky will be used")
    end

    ensureRainSound()
    outside = inOpenWorld()
    spawned = isSpawned()

    local s = readRootWeather()
    if s then
        weatherState = s
        applyEnvironmentTarget(s, 0)
    else
        applyEnvironmentTarget(DEFAULT_STATE, 0)
    end

    local h, m = getTime()
    currentHour = (tonumber(h) or 12) + (tonumber(m) or 0) / 60.0
    setSkyTarget(effectiveSkyKey(weatherState, currentHour), 0)
    applyQuality(false)

    addEventHandler("onClientRender", root, updateFrame, true, "high+30")
    addEventHandler("onClientRender", root, renderSky, true, "high+10")
    addEventHandler("onClientRender", root, renderRain, true, "high+8")
    addEventHandler("onClientRender", root, renderPost, true, "high+5")
    addEventHandler("onClientRender", root, renderLightning, true, "high+2")
    addEventHandler("onClientRender", root, countFrame, true, "low-10")

    setTimer(checkWorld, 500, 0)
    setTimer(function()
        if outside then updateWet(syncedRain() > 0.01 or wetLevel > 0.05) end
    end, 700, 0)
    setTimer(requestAll, 1500, 1)
    setTimer(function()
        if outside then requestAll() end
    end, 30000, 0)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    removeEventHandler("onClientRender", root, updateFrame)
    removeEventHandler("onClientRender", root, renderSky)
    removeEventHandler("onClientRender", root, renderRain)
    removeEventHandler("onClientRender", root, renderPost)
    removeEventHandler("onClientRender", root, renderLightning)
    removeEventHandler("onClientRender", root, countFrame)

    removeWet()
    if isElement(wetShader) then destroyElement(wetShader) end
    destroyPost()

    if isElement(skyShader) then destroyElement(skyShader) end
    for _, e in pairs(skyTextures) do
        if e.tex and isElement(e.tex) then destroyElement(e.tex) end
    end
    skyTextures = {}

    if isElement(rainSound) then stopSound(rainSound) end

    setCloudsEnabled(true)
    resetRainLevel()
    resetFogDistance()
    resetFarClipDistance()
end)
