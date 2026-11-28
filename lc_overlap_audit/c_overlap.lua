-- Read-only full-map AABB overlap auditor (chunked).
-- Iterates every streamed building/object, computes world bounding boxes,
-- and reports pairs whose axis-aligned boxes intersect by a meaningful
-- volume. LOD elements and known day/night variants are excluded so the
-- report only contains real geometry overlaps.
--
-- With the whole city streamed the scan touches tens of thousands of
-- elements, which trips MTA's "Aborting; infinite running script" watchdog
-- if it runs in one go. The scan is therefore a sequence of steps, each
-- running for at most TICK_MS before yielding back to the game loop.

local CELL = 48
local MIN_DIM = 6.0
local MAX_DIM = 400.0     -- ground/sea planes are km-wide; never grid them
local MAX_CELLS = 4096    -- per-element spatial-hash budget
local MIN_VOL = 120.0
local MIN_FRAC = 0.35
local MAX_RESULTS = 250
local RESULTS_CAP = 4000  -- keep at most this many pending pairs; re-rank in
                          -- amortised batches so table.sort never sees an
                          -- unbounded list in a single tick
local MAX_ELEMENTS = 60000
local TICK_MS = 30        -- per-frame time budget

local function isExcludedId(id)
    local lower = id:lower()
    if lower:find("lod", 1, true) then return true end
    if lower:find("_nt", 1, true) then return true end
    if lower:find("repair", 1, true) then return true end
    if lower:find("cable", 1, true) then return true end
    if lower:find("wire", 1, true) then return true end
    return false
end

local busy = false
local S = nil

local function sendResult(data)
    triggerServerEvent("lcOverlap:result", localPlayer, data)
    busy = false
    S = nil
end

local function fail(err)
    outputDebugString("[lc_overlap] scan failed: " .. tostring(err), 1)
    sendResult({
        scanned = -1, pairs = 0, items = {},
        err = tostring(err),
        px = 0, py = 0, pz = 0
    })
end

