--[[
    ng-login2 - c_login.lua - luxury DX login UI v5.0 "NEON HUE"
    Port of the approved web design (v19 preview):
      - full Lmbaw9in RP banner artwork background
      - free hue engine: primary + analogous + complementary, one click
      - small "Z" badge on the panel = ONLY control that opens the hue wheel
      - hue wheel: 9 preset swatches + rainbow slider (hidden until Z pressed)
      - color change NEVER touches the characters: original artwork pixels
        are re-drawn over the tint inside three character zones
      - long-press (steady 0.32s) or held-move (0.25s + 30px) = free 1:1 drag
      - hold-progress neon glow while the press builds up
      - luxury smoke: bursts on engage/drop/Z, edge trail while dragging
      - floating neon motes, animated gradient button
    Server contract (s_login.lua, unchanged):
        client -> triggerServerEvent ngl:login(user, pass) / ngl:register(user, pass)
        server -> ngl:status(text, ok) | ngl:loginOk | ngc:charSpawned
]]

local scrW, scrH = guiGetScreenSize()

local ui = {
    -- 2026-11-16 FIX: default CLOSED. The client never opens itself; only the
    -- server decision (ngl:open) opens the login screen. This prevents a hot
    -- restart of ng-login2 from resurrecting the frozen login UI over players
    -- who are already in the character creator.
    open        = false,
    mode        = "login",     -- "login" | "register"
    focus       = "user",      -- "user" | "pass" | "pass2"
    arabic      = false,       -- 2026-11-16: in-panel layout (EN/ع chip)
    user        = "",
    pass        = "",
    pass2       = "",
    busy        = false,
    status      = nil,         -- { text = "", ok = bool, t0 = tick }
    t0          = getTickCount(),

    -- hue engine
    hue         = 210,
    sel         = 1,           -- selected preset index
    c1          = { 232, 197, 107 }, -- primary gold (unified identity)
    c2          = { 184, 145, 43 },  -- analogous deep gold
    c3          = { 92, 110, 140 },  -- complementary steel
    tintC       = { 196, 158, 66 },  -- artwork tint
    darkC       = { 12, 14, 18 },    -- charcoal vignette

    -- wheel
    wheelOpen   = false,
    wheelT0     = 0,

    -- drag state (long-press gate)
    dragPending = false,
    dragging    = false,
    downX       = 0, downY = 0, downT = 0, holdT0 = 0,
    lastMX      = 0, lastMY = 0,
    grabX       = 0, grabY = 0,
    ox          = 0, oy = 0,          -- panel drag offset

    -- smoke / motes
    lastEmit    = 0,
    lastFrame   = getTickCount(),
    fps         = 60,          -- real measured FPS (MTA has no getFPS())
    sliderDrag  = false,
    pressHit    = nil,
}

-- fonts (Cairo fallback-safe)
local fMed, fTitle, fBig = "default", "default-bold", "default-bold"
if fileExists("html/fonts/Cairo.ttf") then
    local f = dxCreateFont("html/fonts/Cairo.ttf", 13)
    if f then fMed = f end
    local f2 = dxCreateFont("html/fonts/Cairo.ttf", 20, true)
    if f2 then fTitle = f2 end
    local f3 = dxCreateFont("html/fonts/Cairo.ttf", 17, true)
    if f3 then fBig = f3 end
end

-- ============================== hue engine ==============================
local function hslRgb(h, s, l)
    h = ((h % 360) + 360) % 360
    s, l = s / 100, l / 100
    local c = (1 - math.abs(2 * l - 1)) * s
    local hp = h / 60
    local x = c * (1 - math.abs(hp % 2 - 1))
    local r, g, b
    if hp < 1 then r, g, b = c, x, 0
    elseif hp < 2 then r, g, b = x, c, 0
    elseif hp < 3 then r, g, b = 0, c, x
    elseif hp < 4 then r, g, b = 0, x, c
    elseif hp < 5 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end
    local m = l - c / 2
    return math.floor((r + m) * 255 + 0.5), math.floor((g + m) * 255 + 0.5), math.floor((b + m) * 255 + 0.5)
end

-- cached-background state (2026-11-16): declared early so setHue can flag it
local bgRT = nil            -- render target holding the static backdrop
local bgDirty = true        -- backdrop needs (re)composition
local bgAlpha = -1          -- alpha the backdrop was composed at

local PRESET_HUES = { 210, 250, 290, 330, 0, 35, 60, 140, 180 }

local function setHue(h)
    ui.hue = ((h % 360) + 360) % 360
    local r, g, b
    ui.c1 = { hslRgb(ui.hue, 95, 60) }
    ui.c2 = { hslRgb(ui.hue + 40, 95, 62) }
    ui.c3 = { hslRgb(ui.hue + 180, 90, 55) }
    ui.tintC = { hslRgb(ui.hue, 90, 48) }
    ui.darkC = { hslRgb(ui.hue, 55, 12) }
    ui.sel = nil
    for i, ph in ipairs(PRESET_HUES) do
        if ph == ui.hue then ui.sel = i end
    end
    bgDirty = true -- static backdrop must be recomposed with the new hue
end

-- ============================== sprites (built once) ==============================
local circleTex, blobTex = nil, nil

local function buildSprites()
    if circleTex then return end
    local ok = pcall(function()
        local size = 64
        local rt = dxCreateRenderTarget(size, size, true)
        if not rt then return end
        dxSetRenderTarget(rt, true)
        local r = size / 2 - 1
        for y = 0, size - 1 do
            local dy = y - size / 2 + 0.5
            local half = math.sqrt(math.max(r * r - dy * dy, 0))
            if half > 0.5 then
                dxDrawRectangle(size / 2 - half, y, half * 2, 1, tocolor(255, 255, 255, 255))
            end
        end
        dxSetRenderTarget()
        circleTex = rt

        local bs = 128
        local brt = dxCreateRenderTarget(bs, bs, true)
        if brt then
            dxSetRenderTarget(brt, true)
            local layers = {
                { 1.00, 20 }, { 0.84, 30 }, { 0.68, 40 },
                { 0.52, 55 }, { 0.36, 75 }, { 0.20, 110 }, { 0.08, 160 },
            }
            for _, L in ipairs(layers) do
                local s = bs * L[1]
                dxDrawImage((bs - s) / 2, (bs - s) / 2, s, s, circleTex, 0, 0, 0, tocolor(255, 255, 255, L[2]))
            end
            dxSetRenderTarget()
            blobTex = brt
        end
    end)
    if not ok then circleTex, blobTex = nil, nil end
end

local function drawBlob(x, y, r, col, a)
    if not blobTex or r < 1 or a < 4 then return end
    dxSetBlendMode("add")
    dxDrawImage(x - r, y - r, r * 2, r * 2, blobTex, 0, 0, 0, tocolor(col[1], col[2], col[3], math.floor(a)))
    dxSetBlendMode("blend")
end

-- ============================== smoke engine ==============================
local puffs = {}

