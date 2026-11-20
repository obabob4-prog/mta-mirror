--[[
    [LuxuryCars] Engine Sound System  v1.0
    ---------------------------------------
    Sounds: CC0 (public domain) loop pack - OpenGameArt "racing car engine sound loops"
    Replaces/overlays the engine sound for the 40 vehicles of Luxury_Vehicles_Pack.

    How it works:
      * A looping 3D sound is attached (position-synced) to every configured nearby vehicle.
      * Playback speed (pitch) follows vehicle speed -> feels like a real revving engine.
      * Only streamed-in vehicles within MAX_DISTANCE are processed (low CPU cost).

    Tuning: edit the CONFIG table below (volume / pitch / maxSpeed per model).
]]

local SOUND_FILES = {
    v8_super   = "sounds/engine_v8_super.wav",    -- V8 twin-turbo supercars
    v12_hyper  = "sounds/engine_v12_hyper.wav",   -- V12 / W16 hypercars
    turbo_i6   = "sounds/engine_turbo_i6.wav",    -- turbo inline-6 tuners
    flat6      = "sounds/engine_flat6.wav",       -- flat-6 sports cars
    v8_suv     = "sounds/engine_v8_suv.wav",      -- V8 lux/SUV
}

-- modelId = { sound, volume, minPitch, maxPitch, maxSpeed(km/h for full pitch) }
local CONFIG = {
    -- ===== Lamborghini =====
    [411] = { snd = "v12_hyper", vol = 0.75, minPitch = 0.55, maxPitch = 2.10, maxSpeed = 330 }, -- Aventador
    [602] = { snd = "v12_hyper", vol = 0.75, minPitch = 0.55, maxPitch = 2.15, maxSpeed = 340 }, -- Revuelto
    [424] = { snd = "v8_suv",    vol = 0.65, minPitch = 0.50, maxPitch = 1.85, maxSpeed = 300 }, -- Urus
    [402] = { snd = "v8_super",  vol = 0.75, minPitch = 0.55, maxPitch = 2.05, maxSpeed = 325 }, -- Huracan
    [533] = { snd = "v12_hyper", vol = 0.75, minPitch = 0.55, maxPitch = 2.05, maxSpeed = 340 }, -- Murcielago

    -- ===== Ferrari =====
    [451] = { snd = "v8_super",  vol = 0.75, minPitch = 0.55, maxPitch = 2.00, maxSpeed = 330 }, -- SF90
    [415] = { snd = "v8_super",  vol = 0.75, minPitch = 0.55, maxPitch = 2.00, maxSpeed = 320 }, -- F8 Tributo
    [405] = { snd = "v8_super",  vol = 0.75, minPitch = 0.55, maxPitch = 2.00, maxSpeed = 320 }, -- 488 GTB
    [536] = { snd = "v12_hyper", vol = 0.75, minPitch = 0.55, maxPitch = 2.10, maxSpeed = 350 }, -- LaFerrari

    -- ===== Bugatti =====
    [541] = { snd = "v12_hyper", vol = 0.80, minPitch = 0.50, maxPitch = 2.20, maxSpeed = 420 }, -- Chiron
    [535] = { snd = "v12_hyper", vol = 0.80, minPitch = 0.50, maxPitch = 2.20, maxSpeed = 410 }, -- Veyron SS
    [534] = { snd = "v12_hyper", vol = 0.80, minPitch = 0.50, maxPitch = 2.20, maxSpeed = 380 }, -- Divo

    -- ===== Rolls-Royce =====
    [400] = { snd = "v8_suv",    vol = 0.55, minPitch = 0.45, maxPitch = 1.55, maxSpeed = 250 }, -- Cullinan
    [409] = { snd = "v12_hyper", vol = 0.50, minPitch = 0.45, maxPitch = 1.50, maxSpeed = 240 }, -- Phantom Limo
    [445] = { snd = "v12_hyper", vol = 0.55, minPitch = 0.45, maxPitch = 1.60, maxSpeed = 250 }, -- Wraith

    -- ===== Mercedes =====
    [429] = { snd = "v8_suv",    vol = 0.70, minPitch = 0.50, maxPitch = 1.95, maxSpeed = 310 }, -- AMG GT63S
    [579] = { snd = "v8_suv",    vol = 0.70, minPitch = 0.50, maxPitch = 1.75, maxSpeed = 220 }, -- G63
    [421] = { snd = "v8_suv",    vol = 0.55, minPitch = 0.45, maxPitch = 1.60, maxSpeed = 250 }, -- S-Class Coupe
    [410] = { snd = "v8_suv",    vol = 0.65, minPitch = 0.50, maxPitch = 1.90, maxSpeed = 290 }, -- C63
    [412] = { snd = "v8_suv",    vol = 0.65, minPitch = 0.50, maxPitch = 1.90, maxSpeed = 300 }, -- E63S

    -- ===== BMW =====
    [558] = { snd = "turbo_i6",  vol = 0.65, minPitch = 0.55, maxPitch = 1.95, maxSpeed = 290 }, -- M4
    [560] = { snd = "turbo_i6",  vol = 0.65, minPitch = 0.55, maxPitch = 1.95, maxSpeed = 305 }, -- M5 F90
    [419] = { snd = "turbo_i6",  vol = 0.65, minPitch = 0.55, maxPitch = 1.95, maxSpeed = 290 }, -- M3
    [561] = { snd = "turbo_i6",  vol = 0.65, minPitch = 0.55, maxPitch = 1.95, maxSpeed = 305 }, -- M8
    [422] = { snd = "v8_suv",    vol = 0.60, minPitch = 0.50, maxPitch = 1.75, maxSpeed = 260 }, -- X6M

    -- ===== Porsche =====
    [559] = { snd = "flat6",     vol = 0.75, minPitch = 0.55, maxPitch = 2.10, maxSpeed = 315 }, -- GT3 RS
    [475] = { snd = "flat6",     vol = 0.70, minPitch = 0.55, maxPitch = 2.00, maxSpeed = 345 }, -- 918 Spyder
    [496] = { snd = "flat6",     vol = 0.70, minPitch = 0.55, maxPitch = 1.95, maxSpeed = 295 }, -- Cayman GT4

    -- ===== McLaren =====
    [506] = { snd = "v8_super",  vol = 0.75, minPitch = 0.55, maxPitch = 2.05, maxSpeed = 340 }, -- 720S
    [603] = { snd = "v8_super",  vol = 0.75, minPitch = 0.55, maxPitch = 2.05, maxSpeed = 350 }, -- P1
    [546] = { snd = "v8_super",  vol = 0.75, minPitch = 0.55, maxPitch = 2.05, maxSpeed = 330 }, -- 600LT

    -- ===== Other =====
    [562] = { snd = "turbo_i6",  vol = 0.70, minPitch = 0.55, maxPitch = 1.95, maxSpeed = 310 }, -- GT-R R35
    [470] = { snd = "v8_suv",    vol = 0.55, minPitch = 0.45, maxPitch = 1.65, maxSpeed = 250 }, -- Range Rover Sport
    [565] = { snd = "v8_suv",    vol = 0.65, minPitch = 0.50, maxPitch = 1.90, maxSpeed = 305 }, -- RS7
    [477] = { snd = "turbo_i6",  vol = 0.65, minPitch = 0.55, maxPitch = 1.90, maxSpeed = 285 }, -- Supra MK4
    [551] = { snd = "turbo_i6",  vol = 0.65, minPitch = 0.55, maxPitch = 1.90, maxSpeed = 285 }, -- Supra A90
    [587] = { snd = "v8_super",  vol = 0.70, minPitch = 0.55, maxPitch = 1.95, maxSpeed = 315 }, -- R8
    [589] = { snd = "turbo_i6",  vol = 0.65, minPitch = 0.55, maxPitch = 1.90, maxSpeed = 280 }, -- TT RS
    [580] = { snd = "turbo_i6",  vol = 0.70, minPitch = 0.55, maxPitch = 1.95, maxSpeed = 300 }, -- R34
    [547] = { snd = "v8_super",  vol = 0.70, minPitch = 0.55, maxPitch = 1.95, maxSpeed = 310 }, -- NSX
}