-- step 1: walk every building/object, collect LOD marks + candidate boxes.
-- The LOD set can be discovered after an element was already appended, so
-- entries are re-checked against it while gridding (step 2).
local function stepCollect(st, deadline)
    while true do
        local cur = st.lists[st.li]
        if not cur then return true end
        if st.i > #cur then
            st.li = st.li + 1
            st.i = 1
        else
            local e = cur[st.i]
            st.i = st.i + 1
            local low = getLowLODElement(e)
            if isElement(low) then st.lowLod[low] = true end
            local id = tostring(getElementID(e) or "")
            if id ~= "" and #st.samples < 6 then
                st.samples[#st.samples + 1] = id
            end
            if id ~= "" and not isExcludedId(id) then
                local ok, minX, minY, minZ, maxX, maxY, maxZ = pcall(getElementBoundingBox, e)
                if ok and type(minX) == "number" and type(maxX) == "number" then
                    local sx, sy, sz = maxX - minX, maxY - minY, maxZ - minZ
                    local maxDim = math.max(sx, sy, sz)
                    if maxDim > MAX_DIM then
                        st.tooBig = st.tooBig + 1
                    elseif maxDim >= MIN_DIM and sx > 0 and sy > 0 and sz > 0 then
                        if #st.list < MAX_ELEMENTS then
                            local x, y, z = getElementPosition(e)
                            st.list[#st.list + 1] = {
                                e = e, id = id,
                                model = tonumber(getElementModel(e)) or 0,
                                x = x, y = y, z = z,
                                minX = minX, minY = minY, minZ = minZ,
                                maxX = maxX, maxY = maxY, maxZ = maxZ,
                                sx = sx, sy = sy, sz = sz
                            }
                        end
                    else
                        st.tooSmall = st.tooSmall + 1
                    end
                end
            else
                if id == "" then st.noId = st.noId + 1 else st.excluded = st.excluded + 1 end
            end
            if getTickCount() >= deadline then return false end
        end
    end
end

-- step 2: insert candidates into the 2D spatial hash (skip LOD-marked ones).
local function stepGrid(st, deadline)
    local grid = st.grid
    while st.gi < #st.list do
        st.gi = st.gi + 1
        local o = st.list[st.gi]
        if not st.lowLod[o.e] then
            local x0 = math.floor(o.minX / CELL)
            local x1 = math.floor(o.maxX / CELL)
            local y0 = math.floor(o.minY / CELL)
            local y1 = math.floor(o.maxY / CELL)
            if (x1 - x0 + 1) * (y1 - y0 + 1) > MAX_CELLS then
                st.gridDropped = st.gridDropped + 1
            else
                for gx = x0, x1 do
                    for gy = y0, y1 do
                        local key = gx .. ":" .. gy
                        local cell = grid[key]
                        if not cell then cell = {}; grid[key] = cell end
                        cell[#cell + 1] = st.gi
                    end
                end
            end
        end
        if getTickCount() >= deadline then return false end
    end
    return true
end

-- step 3: test candidate pairs, resuming mid-cell when the tick budget runs
-- out (dense cells can hold hundreds of entries).
local function stepPairs(st, deadline)
    local grid, list, seen, results = st.grid, st.list, st.seen, st.results
    local cellKey, ca, cb = st.cellKey, st.ca, st.cb
    while true do
        local cell
        if cellKey then
            cell = grid[cellKey]
            if not cell then
                cellKey, ca, cb = nil, nil, nil
            end
        else
            local prevKey = st.prevKey
            cellKey, cell = next(grid, prevKey)
            st.prevKey = cellKey
            ca, cb = 1, 2
            if not cellKey then return true end
        end
        if cell then
            local n = #cell
            while ca <= n do
                while cb <= n do
                    local i, j = cell[ca], cell[cb]
                    cb = cb + 1
                    local row = seen[i]
                    if not row then row = {}; seen[i] = row end
                    if not row[j] then
                        row[j] = true
                        local A, B = list[i], list[j]
                        local ix = math.min(A.maxX, B.maxX) - math.max(A.minX, B.minX)
                        local iy = math.min(A.maxY, B.maxY) - math.max(A.minY, B.minY)
                        local iz = math.min(A.maxZ, B.maxZ) - math.max(A.minZ, B.minZ)
                        if ix > 0.05 and iy > 0.05 and iz > 0.05 then
                            local vol = ix * iy * iz
                            local smallVol = math.min(A.sx * A.sy * A.sz, B.sx * B.sy * B.sz)
                            local frac = smallVol > 0 and (vol / smallVol) or 0
                            if vol >= MIN_VOL and frac >= MIN_FRAC then
                                st.pairs = st.pairs + 1
                                if vol > (st.floor or 0) then
                                    results[#results + 1] = {
                                        a = A.id, ma = A.model, pax = A.x, pay = A.y, paz = A.z,
                                        b = B.id, mb = B.model, pbx = B.x, pby = B.y, pbz = B.z,
                                        vol = vol, frac = frac,
                                        ix = ix, iy = iy, iz = iz
                                    }
                                    if #results >= RESULTS_CAP then
                                        -- amortised top-K: rank once, keep the
                                        -- best MAX_RESULTS, then only accept
                                        -- pairs that beat the new floor.
                                        table.sort(results, function(x, y) return x.vol > y.vol end)
                                        for r = #results, MAX_RESULTS + 1, -1 do results[r] = nil end
                                        st.floor = results[#results] and results[#results].vol or 0
                                    end
                                end
                            end
                        end
                    end
                    if getTickCount() >= deadline then
                        st.cellKey, st.ca, st.cb = cellKey, ca, cb
                        return false
                    end
                end
                ca = ca + 1
                cb = ca + 1
            end
        end
        cellKey, ca, cb = nil, nil, nil
        st.cellKey, st.ca, st.cb = nil, nil, nil
    end
end

-- step 4: rank and report.
local function stepReport(st, deadline)
    local results = st.results
    table.sort(results, function(x, y) return x.vol > y.vol end)
    local top = {}
    for i = 1, math.min(#results, MAX_RESULTS) do top[i] = results[i] end
    local px, py, pz = getElementPosition(localPlayer)
    sendResult({
        scanned = #st.list,
        pairs = st.pairs,
        items = top,
        rawB = st.rawB, rawO = st.rawO,
        noId = st.noId, excluded = st.excluded,
        tooSmall = st.tooSmall, tooBig = st.tooBig,
        gridDropped = st.gridDropped,
        samples = table.concat(st.samples, ","),
        px = px, py = py, pz = pz
    })
    return true
end

local steps = { stepCollect, stepGrid, stepPairs, stepReport }

local function tick()
    local st = S
    if not st then return end
    local deadline = getTickCount() + TICK_MS
    st.ticks = (st.ticks or 0) + 1
    if st.ticks % 40 == 0 then
        outputDebugString(string.format(
            "[lc_overlap] progress step=%d i=%d gi=%d pairs=%d results=%d tested=%d",
            st.step, st.i or 0, st.gi or 0, st.pairs or 0,
            #st.results, st.tested or 0), 3)
    end
    if getTickCount() - st.startedAt > 240000 then
        fail(string.format("timeout at step=%d i=%d gi=%d pairs=%d results=%d tested=%d",
            st.step, st.i or 0, st.gi or 0, st.pairs or 0,
            #st.results, st.tested or 0))
        return
    end
    while true do
        local ok, done = pcall(steps[st.step], st, deadline)
        if not ok then fail(done); return end
        if not done then
            setTimer(tick, 0, 1)
            return
        end
        st.step = st.step + 1
        if st.step > #steps then return end
        if getTickCount() >= deadline then
            setTimer(tick, 0, 1)
            return
        end
    end
end

local function startScan()
    local buildings = getElementsByType("building")
    local objects = getElementsByType("object")
    S = {
        step = 1,
        lists = { buildings, objects },
        li = 1, i = 1,
        rawB = #buildings, rawO = #objects,
        lowLod = {}, samples = {}, list = {},
        noId = 0, excluded = 0, tooSmall = 0, tooBig = 0,
        grid = {}, gridDropped = 0, gi = 0,
        seen = {}, results = {}, pairs = 0, floor = 0,
        ticks = 0, tested = 0, startedAt = getTickCount(),
        prevKey = nil, cellKey = nil, ca = nil, cb = nil,
    }
    tick()
end

addEvent("lcOverlap:run", true)
addEventHandler("lcOverlap:run", localPlayer, function()
    if busy then return end
    busy = true
    local ok, err = pcall(startScan)
    if not ok then fail(err) end
end)
