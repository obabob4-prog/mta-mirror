--[[
    ng-shops c_shops.lua - GTA V style retail interface (pure DX, no CEF)
    -------------------------------------------------------------------
    - dark glass panels, blue/gold accents, item list + detail preview
    - category tabs, hover states, mouse wheel scroll, buy confirmation
    - proximity [E] prompt rendered in world space style
    - all purchases still validated by s_shops.lua
]]

local SW, SH = guiGetScreenSize()
local BX, BY = 1920, 1080

local function sx(v) return v * SW / BX end
local function sy(v) return v * SH / BY end
local function fs(v) return v * math.min(SW / BX, SH / BY) end

local P = {
    overlay = { 4,   7,  11, 215 },
    bg      = { 11,  15,  22, 252 },
    panel   = { 18,  24,  33, 250 },
    panel2  = { 26,  34,  46, 250 },
    line    = { 46,  60,  78, 255 },
    accent  = { 76, 166, 255, 255 },
    accentS = { 76, 166, 255, 52  },
    gold    = { 232,197, 107, 255 },
    green   = { 126,217,  87, 255 },
    red     = { 224, 91,  91, 255 },
    text    = { 236,241, 248, 255 },
    dim     = { 151,164, 181, 255 },
    dark    = { 7,  10,  14, 235 },
}

local function C(key, mul)
    local c = P[key] or key
    return tocolor(c[1], c[2], c[3], math.floor((c[4] or 255) * (mul or 1)))
end

