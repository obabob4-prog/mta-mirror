--[[
    luxury_weather / client
    -----------------------
    Applies the server-owned state locally, but only after the character is
    spawned. That single gate keeps the login scene and the 3D character
    creator (which set their own time/fog/sky) completely untouched.

    Rain is cross-faded here; luxury_graphics reads getRainLevel() for its
    custom rain, wet-road shader and audio. The sky dome/post-process live in
    luxury_graphics and listen to the same "luxuryWeather:state" event.
]]

local currentState = nil
local appliedKey = nil
local lastTimestamp = 0

local rainFrom = 0
local rainTo = 0
local rainStart = 0
local rainDuration = 0
local rainTimer = nil

local function isSpawned()
    if not isElement(localPlayer) then return false end
    return getElementData(localPlayer, "char.spawned") == true
end

-- The creator studio is an interior/dimension. Staying out of its environment
-- is the safest way not to fight its scripted time/fog/sky.
local function inOpenWorld()
    if not isSpawned() then return false end
    if getElementInterior(localPlayer) ~= 0 then return false end
    if getElementDimension(localPlayer) ~= 0 then return false end
    return true
end

local function clamp(n, lo, hi)
    n = tonumber(n) or lo
    if n < lo then return lo end
    if n > hi then return hi end
    return n
end

local function validState(s)
    return type(s) == "table"
        and type(s.key) == "string"
        and tonumber(s.weather) ~= nil
        and tonumber(s.hour) ~= nil
        and tonumber(s.minute) ~= nil
end

local function stopRainTransition()
    if rainTimer and isTimer(rainTimer) then
        killTimer(rainTimer)
    end
    rainTimer = nil
end

local function applyRain(level)
    level = clamp(level, 0.0, 1.0)
    setRainLevel(level)
end

local function beginRainTransition(target, seconds)
    target = clamp(target, 0.0, 1.0)
    local current = tonumber(getRainLevel()) or 0.0
    stopRainTransition()

    rainFrom = current
    rainTo = target
    rainStart = getTickCount()
    rainDuration = math.max(0, (tonumber(seconds) or 0) * 1000)

    if rainDuration <= 0 or math.abs(target - current) < 0.001 then
        applyRain(target)
        return
    end

    rainTimer = setTimer(function()
        local t = (getTickCount() - rainStart) / rainDuration
        if t >= 1 then
            applyRain(rainTo)
            stopRainTransition()
            return
        end
        local e = t * t * (3 - 2 * t) -- smoothstep
        applyRain(rainFrom + (rainTo - rainFrom) * e)
    end, 100, 0)
end

-- ------------------------------------------------------------------
-- World light grade (MTA 1.6 setWorldProperty)
-- ------------------------------------------------------------------
-- Liberty City ships a GTA III-era timecyc.dat whose ambient light turns
-- strongly orange between roughly 18:00 and 21:00. That was the root of the
-- persistent yellow cast on roads and buildings. setWorldProperty lets us
-- override the remaining timecyc channels; we drive them with a neutral
-- day/night curve, and reset everything as soon as the player leaves the
-- open world so interiors and the character creator keep their own lighting.
--
-- AmbientColor      : ambient light on map objects
-- AmbientObjColor   : ambient light on peds/vehicles
-- DirectionalColor  : direct light on peds/vehicles
-- Illumination      : directional light multiplier
-- ShadowStrength    : shadow alpha (0-255)
-- PoleShadowStrength: pole shadow alpha (0-255)
-- Foggyness         : headlight/ground fog alpha (0-1)

local WORLD_KEYS = {
    "AmbientColor", "AmbientObjColor", "DirectionalColor",
    "Illumination", "ShadowStrength", "PoleShadowStrength", "Foggyness",
}
local worldGradeActive = false

local FOGGYNESS = {
    foggy = 0.28,
    morning_mist = 0.14,
    light_rain = 0.07,
    heavy_rain = 0.14,
    thunderstorm = 0.18,
    overcast = 0.03,
}

local function resetWorldGrade()
    if not worldGradeActive then return end
    worldGradeActive = false
    if type(resetWorldProperties) == "function" then
        pcall(resetWorldProperties)
        return
    end
    if type(resetWorldProperty) == "function" then
        for _, key in ipairs(WORLD_KEYS) do
            pcall(resetWorldProperty, key)
        end
    end
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function mixColor(a, b, t)
    return {
        lerp(a[1], b[1], t),
        lerp(a[2], b[2], t),
        lerp(a[3], b[3], t),
    }
