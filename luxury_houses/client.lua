--[[ ============================================================
     luxury_houses / client.lua
     gta4gg - "PREMIUM REAL ESTATE & INTERIOR SYSTEM" (client)

     GTA V Online inspired UI: black / gold / white.
     * floating door sign: property name, type, status, price, PRESS E
     * E to enter, E at the interior exit point to leave
     * purchase / management / storage / furniture / garage panels
     * furniture placement mode (arrows move, R rotate, ENTER confirm)

     NOTE: MTA dx* functions take ONE integer colour (tocolor). The C()
     helper below keeps all colours in that format.
   ============================================================ ]]

local sx, sy = guiGetScreenSize()
local scale = math.max(0.75, math.min(sx / 1920, sy / 1080))

-- premium palette
local GOLD      = { 212, 175, 55 }
local GOLD_DARK = { 150, 120, 40 }
local PANEL     = { 12, 12, 14 }
local WHITE     = { 240, 240, 240 }
local GRAY      = { 150, 150, 150 }
local GREEN     = { 70, 180, 110 }
local RED       = { 200, 70, 60 }

local function C(c, a) return tocolor(c[1], c[2], c[3], a or 255) end

local props    = {}     -- id -> sync table
local inside   = nil    -- {id,name,exit={x,y,z},...}
local ui       = nil    -- {mode=..., data=...}
local buttons  = {}     -- clickable rects rebuilt each frame
local toasts   = {}
local place    = nil    -- {model,name,el,moving,fid}
local fade     = { on = false, a = 0, time = 350, t = 0 }

-- GTA V private-room helpers are defined below; declared here so the
-- property sync/enter handlers can call them safely.
local ensureRoom, ensureAllRooms

local function f(n)
    n = tonumber(n) or 0
    local s = tostring(math.floor(n))
    local out = ""
    while #s > 3 do out = "," .. s:sub(-3) .. out; s = s:sub(1, -4) end
    return s .. out
end

local function drawPanel(x, y, w, h, title, subtitle)
    dxDrawRectangle(x, y, w, h, C(PANEL, 238))
    dxDrawRectangle(x, y, math.floor(3 * scale), w, C(GOLD))
    dxDrawRectangle(x, y + h - math.floor(2 * scale), w, math.floor(2 * scale), C(GOLD_DARK, 200))
    dxDrawRectangle(x + math.floor(w * 0.5) - math.floor(60 * scale), y, math.floor(120 * scale), 3, C(GOLD))
    if title then
        dxDrawText(title, x, y + math.floor(14 * scale), x + w, y + math.floor(48 * scale),
            C(WHITE), 1.15 * scale, "default-bold", "center", "top")
    end
    if subtitle then
        dxDrawText(subtitle, x, y + math.floor(52 * scale), x + w, y + math.floor(78 * scale),
            C(GOLD), 0.9 * scale, "default", "center", "top")
    end
end

local function button(text, x, y, w, h, options)
    options = options or {}
    local hovering = isMouseInPosition and isMouseInPosition(x, y, w, h) and ui ~= nil
    local base = options.color or GOLD
    dxDrawRectangle(x, y, w, h, C(base, hovering and 70 or 24))
    dxDrawRectangle(x, y, w, math.floor(2 * scale), C(base))
    dxDrawRectangle(x, y + h - math.floor(1 * scale), w, math.floor(1 * scale), C(base, 160))
    dxDrawText(text, x, y, x + w, y + h,
        C(options.textColor or WHITE), 0.95 * scale, "default-bold", "center", "center")
    table.insert(buttons, { x = x, y = y, w = w, h = h, action = options.action, data = options.data })
end

local function toast(text, kind)
    table.insert(toasts, {
        text = tostring(text), kind = kind or "info", t = getTickCount(), life = 6500,
    })
end

addEvent("lh:notify", true)
addEventHandler("lh:notify", root, function(text, kind)
    toast(text, kind)
end)

addEvent("lh:syncProps", true)
addEventHandler("lh:syncProps", root, function(list)
    props = {}
    for _, p in ipairs(list or {}) do
        p.id = tonumber(p.id)
        p.dim = tonumber(p.dim) or ((tonumber(LH.dimBase) or 21000) + p.id)
        props[p.id] = p
    end
    ensureAllRooms()
end)

addEvent("lh:inside", true)
addEventHandler("lh:inside", root, function(data)
    if not data then return end
    local id = tonumber(data.id) or 0
    if props[id] then
        data.dim = tonumber(data.dim) or props[id].dim
    end
    ensureRoom(id)
    inside = data
    if data.exit then
        inside.exit = { tonumber(data.exit[1]), tonumber(data.exit[2]), tonumber(data.exit[3]) }
    end
    toast("ENTER HOUSE - " .. tostring(data.name), "gold")
end)

addEvent("lh:outside", true)
addEventHandler("lh:outside", root, function()
    inside = nil
    ui = nil
    place = nil
    showCursor(false)
end)

addEvent("lh:fade", true)
addEventHandler("lh:fade", root, function(on, time)
    fade.on = on and true or false
    fade.time = tonumber(time) or 350
    fade.t = getTickCount()
    if on then fade.a = 0 else fade.a = 255 end
end)

addEvent("lh:closeUI", true)
addEventHandler("lh:closeUI", root, function()
    ui = nil
    showCursor(false)
end)

-- ============================================================
-- GTA V ECLIPSE TOWER PRIVATE ROOM
-- Real converted DFF/TXD/COL assets are loaded into custom object model IDs
-- and instantiated ONLY in each property's private dimension (21000 + id).
-- Nothing here touches stock GTA models or the exterior Liberty City world.
-- ============================================================

local ROOM_PARTS = {
    shell = {
        dff = "models/apt_mp_shell.dff",
        txd = "models/apt_mp_mod.txd",
        col = "models/apt_mp_shell.col",
    },
    int = {
        dff = "models/apt_mp_int.dff",
        txd = "models/apt_mp_int.txd",
        col = "models/apt_mp_int.col",
    },
    props = {
        dff = "models/apt_mp_props.dff",
        txd = "models/apt_mp_props.txd",
        col = "models/apt_mp_props.col",
    },
}

local roomAssets = {}       -- part -> { id, dff, txd, col }
local roomModels = {}       -- custom model ids (for engineFreeModel)
local rooms      = {}       -- property id -> { dim, objects = {} }
local assetsTried = false
local floorScale = nil

