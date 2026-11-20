--[[ ============================================================
     ng-vehicles / c_f9vehicles.lua  (2026-11-18)
     F9 -> live list of the luxury cars installed on this server.
     Click a car and the server spawns it next to you and seats you
     in the driver seat. DX only, LmB gold/black styling.
     ============================================================ ]]

local SCREEN_W, SCREEN_H = guiGetScreenSize()

local open      = false
local list      = nil      -- filled by ngv:f9show (server is the source)
local hover     = nil
local scroll    = 0
local flash     = {}       -- model -> tick, short gold confirmation
local requested = false

local GOLD       = tocolor(226, 190, 116, 255)
local GOLD_SOFT  = tocolor(226, 190, 116, 190)
local GOLD_DIM   = tocolor(226, 190, 116, 60)
local WHITE      = tocolor(238, 241, 247, 255)
local GRAY       = tocolor(150, 157, 170, 235)
local CARD_BG    = tocolor(16, 18, 22, 235)
local CARD_HOVER = tocolor(34, 28, 18, 245)

local function unit()
    return math.max(SCREEN_H / 1080, 0.72)
end

-- layout is rebuilt every frame; click/wheel use the same numbers
local function getLayout()
    local u = unit()
    local w = math.min(940 * u, SCREEN_W * 0.94)
    local h = math.min(660 * u, SCREEN_H * 0.90)
    local x = (SCREEN_W - w) / 2
    local y = (SCREEN_H - h) / 2
    local pad = 26 * u
    local headerH = 96 * u
    local footerH = 52 * u
    local gap = 10 * u
    local cardH = 46 * u
    local cols = 2
    local cardW = (w - pad * 2 - gap) / 2
    local listH = h - headerH - footerH
    local rows = math.max(1, math.floor((listH + gap) / (cardH + gap)))

    return {
        u = u, x = x, y = y, w = w, h = h, pad = pad,
        headerH = headerH, footerH = footerH,
        gap = gap, cardH = cardH, cardW = cardW, cols = cols,
        rows = rows, listH = listH,
        close = {
            x = x + w - pad - 96 * u, y = y + h - footerH + 8 * u,
            w = 96 * u, h = 34 * u,
        },
    }
end

