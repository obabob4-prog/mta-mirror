--[[ ============================================================
     lc_premium_interiors / client/c_main.lua
     Real converted DFF/TXD/COL rooms + pure-DX interface.

     Every room object is created only in its configured private
     dimension, interior 0, on a remote stage. The exterior Liberty
     City world is untouched. No CEF, no stock model replacement.
     ============================================================ ]]

local sx, sy = guiGetScreenSize()
local scale  = math.max(0.75, math.min(sx / 1920, sy / 1080))

local GOLD      = { 212, 175, 55 }
local GOLD_DARK = { 150, 120, 40 }
local PANEL     = { 11, 11, 13 }
local WHITE     = { 240, 240, 240 }
local GRAY      = { 150, 150, 150 }
local GREEN     = { 70, 180, 110 }
local RED       = { 200, 70, 60 }

local function C(c, a) return tocolor(c[1], c[2], c[3], a or 255) end

local function money(n)
    n = tonumber(n) or 0
    local s = tostring(math.floor(n))
    local out = ""
    while #s > 3 do
        out = "," .. s:sub(-3) .. out
        s = s:sub(1, -4)
    end
    return s .. out
end

local function isTyping()
    return (isChatBoxInputActive and isChatBoxInputActive()) or
           (isConsoleActive and isConsoleActive()) or
           (isMenuVisible and isMenuVisible())
end

local function inPosition(mx, my, x, y, w, h)
    if not mx or not my then return false end
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function isMouseInPosition(x, y, w, h)
    local mx, my = getCursorPosition()
    if mx and my then mx, my = mx * sx, my * sy end
    return inPosition(mx, my, x, y, w, h)
end

-- ============================================================
-- custom model assets + private rooms
-- ============================================================

local models       = {}   -- asset name -> custom object model id
local customModels = {}   -- ids to free on stop
local rooms        = {}   -- venue id -> { objects = {} }
local floorScale   = nil  -- generic measurement of model 1337
local assetsTried  = false
local roomsBuilt   = false

local function logLine(text)
    outputDebugString("[lc_premium_interiors][client] " .. tostring(text), 2)
end

