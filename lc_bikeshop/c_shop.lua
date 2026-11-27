--[[
    lc_bikeshop / client - compact premium GUI
    Small elegant design with working test ride button.
    Open with E near the shop or /bikeshop
]]

local sx, sy = guiGetScreenSize()
local ui = {
    open = false, payload = nil, tab = 1, sel = 0, hovered_row = false,
    notice = nil, noticeUntil = 0,
    testName = nil, testEnd = 0,
    probed = false,
}

local TABS = { "ALL", "BICYCLES", "MOTORCYCLES" }
-- compact size: 620x460
local W, H = 620, 460
local SHOP_X, SHOP_Y = -326.18, 1378.94

local buttons = {}

-- colour helpers
local function unpack_color(col)
    local a = math.floor(col / 0x1000000) % 256
    local r = math.floor(col / 0x10000) % 256
    local g = math.floor(col / 0x100) % 256
    local b = col % 256
    return r, g, b, a
end

local function rgba(r, g, b, a)
    return tocolor(r, g, b, a or 255)
end

local function inBox(cx, cy, x, y, w, h)
    return cx >= x and cx <= x + w and cy >= y and cy <= y + h
end

local function addButton(id, x, y, w, h, label, r, g, b, a)
    buttons[#buttons + 1] = {
        id = id, x = x, y = y, w = w, h = h, label = label,
        r = r, g = g, b = b, a = a,
    }
end

