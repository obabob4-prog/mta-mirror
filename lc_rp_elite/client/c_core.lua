--[[
    lc_rp_elite / client/c_core.lua
    Shared client state, bilingual text, dx primitives, input capture,
    notifications and fade. Drawing only happens while a panel is open.
]]
LCRE = LCRE or {}
LCRE.client = LCRE.client or {}

local C = LCRE.client
local sw, sh = guiGetScreenSize()
C.sw, C.sh = sw, sh
C.scale = math.max(0.78, math.min(1.25, sh / 1080))
C.panel = nil
C.tab = {}
C.lang = "en"
C.focus = nil
C.inputs = {}
C.buttons = {}
C.notifications = {}
C.fade = { active = false, alpha = 0, dir = 1, t = 0, duration = 350, hold = 0, autoOut = false }
C.duty = false
C.roomIds = {}
C.data = { mafia = nil, mdt = nil, record = nil, vehicles = nil, evidence = nil, search = nil }

C.font = dxCreateFont(":lmb_mechanic/fonts/Cairo.ttf", math.floor(18 * C.scale), true) or "default-bold"
C.fontSmall = dxCreateFont(":lmb_mechanic/fonts/Tajawal-Regular.ttf", math.floor(15 * C.scale)) or "default"
C.fontTitle = dxCreateFont(":lmb_mechanic/fonts/Cairo.ttf", math.floor(26 * C.scale), true) or "default-bold"

function C.t(ar, en)
    if C.lang == "ar" then return ar or en or "" end
    return en or ar or ""
end

function C.send(action, data)
    triggerServerEvent("lcre:action", localPlayer, action, data or {})
end

function C.open(panel)
    C.panel = panel
    C.focus = nil
    showCursor(panel ~= nil)
end

function C.close()
    C.panel = nil
    C.focus = nil
    showCursor(false)
end

function C.color(t, alpha)
    if type(t) == "table" then
        return tocolor(t[1] or 255, t[2] or 255, t[3] or 255, alpha or t[4] or 255)
    end
    return tocolor(255, 255, 255, alpha or 255)
end

function C.px(n) return math.floor(n * C.scale) end

function C.rect(x, y, w, h, color, postGUI)
    dxDrawRectangle(x, y, w, h, color, postGUI ~= false)
end

function C.line(x, y, w, color)
    C.rect(x, y, w, math.max(1, C.px(1)), color)
end

function C.text(str, x, y, w, h, color, font, align, valign, postGUI)
    dxDrawText(tostring(str), x, y, x + w, y + h, color or C.color(LCRE.theme.text),
        font or C.fontSmall, align or "left", valign or "center", false, false, postGUI ~= false)
end