end

-- Neutral light curve: cool blue night, white daylight, no orange phase.
local LIGHT_KEYS = {
    { h = 0.0,  amb = { 48, 53, 70 },   dir = { 26, 31, 48 },    illum = 0.30, shadow = 120, pole = 150 },
    { h = 4.5,  amb = { 48, 53, 70 },   dir = { 26, 31, 48 },    illum = 0.30, shadow = 120, pole = 150 },
    { h = 6.5,  amb = { 130, 135, 148 }, dir = { 185, 190, 205 }, illum = 0.82, shadow = 165, pole = 175 },
    { h = 9.0,  amb = { 158, 162, 170 }, dir = { 220, 223, 230 }, illum = 1.00, shadow = 185, pole = 185 },
    { h = 16.0, amb = { 158, 162, 170 }, dir = { 220, 223, 230 }, illum = 1.00, shadow = 185, pole = 185 },
    { h = 18.5, amb = { 120, 125, 138 }, dir = { 170, 175, 190 }, illum = 0.75, shadow = 155, pole = 170 },
    { h = 20.5, amb = { 55, 60, 78 },   dir = { 32, 38, 56 },    illum = 0.35, shadow = 125, pole = 155 },
    { h = 24.0, amb = { 48, 53, 70 },   dir = { 26, 31, 48 },    illum = 0.30, shadow = 120, pole = 150 },
}

