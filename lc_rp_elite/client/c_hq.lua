--[[
    lc_rp_elite / client/c_hq.lua
    Private HQ rooms and minimal walk hints.

    HARD RULES
    - No E key, no command, no marker, no new exterior object or teleport.
    - Rooms exist ONLY in private dimensions 50001-50012, interior 0.
    - Each room is rotated to the real map door and staged so its own GTA V
      doorway sits exactly on that exterior coordinate.
    - Walking through the door changes only dimension; this file never moves
      the player and never animates or creates an exterior door.
]]
local C = LCRE.client
local sw, sh = C.sw, C.sh

local ROOM_PARTS = {
    shell = { dff = "models/apt_mp_shell.dff", txd = "models/apt_mp_mod.txd",  col = "models/apt_mp_shell.col" },
    int   = { dff = "models/apt_mp_int.dff",   txd = "models/apt_mp_int.txd",   col = "models/apt_mp_int.col" },
    props = { dff = "models/apt_mp_props.dff", txd = "models/apt_mp_props.txd", col = "models/apt_mp_props.col" },
}

local assets = {}
local models = {}
local rooms = {}
local tried = false
local floorScale = nil

local function log(text)
    outputDebugString("[lc_rp_elite][rooms] " .. tostring(text), 2)
end

local function stagePoint(lx, ly, lz, hq)
    return LCRE.roomPoint(lx, ly, lz, hq)
end

