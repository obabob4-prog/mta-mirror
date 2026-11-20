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
        return -- creator/login/interiors keep their own environment
    end

    local weatherId = tonumber(s.weather) or 0
    weatherId = math.floor(clamp(weatherId, 0, 255))

    if force or appliedKey ~= s.key or tonumber(getWeather()) ~= weatherId then
        setWeather(weatherId)
        appliedKey = s.key
    end

    applyTime(s)

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

addEvent("luxuryWeather:state", false)
addEvent("luxuryWeather:time", false)
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
    if not inOpenWorld() then return end
    applyTime({
        hour = t.hour,
        minute = t.minute,
        minuteMs = t.minuteMs,
    })
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
        end
        wasOutside = outside
    end, 1500, 0)

    setTimer(function()
        if inOpenWorld() then requestState() end
    end, 15000, 0)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    stopRainTransition()
    if isElement(localPlayer) then
        resetRainLevel()
    end
end)
