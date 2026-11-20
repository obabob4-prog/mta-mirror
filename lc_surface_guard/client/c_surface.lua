--[[
    lc_surface_guard / client side
    ---------------------------------------------------------------
    LC collision is client-side, so this is where the work happens.

    Every SCAN_INTERVAL ms a small grid around the local player is probed:

      * no surface + no water                -> VOID      (visible road patch)
      * thin strip with nothing underneath   -> THIN      (visible road patch)
      * second surface within 8 cm           -> OVERLAP   (hide exact duplicate)

    Patches are real road-tile objects (model 4544, the flat rd_road2a20 tile
    that is already part of Liberty City), scaled down, collision enabled and
    recycled once the player moves away.  Nothing is created in water, in an
    interior or in a non-zero dimension, and no other resource is edited.
]]

local ENABLED       = true
local SCAN_INTERVAL = 4000
local RADIUS        = 10         -- 10 cells * 4 m = 40 m around the player
local STEP          = 4.0
local MAX_PATCHES   = 240
local RECYCLE_DIST  = 110
local PATCH_MODEL   = 4544       -- rd_road2a20 flat road tile; 1337 is the fallback
local FALLBACK_MODEL = 1337      -- always loaded stock cube, invisible collision floor

local RAY_TOP       = 10.0
local RAY_BOTTOM    = -14.0

local patches = {}               -- cellKey -> element
local hidden  = {}               -- element -> original z
local patchCount = 0
local lastReport = 0

local function cellKey(x, y)
    return ("%d|%d"):format(math.floor(x / STEP), math.floor(y / STEP))
end

local function rayDown(x, y, fromDz, toDz)
    local px, py, pz = getElementPosition(localPlayer)
    local ok, hit, hx, hy, hz, element = pcall(processLineOfSight,
        x, y, pz + fromDz, x, y, pz + toDz,
        true, false, false, true, false, false, false, false, nil, false)
    if not ok or not hit then return nil end
    return hz, element
end

local function isWater(x, y)
    local ok, level = pcall(getWaterLevel, x, y, 4, true)
    return ok and level and level > -20
end

local function sizeOf(element)
    if not isElement(element) then return nil end
    local ok, minX, minY, minZ, maxX, maxY, maxZ = pcall(getElementBoundingBox, element)
    if not ok or type(minX) ~= "number" then return nil end
    return maxX - minX, maxY - minY, maxZ - minZ
end

local function makePatch(x, y, z, rotZ)
    local key = cellKey(x, y)
    if patches[key] and isElement(patches[key]) then return false end

    if patchCount >= MAX_PATCHES then
        -- recycle far-away patches before creating more
        local removed = 0
        for k, element in pairs(patches) do
            if isElement(element) then
                local ex, ey = getElementPosition(element)
                local px, py = getElementPosition(localPlayer)
                if (ex - px) ^ 2 + (ey - py) ^ 2 > RECYCLE_DIST ^ 2 then
                    destroyElement(element)
                    patches[k] = nil
                    patchCount = patchCount - 1
                    removed = removed + 1
                    if removed >= 8 then break end
                end
            else
                patches[k] = nil
                patchCount = patchCount - 1
            end
        end
        if patchCount >= MAX_PATCHES then return false end
    end

    local element = createObject(PATCH_MODEL, x, y, z - 0.06, 0, 0, rotZ or 0)
    local fallback = false
    if not isElement(element) then
        element = createObject(FALLBACK_MODEL, x, y, z - 0.10, 0, 0, rotZ or 0)
        fallback = true
    end
    if not isElement(element) then return false end
    if setObjectScale then setObjectScale(element, 0.15, 0.15, fallback and 0.5 or 1.0) end
    setElementAlpha(element, fallback and 0 or 255)
    setElementCollisionsEnabled(element, true)
    setElementDimension(element, 0)
    setElementInterior(element, 0)
    patches[key] = element
    patchCount = patchCount + 1
    return true
end

