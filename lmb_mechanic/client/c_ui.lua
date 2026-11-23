-- ============================================================
-- LmB Customs - premium DX interface (charcoal / champagne gold)
-- All decisions are made by the server; this file only draws and
-- forwards button presses through the trusted "lmb:action" event.
-- ============================================================

local RES = ":lmb_mechanic/"
local ui = {
    open = false, page = "main", state = {}, hits = {},
    quote = nil, parts = {}, notify = nil, invoiceOpen = nil,
    sel = { repair = "all", upgrade = nil, c1 = 1, c2 = 1, part = nil, cat = nil },
    preview = nil, cursorWasShowing = false,
}

local screenW, screenH = guiGetScreenSize()
local sx, sy = screenW / 1920, screenH / 1080
local W, H = 1180, 700
local X, Y = (screenW - W * sx) / 2, (screenH - H * sy) / 2 + 30 * sy

local GOLD      = tocolor(212, 175,  90)
local GOLD_SOFT = tocolor(212, 175,  90, 42)
local GOLD_LINE = tocolor(212, 175,  90, 145)
local CHARCOAL  = tocolor(10,  11,  15, 246)
local GLASS     = tocolor(26,  28,  34, 222)
local GLASS_2   = tocolor(34,  36,  43, 232)
local WHITE     = tocolor(242, 240, 235)
local MUTED     = tocolor(168, 170, 178)
local GREEN     = tocolor( 96, 214, 138)
local RED       = tocolor(232,  92,  92)

local F = {}
local T = {}
local function buildAssets()
    local function font(file, size, bold)
        return dxCreateFont(RES .. "fonts/" .. file, size, bold or false) or "default-bold"
    end
    F.ar14  = font("Cairo.ttf", 14, true)
    F.ar17  = font("Cairo.ttf", 17, true)
    F.ar21  = font("Cairo.ttf", 21, true)
    F.ar27  = font("Cairo.ttf", 27, true)
    F.body  = font("Ubuntu-L.ttf", 15)
    F.bold  = font("Ubuntu-B.ttf", 15)
    F.big   = font("BebasNeueRegular.otf", 46)
    F.mid   = font("BebasNeueRegular.otf", 26)

    T.logo  = dxCreateTexture(RES .. "ui/logo.png")
    T.title = dxCreateTexture(RES .. "ui/ic_title.png")
    T.ic_title = T.title
    T.glow  = dxCreateTexture(RES .. "ui/glow.png")
    T.grad  = dxCreateTexture(RES .. "ui/grad.png")
    T.ring  = dxCreateTexture(RES .. "ui/ring.png")
    for _, name in ipairs({
        "ic_repair", "ic_upgrade", "ic_paint", "ic_parts", "ic_tow", "ic_info", "ic_close",
        "ic_cash", "ic_car", "ic_duty", "ic_ranks", "ic_invoice", "ic_people", "ic_check",
        "ic_engine", "ic_turbo", "ic_brake", "ic_susp", "ic_dash", "ic_nitro", "ic_wrench",
        "ic_wheel", "ic_exhaust", "ic_bumper", "ic_skirt", "ic_bodykit", "ic_lights", "ic_home",
    }) do
        T[name] = dxCreateTexture(RES .. "ui/icons/" .. name .. ".png")
    end
end
addEventHandler("onClientResourceStart", resourceRoot, buildAssets)

local function px(v) return v * sx end
local function py(v) return v * sy end

local function inside(x, y, w, h)
    local mx, my = getCursorPosition()
    if not mx then return false end
    mx, my = mx * screenW, my * screenH
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function text(s, x, y, w, h, color, font, scale, align, rtl)
    dxDrawText(tostring(s), x, y, x + w, y + h, color, scale or sx, scale or sx,
        font or F.body, align or "left", "center", false, true, false, false, false, 0, 0, 0)
end

local function panel(x, y, w, h, hover, strong)
    dxDrawImage(x - px(10), y - py(10), w + px(20), h + py(20), T.glow,
        0, 0, 0, hover and tocolor(212, 175, 90, 125) or (strong and tocolor(212, 175, 90, 70) or tocolor(0, 0, 0, 0)))
    dxDrawRectangle(x, y, w, h, hover and GLASS_2 or GLASS)
    dxDrawRectangle(x, y, w, py(1), hover and GOLD or GOLD_LINE)
    dxDrawRectangle(x, y + h - py(1), w, py(1), tocolor(212, 175, 90, 60))
end

local function icon(name, x, y, size, color)
    if T[name] then dxDrawImage(x, y, size, size, T[name], 0, 0, 0, color or WHITE) end
end

local function send(action, a, b, c, d)
    triggerServerEvent("lmb:action", localPlayer, action, a, b, c, d)
end