local function roomLog(text)
    outputDebugString("[luxury_houses][gtav] " .. tostring(text), 2)
end

local function stagePoint(lx, ly, lz)
    local g = LH.gtav or {}
    local rot = math.rad(tonumber(g.rotZ) or 0)
    local c, s = math.cos(rot), math.sin(rot)
    return (tonumber(g.originX) or 3000) + lx * c - ly * s,
           (tonumber(g.originY) or 3000) + lx * s + ly * c,
           (tonumber(g.originZ) or 500) + lz
end

local function loadRoomAssets()
    if assetsTried then return next(roomAssets) ~= nil end
    assetsTried = true

    if type(engineRequestModel) ~= "function" then
        roomLog("engineRequestModel unavailable - update MTA client")
        return false
    end

    local ok = true
    for name, path in pairs(ROOM_PARTS) do
        local model = engineRequestModel("object")
        if not model then
            roomLog("engineRequestModel failed for " .. name)
            ok = false
        else
            local txd = engineLoadTXD(path.txd)
            local dff = engineLoadDFF(path.dff, model)
            local col = engineLoadCOL(path.col)
            if not (txd and dff and col) then
                roomLog("asset load failed for " .. name ..
                    " (txd=" .. tostring(txd ~= false) ..
                    ", dff=" .. tostring(dff ~= false) ..
                    ", col=" .. tostring(col ~= false) .. ")")
                engineFreeModel(model)
                ok = false
            else
                engineImportTXD(txd, model)
                engineReplaceCOL(col, model)
                engineReplaceModel(dff, model)
                roomAssets[name] = { id = model, dff = dff, txd = txd, col = col }
                table.insert(roomModels, model)
            end
        end
    end

    -- Measure the invisible collision floor once, in an unused dimension,
    -- so the configured world size is exact regardless of the stock model.
    local tmp = createObject(1337, 29990, 29990, 490, 0, 0, 0)
    if tmp then
        setElementDimension(tmp, 31990)
        local minx, miny, minz, maxx, maxy, maxz = getElementBoundingBox(tmp)
        if minx and maxx and maxx > minx and maxy > miny and maxz >= minz then
            floorScale = {
                sx = (tonumber(LH.gtav.floorSizeX) or 28) / (maxx - minx),
                sy = (tonumber(LH.gtav.floorSizeY) or 46) / (maxy - miny),
                sz = (tonumber(LH.gtav.floorThickness) or 0.45) /
                     math.max(0.01, maxz - minz),
                cx = (minx + maxx) * 0.5,
                cy = (miny + maxy) * 0.5,
                cz = maxz,
            }
        end
        destroyElement(tmp)
    end
    if not floorScale then
        floorScale = { sx = 28, sy = 46, sz = 0.45, cx = 0, cy = 0, cz = 0.5 }
        roomLog("floor template unavailable - using configured fallback scale")
    end

    roomLog("assets ready: " .. tostring(next(roomAssets) ~= nil) ..
        ", custom models=" .. #roomModels)
    return next(roomAssets) ~= nil
end

local function applyStatic(element)
    if not isElement(element) then return end
    if setElementDoubleSided then setElementDoubleSided(element, true) end
    -- setElementFrozen replaces the deprecated setObjectStatic call (same
    -- pattern already applied to lc_premium_interiors).
    if setElementFrozen then setElementFrozen(element, true) end
end

local function makeSafetyFloor(dim)
    local g = LH.gtav or {}
    local s = floorScale
    if not s then return nil end

    -- scale first, then offset so the model's top face is exactly floorTopZ
    local lx = -s.cx * s.sx
    local ly = (tonumber(g.floorCenterY) or 2.4) - s.cy * s.sy
    local lz = (tonumber(g.floorTopZ) or -1.8) - s.cz * s.sz
    local x, y, z = stagePoint(lx, ly, lz)

    local o = createObject(1337, x, y, z, 0, 0, tonumber(g.rotZ) or 0)
    if not o then return nil end
    if setObjectScale then
        setObjectScale(o, s.sx, s.sy, s.sz)
    end
    setElementDimension(o, dim)
    setElementInterior(o, 0)
    setElementAlpha(o, 0)
    setElementCollisionsEnabled(o, true)
    applyStatic(o)
    return o
end

ensureRoom = function(id)
    id = tonumber(id) or 0
    if id <= 0 or not loadRoomAssets() then return end
    local p = props[id]
    local dim = p and tonumber(p.dim) or ((tonumber(LH.dimBase) or 21000) + id)
    if rooms[id] then return rooms[id] end

    local room = { dim = dim, objects = {} }
    local x, y, z = stagePoint(0, 0, 0)
    for name, asset in pairs(roomAssets) do
        local o = createObject(asset.id, x, y, z, 0, 0, tonumber(LH.gtav and LH.gtav.rotZ) or 0)
        if o then
            setElementDimension(o, dim)
            setElementInterior(o, 0)
            applyStatic(o)
            table.insert(room.objects, o)
        else
            roomLog("could not create room part " .. name .. " in dimension " .. dim)
        end
    end

    local floor = makeSafetyFloor(dim)
    if floor then table.insert(room.objects, floor) end
    rooms[id] = room
    return room
end

ensureAllRooms = function()
    for id, _ in pairs(props) do ensureRoom(id) end
    -- remove rooms whose property no longer exists
    for id, room in pairs(rooms) do
        if not props[id] then
            for _, o in ipairs(room.objects) do
                if isElement(o) then destroyElement(o) end
            end
            rooms[id] = nil
        end
    end
end

addEvent("lh:requestSync", false)

local function destroyRooms()
    for id, room in pairs(rooms) do
        for _, o in ipairs(room.objects) do
            if isElement(o) then destroyElement(o) end
        end
        rooms[id] = nil
    end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
    destroyRooms()
    for _, model in ipairs(roomModels) do
        if engineFreeModel then engineFreeModel(model) end
    end
    roomModels = {}
    roomAssets = {}
end)

-- ============================================================
-- ANIMATED EXTERIOR DOOR - ONE HOUSE DEMO (2026-11-20)
-- The LC map ALREADY has the real door object (model 1522) at the exact
-- Chinatown entrance. eagleLoader creates it CLIENT-SIDE as a streamed
-- object, so we locate that element and moveObject it. No new geometry is
-- added to dimension 0, no .map file is edited, and no other house changes.
-- ============================================================

local demoDoorEl   = nil   -- cached existing map object
local demoDoorTemp = nil   -- temporary object ONLY if map element is not loaded