local function clearPatches()
    for k, element in pairs(patches) do
        if isElement(element) then destroyElement(element) end
        patches[k] = nil
    end
    patchCount = 0
    for element, z in pairs(hidden) do
        if isElement(element) then
            local x, y = getElementPosition(element)
            setElementPosition(element, x, y, z)
        end
        hidden[element] = nil
    end
    outputDebugString("[LC-Surface] all patches cleared", 3)
end

local function nearestGround(results, cx, cy, step)
    local bestZ, bestD = nil, math.huge
    for _, r in ipairs(results) do
        if r.z and not r.void then
            local d = (r.x - cx) ^ 2 + (r.y - cy) ^ 2
            if d < bestD then bestD, bestZ = d, r.z end
        end
    end
    if bestZ then return bestZ end
    local _, _, pz = getElementPosition(localPlayer)
    return pz - 0.4
end

local function hideDuplicate(element)
    if not isElement(element) or hidden[element] then return false end
    local x, y, z = getElementPosition(element)
    hidden[element] = z
    setElementAlpha(element, 0)
    setElementCollisionsEnabled(element, false)
    return true
end

local function scan()
    if not ENABLED then return end
    if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return end

    local px, py = getElementPosition(localPlayer)
    local results = {}
    local voids, thin, overlaps = 0, 0, 0

    for ix = -RADIUS, RADIUS do
        for iy = -RADIUS, RADIUS do
            local x = px + ix * STEP
            local y = py + iy * STEP
            local r = { x = x, y = y, ix = ix, iy = iy }
            local hz, element = rayDown(x, y, RAY_TOP, RAY_BOTTOM)
            if not hz then
                if not isWater(x, y) then
                    r.void = true
                    voids = voids + 1
                end
            else
                r.z = hz
                r.element = element
                r.rot = 0
                if isElement(element) then
                    local _, _, rz = getElementRotation(element)
                    r.rot = rz or 0
                end

                -- overlapping surfaces within 8 cm
                local hz2, element2 = rayDown(x, y, -0.02, -0.45)
                if hz2 and (hz - hz2) < 0.5 then
                    local sx1, sy1, sz1 = sizeOf(element)
                    local sx2, sy2, sz2 = sizeOf(element2)
                    if sx1 and sx2
                       and math.abs(sx1 - sx2) < 0.3
                       and math.abs(sy1 - sy2) < 0.3
                       and math.abs(sz1 - sz2) < 0.3 then
                        if hideDuplicate(element2) then overlaps = overlaps + 1 end
                    end
                end

                -- thin strip with genuine void underneath
                local hz3 = rayDown(x, y, -0.25, -4.0)
                if not hz3 and not isWater(x, y) then
                    local sx, sy, sz = sizeOf(element)
                    if sz and sz <= 0.6 then
                        r.thin = true
                        thin = thin + 1
                    end
                end
            end
            results[#results + 1] = r
        end
    end

    local created = 0
    for _, r in ipairs(results) do
        if r.void or r.thin then
            local z = r.z or nearestGround(results, r.x, r.y, STEP)
            if makePatch(r.x, r.y, z, r.rot) then created = created + 1 end
        end
    end

    -- recycle patches that are far behind us
    for k, element in pairs(patches) do
        if not isElement(element) then
            patches[k] = nil
            patchCount = patchCount - 1
        else
            local ex, ey = getElementPosition(element)
            if (ex - px) ^ 2 + (ey - py) ^ 2 > RECYCLE_DIST ^ 2 then
                destroyElement(element)
                patches[k] = nil
                patchCount = patchCount - 1
            end
        end
    end
    if patchCount < 0 then patchCount = 0 end

    -- restore hidden duplicates once we leave the area
    for element, z in pairs(hidden) do
        if not isElement(element) then
            hidden[element] = nil
        else
            local ex, ey = getElementPosition(element)
            if (ex - px) ^ 2 + (ey - py) ^ 2 > RECYCLE_DIST ^ 2 then
                setElementPosition(element, ex, ey, z)
                setElementAlpha(element, 255)
                setElementCollisionsEnabled(element, true)
                hidden[element] = nil
            end
        end
    end

    local now = getTickCount()
    if now - lastReport > 10000 and (created > 0 or overlaps > 0) then
        lastReport = now
        if created > 0 then
            triggerServerEvent("lcSG:report", localPlayer, "void", created, patchCount)
        end
        if overlaps > 0 then
            triggerServerEvent("lcSG:report", localPlayer, "overlap", overlaps, patchCount)
        end
    end

    return created, overlaps
end

-- Fast local fall guard.  The grid scan above finds holes before you reach
-- them; this one catches the case where collision simply is not there when
-- you step onto it (LC streams geometry late, leaving a half-buried ped).
local lastSafeZ = 13.9
-- The character database still stores the old reception point (-200/-208,
-- 1136, 13.9), which is a bare void between the police lot and the road.
-- Lifting the ped in place there only makes it blink half-buried forever, so
-- a fall inside that zone relocates it to the verified rd_road1a10 tile.
local RESCUE_X, RESCUE_Y, RESCUE_Z = -224.23, 1146.18, 14.05
local VOID_X, VOID_Y, VOID_R2 = -208.0, 1136.0, 45 * 45
local lastRecover = 0

local function fallGuard()
    if not ENABLED or not isElement(localPlayer) then return end
    if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return end
    if isPedDead(localPlayer) or getElementAlpha(localPlayer) == 0 then return end

    local px, py, pz = getElementPosition(localPlayer)
    local ok, hit, _, _, hz = pcall(processLineOfSight,
        px, py, pz + 15.0, px, py, pz - 40.0,
        true, false, false, true, false, false, false, false, nil, false)

    local function recover(z)
        local now = getTickCount()
        if now - lastRecover < 2000 then return end
        lastRecover = now

        local inOldVoid = (px - VOID_X) ^ 2 + (py - VOID_Y) ^ 2 <= VOID_R2
        if inOldVoid then
            setElementPosition(localPlayer, RESCUE_X, RESCUE_Y, RESCUE_Z)
        else
            makePatch(px, py, z, 0)
            setElementPosition(localPlayer, px, py, z + 1.05)
        end
        setElementVelocity(localPlayer, 0, 0, 0)
        triggerServerEvent("lcSG:report", localPlayer, inOldVoid and "void-rescue" or "fall", 1, patchCount)
    end

    if ok and hit and hz then
        if pz > -20 then lastSafeZ = hz end
        if pz < hz - 1.0 then recover(hz) end
    elseif not isWater(px, py) and pz < 3.0 then
        recover(lastSafeZ)
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(scan, SCAN_INTERVAL, 0)
    setTimer(fallGuard, 300, 0)
    -- One startup ack lets the server prove the client half is really live.
    triggerServerEvent("lcSG:report", localPlayer, "startup", 1, 0)
    outputDebugString("[LC-Surface] guard active (grid " .. (RADIUS * 2 + 1) .. "x" .. (RADIUS * 2 + 1) .. ")", 3)
end)

addEvent("lcSG:command", true)
addEventHandler("lcSG:command", localPlayer, function(action)
    if action == "toggle" then
        ENABLED = not ENABLED
        outputChatBox("[LC-Surface] guard " .. (ENABLED and "ENABLED" or "DISABLED"), 212, 175, 55)
    elseif action == "clear" then
        clearPatches()
    elseif action == "scan" then
        local created, overlaps = scan()
        triggerServerEvent("lcSG:report", localPlayer, "manual", created + overlaps, patchCount)
        outputChatBox(("[LC-Surface] manual scan: created=%d overlaps=%d patches=%d"):format(created, overlaps, patchCount), 212, 175, 55)
    end
end)

addCommandHandler("lcsurfacescan", function()
    local created, overlaps = scan()
    triggerServerEvent("lcSG:report", localPlayer, "manual", created + overlaps, patchCount)
    outputChatBox(("[LC-Surface] manual scan: created=%d overlaps=%d patches=%d"):format(created, overlaps, patchCount), 212, 175, 55)
end)