local function maxScroll(lay)
    local totalRows = math.ceil(((list or {}) and #list or 0) / lay.cols)
    return math.max(0, totalRows - lay.rows)
end

local function mouseIn(x, y, w, h)
    if not isCursorShowing() then return false end
    local cx, cy = getCursorPosition()
    cx, cy = cx * SCREEN_W, cy * SCREEN_H
    return cx >= x and cx <= x + w and cy >= y and cy <= y + h
end

local function drawPanel(lay)
    local u, x, y, w, h, pad = lay.u, lay.x, lay.y, lay.w, lay.h, lay.pad

    dxDrawRectangle(0, 0, SCREEN_W, SCREEN_H, tocolor(0, 0, 0, 160))

    -- charcoal glass body + gold rims
    dxDrawRectangle(x + 6 * u, y + 10 * u, w, h, tocolor(0, 0, 0, 110))
    dxDrawRectangle(x, y, w, h, tocolor(10, 11, 14, 242))
    dxDrawRectangle(x, y, w, math.max(2, 3 * u), GOLD)
    dxDrawRectangle(x, y + h - math.max(1, 2 * u), w, math.max(1, 2 * u), GOLD_DIM)
    dxDrawRectangle(x, y, math.max(1, 2 * u), h, GOLD_DIM)
    dxDrawRectangle(x + w - math.max(1, 2 * u), y, math.max(1, 2 * u), h, GOLD_DIM)

    -- header
    dxDrawText("SERVER VEHICLES", x + pad, y + 18 * u, x + w - pad, y + 52 * u,
        GOLD, 1, "default-bold", "left", "center")
    dxDrawText("CHOOSE A CAR TO SPAWN IT NEXT TO YOU", x + pad, y + 52 * u, x + w - pad, y + 78 * u,
        GRAY, 1, "default", "left", "center")
    dxDrawRectangle(x + pad, y + 84 * u, w - pad * 2, math.max(1, u), GOLD_DIM)

    -- footer hint
    dxDrawText("F9 / ESC  CLOSE      MOUSE WHEEL  SCROLL", x + pad, y + h - 44 * u, x + w - pad, y + h - 12 * u,
        GRAY, 1, "default", "left", "center")
end

local function drawCards(lay)
    local u, x, y, w, pad = lay.u, lay.x, lay.y, lay.w, lay.pad
    local listTop = y + lay.headerH
    local maxS = maxScroll(lay)
    if scroll > maxS then scroll = maxS end
    if scroll < 0 then scroll = 0 end

    hover = nil

    for i = 1, #(list or {}) do
        local row = math.floor((i - 1) / lay.cols)
        local col = (i - 1) % lay.cols
        local vis = row - scroll
        if vis >= 0 and vis < lay.rows then
            local cx = x + pad + col * (lay.cardW + lay.gap)
            local cy = listTop + vis * (lay.cardH + lay.gap)
            local item = list[i]
            local isHover = mouseIn(cx, cy, lay.cardW, lay.cardH)
            if isHover then hover = i end

            local isFlash = flash[item.model] and (getTickCount() - flash[item.model] < 600)

            dxDrawRectangle(cx, cy, lay.cardW, lay.cardH,
                (isHover or isFlash) and CARD_HOVER or CARD_BG)
            dxDrawRectangle(cx, cy, lay.cardW, math.max(1, math.floor(u)),
                isHover and GOLD or GOLD_DIM)
            dxDrawRectangle(cx, cy, math.max(1, math.floor(2 * u)), lay.cardH,
                isHover and GOLD or tocolor(226, 190, 116, 90))

            dxDrawText(tostring(item.name), cx + 12 * u, cy + 4 * u,
                cx + lay.cardW - 10 * u, cy + lay.cardH * 0.62,
                isHover and tocolor(248, 226, 182, 255) or WHITE,
                1, "default-bold", "left", "center", true)
            dxDrawText("MODEL " .. tostring(item.model), cx + 12 * u,
                cy + lay.cardH * 0.58, cx + lay.cardW - 10 * u, cy + lay.cardH - 2 * u,
                isHover and GOLD_SOFT or GRAY, 1, "default", "left", "center")
        end
    end

    -- scroll bar
    local totalRows = math.ceil(#(list or {}) / lay.cols)
    if totalRows > lay.rows then
        local trackH = lay.listH - 10 * u
        local trackX = x + w - pad + 6 * u
        local trackY = listTop + 4 * u
        local thumbH = math.max(28 * u, trackH * lay.rows / totalRows)
        local maxS2 = math.max(1, totalRows - lay.rows)
        local thumbY = trackY + (trackH - thumbH) * (scroll / maxS2)

        dxDrawRectangle(trackX, trackY, math.max(1, 2 * u), trackH, tocolor(255, 255, 255, 26))
        dxDrawRectangle(trackX, thumbY, math.max(2, 3 * u), thumbH, GOLD_SOFT)
    end
end

local function draw()
    if not open then return end
    local lay = getLayout()

    drawPanel(lay)

    if list == nil then
        dxDrawText(requested and "LOADING VEHICLES..." or "PRESS F9 AGAIN TO LOAD",
            lay.x, lay.y + lay.h * 0.45, lay.x + lay.w, lay.y + lay.h * 0.55,
            GRAY, 1, "default-bold", "center", "center")
    elseif #list == 0 then
        dxDrawText("NO SERVER VEHICLES AVAILABLE", lay.x, lay.y + lay.h * 0.45,
            lay.x + lay.w, lay.y + lay.h * 0.55, GRAY, 1, "default-bold", "center", "center")
    else
        drawCards(lay)
    end

    -- close button
    local cb = lay.close
    local hov = mouseIn(cb.x, cb.y, cb.w, cb.h)
    dxDrawRectangle(cb.x, cb.y, cb.w, cb.h, hov and tocolor(48, 30, 26, 240) or tocolor(24, 22, 22, 220))
    dxDrawRectangle(cb.x, cb.y, cb.w, math.max(1, math.floor(lay.u)), hov and GOLD or GOLD_DIM)
    dxDrawText("CLOSE", cb.x, cb.y, cb.x + cb.w, cb.y + cb.h,
        hov and GOLD or WHITE, 1, "default-bold", "center", "center")
end

local prevCursor = false

local function close()
    if not open then return end
    open = false
    hover = nil
    showCursor(prevCursor and true or false)
    removeEventHandler("onClientRender", root, draw)
end

local function openPanel()
    if open then return end
    if not getElementData(localPlayer, "char.spawned") then
        outputChatBox("[F9] Spawn a character first.", 226, 190, 116)
        return
    end
    open = true
    scroll = 0
    hover = nil
    prevCursor = isCursorShowing()
    showCursor(true)
    addEventHandler("onClientRender", root, draw)
    if not requested then
        requested = true
        triggerServerEvent("ngv:f9list", localPlayer)
    end
end

local function toggle()
    if open then close() else openPanel() end
end

bindKey("f9", "down", function()
    toggle()
end)

addEvent("ngv:f9show", true)
addEventHandler("ngv:f9show", root, function(data)
    if type(data) == "table" then
        list = data
        scroll = 0
    end
end)

addEventHandler("onClientClick", root, function(button, state)
    if not open or button ~= "left" or state ~= "down" then return end
    local lay = getLayout()

    if mouseIn(lay.close.x, lay.close.y, lay.close.w, lay.close.h) then
        close()
        return
    end

    if hover and list and list[hover] then
        local item = list[hover]
        flash[item.model] = getTickCount()
        triggerServerEvent("ngv:f9spawn", localPlayer, item.model)
        close()
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not open or not press then return end

    if key == "escape" then
        close()
        cancelEvent()
    elseif key == "mouse_wheel_up" then
        scroll = math.max(0, scroll - 1)
        cancelEvent()
    elseif key == "mouse_wheel_down" then
        local lay = getLayout()
        scroll = math.min(maxScroll(lay), scroll + 1)
        cancelEvent()
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    removeEventHandler("onClientRender", root, draw)
    showCursor(false)
    open = false
end)