local function money(n)
    n = math.floor(tonumber(n) or 0)
    local s = tostring(n)
    local a = {}
    for i = #s, 1, -1 do
        a[#a + 1] = s:sub(i, i)
        if (#a - 1) % 3 == 0 and i > 1 then a[#a + 1] = "," end
    end
    local out = ""
    for i = #a, 1, -1 do out = out .. a[i] end
    return out
end

-- mirrors the server CATALOGS exactly ----------------------------------------
local CATALOGS = {
    store = {
        { item="burger",    name="Burger",          price=12,  cat="FOOD",    icon="BG", col={210,150,80},  desc="Fresh grilled burger with cheese and salad. A Liberty City classic." },
        { item="pizza",     name="Pizza Slice",     price=18,  cat="FOOD",    icon="PZ", col={225,120,70},  desc="Hot cheese and pepperoni slice. Perfect for a quick stop." },
        { item="water",     name="Water Bottle",    price=5,   cat="DRINKS",  icon="WA", col={90,170,235},  desc="Still mineral water. Restores 30 thirst." },
        { item="soda",      name="Soda Can",        price=6,   cat="DRINKS",  icon="SO", col={205,70,80},   desc="Ice cold cola. Restores 25 thirst." },
        { item="medkit",    name="Medkit",          price=90,  cat="TOOLS",   icon="MD", col={225,80,90},   desc="Restores 60 health. Keep one in the glovebox." },
        { item="repairkit", name="Repair Kit",      price=220, cat="TOOLS",   icon="RK", col={120,190,110}, desc="Full vehicle repair kit for roadside emergencies." },
        { item="fuelcan",   name="Fuel Canister",   price=60,  cat="TOOLS",   icon="FC", col={200,170,90},  desc="Portable fuel can. Never get stranded again." },
        { item="phone",     name="Phone",           price=350, cat="TECH",    icon="PH", col={80,140,220},  desc="Smartphone for calls and city contacts." },
        { item="radio",     name="Radio",           price=80,  cat="TECH",    icon="RA", col={130,110,210}, desc="Portable radio receiver." },
        { item="backpack",  name="Backpack",        price=250, cat="TECH",    icon="BP", col={110,150,130}, desc="Expands inventory capacity from 20 to 35 slots." },
    },
    food = {
        { item="burger", name="Fresh Burger",  price=10, cat="FOOD",   icon="BG", col={210,150,80}, desc="Flame-grilled beef burger, made fresh to order." },
        { item="pizza",  name="Pizza Slice",    price=15, cat="FOOD",   icon="PZ", col={225,120,70}, desc="Loaded cheese and pepperoni slice." },
        { item="water",  name="Water Bottle",   price=5,  cat="DRINKS", icon="WA", col={90,170,235}, desc="Chilled mineral water." },
        { item="soda",   name="Soda Can",       price=6,  cat="DRINKS", icon="SO", col={205,70,80},  desc="Ice cold soda can." },
    },
}

local TABS = { "ALL", "FOOD", "DRINKS", "TECH", "TOOLS" }

local BANNERS = {
    [1] = "images/banner_247_bohan.png",
    [2] = "images/banner_247_dukes.png",
    [3] = "images/banner_burgershot.png",
    [4] = "images/banner_binco.png",
}
local bannerTex = {}

local ui = {
    open = false, payload = nil, cat = "ALL", sel = 1, scroll = 0,
    openedAt = 0, toast = nil, near = nil, points = {},
    view = "catalog", -- catalog | stores
    storeSel = 1,
}

local hit = { tabs = {}, rows = {}, buy = nil, close = nil, storesBtn = nil, storeRows = {}, backBtn = nil }

local function filtered()
    local out = {}
    local list = CATALOGS[ui.payload and ui.payload.type or "store"] or {}
    for _, it in ipairs(list) do
        if ui.cat == "ALL" or it.cat == ui.cat then out[#out + 1] = it end
    end
    return out
end

local function closeUI()
    if not ui.open then return end
    ui.open = false
    ui.payload = nil
    if isCursorShowing() then showCursor(false) end
    triggerServerEvent("ngsh:hide", localPlayer)
end

addEvent("ngsh:show", true)
addEventHandler("ngsh:show", root, function(p)
    if not p or not p.type then return end
    ui.open = true
    ui.payload = p
    ui.cat = "ALL"
    ui.sel = 1
    ui.scroll = 0
    ui.view = "catalog"
    ui.openedAt = getTickCount()
    if not isCursorShowing() then showCursor(true) end
end)

addEvent("ngsh:points", true)
addEventHandler("ngsh:points", root, function(points)
    if type(points) == "table" then ui.points = points end
end)

addEvent("ngsh:hide", true)
addEventHandler("ngsh:hide", root, function()
    if ui.open then
        ui.open = false
        ui.payload = nil
        if isCursorShowing() then showCursor(false) end
    end
end)

addEvent("ngsh:status", true)
addEventHandler("ngsh:status", root, function(text, ok)
    ui.toast = { text = tostring(text), ok = ok and true or false, until_ = getTickCount() + 3600 }
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    ui.points = getElementData(resourceRoot, "ngsh.points") or {}
    for idx, path in pairs(BANNERS) do
        if fileExists(path) then
            bannerTex[idx] = dxCreateTexture(path, "argb", false, "wrap")
        end
    end
    triggerServerEvent("ngsh:requestPoints", localPlayer)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, tex in pairs(bannerTex) do
        if isElement(tex) then destroyElement(tex) end
    end
end)

bindKey("escape", "down", function() if ui.open then closeUI() end end)
bindKey("backspace", "down", function() if ui.open then closeUI() end end)

local function cursorPos()
    if not isCursorShowing() then return -1, -1 end
    local rx, ry = getCursorPosition()
    return rx * SW, ry * SH
end

local function inBox(cx, cy, x, y, w, h)
    return cx >= x and cx <= x + w and cy >= y and cy <= y + h
end

local function drawPanel(x, y, w, h, key)
    dxDrawRectangle(x, y, w, h, C(key or "panel"))
    dxDrawRectangle(x, y, w, 2, C("line"))
    dxDrawRectangle(x, y, 2, h, C("line"))
    dxDrawRectangle(x + w - 2, y, 2, h, C("line"))
    dxDrawRectangle(x, y + h - 2, w, 2, C("line"))
end

local function drawUI()
    local p = ui.payload
    if not p then return end

    local now = getTickCount()
    local fade = math.min(1, (now - ui.openedAt) / 220)

    dxDrawRectangle(0, 0, SW, SH, C("overlay", fade))

    local w, h = sx(1180), sy(700)
    local x, y = (SW - w) / 2, (SH - h) / 2
    drawPanel(x, y, w, h, "bg")

    -- accent top line + glow strip
    dxDrawRectangle(x, y, w, sy(5), C("accent", fade))
    dxDrawRectangle(x, y + sy(5), w, sy(28), C("accentS", fade))

    local cx, cy = cursorPos()

    -- header with shop banner --------------------------------------------
    local headH = sy(82)
    dxDrawRectangle(x, y + sy(5), w, headH, C("panel", fade))
    local btex = bannerTex[p.idx]
    if btex and isElement(btex) then
        dxDrawImage(x, y + sy(5), w, headH, btex, 0, 0, 0, tocolor(255,255,255, math.floor(210 * fade)))
        dxDrawRectangle(x, y + sy(5), w, headH, tocolor(8,12,18, math.floor(120 * fade)))
    end
    dxDrawText(tostring(p.name), x + sx(26), y + sy(12), x + sx(700), y + sy(50),
        C("text", fade), fs(1.55), "default-bold", "left", "center", true)
    dxDrawText((p.zone or "LIBERTY CITY") .. "  //  LICENSED RETAIL  //  متجر رسمي",
        x + sx(28), y + sy(52), x + sx(700), y + sy(78),
        C("dim", fade), fs(0.95), "arial", "left", "center", true)

    local cash = getElementData(localPlayer, "char.cash") or p.cash or 0
    dxDrawText("CASH", x + w - sx(360), y + sy(18), x + w - sx(130), y + sy(40),
        C("dim", fade), fs(0.95), "arial", "right", "center", true)
    dxDrawText("$" .. money(cash), x + w - sx(360), y + sy(40), x + w - sx(130), y + sy(70),
        C("green", fade), fs(1.35), "default-bold", "right", "center", true)

    -- stores directory button
    local sbW, sbH = sx(118), sy(30)
    hit.storesBtn = { x + w - sx(260), y + sy(28), sbW, sbH }
    local sbHover = inBox(cx, cy, hit.storesBtn[1], hit.storesBtn[2], sbW, sbH)
    local sbActive = (ui.view == "stores")
    dxDrawRectangle(hit.storesBtn[1], hit.storesBtn[2], sbW, sbH,
        sbActive and C("accent", fade) or (sbHover and C("panel2", fade) or C("dark", fade)))
    dxDrawRectangle(hit.storesBtn[1], hit.storesBtn[2] + sbH - sy(2), sbW, sy(2), C("gold", fade))
    dxDrawText("STORES  المتاجر", hit.storesBtn[1], hit.storesBtn[2], hit.storesBtn[1] + sbW, hit.storesBtn[2] + sbH,
        sbActive and C("dark", fade) or C("text", fade), fs(0.8), "default-bold", "center", "center", true)

    hit.close = { x + w - sx(50), y + sy(18), sx(32), sy(32) }
    local closeHover = inBox(cx, cy, hit.close[1], hit.close[2], hit.close[3], hit.close[4])
    dxDrawRectangle(hit.close[1], hit.close[2], hit.close[3], hit.close[4],
        closeHover and C("red", fade) or C("panel2", fade))
    dxDrawText("X", hit.close[1], hit.close[2], hit.close[1] + hit.close[3], hit.close[2] + hit.close[4],
        C("text", fade), fs(1.05), "default-bold", "center", "center", true)

    -- stores directory view ----------------------------------------------
    if ui.view == "stores" then
        hit.tabs = {}
        hit.rows = {}
        hit.buy = nil
        hit.storeRows = {}
        local ly = y + sy(100)
        local lh = h - sy(135)
        local lx = x + sx(24)
        local lw = w - sx(48)
        drawPanel(lx, ly, lw, lh, "panel")
        dxDrawText("قائمة المتاجر  -  STORE DIRECTORY", lx + sx(20), ly + sy(12), lx + lw - sx(20), ly + sy(44),
            C("gold", fade), fs(1.2), "default-bold", "left", "center", true)
        dxDrawRectangle(lx + sx(20), ly + sy(46), lw - sx(40), sy(2), C("line", fade))

        local list = ui.points or {}
        local rowH = sy(96)
        local startY = ly + sy(58)
        local maxRows = math.floor((lh - sy(70)) / (rowH + sy(10)))
        for i, pt in ipairs(list) do
            if i > maxRows then break end
            local ry = startY + (i - 1) * (rowH + sy(10))
            local rowW = lw - sx(40)
            local rx = lx + sx(20)
            local hover = inBox(cx, cy, rx, ry, rowW, rowH)
            local selected = (ui.storeSel == i)
            dxDrawRectangle(rx, ry, rowW, rowH, selected and C("accentS", fade) or (hover and C("panel2", fade) or C("dark", fade)))
            dxDrawRectangle(rx, ry, sy(5), rowH, selected and C("accent", fade) or C("line", fade))
            hit.storeRows[i] = { rx, ry, rowW, rowH, i, pt }

            local tw, th = sx(300), rowH - sy(16)
            local tx, ty = rx + sx(14), ry + sy(8)
            dxDrawRectangle(tx, ty, tw, th, C("panel", fade))
            local tex = bannerTex[pt.idx]
            if tex and isElement(tex) then
                dxDrawImage(tx, ty, tw, th, tex, 0, 0, 0, tocolor(255,255,255, math.floor(230 * fade)))
            else
                dxDrawText(tostring(pt.name or "SHOP"), tx, ty, tx + tw, ty + th, C("text", fade), fs(0.9), "default-bold", "center", "center", true)
            end

            local nx = tx + tw + sx(18)
            dxDrawText(tostring(pt.name or "SHOP"), nx, ry + sy(14), rx + rowW - sx(20), ry + sy(44),
                C("text", fade), fs(1.25), "default-bold", "left", "center", true)
            local info = (pt.zone or "LIBERTY CITY") .. "  •  " .. tostring(pt.type or "store"):upper()
            dxDrawText(info, nx, ry + sy(44), rx + rowW - sx(20), ry + sy(68),
                C("dim", fade), fs(0.95), "arial", "left", "center", true)
            dxDrawText("اضغط للفتح / Open (E near store)", nx, ry + sy(68), rx + rowW - sx(20), ry + sy(88),
                C("gold", fade), fs(0.9), "arial", "left", "center", true)
        end

        if #list == 0 then
            dxDrawText("NO SHOPS LOADED", lx, ly + lh / 2, lx + lw, ly + lh / 2 + sy(30),
                C("dim", fade), fs(1.1), "default-bold", "center", "center", true)
        end

        dxDrawRectangle(x, y + h - sy(30), w, sy(30), C("dark", fade))
        dxDrawText("STORE DIRECTORY  •  بنرات وأسماء المتاجر        /        اضغط STORES للعودة        /        ESC OR X TO CLOSE",
            x + sx(20), y + h - sy(30), x + w - sx(20), y + h,
            C("dim", fade), fs(0.88), "arial", "left", "center", true)
        return
    end

    -- category tabs (catalog view) ---------------------------------------
    hit.tabs = {}
    hit.storeRows = {}
    local tabY = y + sy(100)
    local tabW = sx(150)
    local tabGap = sx(8)
    for i, name in ipairs(TABS) do
        local tx = x + sx(24) + (i - 1) * (tabW + tabGap)
        local ty = tabY
        hit.tabs[i] = { tx, ty, tabW, sy(38), name }
        local active = (ui.cat == name)
        local hover = inBox(cx, cy, tx, ty, tabW, sy(38))
        dxDrawRectangle(tx, ty, tabW, sy(38),
            active and C("accent", fade) or (hover and C("panel2", fade) or C("dark", fade)))
        dxDrawRectangle(tx, ty + sy(36), tabW, sy(2), active and C("gold", fade) or C("line", fade))
        dxDrawText(name, tx, ty, tx + tabW, ty + sy(38),
            active and C("dark", fade) or C("text", fade), fs(0.95), "default-bold", "center", "center", true)
    end

    -- left item list -----------------------------------------------------
    local lx = x + sx(24)
    local ly = y + sy(150)
    local lw = sx(420)
    local lh = h - sy(185)
    drawPanel(lx, ly, lw, lh, "panel")

    local items = filtered()
    local rowH = sy(52)
    local maxRows = math.floor(lh / rowH)
    ui.scroll = math.max(0, math.min(ui.scroll, math.max(0, #items - maxRows)))

    hit.rows = {}
    for r = 1, maxRows do
        local idx = ui.scroll + r
        local it = items[idx]
        if not it then break end
        local ry = ly + (r - 1) * rowH
        local hover = inBox(cx, cy, lx, ry, lw, rowH)
        local selected = (idx == ui.sel)
        if selected then
            dxDrawRectangle(lx, ry, lw, rowH, C("accentS", fade))
            dxDrawRectangle(lx, ry, sy(4), rowH, C("accent", fade))
        elseif hover then
            dxDrawRectangle(lx, ry, lw, rowH, C("panel2", fade))
        end
        hit.rows[r] = { lx, ry, lw, rowH, idx }

        local icon = sx(38)
        dxDrawRectangle(lx + sx(10), ry + sy(7), icon, sy(38),
            tocolor(it.col[1], it.col[2], it.col[3], math.floor(220 * fade)))
        dxDrawText(it.icon, lx + sx(10), ry + sy(7), lx + sx(10) + icon, ry + sy(45),
            C("text", fade), fs(0.95), "default-bold", "center", "center", true)
        dxDrawText(it.name, lx + sx(60), ry + sy(5), lx + lw - sx(80), ry + sy(28),
            C("text", fade), fs(1.0), "default-bold", "left", "center", true)
        dxDrawText(it.cat .. "  //  " .. it.item:upper(), lx + sx(60), ry + sy(28), lx + lw - sx(80), ry + sy(48),
            C("dim", fade), fs(0.82), "arial", "left", "center", true)
        dxDrawText("$" .. it.price, lx + lw - sx(72), ry + sy(8), lx + lw - sx(10), ry + sy(44),
            C("green", fade), fs(1.0), "default-bold", "right", "center", true)
    end

    if #items == 0 then
        dxDrawText("NO ITEMS IN THIS CATEGORY", lx, ly + lh / 2, lx + lw, ly + lh / 2 + sy(30),
            C("dim", fade), fs(1.0), "default-bold", "center", "center", true)
    end

    -- right detail panel -------------------------------------------------
    local rx = x + sx(466)
    local rw = w - sx(490)
    drawPanel(rx, ly, rw, lh, "panel")

    local it = items[ui.sel] or items[1]
    if it then
        local ph = sy(230)
        dxDrawRectangle(rx + sx(14), ly + sy(14), rw - sx(28), ph, C("dark", fade))
        for i = 1, 7 do
            local bx = rx + sx(14) + i * sx(76)
            dxDrawRectangle(bx, ly + sy(14), sx(10), ph, C("accentS", fade * 0.55))
        end
        dxDrawRectangle(rx + sx(14), ly + sy(14) + ph - sy(4), rw - sx(28), sy(4), C("accent", fade))

        local big = sx(96)
        dxDrawRectangle(rx + (rw - big) / 2, ly + sy(52), big, big,
            tocolor(it.col[1], it.col[2], it.col[3], math.floor(235 * fade)))
        dxDrawRectangle(rx + (rw - big) / 2, ly + sy(52), big, sy(5), C("gold", fade))
        dxDrawText(it.icon, rx + (rw - big) / 2, ly + sy(52), rx + (rw - big) / 2 + big, ly + sy(52) + big,
            C("text", fade), fs(2.6), "default-bold", "center", "center", true)

        dxDrawText(it.name, rx + sx(24), ly + sy(200), rx + rw - sx(24), ly + sy(240),
            C("text", fade), fs(1.45), "default-bold", "center", "center", true)

        dxDrawText(it.desc, rx + sx(30), ly + sy(276), rx + rw - sx(30), ly + sy(350),
            C("dim", fade), fs(1.0), "arial", "left", "top", true, true)

        dxDrawRectangle(rx + sx(24), ly + sy(366), rw - sx(48), sy(2), C("line", fade))
        dxDrawText("CATEGORY", rx + sx(30), ly + sy(382), rx + sx(220), ly + sy(406),
            C("dim", fade), fs(0.9), "arial", "left", "center", true)
        dxDrawText(it.cat, rx + sx(180), ly + sy(382), rx + rw - sx(30), ly + sy(406),
            C("accent", fade), fs(1.0), "default-bold", "right", "center", true)

        dxDrawText("PRICE", rx + sx(30), ly + sy(416), rx + sx(220), ly + sy(440),
            C("dim", fade), fs(0.9), "arial", "left", "center", true)
        dxDrawText("$" .. money(it.price), rx + sx(180), ly + sy(410), rx + rw - sx(30), ly + sy(452),
            C("green", fade), fs(1.6), "default-bold", "right", "center", true)

        local bh = sy(62)
        local by = ly + lh - bh - sy(22)
        hit.buy = { rx + sx(24), by, rw - sx(48), bh }
        local bhover = inBox(cx, cy, hit.buy[1], hit.buy[2], hit.buy[3], hit.buy[4])
        local canAfford = (tonumber(cash) or 0) >= it.price
        dxDrawRectangle(hit.buy[1], hit.buy[2], hit.buy[3], hit.buy[4],
            not canAfford and C("panel2", fade) or (bhover and C("green", fade) or C("accent", fade)))
        dxDrawRectangle(hit.buy[1], hit.buy[2], sy(5), hit.buy[4], C("gold", fade))
        dxDrawText(not canAfford and "INSUFFICIENT FUNDS" or "PURCHASE  //  اشتري",
            hit.buy[1], hit.buy[2], hit.buy[1] + hit.buy[3], hit.buy[2] + hit.buy[4],
            C("dark", fade), fs(1.15), "default-bold", "center", "center", true)
    end

    dxDrawRectangle(x, y + h - sy(30), w, sy(30), C("dark", fade))
    dxDrawText("CLICK ITEM  •  SELECT  •  PURCHASE        /        STORES = قائمة المتاجر        /        ESC OR X TO CLOSE",
        x + sx(20), y + h - sy(30), x + w - sx(20), y + h,
        C("dim", fade), fs(0.88), "arial", "left", "center", true)

    if ui.toast then
        if ui.toast.until_ < now then
            ui.toast = nil
        else
            local tw = sx(520)
            local tx = (SW - tw) / 2
            local ty = y + h + sy(16)
            dxDrawRectangle(tx, ty, tw, sy(52), C("dark"))
            dxDrawRectangle(tx, ty, sy(5), sy(52), ui.toast.ok and C("green") or C("red"))
            dxDrawText(ui.toast.text, tx + sx(20), ty, tx + tw - sx(20), ty + sy(52),
                ui.toast.ok and C("green") or C("red"), fs(1.05), "default-bold", "left", "center", true)
        end
    end
end
local function drawPrompt()
    if ui.open or not ui.points or #ui.points == 0 then return end
    local px, py, pz = getElementPosition(localPlayer)
    local best, bestD = nil, 4.0
    for _, pt in ipairs(ui.points) do
        local d = getDistanceBetweenPoints3D(px, py, pz, pt.px, pt.py, pt.pz)
        if d < bestD then best, bestD = pt, d end
    end
    ui.near = best

    if not best then return end

    local w, h = sx(430), sy(70)
    local x, y = (SW - w) / 2, SH - sy(150)
    dxDrawRectangle(x, y, w, h, C("dark"))
    dxDrawRectangle(x, y, w, sy(4), C("accent"))
    dxDrawRectangle(x + sx(14), y + sy(16), sx(38), sy(38), C("accent"))
    dxDrawText("E", x + sx(14), y + sy(16), x + sx(52), y + sy(54),
        C("dark"), fs(1.2), "default-bold", "center", "center", true)
    dxDrawText("OPEN " .. best.name, x + sx(64), y + sy(12), x + w - sx(16), y + sy(38),
        C("text"), fs(1.05), "default-bold", "left", "center", true)
    dxDrawText("اضغط E لفتح المتجر", x + sx(64), y + sy(38), x + w - sx(16), y + sy(62),
        C("dim"), fs(0.95), "arial", "left", "center", true)
end

addEventHandler("onClientRender", root, function()
    if ui.open then drawUI() else drawPrompt() end
end, true, "high-100")

addEventHandler("onClientClick", root, function(button, state)
    if button ~= "left" or state ~= "down" or not ui.open then return end
    local cx, cy = cursorPos()

    if hit.close and inBox(cx, cy, hit.close[1], hit.close[2], hit.close[3], hit.close[4]) then
        closeUI()
        return
    end

    if hit.storesBtn and inBox(cx, cy, hit.storesBtn[1], hit.storesBtn[2], hit.storesBtn[3], hit.storesBtn[4]) then
        ui.view = (ui.view == "stores") and "catalog" or "stores"
        return
    end

    if ui.view == "stores" then
        for _, r in ipairs(hit.storeRows or {}) do
            if inBox(cx, cy, r[1], r[2], r[3], r[4]) then
                ui.storeSel = r[5]
                local pt = r[6]
                if pt and ui.near and ui.near.idx == pt.idx then
                    triggerServerEvent("ngsh:interact", localPlayer, pt.idx)
                elseif pt then
                    ui.toast = { text = "اذهب إلى " .. tostring(pt.name) .. " واضغط E للفتح / Go to this store and press E", ok = true, until_ = getTickCount() + 3200 }
                end
                return
            end
        end
        return
    end

    for _, t in ipairs(hit.tabs) do
        if inBox(cx, cy, t[1], t[2], t[3], t[4]) then
            ui.cat = t[5]
            ui.sel = 1
            ui.scroll = 0
            return
        end
    end

    for _, r in ipairs(hit.rows) do
        if inBox(cx, cy, r[1], r[2], r[3], r[4]) then
            ui.sel = r[5]
            return
        end
    end

    if hit.buy and inBox(cx, cy, hit.buy[1], hit.buy[2], hit.buy[3], hit.buy[4]) then
        local items = filtered()
        local it = items[ui.sel]
        if it and ui.payload then
            triggerServerEvent("ngsh:buy", localPlayer, ui.payload.idx, it.item)
        end
    end
end, true, "high-100")

addEventHandler("onClientMouseWheel", root, function(direction)
    if not ui.open then return end
    ui.scroll = math.max(0, ui.scroll - (direction > 0 and 1 or -1))
end, true, "high-100")

bindKey("e", "down", function()
    if ui.open then return end
    if ui.near then
        triggerServerEvent("ngsh:interact", localPlayer, ui.near.idx)
    end
end)