local function hit(id, x, y, w, h, fn)
    ui.hits[#ui.hits + 1] = { id = id, x = x, y = y, w = w, h = h, fn = fn }
    return inside(x, y, w, h)
end

local function button(id, ar, en, iconName, x, y, w, h, fn, active, danger)
    local hov = hit(id, x, y, w, h, fn)
    local edge = active and GOLD or (hov and tocolor(212, 175, 90, 210) or GOLD_LINE)
    dxDrawImage(x - px(8), y - py(8), w + px(16), h + py(16), T.glow, 0, 0, 0,
        hov and tocolor(212, 175, 90, 110) or tocolor(0, 0, 0, 0))
    dxDrawRectangle(x, y, w, h, hov and tocolor(52, 45, 32, 245) or tocolor(28, 29, 34, 238))
    dxDrawRectangle(x, y, py(2), h, edge)
    dxDrawRectangle(x, y + h - py(1), w, py(1), tocolor(212, 175, 90, 50))
    if iconName then icon(iconName, x + px(14), y + h / 2 - px(11), px(22), (active or hov) and GOLD or MUTED) end
    local tx = x + px(iconName and 46 or 16)
    text(ar, tx, y + py(3), w - px(56), h * 0.52, hov or active and WHITE or tocolor(220, 218, 214), F.ar17, sx, "left", true)
    text(en, tx, y + h * 0.50, w - px(56), h * 0.42, hov and GOLD or MUTED, F.body, sx * 0.86, "left")
    return hov
end

local function title(ar, en, x, y, w)
    text(ar, x, y, w, py(34), WHITE, F.ar21, sx, "left", true)
    text(en, x, y + py(31), w, py(22), GOLD, F.mid, sx * 0.85, "left")
    dxDrawRectangle(x, y + py(58), px(70), py(2), GOLD)
end

local function stat(x, y, w, h, ar, en, value, iconName)
    panel(x, y, w, h, false, false)
    icon(iconName, x + px(16), y + py(14), px(28), GOLD)
    text(ar, x + px(54), y + py(10), w - px(60), py(22), MUTED, F.ar14, sx, "left", true)
    text(en, x + px(54), y + py(30), w - px(60), py(18), MUTED, F.body, sx * 0.82, "left")
    text(value, x + px(16), y + py(52), w - px(30), py(28), WHITE, F.bold, sx * 1.15, "left")
end

-- ============================ pages ============================

local NAV = {
    { id = "repair",   ar = "إصلاح المركبات",   en = "Repair Vehicle",    icon = "ic_repair"  },
    { id = "upgrade",  ar = "ترقية المركبات",   en = "Upgrade Vehicle",   icon = "ic_upgrade" },
    { id = "paint",    ar = "تعديل الألوان",    en = "Modify Colors",     icon = "ic_paint"   },
    { id = "parts",    ar = "تركيب قطع",        en = "Install Parts",     icon = "ic_parts"   },
    { id = "tow",      ar = "سحب المركبات",     en = "Tow Vehicles",      icon = "ic_tow"     },
    { id = "job",      ar = "معلومات الوظيفة",  en = "Job Information",   icon = "ic_info"    },
    { id = "invoices", ar = "الفواتير",         en = "Invoices",          icon = "ic_invoice" },
}

local function drawNav(nx, ny, nw, nh)
    panel(nx, ny, nw, nh, false, true)
    text("LmB CUSTOMS", nx + px(18), ny + py(14), nw - px(30), py(24), GOLD, F.big, sx * 0.62, "left")
    text("ورشة السيارات الاحترافية", nx + px(18), ny + py(44), nw - px(30), py(20), MUTED, F.ar14, sx, "left", true)
    dxDrawRectangle(nx + px(16), ny + py(74), nw - px(32), py(1), GOLD_LINE)

    local by = ny + py(88)
    for i, item in ipairs(NAV) do
        local bh = py(62)
        button("nav_" .. item.id, item.ar, item.en, item.icon, nx + px(12), by, nw - px(24), bh,
            function() ui.page = item.id; ui.quote = nil; if item.id == "parts" then send("parts:list") end end,
            ui.page == item.id)
        by = by + bh + py(7)
    end

    button("nav_close", "إغلاق القائمة", "Close Menu", "ic_close", nx + px(12), ny + nh - py(74), nw - px(24), py(58),
        function() ui.close() end, false)
end

local MENU = {
    { id = "repair",  ar = "إصلاح المركبات",  en = "Repair Your Vehicle",   icon = "ic_repair"  },
    { id = "upgrade", ar = "ترقية المركبات",  en = "Upgrade Your Vehicle",  icon = "ic_upgrade" },
    { id = "paint",   ar = "تعديل الألوان",   en = "Modify Vehicle Colors", icon = "ic_paint"   },
    { id = "parts",   ar = "تركيب قطع",       en = "Install Parts",         icon = "ic_parts"   },
    { id = "tow",     ar = "سحب المركبات",    en = "Tow Vehicles",          icon = "ic_tow"     },
    { id = "job",     ar = "معلومات الوظيفة", en = "Job Information",       icon = "ic_info"    },
}

local function menuButton(id, ar, en, iconName, x, y, w, h, fn)
    local hov = hit(id, x, y, w, h, fn)
    dxDrawImage(x - px(8), y - py(8), w + px(16), h + py(16), T.glow, 0, 0, 0,
        hov and tocolor(212, 175, 90, 115) or tocolor(0, 0, 0, 0))
    dxDrawRectangle(x, y, w, h, hov and tocolor(52, 45, 32, 246) or tocolor(24, 25, 30, 240))
    dxDrawRectangle(x, y, py(2), h, hov and GOLD or GOLD_LINE)
    dxDrawRectangle(x, y + h - py(1), w, py(1), tocolor(212, 175, 90, 55))
    icon(iconName, x + px(16), y + h / 2 - px(16), px(32), hov and GOLD or tocolor(212, 175, 90, 210))
    text(ar, x + px(60), y + py(10), w - px(130), py(28), hov and WHITE or tocolor(226, 223, 217), F.ar21, sx, "left", true)
    text(en, x + px(60), y + py(42), w - px(130), py(22), hov and GOLD or MUTED, F.body, sx * 0.86, "left")
    local cxs, cys = x + w - px(28), y + h / 2
    local cc = hov and GOLD or tocolor(212, 175, 90, 175)
    dxDrawLine(cxs - px(5), cys - py(8), cxs + px(5), cys, cc, px(2))
    dxDrawLine(cxs + px(5), cys, cxs - px(5), cys + py(8), cc, px(2))
    return hov
end

local function drawMain(cx, cy, cw, ch)
    -- status strip (rank / duty / treasury / services)
    local g = px(14)
    local w = (cw - g * 3) / 4
    stat(cx, cy, w, py(84), "الرصيد النقدي", "Cash", LMB.money(ui.state.cash or 0), "ic_cash")
    stat(cx + w + g, cy, w, py(84), "الرصيد البنكي", "Bank", LMB.money(ui.state.bank or 0), "ic_home")
    stat(cx + (w + g) * 2, cy, w, py(84), "خزنة الورشة", "Treasury", LMB.money(ui.state.treasury or 0), "ic_cash")
    stat(cx + (w + g) * 3, cy, w, py(84), "خدمات منفذة", "Services", tostring(ui.state.services or 0), "ic_check")

    local bw = (cw - px(24)) / 2
    local bh = py(96)
    local gap = px(12)
    for i, item in ipairs(MENU) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local x = cx + col * (bw + gap)
        local y = cy + py(104) + row * (bh + py(10))
        menuButton("menu_" .. item.id, item.ar, item.en, item.icon, x, y, bw, bh, function()
            ui.page = item.id
            ui.quote = nil
            if item.id == "parts" then send("parts:list") end
        end)
    end

    -- duty toggle + close
    local dutyW = px(300)
    button("duty_toggle", ui.state.duty and "تسجيل الخروج من العمل" or "تسجيل الدخول للعمل",
        ui.state.duty and "Clock Out" or "Clock In", "ic_duty",
        cx, cy + ch - py(60), dutyW, py(50), function() send("job:duty") end, ui.state.duty)

    local cw2 = px(340)
    menuButton("menu_close", "إغلاق القائمة", "Close Menu", "ic_close",
        cx + cw - cw2, cy + ch - py(60), cw2, py(50), function() ui.close() end)
end

local function drawRepair(cx, cy, cw, ch)
    title("إصلاح المركبات", "REPAIR VEHICLE", cx, cy, cw)
    text("اختر نوع الإصلاح — سيظهر السعر قبل التأكيد", cx, cy + py(58), cw, py(24), MUTED, F.ar14, sx, "left", true)
    local g = px(14)
    local w = (cw - g) / 2
    local items = {
        { key = "engine", ar = "إصلاح المحرك", en = "Repair Engine", icon = "ic_engine" },
        { key = "body",   ar = "إصلاح الهيكل", en = "Repair Body",   icon = "ic_car" },
        { key = "tires",  ar = "إصلاح الإطارات", en = "Repair Tires", icon = "ic_wheel" },
        { key = "all",    ar = "إصلاح شامل",   en = "Full Repair",   icon = "ic_wrench" },
    }
    for i, it in ipairs(items) do
        local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
        local x, y = cx + col * (w + g), cy + py(104) + row * py(164)
        panel(x, y, w, py(150), false, false)
        icon(it.icon, x + px(18), y + py(18), px(38), GOLD)
        text(it.ar, x + px(68), y + py(16), w - px(80), py(30), WHITE, F.ar21, sx, "left", true)
        text(it.en, x + px(68), y + py(48), w - px(80), py(20), MUTED, F.body, sx * 0.9, "left")
        text(LMB.money(LMB.repair[it.key].price), x + px(20), y + py(84), w * 0.45, py(34), GOLD, F.bold, sx * 1.2, "left")
        button("rep_" .. it.key, "طلب الإصلاح", "Request", "ic_check", x + w - px(220), y + py(80), px(200), py(50),
            function() send("service:quote", "repair", it.key) end, ui.sel.repair == it.key)
    end
end

local function drawUpgrade(cx, cy, cw, ch)
    title("ترقية المركبات", "UPGRADE VEHICLE", cx, cy, cw)
    text("الأداء يُحسب من المواصفات الأصلية للمركبة — لا تتراكم الترقيات خطأً", cx, cy + py(58), cw, py(24), MUTED, F.ar14, sx, "left", true)
    local g, vg = px(12), py(10)
    local w = (cw - g) / 2
    for i, u in ipairs(LMB.upgrades) do
        local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
        local x = cx + col * (w + g)
        local y = cy + py(96) + row * (py(92) + vg)
        panel(x, y, w, py(92), false, false)
        icon(u.icon, x + px(14), y + py(16), px(30), GOLD)
        text(u.ar, x + px(52), y + py(8), w * 0.52, py(28), WHITE, F.ar17, sx, "left", true)
        text(u.en, x + px(52), y + py(34), w * 0.52, py(20), MUTED, F.body, sx * 0.85, "left")
        text(u.effect, x + px(52), y + py(56), w * 0.52, py(22), GREEN, F.body, sx * 0.82, "left")
        text(LMB.money(u.price), x + w - px(190), y + py(10), px(170), py(28), GOLD, F.bold, sx, "right")
        button("upg_" .. u.id, "شراء", "Buy", "ic_plus", x + w - px(190), y + py(46), px(170), py(38),
            function() send("service:quote", "upgrade", u.id) end, false)
    end
end

local function drawPaint(cx, cy, cw, ch)
    title("تعديل الألوان", "MODIFY COLORS", cx, cy, cw)
    text("اختر اللون الأساسي والثانوي — ستُعاين الألوان على المركبة مباشرة", cx, cy + py(58), cw, py(24), MUTED, F.ar14, sx, "left", true)
    local cell, gap = px(44), px(8)
    local cols = 8
    text("اللون الأساسي / Primary", cx + px(10), cy + py(96), cw * 0.5, py(24), GOLD, F.ar17, sx, "left", true)
    text("اللون الثانوي / Secondary", cx + cw * 0.5 + px(10), cy + py(96), cw * 0.5, py(24), GOLD, F.ar17, sx, "left", true)

    for i, c in ipairs(LMB.palette) do
        local side = (i - 1) < 8 and 1 or 2
        local k = ((i - 1) % 8)
        local bx = cx + px(10) + (side == 2 and cw * 0.5 or 0) + k * (cell + gap)
        local by = cy + py(130) + math.floor(k / 8) * (cell + gap)
        local col = tocolor(c.rgb[1], c.rgb[2], c.rgb[3])
        local selected = (side == 1 and ui.sel.c1 == i) or (side == 2 and ui.sel.c2 == i)
        hit("paint_" .. side .. "_" .. i, bx, by, cell, cell, function()
            if side == 1 then ui.sel.c1 = i else ui.sel.c2 = i end
            local a, b = LMB.palette[ui.sel.c1].rgb, LMB.palette[ui.sel.c2].rgb
            send("paint:preview", { c1 = { a[1], a[2], a[3] }, c2 = { b[1], b[2], b[3] } })
        end)
        dxDrawRectangle(bx - px(3), by - py(3), cell + px(6), cell + py(6), selected and GOLD or tocolor(70, 70, 76, 180))
        dxDrawRectangle(bx, by, cell, cell, col)
        if selected then dxDrawImage(bx - px(10), by - py(10), cell + px(20), cell + py(20), T.ring, 0, 0, 0, GOLD) end
    end

    panel(cx, cy + py(260), cw, py(120), false, false)
    text(LMB.palette[ui.sel.c1].ar .. "  +  " .. LMB.palette[ui.sel.c2].ar, cx + px(20), cy + py(274), cw * 0.6, py(30), WHITE, F.ar21, sx, "left", true)
    text("Champagne gold • luxury palette  |  $450", cx + px(20), cy + py(312), cw * 0.6, py(24), GOLD, F.body, sx, "left")
    button("paint_apply", "تطبيق اللون والدفع", "Apply & Pay", "ic_check", cx + cw - px(320), cy + py(290), px(300), py(66),
        function()
            local a, b = LMB.palette[ui.sel.c1].rgb, LMB.palette[ui.sel.c2].rgb
            send("service:quote", "paint", "paint", { c1 = { a[1], a[2], a[3] }, c2 = { b[1], b[2], b[3] } })
        end, false)
end

local function drawParts(cx, cy, cw, ch)
    title("تركيب القطع", "INSTALL PARTS", cx, cy, cw)
    text("يتم بناء القائمة من القطع المتوافقة فعلياً مع طراز مركبتك", cx, cy + py(58), cw, py(24), MUTED, F.ar14, sx, "left", true)
    if #ui.parts == 0 then
        text("جارٍ تحميل القطع المتوافقة… / Loading compatible parts…", cx + px(20), cy + py(120), cw - px(40), py(40), GOLD, F.ar21, sx, "left", true)
        return
    end
    local x = cx + px(6)
    local y = cy + py(96)
    for _, cat in ipairs(ui.parts) do
        local h = py(52 + math.min(6, #cat.items) * 34)
        panel(x, y, cw - px(12), h, false, false)
        icon(cat.icon, x + px(14), y + py(10), px(28), GOLD)
        text(cat.ar, x + px(52), y + py(6), cw * 0.45, py(26), WHITE, F.ar17, sx, "left", true)
        text(cat.en .. "  |  " .. LMB.money(cat.price), x + cw - px(300), y + py(8), px(280), py(24), GOLD, F.body, sx, "right")
        for j, it in ipairs(cat.items) do
            if j <= 6 then
                local iy = y + py(50) + (j - 1) * py(34)
                text(it.name, x + px(54), iy, cw * 0.42, py(30), MUTED, F.body, sx * 0.88, "left")
                button("part_" .. cat.key .. "_" .. it.id, "تثبيت", "Install", "ic_plus",
                    x + cw - px(310), iy, px(290), py(30),
                    function() send("service:quote", "part", it.id) end, false)
            end
        end
        y = y + h + py(8)
        if y > cy + ch - py(60) then break end
    end
end

local function drawTow(cx, cy, cw, ch)
    title("سحب المركبات", "TOW VEHICLES", cx, cy, cw)
    local t = ui.state.tow or {}
    panel(cx, cy + py(100), cw, py(160), false, false)
    text("شاحنة السحب", "TOW TRUCK", cx + px(20), cy + py(114), cw - px(40), py(26), GOLD, F.ar17, sx, "left", true)
    text(t.truck and "متوفرة / Available" or "غير مخرجة / Not spawned", cx + px(20), cy + py(150), cw * 0.5, py(30),
        t.truck and GREEN or MUTED, F.ar21, sx, "left", true)
    text("المركبة المربوطة: " .. tostring(t.plate or "—"), cx + px(20), cy + py(194), cw * 0.6, py(28), WHITE, F.ar17, sx, "left", true)
    text("أجرة الخدمة: " .. LMB.money(350), cx + cw - px(340), cy + py(190), px(320), py(28), GOLD, F.bold, sx, "right")

    local bw = (cw - px(42)) / 4
    button("tow_spawn", "إخراج الشاحنة", "Spawn", "ic_tow", cx + px(10), cy + py(286), bw, py(70), function() send("tow:spawn") end, false)
    button("tow_hook", "ربط مركبة", "Hook", "ic_check", cx + px(20) + bw, cy + py(286), bw, py(70), function() send("tow:hook") end, false)
    button("tow_drop", "إنزال المركبة", "Drop", "ic_exit", cx + px(30) + bw * 2, cy + py(286), bw, py(70), function() send("tow:drop") end, false)
    button("tow_store", "إعادة الشاحنة", "Store", "ic_home", cx + px(40) + bw * 3, cy + py(286), bw, py(70), function() send("tow:store") end, false)

    panel(cx, cy + py(386), cw, py(130), false, false)
    title("شروط السحب", "TOW RULES", cx + px(20), cy + py(398), cw - px(40))
    for i, line in ipairs({
        "• يجب تسجيل الدخول للعمل برتبة فني على الأقل.",
        "• المركبة يجب أن تكون مسجلة في نظام المركبات ومفرغة.",
        "• تُرسل فاتورة تلقائية لمالك المركبة عند السحب.",
        "• يتم حفظ موقع المركبة بعد إنزالها.",
    }) do
        text(line, cx + px(24), cy + py(450) + (i - 1) * py(20), cw - px(48), py(20), MUTED, F.ar14, sx, "left", true)
    end
end

local function drawJob(cx, cy, cw, ch)
    title("معلومات الوظيفة", "JOB INFORMATION", cx, cy, cw)
    local g = px(12)
    local w = (cw - g) / 3
    stat(cx, cy + py(100), w, py(110), "رتبتك الحالية", "Rank", tostring(ui.state.rankName or "—"), "ic_ranks")
    stat(cx + w + g, cy + py(100), w, py(110), "الخدمات المنفذة", "Services", tostring(ui.state.services or 0), "ic_wrench")
    stat(cx + (w + g) * 2, cy + py(100), w, py(110), "إجمالي الأرباح", "Earnings", LMB.money(ui.state.earnings or 0), "ic_cash")

    panel(cx, cy + py(230), cw, py(150), false, false)
    title("الرواتب والمكافآت", "SALARY & BONUSES", cx + px(20), cy + py(242), cw - px(40))
    text("الراتب الأساسي：$400 كل 30 دقيقة + الرتبة × $100 (نظام ng-economy).", cx + px(24), cy + py(300), cw - px(48), py(24), WHITE, F.ar14, sx, "left", true)
    text("مكافأة فورية: 20% من قيمة كل خدمة تُنفذها تُودع في حسابك البنكي.", cx + px(24), cy + py(330), cw - px(48), py(24), GOLD, F.ar14, sx, "left", true)

    local bw = (cw - px(46)) / 3
    button("job_apply", "التقديم للوظيفة", "Apply", "ic_people", cx + px(10), cy + py(404), bw, py(66), function() send("job:apply", "أود الانضمام إلى LmB Customs") end, ui.state.role == "none")
    button("job_duty", ui.state.duty and "تسجيل الخروج" or "تسجيل الدخول", ui.state.duty and "Clock Out" or "Clock In", "ic_duty", cx + px(20) + bw, cy + py(404), bw, py(66), function() send("job:duty") end, ui.state.duty)
    button("job_uniform", "تبديل الزي", "Uniform", "ic_uniform", cx + px(30) + bw * 2, cy + py(404), bw, py(66), function() send("job:uniform", not ui.state.duty) end, false)

    if ui.state.canManage then
        button("nav_hr", "إدارة الموظفين والطلبات", "HR / Management", "ic_chief", cx + px(10), cy + py(496), cw - px(20), py(62),
            function() ui.page = "hr" end, ui.page == "hr")
    end
end

local function drawInvoices(cx, cy, cw, ch)
    title("الفواتير", "INVOICES", cx, cy, cw)
    text("استخدم /lmbill [player] لإنشاء فاتورة من الخدمات المعلقة • Pay only after you approve the details",
        cx, cy + py(56), cw, py(22), MUTED, F.ar14, sx, "left", true)
    local list = ui.state.invoices or {}
    if #list == 0 then
        text("لا توجد فواتير حالياً / No invoices", cx + px(20), cy + py(120), cw - px(40), py(40), MUTED, F.ar21, sx, "left", true)
        return
    end
    for i, inv in ipairs(list) do
        local y = cy + py(96) + (i - 1) * py(72)
        if y > cy + ch - py(80) then break end
        panel(cx, y, cw, py(64), false, false)
        text("#" .. tostring(inv.id) .. "  •  " .. tostring(inv.mechanic), cx + px(18), y + py(6), cw * 0.45, py(26), WHITE, F.bold, sx, "left")
        text(tostring(inv.items), cx + px(18), y + py(32), cw * 0.55, py(24), MUTED, F.ar14, sx, "left", true)
        text(LMB.money(inv.amount), cx + cw - px(430), y + py(16), px(200), py(32), GOLD, F.bold, sx * 1.05, "right")
        if tostring(inv.status) == "pending" then
            button("pay_" .. inv.id, "دفع", "Pay", "ic_check", cx + cw - px(210), y + py(8), px(90), py(48),
                function() send("invoice:pay", inv.id) end, false)
            button("dec_" .. inv.id, "رفض", "Decline", "ic_close", cx + cw - px(110), y + py(8), px(90), py(48),
                function() send("invoice:decline", inv.id) end, false)
        else
            text(tostring(inv.status), cx + cw - px(220), y + py(16), px(200), py(30), inv.status == "paid" and GREEN or RED, F.body, sx, "right")
        end
    end
end

local function drawHR(cx, cy, cw, ch)
    title("إدارة الورشة", "MANAGEMENT", cx, cy, cw)
    text("طلبات التوظيف", "APPLICATIONS", cx + px(10), cy + py(92), cw * 0.5, py(26), GOLD, F.ar17, sx, "left", true)
    local apps = ui.state.applications or {}
    local y = cy + py(124)
    for i, a in ipairs(apps) do
        if y > cy + py(250) then break end
        panel(cx, y, cw * 0.5 - px(14), py(58), false, false)
        text(tostring(a.name), cx + px(20), y + py(4), cw * 0.28, py(24), WHITE, F.ar17, sx, "left", true)
        text(tostring(a.reason or ""):sub(1, 40), cx + px(20), y + py(28), cw * 0.28, py(22), MUTED, F.ar14, sx, "left", true)
        button("hire_" .. a.id, "قبول", "Hire", "ic_check", cx + cw * 0.5 - px(180), y + py(8), px(78), py(42),
            function() send("hr:review", { id = a.id, accept = true }) end, false)
        button("rej_" .. a.id, "رفض", "Reject", "ic_close", cx + cw * 0.5 - px(94), y + py(8), px(78), py(42),
            function() send("hr:review", { id = a.id, accept = false }) end, false)
        y = y + py(64)
    end

    local rx = cx + cw * 0.5 + px(10)
    text("الموظفون", "MEMBERS", rx, cy + py(92), cw * 0.5, py(26), GOLD, F.ar17, sx, "left", true)
    local y2 = cy + py(124)
    for i, m in ipairs(ui.state.members or {}) do
        if y2 > cy + py(330) then break end
        panel(rx, y2, cw * 0.5 - px(14), py(46), false, false)
        text(tostring(m.name) .. "  [" .. tostring(m.rank) .. "]", rx + px(14), y2 + py(6), cw * 0.24, py(24), WHITE, F.ar14, sx, "left", true)
        text("badge " .. tostring(m.badge), rx + cw * 0.25, y2 + py(6), px(90), py(24), GOLD, F.body, sx * 0.85, "left")
        button("rank_" .. m.char_id, "ترقية", "Rank+", "ic_plus", rx + cw * 0.5 - px(180), y2 + py(4), px(80), py(38),
            function() send("hr:rank", { cid = m.char_id, rank = math.min(6, tonumber(m.rank) + 1) }) end, false)
        button("fire_" .. m.char_id, "فصل", "Fire", "ic_close", rx + cw * 0.5 - px(92), y2 + py(4), px(80), py(38),
            function() send("hr:fire", m.char_id) end, false)
        y2 = y2 + py(52)
    end

    panel(cx, cy + py(420), cw, py(182), false, false)
    title("سجل الخدمات", "SERVICE LOG", cx + px(18), cy + py(430), cw - px(36))
    for i, l in ipairs(ui.state.logs or {}) do
        if i > 6 then break end
        text(tostring(l.time) .. "  |  " .. tostring(l.actor) .. "  |  " .. tostring(l.action) .. "  |  " .. tostring(l.details),
            cx + px(22), cy + py(470) + (i - 1) * py(21), cw - px(44), py(20), i % 2 == 0 and MUTED or WHITE, F.body, sx * 0.82, "left")
    end
end

-- ============================ overlays ============================

local function drawQuote()
    if not ui.quote then return end
    local q = ui.quote
    dxDrawRectangle(0, 0, screenW, screenH, tocolor(0, 0, 0, 150))
    local w, h = px(640), py(300)
    local x, y = (screenW - w) / 2, (screenH - h) / 2
    panel(x, y, w, h, false, true)
    text("تأكيد الخدمة", "CONFIRM SERVICE", x + px(24), y + py(20), w - px(48), py(34), GOLD, F.ar21, sx, "left", true)
    text(q.label, x + px(24), y + py(70), w - px(48), py(34), WHITE, F.ar21, sx, "left", true)
    text(q.detail or "", x + px(24), y + py(110), w - px(48), py(28), MUTED, F.body, sx, "left")
    dxDrawRectangle(x + px(24), y + py(150), w - px(48), py(1), GOLD_LINE)
    text("السعر النهائي", "FINAL PRICE", x + px(24), y + py(162), w * 0.5, py(26), MUTED, F.ar17, sx, "left", true)
    text(LMB.money(q.price), x + px(24), y + py(190), w * 0.5, py(46), GOLD, F.bold, sx * 1.7, "left")
    button("q_yes", "تأكيد والدفع", "Confirm & Pay", "ic_check", x + w - px(330), y + py(186), px(160), py(58),
        function() send("service:confirm", q.token); ui.quote = nil end, false)
    button("q_no", "إلغاء", "Cancel", "ic_close", x + w - px(160), y + py(186), px(140), py(58),
        function() send("paint:clear"); ui.quote = nil end, false)
end

local function drawNotify()
    local n = ui.notify
    if not n or getTickCount() > n.expire then return end
    local w, h = px(520), py(64)
    local x, y = (screenW - w) / 2, py(24)
    dxDrawRectangle(x, y, w, h, n.ok and tocolor(16, 44, 30, 235) or tocolor(54, 20, 20, 235))
    dxDrawRectangle(x, y, px(4), h, n.ok and GREEN or RED)
    text(n.text, x + px(16), y, w - px(30), h, WHITE, F.ar17, sx, "left", true)
end

-- ============================ main render ============================

addEventHandler("onClientRender", root, function()
    if not ui.open then return end
    ui.hits = {}
    dxDrawRectangle(0, 0, screenW, screenH, tocolor(0, 0, 0, 110))
    dxDrawImage(0, 0, screenW, screenH, T.grad, 0, 0, 0, tocolor(10, 12, 17, 225))

    -- brand watermark (top-right) + welcome line (bottom)
    if T.logo then dxDrawImage(screenW - px(200), py(20), px(160), py(90), T.logo) end
    text("Welcome to LmB Roleplay", screenW - px(40), screenH - py(56), px(360), py(40),
        tocolor(212, 175, 90, 215), F.ar27, sx, "right", true)

    -- title above the panel (reference layout: wrench + MECHANIC + slogan)
    local tY = Y - py(92)
    icon("ic_title", X + px(20), tY, px(52), GOLD)
    text("MECHANIC", X + px(86), tY - py(4), px(520), py(50), WHITE, F.big, sx, "left")
    text("FIX  •  UPGRADE  •  DRIVE", X + px(90), tY + py(46), px(460), py(24), GOLD, F.mid, sx * 0.72, "left")

    -- panel
    dxDrawImage(X - px(12), Y - py(12), W * sx + px(24), H * sy + py(24), T.glow, 0, 0, 0, tocolor(212, 175, 90, 55))
    dxDrawRectangle(X, Y, W * sx, H * sy, CHARCOAL)
    dxDrawRectangle(X, Y, W * sx, py(2), GOLD)
    dxDrawRectangle(X, Y + H * sy - py(1), W * sx, py(1), tocolor(212, 175, 90, 60))

    text(LMB.brand .. "  |  " .. LMB.studio, X + W * sx - px(120), Y + py(18), px(300), py(26), GOLD, F.ar17, sx, "right", true)
    button("close_x", "", "✕", "ic_close", X + W * sx - px(64), Y + py(14), px(44), py(44), function() ui.close() end, false)
    dxDrawRectangle(X + px(16), Y + py(62), W * sx - px(32), py(1), GOLD_LINE)

    local cx, cy = X + px(20), Y + py(78)
    local cw, ch = W * sx - px(40), H * sy - py(94)

    if ui.page == "main" then
        drawMain(cx, cy, cw, ch)
    else
        button("back", "رجوع", "Back", "ic_exit", cx + cw - px(150), cy, px(150), py(42),
            function() ui.page = "main" end, false)
        if ui.page == "repair" then drawRepair(cx, cy, cw, ch)
        elseif ui.page == "upgrade" then drawUpgrade(cx, cy, cw, ch)
        elseif ui.page == "paint" then drawPaint(cx, cy, cw, ch)
        elseif ui.page == "parts" then drawParts(cx, cy, cw, ch)
        elseif ui.page == "tow" then drawTow(cx, cy, cw, ch)
        elseif ui.page == "job" then drawJob(cx, cy, cw, ch)
        elseif ui.page == "invoices" then drawInvoices(cx, cy, cw, ch)
        elseif ui.page == "hr" then drawHR(cx, cy, cw, ch)
        else drawMain(cx, cy, cw, ch) end
    end

    drawQuote()
    drawNotify()
end)

addEventHandler("onClientClick", root, function(button, state)
    if not ui.open or button ~= "left" or state ~= "down" then return end
    if ui.quote then
        for i = #ui.hits, 1, -1 do
            local h = ui.hits[i]
            if h.id == "q_yes" or h.id == "q_no" then
                if inside(h.x, h.y, h.w, h.h) then h.fn() return end
            end
        end
        return
    end
    for i = #ui.hits, 1, -1 do
        local h = ui.hits[i]
        if inside(h.x, h.y, h.w, h.h) then h.fn() return end
    end
end)

-- ============================ events ============================

addEvent("lmb:open", true)
addEvent("lmb:state", true)
addEvent("lmb:notify", true)
addEvent("lmb:quote", true)
addEvent("lmb:parts", true)
addEvent("lmb:invoice", true)

addEventHandler("lmb:open", root, function(page, state)
    ui.open = true
    ui.page = page or "main"
    if state then ui.state = state end
    if not ui.cursorWasShowing then showCursor(true) end
end)

addEventHandler("lmb:state", root, function(state)
    if state then ui.state = state end
end)

addEventHandler("lmb:notify", root, function(msg, ok, title)
    ui.notify = { text = tostring(msg), ok = ok ~= false, expire = getTickCount() + 4200 }
end)

addEventHandler("lmb:quote", root, function(q)
    ui.quote = q
end)

addEventHandler("lmb:parts", root, function(list)
    ui.parts = list or {}
end)

addEventHandler("lmb:invoice", root, function(id, state)
    ui.invoiceOpen = tonumber(id)
    if state then ui.state = state end
    ui.page = "invoices"
    ui.open = true
    showCursor(true)
end)

function ui.close()
    send("paint:clear")
    ui.open = false
    ui.quote = nil
    showCursor(false)
end

bindKey("escape", "down", function()
    if ui.open then ui.close() end
end)

bindKey("F6", "down", function()
    if ui.open then
        ui.close()
    else
        triggerServerEvent("lmb:request", localPlayer)
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    showCursor(false)
end)