local function puff(x, y, big)
    puffs[#puffs + 1] = {
        x = x, y = y,
        r = (big and (12 + math.random() * 14) or (6 + math.random() * 7)) * ui.s0,
        vx = (math.random() - 0.5) * 0.8,
        vy = -(0.5 + math.random() * 1.1),
        life = 1,
        grow = 26 + math.random() * 34,
    }
    if #puffs > 40 then table.remove(puffs, 1) end -- 2026-11-16: 90 -> 40 (iGPU drag jank)
end

local function burst(x, y, n)
    for i = 1, n do puff(x, y, true) end
end

-- ============================== neon motes ==============================
local motes = {}
local function initMotes()
    motes = {}
    for i = 1, 22 do -- 2026-11-16: 42 -> 22 motes (iGPU smoothness)
        motes[i] = {
            x = math.random() * scrW, y = math.random() * scrH,
            r = (1.5 + math.random() * 3.5) * ui.s0,
            v = (0.3 + math.random() * 0.9) * ui.s0,
            drift = math.random() * 6.28, ds = 0.3 + math.random() * 0.7,
        }
    end
end

-- ============================== banner ==============================
local bannerTex = nil
local imgW, imgH = 0, 0
if fileExists("html/bg_login.jpg") then
    bannerTex = dxCreateTexture("html/bg_login.jpg")
    if bannerTex then
        imgW, imgH = dxGetMaterialSize(bannerTex)
    else
        bannerTex = "html/bg_login.jpg"
        imgW, imgH = 1280, 800
    end
end

local function artCover()
    local s = math.max(scrW / imgW, scrH / imgH)
    local aw, ah = imgW * s, imgH * s
    return (scrW - aw) / 2, (scrH - ah) / 2, aw, ah
end

-- zones of the artwork that must keep ORIGINAL colors (the characters)
local ZONES = {
    { 0.000, 0.150, 0.345, 1.000 },  -- left character (the clown)
    { 0.655, 0.170, 1.000, 1.000 },  -- right character (the man)
    { 0.430, 0.840, 0.590, 1.000 },  -- sneakers bottom center
}

local function restoreZones(alpha)
    if not bannerTex or imgW <= 0 then return end
    local ax, ay, aw, ah = artCover()
    for zi, z in ipairs(ZONES) do
        -- zones are fractions OF THE ARTWORK (the cover rect), NOT of the
        -- screen: the artwork is larger than the screen (cover crop), so
        -- screen-fraction math put the zones in wrong places and the
        -- characters stayed tinted. Map everything in artwork space:
        for step = 1, 3 do
            local e = (3 - step) * 0.022
            local fx0 = math.max(0, z[1] - e)
            local fy0 = math.max(0, z[2] - e)
            local fx1 = math.min(1, z[3] + e)
            local fy1 = math.min(1, z[4] + e)
            local x0 = ax + fx0 * aw
            local y0 = ay + fy0 * ah
            local rw = (fx1 - fx0) * aw
            local rh = (fy1 - fy0) * ah
            if rw > 2 and rh > 2 then
                local sx = math.floor(fx0 * imgW + 0.5)
                local sy = math.floor(fy0 * imgH + 0.5)
                local sw = math.min(imgW - sx, math.ceil((fx1 - fx0) * imgW))
                local sh = math.min(imgH - sy, math.ceil((fy1 - fy0) * imgH))
                if sw > 0 and sh > 0 then
                    local ra = (step == 1 and 80) or (step == 2 and 170) or 255
                    dxDrawImageSection(x0, y0, rw, rh, sx, sy, sw, sh, bannerTex,
                        0, 0, 0, tocolor(255, 255, 255, math.floor(alpha * ra / 255)))
                end
            end
        end
    end
end

-- ============================== cached backdrop (2026-11-16) ==============================
-- The static backdrop (banner + hue tint + restore zones + vignettes) was
-- redrawn FULL-SCREEN every frame: a fill rect + a 2.5MP image + several
-- image-section restores + 3 vignette rects. On weak iGPUs that is the main
-- cause of the choppy "frozen" feel. It is composed ONCE into a render
-- target and blitted per frame; recomposed only when the entrance alpha
-- moves or the hue changes.
local function composeBG(alpha)
    dxSetRenderTarget(bgRT, true)
    dxDrawRectangle(0, 0, scrW, scrH, tocolor(4, 6, 12, 255))
    if bannerTex then
        local ax, ay, aw, ah = artCover()
        dxDrawImage(ax, ay, aw, ah, bannerTex, 0, 0, 0, tocolor(255, 255, 255, math.floor(alpha)))
        -- hue tint over EVERYTHING ...
        dxDrawRectangle(0, 0, scrW, scrH, tocolor(ui.tintC[1], ui.tintC[2], ui.tintC[3], math.floor(alpha * 0.22)))
        -- ... then restore the characters to their original colors
        restoreZones(alpha)
    end
    -- tinted dark vignette (over everything, like the approved web look)
    local dc = ui.darkC
    dxDrawRectangle(0, 0, scrW, scrH * 0.10, tocolor(dc[1], dc[2], dc[3], math.floor(alpha * 0.30)))
    dxDrawRectangle(0, scrH * 0.86, scrW, scrH * 0.14, tocolor(dc[1], dc[2], dc[3], math.floor(alpha * 0.55)))
    dxDrawRectangle(0, scrH * 0.94, scrW, scrH * 0.06, tocolor(dc[1], dc[2], dc[3], math.floor(alpha * 0.75)))
    dxSetRenderTarget()
end

-- returns false when no RT could be created (caller falls back to direct draws)
local function ensureBG(alpha)
    if not bgRT then
        bgRT = dxCreateRenderTarget(scrW, scrH, false)
        if not bgRT then return false end
        bgDirty, bgAlpha = true, -1
    end
    if bgDirty or math.abs(alpha - bgAlpha) > 8 then
        composeBG(alpha)
        bgDirty, bgAlpha = false, alpha
    end
    return true
end

-- ============================== layout ==============================
ui.s0 = math.max(0.75, math.min(scrH / 800, 1.6))   -- global scale

local function entranceOffset()
    if ui.dragging then return 0 end
    local et = math.min((getTickCount() - ui.t0) / 700, 1)
    local ease = 1 - (1 - et) * (1 - et)
    return -44 * (1 - ease)
end

local function panelRect()
    local w = math.min(scrW * 0.34, 520)
    local h = scrH * 0.62
    -- 2026-11-16: clamp drag offsets so the panel ALWAYS stays fully on
    -- screen, no matter how far it is dragged (it used to vanish off-edge)
    local maxOx = (scrW - w) / 2
    local maxOy = (scrH - h) / 2
    ui.ox = math.max(-maxOx, math.min(maxOx, ui.ox))
    ui.oy = math.max(-maxOy, math.min(maxOy, ui.oy))
    local x = (scrW - w) / 2 + ui.ox
    local y = (scrH - h) / 2 + ui.oy + entranceOffset()
    return x, y, w, h
end

