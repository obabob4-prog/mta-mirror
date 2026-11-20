--[[
    lmb_police / client/c_ui.lua
    LmB POLICE DEPARTMENT - luxury DX terminal (pure DX, zero CEF)
    Charcoal glass, champagne-gold rims, heraldic badge, soft transitions.
    Pages: Dashboard | Uniform | Garage | Armoury | Ranks | Dispatch | MDT | Personnel
    Also handles the civilian application form (/applypd).
]]

local sw, sh = guiGetScreenSize()

local L = { s = 1, x = 0, y = 0 }
local function recalc()
    sw, sh = guiGetScreenSize()
    L.s = math.min(sw / 1920, sh / 1080)
    L.x = (sw - 1280 * L.s) / 2
    L.y = (sh - 800 * L.s) / 2
end
recalc()
addEventHandler("onClientRestore", root, function() setTimer(recalc, 500, 1) end)

local function PX(v) return L.x + v * L.s end
local function PY(v) return L.y + v * L.s end
local function PZ(v) return v * L.s end

local GOLD     = { 226, 190, 116 }
local GOLD_SOFT= { 246, 222, 174 }
local GOLD_DEEP= { 154, 120, 58 }
local TEXT     = { 240, 242, 246 }
local MUTE     = { 150, 155, 166 }
local DIM      = { 92, 97, 108 }
local GOOD     = { 104, 196, 128 }
local BAD      = { 208, 82, 74 }
local WARN     = { 226, 176, 84 }
local BLUE     = { 92, 150, 214 }
local PANEL    = { 18, 19, 23 }
local PANEL2   = { 25, 27, 32 }

local function C(t, a)
    return tocolor(t[1], t[2], t[3], math.floor(a or 255))
end

-- ============================================================
-- fonts
-- ============================================================
local FONT_FILES = {
    serif   = "fonts/Constantia.ttf",
    serifI  = "fonts/Constantia-Italic.ttf",
    display = "fonts/BebasNeueRegular.otf",
    body    = "fonts/Ubuntu-L.ttf",
    bold    = "fonts/Ubuntu-B.ttf",
}
local fonts = {}
local function F(kind, sizePx)
    local px = math.max(8, math.floor(sizePx * L.s))
    local key = kind .. ":" .. px
    if not fonts[key] then
        fonts[key] = dxCreateFont(":lmb_police/" .. (FONT_FILES[kind] or FONT_FILES.body), px)
            or "default-bold"
    end
    return fonts[key]
end

local function text(s, x, y, w, h, color, kind, size, align, noClip, breakWord)
    dxDrawText(tostring(s or ""), PX(x), PY(y), PX(x + w), PY(y + h), color, 1,
        F(kind or "body", size or 14), align or "left", "center",
        noClip ~= true, breakWord == true, false)
end

-- ============================================================
-- textures
-- ============================================================
local TEX = {}
local ICONS = { "ic_dash", "ic_uniform", "ic_car", "ic_armory", "ic_ranks", "ic_radio",
    "ic_mdt", "ic_people", "ic_enter", "ic_exit", "ic_duty", "ic_cells", "ic_chief",
    "ic_lock", "ic_close", "ic_check", "ic_plus", "ic_minus", "ic_search", "ic_shield" }

local function loadTextures()
    TEX.badge = dxCreateTexture(":lmb_police/ui/pd_badge.png", "argb", true, "clamp")
    TEX.glow  = dxCreateTexture(":lmb_police/ui/pd_glow.png", "argb", true, "clamp")
    TEX.grad  = dxCreateTexture(":lmb_police/ui/pd_grad.png", "argb", true, "clamp")
    TEX.ring  = dxCreateTexture(":lmb_police/ui/pd_ring.png", "argb", true, "clamp")
    TEX.star  = dxCreateTexture(":lmb_police/ui/pd_star.png", "argb", true, "clamp")
    TEX.icons = {}
    for _, n in ipairs(ICONS) do
        TEX.icons[n] = dxCreateTexture(":lmb_police/ui/icons/" .. n .. ".png", "argb", true, "clamp")
    end
end
addEventHandler("onClientResourceStart", resourceRoot, loadTextures)

local function icon(name, x, y, size, alpha, color, rot)
    local t = TEX.icons and TEX.icons[name]
    if not t then return end
    local c = color or GOLD
    dxDrawImage(PX(x), PY(y), PZ(size), PZ(size), t, rot or 0, 0, 0, C(c, alpha or 255))
end

-- ============================================================
-- state
-- ============================================================
local ui = {
    open = false,
    page = "dashboard",
    state = nil,
    t0 = 0,
    anim = 0,
    hits = {},
    fields = {},
    focus = nil,
    limits = {},
    hover = nil,
    tab = "apps",
    pri = 2,
    selCall = nil,
    selVeh = nil,
    mdt = nil,
    toast = {},
    apply = false,
    applyT0 = 0,
    lastClick = 0,
    lastSpawn = 0,
    scroll = 0,
}

local function nowMs() return getTickCount() end

local function resetHits()
    ui.hits = {}
end

