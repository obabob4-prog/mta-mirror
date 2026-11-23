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
addEventHandler("lcAudit:nearbyProps", localPlayer, function(cx, cy, cz, radius, pts)
    if type(cx) ~= "number" or type(cy) ~= "number" or type(cz) ~= "number" then return end
    radius = tonumber(radius) or 80
    local out = {}

    -- Optional screen-ray pass. Piggybacks on this proven event because the
    -- dedicated lcAudit:screenProbe client event was never delivered by eval.
    if type(pts) == "table" then
        local sw, sh = getScreenSize()
        local camX, camY, camZ = getCameraMatrix()
        triggerServerEvent("lcAudit:probeStarted", localPlayer, #pts,
            tostring(sw) .. "x" .. tostring(sh),
            tostring(camX) .. "," .. tostring(camY) .. "," .. tostring(camZ))
        for _, p in ipairs(pts) do
            local u, v = tonumber(p[1]), tonumber(p[2])
            if u and v then
                local okRay, wx, wy, wz = pcall(getWorldFromScreenPosition, u * sw, v * sh, 220)
                if okRay and wx then
                    local okLOS, hit, hx, hy, hz, hitElement = pcall(processLineOfSight,
                        camX, camY, camZ, wx, wy, wz,
                        true, false, false, true, true, false, false, false)
                    if okLOS and hit and isElement(hitElement) then
                        local ex, ey, ez = getElementPosition(hitElement)
                        out[#out + 1] = {
                            t = "screen", id = tostring(getElementID(hitElement) or ""),
                            model = tonumber(getElementModel(hitElement)) or 0,
                            name = "", x = ex, y = ey, z = ez,
                            rx = 0, ry = 0, rz = 0, sx = 0, sy = 0, sz = 0,
                            alpha = getElementAlpha(hitElement),
                            dim = getElementDimension(hitElement),
                            int = getElementInterior(hitElement),
                            d = getDistanceBetweenPoints3D(camX, camY, camZ, hx, hy, hz),
                            u = u, v = v, hitx = hx, hity = hy, hitz = hz
                        }
                    end
                end
            end
        end
    end

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
addEventHandler("lcAudit:screenProbe", root, function(points, depth)
    if type(points) ~= "table" then return end
    depth = tonumber(depth) or 200
    local sw, sh = getScreenSize()
    local cx, cy, cz = getCameraMatrix()
    triggerServerEvent("lcAudit:probeStarted", localPlayer, #points, sw, sh)
    local out = {}
    local seen = {}

    for _, p in ipairs(points) do
        local u, v = tonumber(p[1]), tonumber(p[2])
        if u and v then
            local okRay, wx, wy, wz = pcall(getWorldFromScreenPosition, u * sw, v * sh, depth)
            if not okRay or not wx then
                out[#out + 1] = { u = u, v = v, t = "ray-error", id = "", model = 0, name = "",
                    x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, sx = 0, sy = 0, sz = 0,
                    hitx = 0, hity = 0, hitz = 0, d = 0, alpha = 0, dim = 0, int = 0 }
            else
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
    end

    table.sort(out, function(a, b) return a.d < b.d end)
    while #out > 80 do table.remove(out) end
    triggerServerEvent("lcAudit:screenProbeResult", localPlayer, out, sw, sh, cx, cy, cz)
end)

-- 2026-11-19: /lcprobe is handled server-side in s_audit.lua (requestOverlapProbe).
-- The old client-side copy called outputServerLog (server-only) and silently
-- errored after triggering the probe, so it has been removed here.


-- 2026-11-22: texture / LOD probe for the reported "lab" overlap.
-- Read-only: reports the actual texture names attached to nearby LC models
-- and whether an element has a linked low-LOD twin. No world changes.
addEvent("lcAudit:textureProbe", true)
addEventHandler("lcAudit:textureProbe", localPlayer, function(cx, cy, cz, radius)
    if type(cx) ~= "number" or type(cy) ~= "number" or type(cz) ~= "number" then return end
    radius = tonumber(radius) or 120
    local out, seenModels = {}, {}
    local function addModel(model, ownerID)
        model = tonumber(model)
        if not model or model <= 0 or seenModels[model] then return end
        seenModels[model] = true
        local names = {}
        if engineGetModelTextureNames then
            local ok, list = pcall(engineGetModelTextureNames, model)
            if ok and type(list) == "table" then
                for i = 1, math.min(#list, 12) do names[#names + 1] = tostring(list[i]) end
            end
        end
        local lodDistance = "n/a"
        if engineGetModelLODDistance then
            local ok, d = pcall(engineGetModelLODDistance, model)
            if ok then lodDistance = tostring(d) end
        end
        out[#out + 1] = string.format("model=%d owner=%s lodDist=%s tex=%s",
            model, tostring(ownerID or ""), lodDistance,
            #names > 0 and table.concat(names, ",") or "<none>")
    end

    local function scan(elementType)
        for _, e in ipairs(getElementsByType(elementType)) do
            local x, y, z = getElementPosition(e)
            local dx, dy, dz = x - cx, y - cy, z - cz
            if dx * dx + dy * dy + dz * dz <= radius * radius then
                local id = tostring(getElementID(e) or "")
                local model = tonumber(getElementModel(e)) or 0
                addModel(model, id)
                local low = getLowLODElement(e)
                if isElement(low) then
                    addModel(tonumber(getElementModel(low)) or 0, "LOD:" .. id)
                    out[#out + 1] = string.format("lod-link %s(%d) -> %s(%d) streamed=%s/%s",
                        id, model, tostring(getElementID(low) or ""),
                        tonumber(getElementModel(low)) or 0,
                        tostring(isElementStreamedIn(e)), tostring(isElementStreamedIn(low)))
                end
            end
        end
    end
    scan("building")
    scan("object")
    while #out > 90 do table.remove(out) end
    triggerServerEvent("lcAudit:textureProbeResult", localPlayer, out, cx, cy, cz)
end)

-- 2026-11-22: overlap fingerprint probe. Read-only. For each supplied
-- coordinate it reports BOTH collision surfaces a few centimetres apart and
-- the exact client elements that own them, so residual z-fighting can be
-- fixed at the source instead of guessed.
addEvent("lcAudit:overlapDetail", true)
addEventHandler("lcAudit:overlapDetail", localPlayer, function(points)
    if type(points) ~= "table" then return end
    local out = {}
    local function info(e, wm, wlod)
        if isElement(e) then
            local x, y, z = getElementPosition(e)
            local low = getLowLODElement(e)
            local lowText = "none"
            if isElement(low) then
                lowText = string.format("%s/%s", tostring(getElementType(low)),
                    tostring(getElementID(low) or ""))
            end
            return string.format("%s/%s model=%d pos=%.2f,%.2f,%.2f lift=%s low=%s",
                tostring(getElementType(e)), tostring(getElementID(e) or ""),
                tonumber(getElementModel(e)) or 0, x, y, z,
                tostring(getElementData(e, "lc_hq:roadLift") or "-"), lowText)
        end
        return string.format("world model=%s lod=%s", tostring(wm), tostring(wlod))
    end
    for _, p in ipairs(points) do
        local x, y = tonumber(p[1]), tonumber(p[2])
        if x and y then
            local hit, _, _, hz, e1, _, _, _, _, _, _, wm1, _, _, _, _, _, _, wlod1 = processLineOfSight(
                x, y, RAY_TOP, x, y, RAY_BOTTOM,
                true, false, false, true, false, false, false, false, nil, true)
            if hit and hz then
                local hit2, _, _, hz2, e2, _, _, _, _, _, _, wm2, _, _, _, _, _, _, wlod2 = processLineOfSight(
                    x, y, hz - 0.02, x, y, hz - 0.45,
                    true, false, false, true, false, false, false, false, nil, true)
                if hit2 and hz2 and (hz - hz2) < 0.08 then
                    out[#out + 1] = string.format(
                        "x=%.1f y=%.1f z1=%.3f z2=%.3f gap=%.3f | top %s | under %s",
                        x, y, hz, hz2, hz - hz2,
                        info(e1, wm1, wlod1), info(e2, wm2, wlod2))
                end
            end
        end
    end
    triggerServerEvent("lcAudit:overlapDetailResult", localPlayer, out)
end)

-- ============================================================
-- WORLD_WIPE_PROBE: verifies that the SA world was really wiped.
-- Runs for every client that starts this resource. If ground still
-- exists at known San Andreas coordinates (or at the creator studio)
-- we report it so the wipe can be fixed, instead of guessing.
-- ============================================================
addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(function()
        local pts = {
            {"studio",  -980.0,  1095.0},
            {"ls",      1500.0, -1600.0},
            {"sf",     -2000.0,   800.0},
            {"chiliad", -2300.0, -1700.0},
            {"lv",      2000.0,  1500.0},
        }
        local lines = {}
        for _, p in ipairs(pts) do
            local gz = getGroundPosition(p[2], p[3], 800)
            local hit, hx, hy, hz = processLineOfSight(p[2], p[3], 800, p[2], p[3], -500, true, true, true, true, false, false, false, false)
            lines[#lines+1] = string.format("%s ground=%s los=%s z=%s",
                p[1], tostring(gz), tostring(hit), tostring(hz))
        end
        lines[#lines+1] = "playerDim="..tostring(getElementDimension(localPlayer))
        triggerServerEvent("lcAudit:studioProbe", localPlayer, table.concat(lines, " | "))
    end, 6000, 1)
end)