local function findDemoDoorObject()
    local cfg = LH.demoDoor
    if not cfg then return nil end
    if demoDoorEl and isElement(demoDoorEl) then return demoDoorEl end
    demoDoorEl = nil
    for _, o in ipairs(getElementsByType("object") or {}) do
        if getElementModel(o) == tonumber(cfg.model) then
            local x, y, z = getElementPosition(o)
            if getDistanceBetweenPoints3D(x, y, z, cfg.x, cfg.y, cfg.z) < 1.5 then
                demoDoorEl = o
                return o
            end
        end
    end
    return nil
end

local function ensureDemoDoorObject()
    local o = findDemoDoorObject()
    if o then return o end
    local cfg = LH.demoDoor
    if not cfg then return nil end
    -- Rare fallback: the streamed map element is not loaded yet. Spawn one
    -- identical door for this animation only and destroy it after the close
    -- swing, so no duplicate exterior geometry is ever left behind.
    o = createObject(tonumber(cfg.model), cfg.x, cfg.y, cfg.z, 0, 0, tonumber(cfg.rotZ) or 0)
    if o then
        setElementDimension(o, 0)
        setElementInterior(o, 0)
        demoDoorTemp = o
        outputDebugString("[luxury_houses] demo door: temporary fallback object created")
    end
    return o
end

addEvent("lh:animateDoor", true)
addEventHandler("lh:animateDoor", root, function(pid, open)
    local cfg = LH.demoDoor
    if not cfg then return end
    local o = ensureDemoDoorObject()
    if not o or not isElement(o) then return end
    local ox, oy, oz = getElementPosition(o)
    local base = tonumber(cfg.rotZ) or 0
    local rz   = open and (base + (tonumber(cfg.openAngle) or -85)) or base
    local dur  = tonumber(cfg.animTime) or 800
    moveObject(o, dur, ox, oy, oz, 0, 0, rz, "InOutQuad")
    if not open and demoDoorTemp and isElement(demoDoorTemp) then
        setTimer(function()
            if demoDoorTemp and isElement(demoDoorTemp) then
                destroyElement(demoDoorTemp)
                demoDoorTemp = nil
                demoDoorEl   = nil
            end
        end, dur + 120, 1)
    end
end)

-- ============================================================
-- door hint + E interaction
-- ============================================================

local nearest = nil

local function findNearestDoor()
    if inside then return nil end
    if not getElementData(localPlayer, "char.spawned") then return nil end
    local x, y, z = getElementPosition(localPlayer)
    local best, bestD = nil, (LH.doorRange or 3.2) + 0.6
    for id, p in pairs(props) do
        local d = getDistanceBetweenPoints3D(x, y, z, p.x, p.y, p.z)
        if d < bestD then best, bestD = p, d end
    end
    return best
end

local function statusLine(p)
    if tonumber(p.owner) and tonumber(p.owner) > 0 then
        return "OWNED" .. (p.oname and (" - " .. p.oname) or ""), GOLD
    end
    return "FOR SALE - $" .. f(p.price), GREEN
end

-- ============================================================
-- LUXURY PROPERTY MARKER  (GTA V Online style)
-- Replaces the old yellow cylinder light completely.
--
--   * icon type per property:   house / apartment / warehouse
--   * state colours:            gold = for sale, soft white = owned,
--                               bright gold + bigger glow = VIP
--   * soft additive glow frame, rotating gold ring, gentle bobbing,
--     ground shadow - all pure dx* so nothing else is spawned.
-- ============================================================

local TEX = {}          -- file -> texture (false = creation failed)

local function tex(name)
    if TEX[name] == false then return nil end
    if not TEX[name] then
        TEX[name] = dxCreateTexture("textures/" .. name, "argb", true, "clamp") or false
    end
    return TEX[name] or nil
end

local function iconForType(ptype)
    ptype = tostring(ptype or ""):lower()
    if ptype == "warehouse" or ptype == "garage" or ptype == "depot" then
        return "warehouse_icon.png"
    elseif ptype == "penthouse" or ptype == "apartment" or ptype == "flat" then
        return "building_icon.png"
    end
    return "house_icon.png"
end

local function markerStyle(p)
    local owned = p and (tonumber(p.owner) or 0) > 0
    local price = p and (tonumber(p.price) or 0) or 0
    local vip   = price >= 500000
    if owned then
        return { 238, 232, 214 }, 1.45, 0.55      -- quiet gold-white
    elseif vip then
        return { 255, 216, 92 }, 1.75, 1.00       -- bright VIP gold
    end
    return { 212, 175, 55 }, 1.50, 0.80           -- classic gold, for sale
end

-- flat horizontal quad (ground fx)
local function drawFlat(x, y, z, material, size, colour, angle)
    local dx, dy = math.cos(angle) * size * 0.5, math.sin(angle) * size * 0.5
    dxDrawMaterialLine3D(x - dx, y - dy, z, x + dx, y + dy, z,
        material, size, colour, x, y, z + 8)
end

-- camera facing billboard
local function drawBillboard(x, y, z, material, size, colour)
    local camX, camY, camZ = getElementPosition(getCamera())
    dxDrawMaterialLine3D(x, y, z + size, x, y, z,
        material, size, colour, camX, camY, camZ)
end

local function drawPropertyMarker(x, y, baseZ, prop, tick, fade)
    local icon = tex(iconForType(prop and prop.ptype))
    if not icon then return end
    local ring = tex("ring.png")
    local glow = tex("glow.png")

    fade = fade or 1.0
    local col, size, glowPower = markerStyle(prop)
    local bob  = math.sin(tick / 720) * 0.10
    -- baseZ is the real ground/door threshold: ring sits on the pavement,
    -- the icon floats just above the door handle (1.05 m).
    local base = baseZ + 1.05 + bob

    -- ground shadow (dark, flat) - grounds the floating icon
    if glow then
        dxSetBlendMode("blend")
        drawFlat(x, y, baseZ + 0.05, glow, 1.9, tocolor(0, 0, 0, math.floor(95 * fade)), 0)
    end

    -- rotating golden ring on the pavement
    if ring then
        dxSetBlendMode("add")
        drawFlat(x, y, baseZ + 0.07, ring, 2.7,
            tocolor(col[1], col[2], col[3], math.floor(185 * fade)), tick / 1600)
        dxSetBlendMode("blend")
    end

    -- soft golden halo behind the icon
    if glow then
        dxSetBlendMode("add")
        local gs = size * 2.1
        drawBillboard(x, y, base - gs * 0.5, glow, gs,
            tocolor(col[1], col[2], col[3], math.floor(110 * glowPower * fade)))
        dxSetBlendMode("blend")
    end

    -- the house / building / warehouse icon itself
    drawBillboard(x, y, base, icon, size, tocolor(col[1], col[2], col[3], math.floor(255 * fade)))

    -- thin light beam under the icon so it is visible from a distance
    dxDrawLine3D(x, y, baseZ + 0.1, x, y, base - 0.05,
        tocolor(col[1], col[2], col[3], math.floor(70 * glowPower * fade)), 2)
