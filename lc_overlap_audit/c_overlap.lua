-- Read-only full-map AABB overlap auditor.
-- Iterates every streamed building/object, computes world bounding boxes,
-- and reports pairs whose axis-aligned boxes intersect by a meaningful
-- volume. LOD elements and known day/night variants are excluded so the
-- report only contains real geometry overlaps.

local CELL = 48
local MIN_DIM = 6.0
local MIN_VOL = 120.0
local MIN_FRAC = 0.35
local MAX_RESULTS = 250

local function isExcludedId(id)
    local lower = id:lower()
    if lower:find("lod", 1, true) then return true end
    if lower:find("_nt", 1, true) then return true end
    if lower:find("repair", 1, true) then return true end
    if lower:find("cable", 1, true) then return true end
    if lower:find("wire", 1, true) then return true end
    return false
end

addEvent("lcOverlap:run", true)
addEventHandler("lcOverlap:run", localPlayer, function()
    local scanTypes = { "building", "object" }

    -- Any element registered as another element's low LOD is not real
    -- geometry; skip it so LOD duplicates never appear in the report.
    local lowLod = {}
    for _, t in ipairs(scanTypes) do
        for _, e in ipairs(getElementsByType(t)) do
            local low = getLowLODElement(e)
            if isElement(low) then lowLod[low] = true end
        end
    end

    local list = {}
    for _, t in ipairs(scanTypes) do
        for _, e in ipairs(getElementsByType(t)) do
            if not lowLod[e] then
                local id = tostring(getElementID(e) or "")
                if id ~= "" and not isExcludedId(id) then
                    local ok, minX, minY, minZ, maxX, maxY, maxZ = pcall(getElementBoundingBox, e)
                    if ok and type(minX) == "number" and type(maxX) == "number" then
                        local sx, sy, sz = maxX - minX, maxY - minY, maxZ - minZ
                        local maxDim = math.max(sx, sy, sz)
                        if maxDim >= MIN_DIM and sx > 0 and sy > 0 and sz > 0 then
                            local x, y, z = getElementPosition(e)
                            list[#list + 1] = {
                                id = id,
                                model = tonumber(getElementModel(e)) or 0,
                                x = x, y = y, z = z,
                                minX = minX, minY = minY, minZ = minZ,
                                maxX = maxX, maxY = maxY, maxZ = maxZ,
                                sx = sx, sy = sy, sz = sz
                            }
                        end
                    end
                end
            end
        end
    end

    -- 2D spatial hash on X/Y; boxes are small enough that Z can be
    -- tested directly for every candidate pair.
    local grid = {}
    for i, o in ipairs(list) do
        local x0 = math.floor(o.minX / CELL)
        local x1 = math.floor(o.maxX / CELL)
        local y0 = math.floor(o.minY / CELL)
        local y1 = math.floor(o.maxY / CELL)
        for gx = x0, x1 do
            for gy = y0, y1 do
                local key = gx .. ":" .. gy
                local cell = grid[key]
                if not cell then cell = {}; grid[key] = cell end
                cell[#cell + 1] = i
            end
        end
    end

    local seen = {}
    local results = {}
    for _, cell in pairs(grid) do
        for a = 1, #cell do
            for b = a + 1, #cell do
                local i, j = cell[a], cell[b]
                local key = i < j and (i .. ":" .. j) or (j .. ":" .. i)
                if not seen[key] then
                    seen[key] = true
                    local A, B = list[i], list[j]
                    local ix = math.min(A.maxX, B.maxX) - math.max(A.minX, B.minX)
                    local iy = math.min(A.maxY, B.maxY) - math.max(A.minY, B.minY)
                    local iz = math.min(A.maxZ, B.maxZ) - math.max(A.minZ, B.minZ)
                    if ix > 0.05 and iy > 0.05 and iz > 0.05 then
                        local vol = ix * iy * iz
                        local smallVol = math.min(A.sx * A.sy * A.sz, B.sx * B.sy * B.sz)
                        local frac = smallVol > 0 and (vol / smallVol) or 0
                        if vol >= MIN_VOL and frac >= MIN_FRAC then
                            results[#results + 1] = {
                                a = A.id, ma = A.model, pax = A.x, pay = A.y, paz = A.z,
                                b = B.id, mb = B.model, pbx = B.x, pby = B.y, pbz = B.z,
                                vol = vol, frac = frac,
                                ix = ix, iy = iy, iz = iz
                            }
                        end
                    end
                end
            end
        end
    end

    table.sort(results, function(x, y) return x.vol > y.vol end)
    local top = {}
    for i = 1, math.min(#results, MAX_RESULTS) do top[i] = results[i] end

    triggerServerEvent("lcOverlap:result", localPlayer, {
        scanned = #list,
        pairs = #results,
        items = top
    })
end)