local function loadAssets()
    if tried then return next(assets) ~= nil end
    tried = true
    if type(engineRequestModel) ~= "function" then
        log("engineRequestModel unavailable")
        return false
    end
    local ok = true
    for name, path in pairs(ROOM_PARTS) do
        local model = engineRequestModel("object")
        if not model then
            ok = false
        else
            local txd = engineLoadTXD(path.txd)
            local dff = engineLoadDFF(path.dff, model)
            local col = engineLoadCOL(path.col)
            if not (txd and dff and col) then
                if engineFreeModel then engineFreeModel(model) end
                ok = false
                log("asset load failed: " .. name)
            else
                engineImportTXD(txd, model)
                engineReplaceCOL(col, model)
                engineReplaceModel(dff, model)
                assets[name] = { id = model, dff = dff, txd = txd, col = col }
                table.insert(models, model)
            end
        end
    end
    -- Measure the invisible safety floor in an unused PRIVATE dimension only.
    local tmp = createObject(1337, 30990, 30990, 490, 0, 0, 0)
    if tmp then
        setElementDimension(tmp, 50990)
        local minx, miny, minz, maxx, maxy, maxz = getElementBoundingBox(tmp)
        if minx and maxx and maxx > minx and maxy > miny and maxz >= minz then
            floorScale = {
                sx = (tonumber(LCRE.room.floorSizeX) or 28) / (maxx - minx),
                sy = (tonumber(LCRE.room.floorSizeY) or 46) / (maxy - miny),
                sz = (tonumber(LCRE.room.floorThickness) or 0.45) / math.max(0.01, maxz - minz),
                cx = (minx + maxx) * 0.5,
                cy = (miny + maxy) * 0.5,
                cz = maxz,
            }
        end
        destroyElement(tmp)
    end
    if not floorScale then
        floorScale = { sx = 28, sy = 46, sz = 0.45, cx = 0, cy = 0, cz = 0.5 }
    end
    log("assets ready=" .. tostring(next(assets) ~= nil) .. " models=" .. #models)
    return next(assets) ~= nil
end

local function static(element)
    if not isElement(element) then return end
    if setElementDoubleSided then setElementDoubleSided(element, true) end
    if setElementFrozen then setElementFrozen(element, true) end
end

local function makeFloor(hq)
    local g, s = LCRE.room, floorScale
    if not s then return nil end
    local lx = -s.cx * s.sx
    local ly = (tonumber(g.floorCenterY) or 2.4) - s.cy * s.sy
    local lz = (tonumber(g.floorTopZ) or -1.8) - s.cz * s.sz
    local x, y, z = stagePoint(lx, ly, lz, hq)
    local o = createObject(1337, x, y, z, 0, 0, tonumber(hq.roomRot) or 0)
    if not o then return nil end
    if setObjectScale then setObjectScale(o, s.sx, s.sy, s.sz) end
    setElementDimension(o, hq.dimension)
    setElementInterior(o, 0)
    setElementAlpha(o, 0)
    setElementCollisionsEnabled(o, true)
    static(o)
    return o
end

local function ensureRoom(id)
    id = tonumber(id) or 0
    local hq = LCRE.hqById[id]
    if not hq then return end
    local dim = tonumber(hq.dimension) or 0
    if dim < (LCRE.world.dimBase + 1) then
        log("refusing to build room outside private dimensions")
        return
    end
    if rooms[id] then return rooms[id] end
    if not loadAssets() then return end

    local room = { dim = dim, objects = {} }
    local x, y, z = stagePoint(0, 0, 0, hq)
    for name, asset in pairs(assets) do
        local o = createObject(asset.id, x, y, z, 0, 0, tonumber(hq.roomRot) or 0)
        if o then
            setElementDimension(o, dim)
            setElementInterior(o, 0)
            static(o)
            table.insert(room.objects, o)
        end
    end
    local floor = makeFloor(hq)
    if floor then table.insert(room.objects, floor) end
    -- Intentionally NO marker: leaving is also done by walking back through
    -- the same real doorway, detected server-side.
    rooms[id] = room
    C.roomIds[id] = true
    return room
end

addEvent("lcre:ensureRoom", true)
addEventHandler("lcre:ensureRoom", root, function(id) ensureRoom(id) end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for id, room in pairs(rooms) do
        for _, o in ipairs(room.objects) do
            if isElement(o) then destroyElement(o) end
        end
        rooms[id] = nil
        C.roomIds[id] = nil
    end
    for _, model in ipairs(models) do
        if engineFreeModel then engineFreeModel(model) end
    end
    models, assets = {}, {}
end)

local function doorPos(hq)
    return tonumber(hq.door.x) or 0, tonumber(hq.door.y) or 0, tonumber(hq.door.z) or 0
end

local function flatDistance(x, y, hq)
    local dx, dy = doorPos(hq)
    return math.sqrt((x - dx) * (x - dx) + (y - dy) * (y - dy))
end

local function nearestEntrance()
    if getElementDimension(localPlayer) ~= LCRE.world.exteriorDimension or
       getElementInterior(localPlayer) ~= LCRE.world.exteriorInterior then return nil end
    local x, y, z = getElementPosition(localPlayer)
    local best, bestD = nil, 99999
    for _, hq in ipairs(LCRE.hqs) do
        local d = flatDistance(x, y, hq)
        if d <= (tonumber(LCRE.world.hintRange) or 4.0) and d < bestD then best, bestD = hq, d end
    end
    return best
end

local function currentInteriorHQ()
    local dim = getElementDimension(localPlayer)
    if dim < 50001 or dim > 50012 then return nil end
    for _, hq in ipairs(LCRE.hqs) do
        if hq.dimension == dim then return hq end
    end
    return nil
end

local function drawHint(titleAr, titleEn, subAr, subEn, accent)
    local w, h = C.px(410), C.px(56)
    local x, y = (sw - w) / 2, sh - C.px(122)
    C.rect(x, y, w, h, C.color({ 8, 8, 11 }, 226))
    C.rect(x, y, C.px(4), h, C.color(accent or LCRE.theme.gold, 255))
    C.text(C.t(titleAr, titleEn), x + C.px(16), y + C.px(7), w - C.px(30), C.px(24),
        C.color(LCRE.theme.text), C.font, "left", "center")
    C.text(C.t(subAr, subEn), x + C.px(16), y + C.px(32), w - C.px(30), C.px(18),
        C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
end

addEventHandler("onClientRender", root, function()
    if not getElementData(localPlayer, "char.spawned") or C.panel then return end
    local hq = currentInteriorHQ()
    if hq then
        local x, y, z = getElementPosition(localPlayer)
        if flatDistance(x, y, hq) <= (tonumber(LCRE.world.hintRange) or 4.0) then
            drawHint("امشِ عبر الباب للخروج", "Walk through the door to leave",
                hq.name.ar .. " / " .. hq.name.en, "Same real door - no press, no teleport", LCRE.theme.blue)
        end
        return
    end
    hq = nearestEntrance()
    if hq then
        -- Pre-build the private room before the walk-through happens. This
        -- only touches the private dimension and prevents an empty first frame.
        ensureRoom(hq.id)
        drawHint("امشِ عبر الباب للدخول", "Walk through the door to enter",
            hq.name.ar .. " / " .. hq.name.en, "No E, no marker - just walk in", LCRE.theme.gold)
    end
end)