local function fieldRect(idx)
    local px, py, pw, ph = panelRect()
    local fw = pw * 0.78
    local fx = px + (pw - fw) / 2
    local fy = py + ph * (0.30 + idx * 0.14)
    return fx, fy, fw, ph * 0.088
end

local function tabRect(which)
    local px, py, pw, ph = panelRect()
    local tw = pw * 0.5
    local ty = py + ph * 0.145
    local th = ph * 0.075
    if which == "login" then
        return px, ty, tw, th
    end
    return px + tw, ty, tw, th
end

local function buttonRect()
    local px, py, pw, ph = panelRect()
    return px + pw * 0.11, py + ph * 0.755, pw * 0.78, ph * 0.09
end

local function zCenter()
    local px, py, pw, ph = panelRect()
    return px + pw, py
end

local function wheelCenter()
    local zx, zy = zCenter()
    return zx - 40 * ui.s0, zy + 40 * ui.s0
end

local function inRect(cx, cy, r)
    -- rect helpers return 4 values; callers wrap them as { x, y, w, h }
    if not cx or not cy or type(r) ~= "table" then return false end
    return cx >= r[1] and cx <= r[1] + r[3] and cy >= r[2] and cy <= r[2] + r[4]
end

-- 2026-11-16: EN/ع layout chip (top-right of the panel header)
local function langRect()
    local px, py, pw = panelRect()
    local w, h = 58 * ui.s0, 32 * ui.s0
    return px + pw - w - 14 * ui.s0, py + 12 * ui.s0, w, h
end

local function hitTest(cx, cy)
    if inRect(cx, cy, { langRect() }) then return "lang" end
    if inRect(cx, cy, { tabRect("login") }) then return "tabLogin" end
    if inRect(cx, cy, { tabRect("register") }) then return "tabRegister" end
    local fieldCount = (ui.mode == "register") and 3 or 2
    for i = 0, fieldCount - 1 do
        if inRect(cx, cy, { fieldRect(i) }) then
            return (i == 0 and "user" or (i == 1 and "pass" or "pass2"))
        end
    end
    if inRect(cx, cy, { buttonRect() }) then return "button" end
    return nil
end

local function overPanel(cx, cy)
    local px, py, pw, ph = panelRect()
    return cx >= px and cx <= px + pw and cy >= py and cy <= py + ph
end

local function zHit(cx, cy)
    local zx, zy = zCenter()
    return (cx - zx) ^ 2 + (cy - zy) ^ 2 <= (24 * ui.s0) ^ 2
end

local function swatchPos(i)
    local wcx, wcy = wheelCenter()
    local ang = (i - 1) / #PRESET_HUES * math.pi * 2 - math.pi / 2
    local openT = ui.wheelOpen and math.min((getTickCount() - ui.wheelT0) / 350, 1) or 0
    local c3t = 1.70158
    local ease = 1 + (c3t + 1) * ((openT - 1) ^ 3) + c3t * ((openT - 1) ^ 2)
    local R = 85 * ui.s0 * ease
    return wcx + math.cos(ang) * R, wcy + math.sin(ang) * R, R
end

local function sliderRect()
    local wcx, wcy = wheelCenter()
    local w, h = 110 * ui.s0, 14 * ui.s0
    return wcx - w / 2, wcy - h / 2, w, h
end

-- ============================== wheel actions ==============================
local function toggleWheel()
    ui.wheelOpen = not ui.wheelOpen
    ui.wheelT0 = getTickCount()
    local zx, zy = zCenter()
    burst(zx, zy, 20)
end

local function pickSwatch(i)
    local h = PRESET_HUES[i]
    if not h then return end
    setHue(h)
    local sx, sy = swatchPos(i)
    burst(sx, sy, 16)
end

local function setHueFromSlider(cx)
    local sr = { sliderRect() }
    local frac = math.max(0, math.min(1, (cx - sr[1]) / sr[3]))
    setHue(frac * 360)
end

-- ============================== drag ==============================
-- 2026-11-16: gates cut 320/250/30 -> 150/120/12 (the old 1/3-second dead
-- zone before drag engaged was the real "not smooth" feel)
local HOLD_MS, MOVE_GATE_MS, MOVE_GATE_PX = 150, 120, 12

local function arm(x, y)
    if ui.dragging or ui.dragPending then return end
    ui.dragPending = true
    ui.downX, ui.downY = x, y
    ui.downT = getTickCount()
    ui.holdT0 = ui.downT
    ui.lastMX, ui.lastMY = x, y
end

local function cancelHold()
    ui.dragPending = false
end

local function engage()
    if ui.dragging then return end
    -- 2026-11-16 v3: RELATIVE (delta) drag. We read the cursor ONCE at grab,
    -- then only track the movement DELTA afterwards. Event coords and
    -- getCursorPosition use different bases; mixing them made the panel grab
    -- beside the click point ("moves from right of the click"). Deltas cancel
    -- any basis mismatch, so the grabbed point stays exactly under the click.
    local rcx, rcy = getCursorPosition()
    if not rcx then return end
    ui.dragPending = false
    ui.dragCX, ui.dragCY = rcx, rcy
    ui.dragBaseOx, ui.dragBaseOy = ui.ox, ui.oy
    local px, py = panelRect()
    ui.grabX = rcx * scrW - px   -- kept for telemetry only
    ui.grabY = rcy * scrH - py
    ui.dragging = true
    ui.wheelOpen = false
    burst(rcx * scrW, rcy * scrH, 12)
    -- full grab-state telemetry: proves the panel anchored at the click point
    triggerServerEvent("ngl:clientLog", localPlayer,
        ("drag engaged fps=%d cursor=%.3f,%.3f panelXY=%.0f,%.0f grabOff=%.0f,%.0f")
        :format(ui.fps, rcx, rcy, px, py, ui.grabX, ui.grabY))
end

local function endDrag()
    cancelHold()
    if not ui.dragging then return end
    ui.dragging = false
    local px, py, pw, ph = panelRect()
    for i = 1, 16 do
        puff(px + math.random() * pw, py + math.random() * ph, true)
    end
end

-- ============================== server/log helpers ==============================
local function logToServer(msg)
    triggerServerEvent("ngl:clientLog", localPlayer, msg)
end

local function setStatus(text, ok)
    ui.status = { text = tostring(text), ok = ok and true or false, t0 = getTickCount() }
end

-- ============================== login logic ==============================
local FOCUS_ORDER = { user = "pass", pass = "pass2", pass2 = "user" }

-- 2026-11-17 gta4gg: remember the last successful login locally (client-side
-- XML) so the fields come prefilled next session - the player only has to
-- press LOGIN instead of retyping everything.
local SAVE_FILE = "@login_saved.xml"

local function saveCredentials(user, pass)
    local xml = fileExists(SAVE_FILE) and xmlLoadFile(SAVE_FILE) or xmlCreateFile(SAVE_FILE, "credentials")
    if not xml then return end
    local un = xmlFindChild(xml, "username", 0)
    if not un then un = xmlCreateChild(xml, "username") end
    xmlNodeSetValue(un, tostring(user or ""))
    local pw = xmlFindChild(xml, "password", 0)
    if not pw then pw = xmlCreateChild(xml, "password") end
    xmlNodeSetValue(pw, tostring(pass or ""))
    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end