local function loadAssets()
    if assetsTried then return next(models) ~= nil end
    assetsTried = true

    if type(engineRequestModel) ~= "function" then
        logLine("engineRequestModel unavailable - update MTA client")
        return false
    end

    local txdCache = {}
    local ok = true

    for name, path in pairs(LPI.assets or {}) do
        local model = engineRequestModel("object")
        if not model then
            logLine("engineRequestModel failed for " .. tostring(name))
            ok = false
        else
            local txd = txdCache[path.txd]
            if not txd then
                txd = engineLoadTXD(path.txd)
                txdCache[path.txd] = txd
            end
            local dff = engineLoadDFF(path.dff, model)
            local col = path.col and engineLoadCOL(path.col) or nil

            if not (txd and dff and (not path.col or col)) then
                logLine("asset load failed: " .. tostring(name) ..
                    " (txd=" .. tostring(txd ~= false) ..
                    ", dff=" .. tostring(dff ~= false) ..
                    ", col=" .. tostring(not path.col or col ~= false) .. ")")
                engineFreeModel(model)
                ok = false
            else
                engineImportTXD(txd, model)
                if col then engineReplaceCOL(col, model) end
                engineReplaceModel(dff, model)
                models[name] = model
                customModels[#customModels + 1] = model
            end
        end
    end

    -- Measure a stock cube once in an unused dimension. It is used only as
    -- an invisible collision floor; no exterior object is modified.
    local tmp = createObject(1337, 29991, 29991, 490, 0, 0, 0)
    if tmp then
        setElementDimension(tmp, LPI.dims.measure)
        setElementInterior(tmp, 0)
        local minx, miny, minz, maxx, maxy, maxz = getElementBoundingBox(tmp)
        if minx and maxx and maxx > minx and maxy > miny and maxz > minz then
            floorScale = {
                cx = (minx + maxx) * 0.5,
                cy = (miny + maxy) * 0.5,
                cz = maxz,
                sx = maxx - minx,
                sy = maxy - miny,
                sz = maxz - minz,
            }
        end
        destroyElement(tmp)
    end
    if not floorScale then
        floorScale = { cx = 0, cy = 0, cz = 0.5, sx = 1, sy = 1, sz = 1 }
        logLine("floor template unavailable - using fallback measurement")
    end

    logLine("assets ready=" .. tostring(ok) .. " models=" .. tostring(#customModels))
    return next(models) ~= nil
end

local function applyStatic(element)
    if not isElement(element) then return end
    if setElementDoubleSided then setElementDoubleSided(element, true) end
    if setElementFrozen then setElementFrozen(element, true) end
end

local function makeSafetyFloor(v)
    local fs = floorScale
    local fl = v.floor or {}
    if not fs then return nil end

    local sx = (tonumber(fl.sizeX) or 28) / math.max(0.01, fs.sx)
    local sy = (tonumber(fl.sizeY) or 46) / math.max(0.01, fs.sy)
    local sz = (tonumber(fl.thickness) or 0.45) / math.max(0.01, fs.sz)

    local lx = (tonumber(fl.centerX) or 0) - fs.cx * sx
    local ly = (tonumber(fl.centerY) or 0) - fs.cy * sy
    local lz = (tonumber(fl.topZ) or -1.8) - fs.cz * sz

    local x, y, z = LPI.stagePoint(v, lx, ly, lz)
    local o = createObject(1337, x, y, z, 0, 0, tonumber(v.rotZ) or 0)
    if not o then return nil end
    if setObjectScale then setObjectScale(o, sx, sy, sz) end
    setElementDimension(o, tonumber(v.dim))
    setElementInterior(o, tonumber(v.interior) or 0)
    setElementAlpha(o, 0)
    setElementCollisionsEnabled(o, true)
    applyStatic(o)
    return o
end

local function buildRoom(v)
    if not v or rooms[v.id] then return end
    if not loadAssets() then return end

    local room = { objects = {} }
    local x, y, z = LPI.stagePoint(v, 0, 0, 0)
    local rz = tonumber(v.rotZ) or 0

    for _, name in ipairs(v.assets or {}) do
        local model = models[name]
        if model then
            local o = createObject(model, x, y, z, 0, 0, rz)
            if o then
                setElementDimension(o, tonumber(v.dim))
                setElementInterior(o, tonumber(v.interior) or 0)
                applyStatic(o)
                room.objects[#room.objects + 1] = o
            else
                logLine("could not create asset " .. tostring(name) .. " in dim " .. tostring(v.dim))
            end
        end
    end

    local floor = makeSafetyFloor(v)
    if floor then room.objects[#room.objects + 1] = floor end
    rooms[v.id] = room
end

local function buildAllRooms()
    if roomsBuilt then return end
    roomsBuilt = true
    for id, v in pairs(LPI.venues or {}) do
        v.id = tonumber(id) or tonumber(v.id) or id
        buildRoom(v)
    end
end

local function destroyRooms()
    for id, room in pairs(rooms) do
        for _, o in ipairs(room.objects) do
            if isElement(o) then destroyElement(o) end
        end
        rooms[id] = nil
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    buildAllRooms()
    setTimer(function()
        outputChatBox("#C9AF37[PREMIUM] #FFFFFFE at a gold marker to enter. Inside: F for shop/gym/terminal, E to exit.", 212, 175, 55, true)
    end, 5000, 1)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    destroyRooms()
    for _, model in ipairs(customModels) do
        if engineFreeModel then engineFreeModel(model) end
    end
    customModels = {}
    models = {}
end)

-- ============================================================
-- state from server
-- ============================================================

local inside  = nil    -- { id, name, type, exit = {x,y,z}, ... }
local nearest = nil
local shop    = nil    -- { data = ..., status = "" }
local buttons = {}
local toasts  = {}
local fade    = { on = false, time = 350, t = 0 }

local function toast(text, kind)
    toasts[#toasts + 1] = {
        text = tostring(text), kind = kind or "info", t = getTickCount(), life = 6000,
    }
end

local function closeShop()
    shop = nil
    showCursor(false)
end

addEvent("lpi:notify", true)
addEventHandler("lpi:notify", root, function(text, kind)
    toast(text, kind)
end)

addEvent("lpi:fade", true)
addEventHandler("lpi:fade", root, function(on, time)
    fade.on = on and true or false
    fade.time = tonumber(time) or 350
    fade.t = getTickCount()
end)

addEvent("lpi:inside", true)
addEventHandler("lpi:inside", root, function(data)
    if not data then return end
    local id = tonumber(data.id) or 0
    local v = LPI.venues[id]
    if v then buildRoom(v) end
    inside = data
    closeShop()
    toast("ENTER - " .. tostring(data.name), "gold")
end)

addEvent("lpi:outside", true)
addEventHandler("lpi:outside", root, function()
    inside = nil
    nearest = nil
    closeShop()
end)

addEvent("lpi:showShop", true)
addEventHandler("lpi:showShop", root, function(data)
    shop = { data = data or {}, status = "" }
    showCursor(true)
end)

addEvent("lpi:shopStatus", true)
addEventHandler("lpi:shopStatus", root, function(text, ok)
    if shop then shop.status = tostring(text or "") end
    toast(text, ok and "success" or "error")
end)

addEvent("lpi:gymStatus", true)
addEventHandler("lpi:gymStatus", root, function(text, ok)
    toast(text, ok and "success" or "info")
end)

-- Server has already verified which room we are in; this only forwards the
-- request to the existing LCPD / LmB server events, which re-validate it.
addEvent("lpi:openService", true)
addEventHandler("lpi:openService", root, function(kind)
    if kind == "police" then
        triggerServerEvent("pd:request", localPlayer, "dashboard")
    elseif kind == "mechanic" then
        triggerServerEvent("lmb:request", localPlayer)
    end
end)

-- ============================================================
-- DX helpers
-- ============================================================

local function drawPanel(x, y, w, h, title, subtitle)
    dxDrawRectangle(x, y, w, h, C(PANEL, 242))
    dxDrawRectangle(x, y, math.floor(3 * scale), h, C(GOLD))
    dxDrawRectangle(x, y + h - math.floor(2 * scale), w, math.floor(2 * scale), C(GOLD_DARK, 210))
    dxDrawRectangle(x + math.floor(w * 0.5) - math.floor(70 * scale), y,
        math.floor(140 * scale), math.floor(3 * scale), C(GOLD))
    if title then
        dxDrawText(title, x, y + math.floor(12 * scale), x + w, y + math.floor(44 * scale),
            C(WHITE), 1.08 * scale, "default-bold", "center", "top")
    end
    if subtitle then
        dxDrawText(subtitle, x, y + math.floor(46 * scale), x + w, y + math.floor(72 * scale),
            C(GOLD), 0.86 * scale, "default", "center", "top")
    end
end

local function drawButton(text, x, y, w, h, options)
    options = options or {}
    local hover = isMouseInPosition(x, y, w, h) and shop ~= nil
    local base = options.color or GOLD
    dxDrawRectangle(x, y, w, h, C(base, hover and 72 or 26))
    dxDrawRectangle(x, y, w, math.floor(2 * scale), C(base))
    dxDrawText(text, x + 6 * scale, y, x + w - 6 * scale, y + h,
        C(options.textColor or WHITE), (options.fontSize or 0.82) * scale,
        "default-bold", "center", "center")
    buttons[#buttons + 1] = {
        x = x, y = y, w = w, h = h, action = options.action, data = options.data,
    }
end

local function drawWorldMarker(x, y, z, title, sub, color, range)
    local px, py, pz = getElementPosition(localPlayer)
    local dist = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
    if dist > (range or 80) then return end

    local screenX, screenY, inFront = getScreenFromWorldPosition(x, y, z + 1.25, 0, true)
    if not screenX or not screenY or not inFront then return end

    local s = scale * math.max(0.55, math.min(1.45, 20 / math.max(4, dist)))
    local r = 24 * s
    local blink = 150 + math.floor(105 * math.abs(math.sin(getTickCount() / 380)))

    for i = 0, 23 do
        local a1 = math.pi * 2 * i / 24
        local a2 = math.pi * 2 * (i + 1) / 24
        dxDrawLine(screenX + math.cos(a1) * r, screenY + math.sin(a1) * r * 0.42,
                   screenX + math.cos(a2) * r, screenY + math.sin(a2) * r * 0.42,
                   C(color, blink), math.max(1, 2 * s))
    end
    dxDrawLine(screenX, screenY - r * 0.42, screenX, screenY - r * 1.35,
        C(color, 110), math.max(1, 2 * s))
    dxDrawText(title, screenX - r * 2.6, screenY - r * 2.9, screenX + r * 2.6, screenY - r * 1.25,
        C(WHITE), 0.92 * s, "default-bold", "center", "bottom")
    dxDrawText(sub, screenX - r * 2.6, screenY + r * 0.7, screenX + r * 2.6, screenY + r * 2.2,
        C(GOLD, blink), 0.82 * s, "default-bold", "center", "top")
end

local function drawBottomHint(title, line1, line2)
    local w, h = 460 * scale, 92 * scale
    local x = (sx - w) / 2
    local y = sy - h - 58 * scale
    dxDrawRectangle(x, y, w, h, C({ 8, 8, 10 }, 232))
    dxDrawRectangle(x, y, math.floor(4 * scale), h, C(GOLD))
    dxDrawText(title, x + 16 * scale, y + 8 * scale, x + w - 12 * scale, y + 36 * scale,
        C(GOLD), 1.02 * scale, "default-bold", "left", "top")
    dxDrawText(line1, x + 16 * scale, y + 38 * scale, x + w - 12 * scale, y + 62 * scale,
        C(WHITE), 0.86 * scale, "default", "left", "top")
    dxDrawText(line2, x + 16 * scale, y + 62 * scale, x + w - 12 * scale, y + h - 6 * scale,
        C(GRAY), 0.78 * scale, "default", "left", "top")
end

local function actionLabel(v)
    if not v then return "SERVICE" end
    if v.type == "shop" then return "BROWSE SHOP" end
    if v.type == "gym" then return "TRAIN (FREE)" end
    if v.type == "police" then return "LCPD TERMINAL" end
    if v.type == "mechanic" then return "LmB CUSTOMS TERMINAL" end
    return "SERVICE"
end

local function findNearestDoor()
    if inside or shop then return nil end
    if not getElementData(localPlayer, "char.spawned") then return nil end
    if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return nil end

    local px, py, pz = getElementPosition(localPlayer)
    local best, bestD = nil, (tonumber(LPI.doorRange) or 4.5) + 1.0
    for _, v in pairs(LPI.venues or {}) do
        local d = getDistanceBetweenPoints3D(px, py, pz, v.door.x, v.door.y, v.door.z)
        if d < bestD then best, bestD = v, d end
    end
    return best
end

local function drawOutside()
    if not getElementData(localPlayer, "char.spawned") then return end
    if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return end

    for _, v in pairs(LPI.venues or {}) do
        drawWorldMarker(v.door.x, v.door.y, v.door.z, v.name, "PRESS E TO ENTER", GOLD, 75)
    end
    if nearest then
        drawBottomHint(nearest.name, "[ E ]  ENTER PREMIUM INTERIOR",
            string.upper(tostring(nearest.type)) .. "  |  PRIVATE GTA V ROOM")
    end
end

local function drawInside()
    if not inside then return end
    local v = LPI.venues[tonumber(inside.id)]
    local ex, ey, ez = inside.exit[1], inside.exit[2], inside.exit[3]

    drawWorldMarker(ex, ey, ez, "EXIT", "PRESS E TO LEAVE", GOLD, 60)

    local w = 370 * scale
    dxDrawRectangle(22 * scale, 22 * scale, w, 74 * scale, C({ 8, 8, 10 }, 216))
    dxDrawRectangle(22 * scale, 22 * scale, math.floor(3 * scale), 74 * scale, C(GOLD))
    dxDrawText(inside.name or "Premium Interior", 36 * scale, 28 * scale,
        22 * scale + w, 56 * scale, C(WHITE), 0.98 * scale, "default-bold", "left", "top")
    dxDrawText("[ F ]  " .. actionLabel(v), 36 * scale, 56 * scale,
        22 * scale + w, 82 * scale, C(GOLD), 0.86 * scale, "default-bold", "left", "top")
    dxDrawText("E at the gold marker = leave | /lpiexit if stuck", 36 * scale, 80 * scale,
        22 * scale + w, 96 * scale, C(GRAY), 0.72 * scale, "default", "left", "top")

    local px, py, pz = getElementPosition(localPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, ex, ey, ez) <= (tonumber(LPI.exitRange) or 3.2) + 1.2 then
        drawBottomHint("EXIT INTERIOR", "[ E ]  RETURN TO THE STREET", "Your exact entry point is restored.")
    else
        drawBottomHint(actionLabel(v), "[ F ]  USE THE SERVICE", "Walk to the gold EXIT marker and press E to leave.")
    end
end

-- ============================================================
-- shop panel (pure DX)
-- ============================================================

local function drawShopUI()
    local d = shop and shop.data
    if not d then return end

    local w, h = 780 * scale, 540 * scale
    local x, y = (sx - w) / 2, (sy - h) / 2
    drawPanel(x, y, w, h, "GTA V BOUTIQUE 24/7", tostring(d.name or "Premium Shop"))

    local pad = 26 * scale
    dxDrawText("CASH: $" .. money(d.cash), x + pad, y + 76 * scale,
        x + w - pad, y + 98 * scale, C(GREEN), 0.92 * scale, "default-bold", "right", "top")

    dxDrawText("ITEMS", x + pad, y + 106 * scale, x + w - pad, y + 128 * scale,
        C(GOLD), 0.86 * scale, "default-bold", "left", "top")
    local bw = (w - pad * 3) / 2
    local bh = 46 * scale
    for i, item in ipairs(d.items or {}) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local bx = x + pad + col * (bw + pad)
        local by = y + 130 * scale + row * (bh + 8 * scale)
        drawButton(tostring(item.name) .. "   -   $" .. money(item.price),
            bx, by, bw, bh, { action = "item", data = item.key, fontSize = 0.82 })
    end

    local outY = y + 236 * scale
    dxDrawText("HD OUTFITS  -  $" .. money(d.outfitPrice) .. " each",
        x + pad, outY, x + w - pad, outY + 22 * scale,
        C(GOLD), 0.86 * scale, "default-bold", "left", "top")

    local oh = 30 * scale
    local gap = 5 * scale
    local maxRows = 5
    for i, skin in ipairs(d.skins or {}) do
        if i <= maxRows * 2 then
            local col = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            local bx = x + pad + col * (bw + pad)
            local by = outY + 26 * scale + row * (oh + gap)
            local tag = skin.id == d.currentSkin and "  [WORN]" or ""
            drawButton(tostring(skin.name) .. tag, bx, by, bw, oh,
                { action = "outfit", data = skin.id, fontSize = 0.7 })
        end
    end

    local sy0 = y + h - 62 * scale
    dxDrawText(tostring(shop.status or ""), x + pad, sy0 - 20 * scale,
        x + w - pad, sy0, C(GRAY), 0.74 * scale, "default", "left", "center")
    drawButton("CLOSE", x + w - pad - 130 * scale, sy0, 130 * scale, 40 * scale,
        { action = "close" })
end

addEventHandler("onClientClick", root, function(btn, state, absX, absY)
    if btn ~= "left" or state ~= "down" or not shop then return end
    for _, b in ipairs(buttons) do
        if inPosition(absX, absY, b.x, b.y, b.w, b.h) then
            if b.action == "close" then
                closeShop()
            elseif b.action == "item" then
                triggerServerEvent("lpi:buyItem", localPlayer, b.data)
            elseif b.action == "outfit" then
                triggerServerEvent("lpi:buyOutfit", localPlayer, b.data)
            end
            return
        end
    end
end)

-- ============================================================
-- toasts + fade + render
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
            if age > t.life - 800 then
                alpha = math.floor(225 * (t.life - age) / 800)
            end
            local c = GOLD
            if t.kind == "error" then c = RED
            elseif t.kind == "success" then c = GREEN end
            local w, h = 450 * scale, 46 * scale
            local x = sx - w - 22 * scale
            local y = 22 * scale + (i - 1) * (h + 7 * scale)
            dxDrawRectangle(x, y, w, h, C({ 10, 10, 12 }, alpha))
            dxDrawRectangle(x, y, math.floor(4 * scale), h, C(c, math.min(alpha, 255)))
            dxDrawText(t.text, x + 12 * scale, y, x + w - 10 * scale, y + h,
                C(WHITE, math.min(alpha, 255)), 0.84 * scale, "default", "left", "center")
            i = i + 1
        end
    end
end

local function drawFade()
    if not fade.t or fade.t == 0 then return end
    local p = (getTickCount() - fade.t) / math.max(1, fade.time)
    local a
    if fade.on then a = math.min(1, p) else a = math.max(0, 1 - p) end
    if a > 0.01 then
        dxDrawRectangle(0, 0, sx, sy, tocolor(0, 0, 0, math.floor(a * 255)))
    end
end

addEventHandler("onClientRender", root, function()
    buttons = {}
    if not shop then nearest = findNearestDoor() else nearest = nil end

    if shop then
        drawShopUI()
    else
        drawOutside()
        drawInside()
    end

    drawToasts()
    drawFade()
end)

-- ============================================================
-- input
-- ============================================================

bindKey("e", "down", function()
    if isTyping() or shop or fade.on then return end
    if inside then
        local x, y, z = getElementPosition(localPlayer)
        local ex, ey, ez = inside.exit[1], inside.exit[2], inside.exit[3]
        if getDistanceBetweenPoints3D(x, y, z, ex, ey, ez) <= (tonumber(LPI.exitRange) or 3.2) + 1.2 then
            triggerServerEvent("lpi:requestExit", localPlayer)
        else
            toast("Walk to the gold EXIT marker to leave.", "info")
        end
        return
    end
    if nearest then
        triggerServerEvent("lpi:requestEnter", localPlayer, nearest.id)
    end
end)

bindKey("f", "down", function()
    if isTyping() or shop or fade.on or not inside then return end
    local v = LPI.venues[tonumber(inside.id)]
    if not v then return end

    if v.type == "shop" then
        triggerServerEvent("lpi:openShop", localPlayer)
    elseif v.type == "gym" then
        triggerServerEvent("lpi:gymTrain", localPlayer)
    elseif v.type == "police" then
        triggerServerEvent("lpi:service", localPlayer, "police")
    elseif v.type == "mechanic" then
        triggerServerEvent("lpi:service", localPlayer, "mechanic")
    end
end)

bindKey("backspace", "down", function()
    if shop then closeShop() end
end)

bindKey("escape", "down", function()
    if shop then closeShop() end
end)