local MAX_DISTANCE = 90      -- metres: process vehicles closer than this
local SCAN_INTERVAL = 400    -- ms: scan for new nearby luxury vehicles
local TICK_INTERVAL = 100    -- ms: position/pitch update
local MAX_ACTIVE = 20        -- hard cap to protect FPS

local active = {}            -- [vehicle] = { sound = sound, cfg = table, speed = number }
local scanTimer, tickTimer

local function getSpeedKmh(veh)
    local vx, vy, vz = getElementVelocity(veh)
    return math.sqrt(vx * vx + vy * vy + vz * vz) * 180
end

local function distToLocalPlayer(veh)
    local x1, y1, z1 = getElementPosition(veh)
    local x2, y2, z2 = getElementPosition(localPlayer)
    return getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2), x1, y1, z1
end

local function startVehicleSound(veh, cfg, x, y, z)
    local snd = playSound3D(SOUND_FILES[cfg.snd], x, y, z, true)
    if not snd then return false end
    setSoundMaxDistance(snd, MAX_DISTANCE + 30)
    setSoundMinDistance(snd, 5)
    setSoundVolume(snd, cfg.vol)
    setSoundSpeed(snd, cfg.minPitch)
    setElementInterior(snd, getElementInterior(veh))
    setElementDimension(snd, getElementDimension(veh))
    active[veh] = { sound = snd, cfg = cfg }
    return true