local function loadCredentials()
    local user, pass = "", ""
    if fileExists(SAVE_FILE) then
        local xml = xmlLoadFile(SAVE_FILE)
        if xml then
            local un = xmlFindChild(xml, "username", 0)
            local pw = xmlFindChild(xml, "password", 0)
            user = un and xmlNodeGetValue(un) or ""
            pass = pw and xmlNodeGetValue(pw) or ""
            xmlUnloadFile(xml)
        end
    end
    return user, pass
end

local function cycleFocus()
    if ui.mode == "login" then
        ui.focus = (ui.focus == "user") and "pass" or "user"
    else
        ui.focus = FOCUS_ORDER[ui.focus] or "user"
    end
end

local function submit()
    if ui.busy then return end
    local user, pass = ui.user, ui.pass
    logToServer(("submit: mode=%s userLen=%d passLen=%d"):format(tostring(ui.mode), #user, #pass))
    if ui.mode == "login" then
        if user == "" or pass == "" then
            setStatus("Enter username and password", false)
            return
        end
        ui.busy = true
        setStatus("Checking credentials...", true)
        triggerServerEvent("ngl:login", localPlayer, tostring(user), tostring(pass))
    else
        -- 2026-11-16 bilingual: English OR Arabic letters/digits/underscore
        local _, chars = user:gsub("[^\128-\191]", "") -- UTF-8 codepoints
        if chars < 3 or chars > 20 or not user:match("^[%w\128-\255_]+$") then
            setStatus("Username: 3-20 letters/digits/underscore", false)
            return
        end
        if #pass < 5 then
            setStatus("Password must be 5+ characters", false)
            return
        end
        if pass ~= ui.pass2 then
            setStatus("Passwords do not match", false)
            return
        end
        ui.busy = true
        setStatus("Creating account...", true)
        triggerServerEvent("ngl:register", localPlayer, tostring(user), tostring(pass))
    end
end

-- ============================== keyboard input ==============================
-- 2026-11-16: in-panel Arabic layout. Typing is mapped IN LUA from the
-- physical English char to the Arabic 101 layout, so the user never has to
-- switch the Windows language in-game (that switch kills DirectInput
-- keyboard acquisition and typing dies). Arabic literals as \ddd UTF-8
-- escapes so the source file stays pure-ASCII safe.
local AR_KEYMAP = {
    q = "\216\182", w = "\215\181", e = "\216\171", r = "\217\130",
    t = "\217\129", y = "\216\186", u = "\216\185", i = "\217\135",
    o = "\216\174", p = "\216\173", ["["] = "\216\172", ["]"] = "\216\175",
    a = "\216\180", s = "\216\179", d = "\217\138", f = "\216\168",
    g = "\217\132", h = "\216\167", j = "\216\170", k = "\217\134",
    l = "\217\133", [";"] = "\217\131", ["'"] = "\216\183",
    z = "\216\166", x = "\216\161", c = "\216\164", v = "\216\177",
    b = "\217\132\216\167", n = "\217\137", m = "\216\169",
    [","] = "\217\136", ["."] = "\216\178", ["/"] = "\216\184",
}

-- 2026-11-16: UTF-8 aware field helpers. The old logic counted BYTES, so a
-- few Arabic chars (2 bytes each) filled the 20-BYTE limit and every further
-- keystroke was silently dropped = "typing impossible in the username field".
-- Backspace also removed one BYTE, corrupting half an Arabic character.
local function utf8Len(s)
    local _, n = s:gsub("[^\128-\191]", "")
    return n
end

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
    if not ui.open then return end
    -- input tracer (2026-11-16): prove events reach this handler; throttled
    if not ui._lastCharLog or getTickCount() - ui._lastCharLog > 10000 then
        ui._lastCharLog = getTickCount()
        local chatOk, chatActive = pcall(function() return isChatBoxInputActive() end)
        logToServer(("input: char='%s' focus=%s mode=%s chatActive=%s"):format(
            tostring(ch), tostring(ui.focus), tostring(guiGetInputMode()), tostring(chatActive)))
    end
    -- accept ANY printable character the engine hands us (Arabic/UTF-8
    -- included): the old [%w%p] filter silently dropped Arabic IME input,
    -- leaving the fields empty so login could never be submitted
    if not ch or ch == "" or #ch == 0 then return end
    -- 2026-11-16: in-panel layout - when the EN/ع chip is on, map the English
    -- char to its Arabic 101 counterpart (both shifts covered via lower())
    if ui.arabic then
        local mapped = AR_KEYMAP[ch:lower()]
        if mapped then ch = mapped end
    end
    if ui.focus == "user" then
        -- 2026-11-16: count CHARACTERS not bytes (Arabic = 2 bytes/char)
        if utf8Len(ui.user) < 20 then ui.user = ui.user .. ch end
    elseif ui.focus == "pass" then
        if utf8Len(ui.pass) < 64 then ui.pass = ui.pass .. ch end
    elseif ui.focus == "pass2" then
        if utf8Len(ui.pass2) < 64 then ui.pass2 = ui.pass2 .. ch end
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not ui.open or not press then return end
    -- input tracer (2026-11-16): first visible key event, throttled 10s
    if not ui._lastKeyLog or getTickCount() - ui._lastKeyLog > 10000 then
        ui._lastKeyLog = getTickCount()
        logToServer("input: key=" .. tostring(key) .. " focus=" .. tostring(ui.focus))
    end
    if key == "backspace" then
        -- 2026-11-16: UTF-8 safe - removes a WHOLE Arabic char, not half
        if ui.focus == "user" then
            ui.user = utf8Back(ui.user)
        elseif ui.focus == "pass" then
            ui.pass = utf8Back(ui.pass)
        elseif ui.focus == "pass2" then
            ui.pass2 = utf8Back(ui.pass2)
        end
        cancelEvent()
    elseif key == "F2" then
        -- 2026-11-16: keyboard backup for the EN/ع chip (no Windows switch)
        ui.arabic = not ui.arabic
        logToServer("in-panel layout (F2): " .. (ui.arabic and "Arabic" or "English"))
        cancelEvent()
    elseif key == "tab" then
        cycleFocus()
        cancelEvent()
    elseif key == "enter" then
        submit()
    end
end)

-- ============================== mouse input ==============================
addEventHandler("onClientClick", root, function(button, state, cx, cy)
    if not ui.open or button ~= "left" then return end
    if state == "down" then
        if ui.dragging then return end
        -- Z badge: the ONLY control that opens/closes the hue wheel
        if zHit(cx, cy) then
            toggleWheel()
            return
        end
        -- wheel interactions (only while open)
        if ui.wheelOpen then
            local sr = { sliderRect() }
            if inRect(cx, cy, sr) then
                ui.sliderDrag = true
                setHueFromSlider(cx)
                return
            end
            for i = 1, #PRESET_HUES do
                local sx, sy = swatchPos(i)
                if (cx - sx) ^ 2 + (cy - sy) ^ 2 <= (20 * ui.s0) ^ 2 then
                    pickSwatch(i)
                    return
                end
            end
            -- pressed outside the wheel: close it and continue normal handling
            ui.wheelOpen = false
        end
        -- panel widgets
        local hit = hitTest(cx, cy)
        if hit then
            ui.pressHit = hit
            if hit == "user" or hit == "pass" or hit == "pass2" then
                -- 2026-11-16: double-click a field to CLEAR it (removes the
                -- garbage left by the old byte-based typing bug instantly)
                if ui.lastField == hit and getTickCount() - (ui.lastFieldT or 0) < 400 then
                    ui[hit] = ""
                    logToServer("field cleared by double-click: " .. hit)
                end
                ui.lastField, ui.lastFieldT = hit, getTickCount()
                ui.focus = hit
            end
            return
        end
        -- empty panel area: arm the long-press drag
        if overPanel(cx, cy) then
            arm(cx, cy)
        end
    else -- up
        ui.sliderDrag = false
        if ui.dragging then
            endDrag()
            return
        end
        cancelHold()
        local hit = hitTest(cx, cy)
        if hit and hit == ui.pressHit and not ui.dragPending then
            if hit == "tabLogin" then
                ui.mode, ui.focus = "login", "user"
            elseif hit == "tabRegister" then
                ui.mode, ui.focus = "register", "user"
            elseif hit == "button" then
                submit()
            elseif hit == "lang" then
                -- 2026-11-16: toggle the in-panel layout (no Windows switch!)
                ui.arabic = not ui.arabic
                logToServer("in-panel layout: " .. (ui.arabic and "Arabic" or "English"))
                local lx, ly, lw, lh = langRect()
                burst(lx + lw / 2, ly + lh / 2, 8)
            end
        end
        ui.pressHit = nil
    end
end)

addEventHandler("onClientCursorMove", root, function(absX, absY)
    if not ui.open then return end
    if ui.sliderDrag then
        setHueFromSlider(absX)
        ui.lastMX, ui.lastMY = absX, absY
        return
    end
    if ui.dragPending and not ui.dragging then
        local held = getTickCount() - ui.downT
        local moved = math.abs(absX - ui.downX) + math.abs(absY - ui.downY)
        -- natural hand motion does NOT cancel: a settled hold OR a held press
        -- that then moves (after 0.25s, 30px) both engage the drag
        if held >= MOVE_GATE_MS and moved > MOVE_GATE_PX then
            engage(absX, absY)
        elseif math.abs(absX - ui.lastMX) + math.abs(absY - ui.lastMY) > 8 then
            ui.holdT0 = getTickCount()
        end
    end
    if ui.dragging then
        -- v3: panel motion is owned ONLY by the render loop (delta-based).
        -- Event coords here use a different basis - writing offsets from them
        -- is what dragged the panel away from the click point. Smoke only.
        local now = getTickCount()
        if now - ui.lastEmit > 55 then
            ui.lastEmit = now
            local px, py, pw, ph = panelRect()
            if math.random() < 0.6 then
                puff(px + math.random() * pw, (math.random() < 0.5 and py or py + ph), true)
            end
            if math.random() < 0.5 then
                puff((math.random() < 0.5 and px or px + pw), py + math.random() * ph, true)
            end
        end
    end
    ui.lastMX, ui.lastMY = absX, absY
end)

-- ============================== close / server events ==============================
local function closeLogin()
    if not ui.open then return end
    ui.open = false
    showCursor(false)
    guiSetInputMode("allow_binds")
    showChat(true)
end

addEvent("ngl:status", true)
addEventHandler("ngl:status", root, function(text, ok)
    if not ui.open then return end
    ui.busy = false
    setStatus(text, ok)
end)

addEvent("ngl:loginOk", true)
addEventHandler("ngl:loginOk", root, function()
    -- remember these credentials for the next session (gta4gg)
    pcall(saveCredentials, ui.user, ui.pass)
    setStatus("Welcome! Spawning...", true)
    setTimer(closeLogin, 700, 1)
end)

-- server-forced close (2026-11-16): used by admin force-login so the UI can
-- never stay open over a spawned player (root cause of the "frozen" screen)
addEvent("ngl:forceClose", true)
addEventHandler("ngl:forceClose", root, function()
    logToServer("forceClose: closing login UI by server request")
    closeLogin()
end)

addEvent("ngc:charSpawned", true)
addEventHandler("ngc:charSpawned", root, function()
    closeLogin()
end)

-- ============================== rendering ==============================
local function lerp(a, b, t) return a + (b - a) * t end

local function mixCol(c1, c2, t, a)
    return tocolor(math.floor(lerp(c1[1], c2[1], t)), math.floor(lerp(c1[2], c2[2], t)),
                   math.floor(lerp(c1[3], c2[3], t)), math.floor(a))
end

local function textGlow(txt, x1, y1, x2, y2, col, a, scale, font, alignX, alignY)
    dxDrawText(txt, x1, y1, x2, y2, tocolor(col[1], col[2], col[3], math.floor(a * 0.35)),
        scale, font, alignX, alignY, false, false, false, true)
    dxDrawText(txt, x1, y1, x2, y2, tocolor(255, 255, 255, math.floor(a)), scale, font, alignX, alignY)
end

function renderUI()
    local now = getTickCount()
    local dt = math.min((now - ui.lastFrame) / 1000, 0.05)
    ui.lastFrame = now
    local c1, c2 = ui.c1, ui.c2

    -- entrance animation
    local enterT = (now - ui.t0) / 700
    if ui.dragging then enterT = 1 end
    enterT = math.min(enterT, 1)
    local enterEase = 1 - (1 - enterT) * (1 - enterT)
    local alpha = enterEase * 255

    -- smooth drag follow v2 (2026-11-16): sample the REAL cursor every frame
    -- (immune to event gaps and stale grab points), clamp to screen, and ease
    -- with a fast constant - panel and cursor move as one, zero relative lag
    if ui.dragging then
        -- v3: delta-based follow - ONLY source of panel motion while dragging
        -- (same basis as the grab read; event-coord writes were removed because
        -- their basis mismatch dragged the panel away from the click point)
        local rcx, rcy = getCursorPosition()
        if rcx then
            local w = math.min(scrW * 0.34, 520)
            local h = scrH * 0.62
            local maxOx, maxOy = (scrW - w) / 2, (scrH - h) / 2
            local tox = math.max(-maxOx, math.min(maxOx,
                ui.dragBaseOx + (rcx - ui.dragCX) * scrW))
            local toy = math.max(-maxOy, math.min(maxOy,
                ui.dragBaseOy + (rcy - ui.dragCY) * scrH))
            local k = math.min(dt * 50, 1)
            ui.ox = ui.ox + (tox - ui.ox) * k
            ui.oy = ui.oy + (toy - ui.oy) * k
        end
    end

    -- ===== background: cached full-screen backdrop (one blit) =====
    if not ensureBG(alpha) then
        -- fallback: direct draws when the render target is unavailable
        dxDrawRectangle(0, 0, scrW, scrH, tocolor(4, 6, 12, 255))
        if bannerTex then
            local ax, ay, aw, ah = artCover()
            dxDrawImage(ax, ay, aw, ah, bannerTex, 0, 0, 0, tocolor(255, 255, 255, math.floor(alpha)))
            dxDrawRectangle(0, 0, scrW, scrH, tocolor(ui.tintC[1], ui.tintC[2], ui.tintC[3], math.floor(alpha * 0.22)))
            restoreZones(alpha)
        end
        local dc = ui.darkC
        dxDrawRectangle(0, 0, scrW, scrH * 0.10, tocolor(dc[1], dc[2], dc[3], math.floor(alpha * 0.30)))
        dxDrawRectangle(0, scrH * 0.86, scrW, scrH * 0.14, tocolor(dc[1], dc[2], dc[3], math.floor(alpha * 0.55)))
        dxDrawRectangle(0, scrH * 0.94, scrW, scrH * 0.06, tocolor(dc[1], dc[2], dc[3], math.floor(alpha * 0.75)))
    else
        dxDrawImage(0, 0, scrW, scrH, bgRT)
    end

    -- ===== neon motes (behind the panel) - skipped on low fps for smoothness =====
    -- NOTE: MTA has no getFPS() - we count frames ourselves (see draw loop below)
    -- 2026-11-16: threshold raised 24 -> 30, and motes pause while dragging
    -- (GPU headroom for the smooth drag follow)
    if ui.fps >= 30 and not ui.dragging then
        for _, m in ipairs(motes) do
            m.y = m.y - m.v
            m.drift = m.drift + m.ds * 0.01
            m.x = m.x + math.sin(m.drift) * 0.5
            if m.y < -16 then
                m.y = scrH + 16
                m.x = math.random() * scrW
            end
            local tw = 0.5 + 0.5 * math.sin(m.drift * 2.2)
            drawBlob(m.x, m.y, m.r * 5, c1, alpha * 0.45 * tw)
        end
    end

    -- ===== steady-hold engagement check (no movement needed) =====
    if ui.dragPending and not ui.dragging and (now - ui.downT) >= HOLD_MS and (now - ui.holdT0) >= HOLD_MS then
        engage(ui.downX, ui.downY)
    end

    local px, py, pw, ph = panelRect()

    -- ===== EN/ع layout chip (2026-11-16): click to switch typing language
    -- inside the panel - never touch the Windows language in-game =====
    do
        local lx, ly, lw, lh = langRect()
        local on = ui.arabic
        local chipA = math.floor(alpha * 0.18)
        dxDrawRectangle(lx, ly, lw, lh, tocolor(255, 255, 255, chipA))
        local barR, barG, barB = on and 120 or 90, on and 220 or 150, on and 140 or 255
        dxDrawRectangle(lx, ly, lw, 2, tocolor(barR, barG, barB, math.floor(alpha)))
        dxDrawRectangle(lx, ly + lh - 2, lw, 2, tocolor(barR, barG, barB, math.floor(alpha)))
        local label = on and "\216\185" or "EN"
        dxDrawText(label, lx, ly, lx + lw, ly + lh,
            tocolor(235, 242, 255, math.floor(alpha * (on and 1 or 0.85))),
            1.1 * ui.s0, "default-bold", "center", "center")
    end

    -- ===== hold-progress glow / dragging glow =====
    local glowA = 0
    if ui.dragPending then
        glowA = math.min((now - ui.holdT0) / HOLD_MS, 1)
    elseif ui.dragging then
        glowA = 1
    end
    if glowA > 0.02 then
        for g = 1, 5 do
            local off = g * 3 + glowA * 6
            dxSetBlendMode("add")
            dxDrawRectangle(px - off, py - off, pw + off * 2, ph + off * 2,
                tocolor(c1[1], c1[2], c1[3], math.floor(alpha * 0.055 * glowA * (6 - g))))
            dxSetBlendMode("blend")
        end
    end

    -- ===== glass panel =====
    dxDrawRectangle(px + 6, py + 8, pw, ph, tocolor(0, 0, 0, math.floor(alpha * 0.45)))  -- drop shadow
    dxDrawRectangle(px - 2, py - 2, pw + 4, ph + 4,
        tocolor(c1[1], c1[2], c1[3], math.floor(alpha * 0.80)))                          -- neon border
    dxDrawRectangle(px, py, pw, ph, tocolor(9, 12, 22, math.floor(alpha * 0.92)))        -- glass body
    dxDrawRectangle(px, py, pw, ph, tocolor(c1[1], c1[2], c1[3], math.floor(alpha * 0.05)))

    -- ===== title =====
    local title = (ui.mode == "login") and "Lmbaw9in RP" or "CREATE ACCOUNT"
    textGlow(title, px, py + ph * 0.025, px + pw, py + ph * 0.095, c1, alpha, 1.0, fTitle, "center", "center")
    -- accent separator line (animated a1 -> a2 sweep)
    local lx0, lx1 = px + pw * 0.2, px + pw * 0.8
    local lw = lx1 - lx0
    local segs = 20
    for i = 0, segs - 1 do
        local u = ((i / (segs - 1)) * 0.6 + (now / 3000) % 1 * 0.4) % 1
        local cc = (u < 0.5) and mixCol(c1, c2, u * 2, alpha * 0.9) or mixCol(c2, c1, (u - 0.5) * 2, alpha * 0.9)
        dxDrawRectangle(lx0 + lw * i / segs, py + ph * 0.105, lw / segs + 1, 2, cc)
    end

    -- ===== tabs =====
    for _, t in ipairs({ "login", "register" }) do
        local tx, ty, tw, th = tabRect(t)
        local active = (ui.mode == t)
        if active then
            dxDrawRectangle(tx, ty, tw, th, mixCol(c1, c2, 0.3, alpha * 0.30))
            dxDrawRectangle(tx + 1, ty + 1, tw - 2, th - 2, tocolor(12, 16, 26, math.floor(alpha * 0.35)))
            dxDrawRectangle(tx, ty, tw, 1, tocolor(c1[1], c1[2], c1[3], alpha))
            dxDrawRectangle(tx, ty + th - 1, tw, 1, tocolor(c1[1], c1[2], c1[3], alpha))
            dxDrawRectangle(tx, ty, 1, th, tocolor(c1[1], c1[2], c1[3], alpha))
            dxDrawRectangle(tx + tw - 1, ty, 1, th, tocolor(c1[1], c1[2], c1[3], alpha))
        else
            dxDrawRectangle(tx, ty, tw, th, tocolor(255, 255, 255, math.floor(alpha * 0.05)))
        end
        local label = (t == "login") and "LOGIN" or "NEW ACCOUNT"
        if active then
            textGlow(label, tx, ty, tx + tw, ty + th, c1, alpha, 1.0, fBig, "center", "center")
        else
            dxDrawText(label, tx, ty, tx + tw, ty + th,
                tocolor(170, 185, 210, math.floor(alpha * 0.6)), 1.0, fBig, "center", "center")
        end
    end

    -- ===== fields =====
    local fieldCount = (ui.mode == "register") and 3 or 2
    local values = { user = ui.user, pass = ui.pass, pass2 = ui.pass2 }
    local labels = { user = "USERNAME", pass = "PASSWORD", pass2 = "CONFIRM PASSWORD" }
    for i = 0, fieldCount - 1 do
        local name = (i == 0 and "user" or (i == 1 and "pass" or "pass2"))
        local fx, fy, fw, fh = fieldRect(i)
        local focused = (ui.focus == name)
        dxDrawRectangle(fx, fy, fw, fh, tocolor(6, 9, 18, math.floor(alpha * 0.72)))
        local bc = focused and c1 or { 255, 255, 255 }
        local bA = focused and alpha or alpha * 0.25
        dxDrawRectangle(fx, fy, fw, 1, tocolor(bc[1], bc[2], bc[3], math.floor(bA)))
        dxDrawRectangle(fx, fy + fh - 1, fw, 1, tocolor(bc[1], bc[2], bc[3], math.floor(bA)))
        dxDrawRectangle(fx, fy, 1, fh, tocolor(bc[1], bc[2], bc[3], math.floor(bA)))
        dxDrawRectangle(fx + fw - 1, fy, 1, fh, tocolor(bc[1], bc[2], bc[3], math.floor(bA)))
        if focused then
            dxDrawRectangle(fx - 1, fy - 1, fw + 2, fh + 2,
                tocolor(c1[1], c1[2], c1[3], math.floor(alpha * 0.28)))
        end
        dxDrawText(labels[name], fx, fy - fh * 0.62, fx + fw, fy,
            tocolor(150, 165, 190, math.floor(alpha * 0.8)), 0.9, fMed, "left", "center")
        local shown = values[name]
        if name ~= "user" then shown = string.rep("*", #shown) end
        local caret = ""
        if focused and math.floor((now % 900) / 450) == 0 then caret = "|" end
        dxDrawText(shown .. caret, fx + 12, fy, fx + fw - 12, fy + fh,
            tocolor(240, 244, 255, alpha), 1.0, fMed, "left", "center")
    end

    -- ===== main button: animated neon gradient =====
    local bx, by, bw, bh = buttonRect()
    local ccx, ccy = getCursorPosition()
    if ccx then ccx, ccy = ccx * scrW, ccy * scrH end
    local hovered = ccx and inRect(ccx, ccy, { buttonRect() })
    local btnLabel = (ui.mode == "login") and "LOGIN" or "CREATE ACCOUNT"
    if ui.busy then
        btnLabel = "PLEASE WAIT" .. string.rep(".", math.floor((now / 350) % 4) + 1)
    end
    if hovered then
        dxSetBlendMode("add")
        dxDrawRectangle(bx - 3, by - 3, bw + 6, bh + 6,
            tocolor(c1[1], c1[2], c1[3], math.floor(alpha * 0.22)))
        dxSetBlendMode("blend")
    end
    dxDrawRectangle(bx + 2, by + 3, bw, bh, tocolor(0, 0, 0, math.floor(alpha * 0.4)))
    local segN = 24
    local phase = (now % 3600) / 3600 * 2
    for i = 0, segN - 1 do
        local u = (i / (segN - 1) + phase) % 2
        local cc = (u < 1) and mixCol(c1, c2, u, alpha) or mixCol(c2, c1, u - 1, alpha)
        dxDrawRectangle(bx + bw * i / segN, by, bw / segN + 1, bh, cc)
    end
    if hovered then
        dxSetBlendMode("add")
        dxDrawRectangle(bx, by, bw, bh, tocolor(255, 255, 255, math.floor(alpha * 0.12)))
        dxSetBlendMode("blend")
    end
    dxDrawRectangle(bx, by, bw, 1, tocolor(255, 255, 255, math.floor(alpha * 0.5)))
    dxDrawText(btnLabel, bx, by, bx + bw, by + bh,
        tocolor(255, 255, 255, alpha), 1.05, fBig, "center", "center")

    -- ===== status message =====
    if ui.status then
        local age = now - ui.status.t0
        if age < 4000 then
            local sa = alpha * (1 - math.max((age - 3000) / 1000, 0))
            local col = ui.status.ok and { 120, 220, 140 } or { 255, 110, 110 }
            dxDrawText(ui.status.text, px, py + ph * 0.66, px + pw, py + ph * 0.72,
                tocolor(col[1], col[2], col[3], math.floor(sa)), 1.0, fMed, "center", "center", true)
        end
    end

    -- ===== Z badge (the ONLY hue-wheel control) =====
    local zx, zy = zCenter()
    local zR = 21 * ui.s0
    if ui.wheelOpen then
        zR = zR * (1 + 0.08 * math.sin((now - ui.wheelT0) / 180))
    end
    if circleTex then
        drawBlob(zx, zy, zR * 1.7, c1, alpha * (ui.wheelOpen and 0.9 or 0.5))
        dxDrawImage(zx - zR * 1.08, zy - zR * 1.08, zR * 2.16, zR * 2.16, circleTex,
            0, 0, 0, tocolor(255, 255, 255, math.floor(alpha * 0.55)))
        dxDrawImage(zx - zR, zy - zR, zR * 2, zR * 2, circleTex, 0, 0, 0,
            mixCol(c1, { 8, 12, 24 }, 0.55, alpha))
    else
        dxDrawRectangle(zx - zR, zy - zR, zR * 2, zR * 2, mixCol(c1, { 8, 12, 24 }, 0.55, alpha))
    end
    dxDrawText("Z", zx - zR, zy - zR, zx + zR, zy + zR,
        tocolor(255, 255, 255, alpha), 1.0, fBig, "center", "center", false, false, false, true)

    -- ===== hue wheel (only visible after Z) =====
    if ui.wheelOpen or (now - ui.wheelT0) < 380 then
        local wAlpha = ui.wheelOpen and alpha or math.max(0, alpha * (1 - (now - ui.wheelT0) / 380))
        if wAlpha > 4 then
            local wcx, wcy = wheelCenter()
            -- dark disc
            drawBlob(wcx, wcy, 110 * ui.s0, c1, wAlpha * 0.5)
            dxDrawImage(wcx - 96 * ui.s0, wcy - 96 * ui.s0, 192 * ui.s0, 192 * ui.s0, circleTex,
                0, 0, 0, tocolor(6, 9, 18, math.floor(wAlpha * 0.9)))
            -- swatches
            for i = 1, #PRESET_HUES do
                local sx, sy = swatchPos(i)
                local hcol = { hslRgb(PRESET_HUES[i], 95, 60) }
                local sr = (i == ui.sel) and 19 * ui.s0 or 16 * ui.s0
                dxDrawImage(sx - sr - 2 * ui.s0, sy - sr - 2 * ui.s0,
                    (sr + 2 * ui.s0) * 2, (sr + 2 * ui.s0) * 2, circleTex,
                    0, 0, 0, tocolor(255, 255, 255, math.floor(wAlpha * (i == ui.sel and 0.95 or 0.45))))
                dxDrawImage(sx - sr, sy - sr, sr * 2, sr * 2, circleTex,
                    0, 0, 0, tocolor(hcol[1], hcol[2], hcol[3], math.floor(wAlpha)))
                if i == ui.sel then
                    drawBlob(sx, sy, sr * 2.2, hcol, wAlpha * 0.8)
                end
            end
            -- rainbow hue slider
            local sr2 = { sliderRect() }
            local slices = 60
            for i = 0, slices - 1 do
                local hcol = { hslRgb(i / (slices - 1) * 360, 90, 55) }
                dxDrawRectangle(sr2[1] + sr2[3] * i / slices, sr2[2],
                    sr2[3] / slices + 1, sr2[4],
                    tocolor(hcol[1], hcol[2], hcol[3], math.floor(wAlpha)))
            end
            dxDrawRectangle(sr2[1] - 1, sr2[2] - 1, sr2[3] + 2, sr2[4] + 2,
                tocolor(255, 255, 255, math.floor(wAlpha * 0.25)))
            local frac = ui.hue / 360
            local thx = sr2[1] + sr2[3] * frac
            dxDrawImage(thx - 8 * ui.s0, wcy - 8 * ui.s0, 16 * ui.s0, 16 * ui.s0, circleTex,
                0, 0, 0, tocolor(255, 255, 255, math.floor(wAlpha)))
        end
    end

    -- ===== smoke puffs (on top of everything) =====
    -- 2026-11-16: puffs fade ~1.7x faster while dragging (fewer live blobs)
    local decay = 0.94 ^ (dt * 60 * (ui.dragging and 1.7 or 1))
    for i = #puffs, 1, -1 do
        local p = puffs[i]
        p.x = p.x + p.vx
        p.y = p.y + p.vy
        p.r = p.r + p.grow * dt
        p.life = p.life * decay
        if p.life < 0.04 then
            table.remove(puffs, i)
        else
            -- 2026-11-16: one blob per puff instead of two (halves smoke cost)
            drawBlob(p.x, p.y, p.r, ui.c1, alpha * 0.55 * p.life)
        end
    end

    -- ===== footers =====
    dxDrawText("connect  192.168.87.240:22003  (LAN)   |   molecule-markets.tun.ply.gg:37955  (online)",
        0, scrH - 34, scrW, scrH - 10, tocolor(150, 160, 180, math.floor(alpha * 0.8)),
        1.0, "default", "center", "center")
    dxDrawText("ENTER = submit   |   TAB = next field   |   hold panel = drag   |   Z = colors   |   v5 NEON HUE",
        0, scrH - 18, scrW, scrH, tocolor(110, 118, 135, math.floor(alpha * 0.7)),
        1.0, "default", "center", "center")
end

-- real FPS measurement (frames per second, counted) - MTA has no getFPS()
local fpsFrames, fpsT0 = 0, getTickCount()

local function draw()
    if not ui.open then return end
    fpsFrames = fpsFrames + 1
    local nowMs = getTickCount()
    if nowMs - fpsT0 >= 1000 then
        ui.fps = fpsFrames
        fpsFrames, fpsT0 = 0, nowMs
    end
    local ok, err = pcall(renderUI)
    if not ok then
        dxDrawRectangle(0, 0, scrW, scrH, tocolor(0, 0, 0, 235))
        dxDrawText("UI ERROR: " .. tostring(err), 12, 12, scrW - 12, scrH - 12,
            tocolor(255, 80, 80, 255), 1.2, "default-bold", "left", "top", true, false)
    end
end

-- ============================== open / close ==============================
addEventHandler("onClientRender", root, draw, false)

-- restart-safe open (2026-11-16): the client NEVER opens the UI on its own
-- anymore. It reports ready and the server decides: unlogged players get the
-- UI (ngl:open), players already in-game get ngl:skipLogin. This kills the
-- frozen login screen appearing over spawned players after a hot restart.
local function doOpen()
    ui.open = true
    ui.t0 = getTickCount()
    ui.lastFrame = ui.t0
    -- gta4gg: prefill the last used credentials (player presses LOGIN only)
    local su, sp = loadCredentials()
    if su ~= "" then
        ui.user = su
        ui.pass = sp
        ui.pass2 = sp
        ui.focus = nil
    end
    setHue(35) -- 2026-11-19: unified Luxury GTA V identity (charcoal + gold)
    buildSprites()
    initMotes()
    showChat(false)
    showCursor(true)
    guiSetInputMode("no_binds")
    logToServer("ng-login2 v5 LUXURY GOLD open (mode login) - unified LC identity")
end

addEvent("ngl:open", true)
addEventHandler("ngl:open", root, doOpen)

addEvent("ngl:skipLogin", true)
addEventHandler("ngl:skipLogin", root, function()
    -- 2026-11-16 FIX: force-close, not just a log line. If a hot restart of
    -- ng-login2 reloaded this script while the player is already logged in and
    -- in the character creator, any stale open state must die. We do NOT touch
    -- showCursor or the player freeze here: ng-characters owns the cursor and
    -- needs the frozen state for its cinematic creator camera.
    if ui.open then
        ui.open = false
        logToServer("skipLogin: force-closed stale login UI")
    else
        logToServer("skipLogin: already in-game - login UI stays closed")
    end
end)

-- 2026-11-16: language switches (Win+Space / Alt+Shift) and focus changes can
-- drop character input - reapply the input mode the moment focus returns and
-- prove it in the log so we can verify typing works after a layout change
addEventHandler("onClientFocus", root, function()
    if ui.open then
        guiSetInputMode("no_binds")
        logToServer("focus regained - input mode reapplied (no_binds)")
    end
end)

-- fps telemetry (2026-11-16): one line per 10s while the UI is open -
-- gives REAL fps numbers from the player's machine for tuning
setTimer(function()
    if ui.open then
        logToServer(("fps=%d drag=%s puffs=%d motes=%s"):format(
            ui.fps, tostring(ui.dragging), #puffs, tostring(ui.fps >= 30)))
    end
end, 10000, 0)

addEventHandler("onClientResourceStart", resourceRoot, function()
    -- prep assets without opening the UI; server decides below
    setHue(35)
    buildSprites()
    initMotes()
    triggerServerEvent("ngl:ready", localPlayer)
end)

addEventHandler("onClientRestore", resourceRoot, function()
    -- device/resolution restore invalidates the cached backdrop
    if bgRT then destroyElement(bgRT) end
    bgRT = nil
    bgDirty = true
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if ui.open then
        showCursor(false)
        guiSetInputMode("allow_binds")
        showChat(true)
    end
    if circleTex then destroyElement(circleTex) end
    if blobTex then destroyElement(blobTex) end
    if bgRT then destroyElement(bgRT) end
end)