local function lightAt(hour)
    hour = hour % 24
    local from, to = LIGHT_KEYS[1], LIGHT_KEYS[#LIGHT_KEYS]
    for i = 1, #LIGHT_KEYS - 1 do
        local a, b = LIGHT_KEYS[i], LIGHT_KEYS[i + 1]
        if hour >= a.h and hour <= b.h then
            from, to = a, b
            break
        end
    end
    local span = to.h - from.h
    local t = span > 0 and (hour - from.h) / span or 0
    t = t * t * (3 - 2 * t) -- smoothstep, no visible stepping at 30 s sync
    return {
        amb = mixColor(from.amb, to.amb, t),
        dir = mixColor(from.dir, to.dir, t),
        illum = lerp(from.illum, to.illum, t),
        shadow = lerp(from.shadow, to.shadow, t),
        pole = lerp(from.pole, to.pole, t),
    }
end

local function applyWorldGrade(hour, weatherKey)
    if type(setWorldProperty) ~= "function" then return end
    local g = lightAt(tonumber(hour) or 12)
    local foggy = FOGGYNESS[weatherKey] or 0.0
    local ok = pcall(function()
        setWorldProperty("AmbientColor",
            math.floor(g.amb[1] + 0.5), math.floor(g.amb[2] + 0.5), math.floor(g.amb[3] + 0.5))
        setWorldProperty("AmbientObjColor",
            math.floor(g.amb[1] + 0.5), math.floor(g.amb[2] + 0.5), math.floor(g.amb[3] + 0.5))
        setWorldProperty("DirectionalColor",
            math.floor(g.dir[1] + 0.5), math.floor(g.dir[2] + 0.5), math.floor(g.dir[3] + 0.5))
        setWorldProperty("Illumination", g.illum)
        setWorldProperty("ShadowStrength", math.floor(g.shadow + 0.5))
        setWorldProperty("PoleShadowStrength", math.floor(g.pole + 0.5))
        setWorldProperty("Foggyness", foggy)
    end)
    if ok then
        worldGradeActive = true
    end
end

local function applyTime(s)
    local h = math.floor(clamp(s.hour, 0, 23))
    local m = math.floor(clamp(s.minute, 0, 59))
    local minuteMs = clamp(s.minuteMs or 10000, 3000, 600000)
    setMinuteDuration(minuteMs)
    setTime(h, m)
end

local function applyState(s, force)
    if not validState(s) then return end
    currentState = s

    if not inOpenWorld() then
        -- Interiors and the character creator keep their own lighting; never
        -- leave the open-world timecyc override active in there.
        resetWorldGrade()
        return
    end

    local weatherId = tonumber(s.weather) or 0
    weatherId = math.floor(clamp(weatherId, 0, 255))

    if force or appliedKey ~= s.key or tonumber(getWeather()) ~= weatherId then
        setWeather(weatherId)
        appliedKey = s.key
    end

    applyTime(s)

    -- Neutral ambient/directional light after the clock is set. s_weather
    -- broadcasts a fresh state every 30 s, so the curve is re-evaluated
    -- continuously as the in-game day advances.
    applyWorldGrade((tonumber(s.hour) or 12) + (tonumber(s.minute) or 0) / 60, s.key)

    if s.sunA and s.sunB then
        setSunColor(
            math.floor(clamp(s.sunA[1], 0, 255)), math.floor(clamp(s.sunA[2], 0, 255)), math.floor(clamp(s.sunA[3], 0, 255)),
            math.floor(clamp(s.sunB[1], 0, 255)), math.floor(clamp(s.sunB[2], 0, 255)), math.floor(clamp(s.sunB[3], 0, 255))
        )
    end
    if tonumber(s.sunSize) then
        setSunSize(clamp(s.sunSize, 0.0, 10.0))
    end
    if s.skyTop and s.skyBottom then
        setSkyGradient(
            math.floor(clamp(s.skyTop[1], 0, 255)), math.floor(clamp(s.skyTop[2], 0, 255)), math.floor(clamp(s.skyTop[3], 0, 255)),
            math.floor(clamp(s.skyBottom[1], 0, 255)), math.floor(clamp(s.skyBottom[2], 0, 255)), math.floor(clamp(s.skyBottom[3], 0, 255))
        )
    end
    if s.wind then
        setWindVelocity(clamp(s.wind[1], -50, 50), clamp(s.wind[2], -50, 50), clamp(s.wind[3], -50, 50))
    end

    beginRainTransition(s.rain or 0.0, s.transition or 0)
end

local function requestState()
    if isElement(localPlayer) then
        triggerServerEvent("luxuryWeather:request", localPlayer)
    end
end

local function readRootState()
    local raw = getElementData(root, "luxury.weather")
    if type(raw) ~= "string" or raw == "" then return nil end
    local ok, s = pcall(fromJSON, raw)
    if ok and validState(s) then return s end
    return nil
end

-- ------------------------------------------------------------------
-- Events
-- ------------------------------------------------------------------

addEvent("luxuryWeather:state", true)
addEvent("luxuryWeather:time", true)
addEvent("luxuryWeather:request", false)

addEventHandler("luxuryWeather:state", root, function(s)
    if not validState(s) then return end
    local ts = tonumber(s.timestamp) or 0
    if ts > 0 and ts < lastTimestamp then return end
    if ts > 0 then lastTimestamp = ts end
    applyState(s, false)
end)

addEventHandler("luxuryWeather:time", root, function(t)
    if type(t) ~= "table" then return end
    if not inOpenWorld() then
        resetWorldGrade()
        return
    end
    applyTime({
        hour = t.hour,
        minute = t.minute,
        minuteMs = t.minuteMs,
    })
    applyWorldGrade((tonumber(t.hour) or 12) + (tonumber(t.minute) or 0) / 60,
        currentState and currentState.key or nil)
end)

addEventHandler("onClientElementDataChange", root, function(key, oldValue, newValue)
    if source ~= localPlayer then return end
    if key == "char.spawned" then
        if newValue == true then
            if inOpenWorld() then
                local s = currentState or readRootState()
                if s then applyState(s, true) end
            end
            requestState()
        end
    end
end)

addEventHandler("onClientElementDataChange", root, function(key)
    if source ~= root or key ~= "luxury.weather" then return end
    local s = readRootState()
    if not s then return end
    local ts = tonumber(s.timestamp) or 0
    if ts > 0 and ts < lastTimestamp then return end
    if ts > 0 then lastTimestamp = ts end
    applyState(s, false)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    local s = readRootState()
    if s then
        currentState = s
        applyState(s, true)
    end
    setTimer(requestState, 1200, 1)

    local wasOutside = false
    setTimer(function()
        local outside = inOpenWorld()
        if outside and not wasOutside and currentState then
            -- we just left the creator / an interior: re-apply the live state
            applyState(currentState, true)
            requestState()
        elseif wasOutside and not outside then
            -- we just entered an interior: drop the open-world light override
            resetWorldGrade()
        end
        wasOutside = outside
    end, 1500, 0)

    setTimer(function()
        if inOpenWorld() then requestState() end
    end, 15000, 0)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    stopRainTransition()
    resetWorldGrade()
    if isElement(localPlayer) then
        resetRainLevel()
    end
end)