local function zone(x, y, w, h, fn)
    ui.hits[#ui.hits + 1] = { x = PX(x), y = PY(y), w = PZ(w), h = PZ(h), fn = fn }
end

local function mouseIn(x, y, w, h)
    local mx, my = getCursorPosition()
    if not mx then return false end
    mx, my = mx * sw, my * sh
    return mx >= PX(x) and mx <= PX(x + w) and my >= PY(y) and my <= PY(y + h)
end

local function hover(x, y, w, h)
    return mouseIn(x, y, w, h)
end

-- ============================================================
-- drawing primitives
-- ============================================================
local function rect(x, y, w, h, color)
    dxDrawRectangle(PX(x), PY(y), PZ(w), PZ(h), color)
end

local function glass(x, y, w, h, a, tint)
    a = a or 255
    dxDrawRectangle(PX(x + 3), PY(y + 5), PZ(w), PZ(h), tocolor(0, 0, 0, math.floor(70 * a / 255)))
    local base = tint or PANEL
    dxDrawRectangle(PX(x), PY(y), PZ(w), PZ(h), tocolor(base[1], base[2], base[3], math.floor(238 * a / 255)))
    if TEX.grad then
        dxDrawImage(PX(x), PY(y), PZ(w), PZ(h * 0.5), TEX.grad, 0, 0, 0,
            tocolor(255, 255, 255, math.floor(14 * a / 255)))
    end
    local rim = tocolor(GOLD[1], GOLD[2], GOLD[3], math.floor(96 * a / 255))
    local rim2 = tocolor(GOLD[1], GOLD[2], GOLD[3], math.floor(34 * a / 255))
    dxDrawRectangle(PX(x), PY(y), PZ(w), 1, rim)
    dxDrawRectangle(PX(x), PY(y + h), PZ(w), 1, rim2)
    dxDrawRectangle(PX(x), PY(y), 1, PZ(h), rim2)
    dxDrawRectangle(PX(x + w), PY(y), 1, PZ(h), rim2)
end

local function pill(x, y, w, h, label, color, alpha)
    color = color or GOLD
    rect(x, y, w, h, tocolor(color[1], color[2], color[3], math.floor(26 * (alpha or 255) / 255)))
    rect(x, y, PZ(2) / PZ(1) * 2, h, C(color, alpha or 255))
    text(label, x + 8, y, w - 12, h, C(color, alpha or 255), "bold", 11)
end

local function button(x, y, w, h, label, opts, fn)
    opts = opts or {}
    local hot = hover(x, y, w, h) and ui.open
    local primary = opts.primary
    local danger = opts.danger
    local base = primary and GOLD or (danger and BAD or { 44, 46, 53 })
    local txtCol = primary and { 20, 18, 14 } or (danger and { 255, 236, 232 } or TEXT)
    local a = opts.disabled and 90 or 255

    if hot and not opts.disabled then
        if TEX.glow then
            local g = math.floor(PZ(56))
            dxDrawImage(PX(x + w / 2) - g / 2, PY(y + h / 2) - g / 2, g, g, TEX.glow,
                0, 0, 0, C(primary and GOLD_SOFT or base, 90))
        end
    end
    dxDrawRectangle(PX(x), PY(y), PZ(w), PZ(h),
        tocolor(base[1], base[2], base[3], math.floor((hot and 255 or 220) * a / 255)))
    if TEX.grad then
        dxDrawImage(PX(x), PY(y), PZ(w), PZ(h), TEX.grad, 0, 0, 0,
            tocolor(255, 255, 255, math.floor(36 * a / 255)))
    end
    local rimC = primary and GOLD_SOFT or (danger and { 236, 120, 110 } or GOLD)
    dxDrawRectangle(PX(x), PY(y), PZ(w), 1, tocolor(rimC[1], rimC[2], rimC[3], math.floor(180 * a / 255)))
    dxDrawRectangle(PX(x), PY(y + h - 1), PZ(w), 1, tocolor(0, 0, 0, math.floor(120 * a / 255)))
    if opts.icon then
        local isz = math.min(h - PZ(10) / L.s, 18)
        icon(opts.icon, x + 10, y + (h - isz) / 2, isz, a, primary and { 30, 26, 18 } or GOLD)
        text(label, x + 12 + isz, y, w - isz - 20, h, C(txtCol, a), "bold", 12, opts.align or "left")
    else
        text(label, x, y, w, h, C(txtCol, a), "bold", opts.size or 13, opts.align or "center")
    end
    if not opts.disabled and fn then zone(x, y, w, h, fn) end
    return hot
end

local function inputBox(field, x, y, w, h, placeholder, maxLen, numeric, multiline)
    local focused = ui.focus == field
    local val = ui.fields[field] or ""
    dxDrawRectangle(PX(x), PY(y), PZ(w), PZ(h), tocolor(255, 255, 255, focused and 16 or 8))
    dxDrawRectangle(PX(x), PY(y + h - 1), PZ(w), 1,
        tocolor(GOLD[1], GOLD[2], GOLD[3], focused and 200 or 60))
    if val == "" and not focused then
        text(placeholder, x + 10, y, w - 16, h, C(DIM, 220), "body", 13, "left", true, multiline == true)
    else
        local shown = val
        if focused and math.floor(nowMs() / 500) % 2 == 0 then shown = shown .. "|" end
        text(shown, x + 10, y, w - 16, h, C(TEXT, 245), "body", 13, "left", true, multiline == true)
    end
    zone(x, y, w, h, function()
        ui.focus = field
        ui.limits[field] = maxLen or 60
        ui.numeric = numeric and true or nil
    end)
end

local function bar(x, y, w, h, pct, color)
    pct = math.max(0, math.min(1, pct or 0))
    rect(x, y, w, h, tocolor(255, 255, 255, 14))
    rect(x, y, w * pct, h, C(color or GOLD, 230))
end

-- ============================================================
-- model access
-- ============================================================
local function st() return ui.state or { ranks = {}, perms = {}, can = {}, uniforms = {}, vehicles = {}, armory = {}, calls = {}, units = {}, nearby = {} } end

local function rankDef(id)
    for _, r in ipairs(PD.ranks) do if r.id == tonumber(id) then return r end end
    return PD.ranks[1]
end

local function permAllowed(key)
    local s = st()
    local need = (s.perms and s.perms[key]) or 99
    return (tonumber(s.rank) or 0) >= need
end

-- ============================================================
-- navigation
-- ============================================================
local NAV = {
    { key = "dashboard", label = "Dashboard",  icon = "ic_dash" },
    { key = "uniform",   label = "Uniform",    icon = "ic_uniform" },
    { key = "garage",    label = "Garage",     icon = "ic_car" },
    { key = "armory",    label = "Armoury",    icon = "ic_armory" },
    { key = "ranks",     label = "Ranks",      icon = "ic_ranks" },
    { key = "dispatch",  label = "Dispatch",   icon = "ic_radio" },
    { key = "mdt",       label = "MDT",        icon = "ic_mdt" },
    { key = "personnel", label = "Personnel",  icon = "ic_people", need = "reviewApps" },
}

local PAGE_META = {
    dashboard = { "DASHBOARD", "Liberty City Police Department - live operations" },
    uniform   = { "UNIFORM",   "Rank-issued dress code" },
    garage    = { "GARAGE",    "LCPD fleet - one active unit per officer" },
    armory    = { "ARMOURY",   "Equipment issue by rank and authorisation" },
    ranks     = { "RANKS",     "Nine ranks - authority and privileges" },
    dispatch  = { "DISPATCH",  "Calls, units and radio traffic" },
    mdt       = { "MDT",       "Mobile data terminal - citizen records" },
    personnel = { "PERSONNEL", "Recruitment, ranks and discipline" },
}

-- ============================================================
-- pages
-- ============================================================
local CX, CY, CW, CH = 286, 108, 966, 664

local pages = {}

-- ---------- dashboard ----------
pages.dashboard = function()
    local s = st()
    local duty = s.duty == true

    -- identity card
    local cw = 462
    glass(CX, CY, cw, 246, 255, PANEL2)
    if TEX.badge then
        dxDrawImage(PX(CX + 24), PY(CY + 22), PZ(104), PZ(104), TEX.badge, 0, 0, 0, C(GOLD_SOFT, 235))
    end
    text(s.name or "-", CX + 144, CY + 26, cw - 160, 34, C(TEXT), "serif", 27)
    text(s.rankName or "-", CX + 144, CY + 62, cw - 160, 22, C(GOLD, 255), "bold", 14)
    text("BADGE " .. tostring(s.badge or "--") .. "   -   " .. tostring(s.callsign or "--"),
        CX + 144, CY + 84, cw - 160, 18, C(MUTE, 230), "body", 12)

    local statusC = duty and GOOD or DIM
    dxDrawRectangle(PX(CX + 144), PY(CY + 108), PZ(8), PZ(8), C(statusC, 255))
    text(duty and "ON DUTY" or "OFF DUTY", CX + 158, CY + 100, 160, 22, C(statusC, 255), "bold", 12)
    text(duty and (tostring(getElementData(localPlayer, "pol.unitStatus") or "10-8")) or "10-7",
        CX + 144, CY + 122, cw - 160, 18, C(MUTE, 200), "body", 11)

    -- duty button
    button(CX + 24, CY + 176, cw - 48, 46, duty and "GO OFF DUTY" or "GO ON DUTY",
        { primary = not duty, danger = duty, icon = "ic_duty" },
        function() send("duty") end)

    -- stats
    local sx2 = CX + cw + 14
    local sw2 = CW - cw - 14
    glass(sx2, CY, sw2, 246, 255, PANEL2)
    local stats = {
        { "ARRESTS", tostring(s.stats and s.stats.arrests or 0), GOOD },
        { "FINES", PDmoney(s.stats and s.stats.finesTotal or 0), GOLD },
        { "SHIFT", hms(s.stats and s.stats.shift or 0), BLUE },
        { "SERVICE", hms(s.stats and s.stats.dutySeconds or 0), GOLD_SOFT },
    }
    for i, v in ipairs(stats) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local bx = sx2 + 16 + col * (sw2 - 32) / 2
        local by = CY + 16 + row * 108
        local bw = (sw2 - 44) / 2
        dxDrawRectangle(PX(bx), PY(by), PZ(bw), PZ(94), tocolor(255, 255, 255, 6))
        dxDrawRectangle(PX(bx), PY(by), 2, PZ(94), C(v[3], 200))
        text(v[1], bx + 14, by + 12, bw - 20, 18, C(MUTE, 230), "bold", 10)
        text(v[2], bx + 14, by + 34, bw - 20, 42, C(v[3], 255), "serif", 26)
    end

    -- quick actions
    local qy = CY + 262
    text("QUICK ACTIONS", CX, qy, 300, 20, C(GOLD, 210), "bold", 10)
    local quick = {
        { "ic_uniform", "WARDROBE", "uniform" },
        { "ic_car", "GARAGE", "garage" },
        { "ic_armory", "ARMOURY", "armory" },
        { "ic_radio", "DISPATCH", "dispatch" },
        { "ic_mdt", "MDT", "mdt" },
        { "ic_people", "PERSONNEL", "personnel" },
    }
    local qw = (CW - 5 * 10) / 6
    for i, q in ipairs(quick) do
        local qx = CX + (i - 1) * (qw + 10)
        local qqy = qy + 26
        local hot = hover(qx, qqy, qw, 84)
        dxDrawRectangle(PX(qx), PY(qqy), PZ(qw), PZ(84),
            tocolor(255, 255, 255, hot and 22 or 9))
        dxDrawRectangle(PX(qx), PY(qqy + 84 - 2), PZ(qw), 2, C(GOLD, hot and 200 or 70))
        icon(q[1], qx + qw / 2 - 13, qqy + 16, 26, hot and 255 or 210)
        text(q[2], qx, qqy + 52, qw, 20, C(hot and TEXT or MUTE, 240), "bold", 10, "center")
        zone(qx, qqy, qw, 84, function()
            if q[3] == "personnel" and not permAllowed("reviewApps") then
                notify("Command staff only.", false)
                return
            end
            openPage(q[3])
        end)
    end

    -- calls + nearby
    local by = qy + 126
    local hw = (CW - 14) / 2
    glass(CX, by, hw, 172, 255, PANEL2)
    text("ACTIVE CALLS", CX + 16, by + 10, hw - 30, 20, C(GOLD, 220), "bold", 10)
    local calls = s.calls or {}
    if #calls == 0 then
        text("No open calls. All quiet.", CX + 16, by + 44, hw - 32, 24, C(DIM, 220), "body", 12)
    else
        for i = 1, math.min(3, #calls) do
            local c = calls[i]
            local ry = by + 34 + (i - 1) * 44
            local pc = (c.priority or 1) >= 3 and BAD or ((c.priority or 1) == 2 and WARN or BLUE)
            dxDrawRectangle(PX(CX + 12), PY(ry), PZ(hw - 24), PZ(38), tocolor(255, 255, 255, 8))
            dxDrawRectangle(PX(CX + 12), PY(ry), 2, PZ(38), C(pc, 230))
            text("#" .. tostring(c.id) .. "  " .. tostring(c.title), CX + 22, ry + 3, hw - 110, 18,
                C(TEXT, 240), "bold", 11)
            text(tostring(c.details or ""), CX + 22, ry + 20, hw - 110, 16, C(MUTE, 220), "body", 10)
            text(tostring(c.status or "open"):upper(), CX + hw - 84, ry, 68, 38,
                C(c.status == "accepted" and GOOD or WARN, 230), "bold", 9, "right")
            zone(CX + 12, ry, hw - 24, 38, function() openPage("dispatch") end)
        end
    end

    local nx = CX + hw + 14
    glass(nx, by, hw, 172, 255, PANEL2)
    text("NEARBY PERSONS", nx + 16, by + 10, hw - 30, 20, C(GOLD, 220), "bold", 10)
    local near = s.nearby or {}
    if #near == 0 then
        text("Nobody within 8 metres.", nx + 16, by + 44, hw - 32, 24, C(DIM, 220), "body", 12)
    else
        for i = 1, math.min(3, #near) do
            local n = near[i]
            local ry = by + 34 + (i - 1) * 44
            dxDrawRectangle(PX(nx + 12), PY(ry), PZ(hw - 24), PZ(38), tocolor(255, 255, 255, 8))
            text(n.name, nx + 22, ry + 2, hw - 130, 18, C(TEXT, 240), "bold", 11)
            text((n.cuffed and "RESTRAINED" or "FREE") .. "  -  WANTED " .. tostring(n.wanted or 0),
                nx + 22, ry + 20, hw - 130, 15, C(n.cuffed and WARN or MUTE, 220), "body", 10)
            button(nx + hw - 96, ry + 7, 76, 24, n.cuffed and "RELEASE" or "CUFF",
                { size = 9, danger = n.cuffed }, function() send("cuff", n.charId) end)
        end
    end
end

-- ---------- uniform ----------
pages.uniform = function()
    local s = st()
    local cols = 3
    local gap = 12
    local cw = (CW - (cols - 1) * gap) / cols
    local ch = 150
    local list = s.uniforms or {}
    for i, u in ipairs(list) do
        if i > 12 then break end
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = CX + col * (cw + gap)
        local y = CY + row * (ch + gap)
        local worn = s.worn == u.key
        local hot = hover(x, y, cw, ch)
        glass(x, y, cw, ch, 255, worn and { 30, 28, 22 } or PANEL2)
        if worn then
            dxDrawRectangle(PX(x), PY(y), 3, PZ(ch), C(GOLD, 255))
        end
        text(u.name, x + 14, y + 10, cw - 28, 26, C(u.locked and DIM or TEXT, 245), "serif", 17)
        text(u.desc or "", x + 14, y + 38, cw - 28, 40, C(u.locked and DIM or MUTE, 220), "body", 10, "left", false, true)
        text("SKIN " .. tostring(u.skin or "-"), x + 14, y + 84, 120, 16, C(DIM, 220), "body", 10)
        pill(x + 14, y + 104, 92, 22, PD.rankName(u.minRank),
            u.locked and DIM or GOLD, 230)
        if u.locked then
            icon("ic_lock", x + cw - 40, y + 16, 22, 200, DIM)
            text("LOCKED", x + cw - 90, y + 108, 74, 18, C(DIM, 230), "bold", 9, "right")
        elseif worn then
            button(x + cw - 108, y + 100, 94, 30, "WORN", { disabled = true, size = 10 }, nil)
        else
            button(x + cw - 108, y + 100, 94, 30, "WEAR", { primary = true, size = 10 },
                function() send("uniform", u.key) end)
        end
    end
end

-- ---------- garage ----------
pages.garage = function()
    local s = st()
    local function releaseSelected(key)
        if not key then return end
        local t = nowMs()
        if t - ui.lastSpawn < 700 then return end
        ui.lastSpawn = t
        send("spawn", key)
    end
    local listW = 566
    local rowH = 56
    glass(CX, CY, listW, CH, 255, PANEL2)
    text("LCPD FLEET", CX + 16, CY + 10, listW - 30, 20, C(GOLD, 220), "bold", 10)
    local list = s.vehicles or {}
    for i, v in ipairs(list) do
        local y = CY + 36 + (i - 1) * (rowH + 4)
        if y + rowH > CY + CH then break end
        local locked = v.locked
        local hot = hover(CX + 10, y, listW - 20, rowH)
        dxDrawRectangle(PX(CX + 10), PY(y), PZ(listW - 20), PZ(rowH),
            tocolor(255, 255, 255, (hot and 18 or 8)))
        dxDrawRectangle(PX(CX + 10), PY(y), 2, PZ(rowH), C(locked and DIM or GOLD, 200))
        text(v.name, CX + 24, y + 4, listW - 150, 22, C(locked and DIM or TEXT, 245), "bold", 13)
        text(tostring(v.desc or ""), CX + 24, y + 26, listW - 150, 22, C(DIM, 220), "body", 10)
        text(string.upper(tostring(v.class or "")), CX + listW - 128, y + 8, 100, 16,
            C(locked and DIM or MUTE, 220), "bold", 9, "right")
        text("x" .. tostring(v.count or 0) .. "/4", CX + listW - 128, y + 30, 100, 16,
            C(MUTE, 200), "body", 10, "right")
        if locked then
            icon("ic_lock", CX + listW - 52, y + 16, 20, 180, DIM)
        else
            zone(CX + 10, y, listW - 20, rowH, function() ui.selVeh = v.key end)
        end
    end

    -- right detail
    local dx = CX + listW + 14
    local dw = CW - listW - 14
    local sel
    for _, v in ipairs(list) do if v.key == ui.selVeh then sel = v end end
    if not sel then sel = list[1] end
    glass(dx, CY, dw, 330, 255, PANEL2)
    if sel then
        if TEX.badge then
            dxDrawImage(PX(dx + dw / 2 - 34), PY(CY + 18), PZ(68), PZ(68), TEX.badge, 0, 0, 0, C(GOLD_SOFT, 200))
        end
        text(sel.name, dx + 20, CY + 96, dw - 40, 32, C(TEXT), "serif", 22, "center")
        text(tostring(sel.desc or ""), dx + 24, CY + 130, dw - 48, 44, C(MUTE, 225), "body", 11, "center", false, true)
        pill(dx + (dw - 110) / 2, CY + 180, 110, 24, PD.rankName(sel.minRank),
            sel.locked and DIM or GOLD, 235)
        text(tostring(sel.model), dx + 20, CY + 210, dw - 40, 18, C(DIM, 200), "body", 10, "center")
    end
    local cur = s.vehicle
    local yy = CY + 344
    glass(dx, yy, dw, CH - 344, 255, PANEL2)
    text("YOUR UNIT", dx + 16, yy + 10, dw - 30, 20, C(GOLD, 220), "bold", 10)
    if cur then
        text(cur.name, dx + 16, yy + 34, dw - 32, 26, C(TEXT), "serif", 18)
        text("PLATE " .. tostring(cur.plate) .. "   -   " .. hms(cur.since) .. " deployed",
            dx + 16, yy + 62, dw - 32, 18, C(MUTE, 220), "body", 10)
        text("UNITS " .. tostring(cur.count or 1) .. "/" .. tostring(cur.max or PD.maxPerPlayer or 1),
            dx + 16, yy + 80, dw - 32, 16, C(MUTE, 200), "body", 9)
        bar(dx + 16, yy + 92, dw - 32, 8, (cur.health or 0) / 1000,
            (cur.health or 0) > 400 and GOOD or BAD)
        button(dx + 16, yy + 116, (dw - 44) / 2, 40, "RETURN", { icon = "ic_exit" }, function() send("return") end)
        button(dx + 16 + (dw - 44) / 2 + 12, yy + 116, (dw - 44) / 2, 40, "REPAIR",
            { icon = "ic_check" }, function() send("repair") end)
        local canAdd = (tonumber(cur.count) or 1) < (tonumber(cur.max) or PD.maxPerPlayer or 3)
        if canAdd and sel and not sel.locked then
            button(dx + 16, yy + 176, dw - 32, 44, "RELEASE SELECTED", { primary = true, icon = "ic_car" },
                function() releaseSelected(sel.key) end)
        else
            text(canAdd and "Select an available unit above." or "Unit limit reached - return one first.",
                dx + 16, yy + 188, dw - 32, 22, C(DIM, 220), "body", 11)
        end
    else
        text("No unit deployed.", dx + 16, yy + 38, dw - 32, 22, C(DIM, 220), "body", 12)
        if sel and not sel.locked then
            button(dx + 16, yy + 76, dw - 32, 44, "RELEASE UNIT", { primary = true, icon = "ic_car" },
                function() releaseSelected(sel.key) end)
        else
            button(dx + 16, yy + 76, dw - 32, 44, "RANK LOCKED",
                { disabled = true, icon = "ic_lock" }, nil)
        end
    end
end

-- ---------- armory ----------
pages.armory = function()
    local s = st()
    local cols = 3
    local gap = 12
    local cw = (CW - (cols - 1) * gap) / cols
    local ch = 104
    local list = s.armory or {}
    for i, a in ipairs(list) do
        if i > 12 then break end
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = CX + col * (cw + gap)
        local y = CY + row * (ch + gap)
        glass(x, y, cw, ch, 255, PANEL2)
        icon(a.locked and "ic_lock" or "ic_shield", x + 14, y + 16, 26, a.locked and 150 or 220,
            a.locked and DIM or GOLD)
        text(a.name, x + 50, y + 12, cw - 64, 24, C(a.locked and DIM or TEXT, 245), "bold", 12)
        text(string.upper(tostring(a.kind or "")), x + 50, y + 34, cw - 64, 16, C(DIM, 210), "body", 9)
        pill(x + 14, y + 66, 92, 22, PD.rankName(a.minRank), a.locked and DIM or GOLD, 225)
        if a.locked then
            text("LOCKED", x + cw - 80, y + 68, 66, 18, C(DIM, 220), "bold", 9, "right")
        else
            button(x + cw - 92, y + 64, 78, 28, "TAKE", { primary = true, size = 10 },
                function() send("armory", a.key) end)
        end
    end
end

-- ---------- ranks ----------
pages.ranks = function()
    local s = st()
    local mine = tonumber(s.rank) or 0
    local rowH = 62
    glass(CX, CY, CW, CH, 255, PANEL2)
    text("RANK LADDER", CX + 18, CY + 10, 300, 20, C(GOLD, 220), "bold", 10)
    text("AUTHORITY LEVEL", CX + CW - 220, CY + 10, 200, 20, C(DIM, 200), "bold", 9, "right")
    for i, r in ipairs(PD.ranks) do
        local y = CY + 36 + (i - 1) * rowH
        local active = (r.id == mine)
        dxDrawRectangle(PX(CX + 12), PY(y), PZ(CW - 24), PZ(rowH - 4),
            tocolor(255, 255, 255, active and 22 or (i % 2 == 0 and 5 or 9)))
        if active then
            dxDrawRectangle(PX(CX + 12), PY(y), 3, PZ(rowH - 4), C(GOLD, 255))
            if TEX.glow then
                dxDrawImage(PX(CX + 26), PY(y + 2), PZ(56), PZ(56), TEX.glow, 0, 0, 0, C(GOLD, 60))
            end
        end
        -- rank chevron / number
        dxDrawRectangle(PX(CX + 26), PY(y + 12), PZ(32), PZ(32), tocolor(GOLD[1], GOLD[2], GOLD[3], active and 60 or 26))
        text(tostring(r.id), CX + 26, y + 12, 32, 32, C(GOLD, 255), "serif", 16, "center")
        text(r.name, CX + 72, y + 8, 320, 24, C(active and GOLD_SOFT or TEXT, 245), "serif", 17)
        text("BADGE PREFIX " .. r.badge .. "   -   $" .. r.pay .. " / shift", CX + 72, y + 32, 360, 18,
            C(MUTE, 210), "body", 10)
        -- permission preview
        local px2 = CX + 470
        local n = 0
        for _, p in ipairs(PD.permLabels) do
            if (PD.minRank[p.key] or 99) <= r.id then
                text(p.label:gsub(" .*", ""), px2 + n * 62, y + 16, 62, 26,
                    C(active and GOLD or MUTE, 190), "body", 8)
                n = n + 1
                if n >= 6 then break end
            end
        end
        text(i == #PD.ranks and "COMMAND" or ("+" .. tostring(PD.ranks[i + 1] and PD.ranks[i + 1].pay - r.pay or 0) .. " next"),
            CX + CW - 140, y + 16, 120, 26, C(DIM, 200), "body", 9, "right")
    end
end

-- ---------- dispatch ----------
pages.dispatch = function()
    local s = st()
    local lw = 596
    local y = CY
    glass(CX, y, lw, CH, 255, PANEL2)
    text("OPEN CALLS", CX + 16, y + 10, 200, 20, C(GOLD, 220), "bold", 10)
    local calls = s.calls or {}
    if #calls == 0 then
        text("No open calls.", CX + 16, y + 44, lw - 32, 22, C(DIM, 220), "body", 12)
    end
    for i = 1, math.min(5, #calls) do
        local c = calls[i]
        local ry = y + 34 + (i - 1) * 74
        local pc = (c.priority or 1) >= 3 and BAD or ((c.priority or 1) == 2 and WARN or BLUE)
        local sel = ui.selCall == c.id
        dxDrawRectangle(PX(CX + 10), PY(ry), PZ(lw - 20), PZ(68),
            tocolor(255, 255, 255, sel and 20 or 8))
        dxDrawRectangle(PX(CX + 10), PY(ry), 3, PZ(68), C(pc, 230))
        text("#" .. tostring(c.id) .. "  " .. tostring(c.title), CX + 22, ry + 6, lw - 190, 20,
            C(TEXT, 245), "bold", 12)
        text(tostring(c.details or ""), CX + 22, ry + 26, lw - 190, 18, C(MUTE, 215), "body", 10)
        text(tostring(c.created_by or ""), CX + 22, ry + 46, 240, 16, C(DIM, 200), "body", 9)
        text(string.upper(tostring(c.status or "open")), CX + lw - 160, ry + 6, 90, 16,
            C(c.status == "accepted" and GOOD or WARN, 230), "bold", 9, "right")
        text("P" .. tostring(c.priority or 1), CX + lw - 60, ry + 6, 40, 16, C(pc, 230), "bold", 10, "right")
        button(CX + lw - 152, ry + 30, 64, 26, "ACCEPT", { size = 9 }, function() send("call:accept", c.id) end)
        button(CX + lw - 82, ry + 30, 64, 26, "LOCATE", { size = 9 }, function() send("call:locate", c.id) end)
        zone(CX + 10, ry, lw - 20, 68, function() ui.selCall = c.id end)
    end

    -- new call form
    local fy = y + 34 + 5 * 74 + 8
    text("LOG A CALL", CX + 16, fy, 200, 18, C(GOLD, 210), "bold", 9)
    inputBox("callTitle", CX + 16, fy + 22, lw - 32, 34, "Call title (e.g. 10-31 robbery in progress)", 50)
    inputBox("callDetails", CX + 16, fy + 62, lw - 122, 34, "Details / location notes", 120)
    button(CX + lw - 100, fy + 62, 84, 34, "SEND", { primary = true, size = 10 }, function()
        if (ui.fields.callTitle or "") == "" then notify("Call needs a title.", false) return end
        send("call:create", { title = ui.fields.callTitle, details = ui.fields.callDetails, priority = ui.pri })
        ui.fields.callTitle, ui.fields.callDetails = "", ""
        ui.focus = nil
    end)
    for p = 1, 3 do
        local bx = CX + 16 + (p - 1) * 44
        local active = ui.pri == p
        dxDrawRectangle(PX(bx), PY(fy + 104), PZ(38), PZ(24),
            tocolor(active and GOLD[1] or 255, active and GOLD[2] or 255, active and GOLD[3] or 255,
                active and 220 or 18))
        text("P" .. p, bx, fy + 104, 38, 24, active and tocolor(20, 18, 14, 255) or C(MUTE, 230),
            "bold", 10, "center")
        zone(bx, fy + 104, 38, 24, function() ui.pri = p end)
    end
    text("PRIORITY", CX + 156, fy + 104, 120, 24, C(DIM, 210), "bold", 9)

    -- right column: units + emergency
    local rx = CX + lw + 14
    local rw = CW - lw - 14
    glass(rx, y, rw, 384, 255, PANEL2)
    text("UNITS ON DUTY", rx + 16, y + 10, rw - 30, 20, C(GOLD, 220), "bold", 10)
    local units = s.units or {}
    if #units == 0 then
        text("No units on duty.", rx + 16, y + 40, rw - 32, 22, C(DIM, 220), "body", 12)
    end
    for i = 1, math.min(6, #units) do
        local u = units[i]
        local ry = y + 34 + (i - 1) * 48
        dxDrawRectangle(PX(rx + 10), PY(ry), PZ(rw - 20), PZ(42), tocolor(255, 255, 255, 7))
        text(tostring(u.callsign or ""), rx + 20, ry + 3, rw - 130, 18, C(GOLD, 240), "bold", 10)
        text(tostring(u.name or ""), rx + 20, ry + 21, rw - 130, 16, C(MUTE, 220), "body", 9)
        text(tostring(u.status or "10-8"), rx + rw - 92, ry + 3, 74, 18, C(GOOD, 230), "bold", 10, "right")
        text(PD.rankName(u.rank), rx + rw - 92, ry + 21, 74, 16, C(DIM, 200), "body", 8, "right")
    end

    local ey = y + 398
    glass(rx, ey, rw, CH - 398, 255, PANEL2)
    text("EMERGENCY", rx + 16, ey + 10, rw - 30, 20, C(GOLD, 220), "bold", 10)
    button(rx + 16, ey + 36, rw - 32, 40, "REQUEST BACKUP", { icon = "ic_radio" },
        function() send("backup", "") end)
    button(rx + 16, ey + 84, rw - 32, 40, "PANIC - OFFICER DOWN", { danger = true },
        function() send("panic") end)
    text("Status", rx + 16, ey + 138, rw - 32, 18, C(DIM, 210), "bold", 9)
    local statuses = { "10-8", "10-6", "10-7", "CODE 3" }
    for i, sc in ipairs(statuses) do
        local bx = rx + 16 + ((i - 1) % 2) * ((rw - 38) / 2 + 6)
        local by2 = ey + 158 + math.floor((i - 1) / 2) * 32
        button(bx, by2, (rw - 38) / 2, 26, sc, { size = 9 }, function() send("status", sc) end)
    end
end

-- ---------- MDT ----------
local function mdtDrawRecord(x, y, w, h)
    local m = ui.mdt
    if not m then return end
    if m.mode == "record" and m.person then
        local p = m.person
        text(tostring(p.firstname) .. " " .. tostring(p.lastname), x + 16, y + 12, w - 32, 30,
            C(TEXT), "serif", 21)
        text("CID " .. tostring(p.id) .. "  -  AGE " .. tostring(p.age or "?") .. "  -  " ..
            string.upper(tostring(p.job or "unemployed")), x + 16, y + 44, w - 32, 18, C(MUTE, 220), "body", 10)
        local wl = tonumber(p.wanted) or 0
        pill(x + 16, y + 70, 104, 24, "WANTED " .. wl, wl > 0 and BAD or GOOD, 230)
        if m.online then
            pill(x + 128, y + 70, 92, 24, "ONLINE", GOOD, 230)
        else
            pill(x + 128, y + 70, 92, 24, "OFFLINE", DIM, 230)
        end
        if m.member then
            pill(x + 228, y + 70, 96, 24, "LCPD " .. tostring(m.member.badge or ""), GOLD, 230)
        end
        local fy = y + 102
        if m.jail then
            text("IN CUSTODY - " .. math.max(0, math.floor(((tonumber(m.jail.until_ts) or 0) - os.time()) / 60)) ..
                " min left", x + 16, fy, w - 32, 18, C(WARN, 240), "bold", 10)
            fy = fy + 20
        end
        text("FIELD ACTIONS", x + 16, fy, w - 32, 18, C(GOLD, 210), "bold", 9)

        ui.fields.fineAmount = ui.fields.fineAmount or "500"
        ui.fields.arrestMin = ui.fields.arrestMin or "3"
        ui.fields.fieldReason = ui.fields.fieldReason or ""
        local bw = (w - 44) / 4
        local function fbtn(bx, by, label, fn, opts)
            button(bx, by, bw, 26, label, opts or { size = 8 }, fn)
        end
        local b1 = fy + 20
        fbtn(x + 14, b1, "CUFF", function() send("cuff", m.charId) end)
        fbtn(x + 14 + (bw + 8), b1, "SEARCH", function() send("search", m.charId) end)
        fbtn(x + 14 + (bw + 8) * 2, b1, "ID", function() send("idcheck", m.charId) end)
        fbtn(x + 14 + (bw + 8) * 3, b1, "VEH CHK", function() send("vehcheck") end)
        local b2 = b1 + 30
        fbtn(x + 14, b2, "FINE", function()
            local amt = tonumber(ui.fields.fineAmount) or 0
            if amt <= 0 then notify("Enter a fine amount.", false) return end
            local reason = (ui.fields.fieldReason or "") ~= "" and ui.fields.fieldReason or "traffic violation"
            send("fine", m.charId, amt, reason)
        end, { primary = true })
        fbtn(x + 14 + (bw + 8), b2, "WANTED +", function()
            send("wanted", m.charId, math.min(PD.tuning.wantedMax, (tonumber(p.wanted) or 0) + 1))
        end)
        fbtn(x + 14 + (bw + 8) * 2, b2, "ARREST", function()
            local mins = tonumber(ui.fields.arrestMin) or 3
            local reason = (ui.fields.fieldReason or "") ~= "" and ui.fields.fieldReason or "arrest"
            local fine = tonumber(ui.fields.fineAmount) or 0
            send("arrest", m.charId, mins, reason, fine)
        end, { danger = true })
        fbtn(x + 14 + (bw + 8) * 3, b2, "IMPOUND", function() send("impound") end)

        local iw = (w - 44) / 3
        inputBox("fineAmount", x + 14, b2 + 34, iw, 32, "Fine $", 6, true)
        inputBox("arrestMin", x + 14 + iw + 6, b2 + 34, iw, 32, "Minutes", 2, true)
        inputBox("fieldReason", x + 14 + (iw + 6) * 2, b2 + 34, iw, 32, "Reason", 60)

        local ry = b2 + 76
        text("RECORD", x + 16, ry, w - 32, 18, C(GOLD, 210), "bold", 9)
        local viol = m.violations or {}
        if #viol == 0 then
            text("Clean record.", x + 16, ry + 20, w - 32, 18, C(DIM, 210), "body", 10)
        else
            for i = 1, math.min(4, #viol) do
                local v = viol[i]
                text(tostring(v.time or ""):sub(1, 10) .. "  " .. tostring(v.reason or ""),
                    x + 16, ry + 20 + (i - 1) * 20, w - 120, 18, C(TEXT, 220), "body", 9)
                text("$" .. tostring(v.fine or 0), x + w - 92, ry + 20 + (i - 1) * 20, 76, 18,
                    C(GOLD, 220), "bold", 9, "right")
            end
        end
        if #(m.vehicles or {}) > 0 then
            local vy = ry + 20 + math.min(4, #viol) * 20 + 8
            text("VEHICLES", x + 16, vy, w - 32, 18, C(GOLD, 210), "bold", 9)
            for i = 1, math.min(3, #m.vehicles) do
                local v = m.vehicles[i]
                text("MODEL " .. tostring(v.model) .. "  -  " .. tostring(v.plate), x + 16, vy + 20 + (i - 1) * 18,
                    w - 32, 16, C(MUTE, 220), "body", 9)
            end
        end
        if m.online then
            button(x + 16, y + h - 48, 130, 34, "LOCATE", { icon = "ic_search" },
                function() send("mdt:locate", m.charId) end)
        end
        if m.jail then
            button(x + 156, y + h - 48, 110, 34, "RELEASE", { danger = true },
                function() send("release", m.charId) end)
        end
        return
    end
    -- search results
    local rows = m.rows or {}
    text("RESULTS (" .. #rows .. ")", x + 16, y + 12, w - 32, 18, C(GOLD, 210), "bold", 9)
    if #rows == 0 then
        text("No citizen found for \"" .. tostring(m.query or "") .. "\".", x + 16, y + 38, w - 32, 22,
            C(DIM, 220), "body", 10)
        return
    end
    for i = 1, math.min(6, #rows) do
        local r = rows[i]
        local ry = y + 34 + (i - 1) * 42
        dxDrawRectangle(PX(x + 10), PY(ry), PZ(w - 20), PZ(36), tocolor(255, 255, 255, 8))
        dxDrawRectangle(PX(x + 10), PY(ry), 2, PZ(36), C((tonumber(r.wanted) or 0) > 0 and BAD or BLUE, 220))
        text(tostring(r.firstname) .. " " .. tostring(r.lastname), x + 20, ry + 2, w - 130, 18,
            C(TEXT, 240), "bold", 10)
        text("CID " .. tostring(r.id) .. "  -  " .. string.upper(tostring(r.job or "")) ..
            "  -  WANTED " .. tostring(r.wanted or 0), x + 20, ry + 19, w - 130, 16, C(MUTE, 220), "body", 8)
        if r.online then
            text("ONLINE", x + w - 92, ry + 2, 70, 16, C(GOOD, 230), "bold", 8, "right")
        end
        button(x + w - 84, ry + 6, 64, 24, "OPEN", { size = 9 }, function() send("mdt:record", r.id) end)
        zone(x + 10, ry, w - 20, 36, function() send("mdt:record", r.id) end)
    end
end

pages.mdt = function()
    local s = st()
    local lw = 596
    glass(CX, CY, lw, CH, 255, PANEL2)
    text("CITIZEN SEARCH", CX + 16, CY + 10, 240, 20, C(GOLD, 220), "bold", 10)
    inputBox("mdtQuery", CX + 16, CY + 36, lw - 110, 38, "Name or partial name...", 40)
    button(CX + lw - 88, CY + 36, 72, 38, "SEARCH", { primary = true, size = 10, icon = "ic_search" },
        function()
            local q = ui.fields.mdtQuery or ""
            if q ~= "" then send("mdt:search", q) end
        end)
    local y = CY + 88
    text("RECENT INCIDENTS", CX + 16, y, 240, 18, C(GOLD, 200), "bold", 9)
    local m = s.mdt or {}
    local rec = m.recent or {}
    if #rec == 0 then
        text("No incidents logged.", CX + 16, y + 24, lw - 32, 20, C(DIM, 210), "body", 10)
    end
    for i = 1, math.min(8, #rec) do
        local r = rec[i]
        local ry = y + 22 + (i - 1) * 38
        dxDrawRectangle(PX(CX + 16), PY(ry), PZ(lw - 32), PZ(32), tocolor(255, 255, 255, i % 2 == 0 and 4 or 8))
        text(tostring(r.firstname or "?") .. " " .. tostring(r.lastname or ""), CX + 24, ry + 2,
            lw - 210, 16, C(TEXT, 230), "bold", 9)
        text(tostring(r.reason or ""), CX + 24, ry + 17, lw - 210, 14, C(MUTE, 210), "body", 8)
        text("$" .. tostring(r.fine or 0), CX + lw - 120, ry, 96, 32, C(GOLD, 220), "bold", 9, "right")
    end
    local jy = y + 22 + math.min(8, #rec) * 38 + 8
    text("IN CUSTODY", CX + 16, jy, 200, 18, C(GOLD, 200), "bold", 9)
    local jailed = m.jailed or {}
    if #jailed == 0 then
        text("No prisoners.", CX + 16, jy + 20, lw - 32, 18, C(DIM, 210), "body", 10)
    else
        for i = 1, math.min(3, #jailed) do
            local r = jailed[i]
            text(tostring(r.firstname or "?") .. " " .. tostring(r.lastname or ""), CX + 16,
                jy + 20 + (i - 1) * 18, 260, 16, C(TEXT, 220), "body", 9)
            text(math.floor((tonumber(r.remaining) or 0) / 60) .. " min", CX + 300,
                jy + 20 + (i - 1) * 18, 100, 16, C(WARN, 220), "bold", 9)
            button(CX + lw - 96, jy + 18 + (i - 1) * 18, 74, 18, "RELEASE", { size = 8 },
                function() send("release", r.char_id) end)
        end
    end

    -- right panel: record / results
    local rx = CX + lw + 14
    local rw = CW - lw - 14
    glass(rx, CY, rw, CH, 255, PANEL2)
    mdtDrawRecord(rx, CY, rw, CH)
end

-- ---------- personnel ----------
pages.personnel = function()
    local s = st()
    local lw = 596
    glass(CX, CY, lw, CH, 255, PANEL2)
    -- tabs
    local tabs = { { "apps", "APPLICATIONS" }, { "roster", "ROSTER" } }
    for i, t in ipairs(tabs) do
        local bx = CX + 14 + (i - 1) * 150
        local active = ui.tab == t[1]
        dxDrawRectangle(PX(bx), PY(CY + 10), PZ(140), PZ(28),
            tocolor(active and GOLD[1] or 255, active and GOLD[2] or 255, active and GOLD[3] or 255,
                active and 40 or 10))
        text(t[2], bx, CY + 10, 140, 28, C(active and GOLD_SOFT or MUTE, 240), "bold", 10, "center")
        zone(bx, CY + 10, 140, 28, function() ui.tab = t[1] end)
    end

    if ui.tab == "apps" then
        local list = s.applications or {}
        if #list == 0 then
            text("No applications.", CX + 16, CY + 56, lw - 32, 22, C(DIM, 220), "body", 12)
        end
        for i = 1, math.min(5, #list) do
            local a = list[i]
            local ry = CY + 50 + (i - 1) * 100
            local pending = a.status == "pending"
            dxDrawRectangle(PX(CX + 10), PY(ry), PZ(lw - 20), PZ(92), tocolor(255, 255, 255, pending and 12 or 5))
            dxDrawRectangle(PX(CX + 10), PY(ry), 2, PZ(92), C(pending and WARN or DIM, 220))
            text(tostring(a.name or "?") .. "  #" .. tostring(a.id), CX + 22, ry + 6, lw - 140, 20,
                C(TEXT, 245), "bold", 11)
            text("AGE " .. tostring(a.age or "?") .. "  -  " .. tostring(a.created or ""):sub(1, 16),
                CX + 22, ry + 26, lw - 140, 16, C(MUTE, 210), "body", 9)
            text(tostring(a.motivation or ""), CX + 22, ry + 44, lw - 150, 34, C(MUTE, 220), "body", 9,
                "left", false, true)
            if pending then
                button(CX + lw - 110, ry + 8, 88, 30, "ACCEPT", { size = 9, primary = true },
                    function() send("app:review", { id = a.id, accept = true, note = ui.fields.note or "" }) end)
                button(CX + lw - 110, ry + 44, 88, 30, "REJECT", { size = 9, danger = true },
                    function() send("app:review", { id = a.id, accept = false, note = ui.fields.note or "" }) end)
                text(string.upper(tostring(a.status)), CX + 22, ry + 76, 100, 14, C(WARN, 220), "bold", 8)
            else
                text(string.upper(tostring(a.status)), CX + lw - 110, ry + 36, 88, 20,
                    C(a.status == "accepted" and GOOD or BAD, 230), "bold", 9, "right")
            end
        end
        inputBox("note", CX + 10, CY + CH - 44, lw - 20, 34, "Reviewer note (optional)", 90)
    else
        local members = s.members or {}
        text("BADGE", CX + 22, CY + 46, 70, 16, C(DIM, 210), "bold", 8)
        text("OFFICER", CX + 100, CY + 46, 240, 16, C(DIM, 210), "bold", 8)
        text("RANK", CX + lw - 216, CY + 46, 130, 16, C(DIM, 210), "bold", 8)
        text("ACTIONS", CX + lw - 84, CY + 46, 70, 16, C(DIM, 210), "bold", 8, "right")
        for i = 1, math.min(8, #members) do
            local m = members[i]
            local ry = CY + 64 + (i - 1) * 62
            dxDrawRectangle(PX(CX + 10), PY(ry), PZ(lw - 20), PZ(54), tocolor(255, 255, 255, i % 2 == 0 and 5 or 9))
            text(tostring(m.badge or ""), CX + 22, ry + 8, 70, 18, C(GOLD, 240), "bold", 10)
            text(tostring(m.firstname or "?") .. " " .. tostring(m.lastname or ""), CX + 100, ry + 6,
                240, 18, C(TEXT, 240), "bold", 10)
            text(tostring(m.callsign or ""), CX + 100, ry + 24, 240, 16, C(DIM, 200), "body", 8)
            text(PD.rankName(m.rank), CX + lw - 216, ry + 14, 130, 22, C(GOLD_SOFT, 235), "body", 10)
            -- rank +/- and fire
            local myRank = tonumber(s.rank) or 0
            local canManage = (tonumber(m.rank) or 0) < myRank
            button(CX + lw - 150, ry + 12, 28, 28, "-", { size = 12, disabled = not canManage },
                function() send("member:rank", m.char_id, (tonumber(m.rank) or 1) - 1) end)
            button(CX + lw - 118, ry + 12, 28, 28, "+", { size = 12, disabled = not canManage },
                function() send("member:rank", m.char_id, (tonumber(m.rank) or 1) + 1) end)
            button(CX + lw - 84, ry + 12, 66, 28, "FIRE", { size = 9, danger = true, disabled = not canManage },
                function() send("member:fire", m.char_id, "command decision") end)
        end
    end

    -- right: audit log
    local rx = CX + lw + 14
    local rw = CW - lw - 14
    glass(rx, CY, rw, CH, 255, PANEL2)
    text("AUDIT LOG", rx + 16, CY + 10, rw - 30, 20, C(GOLD, 220), "bold", 10)
    local logs = s.logs or {}
    for i = 1, math.min(14, #logs) do
        local g = logs[i]
        local ry = CY + 34 + (i - 1) * 42
        if ry + 40 > CY + CH then break end
        text(string.upper(tostring(g.action or "")) .. "  " .. tostring(g.target or ""),
            rx + 16, ry, rw - 32, 16, C(GOLD_SOFT, 230), "bold", 9)
        text(tostring(g.actor_name or "") .. "  -  " .. tostring(g.time or ""):sub(6, 16),
            rx + 16, ry + 17, rw - 32, 14, C(MUTE, 210), "body", 8)
        text(tostring(g.details or ""), rx + 16, ry + 29, rw - 32, 14, C(DIM, 200), "body", 8)
    end
end

-- ============================================================
-- shell
-- ============================================================
local function easeOut(t)
    t = math.max(0, math.min(1, t))
    return 1 - (1 - t) ^ 3
end

local function drawShell()
    local s = st()
    -- backdrop
    local a = math.floor(160 * ui.anim)
    dxDrawRectangle(0, 0, sw, sh, tocolor(4, 4, 6, a))
    if TEX.glow then
        local g = math.floor(sw * 0.9)
        dxDrawImage((sw - g) / 2, (sh - g) / 2, g, g, TEX.glow, 0, 0, 0,
            tocolor(GOLD[1], GOLD[2], GOLD[3], math.floor(18 * ui.anim)))
    end

    local off = (1 - ui.anim) * 24
    local px, py = PX(0), PY(0) + off

    -- panel body
    dxDrawRectangle(px + PZ(6), py + PZ(10), PZ(1280), PZ(800), tocolor(0, 0, 0, math.floor(120 * ui.anim)))
    dxDrawRectangle(px, py, PZ(1280), PZ(800), tocolor(11, 12, 15, math.floor(244 * ui.anim)))
    if TEX.grad then
        dxDrawImage(px, py, PZ(1280), PZ(320), TEX.grad, 0, 0, 0, tocolor(255, 255, 255, math.floor(10 * ui.anim)))
    end
    dxDrawRectangle(px, py, PZ(1280), 1, C(GOLD, 170 * ui.anim))
    dxDrawRectangle(px, py + PZ(800) - 1, PZ(1280), 1, C(GOLD, 40 * ui.anim))
    dxDrawRectangle(px, py, 1, PZ(800), C(GOLD, 40 * ui.anim))
    dxDrawRectangle(px + PZ(1280) - 1, py, 1, PZ(800), C(GOLD, 40 * ui.anim))

    -- sidebar
    dxDrawRectangle(px, py, PZ(262), PZ(800), tocolor(15, 16, 20, math.floor(250 * ui.anim)))
    dxDrawRectangle(px + PZ(262) - 1, py, 1, PZ(800), C(GOLD, 30 * ui.anim))

    -- brand
    if TEX.badge then
        dxDrawImage(px + PZ(28), py + PZ(26), PZ(52), PZ(52), TEX.badge, 0, 0, 0, C(GOLD_SOFT, 240 * ui.anim))
    end
    text("LmB", 90, 30, 120, 34, C(GOLD_SOFT, 250 * ui.anim), "serif", 26)
    text("POLICE DEPARTMENT", 90, 62, 170, 16, C(MUTE, 230 * ui.anim), "bold", 9)
    text("LIBERTY CITY", 90, 78, 170, 14, C(DIM, 210 * ui.anim), "body", 8)

    -- nav
    local navY = 122
    for _, item in ipairs(NAV) do
        if not item.need or permAllowed(item.need) then
            local active = ui.page == item.key
            local hot = hover(12, navY, 238, 46)
            if active or hot then
                dxDrawRectangle(px + PZ(12), py + PZ(navY), PZ(238), PZ(46),
                    tocolor(255, 255, 255, math.floor((active and 20 or 9) * ui.anim)))
            end
            if active then
                dxDrawRectangle(px + PZ(12), py + PZ(navY), PZ(3), PZ(46), C(GOLD, 255 * ui.anim))
                if TEX.glow then
                    dxDrawImage(px + PZ(6), py + PZ(navY + 2), PZ(52), PZ(42), TEX.glow, 0, 0, 0,
                        C(GOLD, 50 * ui.anim))
                end
            end
            icon(item.icon, 28, navY + 12, 22, (active and 255 or 180) * ui.anim, active and GOLD or MUTE)
            text(item.label, 62, navY, 180, 46, C(active and GOLD_SOFT or (hot and TEXT or MUTE), 245 * ui.anim),
                active and "bold" or "body", 12)
            zone(12, navY, 238, 46, function() openPage(item.key) end)
            navY = navY + 50
        end
    end

    -- sidebar footer
    text("v" .. tostring(s.version or PD.version), 28, 742, 120, 16, C(DIM, 180 * ui.anim), "body", 8)
    text("F5 / ESC  CLOSE", 28, 758, 200, 16, C(DIM, 170 * ui.anim), "body", 8)

    -- header
    local meta = PAGE_META[ui.page] or PAGE_META.dashboard
    text(meta[1], 286, 26, 500, 38, C(GOLD_SOFT, 250 * ui.anim), "serif", 30)
    text(meta[2], 288, 66, 560, 18, C(MUTE, 220 * ui.anim), "body", 10)
    dxDrawRectangle(px + PZ(286), py + PZ(92), PZ(966), 1, C(GOLD, 60 * ui.anim))

    -- officer chip
    local cxp = 1004
    text(tostring(s.name or ""), cxp, 30, 220, 20, C(TEXT, 240 * ui.anim), "bold", 11, "right")
    text(tostring(s.rankName or "") .. "  -  " .. tostring(s.badge or "--"), cxp, 48, 220, 16,
        C(GOLD, 230 * ui.anim), "body", 9, "right")
    local duty = s.duty == true
    dxDrawRectangle(px + PZ(cxp + 226), py + PZ(38), PZ(7), PZ(7), C(duty and GOOD or DIM, 255 * ui.anim))
    -- close button
    local chx = 1240
    local hotX = hover(chx, 24, 26, 26)
    if hotX then
        dxDrawRectangle(px + PZ(chx), py + PZ(24), PZ(26), PZ(26), tocolor(255, 255, 255, 20))
    end
    icon("ic_close", chx + 5, 29, 16, (hotX and 255 or 190) * ui.anim, hotX and BAD or MUTE)
    zone(chx, 24, 26, 26, function() closeUI() end)

    -- page body
    if ui.anim > 0.15 then
        local draw = pages[ui.page] or pages.dashboard
        draw()
    end
end

-- ============================================================
-- toasts
-- ============================================================
local function drawToasts()
    local t = nowMs()
    local y = sh - 90
    for i = #ui.toast, 1, -1 do
        local v = ui.toast[i]
        if t - v.t > 4200 then
            table.remove(ui.toast, i)
        end
    end
    for i = #ui.toast, 1, -1 do
        local v = ui.toast[i]
        local age = (t - v.t) / 1000
        local a = math.min(1, age * 5) * math.max(0, math.min(1, (4.2 - age) / 0.6))
        local w = 380
        local x = sw - w - 28
        local col = v.ok and GOOD or BAD
        dxDrawRectangle(x - 4, y - 12, w + 8, 44, tocolor(10, 10, 12, math.floor(225 * a)))
        dxDrawRectangle(x - 4, y - 12, 3, 44, C(col, 240 * a))
        dxDrawText(v.text, x + 10, y - 12, x + w - 10, y + 32, C(TEXT, 245 * a), 1,
            F("body", 12), "left", "center", true, false, false)
        y = y - 56
    end
end

-- ============================================================
-- open / close
-- ============================================================
function openPage(key)
    if key == "personnel" and not permAllowed("reviewApps") then
        notify("Command staff only.", false)
        return
    end
    if not ui.state then return end
    ui.page = key
    ui.anim = 0
    ui.focus = nil
    resetHits()
end

function closeUI()
    ui.open = false
    ui.focus = nil
    showCursor(false)
    guiSetInputMode("binds")
end

local function openUI(state, page)
    ui.state = state
    ui.page = page or (state and state.page) or "dashboard"
    if not ui.open then
        ui.open = true
        ui.t0 = nowMs()
        ui.anim = 0
        showCursor(true)
        guiSetInputMode("no_binds")
    end
    if page then ui.page = page end
    resetHits()
end

function send(action, a, b, c, d, e)
    triggerServerEvent("pd:action", localPlayer, action, a, b, c, d, e)
end

function notify(msg, ok)
    ui.toast[#ui.toast + 1] = { text = tostring(msg), t = nowMs(), ok = ok ~= false }
end

-- ============================================================
-- render
-- ============================================================
addEventHandler("onClientRender", root, function()
    -- clickable zones must be rebuilt every frame for whichever surface is visible
    resetHits()
    if ui.open then
        ui.anim = easeOut((nowMs() - ui.t0) / 200)
        drawShell()
    else
        ui.anim = 0
    end
    drawToasts()
    if ui.apply then
        drawApply()
    end
end)

-- ============================================================
-- application form (civilians)
-- ============================================================
local APPLY = { x = 380, y = 200, w = 560, h = 470 }

function drawApply()
    local a = math.min(1, (nowMs() - ui.applyT0) / 200)
    dxDrawRectangle(0, 0, sw, sh, tocolor(3, 3, 5, math.floor(170 * a)))
    local x, y, w, h = APPLY.x, APPLY.y, APPLY.w, APPLY.h
    glass(x, y, w, h, 255 * a, PANEL2)
    text("JOIN THE LCPD", x + 24, y + 18, w - 48, 34, C(GOLD_SOFT, 250 * a), "serif", 25)
    text("Liberty City Police Department - recruitment", x + 24, y + 54, w - 48, 18,
        C(MUTE, 220 * a), "body", 10)

    inputBox("age", x + 24, y + 88, 120, 36, "Age", 2, true)
    inputBox("phone", x + 156, y + 88, 180, 36, "Phone", 20)
    text("MOTIVATION", x + 24, y + 138, 200, 16, C(GOLD, 200 * a), "bold", 9)
    inputBox("motivation", x + 24, y + 156, w - 48, 82, "Why should the LCPD hire you?", 400, nil, true)
    text("EXPERIENCE", x + 24, y + 248, 200, 16, C(GOLD, 200 * a), "bold", 9)
    inputBox("experience", x + 24, y + 266, w - 48, 60, "Previous police / military / security work", 300, nil, true)

    button(x + 24, y + h - 62, 150, 40, "SUBMIT", { primary = true }, function()
        send("app:submit", {
            age = tonumber(ui.fields.age) or 0,
            phone = ui.fields.phone or "",
            motivation = ui.fields.motivation or "",
            experience = ui.fields.experience or "",
        })
        ui.apply = false
        closeApplyCursor()
    end)
    button(x + w - 174, y + h - 62, 150, 40, "CANCEL", {}, function()
        ui.apply = false
        closeApplyCursor()
    end)
end

local function applyCursor()
    showCursor(true)
    guiSetInputMode("no_binds")
end
function closeApplyCursor()
    if ui.open then return end
    showCursor(false)
    guiSetInputMode("binds")
end

addEvent("pd:apply", true)
addEventHandler("pd:apply", root, function()
    ui.apply = true
    ui.applyT0 = nowMs()
    ui.focus = "age"
    ui.fields = ui.fields or {}
    applyCursor()
end)

-- ============================================================
-- input
-- ============================================================
local function utf8Back(s)
    local n = #s
    if n == 0 then return s end
    n = n - 1
    while n > 0 and s:byte(n + 1) and s:byte(n + 1) >= 0x80 and s:byte(n + 1) < 0xC0 do
        n = n - 1
    end
    return s:sub(1, n)
end

addEventHandler("onClientCharacter", root, function(ch)
    if not (ui.open or ui.apply) then return end
    if not ui.focus then return end
    if not ch or ch == "" then return end
    local limit = ui.limits[ui.focus] or 60
    local cur = ui.fields[ui.focus] or ""
    if #cur >= limit then return end
    if ui.numeric and not ch:match("%d") then return end
    ui.fields[ui.focus] = cur .. ch
end)

addEventHandler("onClientKey", root, function(key, press)
    if ui.apply then
        if key == "escape" and press then
            ui.apply = false
            closeApplyCursor()
            cancelEvent()
        elseif key == "backspace" and press and ui.focus then
            ui.fields[ui.focus] = utf8Back(ui.fields[ui.focus] or "")
            cancelEvent()
        elseif key == "tab" and press then
            local order = { "age", "phone", "motivation", "experience" }
            local idx = 1
            for i, f in ipairs(order) do if f == ui.focus then idx = i break end end
            ui.focus = order[(idx % #order) + 1]
            cancelEvent()
        end
        return
    end
    if not ui.open then return end
    if key == "escape" and press then
        closeUI()
        cancelEvent()
        return
    end
    if (key == "F5" or key == "f5") and press then
        closeUI()
        cancelEvent()
        return
    end
    if key == "backspace" and press and ui.focus then
        ui.fields[ui.focus] = utf8Back(ui.fields[ui.focus] or "")
        cancelEvent()
        return
    end
    if key == "tab" and press then
        local order = { "callTitle", "callDetails", "mdtQuery", "note",
            "fineAmount", "arrestMin", "fieldReason" }
        local idx
        for i, f in ipairs(order) do if f == ui.focus then idx = i end end
        if idx then ui.focus = order[(idx % #order) + 1] else ui.focus = order[1] end
        cancelEvent()
        return
    end
    if key == "enter" and press then
        if ui.page == "mdt" and ui.focus == "mdtQuery" then
            local q = ui.fields.mdtQuery or ""
            if q ~= "" then send("mdt:search", q) end
        elseif ui.page == "dispatch" and (ui.focus == "callTitle" or ui.focus == "callDetails") then
            if (ui.fields.callTitle or "") ~= "" then
                send("call:create", { title = ui.fields.callTitle, details = ui.fields.callDetails, priority = ui.pri })
                ui.fields.callTitle, ui.fields.callDetails = "", ""
                ui.focus = nil
            end
        end
        cancelEvent()
    end
end)

addEventHandler("onClientClick", root, function(button, state, cx, cy)
    if button ~= "left" or state ~= "down" then return end
    if not (ui.open or ui.apply) then return end
    for i = #ui.hits, 1, -1 do
        local h = ui.hits[i]
        if cx >= h.x and cx <= h.x + h.w and cy >= h.y and cy <= h.y + h.h then
            if h.fn then
                local ok, err = pcall(h.fn)
                if not ok then outputDebugString("[lmb_police] click error: " .. tostring(err), 2) end
            end
            return
        end
    end
    if ui.open then ui.focus = nil end
end)

-- ============================================================
-- server events
-- ============================================================
addEvent("pd:open", true)
addEventHandler("pd:open", root, function(state)
    openUI(state, state and state.page)
end)

addEvent("pd:state", true)
addEventHandler("pd:state", root, function(state)
    ui.state = state
    if ui.open and state and state.page == "dashboard" then
        -- keep the current page, only refresh data
    end
end)

addEvent("pd:notify", true)
addEventHandler("pd:notify", root, function(msg, ok)
    notify(msg, ok == true)
end)

addEvent("pd:mdt", true)
addEventHandler("pd:mdt", root, function(payload)
    ui.mdt = payload
end)

-- ============================================================
-- HUD hint (bottom centre while on duty)
-- ============================================================
local function drawHint()
    if ui.open or ui.apply then return end
    if not PD.onDutyClient() then return end
    local txt = "F5  LCPD TERMINAL     E  INTERACT     R  RADIO"
    local w = PZ(360)
    local x = (sw - w) / 2
    local y = sh - PZ(46)
    dxDrawRectangle(x, y, w, PZ(26), tocolor(8, 9, 11, 165))
    dxDrawRectangle(x, y, w, 1, C(GOLD, 90))
    dxDrawText(txt, x, y, x + w, y + PZ(26), C(GOLD_SOFT, 200), 1, F("bold", 9), "center", "center")
end
addEventHandler("onClientRender", root, drawHint)

-- ============================================================
-- small utils used above
-- ============================================================
function PDmoney(v)
    v = math.floor(tonumber(v) or 0)
    local s = tostring(math.abs(v))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return (v < 0 and "-$" or "$") .. out
end

function hms(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if h > 0 then return h .. "h " .. m .. "m" end
    return m .. "m"
end

function PD.onDutyClient()
    return getElementData(localPlayer, "pol.duty") == true
end

-- F5 opens the terminal
bindKey("F5", "down", function()
    if ui.apply then return end
    if ui.open then closeUI() else triggerServerEvent("pd:request", localPlayer, "dashboard") end
end)