end

local function drawHouseIcons()
    if not getElementData(localPlayer, "char.spawned") then return end
    local px, py, pz = getElementPosition(localPlayer)
    local tick = getTickCount()

    if inside then
        -- interior exit: one golden marker, always bright
        if inside.exit then
            drawPropertyMarker(inside.exit[1], inside.exit[2], inside.exit[3] - 1.0, nil, tick)
        end
        return
    end

    for _, p in pairs(props) do
        local d = getDistanceBetweenPoints3D(px, py, pz, p.x, p.y, p.z)
        if d < 90 then
            local fade = d < 35 and 1.0 or math.max(0.45, 1.0 - (d - 35) / 90)
            drawPropertyMarker(p.x, p.y, p.z, p, tick, fade)
        end
    end
end

local function drawDoorHint()
    if not nearest then return end
    local w, h = 420 * scale, 108 * scale
    local x = (sx - w) / 2
    local y = sy - h - 60 * scale
    dxDrawRectangle(x, y, w, h, C({ 8, 8, 10 }, 232))
    dxDrawRectangle(x, y, math.floor(4 * scale), h, C(GOLD))
    dxDrawText(nearest.name, x + 18 * scale, y + 10 * scale, x + w - 14 * scale, y + 40 * scale,
        C(WHITE), 1.05 * scale, "default-bold", "left", "top")
    dxDrawText(string.upper(tostring(nearest.ptype)) .. "  |  " .. tostring(nearest.district or "Liberty City"),
        x + 18 * scale, y + 38 * scale, x + w - 14 * scale, y + 60 * scale,
        C(GRAY), 0.82 * scale, "default", "left", "top")
    local txt, c = statusLine(nearest)
    dxDrawText(txt, x + 18 * scale, y + 60 * scale, x + w - 14 * scale, y + 82 * scale,
        C(c), 0.9 * scale, "default-bold", "left", "top")
    local blink = 150 + math.floor(105 * math.abs(math.sin(getTickCount() / 380)))
    dxDrawText("[ E ]  PRESS E TO " .. ((tonumber(nearest.owner) or 0) > 0 and "ENTER" or "VIEW / BUY"),
        x + 18 * scale, y + 80 * scale, x + w - 14 * scale, y + h - 6 * scale,
        C(GOLD, blink), 0.95 * scale, "default-bold", "left", "top")
end

local function drawInsideHint()    if not inside then return end
    -- property name badge (top-left)
    local w = 340 * scale
    dxDrawRectangle(24 * scale, 24 * scale, w, 62 * scale, C({ 8, 8, 10 }, 210))
    dxDrawRectangle(24 * scale, 24 * scale, math.floor(3 * scale), 62 * scale, C(GOLD))
    dxDrawText(inside.name or "Property", 38 * scale, 30 * scale, 24 * scale + w, 58 * scale,
        C(WHITE), 0.95 * scale, "default-bold", "left", "top")
    dxDrawText("You are inside - press E at the gold house icon to leave", 38 * scale, 54 * scale,
        24 * scale + w, 80 * scale, C(GRAY), 0.75 * scale, "default", "left", "top")

    if not inside.exit then return end
    local ex, ey, ez = inside.exit[1], inside.exit[2], inside.exit[3]
    local x, y, z = getElementPosition(localPlayer)
    if getDistanceBetweenPoints3D(x, y, z, ex, ey, ez) < (LH.exitRange or 2.8) + 0.8 then
        local bw, bh = 380 * scale, 76 * scale
        local bx = (sx - bw) / 2
        local by = sy - bh - 60 * scale
        dxDrawRectangle(bx, by, bw, bh, C({ 8, 8, 10 }, 232))
        dxDrawRectangle(bx, by, bw, math.floor(3 * scale), C(GOLD))
        dxDrawText("EXIT HOUSE", bx, by + 8 * scale, bx + bw, by + 40 * scale,
            C(GOLD), 1.1 * scale, "default-bold", "center", "top")
        local blink = 150 + math.floor(105 * math.abs(math.sin(getTickCount() / 380)))
        dxDrawText("[ E ]  PRESS E TO LEAVE", bx, by + 40 * scale, bx + bw, by + bh - 4 * scale,
            C(WHITE, blink), 0.9 * scale, "default-bold", "center", "top")
    end
end

-- ============================================================
-- panels
-- ============================================================

local function closeUI()
    ui = nil
    showCursor(false)
end

local function centerRect(w, h)
    return (sx - w) / 2, (sy - h) / 2, w, h
end

