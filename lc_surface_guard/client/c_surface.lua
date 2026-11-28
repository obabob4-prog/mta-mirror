--[[
    lc_surface_guard / client side
    ---------------------------------------------------------------
    Runtime guard against Liberty City map issues:
      * missing collision / voids / thin strips  -> solid ground patches
      * exact duplicate overlapping objects       -> hide duplicate copy
      * z-fighting duplicate surfaces            -> nudge lower copy down

    This complements source-data fixes: LC collision is client-side and streams
    dynamically, so the guard keeps the playable world stable around the player.
]]

local ENABLED         = true
local SCAN_INTERVAL   = 1800
local MOVE_SCAN_DIST  = 8.0
local RADIUS          = 11         -- 11 cells * 4 m ~= 44 m around the player
local STEP            = 4.0
local MAX_PATCHES     = 700
local RECYCLE_DIST    = 130
local PATCH_MODEL     = 4544       -- rd_road2a20 flat road tile
local FALLBACK_MODEL  = 1337       -- always-loaded stock fallback

local RAY_TOP         = 12.0
local RAY_BOTTOM      = -18.0

local patches = {}               -- cellKey -> { element = obj, x=, y=, auto= }
local nudged  = {}               -- element -> { x, y, z }
local hidden  = {}               -- element -> { x, y, z }
local patchCount = 0
local lastReport = 0
local lastScanPos = nil
local staticFloors = {}
local wasWorldReady = false

-- LC is streamed in asynchronously by eagleLoader. On a cold client the first
-- few seconds have no map elements at all, so a raycast sees "void" everywhere.
-- The old guard turned those false voids into ~hundreds of road tiles laid on
-- top of the real city, which looked like two cities overlapping until the
-- player rejoined. Never auto-scan until the map is actually present.
local WORLD_READY_MIN_BUILDINGS = 1500

local function worldReady()
    local ok, builds = pcall(getElementsByType, "building")
    return ok and type(builds) == "table" and #builds >= WORLD_READY_MIN_BUILDINGS
end

local RESCUE_X, RESCUE_Y, RESCUE_Z = -224.23, 1146.18, 14.05
local VOID_X, VOID_Y, VOID_R2 = -208.0, 1136.0, 50 * 50

local function cellKey(x, y)
    return ("%d|%d"):format(math.floor(x / STEP), math.floor(y / STEP))
end

local function dist2(ax, ay, bx, by)
    local dx, dy = ax - bx, ay - by
    return dx * dx + dy * dy
end

local function rayDown(x, y, fromDz, toDz, ignored)
    local px, py, pz = getElementPosition(localPlayer)
    local ok, hit, hx, hy, hz, element = pcall(processLineOfSight,
        x, y, pz + fromDz, x, y, pz + toDz,
        true, false, false, true, false, false, false, false, ignored, false)
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

local function prunePatches(px, py, need)
    local farDist2 = RECYCLE_DIST * RECYCLE_DIST
    for k, entry in pairs(patches) do
        local element = entry and entry.element
        if not element or not isElement(element) then
            patches[k] = nil
            patchCount = patchCount - 1
        else
            local ex, ey = getElementPosition(element)
            entry.x, entry.y = ex, ey
            if dist2(ex, ey, px, py) > farDist2 then
                destroyElement(element)
                patches[k] = nil
                patchCount = patchCount - 1
            end
        end
    end

    while patchCount >= (MAX_PATCHES - (need or 0)) do
        local farthestKey, farthestD2 = nil, -1
        for k, entry in pairs(patches) do
            local d2 = dist2(entry.x or px, entry.y or py, px, py)
            if d2 > farthestD2 then
                farthestD2 = d2
                farthestKey = k
            end
        end
        if not farthestKey then break end
        local element = patches[farthestKey] and patches[farthestKey].element
        if isElement(element) then destroyElement(element) end
        patches[farthestKey] = nil
        patchCount = patchCount - 1
    end

    if patchCount < 0 then patchCount = 0 end
end

