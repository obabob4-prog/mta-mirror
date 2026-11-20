-- ============================================================
--  lc_audit / client
--  Terrain verifier for Liberty City.
--
--  For a square tile it samples a grid and classifies every point:
--    GROUND  a solid surface was hit
--    WATER   no surface, but there is water
--    VOID    nothing at all  -> a real hole in the world
--  and it also looks for a second surface a few centimetres under
--  the first one, which is what produces z-fighting / flicker.
--
--  Nothing is created in the world; the scan is read-only.
-- ============================================================

local RAY_TOP = 300.0
local RAY_BOTTOM = -90.0
local BATCH = 120

local running = false

local function classify(x, y, out)
    local hit, _, _, hz = processLineOfSight(
        x, y, RAY_TOP, x, y, RAY_BOTTOM,
        true, false, false, true, false, false, false, false, nil, false
    )

    if hit and hz then
        out.z = hz

        -- second surface just under the first -> overlapping / duplicate tiles
        local hit2, _, _, hz2 = processLineOfSight(
            x, y, hz - 0.02, x, y, hz - 0.45,
            true, false, false, true, false, false, false, false, nil, false
        )
        if hit2 and hz2 and (hz - hz2) < 0.08 then
            out.zfight = { x = x, y = y, z = hz, gap = hz - hz2 }
        end
        return
    end

    local water = getWaterLevel(x, y, 4, true)
    if water and water > -20 then
        out.water = true
        return
    end

    out.void = true
end

-- chars: '' = ground, 'w' = water, 'v' = void
local function scanTile(cx, cy, half, step)
    local cells = {}
    local cols = math.floor((half * 2) / step) + 1
    local idx = 0
    for gy = 0, cols - 1 do
        for gx = 0, cols - 1 do
            local x = cx - half + gx * step
            local y = cy - half + gy * step
            idx = idx + 1
            cells[idx] = { x = x, y = y }
        end
    end
    return cells, cols
end

local scanTimer