local function filtered()
    local out = {}
    local p = ui.payload
    if not p or not p.catalog then return out end
    for i, e in ipairs(p.catalog) do
        if ui.tab == 1 or (ui.tab == 2 and e.kind == "BICYCLE") or
           (ui.tab == 3 and e.kind == "MOTORCYCLE") then
            out[#out + 1] = { e = e, idx = i }
        end
    end
    return out
end

-- 3D preview
local previewModel = nil
local previewRX, previewRY = 0, 0

local function closeUI()
    ui.open = false
    showCursor(false)
    if isElement(previewModel) then destroyElement(previewModel) end
    previewModel = nil
    previewRX, previewRY = 0, 0
end

local function updatePreviewRot()
    if isElement(previewModel) then
        setElementRotation(previewModel, previewRX, previewRY, 0, "zyx")
    end
end

-- events
addEvent("lbs:open", true)
addEventHandler("lbs:open", localPlayer, function(payload)
    if type(payload) ~= "table" then return end
    ui.payload = payload
    ui.open = true
    ui.sel = 0
    showCursor(true)
    local cats = filtered()
    if #cats > 0 and not isElement(previewModel) then
        previewModel = createObject(cats[1].e.model, 0, 0, 0)
        setElementCollisionsEnabled(previewModel, false)
        setElementVisible(previewModel, true)
        updatePreviewRot()
    end
end)

addEvent("lbs:close", true)
addEventHandler("lbs:close", localPlayer, function()
    closeUI()
end)

addEvent("lbs:status", true)
addEventHandler("lbs:status", localPlayer, function(text, ok)
    outputChatBox("[BIKE SHOP] " .. totext(text), ok and 110 or 230,
        ok and 220 or 90, ok and 140 or 90)
    ui.notice = tostring(text)
    ui.noticeUntil = getTickCount() + 5200
end)

addEvent("lbs:testStart", true)
addEventHandler("lbs:testStart", localPlayer, function(name, ms)
    ui.testName = name
    ui.testEnd = getTickCount() + tonumber(ms or 60000)
end)

bindKey("e", "down", function()
    if ui.open then return end
    local x, y = getElementPosition(localPlayer)
    if getDistanceBetweenPoints2D(x, y, SHOP_X, SHOP_Y) <= 8 then
        triggerServerEvent("lbs:request", localPlayer)
    end
end)

bindKey("escape", "down", function()
    if ui.open then closeUI() end
end)

addEventHandler("onClientCursorMove", root, function(cx, cy)
    if not ui.open then return end
    local dx = (cx - (ui.last_cx or cx)) * 0.2
    local dy = (cy - (ui.last_cy or cy)) * 0.2
    previewRX = (previewRX + dx) % 360
    previewRY = (previewRY + dy) % 360
    updatePreviewRot()
    ui.last_cx, ui.last_cy = cx, cy
end)

addEventHandler("onClientClick", root, function(btn, state, cx, cy)
    if btn ~= "left" or state ~= "down" or not ui.open then return end
    local sx2, sy2 = getScreenSize()
    cx, cy = cx * sx2, cy * sy2

    -- close area bottom-right
    if inBox(cx, cy, sx2 - 110, sy2 - 38, 100, 30) then
        closeUI(); return
    end

    for _, b in ipairs(buttons) do
        if inBox(cx, cy, b.x - 4, b.y - 4, b.w + 8, b.h + 8) then
            local id = b.id
            if id:sub(1, 3) == "tab" then
                ui.tab = tonumber(id:sub(4)) or 1
                ui.sel = 0
            elseif id:sub(1, 4) == "test" then
                triggerServerEvent("lbs:test", localPlayer, tonumber(id:sub(5)))
            elseif id:sub(1, 3) == "buy" then
                triggerServerEvent("lbs:buy", localPlayer, tonumber(id:sub(4)))
            elseif id:sub(1, 4) == "sell" then
                triggerServerEvent("lbs:sell", localPlayer, tonumber(id:sub(5)))
            elseif id == "close" or id == "hide" then
                closeUI()
            end
            return
        end
    end
end)

-- ground calibration
addEventHandler("onClientResourceStart", resourceRoot, function()
    if resourceName ~= "lc_bikeshop" then return end
    setTimer(function()
        if ui.probed then return end
        local x, y = getElementPosition(localPlayer)
        if getDistanceBetweenPoints2D(x, y, SHOP_X, SHOP_Y) > 120 then return end
        ui.probed = true
        local pts = {
            { -326.50, 1379.00 },
            { -326.50, 1384.50 },
            { -326.73, 1346.18 },
            { -299.23, 1381.18 },
        }
        local out = {}
        for i, p in ipairs(pts) do
            local gz = getGroundPosition(p[1], p[2], 300)
            out[i] = gz and string.format("%.2f", gz) or "none"
        end
        triggerServerEvent("lbs:ground", localPlayer, out)
    end, 2000, 0)
end)

-- rendering
addEventHandler("onClientRender", root, function()
    if not ui.open or not ui.payload then return end

    local x = (sx - W) / 2
    local y = (sy - H) / 2

    -- dark panel with subtle gold trim
    local p_r, p_g, p_b, p_a = 25, 30, 40, 220
    dxDrawRectangle(x, y, W, H, rgba(p_r, p_g, p_b, p_a))
    -- top strip
    dxDrawRectangle(x, y, W, 38, rgba(255, 215, 0, 230))
    dxDrawText("LC BIKE SHOP", x + 12, y + 6, x + W - 12, y + 32,
        rgba(20, 20, 20, 255), 1.3, "default-bold", "left", "center")

    -- prominent HIDE button (top-right of the header)
    local hideX, hideY = x + W - 108, y + 5
    dxDrawRectangle(hideX, hideY, 100, 28, rgba(170, 55, 55, 235))
    dxDrawText("HIDE  X", hideX, hideY, hideX + 100, hideY + 28,
        rgba(255, 255, 255, 255), 1.05, "default-bold", "center", "center")
    addButton("hide", hideX, hideY, 100, 28, "HIDE", 170, 55, 55, 235)

    -- tabs bar
    local tb_y = y + 48
    local tw = 110
    local tx = x + 14
    for i, name in ipairs(TABS) do
        local active = (ui.tab == i)
        local br, bg, bb, ba = unpack_color(active and 0xFFD700 or 0xB8860B)
        dxDrawRectangle(tx, tb_y, tw, 28, rgba(br, bg, bb, active and 255 or 200))
        dxDrawText(name, tx, tb_y + 4, tx + tw, tb_y + 24,
            rgba(20, 20, 20, 255), 1.05, "default-bold", "center", "center")
        tx = tx + tw + 10
    end

    -- catalog rows
    local cy = y + 88
    local rows = filtered()
    local rh = 30
    local maxRows = 7
    local listBottom = cy + maxRows * (rh + 5) + 8

    for i, item in ipairs(rows) do
        if i <= maxRows then
            local yy = cy + (i - 1) * (rh + 5)
            local is_sel = (ui.sel == i)
            if is_sel then
                dxDrawRectangle(x + 12, yy, W - 24, rh, rgba(255, 215, 0, 20))
            end
            dxDrawText(item.e.name, x + 22, yy, x + 180, yy + rh,
                rgba(255, 255, 255, 255), 1.0, "default", "left", "center")
            dxDrawText("$" .. item.e.price, x + 200, yy, x + 280, yy + rh,
                rgba(255, 215, 0, 255), 1.0, "default-bold", "left", "center")
            -- buttons: TEST and BUY
            local bx = x + W - 130
            addButton("test" .. item.idx, bx, yy + 1, 56, 24, "TEST", 50, 205, 50, 255)
            addButton("buy" .. item.idx, bx + 64, yy + 1, 56, 24, "BUY", 255, 165, 0, 255)
        end
    end

    -- owned bikes section
    dxDrawRectangle(x + 12, listBottom, W - 24, 1, rgba(180, 180, 180, 50))
    dxDrawText("YOUR BIKES (sell 50% bank)", x + 18, listBottom + 6,
        x + W - 20, listBottom + 22, rgba(200, 200, 200, 180), 0.9, "default-bold", "left", "center")

    local owned = ui.payload.owned or {}
    local lo = listBottom + 30
    if #owned == 0 then
        dxDrawText("None yet - buy one above", x + 20, lo + 6, x + W - 20, lo + 20,
            rgba(160, 160, 160, 150), 0.85, "default", "center", "center")
    else
        for i, b in ipairs(owned) do
            if i <= 2 then
                local yy = lo + (i - 1) * 20
                addButton("sell" .. b.id, x + 18, yy, 260, 18,
                    "SELL " .. b.name .. " (id " .. b.id .. ")", 255, 100, 100, 255)
                dxDrawText("SELL " .. b.name .. " (id " .. b.id .. ")",
                    x + 28, yy, x + 278, yy + 18,
                    rgba(255, 255, 255, 250), 0.95, "default", "left", "center")
            end
        end
    end

    -- close button
    addButton("close", x + W - 110, y + H - 38, 100, 28, "CLOSE (ESC)", 100, 100, 100, 255)

    -- 3D preview box (right side, smaller)
    local px, py = x + W - 120, y + 88
    local pw, ph = 110, 90
    dxDrawRectangle(px, py, pw, ph, rgba(20, 25, 35, 200))
    if previewModel then
        dxDrawText("Model: " .. (ui.payload.catalog and
            ui.payload.catalog[math.max(1, ui.sel or 1) + 1] and
            ui.payload.catalog[math.max(1, ui.sel or 1) + 1].name or "?"),
            px + 6, py + 6, px + pw - 6, py + ph - 6,
            rgba(220, 230, 245, 220), 0.9, "default", "center", "center")
        dxDrawText("Rot: " .. string.format("%.1f, %.1f", previewRX, previewRY),
            px + 6, py + ph - 18, px + pw - 6, py + ph - 8,
            rgba(180, 190, 200, 180), 0.7, "default", "center", "center")
    else
        dxDrawText("No model", px + 6, py + 6, px + pw - 6, py + ph - 6,
            rgba(160, 160, 160, 150), 0.8, "default", "center", "center")
    end

    -- notice
    if ui.notice and getTickCount() < ui.noticeUntil then
        dxDrawRectangle(sx / 2 - 140, sy - 50, 280, 26, rgba(10, 18, 26, 200))
        dxDrawText(ui.notice, sx / 2 - 130, sy - 50, sx / 2 + 130, sy - 24,
            rgba(236, 244, 250), 0.95, "default-bold", "center", "center")
    end

    -- test ride timer
    if ui.testEnd and ui.testEnd > 0 then
        local left = math.max(0, math.ceil((ui.testEnd - getTickCount()) / 1000))
        if left > 0 then
            dxDrawRectangle(sx / 2 - 140, 10, 280, 24, rgba(12, 20, 28, 200))
            dxDrawText("TEST RIDE: " .. tostring(ui.testName) .. "  -  " .. left .. "s",
                sx / 2 - 130, 10, sx / 2 + 130, 34,
                rgba(248, 214, 130), 1.0, "default-bold", "center", "center")
        end
    end
end)

-- button colours (defined once at bottom so addButton can reference)
local green_r, green_g, green_b = 50, 205, 50   -- lime
local gold_r, gold_g, gold_b = 255, 215, 0        -- gold

-- register clickable buttons after UI is built (inside render loop is fine;
-- but for simplicity we rely on the addButton ids matching; the click handler
-- uses the id prefix to determine action, so it works without extra setup).

-- ------------------------------------------------------------------