local function makePatch(x, y, z, rotZ, auto)
    local key = cellKey(x, y)
    local existing = patches[key]
    if existing and isElement(existing.element) then return false end
    if existing then
        patches[key] = nil
        patchCount = patchCount - 1
    end

    local px, py = getElementPosition(localPlayer)
    if patchCount >= MAX_PATCHES then
        prunePatches(px, py, 1)
    end
    if patchCount >= MAX_PATCHES then return false end

    local element = createObject(PATCH_MODEL, x, y, z - 0.04, 0, 0, rotZ or 0)
    local fallback = false
    if not isElement(element) then
        element = createObject(FALLBACK_MODEL, x, y, z - 0.08, 0, 0, rotZ or 0)
        fallback = true
    end
    if not isElement(element) then return false end

    if setObjectScale then
        setObjectScale(element, 0.16, 0.16, fallback and 0.35 or 1.0)
    end
    setElementAlpha(element, fallback and 0 or 255)
    setElementCollisionsEnabled(element, true)
    setElementDoubleSided(element, true)
    setElementDimension(element, 0)
    setElementInterior(element, 0)

    patches[key] = { element = element, x = x, y = y, auto = auto and true or false }
    patchCount = patchCount + 1
    return true
end

local function clearPatches()
    for k, entry in pairs(patches) do
        local element = entry and entry.element
        if isElement(element) then destroyElement(element) end
        patches[k] = nil
    end
    patchCount = 0

    for element, pos in pairs(hidden) do
        if isElement(element) and pos then
            setElementPosition(element, pos.x, pos.y, pos.z)
            setElementAlpha(element, 255)
            setElementCollisionsEnabled(element, true)
        end
        hidden[element] = nil
    end

    for element, pos in pairs(nudged) do
        if isElement(element) and pos then
            setElementPosition(element, pos.x, pos.y, pos.z)
        end
        nudged[element] = nil
    end
    outputDebugString("[LC-Surface] all runtime fixes cleared", 3)
end

-- Only remove tiles that were guessed from a pre-map "void" scan. Rescue
-- patches created by the fall guard are left alone.
local function clearAutoPatches()
    local removed = 0
    for k, entry in pairs(patches) do
        if entry and entry.auto then
            local element = entry.element
            if isElement(element) then destroyElement(element) end
            patches[k] = nil
            patchCount = patchCount - 1
            removed = removed + 1
        end
    end
    if patchCount < 0 then patchCount = 0 end
    if removed > 0 then
        outputDebugString(("[LC-Surface] removed %d stale pre-map patches"):format(removed), 3)
    end
end

local function nearestGround(results, cx, cy)
    local bestZ, bestD = nil, math.huge
    for _, r in ipairs(results) do
        if r.z and not r.void and not r.thin then
            local d = dist2(r.x, r.y, cx, cy)
            if d < bestD then bestD, bestZ = d, r.z end
        end
    end
    if bestZ then return bestZ end
    local _, _, pz = getElementPosition(localPlayer)
    return pz - 0.5
end

local function hideDuplicate(element)
    if not isElement(element) or hidden[element] or nudged[element] then return false end
    local x, y, z = getElementPosition(element)
    hidden[element] = { x = x, y = y, z = z }
    setElementAlpha(element, 0)
    setElementCollisionsEnabled(element, false)
    return true
end

local function nudgeDown(element, amount)
    if not isElement(element) or hidden[element] or nudged[element] then return false end
    local x, y, z = getElementPosition(element)
    nudged[element] = { x = x, y = y, z = z }
    setElementPosition(element, x, y, z - (amount or 0.04))
    return true
end

local function restoreAdjusted(px, py)
    local farDist2 = RECYCLE_DIST * RECYCLE_DIST

    for element, pos in pairs(hidden) do
        if not isElement(element) or not pos then
            hidden[element] = nil
        elseif dist2(pos.x, pos.y, px, py) > farDist2 then
            setElementPosition(element, pos.x, pos.y, pos.z)
            setElementAlpha(element, 255)
            setElementCollisionsEnabled(element, true)
            hidden[element] = nil
        end
    end

    for element, pos in pairs(nudged) do
        if not isElement(element) or not pos then
            nudged[element] = nil
        elseif dist2(pos.x, pos.y, px, py) > farDist2 then
            setElementPosition(element, pos.x, pos.y, pos.z)
            nudged[element] = nil
        end
    end