function C.window(x, y, w, h, accent, titleAr, titleEn, subtitle)
    accent = accent or LCRE.theme.gold
    C.rect(x, y, w, h, C.color(LCRE.theme.bg, 246))
    C.rect(x, y, w, C.px(58), C.color(LCRE.theme.panel2, 255))
    C.line(x, y + C.px(58), w, C.color(accent, 170))
    C.rect(x, y, C.px(5), h, C.color(accent, 255))
    C.text(titleAr or "", x + C.px(22), y + C.px(6), w * 0.52, C.px(25),
        C.color(accent), C.font, "left", "center")
    C.text(titleEn or "", x + w * 0.50, y + C.px(7), w * 0.46, C.px(24),
        C.color(LCRE.theme.dim), C.fontSmall, "right", "center")
    if subtitle then
        C.text(subtitle, x + C.px(22), y + C.px(31), w - C.px(40), C.px(22),
            C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
    end
    C.text("×", x + w - C.px(42), y + C.px(6), C.px(30), C.px(30),
        C.color(LCRE.theme.text), C.font, "center", "center")
    C.buttons["__close"] = { x = x + w - C.px(48), y = y + C.px(2), w = C.px(44), h = C.px(48), fn = C.close }
end

function C.button(id, labelAr, labelEn, x, y, w, h, fn, active, accent)
    local mx, my = getCursorPosition()
    mx, my = (mx or 0) * sw, (my or 0) * sh
    local hover = C.panel and mx >= x and mx <= x + w and my >= y and my <= y + h
    local a = accent or LCRE.theme.gold
    local bg = active and C.color(a, 210) or (hover and C.color(LCRE.theme.panel2, 255) or C.color(LCRE.theme.panel, 255))
    C.rect(x, y, w, h, bg)
    C.rect(x, y, C.px(2), h, C.color(a, active and 255 or 130))
    C.text(C.t(labelAr, labelEn), x + C.px(6), y, w - C.px(12), h,
        C.color(active and { 10, 10, 12 } or LCRE.theme.text), C.fontSmall, "center", "center")
    C.buttons[id] = { x = x, y = y, w = w, h = h, fn = fn }
end

function C.input(id, labelAr, labelEn, x, y, w, h)
    local value = C.inputs[id] or ""
    local focused = C.focus == id
    C.rect(x, y, w, h, C.color(focused and LCRE.theme.panel2 or { 10, 10, 14 }, 255))
    C.rect(x, y, w, C.px(1), C.color(focused and LCRE.theme.gold or LCRE.theme.line, 255))
    C.rect(x, y + h - C.px(1), w, C.px(1), C.color(focused and LCRE.theme.gold or LCRE.theme.line, 255))
    local display = value
    if not focused and value == "" then display = C.t(labelAr, labelEn) end
    if focused then display = value .. "▌" end
    C.text(display, x + C.px(8), y, w - C.px(16), h,
        C.color(focused and LCRE.theme.text or LCRE.theme.dim), C.fontSmall, "left", "center")
    C.buttons["input:" .. id] = { x = x, y = y, w = w, h = h,
        fn = function() C.focus = id end }
    return value
end

function C.list(rows, x, y, w, h, rowH, formatter, onClick, accent)
    rowH = rowH or C.px(32)
    C.rect(x, y, w, h, C.color({ 10, 10, 14 }, 220))
    local maxRows = math.floor(h / rowH)
    for i = 1, math.min(#rows, maxRows) do
        local row = rows[i]
        local ry = y + (i - 1) * rowH
        if i % 2 == 0 then C.rect(x, ry, w, rowH, C.color(LCRE.theme.panel, 150)) end
        C.line(x, ry + rowH - 1, w, C.color(LCRE.theme.line, 120))
        C.text(formatter(row, i), x + C.px(8), ry, w - C.px(16), rowH,
            C.color(accent or LCRE.theme.text), C.fontSmall, "left", "center")
        if onClick then
            C.buttons["row:" .. tostring(i)] = { x = x, y = ry, w = w, h = rowH,
                fn = function() onClick(row, i) end }
        end
    end
    if #rows == 0 then
        C.text(C.t("لا توجد بيانات", "No data"), x, y, w, h,
            C.color(LCRE.theme.dim), C.fontSmall, "center", "center")
    end
end

function C.tabs(tabs, x, y, w, current, onChange, accent)
    local tw = w / #tabs
    for i, tab in ipairs(tabs) do
        local active = current == tab.id
        C.button("tab:" .. tab.id, tab.ar, tab.en, x + (i - 1) * tw, y, tw - C.px(4), C.px(34),
            function() onChange(tab.id) end, active, accent)
    end
end

function C.notify(text, kind)
    table.insert(C.notifications, { text = tostring(text), kind = kind or "info", untilTick = getTickCount() + 5200 })
    if #C.notifications > 5 then table.remove(C.notifications, 1) end
end

addEvent("lcre:notify", true)
addEventHandler("lcre:notify", root, function(text, kind) C.notify(text, kind) end)

addEvent("lcre:fade", true)
addEventHandler("lcre:fade", root, function(on, duration)
    C.fade.active = true
    C.fade.dir = on and 1 or -1
    C.fade.duration = tonumber(duration) or 350
    C.fade.hold = on and 140 or 0
    C.fade.autoOut = on == true
    C.fade.t = getTickCount()
end)

addEvent("lcre:duty", true)
addEventHandler("lcre:duty", root, function(on) C.duty = on == true end)

addEventHandler("onClientRender", root, function()
    C.buttons = {}
    local now = getTickCount()
    if C.fade.autoOut and C.fade.dir > 0 and
       (now - C.fade.t) >= C.fade.duration + C.fade.hold then
        C.fade.dir = -1
        C.fade.autoOut = false
        C.fade.t = now
    end
    local elapsed = now - C.fade.t
    local k = C.fade.dir > 0 and elapsed / C.fade.duration or 1 - elapsed / C.fade.duration
    k = math.max(0, math.min(1, k))
    C.fade.alpha = math.floor(255 * k)
    if C.fade.active and C.fade.dir < 0 and elapsed >= C.fade.duration then
        C.fade.active = false
        C.fade.alpha = 0
    end
    if C.fade.alpha > 0 then
        C.rect(0, 0, sw, sh, tocolor(0, 0, 0, C.fade.alpha), true)
    end
    local y = C.px(22)
    for i = #C.notifications, 1, -1 do
        local n = C.notifications[i]
        if now > n.untilTick then
            table.remove(C.notifications, i)
        else
            local a = math.min(255, math.max(0, 255 - ((now - (n.untilTick - 5200)) / 5200) * 255))
            local color = LCRE.theme.info
            if n.kind == "good" or n.kind == "mafia" then color = n.kind == "mafia" and LCRE.theme.gold or LCRE.theme.good end
            if n.kind == "bad" then color = LCRE.theme.bad end
            if n.kind == "warn" or n.kind == "police" then color = n.kind == "police" and LCRE.theme.blue or LCRE.theme.warn end
            local text = n.text
            local w = math.min(C.px(620), dxGetTextWidth(text, 1.0, C.fontSmall) + C.px(46))
            local x = (sw - w) / 2
            C.rect(x, y, w, C.px(38), C.color({ 10, 10, 14 }, math.floor(a * 0.92)))
            C.rect(x, y, C.px(3), C.px(38), C.color(color, a))
            C.text(text, x + C.px(12), y, w - C.px(20), C.px(38), C.color(color, a), C.fontSmall, "left", "center")
            y = y + C.px(43)
        end
    end
end, true)

addEventHandler("onClientClick", root, function(button, state)
    if button ~= "left" or state ~= "up" or not C.panel then return end
    for id, b in pairs(C.buttons) do
        local mx, my = getCursorPosition()
        mx, my = (mx or 0) * sw, (my or 0) * sh
        if mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h then
            if b.fn then b.fn() end
            if id ~= "__close" and not id:find("^input:") then C.focus = nil end
            return
        end
    end
    C.focus = nil
end)

function removeLastUTF8(s)
    if not s or s == "" then return "" end
    local len = #s
    while len > 0 and string.byte(s, len) and string.byte(s, len) >= 0x80 and string.byte(s, len) < 0xC0 do
        len = len - 1
    end
    return s:sub(1, math.max(0, len - 1))
end

addEventHandler("onClientCharacter", root, function(character)
    if not C.focus or not C.panel then return end
    cancelEvent()
    local cur = C.inputs[C.focus] or ""
    if #cur < 80 then C.inputs[C.focus] = cur .. character end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not press then return end
    if key == "escape" and C.panel then
        C.close()
        cancelEvent()
        return
    end
    if C.focus and C.panel then
        if key == "backspace" then
            C.inputs[C.focus] = removeLastUTF8(C.inputs[C.focus] or "")
            cancelEvent()
        elseif key == "enter" then
            C.focus = nil
            cancelEvent()
        end
    end
end)

addCommandHandler("elite", function() C.open("menu") end)
addCommandHandler("eliteclose", function() C.close() end)
addCommandHandler("elitemafia", function() C.open("mafia") C.send("mafiaInfo", {}) end)
addCommandHandler("elitegarage", function() C.open("vehicles") C.send("vehicleList", { kind = "faction", faction = 0 }) end)

addCommandHandler("lrelang", function(_, lang)
    if lang == "ar" or lang == "en" then
        C.lang = lang
    else
        C.lang = C.lang == "ar" and "en" or "ar"
    end
    C.notify(C.t("العربية", "English"), "info")
end)