local function drawBuyUI()
    local d = ui.data
    if not d then return end
    local w, h = 620 * scale, 470 * scale
    local x, y = centerRect(w, h)
    drawPanel(x, y, w, h, "PROPERTY FOR SALE", tostring(d.name))
    local pad = 34 * scale
    local yy = y + 90 * scale
    local function line(label, value, vc)
        dxDrawText(label, x + pad, yy, x + w * 0.55, yy + 26 * scale, C(GRAY), 0.82 * scale, "default", "left", "top")
        dxDrawText(value, x + w * 0.5, yy, x + w - pad, yy + 26 * scale, C(vc or WHITE), 0.9 * scale, "default-bold", "right", "top")
        yy = yy + 30 * scale
    end
    line("TYPE", string.upper(tostring(d.ptype)), GOLD)
    line("DISTRICT", tostring(d.district))
    line("PRICE", "$" .. f(d.price), GREEN)
    if tonumber(d.rent) and tonumber(d.rent) > 0 then line("RENT (24H)", "$" .. f(d.rent), GOLD) end
    if tonumber(d.capacity) and tonumber(d.capacity) > 0 then line("CAPACITY", f(d.capacity) .. " SLOTS") end
    line("YOUR BANK", "$" .. f(d.bank), WHITE)

    yy = yy + 8 * scale
    local desc = tostring(d.description or d.desc or "")
    local curLine, lines = "", {}
    for word in desc:gmatch("%S+") do
        if #curLine + #word > 52 then table.insert(lines, curLine); curLine = word
        else curLine = (curLine == "" and word or (curLine .. " " .. word)) end
    end
    if curLine ~= "" then table.insert(lines, curLine) end
    for i = 1, math.min(#lines, 4) do
        dxDrawText(lines[i], x + pad, yy, x + w - pad, yy + 24 * scale, C(GRAY), 0.8 * scale, "default", "left", "top")
        yy = yy + 24 * scale
    end

    local bw = (w - pad * 3) / 2
    button("BUY PROPERTY  ($" .. f(d.price) .. ")", x + pad, y + h - 84 * scale, bw, 50 * scale,
        { action = "buy", data = d.id, color = GREEN })
    button("CLOSE", x + pad * 2 + bw, y + h - 84 * scale, bw, 50 * scale, { action = "close" })
end

local function drawManageUI()
    local d = ui.data
    if not d then return end
    local w, h = 680 * scale, 500 * scale
    local x, y = centerRect(w, h)
    drawPanel(x, y, w, h, "PROPERTY MANAGEMENT", tostring(d.name))
    local pad = 30 * scale
    local yy = y + 84 * scale
    dxDrawText("STATUS: " .. (tonumber(d.locked) == 1 and "LOCKED" or "UNLOCKED") ..
        "    |    TYPE: " .. string.upper(tostring(d.ptype)) ..
        "    |    DISTRICT: " .. tostring(d.district),
        x + pad, yy, x + w - pad, yy + 26 * scale, C(GOLD), 0.85 * scale, "default-bold", "left", "top")
    yy = yy + 34 * scale

    dxDrawText("KEYS (" .. #(d.keys or {}) .. "/" .. tostring(d.maxKeys) .. ")",
        x + pad, yy, x + w - pad, yy + 24 * scale, C(WHITE), 0.85 * scale, "default-bold", "left", "top")
    yy = yy + 26 * scale
    local kn = 0
    for _, k in ipairs(d.keys or {}) do
        if kn < 3 then
            dxDrawText("- " .. tostring(k.name) .. ((tonumber(k.expires) or 0) > 0 and "  (rented)" or ""),
                x + pad + 10 * scale, yy, x + w - pad, yy + 22 * scale, C(GRAY), 0.78 * scale, "default", "left", "top")
            yy = yy + 22 * scale
        end
        kn = kn + 1
    end

    local bw = (w - pad * 4) / 3
    local bh = 46 * scale
    local by = y + h - 160 * scale
    button(tonumber(d.locked) == 1 and "UNLOCK DOOR" or "LOCK DOOR",
        x + pad, by, bw, bh, { action = "lock", data = d.id })
    button("STORAGE", x + pad * 2 + bw, by, bw, bh, { action = "storage", data = d.id })
    button("FURNITURE", x + pad * 3 + bw * 2, by, bw, bh, { action = "furniture", data = d.id })

    local by2 = by + bh + 16 * scale
    button("GARAGE", x + pad, by2, bw, bh, { action = "garage", data = d.id })
    button("SELL TO BANK  ($" .. f(d.refund) .. ")", x + pad * 2 + bw, by2, bw, bh,
        { action = "sell", data = d.id, color = RED })
    button("CLOSE", x + pad * 3 + bw * 2, by2, bw, bh, { action = "close" })

    dxDrawText("Keys: /givekey <player>  -  /revokekey <player>", x + pad, y + h - 44 * scale,
        x + w - pad, y + h - 20 * scale, C(GRAY), 0.75 * scale, "default", "left", "top")
end

local function drawStorageUI()
    local d = ui.data
    if not d then return end
    local w, h = 760 * scale, 540 * scale
    local x, y = centerRect(w, h)
    drawPanel(x, y, w, h, "WAREHOUSE STORAGE",
        tostring(d.name) .. "   -   slots " .. tostring(d.slots) .. "/" .. tostring(d.capacity))
    local pad = 26 * scale
    local colW = (w - pad * 3) / 2
    local top = y + 88 * scale
    local bottom = y + h - 74 * scale
    local rowH = 30 * scale

    dxDrawText("YOUR INVENTORY  (click = store 1)", x + pad, top, x + pad + colW, top + 24 * scale,
        C(GOLD), 0.82 * scale, "default-bold", "left", "top")
    dxDrawText("IN THE WAREHOUSE  (click = take 1)", x + pad * 2 + colW, top, x + pad * 2 + colW * 2, top + 24 * scale,
        C(GOLD), 0.82 * scale, "default-bold", "left", "top")

    local maxRows = math.floor((bottom - top - 34 * scale) / rowH)
    for i, item in ipairs(d.inv or {}) do
        if i > maxRows then break end
        local ry = top + 30 * scale + (i - 1) * rowH
        dxDrawRectangle(x + pad, ry, colW, rowH - 2 * scale, C(WHITE, 10))
        dxDrawText(tostring(item.item) .. "  x" .. tostring(item.amount),
            x + pad + 8 * scale, ry, x + pad + colW - 8 * scale, ry + rowH,
            C(WHITE), 0.78 * scale, "default", "left", "center")
        table.insert(buttons, { x = x + pad, y = ry, w = colW, h = rowH, action = "deposit", data = item.item })
    end
    for i, item in ipairs(d.stored or {}) do
        if i > maxRows then break end
        local ry = top + 30 * scale + (i - 1) * rowH
        dxDrawRectangle(x + pad * 2 + colW, ry, colW, rowH - 2 * scale, C(GOLD, 14))
        dxDrawText(tostring(item.item) .. "  x" .. tostring(item.amount),
            x + pad * 2 + colW + 8 * scale, ry, x + pad * 2 + colW * 2 - 8 * scale, ry + rowH,
            C(WHITE), 0.78 * scale, "default", "left", "center")
        table.insert(buttons, { x = x + pad * 2 + colW, y = ry, w = colW, h = rowH, action = "withdraw", data = item.item })
    end

    button("CLOSE", x + w / 2 - 90 * scale, y + h - 62 * scale, 180 * scale, 44 * scale, { action = "close" })
end

local function drawFurnitureUI()
    local d = ui.data
    if not d then return end
    local w, h = 800 * scale, 600 * scale
    local x, y = centerRect(w, h)
    drawPanel(x, y, w, h, "FURNITURE CATALOG", tostring(d.name) .. "   -   bank $" .. f(d.bank))
    local pad = 24 * scale
    local cols = 3
    local bw = (w - pad * (cols + 1)) / cols
    local bh = 40 * scale
    local startY = y + 92 * scale
    local maxRows = math.floor((h - 170 * scale) / (bh + 10 * scale))
    local i = 0
    for _, fitem in ipairs(d.catalog or {}) do
        local colIdx = i % cols
        local rowIdx = math.floor(i / cols)
        if rowIdx < maxRows then
            local bx = x + pad + colIdx * (bw + pad)
            local by = startY + rowIdx * (bh + 10 * scale)
            dxDrawRectangle(bx, by, bw, bh, C(WHITE, 10))
            dxDrawText(tostring(fitem.name), bx + 8 * scale, by + 2 * scale, bx + bw - 8 * scale, by + bh / 2,
                C(WHITE), 0.74 * scale, "default", "left", "center")
            dxDrawText("$" .. f(fitem.price), bx + 8 * scale, by + bh / 2, bx + bw - 8 * scale, by + bh - 2 * scale,
                C(GOLD), 0.7 * scale, "default-bold", "left", "center")
            table.insert(buttons, { x = bx, y = by, w = bw, h = bh, action = "furnBuy", data = fitem.model })
        end
        i = i + 1
    end

    local py = y + h - 74 * scale
    dxDrawText("Placed items: " .. #(d.placed or {}) .. "   (owner only - remove refunds 50%)",
        x + pad, py - 26 * scale, x + w - pad, py, C(GRAY), 0.75 * scale, "default", "left", "top")
    local px = x + pad
    local shown = 0
    for _, item in ipairs(d.placed or {}) do
        if shown >= 8 then break end
        local rbw = 150 * scale
        button("MOVE #" .. tostring(item.id), px, py, 72 * scale, 34 * scale,
            { action = "furnMove", data = item.id })
        button("DEL #" .. tostring(item.id), px + 76 * scale, py, 72 * scale, 34 * scale,
            { action = "furnRemove", data = item.id, color = RED })
        px = px + rbw + 8 * scale
        if px + rbw > x + w - pad then px = x + pad; py = py + 38 * scale end
        shown = shown + 1
    end

    button("CLOSE", x + w - 170 * scale, y + h - 62 * scale, 145 * scale, 42 * scale, { action = "close" })
end

local function drawGarageUI()
    local d = ui.data
    if not d then return end
    local w, h = 720 * scale, 480 * scale
    local x, y = centerRect(w, h)
    drawPanel(x, y, w, h, "PRIVATE GARAGE",
        tostring(d.name) .. "   -   " .. #(d.vehicles or {}) .. "/" .. tostring(d.capacity))
    local pad = 26 * scale
    local rowH = 42 * scale
    local top = y + 92 * scale
    if #(d.vehicles or {}) == 0 then
        dxDrawText("Garage is empty. Drive your vehicle here and press PARK MY VEHICLE.", x + pad, top,
            x + w - pad, top + 30 * scale, C(GRAY), 0.85 * scale, "default", "left", "top")
    end
    for i, v in ipairs(d.vehicles or {}) do
        local ry = top + (i - 1) * rowH
        dxDrawRectangle(x + pad, ry, w - pad * 2, rowH - 4 * scale, C(WHITE, 12))
        dxDrawText("Vehicle model " .. tostring(v.model) .. "   " .. tostring(v.plate or ""),
            x + pad + 10 * scale, ry, x + pad + (w - pad * 2) * 0.6, ry + rowH,
            C(WHITE), 0.82 * scale, "default", "left", "center")
        table.insert(buttons, {
            x = x + w - pad - 150 * scale, y = ry, w = 140 * scale, h = rowH - 4 * scale,
            action = "retrieve", data = v.id,
        })
    end
    button("PARK MY VEHICLE", x + pad, y + h - 66 * scale, 210 * scale, 44 * scale, { action = "park", data = d.id })
    button("CLOSE", x + w - pad - 150 * scale, y + h - 66 * scale, 140 * scale, 44 * scale, { action = "close" })
end

-- ============================================================
-- placement mode (client-side preview object)
-- ============================================================

local function startPlacement(data)
    if place and isElement(place.el) then destroyElement(place.el) end
    place = nil
    if not data then return end
    local model = tonumber(data.model)
    if not model then return end
    local x, y, z = tonumber(data.x), tonumber(data.y), tonumber(data.z)
    if not x then
        local px, py, pz = getElementPosition(localPlayer)
        local _, _, rz = getElementRotation(localPlayer)
        x = px + math.sin(math.rad(-rz)) * 2.2
        y = py + math.cos(math.rad(-rz)) * 2.2
        z = pz - 0.9
    end
    local el = createObject(model, x, y, z, 0, 0, tonumber(data.rz) or 0)
    if not el then
        toast("This model could not be previewed.", "error")
        return
    end
    setElementCollisionsEnabled(el, false)
    setElementAlpha(el, 190)
    place = { model = model, name = data.name, el = el, moving = data.moving, fid = data.fid }
    ui = nil
    showCursor(false)
    toast("ARROWS move | R rotate | ENTER confirm | BACKSPACE cancel", "gold")
end

addEvent("lh:placeMode", true)
addEventHandler("lh:placeMode", root, function(data)
    startPlacement(data)
end)

addEvent("lh:placeModeEnd", true)
addEventHandler("lh:placeModeEnd", root, function()
    if place and isElement(place.el) then destroyElement(place.el) end
    place = nil
end)

local function updatePlacement()
    if not place or not isElement(place.el) then return end
    local el = place.el
    local x, y, z = getElementPosition(el)
    local speed = 0.075
    local _, _, cz = getElementRotation(localPlayer)
    local fx, fy = -math.sin(math.rad(cz)), math.cos(math.rad(cz))
    local rx, ry = -math.sin(math.rad(cz + 90)), math.cos(math.rad(cz + 90))
    local moved = false
    if getKeyState("arrow_up") then x = x + fx * speed; y = y + fy * speed; moved = true end
    if getKeyState("arrow_down") then x = x - fx * speed; y = y - fy * speed; moved = true end
    if getKeyState("arrow_right") then x = x + rx * speed; y = y + ry * speed; moved = true end
    if getKeyState("arrow_left") then x = x - rx * speed; y = y - ry * speed; moved = true end
    if moved then
        local gz = getGroundPosition(x, y, z + 3)
        if gz then z = gz + 0.05 end
        setElementPosition(el, x, y, z)
    end
end

local function drawPlacementHUD()
    if not place then return end
    local w, h = 540 * scale, 96 * scale
    local x = (sx - w) / 2
    local y = sy - h - 40 * scale
    dxDrawRectangle(x, y, w, h, C({ 8, 8, 10 }, 225))
    dxDrawRectangle(x, y, w, math.floor(3 * scale), C(GOLD))
    dxDrawText((place.moving and "MOVING: " or "PLACING: ") .. tostring(place.name or ""),
        x, y + 8 * scale, x + w, y + 40 * scale, C(GOLD), 1.0 * scale, "default-bold", "center", "top")
    dxDrawText("ARROWS = move    R = rotate    ENTER = confirm    BACKSPACE = cancel",
        x, y + 46 * scale, x + w, y + h - 6 * scale, C(WHITE), 0.8 * scale, "default", "center", "top")
end

-- ============================================================
-- render
-- ============================================================

local function drawToasts()
    local now = getTickCount()
    local i = 1
    while i <= #toasts do
        local t = toasts[i]
        local age = now - t.t
        if age > t.life then
            table.remove(toasts, i)
        else
            local alpha = 225
            if age > t.life - 800 then alpha = math.floor(225 * (t.life - age) / 800) end
            local w, h = 460 * scale, 48 * scale
            local x = sx - w - 24 * scale
            local y = 24 * scale + (i - 1) * (h + 8 * scale)
            local c = GOLD
            if t.kind == "error" then c = RED elseif t.kind == "success" then c = GREEN end
            dxDrawRectangle(x, y, w, h, C({ 10, 10, 12 }, alpha))
            dxDrawRectangle(x, y, math.floor(4 * scale), h, C(c, math.min(alpha, 255)))
            dxDrawText(t.text, x + 14 * scale, y, x + w - 12 * scale, y + h,
                C(WHITE, math.min(alpha, 255)), 0.85 * scale, "default", "left", "center", true, false, false, false, false, 0, 0, 0, w - 26 * scale)
            i = i + 1
        end
    end
end

local function drawFade()
    if not fade.t or fade.t == 0 then return end
    local p = (getTickCount() - fade.t) / math.max(1, fade.time)
    local alpha
    if fade.on then alpha = math.min(1, p) else alpha = math.max(0, fade.a / 255 - p) end
    fade.a = math.floor(alpha * 255)
    if alpha > 0.01 then
        dxDrawRectangle(0, 0, sx, sy, tocolor(0, 0, 0, math.floor(alpha * 255)))
    end
end

addEventHandler("onClientRender", root, function()
    buttons = {}
    if not ui then nearest = findNearestDoor() else nearest = nil end

    drawHouseIcons()

    if ui then
        if ui.mode == "buy" then drawBuyUI()
        elseif ui.mode == "manage" then drawManageUI()
        elseif ui.mode == "storage" then drawStorageUI()
        elseif ui.mode == "furniture" then drawFurnitureUI()
        elseif ui.mode == "garage" then drawGarageUI() end
    else
        drawDoorHint()
        drawInsideHint()
    end

    drawToasts()
    drawPlacementHUD()
    drawFade()
    updatePlacement()
end)

-- ============================================================
-- input
-- ============================================================

local function uiOpen() return ui ~= nil end

local function isTyping()
    return (isChatBoxInputActive and isChatBoxInputActive()) or (isConsoleActive and isConsoleActive())
end

bindKey("e", "down", function()
    if isTyping() then return end
    if uiOpen() or place then return end
    if inside then
        local ex, ey, ez
        if inside.exit then ex, ey, ez = inside.exit[1], inside.exit[2], inside.exit[3] end
        local x, y, z = getElementPosition(localPlayer)
        if ex and getDistanceBetweenPoints3D(x, y, z, ex, ey, ez) <= (LH.exitRange or 2.8) + 0.9 then
            triggerServerEvent("lh:requestExit", localPlayer)
        else
            triggerServerEvent("lh:requestEnter", localPlayer, inside.id)
        end
        return
    end
    if nearest then
        triggerServerEvent("lh:requestEnter", localPlayer, nearest.id)
    end
end)

bindKey("m", "down", function()
    if isTyping() or uiOpen() or place then return end
    if inside then
        triggerServerEvent("lh:openManage", localPlayer)
    else
        toast("Enter your property to open the management panel.", "info")
    end
end)

bindKey("backspace", "down", function()
    if not place then return end
    if place.moving then
        triggerServerEvent("lh:cancelMoveFurniture", localPlayer)
    else
        triggerServerEvent("lh:cancelPlace", localPlayer, inside and inside.id or 0)
    end
    if isElement(place.el) then destroyElement(place.el) end
    place = nil
end)

bindKey("enter", "down", function()
    if not place or not isElement(place.el) then return end
    local x, y, z = getElementPosition(place.el)
    local _, _, rz = getElementRotation(place.el)
    if place.moving then
        triggerServerEvent("lh:finishMoveFurniture", localPlayer, inside and inside.id or 0, place.fid, x, y, z, rz)
    else
        triggerServerEvent("lh:confirmPlace", localPlayer, inside and inside.id or 0, x, y, z, rz)
    end
    destroyElement(place.el)
    place = nil
end)

bindKey("r", "down", function()
    if place and isElement(place.el) then
        local rx, ry, rz = getElementRotation(place.el)
        setElementRotation(place.el, rx, ry, rz + 15)
    end
end)

-- button clicks
addEventHandler("onClientClick", root, function(btn, state, absX, absY)
    if btn ~= "left" or state ~= "down" or not ui then return end
    for _, b in ipairs(buttons) do
        if absX >= b.x and absX <= b.x + b.w and absY >= b.y and absY <= b.y + b.h then
            local action, data = b.action, b.data
            if action == "close" then closeUI()
            elseif action == "buy" then triggerServerEvent("lh:buy", localPlayer, data)
            elseif action == "sell" then triggerServerEvent("lh:sell", localPlayer, data)
            elseif action == "lock" then triggerServerEvent("lh:toggleLock", localPlayer, data)
            elseif action == "storage" then triggerServerEvent("lh:openStorage", localPlayer, data)
            elseif action == "furniture" then triggerServerEvent("lh:openFurnish", localPlayer, data)
            elseif action == "garage" then triggerServerEvent("lh:openGarage", localPlayer, data)
            elseif action == "deposit" then triggerServerEvent("lh:storageOp", localPlayer, ui.data.id, "deposit", data, 1)
            elseif action == "withdraw" then triggerServerEvent("lh:storageOp", localPlayer, ui.data.id, "withdraw", data, 1)
            elseif action == "furnBuy" then triggerServerEvent("lh:buyFurniture", localPlayer, ui.data.id, data)
            elseif action == "furnRemove" then triggerServerEvent("lh:removeFurniture", localPlayer, ui.data.id, data)
            elseif action == "furnMove" then triggerServerEvent("lh:startMoveFurniture", localPlayer, ui.data.id, data)
            elseif action == "park" then triggerServerEvent("lh:garagePark", localPlayer, data)
            elseif action == "retrieve" then triggerServerEvent("lh:garageRetrieve", localPlayer, ui.data.id, data) end
            return
        end
    end
end)

-- server-driven panels
local function openPanel(mode, data)
    ui = { mode = mode, data = data }
    showCursor(true)
end

addEvent("lh:showBuy", true)
addEventHandler("lh:showBuy", root, function(data) openPanel("buy", data) end)

addEvent("lh:showManage", true)
addEventHandler("lh:showManage", root, function(data) openPanel("manage", data) end)

addEvent("lh:showStorage", true)
addEventHandler("lh:showStorage", root, function(data) openPanel("storage", data) end)

addEvent("lh:showFurniture", true)
addEventHandler("lh:showFurniture", root, function(data) openPanel("furniture", data) end)

addEvent("lh:showGarage", true)
addEventHandler("lh:showGarage", root, function(data) openPanel("garage", data) end)

-- ============================================================
-- shell measurement (bounding boxes -> server)
-- ============================================================
-- 2026-11-18 FIX: this addEvent() used to be swallowed by the comment
-- line above it, so the server-triggered "lh:measure" event never existed
-- on the client. No property shell was ever measured, which is why buying
-- a house did not teleport the player inside (enterProperty refuses to
-- teleport into an unmeasured shell). Keep this line on its own!
addEvent("lh:measure", true)
addEventHandler("lh:measure", root, function(list)
    if type(list) ~= "table" then return end
    setTimer(function()
        local results = {}
        for _, entry in ipairs(list) do
            if isElement(entry.el) then
                local minx, miny, minz, maxx, maxy, maxz = getElementBoundingBox(entry.el)
                if minx then
                    table.insert(results, {
                        model = entry.model,
                        minx = minx, miny = miny, minz = minz,
                        maxx = maxx, maxy = maxy, maxz = maxz,
                    })
                end
            end
        end
        if #results > 0 then
            triggerServerEvent("lh:metrics", localPlayer, results)
        end
    end, 1500, 1)
end)

-- friendly boot hint + ask the server for the current property list
addEventHandler("onClientResourceStart", resourceRoot, function()
    if getElementData(localPlayer, "char.spawned") then
        triggerServerEvent("lh:requestSync", localPlayer)
    end
    setTimer(function()
        outputChatBox("#C9AF37[REAL ESTATE] #FFFFFFGold house markers mark luxury properties - press E at one. M = manage. Admin: /lhaddprop <price> turns any real door into a property.", 212, 175, 55, true)
    end, 6000, 1)
end)

-- ============================================================
-- door probe: the admin looks at a real door, we ray-cast the map
-- collision and send the exact door point to the server
-- ============================================================

addEvent("lh:probeDoor", true)
addEventHandler("lh:probeDoor", root, function()
    local px, py, pz = getElementPosition(localPlayer)
    local cx, cy, cz, tx, ty, tz = getCameraMatrix()
    local dx, dy = tx - cx, ty - cy
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 0.001 then dx, dy, len = 1, 0, 1 end
    dx, dy = dx / len, dy / len

    -- ground under the player
    local ghit, _, _, gz = processLineOfSight(px, py, pz + 1.2, px, py, pz - 4.0,
        true, true, false, true, false, false, false, false)
    local groundZ = ghit and gz or pz

    -- wall in front of the player (chest height)
    local sx, sy, sz = px + dx * 0.5, py + dy * 0.5, groundZ + 1.05
    local hit, hx, hy, hz = processLineOfSight(sx, sy, sz, sx + dx * 8, sy + dy * 8, sz,
        true, true, false, true, false, false, false, false)

    if not hit then
        outputChatBox("[REAL ESTATE] No wall in front of you - stand right at the door and look at it.",
            220, 120, 80)
        triggerServerEvent("lh:doorProbeResult", localPlayer, nil)
        return
    end

    -- 0.75 m out of the wall, snapped to the pavement
    local doorX, doorY = hx - dx * 0.75, hy - dy * 0.75
    local dhit, _, _, dgz = processLineOfSight(doorX, doorY, groundZ + 2.0, doorX, doorY, groundZ - 3.0,
        true, true, false, true, false, false, false, false)
    local doorZ = dhit and dgz or groundZ
    local rot = math.deg(math.atan2(-dx, -dy))

    triggerServerEvent("lh:doorProbeResult", localPlayer, doorX, doorY, doorZ, rot)
    outputChatBox(("[REAL ESTATE] Door detected at %.1f, %.1f, %.1f"):format(doorX, doorY, doorZ),
        212, 175, 55)
end)

-- ============================================================
-- water diagnostic: cast a vertical line and report the hit
-- ============================================================

addEvent("lh:waterProbe", true)
addEventHandler("lh:waterProbe", root, function()
    local x, y, z = getElementPosition(localPlayer)
    local hx, hy, hz = testLineAgainstWater(x, y, z + 250, x, y, z - 150)
    -- extra diagnostics: what the CLIENT actually has in its element tree
    local clientWaters = getElementsByType("water") or {}
    local nearest, nd, nz = nil, 1e9, nil
    for _, w in ipairs(clientWaters) do
        local wx, wy, wz = getElementPosition(w)
        local d = getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)
        if d < nd then nd, nearest, nz = d, w, wz end
    end
    -- 2026-11-18: getWaterLevel() needs coordinates (or a water element);
    -- calling it with no arguments logged a warning on every probe.
    local level = getWaterLevel(x, y, z)
    triggerServerEvent("lh:waterProbeResult", localPlayer,
        hx, hy, hz, #clientWaters, level or -9999,
        (isWaterDrawnLast and isWaterDrawnLast()) or false,
        nd < 1e9 and nd or -1, nz or -9999)
end)
