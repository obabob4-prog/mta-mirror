--[[
    ng-rp c_util.lua - shared DX UI library (client)
    Modern flat GTA-V style windows, buttons, labels, edit boxes.
    All other UI resources build on this via client exports.
]]

-- 2026-11-19: unified GTA V luxury theme.  Every resource that builds its UI
-- through this shared library inherits the new look automatically; widget IDs,
-- rectangles, callbacks and click hit-testing are intentionally untouched.
local THEME = {
    bg      = tocolor(10, 14, 21, 250),
    panel   = tocolor(17, 23, 32, 250),
    panel2  = tocolor(27, 36, 49, 250),
    accent  = tocolor(232, 197, 107, 255),
    accentD = tocolor(120, 92, 36, 255),
    gold    = tocolor(232, 197, 107, 255),
    green   = tocolor(126, 217, 87, 255),
    line    = tocolor(52, 68, 88, 255),
    dark    = tocolor(10, 14, 21, 255),
    text    = tocolor(238, 243, 250, 255),
    dim     = tocolor(151, 164, 181, 255),
    danger  = tocolor(224, 76, 76, 255),
    success = tocolor(96, 200, 120, 255),
}

local function initials(str)
    str = tostring(str or "")
    local out = {}
    for word in str:gmatch("%S+") do
        local c = word:sub(1, 1):upper()
        if c:match("%w") then out[#out + 1] = c end
        if #out >= 2 then break end
    end
    return #out > 0 and table.concat(out) or "LC"
end

-- ============ multilingual shared labels (AR / EN / PT) ============
-- Callers keep their original English IDs and callback wiring.  Only the text
-- that is actually drawn is translated, so /uilang never breaks a button.
local LOCALE = "en"
local DICT = {
    ar = {
        ["BUY"] = "شراء", ["BUY VEHICLE"] = "شراء مركبة", ["CLOSE"] = "إغلاق",
        ["USE"] = "استخدام", ["DROP"] = "إسقاط", ["GIVE"] = "إعطاء",
        ["GIVE TO PLAYER"] = "إعطاء لاعب", ["CANCEL"] = "إلغاء",
        ["CALL"] = "اتصال", ["SMS"] = "رسالة", ["SEND"] = "إرسال",
        ["BACK"] = "رجوع", ["PUBLISH"] = "نشر", ["DEPOSIT"] = "إيداع",
        ["WITHDRAW"] = "سحب", ["TRANSFER"] = "تحويل", ["KICK"] = "طرد",
        ["BAN"] = "حظر", ["GO"] = "انتقال", ["PLAYERS"] = "اللاعبون",
        ["RES"] = "الموارد", ["SERVER"] = "السيرفر", ["LOGS"] = "السجلات",
        ["SPAWN VEH"] = "استدعاء مركبة", ["SPAWN"] = "استدعاء",
        ["PREV"] = "السابق", ["NEXT"] = "التالي",
        ["START /work ROUTE NOW"] = "ابدأ مسار العمل الآن",
        ["LIBERTY CITY  //  NGRP SYSTEMS"] = "ليبرتي سيتي  //  أنظمة NGRP",
    },
    pt = {
        ["BUY"] = "COMPRAR", ["BUY VEHICLE"] = "COMPRAR VEÍCULO", ["CLOSE"] = "FECHAR",
        ["USE"] = "USAR", ["DROP"] = "LARGAR", ["GIVE"] = "DAR",
        ["GIVE TO PLAYER"] = "DAR A JOGADOR", ["CANCEL"] = "CANCELAR",
        ["CALL"] = "LIGAR", ["SMS"] = "MENSAGEM", ["SEND"] = "ENVIAR",
        ["BACK"] = "VOLTAR", ["PUBLISH"] = "PUBLICAR", ["DEPOSIT"] = "DEPOSITAR",
        ["WITHDRAW"] = "SACAR", ["TRANSFER"] = "TRANSFERIR", ["KICK"] = "EXPULSAR",
        ["BAN"] = "BANIR", ["GO"] = "IR", ["PLAYERS"] = "JOGADORES",
        ["RES"] = "RECURSOS", ["SERVER"] = "SERVIDOR", ["LOGS"] = "LOGS",
        ["SPAWN VEH"] = "CRIAR VEÍCULO", ["SPAWN"] = "CRIAR",
        ["PREV"] = "ANTERIOR", ["NEXT"] = "PRÓXIMO",
        ["START /work ROUTE NOW"] = "INICIAR ROTA DE TRABALHO",
        ["LIBERTY CITY  //  NGRP SYSTEMS"] = "LIBERTY CITY  //  SISTEMAS NGRP",
    },
}
local function tr(text)
    if LOCALE == "en" then return tostring(text or "") end
    local key = tostring(text or "")
    local d = DICT[LOCALE]
    return (d and d[key]) or key
end
function setUILocale(lang)
    lang = tostring(lang or "en"):lower()
    if lang == "arabic" or lang == "ar" then LOCALE = "ar"
    elseif lang == "portuguese" or lang == "pt" or lang == "pt-br" then LOCALE = "pt"
    else LOCALE = "en" end
    return LOCALE
end
function getUILocale() return LOCALE end
addCommandHandler("uilang", function(_, lang)
    local ok = setUILocale(lang)
    notify("UI language: " .. string.upper(ok), 232, 197, 107)
end)

local sw, sh = guiGetScreenSize()
local DSX, DSY = 1920, 1080

local function sx(v) return math.floor(v * (sw / DSX)) end
local function sy(v) return math.floor(v * (sh / DSY)) end
local function sxy(v)
    -- dxDrawText accepts FRACTIONAL scales.  Flooring here made every label
    -- snap to 1 on smaller resolutions while the window itself shrank, which
    -- is what produced the oversized / distorted F1-style menus.
    local scale = v * math.min(sw / DSX, sh / DSY)
    if scale < 0.35 then scale = 0.35 end
    return scale
end

local windows  = {}   -- id -> {x,y,w,h,title,visible,labels={},edits={}}
local buttons  = {}   -- list of {win,x,y,w,h,text,cb,hover}
local editObjs = {}   -- key -> gui edit element
local cursorCount = 0

local function inRect(cx, cy, x, y, w, h)
    return cx >= x and cx <= x + w and cy >= y and cy <= y + h
end

-- ============ window management ============

function openWindow(id, title, x, y, w, h)
    local win = windows[id]
    if not win then
        win = {
            x = sx(x), y = sy(y), w = sx(w), h = sy(h),
            title = title or "", visible = false,
            labels = {}, edits = {},
        }
        windows[id] = win
    end
    -- Re-opening an already visible window must NOT take another cursor
    -- reference; that leaked count kept the cursor stuck after closing.
    if not win.visible then
        win.visible = true
        if cursorCount == 0 then showCursor(true) end
        cursorCount = cursorCount + 1
    end
    return win
end

function closeWindow(id)
    local win = windows[id]
    if not win then return end
    win.visible = false
    for k, ed in pairs(win.edits) do
        if isElement(ed) then guiSetVisible(ed, false) end
    end
    for i = #buttons, 1, -1 do
        if buttons[i].win == id then table.remove(buttons, i) end
    end
    cursorCount = math.max(0, cursorCount - 1)
    if cursorCount == 0 then showCursor(false) end
end

function closeAllWindows()
    for id in pairs(windows) do closeWindow(id) end
end

function isWindowOpen(id)
    return windows[id] and windows[id].visible
end

-- Remove dynamic content (labels/buttons/edits) but keep window
function windowClear(winId)
    local win = windows[winId]
    if not win then return end
    for k, ed in pairs(win.edits) do
        if isElement(ed) then destroyElement(ed) end
    end
    win.edits = {}
    win.labels = {}
    for i = #buttons, 1, -1 do
        if buttons[i].win == winId then table.remove(buttons, i) end
    end
end

-- ============ widgets ============

-- x,y,w,h are window-relative percentages of the window (0..1)
function windowButton(winId, btnId, text, rx, ry, rw, rh, cb, color)
    local win = windows[winId]
    if not win then return end
    -- replace existing button with same id
    for i, b in ipairs(buttons) do
        if b.win == winId and b.btnId == btnId then table.remove(buttons, i) break end
    end
    table.insert(buttons, {
        win = winId, btnId = btnId, text = text,
        rx = rx, ry = ry, rw = rw, rh = rh,
        cb = cb, hover = false, color = color,
    })
end

function windowLabel(winId, labelId, text, rx, ry, rw, rh, size, color, alignX, alignY, font)
    local win = windows[winId]
    if not win then return end
    win.labels[labelId] = {
        text = text, rx = rx, ry = ry, rw = rw or 1.0, rh = rh or 0.06,
        size = size or 1.0, color = color or THEME.text,
        alignX = alignX or "left", alignY = alignY or "center", font = font or "default-bold",
    }
    return win.labels[labelId]
end

function setWindowLabel(winId, labelId, text)
    local win = windows[winId]
    if win and win.labels[labelId] then win.labels[labelId].text = text end
end

function windowEdit(winId, editId, defaultText, rx, ry, rw, rh, masked)
    local win = windows[winId]
    if not win then return end
    local key = winId .. "_" .. editId
    if editObjs[key] and isElement(editObjs[key]) then
        destroyElement(editObjs[key])
    end
    local px = win.x + math.floor(rx * win.w)
    local py = win.y + math.floor(ry * win.h)
    local ed = guiCreateEdit(px, py, math.floor(rw * win.w), math.floor(rh * win.h), defaultText or "", false)
    guiSetProperty(ed, "Masked", masked and "True" or "False")
    guiSetProperty(ed, "NormalTextColour", "FFEBF0F5")
    guiSetAlpha(ed, 0.9)
    win.edits[editId] = ed
    editObjs[key] = ed
    return ed
end

function windowGetEdit(winId, editId)
    local win = windows[winId]
    local ed = win and win.edits[editId]
    if ed and isElement(ed) then return guiGetText(ed) end
    return ""
end

-- ============ rendering ============

addEventHandler("onClientRender", root, function()
    local cx, cy = getCursorAbsolute()

    -- visible windows ------------------------------------------------------
    for id, win in pairs(windows) do
        if win.visible then
            -- cinematic scrim + faint side pillars
            dxDrawRectangle(0, 0, sw, sh, tocolor(4, 7, 11, 168))
            dxDrawRectangle(0, 0, sx(34), sh, tocolor(232, 197, 107, 10))
            dxDrawRectangle(sw - sx(34), 0, sx(34), sh, tocolor(232, 197, 107, 10))

            -- outer glow / body / borders
            dxDrawRectangle(win.x - 3, win.y - 3, win.w + 6, win.h + 6, tocolor(232, 197, 107, 22))
            dxDrawRectangle(win.x, win.y, win.w, win.h, THEME.bg)
            dxDrawRectangle(win.x, win.y, win.w, sy(4), THEME.accent)
            dxDrawRectangle(win.x, win.y + sy(4), win.w, sy(2), THEME.gold)
            dxDrawRectangle(win.x, win.y, sy(2), win.h, THEME.line)
            dxDrawRectangle(win.x + win.w - sy(2), win.y, sy(2), win.h, THEME.line)
            dxDrawRectangle(win.x, win.y + win.h - sy(2), win.w, sy(2), THEME.line)

            -- title bar with a small avatar badge
            local headH = sy(52)
            dxDrawRectangle(win.x, win.y + sy(6), win.w, headH, THEME.panel)
            local badge = sy(34)
            local bx0 = win.x + sy(14)
            local by0 = win.y + sy(15)
            dxDrawRectangle(bx0 - 2, by0 - 2, badge + 4, badge + 4, THEME.gold)
            dxDrawRectangle(bx0, by0, badge, badge, THEME.accentD)
            dxDrawText(initials(win.title), bx0, by0, bx0 + badge, by0 + badge,
                THEME.text, sxy(0.92), "default-bold", "center", "center")
            dxDrawText(tr(win.title), win.x + sy(60), win.y + sy(6),
                win.x + win.w - sy(130), win.y + sy(6) + sy(34),
                THEME.text, sxy(1.15), "default-bold", "left", "center")
            -- language chip (EN / ع / PT) - click-free, reflects /uilang
            local chipW = sy(52)
            dxDrawRectangle(win.x + win.w - chipW - sy(14), win.y + sy(16), chipW, sy(26), THEME.panel2)
            dxDrawRectangle(win.x + win.w - chipW - sy(14), win.y + sy(16), sy(3), sy(26), THEME.gold)
            dxDrawText(LOCALE == "ar" and "ع" or string.upper(LOCALE),
                win.x + win.w - chipW - sy(14), win.y + sy(16),
                win.x + win.w - sy(14), win.y + sy(42),
                THEME.gold, sxy(0.8), "default-bold", "center", "center")
            dxDrawText(tr("LIBERTY CITY  //  NGRP SYSTEMS"), win.x + sy(61), win.y + sy(36),
                win.x + win.w - sy(18), win.y + sy(6) + headH,
                THEME.dim, sxy(0.72), "default", "left", "center")

            -- labels (callers keep full control over text/rect/colour)
            for _, lb in pairs(win.labels) do
                local lx = win.x + math.floor(lb.rx * win.w)
                local ly = win.y + math.floor(lb.ry * win.h)
                dxDrawText(tr(lb.text), lx, ly, lx + math.floor(lb.rw * win.w), ly + math.floor(lb.rh * win.h),
                    lb.color, sxy(lb.size), lb.font, lb.alignX, lb.alignY, true, false, false, true)
            end

            -- edit slots
            for _, ed in pairs(win.edits) do
                if isElement(ed) then
                    local ex, ey = guiGetPosition(ed, false)
                    local ew, eh = guiGetSize(ed, false)
                    dxDrawRectangle(ex - 2, ey - 2, ew + 4, eh + 4, THEME.line)
                    dxDrawRectangle(ex - 1, ey - 1, ew + 2, eh + 2, THEME.panel2)
                end
            end
        end
    end

    -- buttons (hit rectangles are unchanged; only the paint is new)
    for _, b in ipairs(buttons) do
        local win = windows[b.win]
        if win and win.visible then
            local bx = win.x + math.floor(b.rx * win.w)
            local by = win.y + math.floor(b.ry * win.h)
            local bw = math.floor(b.rw * win.w)
            local bh = math.floor(b.rh * win.h)
            b.hover = inRect(cx or -1, cy or -1, bx, by, bw, bh)

            local fill = b.color or (b.hover and THEME.accentD or THEME.panel2)
            dxDrawRectangle(bx, by, bw, bh, fill)
            dxDrawRectangle(bx, by, sy(3), bh, b.hover and THEME.gold or THEME.accent)
            dxDrawRectangle(bx, by + bh - 1, bw, 1, THEME.line)

            local iconSize = math.min(sy(24), bh - sy(6))
            local ix = bx + sy(9)
            local iy = by + (bh - iconSize) / 2
            dxDrawRectangle(ix, iy, iconSize, iconSize, b.hover and THEME.accent or THEME.panel)
            local label = tr(b.text)
            dxDrawText(label:sub(1, 1):upper(), ix, iy, ix + iconSize, iy + iconSize,
                b.hover and THEME.dark or THEME.text, sxy(0.85), "default-bold", "center", "center")

            dxDrawText(label, bx + sy(42), by, bx + bw - sy(10), by + bh,
                THEME.text, sxy(1.0), "default-bold", "left", "center", true)
        end
    end
end, true, "low-50")

function getCursorAbsolute()
    local cx, cy = 0, 0
    if isCursorShowing() then
        local rx, ry = getCursorPosition()
        cx, cy = rx * sw, ry * sh
    end
    return cx, cy
end

addEventHandler("onClientClick", root, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    local cx, cy = getCursorAbsolute()
    -- iterate from topmost (last) to first
    for i = #buttons, 1, -1 do
        local b = buttons[i]
        local win = windows[b.win]
        if win and win.visible then
            local bx = win.x + math.floor(b.rx * win.w)
            local by = win.y + math.floor(b.ry * win.h)
            if inRect(cx, cy, bx, by, math.floor(b.rw * win.w), math.floor(b.rh * win.h)) then
                if b.cb then b.cb() end
                return
            end
        end
    end
end)

-- ============ notifications (top-center toasts) ============

local toasts = {} -- {text, color, until_}

function notify(text, r, g, b)
    table.insert(toasts, {
        text = tr(text),
        color = tocolor(r or 232, g or 197, b or 107, 255),
        until_ = getTickCount() + 4000,
    })
end

addEventHandler("onClientRender", root, function()
    local now = getTickCount()
    for i = #toasts, 1, -1 do
        if toasts[i].until_ < now then table.remove(toasts, i) end
    end
    local y = sy(120)
    for _, t in ipairs(toasts) do
        local tw = dxGetTextWidth(t.text, sxy(1.0), "default-bold") or 200
        local boxW = tw + sy(104)
        local boxX = (sw - boxW) / 2
        dxDrawRectangle(boxX - 3, y - 3, boxW + 6, sy(44), tocolor(232, 197, 107, 20))
        dxDrawRectangle(boxX, y, boxW, sy(38), tocolor(10, 14, 21, 235))
        dxDrawRectangle(boxX, y, sy(4), sy(38), t.color)
        dxDrawRectangle(boxX, y + sy(36), boxW, sy(2), THEME.gold)
        dxDrawRectangle(boxX + sy(14), y + sy(7), sy(24), sy(24), t.color)
        dxDrawText("!", boxX + sy(14), y + sy(7), boxX + sy(38), y + sy(31),
            THEME.dark, sxy(0.9), "default-bold", "center", "center")
        dxDrawText(t.text, boxX + sy(48), y, boxX + boxW - sy(12), y + sy(38),
            t.color, sxy(1.0), "default-bold", "left", "center")
        y = y + sy(46)
    end
end)

-- ============ helpers ============

function getTheme() return THEME end
function uiScale() return math.min(sw / DSX, sh / DSY) end

-- watermark toggle
-- 2026-11-18: F9 is the server vehicle list (ng-vehicles).
-- 2026-11-19: F10 is now the in-game character switch (characters_lc), so the
-- watermark moved to F2 to keep both features without a key clash.
local watermark = false
bindKey("f2", "down", function() watermark = not watermark end)
addEventHandler("onClientRender", root, function()
    if watermark then
        dxDrawText("Next Generation Roleplay", sw - 260, 12, sw - 20, 40, tocolor(255, 255, 255, 150), sxy(0.9), "default-bold", "right", "top")
    end
end)