end

local function stopVehicleSound(veh, snd)
    if snd and isElement(snd) then destroyElement(snd) end
    active[veh] = nil
end

local function stopAll()
    for veh, data in pairs(active) do
        if data.sound and isElement(data.sound) then destroyElement(data.sound) end
        active[veh] = nil
    end
end

local function scan()
    local count = 0
    for _, d in pairs(active) do count = count + 1 end
    if count >= MAX_ACTIVE then return end

    for _, veh in ipairs(getElementsByType("vehicle")) do
        if count >= MAX_ACTIVE then break end
        if not active[veh] and isElementStreamedIn(veh) then
            local cfg = CONFIG[getElementModel(veh)]
            if cfg and getVehicleEngineState(veh) then
                local dist, x, y, z = distToLocalPlayer(veh)
                if dist < MAX_DISTANCE then
                    if startVehicleSound(veh, cfg, x, y, z) then count = count + 1 end
                end
            end
        end
    end
end

local function tick()
    for veh, data in pairs(active) do
        local snd = data.sound
        if not isElement(veh) or not isElement(snd) then
            active[veh] = nil
        elseif not isElementStreamedIn(veh) or not getVehicleEngineState(veh) then
            stopVehicleSound(veh, snd)
        else
            local dist, x, y, z = distToLocalPlayer(veh)
            if dist > MAX_DISTANCE + 35 then
                stopVehicleSound(veh, snd)
            else
                setElementPosition(snd, x, y, z)
                local cfg = data.cfg
                local speed = math.max(0, getSpeedKmh(veh))
                local ratio = math.min(1, speed / cfg.maxSpeed)
                local targetPitch = cfg.minPitch + (cfg.maxPitch - cfg.minPitch) * ratio
                -- smooth pitch changes to avoid harsh fluctuations
                local currentPitch = getSoundSpeed(snd) or targetPitch
                local smooth = currentPitch + (targetPitch - currentPitch) * 0.35
                setSoundSpeed(snd, smooth)
                setElementInterior(snd, getElementInterior(veh))
                setElementDimension(snd, getElementDimension(veh))
            end
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    scan()
    scanTimer = setTimer(scan, SCAN_INTERVAL, 0)
    tickTimer = setTimer(tick, TICK_INTERVAL, 0)
    outputDebugString("[LuxuryCars] Engine sound system started")
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if scanTimer and isTimer(scanTimer) then killTimer(scanTimer) end
    if tickTimer and isTimer(tickTimer) then killTimer(tickTimer) end
    stopAll()
end)

addEventHandler("onClientVehicleExplode", root, function()
    if active[source] then stopVehicleSound(source, active[source].sound) end
end)
