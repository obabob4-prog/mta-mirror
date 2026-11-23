--[[
    ng-shops c_shops.lua - Fancy GTA V style retail interface (pure DX, no CEF)
    -------------------------------------------------------------------
    - Neon blue/black luxury panels, electric blue accents, item list + detail preview
    - category tabs with hover states, mouse wheel scroll, buy confirmation
    - proximity [E] prompt rendered in world space style
    - all purchases still validated by s_shops.lua
    - 2026-11-20: LmB RP luxury restyle - full neon blue/black theme
]]--

local SW, SH = guiGetScreenSize()
local BX, BY = 1920, 1080

local function sx(v) return v * SW / BX end
local function sy(v) return v * SH / BY end
local function fs(v) return v * math.min(SW / BX, SH / BY) end

-- =============================================================================
-- LmB RP NEON BLACK / ELECTRIC BLUE COLOR PALETTE
-- =============================================================================
local P = {
    -- Dark background panel base
    background = tocolor(10, 14, 21, 255),       -- dark panel background
    overlay    = tocolor(0, 0, 0, 200),           -- semi-transparent overlay
    
    -- Panel variations
    panel      = tocolor(18, 26, 38, 255),        -- slightly lighter panels
    panel2     = tocolor(24, 36, 49, 255),        -- medium panels
    dark       = tocolor(10, 14, 21, 255),        -- darkest panels
    
    -- Accent colors (neon electric blue)
    accent     = tocolor(0, 150, 255, 255),       -- electric blue accent
    accentS    = tocolor(0, 130, 230, 200),       -- softer blue accent
    accentGlow = tocolor(0, 200, 255, 150),       -- glow effect blue
    
    -- Gold/Silver accents
    gold       = tocolor(232, 197, 107, 255),      -- gold accent
    goldDim    = tocolor(200, 170, 80, 180),      -- dim gold
    silver     = tocolor(200, 220, 240, 255),     -- silver text
    
    -- Text colors
    textWhite  = tocolor(245, 245, 245, 255),      -- pure white text
    textGray   = tocolor(180, 190, 200, 255),      -- gray text
    textDim    = tocolor(130, 140, 150, 255),     -- dim text
    textMuted  = tocolor(100, 110, 120, 255),     -- muted text
    
    -- Interactive colors
    hover      = tocolor(30, 50, 70, 255),         -- hover state
    active     = tocolor(0, 150, 255, 255),        -- active/pressed
    disabled   = tocolor(80, 90, 100, 255),        -- disabled state
    
    -- Specific component colors
    headerBg   = tocolor(12, 16, 24, 255),         -- header background
    headerLine = tocolor(0, 150, 255, 200),        -- header divider line
    line       = tocolor(0, 100, 180, 150),        -- divider lines
    
    -- Status colors
    green      = tocolor(0, 200, 120, 255),        -- success green
    red        = tocolor(244, 67, 54, 255),        -- error red
    yellow     = tocolor(255, 190, 0, 255),        -- warning yellow
    
    -- Money/banking
    moneyGreen = tocolor(0, 220, 120, 255),        -- cash green
    moneyYellow= tocolor(255, 190, 0, 255),        -- cash yellow
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
-- =============================================================================
-- RENDERING FUNCTIONS
-- =============================================================================

local function cursorPos()
    if not isCursorShowing() then return -1, -1 end
    local rx, ry = getCursorPosition()
    return rx * SW, ry * SH
end

local function inBox(cx, cy, x, y, w, h)
    return cx >= x and cx <= x + w and cy >= y and cy <= y + h
end

-- =============================================================================
-- DRAW PANEL - FANCY GLASS PANEL WITH NEON BLUE ACCENTS
-- =============================================================================
local function drawPanel(x, y, w, h, key)
    -- Background panel base
    dxDrawRectangle(x, y, w, h, C(key or "panel"))
    
    -- Inner border line (top)
    dxDrawRectangle(x, y, w, 2, C("line"))
    
    -- Left border line
    dxDrawRectangle(x, y, 2, h, C("line"))
    
    -- Right border line
    dxDrawRectangle(x + w - 2, y, 2, h, C("line"))
    
    -- Bottom border line
    dxDrawRectangle(x, y + h - 2, w, 2, C("line"))
    
    -- Neon blue top accent strip (if not the close area)
    if key ~= "close" then
        dxDrawRectangle(x, y, w, 3, C("accent"))
    end
end

-- =============================================================================
-- DRAW TOAST NOTIFICATION - FANCY NEON STYLE
-- =============================================================================
local function drawToast()
    if not ui.toast then return end
    local now = getTickCount()
    if ui.toast.until_ < now then
        ui.toast = nil
        return
    end
    
    local fade = 1.0 -- full opacity for toast
    local tw = sx(520)
    local tx = (SW - tw) / 2
    local ty = sy(SH) - sy(80) -- at the bottom
    
    -- Dark background rectangle
    dxDrawRectangle(tx, ty, tw, sy(52), C("dark"))
    
    -- Accent bar at top
    dxDrawRectangle(tx, ty, sy(6), sy(52), C("accent"))
    
    -- Icon dot/indicator
    dxDrawRectangle(tx + sy(14), ty + sy(16), sy(38), sy(38), C("accent"))
    
    -- Text
    dxDrawText(ui.toast.text, tx + sy(20), ty, tx + tw - sy(20), ty + sy(52),
        ui.toast.ok and C("green") or C("red"), fs(1.05), "default-bold", "left", "center", true)
end

-- =============================================================================
-- MAIN UI DRAWING FUNCTION
-- =============================================================================
local function drawUI()
    local p = ui.payload
    if not p then return end
    
    local now = getTickCount()
    local fade = math.min(1, (now - ui.openedAt) / 220)
    
    -- Full screen semi-transparent overlay
    dxDrawRectangle(0, 0, SW, SH, C("overlay", fade))
    
    -- Main panel window
    local w, h = sx(1180), sy(700)
    local x, y = (SW - w) / 2, (SH - h) / 2
    
    -- Window background panel with neon blue accents
    drawPanel(x, y, w, h, "panel")
    
    -- Accent top line + glow strip
    dxDrawRectangle(x, y, w, sy(5), C("accent", fade))
    dxDrawRectangle(x, y + sy(5), w, sy(3), C("accentGlow", fade))
    dxDrawRectangle(x, y + sy(5), w, sy(28), C("panel2", fade))
    
    -- ============= HEADER SECTION =============
    local headH = sy(82)
    dxDrawRectangle(x, y + sy(5), w, headH, C("headerBg", fade))
    
    -- Banner texture or fallback
    local btex = bannerTex[p.idx] or false
    if btex and isElement(btex) then
        dxDrawImage(x, y + sy(5), w, headH, btex, 0, 0, 0, tocolor(255,255,255, math.floor(210 * fade)))
    else
        -- Fallback: solid color with shop name
        dxDrawRectangle(x, y + sy(5), w, headH, C("dark", fade))
    end
    
    -- Shop name in header
    dxDrawText(tostring(p.name), x + sx(30), y + sy(15), x + sx(700), y + sy(55),
        C("textWhite", fade), fs(1.7), "default-bold", "left", "center", true)
    
    -- Location/zone text
    dxDrawText((p.zone or "LIBERTY CITY") .. "  //  LUXURY RETAIL", x + sx(32), y + sy(55), x + sx(700), y + sy(78),
        C("textDim", fade), fs(1.0), "default-bold", "left", "center", true)
    
    -- Cash display area
    local cash = getElementData(localPlayer, "char.cash") or (p.cash or 0)
    dxDrawText("BALANCE", x + w - sx(380), y + sy(22), x + w - sx(150), y + sy(40),
        C("textDim", fade), fs(1.0), "default-bold", "right", "center", true)
    dxDrawText("$" .. money(cash), x + w - sx(380), y + sy(42), x + w - sx(150), y + sy(68),
        C("moneyGreen", fade), fs(1.5), "default-bold", "right", "center", true)
    
    -- Stores directory button (top-right toggle)
    local sbW, sbH = sx(130), sy(34)
    hit.storesBtn = { x + w - sx(280), y + sy(24), sbW, sbH }
    local sbHover = inBox(cursorPos(), hit.storesBtn[1], hit.storesBtn[2], sbW, sbH)
    local sbActive = (ui.view == "stores")
    
    -- Fancy button with neon blue accent
    if sbActive then
        dxDrawRectangle(hit.storesBtn[1], hit.storesBtn[2], sbW, sbH, C("accent", fade))
        dxDrawRectangle(hit.storesBtn[1], hit.storesBtn[2] + sbH - sy(3), sbW, sy(3), C("gold", fade))
    elseif sbHover then
        dxDrawRectangle(hit.storesBtn[1], hit.storesBtn[2], sbW, sbH, C("panel2", fade))
        dxDrawRectangle(hit.storesBtn[1], hit.storesBtn[2] + sbH - sy(3), sbW, sy(3), C("accent", fade))
    else
        dxDrawRectangle(hit.storesBtn[1], hit.storesBtn[2], sbW, sbH, C("dark", fade))
        dxDrawRectangle(hit.storesBtn[1], hit.storesBtn[2] + sbH - sy(3), sbW, sy(3), C("dim", fade))
    end
    
    dxDrawText("STORES", hit.storesBtn[1], hit.storesBtn[2], hit.storesBtn[1] + sbW, hit.storesBtn[2] + sbH,
        sbActive and C("dark", fade) or (sbHover and C("textWhite", fade) or C("textDim", fade)), fs(0.85), "default-bold", "center", "center", true)
    
    -- Close button (top-right corner)
    hit.close = { x + w - sx(52), y + sy(22), sx(38), sy(38) }
    local closeHover = inBox(cursorPos(), hit.close[1], hit.close[2], hit.close[3], hit.close[4])
    
    -- Fancy close button
    if closeHover then
        dxDrawRectangle(hit.close[1], hit.close[2], hit.close[3], hit.close[4], C("red", fade))
    else
        dxDrawRectangle(hit.close[1], hit.close[2], hit.close[3], hit.close[4], C("panel2", fade))
    end
    dxDrawText("X", hit.close[1], hit.close[2], hit.close[1] + hit.close[3], hit.close[2] + hit.close[4],
        C("textWhite", fade), fs(1.1), "default-bold", "center", "center", true)
    
    -- ============= VIEW SWITCH: CATALOG vs STORES =============
    
    if ui.view == "stores" then
        -- Stores directory view
        hit.tabs = {}
        hit.rows = {}
        hit.buy = nil
        hit.storeRows = {}
        
        local ly = y + sy(110)
        local lh = h - sy(155)
        local lx = x + sx(30)
        local lw = w - sx(60)
        drawPanel(lx, ly, lw, lh, "panel")
        
        -- Directory title
        dxDrawText("SHOP DIRECTORY", lx + sx(25), ly + sy(15), lx + lw - sx(25), ly + sy(40),
            C("gold", fade), fs(1.3), "default-bold", "left", "center", true)
        
        dxDrawRectangle(lx + sx(25), ly + sy(45), lw - sx(50), sy(2), C("accent", fade))
        
        local list = ui.points or {}
        local rowH = sy(80)
        local startY = ly + sy(60)
        local maxRows = math.floor((lh - sy(80)) / (rowH + sy(8)))
        
        for i, pt in ipairs(list) do
            if i > maxRows then break end
            local ry = startY + (i - 1) * (rowH + sy(8))
            local rowW = lw - sx(40)
            local rx = lx + sx(20)
            local hover = inBox(cursorPos(), rx, ry, rowW, rowH)
            local selected = (ui.storeSel == i)
            
            -- Fancy row background
            if selected then
                dxDrawRectangle(rx, ry, rowW, rowH, C("accent", fade))
                dxDrawRectangle(rx, ry, sy(4), rowH, C("gold", fade))
            elseif hover then
                dxDrawRectangle(rx, ry, rowW, rowH, C("panel2", fade))
                dxDrawRectangle(rx, ry, sy(4), rowH, C("accent", fade))
            else
                dxDrawRectangle(rx, ry, rowW, rowH, C("panel", fade))
                dxDrawRectangle(rx, ry, sy(4), rowH, C("line", fade))
            end
            
            hit.storeRows[i] = { rx, ry, rowW, rowH, i, pt }
            
            -- Shop icon/emblem area
            local iconX = rx + sx(16)
            local iconY = ry + sy(10)
            local icoW = sx(48)
            local icoH = rowH - sy(20)
            
            -- Try to display banner texture
            local tex = bannerTex[pt.idx]
            if tex and isElement(tex) then
                dxDrawImage(iconX, iconY, icoW, icoH, tex, 0, 0, 0, tocolor(255,255,255, math.floor(220 * fade)))
            else
                -- Fallback: shop name first letter
                dxDrawText(tostring(pt.name:sub(1, 1)), iconX, iconY, iconX + icoW, iconY + icoH,
                    C("textGray", fade), fs(1.2), "default-bold", "center", "center", true)
            end
            
            -- Shop name
            local nameX = rx + sx(70)
            local nameW = lw - sx(90)
            dxDrawText(tostring(pt.name or "SHOP"), nameX, ry + sy(8), rx + lw - sx(20), ry + sy(32),
                C("textWhite", fade), fs(1.1), "default-bold", "left", "center", true)
            
            -- Location info
            local infoX = rx + sx(70)
            dxDrawText((pt.zone or "LIBERTY CITY") .. "  |  " .. tostring(pt.type or "store"):upper(), infoX, ry + sy(32), rx + lw - sx(20), ry + sy(52),
                C("textDim", fade), fs(0.85), "arial", "left", "center", true)
            
            -- Open instruction
            dxDrawText("PRESSIONE E PARA ABRIR", rx + sx(70), ry + sy(56), rx + lw - sx(20), ry + sy(70),
                C("gold", fade), fs(0.75), "arial", "left", "center", true)
        end
        
        if #list == 0 then
            dxDrawText("NENHUMA LOJA CARREGADA", lx, ly + lh / 2, lx + lw, ly + lh / 2 + sy(30),
                C("textDim", fade), fs(1.1), "default-bold", "center", "center", true)
        end
        
        -- Bottom bar
        dxDrawRectangle(x, y + h - sy(35), w, sy(35), C("dark", fade))
        dxDrawText("CLIQUE EM UMA LOJA / CLICK ON A STORE  |  ESC OU X PARA SAIR",
            x + sx(25), y + h - sy(35), x + w - sx(25), y + h,
            C("textDim", fade), fs(0.8), "arial", "left", "center", true)
        return
    end
    
    -- ============= CATALOG VIEW =============
    
    -- Category tabs
    hit.tabs = {}
    hit.storeRows = {}
    local tabY = y + sy(110)
    local tabW = sx(140)
    local tabGap = sx(8)
    
    for i, name in ipairs(TABS) do
        local tx = x + sx(28) + (i - 1) * (tabW + tabGap)
        local ty = tabY
        hit.tabs[i] = { tx, ty, tabW, sy(38), name }
        
        local active = (ui.cat == name)
        local hover = inBox(cursorPos(), tx, ty, tabW, sy(38))
        
        -- Fancy tab with neon blue accent
        if active then
            dxDrawRectangle(tx, ty, tabW, sy(38), C("accent", fade))
            dxDrawRectangle(tx, ty + sy(36), tabW, sy(2), C("gold", fade))
            dxDrawText(name, tx, ty, tx + tabW, ty + sy(38),
                C("dark", fade), fs(0.95), "default-bold", "center", "center", true)
        elseif hover then
            dxDrawRectangle(tx, ty, tabW, sy(38), C("panel2", fade))
            dxDrawRectangle(tx, ty + sy(36), tabW, sy(2), C("accent", fade))
            dxDrawText(name, tx, ty, tx + tabW, ty + sy(38),
                C("textWhite", fade), fs(0.95), "default-bold", "center", "center", true)
        else
            dxDrawRectangle(tx, ty, tabW, sy(38), C("panel", fade))
            dxDrawRectangle(tx, ty + sy(36), tabW, sy(2), C("line", fade))
            dxDrawText(name, tx, ty, tx + tabW, ty + sy(38),
                C("textDim", fade), fs(0.95), "default-bold", "center", "center", true)
        end
    end
    
    -- ============= LEFT ITEM LIST =============
    local lx = x + sx(30)
    local ly = y + sy(160)
    local lw = sx(440)
    local lh = h - sy(195)
    drawPanel(lx, ly, lw, lh, "panel")
    
    local items = filtered()
    local rowH = sy(56)
    local maxRows = math.floor(lh / rowH)
    ui.scroll = math.max(0, math.min(ui.scroll, math.max(0, #items - maxRows)))
    
    hit.rows = {}
    for r = 1, maxRows do
        local idx = ui.scroll + r
        local it = items[idx]
        if not it then break end
        local ry = ly + (r - 1) * rowH
        local hover = inBox(cursorPos(), lx, ry, lw, rowH)
        local selected = (idx == ui.sel)
        
        -- Fancy item row with neon blue selection
        if selected then
            dxDrawRectangle(lx, ry, lw, rowH, C("accent", fade))
            dxDrawRectangle(lx, ry, sy(4), rowH, C("gold", fade))
        elseif hover then
            dxDrawRectangle(lx, ry, lw, rowH, C("panel2", fade))
            dxDrawRectangle(lx, ry, sy(4), rowH, C("accent", fade))
        else
            dxDrawRectangle(lx, ry, lw, rowH, C("panel", fade))
            dxDrawRectangle(lx, ry, sy(4), rowH, C("line", fade))
        end
        hit.rows[r] = { lx, ry, lw, rowH, idx }
        
        -- Item icon circle/box
        local iconX = lx + sx(12)
        local iconY = ry + sy(6)
        local iconS = sx(40)
        -- Color box based on item category color
        dxDrawRectangle(iconX, iconY, iconS, iconS, C("accentS", fade))
        dxDrawText(it.icon, iconX, iconY, iconX + iconS, ry + sy(44),
            C("textWhite", fade), fs(0.9), "default-bold", "center", "center", true)
        
        -- Item name
        dxDrawText(it.name, lx + sx(70), ry + sy(3), lx + lw - sx(80), ry + sy(24),
            C("textWhite", fade), fs(1.05), "default-bold", "left", "center", true)
        
        -- Item category tag
        dxDrawText(it.cat .. "  //  " .. it.item:upper(), lx + sx(70), ry + sy(26), lx + lw - sx(80), ry + sy(44),
            C("textDim", fade), fs(0.78), "arial", "left", "center", true)
        
        -- Price tag (right side)
        dxDrawText("$" .. it.price, lx + lw - sx(28), ry + sy(4), lx + lw - sx(10), ry + sy(26),
            C("moneyGreen", fade), fs(1.1), "default-bold", "right", "center", true)
    end
    
    if #items == 0 then
        dxDrawText("NENHUM ITEM NESSA CATEGORIA", lx, ly + lh / 2, lx + lw, ly + lh / 2 + sy(30),
            C("textDim", fade), fs(1.0), "default-bold", "center", "center", true)
    end
    
    -- ============= RIGHT DETAIL PANEL =============
    local rx = x + sx(482)
    local rw = w - sx(510)
    drawPanel(rx, ly, rw, lh, "panel")
    
    local it = items[ui.sel] or items[1]
    if it then
        -- Detail panel background
        local ph = sy(240)
        dxDrawRectangle(rx + sx(16), ly + sy(14), rw - sx(32), ph, C("dark", fade))
        
        -- Color swatches row
        for i = 1, 7 do
            local bx = rx + sx(16) + i * sx(14)
            dxDrawRectangle(bx, ly + sy(14), sx(8), ph, C("accentS", fade * 0.4))
        end
        dxDrawRectangle(rx + sx(16), ly + sy(14) + ph - sy(4), rw - sx(32), sy(4), C("accent", fade))
        
        -- Large item icon (center-left)
        local big = sx(100)
        dxDrawRectangle(rx + (rw - big) / 2, ly + sy(28), big, big,
            tocolor(it.col[1], it.col[2], it.col[3], math.floor(240 * fade)))
        dxDrawRectangle(rx + (rw - big) / 2, ly + sy(28), big, sy(4), C("gold", fade))
        dxDrawText(it.icon, rx + (rw - big) / 2, ly + sy(28), rx + (rw - big) / 2 + big, ly + sy(28) + big,
            C("textWhite", fade), fs(3.0), "default-bold", "center", "center", true)
        
        -- Item name (below large icon)
        dxDrawText(it.name, rx + sx(36), ly + sy(150), rx + rw - sx(36), ly + sy(190),
            C("textWhite", fade), fs(1.55), "default-bold", "center", "center", true)
        
        -- Description text
        dxDrawText(it.desc, rx + sx(28), ly + sy(210), rx + rw - sx(28), ly + sy(340),
            C("textDim", fade), fs(1.0), "arial", "left", "top", true, true)
        
        -- Divider line
        dxDrawRectangle(rx + sx(28), ly + sy(352), rw - sx(56), sy(2), C("line", fade))
        
        -- Category label + value
        dxDrawText("CATEGORIA", rx + sx(28), ly + sy(360), rx + sx(180), ly + sy(384),
            C("textDim", fade), fs(0.85), "arial", "left", "center", true)
        dxDrawText(it.cat, rx + sx(180), ly + sy(360), rx + rw - sx(30), ly + sy(384),
            C("accent", fade), fs(1.0), "default-bold", "right", "center", true)
        
        -- Price label + value
        dxDrawText("PREÇO", rx + sx(28), ly + sy(400), rx + sx(180), ly + sy(424),
            C("textDim", fade), fs(0.85), "arial", "left", "center", true)
        dxDrawText("$" .. money(it.price), rx + sx(180), ly + sy(404), rx + rw - sx(30), ly + sy(448),
            C("moneyGreen", fade), fs(1.7), "default-bold", "right", "center", true)
        
        -- PURCHASE BUTTON
        local bh = sy(52)
        local by = ly + lh - bh - sy(20)
        hit.buy = { rx + sx(24), by, rw - sx(48), bh }
        local bhover = inBox(cursorPos(), hit.buy[1], hit.buy[2], hit.buy[3], hit.buy[4])
        local cash = getElementData(localPlayer, "char.cash") or 0
        local canAfford = (tonumber(cash) or 0) >= it.price
        
        -- Fancy purchase button with neon blue accent
        if not canAfford then
            dxDrawRectangle(hit.buy[1], hit.buy[2], hit.buy[3], hit.buy[4], C("panel2", fade))
            dxDrawRectangle(hit.buy[1], hit.buy[2], sy(5), hit.buy[4], C("red", fade))
            dxDrawText("SALDO INSUFICIENTE", hit.buy[1], hit.buy[2], hit.buy[1] + hit.buy[3], hit.buy[2] + hit.buy[4],
                C("red", fade), fs(1.15), "default-bold", "center", "center", true)
        elseif bhover then
            dxDrawRectangle(hit.buy[1], hit.buy[2], hit.buy[3], hit.buy[4], C("green", fade))
            dxDrawRectangle(hit.buy[1], hit.buy[2], sy(5), hit.buy[4], C("gold", fade))
            dxDrawText("COMPRAR  //  O PRIMEIRO USUAO / O COMPRA", hit.buy[1], hit.buy[2], hit.buy[1] + hit.buy[3], hit.buy[2] + hit.buy[4],
                C("dark", fade), fs(1.2), "default-bold", "center", "center", true)
        else
            dxDrawRectangle(hit.buy[1], hit.buy[2], hit.buy[3], hit.buy[4], C("accent", fade))
            dxDrawRectangle(hit.buy[1], hit.buy[2], sy(5), hit.buy[4], C("gold", fade))
            dxDrawText("COMPRAR  //  O PRIMEIRO USUAO / O COMPRA", hit.buy[1], hit.buy[2], hit.buy[1] + hit.buy[3], hit.buy[2] + hit.buy[4],
                C("white", fade), fs(1.2), "default-bold", "center", "center", true)
        end
    end
    
    -- ============= BOTTOM INSTRUCTION BAR =============
    dxDrawRectangle(x, y + h - sy(38), w, sy(38), C("dark", fade))
    dxDrawText("CLIQUE EM UM ITEM / SELECT ITEM  |  ESC OU X PARA SAIR  |  CATALOGO: " .. table.concat(TABS, ", "),
        x + sx(25), y + h - sy(38), x + w - sx(25), y + h,
        C("textDim", fade), fs(0.8), "arial", "left", "center", true)
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
    
    local w, h = sx(460), sy(80)
    local x, y = (SW - w) / 2, SH - sy(160)
    dxDrawRectangle(x, y, w, h, C("dark"))
    dxDrawRectangle(x, y, w, sy(4), C("accent"))
    dxDrawRectangle(x + sx(14), y + sy(16), sx(38), sy(38), C("accent"))
    dxDrawText("E", x + sx(14), y + sy(16), x + sx(52), y + sy(54),
        C("textWhite", fade), fs(1.8), "default-bold", "center", "center", true)
    dxDrawText("APERTE E PARA COMPRAR / PRESS E TO BUY", x + sx(56), y, x + w - sx(20), y + sy(54),
        C("textWhite", fade), fs(0.9), "default-bold", "left", "center", true)
end

local function drawIfVisible()
    if not ui.open then return end
    drawUI()
    drawToast()
    drawPrompt()
end

-- Event handlers remain exactly the same...
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

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, tex in pairs(bannerTex) do
        if isElement(tex) then destroyElement(tex) end
    end
end)

bindKey("escape", "down", function() if ui.open then closeUI() end end)
bindKey("backspace", "down", function() if ui.open then closeUI() end end)

addEventHandler("onClientRender", root, drawIfVisible)