local function runTile(request, cx, cy, half, step)
    local cells = scanTile(cx, cy, half, step)
    local total = #cells
    local i = 0
    local result = {
        cx = cx, cy = cy, half = half, step = step,
        ground = 0, water = 0, void = 0,
        heights = {}, voids = {}, zfights = {},
    }

    local function tick()
        if not running then return end
        local budget = BATCH
        while budget > 0 and i < total do
            i = i + 1
            local c = cells[i]
            local out = {}
            classify(c.x, c.y, out)
            if out.void then
                result.void = result.void + 1
                if #result.voids < 3000 then
                    result.voids[#result.voids + 1] = { x = c.x, y = c.y }
                end
            elseif out.water then
                result.water = result.water + 1
            else
                result.ground = result.ground + 1
                result.heights[#result.heights + 1] = out.z
                if out.zfight then
                    if #result.zfights < 1500 then
                        result.zfights[#result.zfights + 1] = out.zfight
                    end
                end
            end
            budget = budget - 1
        end
        if i >= total then
            if isTimer(scanTimer) then killTimer(scanTimer) end
            running = false
            triggerServerEvent("lcAudit:tile", localPlayer, result)
            if request.auto then
                triggerServerEvent("lcAudit:tileDone", localPlayer, request.id)
            end
        end
    end

    running = true
    if isTimer(scanTimer) then killTimer(scanTimer) end
    scanTimer = setTimer(tick, 20, 0)
end

addEvent("lcAudit:scanTile", true)
addEventHandler("lcAudit:scanTile", localPlayer, function(cx, cy, half, step, request)
    if running then
        triggerServerEvent("lcAudit:tileDone", localPlayer, type(request) == "table" and request.id or -1)
        return
    end
    -- refuse to scan before the city has streamed in: everything would read as void
    local probeHit = processLineOfSight(cx, cy, RAY_TOP, cx, cy, RAY_BOTTOM,
        true, false, false, true, false, false, false, false, nil, false)
    if not probeHit then
        triggerServerEvent("lcAudit:tileDone", localPlayer, type(request) == "table" and request.id or -1)
        return
    end
    runTile(type(request) == "table" and request or {}, cx, cy, half, step)
end)

-- 2026-11-18: one-shot ground probe used to calibrate new LC landmarks.
-- Read-only: casts the same ray as the audit and reports the surface height.
addEvent("lcAudit:groundProbe", true)
addEventHandler("lcAudit:groundProbe", localPlayer, function(points)
    if type(points) ~= "table" then return end
    local out = {}
    for i, p in ipairs(points) do
        local hit, _, _, hz = processLineOfSight(
            p[1], p[2], RAY_TOP, p[1], p[2], RAY_BOTTOM,
            true, false, false, true, false, false, false, false, nil, false)
        out[i] = { x = p[1], y = p[2], z = hit and hz or -9999, hit = hit or false }
    end
    triggerServerEvent("lcAudit:groundProbeResult", localPlayer, out)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    running = false
    if isTimer(scanTimer) then killTimer(scanTimer) end
end)

-- 2026-11-19: nearby prop inspector. Read-only; lists large or
-- bridge/rail-named streamed elements around a point so a misplaced
-- bridge segment can be identified by its map id / model id.
addEvent("lcAudit:nearbyProps", true)
addEventHandler("lcAudit:nearbyProps", localPlayer, function(cx, cy, cz, radius)
    if type(cx) ~= "number" or type(cy) ~= "number" or type(cz) ~= "number" then return end
    radius = tonumber(radius) or 80
    local out = {}

    local function scan(elementType)
        for _, obj in ipairs(getElementsByType(elementType)) do
            local x, y, z = getElementPosition(obj)
            local dx, dy, dz = x - cx, y - cy, z - cz
            local d2 = dx * dx + dy * dy + dz * dz
            if d2 <= radius * radius then
                local id = tostring(getElementID(obj) or "")
                local model = tonumber(getElementModel(obj)) or 0
                local sx, sy, sz = 0, 0, 0
                local ok, minX, minY, minZ, maxX, maxY, maxZ = pcall(getElementBoundingBox, obj)
                if ok and type(minX) == "number" then
                    sx, sy, sz = maxX - minX, maxY - minY, maxZ - minZ
                end
                local lowerId = id:lower()
                local named = lowerId:find("brid", 1, true) or lowerId:find("rail", 1, true)
                    or lowerId:find("trax", 1, true) or lowerId:find("gird", 1, true)
                    or lowerId:find("truss", 1, true) or lowerId:find("support", 1, true)
                local big = math.max(sx, sy, sz) >= 4.0
                if big or named then
                    local modelName = ""
                    if engineGetModelNameFromID then
                        local okName, name = pcall(engineGetModelNameFromID, model)
                        if okName and type(name) == "string" then modelName = name end
                    end
                    local rx, ry, rz = getElementRotation(obj)
                    out[#out + 1] = {
                        t = elementType, id = id, model = model, name = modelName,
                        x = x, y = y, z = z, rx = rx, ry = ry, rz = rz,
                        sx = sx, sy = sy, sz = sz,
                        alpha = getElementAlpha(obj),
                        dim = getElementDimension(obj), int = getElementInterior(obj),
                        d = math.sqrt(d2)
                    }
                end
            end
        end
    end

    scan("object")
    scan("building")
    table.sort(out, function(a, b) return a.d < b.d end)
    while #out > 100 do table.remove(out) end
    triggerServerEvent("lcAudit:nearbyPropsResult", localPlayer, out, radius)
end)

-- 2026-11-19 diagnostic: report railtrax day/night variant visibility around
-- a point. Read-only; used to verify that only one variant of each co-located
-- rail model is rendered at a time.
addEvent("lcAudit:variantProbe", true)
addEventHandler("lcAudit:variantProbe", localPlayer, function(cx, cy, cz, radius)
    if type(cx) ~= "number" or type(cy) ~= "number" or type(cz) ~= "number" then return end
    radius = tonumber(radius) or 120
    local out = {}
    local function scan(elementType)
        for _, obj in ipairs(getElementsByType(elementType)) do
            local x, y, z = getElementPosition(obj)
            local dx, dy, dz = x - cx, y - cy, z - cz
            if dx * dx + dy * dy + dz * dz <= radius * radius then
                local id = getElementID(obj) or ""
                if id:find("railtrax") or id:find("Nrailtrax") then
                    out[#out + 1] = {
                        id = id,
                        alpha = getElementAlpha(obj),
                        interior = getElementInterior(obj),
                        dimension = getElementDimension(obj),
                        x = x, y = y, z = z,
                    }
                end
            end
        end
    end
    scan("object")
    scan("building")
    triggerServerEvent("lcAudit:variantProbeResult", localPlayer, out, getTime())
end)

-- 2026-11-19: screen-ray inspector. Casts rays through normalized screen
-- points (0..1) and reports the exact element that is rendered there.
-- Read-only. Used to identify the orange bridge beams without guessing.
addEvent("lcAudit:screenProbe", true)
addEventHandler("lcAudit:screenProbe", localPlayer, function(points, depth)
    if type(points) ~= "table" then return end
    depth = tonumber(depth) or 200
    local sw, sh = getScreenSize()
    local cx, cy, cz = getCameraMatrix()
    local out = {}
    local seen = {}

    for _, p in ipairs(points) do
        local u, v = tonumber(p[1]), tonumber(p[2])
        if u and v then
            local wx, wy, wz = getWorldFromScreenPosition(u * sw, v * sh, depth)
            local hit, hx, hy, hz, hitElement = processLineOfSight(
                cx, cy, cz, wx, wy, wz,
                true, false, false, true, true, false, false, false
            )
            if hit and isElement(hitElement) then
                local id = tostring(getElementID(hitElement) or "")
                local model = tonumber(getElementModel(hitElement)) or 0
                local key = tostring(hitElement)
                if not seen[key] then
                    seen[key] = true
                    local ex, ey, ez = getElementPosition(hitElement)
                    local rx, ry, rz = getElementRotation(hitElement)
                    local sx, sy, sz = 0, 0, 0
                    local ok, minX, minY, minZ, maxX, maxY, maxZ = pcall(getElementBoundingBox, hitElement)
                    if ok and type(minX) == "number" then
                        sx, sy, sz = maxX - minX, maxY - minY, maxZ - minZ
                    end
                    local modelName = ""
                    if engineGetModelNameFromID then
                        local okName, name = pcall(engineGetModelNameFromID, model)
                        if okName and type(name) == "string" then modelName = name end
                    end
                    local dx, dy, dz = hx - cx, hy - cy, hz - cz
                    out[#out + 1] = {
                        u = u, v = v,
                        t = getElementType(hitElement),
                        id = id, model = model, name = modelName,
                        x = ex, y = ey, z = ez,
                        rx = rx, ry = ry, rz = rz,
                        sx = sx, sy = sy, sz = sz,
                        hitx = hx, hity = hy, hitz = hz,
                        d = math.sqrt(dx * dx + dy * dy + dz * dz),
                        alpha = getElementAlpha(hitElement),
                        dim = getElementDimension(hitElement),
                        int = getElementInterior(hitElement)
                    }
                end
            elseif hit then
                local key = "world:" .. tostring(math.floor(hx)) .. ":" .. tostring(math.floor(hy)) .. ":" .. tostring(math.floor(hz))
                if not seen[key] then
                    seen[key] = true
                    local dx, dy, dz = hx - cx, hy - cy, hz - cz
                    out[#out + 1] = {
                        u = u, v = v, t = "world", id = "", model = 0, name = "",
                        x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0,
                        sx = 0, sy = 0, sz = 0,
                        hitx = hx, hity = hy, hitz = hz,
                        d = math.sqrt(dx * dx + dy * dy + dz * dz),
                        alpha = 255, dim = 0, int = 0
                    }
                end
            end
        end
    end

    table.sort(out, function(a, b) return a.d < b.d end)
    while #out > 80 do table.remove(out) end
    triggerServerEvent("lcAudit:screenProbeResult", localPlayer, out, sw, sh, cx, cy, cz)
end)

-- 2026-11-19: /lcprobe command. Casts screen rays and logs exact hit elements.
-- Usage: type /lcprobe in-game while connected. Result appears in server log.
addCommandHandler("lcprobe", function()
    local player = localPlayer
    if not isElement(player) then return end
    -- sample 44 points across the screen (same pattern as the auto-probe)
    local pts = {}
    for v = 0.10, 0.55, 0.05 do
        for u = 0.05, 0.95, 0.08 do
            pts[#pts + 1] = { u, v }
        end
    end
    triggerClientEvent(player, "lcAudit:screenProbe", player, pts, 220)
    outputServerLog(string.format("[lc_audit] screenProbe triggered by /lcprobe for %s (%d points)", getPlayerName(player), #pts))
end)