end

local function mitigateOverlap(element, element2, gap)
    if not isElement(element) or not isElement(element2) or element == element2 then return false end

    local sx1, sy1, sz1 = sizeOf(element)
    local sx2, sy2, sz2 = sizeOf(element2)

    local sameShape = sx1 and sx2
        and math.abs(sx1 - sx2) < 0.35
        and math.abs(sy1 - sy2) < 0.35
        and math.abs(sz1 - sz2) < 0.35

    if sameShape and gap < 0.20 then
        return hideDuplicate(element2)
    end

    if gap <= 0.08 then
        return nudgeDown(element2, 0.045)
    end

    return false
end

local function createStaticFloor(x, y, z, sx, sy, sz, alpha)
    local element = createObject(FALLBACK_MODEL, x, y, z, 0, 0, 0)
    if not isElement(element) then return nil end
    if setObjectScale then setObjectScale(element, sx or 1.0, sy or 1.0, sz or 0.25) end
    setElementAlpha(element, alpha or 0)
    setElementCollisionsEnabled(element, true)
    setElementDimension(element, 0)
    setElementInterior(element, 0)
    staticFloors[#staticFloors + 1] = element
    return element
end

local function ensureStaticSafetyFloors()
    if #staticFloors > 0 then return end
    -- Verified LC reception/road area (rd_road1a10 / industse). These invisible
    -- floors prevent falling through the old void at (-208,1136) and keep the
    -- nearby road/station approach solid even before streaming/scan catches up.
    createStaticFloor(-224.23, 1146.18, 13.72, 2.6, 8.5, 0.20, 0)
    createStaticFloor(-224.23, 1126.18, 13.72, 2.6, 8.5, 0.20, 0)
    createStaticFloor(-224.23, 1106.18, 13.72, 2.6, 8.5, 0.20, 0)
    createStaticFloor(-208.00, 1136.00, 13.72, 4.2, 4.2, 0.20, 0)
    createStaticFloor(-216.00, 1136.00, 13.72, 2.8, 4.2, 0.20, 0)
    createStaticFloor(-200.00, 1136.00, 13.72, 2.8, 4.2, 0.20, 0)
end

local function scan()
    if not ENABLED then return 0, 0, 0 end
    if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return 0, 0, 0 end

    -- Wait for the LC map; before that every ray is a false void.
    if not worldReady() then return 0, 0, 0 end
    if not wasWorldReady then
        wasWorldReady = true
        clearAutoPatches()
    end

    ensureStaticSafetyFloors()

    local px, py, pz = getElementPosition(localPlayer)
    lastScanPos = { x = px, y = py }

    local results = {}
    local voids, thin, overlaps = 0, 0, 0

    for ix = -RADIUS, RADIUS do
        for iy = -RADIUS, RADIUS do
            local x = px + ix * STEP
            local y = py + iy * STEP
            local r = { x = x, y = y, rot = 0 }
            local hz, element = rayDown(x, y, RAY_TOP, RAY_BOTTOM, nil)

            if not hz then
                if not isWater(x, y) then
                    r.void = true
                    voids = voids + 1
                end
            else
                r.z = hz
                if isElement(element) then
                    local _, _, rz = getElementRotation(element)
                    r.rot = rz or 0
                end

                local hz2, element2 = rayDown(x, y, hz - pz - 0.02, hz - pz - 0.50, element)
                if hz2 and element2 and (hz - hz2) <= 0.50 then
                    if mitigateOverlap(element, element2, hz - hz2) then
                        overlaps = overlaps + 1
                    end
                end

                local hz3 = rayDown(x, y, hz - pz - 0.25, hz - pz - 5.0, element)
                if not hz3 and not isWater(x, y) then
                    local sx, sy, sz = sizeOf(element)
                    if sz and sz <= 0.8 then
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
            local z = r.z or nearestGround(results, r.x, r.y)
            if makePatch(r.x, r.y, z, r.rot, true) then created = created + 1 end
        end
    end

    prunePatches(px, py, 0)
    restoreAdjusted(px, py)

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

    return created, overlaps, thin
end

-- Fast local fall guard.
local lastSafeZ = 13.9
local lastRecover = 0

local function fallGuard()
    if not ENABLED or not isElement(localPlayer) then return end
    if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return end
    if isPedDead(localPlayer) or getElementAlpha(localPlayer) == 0 then return end

    local px, py, pz = getElementPosition(localPlayer)
    local ok, hit, _, _, hz = pcall(processLineOfSight,
        px, py, pz + 20.0, px, py, pz - 60.0,
        true, false, false, true, false, false, false, false, nil, false)

    local function recover(z)
        local now = getTickCount()
        if now - lastRecover < 1200 then return end
        lastRecover = now

        local inOldVoid = dist2(px, py, VOID_X, VOID_Y) <= VOID_R2
        if inOldVoid then
            setElementPosition(localPlayer, RESCUE_X, RESCUE_Y, RESCUE_Z)
        else
            makePatch(px, py, z or lastSafeZ, 0)
            setElementPosition(localPlayer, px, py, (z or lastSafeZ) + 1.05)
        end
        setElementVelocity(localPlayer, 0, 0, 0)
        triggerServerEvent("lcSG:report", localPlayer, inOldVoid and "void-rescue" or "fall", 1, patchCount)
    end

    if ok and hit and hz then
        if pz > -20 then lastSafeZ = hz end
        if pz < hz - 1.2 then recover(hz) end
    elseif not isWater(px, py) and pz < 1.5 then
        recover(lastSafeZ)
    end
end

local function maybeScanOnMove()
    if not ENABLED or not isElement(localPlayer) then return end
    local px, py = getElementPosition(localPlayer)
    if not lastScanPos or dist2(px, py, lastScanPos.x, lastScanPos.y) >= (MOVE_SCAN_DIST * MOVE_SCAN_DIST) then
        scan()
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    ensureStaticSafetyFloors()
    setTimer(scan, SCAN_INTERVAL, 0)
    setTimer(fallGuard, 250, 0)
    setTimer(maybeScanOnMove, 700, 0)
    -- No early one-shot scan: the periodic timer takes over as soon as the
    -- world is ready, so cold joins can no longer spawn duplicate road tiles.
    triggerServerEvent("lcSG:report", localPlayer, "startup", 1, 0)
    outputDebugString("[LC-Surface] guard active (grid " .. (RADIUS * 2 + 1) .. "x" .. (RADIUS * 2 + 1) .. ", max patches " .. MAX_PATCHES .. ")", 3)
end)

addEvent("lcSG:command", true)
addEventHandler("lcSG:command", localPlayer, function(action)
    if action == "toggle" then
        ENABLED = not ENABLED
        outputChatBox("[LC-Surface] guard " .. (ENABLED and "ENABLED" or "DISABLED"), 212, 175, 55)
    elseif action == "clear" then
        clearPatches()
    elseif action == "scan" then
        local created, overlaps, thin = scan()
        triggerServerEvent("lcSG:report", localPlayer, "manual", (created or 0) + (overlaps or 0), patchCount)
        outputChatBox(("[LC-Surface] manual scan: created=%d overlaps=%d thin=%d patches=%d"):format(created or 0, overlaps or 0, thin or 0, patchCount), 212, 175, 55)
    end
end)

addCommandHandler("lcsurfacescan", function()
    local created, overlaps, thin = scan()
    triggerServerEvent("lcSG:report", localPlayer, "manual", (created or 0) + (overlaps or 0), patchCount)
    outputChatBox(("[LC-Surface] manual scan: created=%d overlaps=%d thin=%d patches=%d"):format(created or 0, overlaps or 0, thin or 0, patchCount), 212, 175, 55)
end)
