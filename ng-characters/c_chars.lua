--[[
    ng-characters c_chars.lua v2 CINEMATIC - GTA V style character system (client, 2026-11-16)
    - pure DX (no gui windows, no CEF) matching the ng-login2 neon look
    - SCREEN 1 "list": GTA V pause-menu style slot cards over a live city flyover
    - SCREEN 2 "create": 3D turntable preview ped standing IN the real GTA V
      city plaza (known streamed spot) + cinematic camera flight between screens
    - the local player is in dimension 9999 (server-frozen). Client-side we
      switch the LOCAL dimension to 0 so the real city renders behind the
      camera (server-side dimension is untouched - no gameplay effect).
    - talks to the EXISTING server events (ngc:createChar / selectChar /
      deleteChar / status / charSpawned) so saving/spawn logic is untouched
]]

local scrW, scrH = guiGetScreenSize()

-- MUST stay identical to the server-side lists in s_chars.lua.
-- 2026-11-22: every playable model comes from D:\022\SKINS\skn\0 (41 packs).
-- Ballas HD (210) removed: its DFF is rejected by engineReplaceModel on every client.
local MALE_SKINS   = {14, 15, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 30, 32, 33, 37, 43, 44, 45, 46, 51, 52, 60, 252, 274}
local FEMALE_SKINS = {9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 88, 93}

-- lookup used by the selection cards to pick the gender icon
local FEMALE_SET = {}
for _, s in ipairs(FEMALE_SKINS) do FEMALE_SET[s] = true end

local SKIN_NAMES = {
    [9] = "Female Surgeon HD", [10] = "COT PF HD", [11] = "K-Camuflada HD", [12] = "Random Girl v2 HD",
    [13] = "Roleplay Girl HD", [14] = "BOPE HD", [15] = "SAMU ByOutfit HD", [18] = "ByRupra HD",
    [19] = "Transito HD", [20] = "Mechanic HD", [21] = "SAMU By7capa HD", [22] = "Business Male HD",
    [23] = "Pulaski HD", [24] = "RED HD", [25] = "GHOST DZ Blue HD", [26] = "ByKAZIDE HD",
    [27] = "ByBeyBy HD", [30] = "Bloods HD", [31] = "TDT HD", [32] = "PMES HD", [33] = "Mafia ByCostela HD",
    [37] = "Handsome Male HD", [38] = "La Casa de Papel HD", [39] = "LCPD Officer F2 HD",
    [40] = "Roleplay Girl v2 HD", [41] = "Brasil HD", [43] = "Mafia Male HD", [44] = "Crips HD",
    [45] = "Business Male v2 HD", [46] = "Mafia Random HD", [51] = "LCPD Cadet HD", [52] = "LCPD Patrol HD",
    [53] = "Pijama HD", [54] = "BySampaio HD", [55] = "LCPD Officer F1 HD", [56] = "Tattooed Girl HD",
    [60] = "Skin 60 HD", [88] = "Tourist Girl HD", [93] = "Kaine Goth HD",
    [252] = "Karakter 252 HD", [274] = "Male Surgeon HD",
}

local RANDOM_FIRST_M = {"James", "Michael", "Franklin", "Trevor", "Lester", "Lamar",
    "Wade", "Floyd", "Brad", "Steve", "Aiden", "Marcus"}
local RANDOM_FIRST_F = {"Amanda", "Tracey", "Molly", "Patricia", "Lacey", "Ursula",
    "Tanisha", "Maria", "Denise", "Karen", "Paige", "Cheryl"}
local RANDOM_LAST = {"Smith", "Johnson", "Brown", "Taylor", "Miller", "Wilson",
    "Anderson", "Thomas", "Walker", "Reyes", "Ortiz", "Kelly"}

local ACCENT = {74, 163, 255}   -- GTA V pause-menu blue
local CARD   = {18, 22, 30}

-- 2026-11-22 LC-ONLY: the old preview used San Andreas interior 14, which made
-- the SA studio bleed over the Liberty City world. All creator peds now live
-- in a private client-side LC dimension at a verified LC lot (interior 0), so
-- nothing from San Andreas can overlap the city.
-- 2026-11-22 LUXURY STUDIO FIX: the old private dimension (9100) hid every
-- dimension-0 LC map element, so the "studio" was an empty skybox. Keep the
-- creator in real LC dimension 0 at the verified ground spawn point; the ped
-- and stage are client-side only, so other players never see them.
local CREATOR_DIM = 0
local CREATOR_INT = 0
-- The approved HD packs place the model's feet about 1m below the collision
-- point (same offset used by lc_premium_interiors for clerk model 22).
local PREVIEW_Z_LIFT = 1.05

local LINEUP = { x = -224.23, y = 1146.18, z = 14.05, spacing = 1.15, interior = CREATOR_INT, dimension = CREATOR_DIM }
local STUDIO = { x = -224.23, y = 1146.18, z = 14.05, interior = CREATOR_INT, dimension = CREATOR_DIM }

local NATIVEUI_RES = "mta_nativeui"

-- ============================== premium assets ==============================
-- hand-generated PNG icon set (white thin strokes, transparent bg, GTA V
-- Online style) + glass panel texture - loaded from this resource's files
local TEX = {}
local ASSETS = { "user", "chev_left", "chev_right", "plus", "trash", "shuffle",
    "calendar", "dice", "crown", "logout", "male", "female", "badge", "panel",
    -- 2026-11-18 premium UI kit (soft-corner glass cards, gold/red pills,
    -- circular icon buttons, screen fades) - generated at 4x and downsampled
    "ui_card_fill", "ui_card_ring", "ui_card_solid", "ui_card_glow",
    "ui_pill_solid", "ui_pill_glow", "ui_btn_gold", "ui_btn_red",
    "ui_circle_solid", "ui_circle_fill", "ui_circle_ring", "ui_fade",
    -- 2026-11-18 LmB branding / GTA city decor (generated silhouettes)
    "deco_city", "deco_palm" }
addEventHandler("onClientResourceStart", root, function(res)
    if res ~= getThisResource() then return end
    for _, n in ipairs(ASSETS) do
        TEX[n] = dxCreateTexture(":ng-characters/" .. n .. ".png", "argb", true, "clamp")
    end
end)

local function icon(name, x, y, s, alpha, tint)
    if not TEX[name] then return end
    local r, g, b = 255, 255, 255
    if tint then r, g, b = tint[1], tint[2], tint[3] end
    dxDrawImage(x, y, s, s, TEX[name], 0, 0, 0, tocolor(r, g, b, math.floor(alpha)))
end

local ui = {
    open    = false,
    screen  = "list",   -- "list" | "create"
    chars   = {},
    level   = 0,
    focus   = nil,      -- "first" | "last"
    first   = "",
    last    = "",
    age     = 25,
    muscle  = 25,   -- UNIFORM SYSTEM: CJ body build (stat 23)
    fat     = 25,   -- UNIFORM SYSTEM: CJ body build (stat 21)
    gender  = 0,        -- 0 male, 1 female
    skinIndex = 1,
    status  = nil,      -- { text = "", ok = bool, t0 = tick }
    t0      = getTickCount(),
    turn    = 0,        -- preview ped turntable angle
    delArm  = nil,      -- char id armed for delete (two-click confirm)
    _hits   = {},
    _ageRect = nil,
    loading = 0,        -- "entering Los Santos" progress when creating
    chat    = {},       -- recent server messages (gold-framed feed)
    _press  = nil,      -- last action button press (hover/press feedback)
}

local previewPed = nil
local camAnim = nil
local dimSwitched = false
local savedDim, savedInt

-- NativeUI creator hooks (implemented after tryCreate; assigned before any
-- server event can call openCreate/closeAll).
local openNativeCreator, closeNativeCreator, refreshNativeText
local openNativeSelector, closeNativeSelector, refreshNativeSelector, syncNativeSelectorHighlight

-- ============================== helpers ==============================

local function now() return getTickCount() end

local function smooth(t)
    t = math.max(0, math.min(1, t))
    return t * t * (3 - 2 * t)
end

-- Design pixels (1920x1080) -> screen pixels, keeps the UI identical in
-- proportion on 1366x768, 2560x1440 and ultrawide screens.
local function S(value)
    local k = math.min(scrW / 1920, scrH / 1080)
    if k <= 0 then k = 1 end
    return value * k
end

-- Design pixel font size -> dxDrawText scale (1.0 is ~22px tall at 1080p).
local function fs(sizePx)
    return S(sizePx) / 22
end

-- 2026-11-18: text now sizes itself in *real screen pixels*. Scale 1.0 is not
-- a fixed pixel height across font builds, so it is measured once instead of
-- assumed: labels stay readable on a 640x480 window, 720p, 1080p and 4K.
local baseFontPx = nil
local function pxScale(px)
    if not baseFontPx then
        local ok, h = pcall(dxGetFontHeight, 1, "default-bold")
        h = ok and tonumber(h) or nil
        baseFontPx = (h and h > 0) and h or 16
    end
    return px / baseFontPx
end

-- Shrinks a label until it fits, so long character names never spill out.
-- sizePx is a real screen-pixel height, not a 1080p design value.
local function fitScale(text, maxW, sizePx, font)
    local scale = pxScale(sizePx)
    if not text or text == "" or maxW <= 0 then return scale end
    local w = dxGetTextWidth(text, scale, font or "default-bold")
    if w > maxW and w > 0 then scale = scale * (maxW / w) end
    return scale
end

-- One set of pill measurements for every button: icon, gap, padding and label
-- scale all derive from the pill height (never below a screen-pixel floor).
-- Returning the scale lets a row of buttons share one size, so a long label
-- can no longer render smaller than a short one next to it.
local function pillMetrics(w, h, label)
    local targetPx = math.max(14, h * 0.36)
    local isz      = math.max(S(22), h * 0.34)
    local gap      = math.max(S(11), isz * 0.45)
    local padX     = math.max(S(20), isz * 0.60)
    local labelW   = math.max(0, w - isz - gap - padX * 2)
    local scale    = pxScale(targetPx)
    if label and label ~= "" and labelW > 0 then
        local tw = dxGetTextWidth(label, scale, "default-bold")
        if tw > labelW then scale = scale * (labelW / tw) end
    end
    return isz, gap, labelW, scale
end

-- ============================== LmB design system ==============================
-- 2026-11-18: one shared "Dark Luxury Premium" kit for both character screens.
-- Charcoal glass bodies, champagne-gold rims, soft glow, serif display type.
-- Everything is measured in real screen pixels so a 640x480 window still gets
-- readable text instead of a shrunken 1080p layout.

local LUX = {
    gold     = { 226, 190, 116 },
    goldSoft = { 246, 222, 174 },
    text     = { 240, 242, 246 },
    mute     = { 166, 172, 184 },
    shadow   = { 4, 5, 8 },
}

local fonts = {}
local fontsH = 0

local function ensureFonts()
    local _, sh = guiGetScreenSize()
    if fonts.logo and fontsH == sh then return end
    fontsH = sh
    for _, f in pairs(fonts) do
        if isElement(f) then destroyElement(f) end
    end
    local function mk(file, px, minPx)
        return dxCreateFont(file, math.max(minPx or 9, math.floor(px * sh / 1080)), false, "proof") or false
    end
    fonts.logo    = mk("fonts/Constantia-Italic.ttf", 40, 20)
    fonts.title   = mk("fonts/Constantia.ttf", 44, 22)
    fonts.eyebrow = mk("fonts/Ubuntu-B.ttf", 11, 9)
    fonts.head    = mk("fonts/BebasNeueRegular.otf", 24, 13)
    fonts.body    = mk("fonts/Ubuntu-L.ttf", 12, 9)
    fonts.bold    = mk("fonts/Ubuntu-B.ttf", 13, 10)
    fonts.chat    = mk("fonts/Ubuntu-L.ttf", 12, 8)
    fonts.sub     = mk("fonts/Ubuntu-L.ttf", 11, 8)
end

-- single space between every glyph: the "expensive" tracked captions
local function spread(text)
    local out = {}
    for i = 1, #text do
        local ch = text:sub(i, i)
        out[#out + 1] = ch
        if ch ~= " " and i < #text then out[#out + 1] = " " end
    end
    return table.concat(out)
end

-- pre-spread captions (no string work in the render loop)
local TXT_FEED = spread("SERVER MESSAGES")
local TXT_FOOTER = spread("WELCOME TO LmB ROLEPLAY")

-- x, y, w, h in screen pixels; opts: hot 0..1, fill, glow, rimAlpha, corners
local function glassPanel(x, y, w, h, a, opts)
    opts = opts or {}
    local hot = math.max(0, math.min(1, opts.hot or 0))
    local glow = opts.glow and (opts.glow == true and 1 or opts.glow) or 0

    if glow > 0 then
        for i = 3, 1, -1 do
            local g = i * math.max(2, S(4))
            dxDrawRectangle(x - g, y - g, w + g * 2, h + g * 2,
                tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3],
                    math.floor(5 * glow * a)))
        end
    end

    if opts.fill ~= false then
        local bands = 8
        for i = 0, bands - 1 do
            local t = i / (bands - 1)
            local r, g, b
            if t < 0.5 then
                local k = t * 2
                r, g, b = 36 + (24 - 36) * k, 39 + (27 - 39) * k, 46 + (33 - 46) * k
            else
                local k = (t - 0.5) * 2
                r, g, b = 24 + (9 - 24) * k, 27 + (10 - 27) * k, 33 + (13 - 33) * k
            end
            dxDrawRectangle(x, y + h * i / bands, w, h / bands + 1,
                tocolor(math.floor(r), math.floor(g), math.floor(b),
                    math.floor((opts.alpha or 214) * a)))
        end
        -- glass sheen
        dxDrawRectangle(x, y, w, math.max(1, h * 0.42),
            tocolor(255, 255, 255, math.floor(9 * a)))
    end

    local lw = math.max(1, math.floor(S(1.5) + 0.5))
    local rimA = math.floor(((opts.rimAlpha or 120) + 105 * hot) * a)
    local rim = tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.min(255, rimA))
    dxDrawRectangle(x, y, w, lw, rim)
    dxDrawRectangle(x, y + h - lw, w, lw, rim)
    dxDrawRectangle(x, y, lw, h, rim)
    dxDrawRectangle(x + w - lw, y, lw, h, rim)

    -- inner hairline keeps the frame from looking flat at small sizes
    dxDrawRectangle(x + lw, y + lw, w - lw * 2, 1,
        tocolor(255, 255, 255, math.floor(22 * a)))

    if opts.corners ~= false then
        local cl = math.max(6, S(16))
        local ct = math.max(2, math.floor(S(2) + 0.5))
        local cc = tocolor(LUX.goldSoft[1], LUX.goldSoft[2], LUX.goldSoft[3],
            math.floor(235 * a))
        dxDrawRectangle(x, y, cl, ct, cc)
        dxDrawRectangle(x, y, ct, cl, cc)
        dxDrawRectangle(x + w - cl, y, cl, ct, cc)
        dxDrawRectangle(x + w - ct, y, ct, cl, cc)
        dxDrawRectangle(x, y + h - ct, cl, ct, cc)
        dxDrawRectangle(x, y + h - cl, ct, cl, cc)
        dxDrawRectangle(x + w - cl, y + h - ct, cl, ct, cc)
        dxDrawRectangle(x + w - ct, y + h - cl, ct, cl, cc)
    end
end

-- LmB wordmark + gold crown, anchored to the top-right corner
local function drawLogo(a)
    ensureFonts()
    local f = fonts.logo or "default-bold"
    local text = "LmB"
    local tw = dxGetTextWidth(text, 1, f)
    local x = scrW - math.max(S(34), 18) - tw
    local y = math.max(S(26), 10)

    icon("crown", x + tw * 0.5 - S(11), y - S(16), S(22), 235 * a, LUX.gold)
    dxDrawText(text, x + 1, y + 2, x + tw + 1, y + S(50), tocolor(0, 0, 0, math.floor(160 * a)),
        1, f, "left", "top")
    dxDrawText(text, x, y, x + tw, y + S(48), tocolor(LUX.goldSoft[1], LUX.goldSoft[2], LUX.goldSoft[3],
        math.floor(255 * a)), 1, f, "left", "top")
    dxDrawText("R O L E P L A Y", x - S(14), y + S(44), x + tw + S(16), y + S(60),
        tocolor(LUX.mute[1], LUX.mute[2], LUX.mute[3], math.floor(190 * a)),
        1, fonts.sub or "default", "center", "top")
end

-- GTA-style city + palms silhouettes, drawn behind the interface
local function drawDecor(a)
    if TEX.deco_city then
        local dh = math.min(S(210), scrH * 0.30)
        dxDrawImage(0, scrH - dh, scrW, dh, TEX.deco_city, 0, 0, 0,
            tocolor(255, 255, 255, math.floor(115 * a)))
    end
    if TEX.deco_palm then
        local ph = math.min(S(330), scrH * 0.44)
        local pw = ph * (520 / 760)
        local py = scrH - ph * 0.90
        dxDrawImage(-pw * 0.16, py, pw, ph, TEX.deco_palm, 0, 0, 0,
            tocolor(255, 255, 255, math.floor(90 * a)))
        dxDrawImage(scrW - pw * 0.84, py, pw, ph, TEX.deco_palm, 0, 0, 0,
            tocolor(255, 255, 255, math.floor(90 * a)))
    end
end

local function drawFooter(a)
    ensureFonts()
    dxDrawText(TXT_FOOTER, 0, scrH - math.max(S(26), 16), scrW, scrH - math.max(S(8), 2),
        tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor(200 * a)),
        1, fonts.eyebrow or "default-bold", "center", "center")
end

-- custom gold-framed server message feed (default chat is hidden while open)
local function drawChat(a)
    if ui.screen ~= "list" then return end
    ensureFonts()
    local w = math.max(200, math.min(S(392), scrW * 0.35))
    local h = math.max(78, math.min(S(184), scrH * 0.34))
    local x = math.max(S(16), scrW * 0.026)
    local y = scrH * 0.135

    glassPanel(x, y, w, h, a, { rimAlpha = 135, corners = true, alpha = 196 })

    local pad = math.max(8, S(12))
    dxDrawText(TXT_FEED, x + pad, y + pad * 0.65, x + w - pad, y + pad + S(14),
        tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor(220 * a)),
        1, fonts.eyebrow or "default-bold", "left", "center")
    dxDrawRectangle(x + pad, y + pad + S(18), w - pad * 2, 1,
        tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor(90 * a)))

    local rows = math.max(2, math.floor((h - pad * 2 - S(22)) / math.max(11, S(15))))
    local first = math.max(1, #ui.chat - rows + 1)
    local lineH = math.max(11, S(15))
    local ty = y + h - pad - lineH * (#ui.chat - first + 1)

    for i = first, #ui.chat do
        local m = ui.chat[i]
        local fade = 1
        local age = now() - (m.t0 or 0)
        if age > 9000 then fade = math.max(0.35, 1 - (age - 9000) / 9000) end
        dxDrawText(m.text, x + pad, ty, x + w - pad, ty + lineH,
            tocolor(m.r or 235, m.g or 238, m.b or 244, math.floor(225 * fade * a)),
            1, fonts.chat or "default", "left", "center", true, false)
        ty = ty + lineH
    end
end


local function setStatus(text, ok)
    ui.status = { text = tostring(text), ok = ok and true or false, t0 = now() }
end

-- client-side diagnostic relay: prints locally AND forwards to server.log so
-- screen-open failures are visible without the player describing anything.
-- (defined before the click handlers so the create button can always log)
local function logToServer(msg)
    outputDebugString("[ng-characters][client] " .. tostring(msg), 1)
    triggerServerEvent("ngc:clientLog", localPlayer, msg)
end

local function skins()
    return ui.gender == 1 and FEMALE_SKINS or MALE_SKINS
end

local function currentSkin()
    local s = skins()
    return s[math.max(1, math.min(#s, ui.skinIndex))]
end

local function alphaIn()
    return smooth((now() - ui.t0) / 700) * 255
end

-- ============================== camera ==============================

local function flyCameraTo(tx, ty, tz, tlx, tly, tlz, dur)
    local cx, cy, cz, clx, cly, clz = getCameraMatrix()
    camAnim = {
        fx = cx, fy = cy, fz = cz, flx = clx, fly = cly, flz = clz,
        tx = tx, ty = ty, tz = tz, tlx = tlx, tly = tly, tlz = tlz,
        t0 = now(), dur = dur or 900,
    }
end

local function updateCamera()
    if not camAnim then return false end
    local p = smooth((now() - camAnim.t0) / camAnim.dur)
    if p >= 1 then
        setCameraMatrix(camAnim.tx, camAnim.ty, camAnim.tz, camAnim.tlx, camAnim.tly, camAnim.tlz)
        camAnim = nil
        return false
    end
    local ex, ey, ez = camAnim.fx, camAnim.fy, camAnim.fz
    local lx, ly, lz = camAnim.flx, camAnim.fly, camAnim.flz
    -- ease position and look-target together for the cinematic glide
    setCameraMatrix(
        ex + (camAnim.tx - ex) * p, ey + (camAnim.ty - ey) * p, ez + (camAnim.tz - ez) * p,
        lx + (camAnim.tlx - lx) * p, ly + (camAnim.tly - ly) * p, lz + (camAnim.tlz - lz) * p)
    return true
end

-- ============================== 3D studio ==============================

local function destroyPreview()
    if isElement(previewPed) then destroyElement(previewPed) end
    previewPed = nil
end

local studioRing, studioGlow, studioBaseZ

local function destroyStudioProps()
    if isElement(studioRing) then destroyElement(studioRing) end
    if isElement(studioGlow) then destroyElement(studioGlow) end
    studioRing, studioGlow = nil, nil
end

local function buildStudioProps()
    destroyStudioProps()
    local z = studioBaseZ or STUDIO.z
    studioGlow = createMarker(STUDIO.x, STUDIO.y, z + 0.02, "cylinder", 2.2, 74, 163, 255, 38)
    studioRing = createMarker(STUDIO.x, STUDIO.y, z + 0.06, "ring", 2.9, 226, 190, 116, 210)
    for _, m in ipairs({ studioGlow, studioRing }) do
        if isElement(m) then
            setElementInterior(m, STUDIO.interior)
            setElementDimension(m, STUDIO.dimension)
        end
    end
end

-- Pure-DX stage lighting drawn in 3D so the studio stays luxurious without
-- adding any new client file to the HTTP mirror.
local function drawStudioLights(a)
    if not studioBaseZ or (ui.screen ~= "create" and ui.screen ~= "native") then return end
    local z = studioBaseZ
    local gold = tocolor(226, 190, 116, math.floor(135 * a))
    local blue = tocolor(74, 163, 255, math.floor(95 * a))

    -- circular gold floor ring
    local segments, radius = 48, 2.35
    for i = 0, segments - 1 do
        local a1 = math.rad(i * 360 / segments)
        local a2 = math.rad((i + 1) * 360 / segments)
        dxDrawLine3D(
            STUDIO.x + math.cos(a1) * radius, STUDIO.y + math.sin(a1) * radius, z + 0.12,
            STUDIO.x + math.cos(a2) * radius, STUDIO.y + math.sin(a2) * radius, z + 0.12,
            gold, 2)
    end

    -- converging spotlight beams around the standing character
    for i = 0, 7 do
        local ang = math.rad(i * 45 + (now() * 0.012) % 360)
        dxDrawLine3D(
            STUDIO.x + math.cos(ang) * 3.1, STUDIO.y + math.sin(ang) * 3.1, z + 3.6,
            STUDIO.x, STUDIO.y, z + 0.25,
            (i % 2 == 0) and gold or blue, 2)
    end
end

local function buildPreview()
    destroyPreview()
    local gz = getGroundPosition(STUDIO.x, STUDIO.y, STUDIO.z + 4)
    local groundZ = STUDIO.z
    if tonumber(gz) and gz > -50 and gz < 100 then groundZ = gz end
    studioBaseZ = groundZ
    local z = groundZ + PREVIEW_Z_LIFT
    previewPed = createPed(currentSkin(), STUDIO.x, STUDIO.y, z, 0)
    if previewPed then
        setElementInterior(previewPed, STUDIO.interior)
        setElementDimension(previewPed, STUDIO.dimension)
        setElementFrozen(previewPed, true)
        setPedRotation(previewPed, 0)
        pcall(function()
            setPedAnimation(previewPed, "ped", "IDLE_STANCE", -1, true, false, false)
        end)
    end
    buildStudioProps()
end

-- ============================== 3D lineup (gta4gg) ==============================
-- one client-side ped per character, standing side by side on real LC
-- ground with even spacing, all facing the camera. Mouse-pick via the
-- projected screen position of each ped.

local lineupPeds = {}

local function destroyLineup()
    for _, p in ipairs(lineupPeds) do
        if isElement(p) then destroyElement(p) end
    end
    lineupPeds = {}
end

local function buildLineup()
    destroyLineup()
    local n = #ui.chars
    if n == 0 then return end
    for i, c in ipairs(ui.chars) do
        local ox = (i - (n + 1) / 2) * LINEUP.spacing
        local ped = createPed(tonumber(c.skin) or 0, LINEUP.x + ox, LINEUP.y, LINEUP.z, 0)
        if ped then
            setElementInterior(ped, LINEUP.interior)
            setElementDimension(ped, LINEUP.dimension)
            setElementFrozen(ped, true)
            table.insert(lineupPeds, ped)
        end
        c._lineX = LINEUP.x + ox
    end
end

-- GTA V selector style: ONE standing ped per highlighted slot, snapped to the
-- LC ground. The old multi-ped row is no longer used (it caused overlapping /
-- "hanging" characters when the fixed Z did not match the lot surface).
local function getSelectedChar()
    for _, c in ipairs(ui.chars) do
        if c.id == ui._selId then return c end
    end
    ui._selId = ui.chars[1] and ui.chars[1].id or nil
    return ui.chars[1]
end

local function buildSelectedPreview()
    destroyPreview()
    local c = getSelectedChar()
    if not c then return end
    local gz = getGroundPosition(STUDIO.x, STUDIO.y, STUDIO.z + 4)
    local groundZ = STUDIO.z
    if tonumber(gz) and gz > -50 and gz < 100 then groundZ = gz end
    studioBaseZ = groundZ
    local z = groundZ + PREVIEW_Z_LIFT
    previewPed = createPed(tonumber(c.skin) or 0, STUDIO.x + 1.45, STUDIO.y, z, 0)
    if previewPed then
        setElementInterior(previewPed, CREATOR_INT)
        setElementDimension(previewPed, CREATOR_DIM)
        setElementFrozen(previewPed, true)
        setPedRotation(previewPed, 0)
    end
end

local function enterWorldView()
    -- LC-only preview: move ONLY this client into a private LC dimension so
    -- the real Liberty City world renders behind the UI without any SA room.
    if not dimSwitched then
        savedDim, savedInt = getElementDimension(localPlayer), getElementInterior(localPlayer)
        setElementDimension(localPlayer, CREATOR_DIM)
        setElementInterior(localPlayer, CREATOR_INT)
        setElementAlpha(localPlayer, 0)
        dimSwitched = true
    end
end

local function leaveWorldView(keepWorld)
    if dimSwitched then
        -- On charSpawned the server has ALREADY spawned us in the real world;
        -- never drag the player back to the pre-login holding dimension.
        if not keepWorld then
            setElementDimension(localPlayer, savedDim or 9999)
            setElementInterior(localPlayer, savedInt or 0)
        end
        dimSwitched = false
        savedDim, savedInt = nil, nil
    end
    if isElement(localPlayer) then setElementAlpha(localPlayer, 255) end
    destroyLineup()
    destroyPreview()
    destroyStudioProps()
    studioBaseZ = nil
    setCameraTarget(localPlayer, localPlayer)
end

local function openCreate()
    -- 2026-11-22: the create screen now uses the SAME NativeUI button style
    -- as the saved-character selector. A fully transparent menu background
    -- keeps the luxury 3D LC studio visible behind it (no opaque full-screen image).
    if openNativeCreator then
        openNativeCreator()
    else
        setStatus("NativeUI creator is still loading.", false)
    end
end

local function openList()
    if closeNativeCreator then closeNativeCreator() end
    if closeNativeSelector then closeNativeSelector() end
    ui.screen = "list"
    ui.t0 = now()
    ui.focus = nil
    ui.delArm = nil
    ui._hits = {}
    showChat(false)
    enterWorldView()
    showCursor(false)
    destroyStudioProps()
    studioBaseZ = nil
    getSelectedChar()
    buildSelectedPreview()
    -- menu sits on the left, the highlighted character stands on the right
    local viewZ = (studioBaseZ or STUDIO.z) + PREVIEW_Z_LIFT
    flyCameraTo(
        STUDIO.x, STUDIO.y + 4.6, viewZ + 1.35,
        STUDIO.x + 0.8, STUDIO.y, viewZ + 0.85, 1200)
    if openNativeSelector then openNativeSelector() end
end

local function closeAll()
    if closeNativeCreator then closeNativeCreator() end
    if closeNativeSelector then closeNativeSelector() end
    ui.open = false
    ui.screen = "list"
    ui.focus = nil
    camAnim = nil
    leaveWorldView(true)
    showCursor(false)
    showChat(true)
end

-- ============================== typing ==============================

local function appendName(field, ch)
    local cap = (ui[field] == "")
    ch = ch:lower()
    if cap then ch = ch:upper() end
    if #ui[field] < 16 then ui[field] = ui[field] .. ch end
end

-- ============================== layout ==============================

local function titleRect()
    return scrW * 0.5 - 300, scrH * 0.06, 600, 54
end

local function cardRect(i)
    local w, h = scrW * 0.26, scrH * 0.115
    return scrW * 0.055, scrH * 0.20 + (i - 1) * (h + scrH * 0.025), w, h
end

local function createCardRect()
    local w, h = scrW * 0.26, scrH * 0.115
    return scrW * 0.055, scrH * 0.20 + 3 * (h + scrH * 0.025), w, h
end

local function logoutRect()
    local w, h = scrW * 0.26, scrH * 0.07
    return scrW * 0.055, scrH * 0.88, w, h
end

local function genderTabRect(which)
    local w, h = 170, 44
    local x = scrW * 0.06
    local y = scrH * 0.20
    if which == "female" then x = x + w + 12 end
    return x, y, w, h
end

local function bottomPanelRect()
    local w = scrW * 0.62
    local h = scrH * 0.30
    return scrW * 0.5 - w / 2, scrH - h - scrH * 0.06, w, h
end

local function fieldRect(which)
    local bx, by, bw, bh = bottomPanelRect()
    local fw = bw * 0.42
    local fx = bx + bw * 0.04
    local fy = by + bh * 0.10
    if which == "last" then fx = bx + bw - fw - bw * 0.04 end
    return fx, fy, fw, bh * 0.17
end

local function ageRect()
    local bx, by, bw, bh = bottomPanelRect()
    return bx + bw * 0.04, by + bh * 0.40, bw * 0.91, bh * 0.09
end

local function skinRect()
    local bx, by, bw, bh = bottomPanelRect()
    -- 2026-11-16 FIX: wider display box (200px fits long HD names like
    -- "Handsome Male HD" at full size) and raised to bh*0.50 so the
    -- carousel + chevrons clear the BACK/RANDOM/CREATE button row below
    -- (no more name overflow or button overlap)
    local w, h = 200, 52
    return bx + bw / 2 - w / 2, by + bh * 0.50, w, h
end

local function createBtnRect()
    local bx, by, bw, bh = bottomPanelRect()
    local w, h = bw * 0.38, bh * 0.18
    return bx + bw - w - bw * 0.04, by + bh * 0.70, w, h
end

local function backBtnRect()
    local bx, by, bw, bh = bottomPanelRect()
    local w, h = bw * 0.27, bh * 0.18
    return bx + bw * 0.04, by + bh * 0.70, w, h
end

local function randomBtnRect()
    local bx, by, bw, bh = bottomPanelRect()
    local w, h = bw * 0.27, bh * 0.18
    return bx + bw * 0.35, by + bh * 0.70, w, h
end

-- UNIFORM SYSTEM: body build slider tracks (muscle / fat), male only
local function buildRect(which)
    local bx, by, bw, bh = bottomPanelRect()
    local w = bw * 0.44
    local x = bx + bw * 0.04
    if which == "fat" then x = bx + bw - w - bw * 0.04 end
    return x, by + bh * 0.53, w, bh * 0.08
end

local function inRect(cx, cy, r)
    return r and cx >= r[1] and cx <= r[1] + r[3] and cy >= r[2] and cy <= r[2] + r[4]
end

-- ============================== GTA Luxury Gold & Black buttons ==============================
-- 2026-11-18: soft-corner pills with baked dark-gold / dark-red metal looks.
-- The gradient and border live in the PNGs (ui_btn_gold / ui_btn_red), so the
-- button costs two draws plus a glow instead of ~150 strip rectangles.

local GOLD = { 226, 190, 116 }   -- CREATE NEW CHARACTER
local RED  = { 198,  76,  72 }   -- LOG OUT

-- Texture geometry: content is 640x120 inside a 680x160 glow canvas.
local BTN_PAD_X, BTN_PAD_Y = 20 / 640, 20 / 120

-- 2026-11-18: black-glass action card: gold rim, icon in a gold ring, title,
-- second-line description and a gold chevron. Two cards share one height so
-- the typography always matches; everything sizes from real pixels.
local function drawLuxButton(id, r, label, desc, iconName, a)
    ensureFonts()
    local x, y, w, h = r[1], r[2], r[3], r[4]
    local hp = ui["_hov_" .. id] or 0
    local pp = 0

    if ui._press and ui._press.id == id then
        pp = 1 - math.min(1, (now() - ui._press.t0) / 260)
    end

    local lift = math.max(0, S(2)) * hp - math.max(0, S(1)) * pp
    local by = y + lift

    glassPanel(x, by, w, h, a, {
        hot = hp, glow = hp > 0.02 and hp or false,
        rimAlpha = 110 + math.floor(55 * pp), alpha = 210,
    })

    -- pressed cards sink: a slim shadow under the top edge sells the depth
    if pp > 0.02 then
        dxDrawRectangle(x, by + h, w, math.max(1, S(3) * pp),
            tocolor(0, 0, 0, math.floor(120 * pp * a)))
    end

    local pad = math.max(8, math.min(h * 0.16, w * 0.06))
    local isz = h * 0.34
    local ring = isz + math.max(10, h * 0.16)
    local ccx = x + pad + ring * 0.5
    local ccy = by + h * 0.5
    local hot = hp > 0.05

    -- gold ring around the icon
    local rr = tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor((hot and 235 or 150) * a))
    dxDrawCircle(ccx, ccy, ring * 0.5, 0, 360, rr, rr, 40)
    dxDrawCircle(ccx, ccy, ring * 0.5 - math.max(1, S(1.5)), 0, 360,
        tocolor(12, 14, 19, math.floor(235 * a)),
        tocolor(12, 14, 19, math.floor(235 * a)), 40)
    icon(iconName, ccx - isz * 0.5, ccy - isz * 0.5, isz, (hot and 255 or 235) * a,
        hot and LUX.goldSoft or LUX.gold)

    -- gold chevron on the right
    local chSz = math.max(10, h * 0.22)
    local chX = x + w - pad - chSz
    icon("chev_right", chX + (hot and S(2) or 0), ccy - chSz * 0.5, chSz,
        (hot and 255 or 175) * a, LUX.gold)

    -- title + description
    local tx = x + pad + ring + math.max(8, h * 0.12)
    local avail = chX - math.max(6, S(8)) - tx
    local titlePx = math.max(12, h * 0.185)
    local descPx  = math.max(9, h * 0.115)
    local titleScale = fitScale(label, avail, titlePx, "default-bold")
    local descScale  = fitScale(desc, avail, descPx, "default")

    local titleY = ccy - titlePx * 0.95
    local descY  = ccy + descPx * 0.30

    dxDrawText(label, tx + 1, titleY + 1, tx + avail, titleY + titlePx * 1.7,
        tocolor(0, 0, 0, math.floor(140 * a)), titleScale, "default-bold", "left", "center")
    dxDrawText(label, tx, titleY, tx + avail, titleY + titlePx * 1.7,
        tocolor(hot and 252 or 240, hot and 236 or 242, hot and 206 or 248, math.floor(255 * a)),
        titleScale, "default-bold", "left", "center")
    dxDrawText(desc, tx, descY, tx + avail, descY + descPx * 1.8,
        tocolor(hot and 226 or LUX.mute[1], hot and 206 or LUX.mute[2], hot and 160 or LUX.mute[3],
            math.floor(225 * a)),
        descScale, "default", "left", "center")
end

-- ============================== render: shared chrome ==============================

local function drawVignette(a)
    -- soft cinematic fades instead of hard letterbox bars
    if TEX.ui_fade then
        local top = S(190)
        dxDrawImage(0, 0, scrW, top, TEX.ui_fade, 0, 0, 0,
            tocolor(5, 6, 8, math.floor(215 * a)))
        local bot = S(230)
        dxDrawImage(0, scrH - bot, scrW, bot, TEX.ui_fade, 180, 0, 0,
            tocolor(5, 6, 8, math.floor(245 * a)))
    else
        dxDrawRectangle(0, 0, scrW, scrH * 0.12, tocolor(8, 10, 15, math.floor(120 * a)))
        dxDrawRectangle(0, scrH * 0.90, scrW, scrH * 0.10, tocolor(8, 10, 15, math.floor(120 * a)))
    end
end

local function drawTitle(text, a)
    ensureFonts()
    local cx = scrW * 0.5
    local listScreen = (ui.screen == "list")
    local subtitle = listScreen and "CHOOSE YOUR CHARACTER TO CONTINUE"
        or "CREATE YOUR IDENTITY BEFORE YOU ENTER THE CITY"
    local y = math.max(S(34), 12)

    -- soft gold glow behind the wordmark line
    local th = math.max(S(56), 24)
    local scale = 1
    local tw = dxGetTextWidth(text, 1, fonts.title or "default-bold")
    local maxW = scrW * 0.72
    if tw > maxW and tw > 0 then scale = maxW / tw end

    dxDrawText(text, 0, y + S(2), scrW, y + th + S(2),
        tocolor(0, 0, 0, math.floor(180 * a)),
        1 * scale, fonts.title or "default-bold", "center", "center")
    dxDrawText(text, 1, y + 1, scrW + 1, y + th + 1,
        tocolor(0, 0, 0, math.floor(150 * a)),
        1 * scale, fonts.title or "default-bold", "center", "center")
    dxDrawText(text, 0, y, scrW, y + th,
        tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor(255 * a)),
        1 * scale, fonts.title or "default-bold", "center", "center")

    -- tracked subtitle between two gold hairlines
    local subH = math.max(12, S(18))
    local sy = y + th + math.max(2, S(4))
    local subScale = 1
    local subW = dxGetTextWidth(subtitle, 1, fonts.sub or "default")
    local subMax = scrW * 0.76
    if subW > subMax and subW > 0 then subScale = subMax / subW end
    dxDrawText(subtitle, 0, sy, scrW, sy + subH,
        tocolor(206, 208, 214, math.floor(215 * a)),
        subScale, fonts.sub or "default", "center", "center")

    local lineY = sy + subH + math.max(1, S(2))
    local half = math.max(24, S(58))
    local gap = math.max(20, S(150))
    dxDrawRectangle(cx - gap - half, lineY, half, math.max(1, math.floor(S(1) + 0.5)),
        tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor(120 * a)))
    dxDrawRectangle(cx + gap, lineY, half, math.max(1, math.floor(S(1) + 0.5)),
        tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor(120 * a)))
end

local function lineupButtonRects()
    -- 2026-11-18: two black-glass action cards with gold frames, centred as a
    -- group. Real-pixel floors keep them usable on a small MTA window.
    local h  = math.max(S(96), 78)
    local wc = math.max(S(392), 292)
    local wl = math.max(S(300), 224)
    local gap = math.max(S(24), 14)
    -- never let the pair run off a narrow window
    local maxTotal = scrW * 0.94
    local total = wc + wl + gap
    if total > maxTotal then
        local k = maxTotal / total
        wc, wl, gap = wc * k, wl * k, gap * k
        total = maxTotal
    end
    local y = scrH - h - math.max(scrH * 0.075, S(52))
    local x = scrW * 0.5 - total * 0.5
    return { x, y, wc, h }, { x + wc + gap, y, wl, h }
end

local function drawStatus(a)
    if not ui.status then return end
    local age = now() - ui.status.t0
    if age > 5000 then return end
    local fade = age > 3800 and (1 - (age - 3800) / 1200) or 1
    local col = ui.status.ok and { 130, 230, 150 } or { 240, 90, 90 }

    local baseY = scrH - 140
    if ui.screen == "list" then
        local _, lr = lineupButtonRects()
        baseY = lr[2] - 44
    end

    dxDrawText(ui.status.text, 0, baseY, scrW, baseY + 34,
        tocolor(0, 0, 0, math.floor(150 * a * fade)),
        fs(14), "default-bold", "center", "center")
    dxDrawText(ui.status.text, 0, baseY - 1, scrW, baseY + 33,
        tocolor(col[1], col[2], col[3], math.floor(255 * a * fade)),
        fs(14), "default-bold", "center", "center")
end

local function drawLoading(a)
    if ui.loading <= 0 or ui.loading >= 1 then return end
    local w = scrW * 0.34
    local x, y = scrW * 0.5 - w / 2, scrH * 0.55
    dxDrawText("ENTERING LIBERTY CITY...", x, y - 26, x + w, y,
        tocolor(235, 240, 250, math.floor(255 * a)), fs(11), "default-bold", "left", "center")
    dxDrawRectangle(x, y, w, 6, tocolor(40, 46, 58, math.floor(255 * a)))
    dxDrawRectangle(x, y, w * ui.loading, 6, tocolor(ACCENT[1], ACCENT[2], ACCENT[3], math.floor(255 * a)))
end

-- ============================== render: list screen (3D lineup) ==============================

local function drawList(a)
    drawVignette(a)
    drawDecor(a)
    drawTitle("SELECT YOUR CHARACTER", a)
    drawLogo(a)

    local mx, my = getCursorPosition()
    local hasCursor = mx ~= false
    if hasCursor then mx, my = mx * scrW, my * scrH end

    if #ui.chars == 0 then
        ensureFonts()
        dxDrawText("NO CHARACTERS YET - CREATE YOUR FIRST CITIZEN", 0, scrH * 0.20, scrW, scrH * 0.26,
            tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor(230 * a)),
            1, fonts.head or "default-bold", "center", "center")
    end

    -- name plates projected above every standing character
    ui._hits = {}
    ui._hv = ui._hv or {}

    -- keep the latched selection valid if the list changed (delete / refresh)
    local selFound = false
    for i = 1, #ui.chars do
        if ui.chars[i].id == ui._selId then selFound = true break end
    end
    if not selFound then ui._selId = ui.chars[1] and ui.chars[1].id or nil end

    -- pass 1: project the ped line-up so the plates can be sized from the real
    -- on-screen spacing instead of a fixed width (no overlapping plates).
    local proj = {}
    for _, c in ipairs(ui.chars) do
        local lx = c._lineX or LINEUP.x
        local sx, sy = getScreenFromWorldPosition(lx, LINEUP.y, LINEUP.z + 2.15)
        if sx then
            proj[#proj + 1] = { c = c, sx = sx, sy = sy, lx = lx }
        end
    end
    table.sort(proj, function(p, q) return p.sx < q.sx end)

    local minGap = math.huge
    for i = 2, #proj do
        minGap = math.min(minGap, proj[i].sx - proj[i - 1].sx)
    end
    local cardW = math.max(150, math.min(S(232), (minGap < math.huge and minGap * 0.92) or S(232)))
    local cardH = math.max(38, S(64))
    local delSize = math.max(18, cardH * 0.46)
    -- when the line-up is tighter than a plate, neighbouring plates alternate
    -- height so two names can never sit on top of each other
    local staggerStep = (minGap < cardW + 8) and (cardH + math.max(6, S(10))) or 0
    local taper = a

    for idx, p in ipairs(proj) do
        local c, sx, sy = p.c, p.sx, p.sy
        local px = sx - cardW * 0.5
        local stagger = (staggerStep > 0 and idx % 2 == 0) and staggerStep or 0
        local py = sy - cardH + math.max(2, S(5)) - stagger
        local hovered = hasCursor
            and mx >= px and mx <= px + cardW
            and my >= py and my <= py + cardH

        if hovered then ui._selId = c.id end

        local last = ui._hv[c.id] or 0
        local target = hovered and 1 or ((ui._selId == c.id) and 0.45 or 0)
        local hv = last + (target - last) * 0.2
        if math.abs(target - hv) < 0.004 then hv = target end
        ui._hv[c.id] = hv

        -- soft gold halo (selected / hovered only)
        if hv > 0.02 and TEX.ui_card_glow then
            dxDrawImage(
                px - cardW * (18 / 480), py - cardH * (18 / 144),
                cardW * (516 / 480), cardH * (180 / 144),
                TEX.ui_card_glow, 0, 0, 0,
                tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor(195 * hv * taper)))
        end

        -- black glass body + warm gold wash + gold frame
        if TEX.ui_card_fill then
            dxDrawImage(px, py, cardW, cardH, TEX.ui_card_fill, 0, 0, 0,
                tocolor(255, 255, 255, math.floor(250 * taper)))
        else
            dxDrawRectangle(px, py, cardW, cardH, tocolor(10, 12, 17, math.floor(226 * taper)))
        end
        if hv > 0.01 and TEX.ui_card_solid then
            dxDrawImage(px, py, cardW, cardH, TEX.ui_card_solid, 0, 0, 0,
                tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor(18 * hv * taper)))
        end
        glassPanel(px, py, cardW, cardH, taper, {
            fill = false, hot = hv * 0.55, rimAlpha = 120, corners = false,
        })

        -- small gold crown, centred above the plate (always visible)
        local crownS = math.max(11, cardH * 0.24)
        icon("crown", px + cardW * 0.5 - crownS * 0.5, py - crownS - math.max(2, S(4)),
            crownS, (185 + 60 * hv) * taper, LUX.gold)

        local isFemale = (FEMALE_SET[tonumber(c.skin)] == true)
        local padP = math.max(4, cardH * 0.12)
        local iszP = math.max(12, cardH * 0.40)

        -- gender mark
        icon(isFemale and "female" or "male",
            px + padP, py + cardH * 0.5 - iszP * 0.5, iszP,
            (hv > 0.05 and 250 or 165) * taper,
            hv > 0.05 and LUX.gold or { 208, 213, 222 })

        -- name + meta block (real pixels, fitted to the free width)
        local nameX = px + padP + iszP + padP
        local nameW = (px + cardW - delSize - padP * 2) - nameX
        local namePx = math.max(11, cardH * 0.27)
        local metaPx = math.max(8, cardH * 0.155)
        local name = tostring(c.name or "?")
        local nameScale = fitScale(name, nameW, namePx, "default-bold")
        local nameY = py + cardH * 0.10
        dxDrawText(name, nameX + 1, nameY + 1, nameX + nameW, nameY + cardH * 0.44,
            tocolor(0, 0, 0, math.floor(150 * taper)),
            nameScale, "default-bold", "left", "center", true, false)
        dxDrawText(name, nameX, nameY, nameX + nameW, nameY + cardH * 0.44,
            tocolor(246, 248, 251, math.floor(255 * taper)),
            nameScale, "default-bold", "left", "center", true, false)

        local armed = ui.delArm == c.id
        local meta
        if armed then
            meta = "CLICK AGAIN TO DELETE"
        else
            local age = tostring(c.info or ""):match("[Aa]ge (%d+)")
            meta = (isFemale and "FEMALE" or "MALE") .. (age and ("   \194\183   AGE " .. age) or "")
        end
        local metaCol = armed and { 240, 120, 112 }
            or (hv > 0.05 and LUX.goldSoft or LUX.mute)
        local metaScale = fitScale(meta, nameW, metaPx, "default-bold")
        local metaY = py + cardH * 0.55
        dxDrawText(meta, nameX, metaY, nameX + nameW, metaY + cardH * 0.34,
            tocolor(metaCol[1], metaCol[2], metaCol[3], math.floor(240 * taper)),
            metaScale, "default-bold", "left", "center", true, false)

        -- circular delete button (two-click confirm kept intact)
        local dx1 = px + cardW - delSize - padP
        local dy1 = py + cardH * 0.5 - delSize * 0.5
        local near = hovered and 1 or 0
        local armedA = armed
        if armedA then
            if TEX.ui_circle_solid then
                dxDrawImage(dx1, dy1, delSize, delSize, TEX.ui_circle_solid, 0, 0, 0,
                    tocolor(126, 30, 30, math.floor(240 * taper)))
            end
            if TEX.ui_circle_ring then
                dxDrawImage(dx1, dy1, delSize, delSize, TEX.ui_circle_ring, 0, 0, 0,
                    tocolor(226, 92, 86, math.floor(255 * taper)))
            end
        else
            if TEX.ui_circle_fill then
                dxDrawImage(dx1, dy1, delSize, delSize, TEX.ui_circle_fill, 0, 0, 0,
                    tocolor(255, 255, 255, math.floor((140 + 115 * near) * taper)))
            end
            if TEX.ui_circle_ring then
                dxDrawImage(dx1, dy1, delSize, delSize, TEX.ui_circle_ring, 0, 0, 0,
                    tocolor(LUX.gold[1], LUX.gold[2], LUX.gold[3], math.floor((60 + 150 * near) * taper)))
            end
        end
        icon("trash", dx1 + delSize * 0.24, dy1 + delSize * 0.24, delSize * 0.52,
            (armedA and 255 or (135 + 110 * near)) * taper,
            armedA and { 255, 226, 222 } or { 236, 239, 245 })

        table.insert(ui._hits, { r = { dx1, dy1, delSize, delSize }, id = "del", charId = c.id })
        table.insert(ui._hits, { r = { px, py, cardW, cardH }, id = "card", charId = c.id })
        -- body pick zone below the plate (click the character itself)
        local bx, by = getScreenFromWorldPosition(p.lx, LINEUP.y, LINEUP.z + 1.0)
        if bx then
            table.insert(ui._hits, { r = { bx - 65, by - 80, 130, 110 }, id = "card", charId = c.id })
        end
    end

    -- bottom action cards: CREATE NEW CHARACTER / LOG OUT
    local cr, lr = lineupButtonRects()
    local hoveredC = hasCursor and inRect(mx, my, cr)
    local hoveredL = hasCursor and inRect(mx, my, lr)
    ui._hov_create = (ui._hov_create or 0) + ((hoveredC and 1 or 0) - (ui._hov_create or 0)) * 0.2
    ui._hov_logout = (ui._hov_logout or 0) + ((hoveredL and 1 or 0) - (ui._hov_logout or 0)) * 0.2

    drawLuxButton("create", cr, "CREATE NEW CHARACTER", "REGISTER A NEW CHARACTER", "plus", a)
    drawLuxButton("logout", lr, "LOG OUT", "LEAVE THE SERVER", "logout", a)

    table.insert(ui._hits, { r = cr, id = "create" })
    table.insert(ui._hits, { r = lr, id = "logout" })

    drawChat(a)
    drawFooter(a)
end

-- ============================== render: create screen ==============================

local function drawCreate(a)
    drawVignette(a)
    drawDecor(a)
    drawTitle("CHARACTER CREATION", a)
    drawLogo(a)
    dxDrawText("LEFT / RIGHT ARROWS - ROTATE CHARACTER", scrW * 0.5 - 300, scrH * 0.06 + 56,
        scrW * 0.5 + 300, scrH * 0.06 + 84,
        tocolor(226, 190, 116, math.floor(210 * a)), 0.75, "default-bold", "center", "center")
    local mx, my = getCursorPosition()
    local hasCursor = mx ~= false
    if hasCursor then mx, my = mx * scrW, my * scrH end
    local t = now() * 0.001

    -- gender tabs (premium icons)
    local tabs = {}
    for _, g in ipairs({"male", "female"}) do
        local x, y, w, h = genderTabRect(g)
        local active = (g == "male" and ui.gender == 0) or (g == "female" and ui.gender == 1)
        local hovered = hasCursor and inRect(mx, my, {x, y, w, h})
        dxDrawRectangle(x, y, w, h,
            tocolor(active and ACCENT[1] or CARD[1], active and ACCENT[2] or CARD[2],
                active and ACCENT[3] or CARD[3], math.floor((active and 240 or (hovered and 235 or 195)) * a)))
        icon(g, x + 10, y + h / 2 - 13, 26,
            255 * a, active and {12, 18, 28} or {235, 240, 248})
        dxDrawText(g == "male" and "MALE" or "FEMALE", x + 34, y, x + w, y + h,
            tocolor(active and 12 or 235, active and 18 or 240, active and 28 or 248, math.floor(255 * a)),
            0.95, "default-bold", "center", "center")
        tabs[g] = {x, y, w, h}
    end

    -- bottom glass panel (premium generated texture)
    local bx, by, bw, bh = bottomPanelRect()
    if TEX.panel then
        dxDrawImage(bx, by, bw, bh, TEX.panel, 0, 0, 0, tocolor(255, 255, 255, math.floor(255 * a)))
    else
        dxDrawRectangle(bx, by, bw, bh, tocolor(CARD[1], CARD[2], CARD[3], math.floor(215 * a)))
        dxDrawRectangle(bx, by, bw, 3, tocolor(ACCENT[1], ACCENT[2], ACCENT[3], math.floor(200 * a)))
    end

    -- name fields
    for _, f in ipairs({"first", "last"}) do
        local x, y, w, h = fieldRect(f)
        local active = ui.focus == f
        dxDrawRectangle(x, y, w, h,
            tocolor(active and 32 or 24, active and 42 or 29, active and 62 or 42, math.floor(255 * a)))
        dxDrawRectangle(x, y, w, 2,
            tocolor(ACCENT[1], ACCENT[2], ACCENT[3], math.floor((active and 255 or 90) * a)))
        local label = f == "first" and "First name" or "Last name"
        local val = ui[f]
        local caret = active and (math.floor(t * 2) % 2 == 0 and "|" or "") or ""
        local shown = val == "" and (active and "|" or label) or (val .. caret)
        dxDrawText(shown, x + 10, y, x + w - 10, y + h,
            tocolor(val == "" and 135 or 240, val == "" and 145 or 244, val == "" and 160 or 252, math.floor(255 * a)),
            0.95, "default-bold", "left", "center")
    end

    -- age slider
    local ax, ay, aw, ah = ageRect()
    icon("calendar", ax, ay - 30, 20, 255 * a)
    dxDrawText("AGE  " .. ui.age, ax + 26, ay - 22, ax + aw, ay,
        tocolor(225, 230, 240, math.floor(255 * a)), 0.85, "default-bold", "left", "center")
    dxDrawRectangle(ax, ay, aw, ah, tocolor(45, 52, 66, math.floor(255 * a)))
    local frac = (ui.age - 18) / 62
    dxDrawRectangle(ax, ay, aw * frac, ah, tocolor(ACCENT[1], ACCENT[2], ACCENT[3], math.floor(200 * a)))
    local kx = ax + aw * frac
    dxDrawRectangle(kx - 7, ay - 5, 14, ah + 10, tocolor(240, 244, 252, math.floor(255 * a)))
    ui._ageRect = {ax, ay - 10, aw, ah + 20}

    -- appearance: face carousel for BOTH genders (HD pack for males)
    local sx, sy, sw, sh = skinRect()
    local hoveredL = hasCursor and inRect(mx, my, {sx - 70, sy, 60, sh})
    local hoveredR = hasCursor and inRect(mx, my, {sx + sw + 10, sy, 60, sh})
    icon("chev_left", sx - 70, sy, 60, (hoveredL and 255 or 215) * a)
    dxDrawRectangle(sx, sy, sw, sh, tocolor(30, 38, 52, math.floor(255 * a)))
    dxDrawText(SKIN_NAMES[currentSkin()] or tostring(currentSkin()), sx, sy - 2, sx + sw, sy + sh,
        tocolor(240, 244, 252, math.floor(255 * a)), 0.8, "default-bold", "center", "center")
    icon("chev_right", sx + sw + 10, sy, 60, (hoveredR and 255 or 215) * a)
    local hitsMid = {
        { r = {sx - 70, sy, 60, sh}, id = "skinPrev" },
        { r = {sx + sw + 10, sy, 60, sh}, id = "skinNext" },
    }

    -- action buttons (premium icons)
    local cbx, cby, cbw, cbh = createBtnRect()
    local bkx, bky, bw2, bh2 = backBtnRect()
    local rnx, rny, rnw, rnh = randomBtnRect()

    -- 2026-11-18: the whole row shares one label size, derived from the button
    -- height and fitted to the tightest label, so CREATE / BACK / RANDOM match.
    local rowPx = math.max(14, cbh * 0.36)
    local baseScale = pxScale(rowPx)
    local btnScale = baseScale
    for _, item in ipairs({
        { "CREATE CHARACTER", cbw - 50 },
        { "BACK  (ESC)",      bw2 - 40 },
        { "RANDOM NAME",      rnw - 40 },
    }) do
        local room = item[2]
        local tw = dxGetTextWidth(item[1], baseScale, "default-bold")
        if room > 0 and tw > room then
            btnScale = math.min(btnScale, baseScale * (room / tw))
        end
    end

    local hoveredB = hasCursor and inRect(mx, my, {cbx, cby, cbw, cbh})
    dxDrawRectangle(cbx, cby, cbw, cbh, tocolor(ACCENT[1], ACCENT[2], ACCENT[3], math.floor((hoveredB and 255 or 225) * a)))
    icon("plus", cbx + 14, cby + cbh / 2 - 15, 30, 255 * a, {12, 18, 28})
    dxDrawText("CREATE CHARACTER", cbx + 40, cby, cbx + cbw - 10, cby + cbh,
        tocolor(12, 18, 28, math.floor(255 * a)), btnScale, "default-bold", "center", "center")

    local hoveredK = hasCursor and inRect(mx, my, {bkx, bky, bw2, bh2})
    dxDrawRectangle(bkx, bky, bw2, bh2, tocolor(hoveredK and 72 or 46, hoveredK and 80 or 54, hoveredK and 100 or 70, math.floor(215 * a)))
    icon("chev_left", bkx + 12, bky + bh2 / 2 - 13, 26, 255 * a)
    dxDrawText("BACK  (ESC)", bkx + 30, bky, bkx + bw2, bky + bh2,
        tocolor(235, 240, 248, math.floor(255 * a)), btnScale, "default-bold", "center", "center")

    local hoveredR2 = hasCursor and inRect(mx, my, {rnx, rny, rnw, rnh})
    dxDrawRectangle(rnx, rny, rnw, rnh, tocolor(hoveredR2 and 72 or 46, hoveredR2 and 80 or 54, hoveredR2 and 100 or 70, math.floor(215 * a)))
    icon("dice", rnx + 12, rny + rnh / 2 - 13, 26, 255 * a)
    dxDrawText("RANDOM NAME", rnx + 30, rny, rnx + rnw, rny + rnh,
        tocolor(235, 240, 248, math.floor(255 * a)), btnScale, "default-bold", "center", "center")

    ui._hits = {
        {r = tabs.male, id = "male"},
        {r = tabs.female, id = "female"},
        {r = {cbx, cby, cbw, cbh}, id = "createGo"},
        {r = {bkx, bky, bw2, bh2}, id = "back"},
        {r = {rnx, rny, rnw, rnh}, id = "random"},
        {r = {fieldRect("first")}, id = "fieldFirst"},
        {r = {fieldRect("last")}, id = "fieldLast"},
    }
    for _, h in ipairs(hitsMid) do table.insert(ui._hits, h) end
end

-- ============================== main draw ==============================

local function draw()
    if not ui.open then return end
    local ok, err = pcall(function()
        local a = alphaIn() / 255
        updateCamera()
        -- NativeUI draws its own GTA V menu; the old DX create form must not
        -- render on top of it. Keep only the 3D LC ped turntable behind it.
        if (ui.screen == "create" or ui.screen == "native") and isElement(previewPed) then
            -- Face the camera by default; LEFT/RIGHT arrows rotate manually.
            setElementRotation(previewPed, 0, 0, ui.turn)
        end
        drawStudioLights(a)
        if ui.screen == "list" then
            -- NativeUI renders the saved-character menu; only follow its
            -- highlight so the single 3D preview matches the chosen slot.
            if syncNativeSelectorHighlight then syncNativeSelectorHighlight() end
        elseif ui.screen == "create" then
            drawCreate(a)
        end
        drawStatus(a)
        drawLoading(a)
    end)
    if not ok then
        outputDebugString("[ng-characters][client] draw error: " .. tostring(err), 1)
    end
end

-- 2026-11-16 FIX: draw() was never bound to the render event - the UI opened
-- but nothing ever drew ("nothing appears" after login). Bound once here.
addEventHandler("onClientRender", root, draw, false)

-- server messages are captured while the selection screen is open and drawn
-- inside the gold-framed feed (the default chatbox is hidden at that point).
addEventHandler("onClientChatMessage", root, function(text, r, g, b)
    if not ui.open or ui.screen ~= "list" or not text then return end
    table.insert(ui.chat, { text = tostring(text), r = r or 235, g = g or 238, b = b or 244, t0 = now() })
    while #ui.chat > 6 do table.remove(ui.chat, 1) end
end)

-- never leave the default chatbox hidden if this resource is stopped/reloaded
addEventHandler("onClientResourceStop", root, function(res)
    if res ~= getThisResource() then return end
    if closeNativeCreator then closeNativeCreator() end
    if closeNativeSelector then closeNativeSelector() end
    showChat(true)
end)

-- ============================== clicks ==============================

local function tryCreate()
    if #ui.first < 2 or #ui.last < 2 then
        setStatus("Enter a first and last name.", false)
        return
    end
    ui.loading = 0.01
    triggerServerEvent("ngc:createChar", localPlayer, ui.first, ui.last, ui.gender, currentSkin(), ui.age)
end

-- ============================== GTA V NativeUI creator ==============================
-- Replacement for the old click-only DX form. The foundation is the downloaded
-- MTA-RAGE-NativeUI resource; this resource owns the character data and keeps
-- the untouched ngc:createChar server contract.

local AGE_CHOICES = { 18, 21, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80 }
local nativeUI = { menu = nil, items = {} }
local selectorUI = { menu = nil, items = {}, charItems = {} }

local function nativeReady()
    local res = getResourceFromName(NATIVEUI_RES)
    return res ~= false and getResourceState(res) == "running" and exports[NATIVEUI_RES] ~= nil
end

local function addNativeEx(fn, ...)
    local ex = exports[NATIVEUI_RES]
    if not ex then error("NativeUI resource is not running") end
    return ex[fn](ex, ...)
end

-- NativeUI fills its whole window with the background image/color. The saved-
-- character selector uses "assets/defaultbg.png". For the creator we pass NO
-- image and a fully transparent color instead, so the menu keeps the EXACT same
-- button style while the luxury 3D LC studio stays visible behind it.
local TRANSPARENT_MENU_BG = tocolor(0, 0, 0, 0)

local function ageChoiceIndex()
    for i, v in ipairs(AGE_CHOICES) do
        if v == ui.age then return i end
    end
    for i, v in ipairs(AGE_CHOICES) do
        if v > ui.age then return i end
    end
    return #AGE_CHOICES
end

local function skinChoices()
    local list = skins()
    local names = {}
    for i, s in ipairs(list) do
        names[i] = string.format("%02d  %s", i, SKIN_NAMES[s] or tostring(s))
    end
    return names
end

refreshNativeText = function()
    local menu = nativeUI.menu
    if not menu or not isElement(menu) or not nativeReady() then return end
    if not nativeUI.items.first or not isElement(nativeUI.items.first) then return end
    local firstMark = (ui.focus == "first" and "> " or "   ") .. "FIRST NAME: " ..
        ((ui.first ~= "" and ui.first) or "-")
    local lastMark = (ui.focus == "last" and "> " or "   ") .. "LAST NAME: " ..
        ((ui.last ~= "" and ui.last) or "-")
    pcall(function()
        addNativeEx("setNativeItemText", menu, nativeUI.items.first, firstMark)
        addNativeEx("setNativeItemText", menu, nativeUI.items.last, lastMark)
    end)
end

closeNativeCreator = function()
    local menu = nativeUI.menu
    nativeUI.menu = nil
    nativeUI.items = {}
    if menu and isElement(menu) and nativeReady() then
        pcall(function() addNativeEx("destroyNativeMenu", menu) end)
    end
    if ui.screen == "native" then ui.focus = nil end
end

local function buildNativeMenu()
    if not nativeReady() then
        setStatus("NativeUI resource is not running.", false)
        return
    end
    closeNativeCreator()

    local ok, menu = pcall(function()
        return addNativeEx("createNativeUI",
            "LmB  //  CHARACTER CREATOR",
            "IDENTITY   /   APPEARANCE   /   Q+E ROTATE",
            false,
            TRANSPARENT_MENU_BG,
            tocolor(226, 190, 116),
            tocolor(240, 244, 252),
            "center", true, 9, "center")
    end)
    if not ok or not isElement(menu) then
        setStatus("NativeUI failed to open: " .. tostring(menu), false)
        return
    end
    nativeUI.menu = menu

    local white = tocolor(255, 255, 255)
    local items = nativeUI.items

    items.first = addNativeEx("addNativeButton", menu, "FIRST NAME", white)
    items.last  = addNativeEx("addNativeButton", menu, "LAST NAME", white)
    items.gender = addNativeEx("addNativeSwitch", menu, "GENDER", white, { "Male", "Female" })
    items.age = addNativeEx("addNativeSwitch", menu, "AGE", white,
        { [1] = "18", [2] = "21", [3] = "25", [4] = "30", [5] = "35", [6] = "40",
          [7] = "45", [8] = "50", [9] = "55", [10] = "60", [11] = "70", [12] = "80" })
    items.skin = addNativeEx("addNativeSwitch", menu, "APPEARANCE", white, skinChoices())
    items.rotate = addNativeEx("addNativeButton", menu, "ROTATE CHARACTER", white, "art")
    items.random = addNativeEx("addNativeButton", menu, "RANDOM NAME", white, "art")
    items.create = addNativeEx("addNativeButton", menu, "CREATE CHARACTER", white, "accept")
    items.back = addNativeEx("addNativeButton", menu, "BACK TO CHARACTERS", white)

    addNativeEx("setNativeSwitchSelection", menu, items.gender, ui.gender + 1)
    addNativeEx("setNativeSwitchSelection", menu, items.age, ageChoiceIndex())
    addNativeEx("setNativeSwitchSelection", menu, items.skin, ui.skinIndex)

    addEventHandler("onClientAcceptButton", items.first, function()
        ui.focus = "first"
        refreshNativeText()
    end)
    addEventHandler("onClientAcceptButton", items.last, function()
        ui.focus = "last"
        refreshNativeText()
    end)

    addEventHandler("onClientChangeNativeSwitch", items.gender, function(value)
        local g = tostring(value) == "Female" and 1 or 0
        if g ~= ui.gender then
            ui.gender, ui.skinIndex = g, 1
            if isElement(previewPed) then setElementModel(previewPed, currentSkin()) end
            buildNativeMenu()
        end
    end)

    addEventHandler("onClientChangeNativeSwitch", items.age, function(value)
        ui.age = tonumber(value) or ui.age
    end)

    addEventHandler("onClientChangeNativeSwitch", items.skin, function(value)
        local choices = skinChoices()
        for i, name in ipairs(choices) do
            if name == tostring(value) then
                ui.skinIndex = i
                if isElement(previewPed) then setElementModel(previewPed, currentSkin()) end
                break
            end
        end
    end)

    addEventHandler("onClientAcceptButton", items.rotate, function()
        ui.turn = (ui.turn + 45) % 360
    end)

    addEventHandler("onClientAcceptButton", items.random, function()
        local firsts = ui.gender == 1 and RANDOM_FIRST_F or RANDOM_FIRST_M
        ui.first = firsts[math.random(#firsts)]
        ui.last = RANDOM_LAST[math.random(#RANDOM_LAST)]
        refreshNativeText()
    end)

    addEventHandler("onClientAcceptButton", items.create, function()
        pcall(function() addNativeEx("setNativeMenuVisible", menu, false) end)
        tryCreate()
    end)

    addEventHandler("onClientAcceptButton", items.back, function()
        if #ui.chars > 0 then
            openList()
        else
            setStatus("Create your first character to continue.", false)
        end
    end)

    refreshNativeText()
end

openNativeCreator = function()
    ui.open = true
    ui.screen = "native"
    ui.loading = 0
    ui.focus = "first"
    ui.status = nil
    ui._hits = {}
    ui.t0 = now()
    ui.turn = 0
    showCursor(false)
    showChat(true)
    enterWorldView()
    destroyLineup()
    buildPreview()
    local viewZ = (studioBaseZ or STUDIO.z) + PREVIEW_Z_LIFT
    flyCameraTo(
        STUDIO.x - 0.4, STUDIO.y + 4.0, viewZ + 1.25,
        STUDIO.x, STUDIO.y, viewZ + 0.85, 1100)
    buildNativeMenu()
    logToServer("list: CREATE button - luxury LC studio opened (NativeUI buttons)")
end

-- ============================== GTA V saved-character selector ==============================

local function charShortMeta(c)
    local isFemale = FEMALE_SET[tonumber(c.skin)] == true
    local age = tostring(c.info or ""):match("[Aa]ge (%d+)")
    return (isFemale and "FEMALE" or "MALE") .. (age and ("   |   AGE " .. age) or "")
end

local function charItemLabel(c, idx, selected)
    return (selected and ">> " or "   ") .. string.format("%02d  %s   %s",
        idx, tostring(c.name or "?"), charShortMeta(c))
end

refreshNativeSelector = function()
    local menu = selectorUI.menu
    if not menu or not isElement(menu) or not nativeReady() then return end
    local sel = getSelectedChar()
    pcall(function()
        for idx, entry in ipairs(selectorUI.charItems) do
            addNativeEx("setNativeItemText", menu, entry.element,
                charItemLabel(entry.char, idx, sel and entry.char.id == sel.id))
        end
        if selectorUI.items.play and isElement(selectorUI.items.play) then
            addNativeEx("setNativeItemText", menu, selectorUI.items.play,
                sel and ("PLAY  >  " .. tostring(sel.name or "?")) or "PLAY CHARACTER")
        end
        if selectorUI.items.delete and isElement(selectorUI.items.delete) then
            addNativeEx("setNativeItemText", menu, selectorUI.items.delete,
                (sel and ui.delArm == sel.id) and "CONFIRM DELETE" or "DELETE CHARACTER")
        end
    end)
end

syncNativeSelectorHighlight = function()
    local menu = selectorUI.menu
    if not menu or not isElement(menu) or not nativeReady() then return end
    local ok, idx = pcall(function() return addNativeEx("getNativeMenuActiveIndex", menu) end)
    if not ok then return end
    idx = tonumber(idx)
    if not idx then return end
    local entry = selectorUI.charItems[idx]
    if not entry then return end
    if entry.char.id ~= ui._selId then
        ui._selId = entry.char.id
        ui.delArm = nil
        buildSelectedPreview()
        refreshNativeSelector()
    end
end

closeNativeSelector = function()
    local menu = selectorUI.menu
    selectorUI.menu = nil
    selectorUI.items = {}
    selectorUI.charItems = {}
    if menu and isElement(menu) and nativeReady() then
        pcall(function() addNativeEx("destroyNativeMenu", menu) end)
    end
end

local function buildNativeSelector()
    if not nativeReady() then
        setStatus("NativeUI resource is not running.", false)
        return
    end
    closeNativeSelector()

    local ok, menu = pcall(function()
        return addNativeEx("createNativeUI",
            "LmB  //  CHARACTERS",
            "SELECT A SAVED CHARACTER",
            "assets/defaultbg.png",
            false,
            tocolor(226, 190, 116),
            tocolor(240, 244, 252),
            "left", true, 8, "center")
    end)
    if not ok or not isElement(menu) then
        setStatus("NativeUI selector failed to open: " .. tostring(menu), false)
        return
    end
    selectorUI.menu = menu

    local white = tocolor(255, 255, 255)
    local items = selectorUI.items

    selectorUI.charItems = {}
    for i, c in ipairs(ui.chars) do
        local btn = addNativeEx("addNativeButton", menu, charItemLabel(c, i, false), white)
        selectorUI.charItems[i] = { element = btn, char = c }
        addEventHandler("onClientAcceptButton", btn, function()
            ui._selId = c.id
            ui.delArm = nil
            buildSelectedPreview()
            refreshNativeSelector()
        end)
    end

    items.play = addNativeEx("addNativeButton", menu, "PLAY CHARACTER", white, "accept")
    items.delete = addNativeEx("addNativeButton", menu, "DELETE CHARACTER", white)
    items.create = addNativeEx("addNativeButton", menu, "CREATE NEW CHARACTER", white, "art")
    items.logout = addNativeEx("addNativeButton", menu, "LOG OUT", white)

    addEventHandler("onClientAcceptButton", items.play, function()
        local c = getSelectedChar()
        if not c then
            setStatus("No saved character selected.", false)
            return
        end
        ui.loading = 0.05
        triggerServerEvent("ngc:selectChar", localPlayer, c.id)
    end)

    addEventHandler("onClientAcceptButton", items.delete, function()
        local c = getSelectedChar()
        if not c then
            setStatus("No saved character selected.", false)
            return
        end
        if ui.delArm ~= c.id then
            ui.delArm = c.id
            setStatus("Press DELETE again to confirm.", true)
            refreshNativeSelector()
        else
            ui.delArm = nil
            triggerServerEvent("ngc:deleteChar", localPlayer, c.id)
        end
    end)

    addEventHandler("onClientAcceptButton", items.create, function()
        openCreate()
    end)

    addEventHandler("onClientAcceptButton", items.logout, function()
        triggerServerEvent("ngc:logout", localPlayer)
    end)

    refreshNativeSelector()
end

openNativeSelector = function()
    if not nativeReady() then
        setStatus("NativeUI resource is not running.", false)
        return
    end
    buildNativeSelector()
    logToServer("NativeUI saved-character selector opened (" .. #ui.chars .. " chars)")
end

addEventHandler("onClientClick", root, function(button, state, cx, cy)
    if ui.screen == "native" or ui.screen == "list" then return end
    if not ui.open or button ~= "left" or state ~= "down" then return end
    for _, h in ipairs(ui._hits or {}) do
        if inRect(cx, cy, h.r) then
            -- gta4gg: press animation trigger for the luxury buttons
            if h.id == "create" or h.id == "logout" then
                ui._press = { id = h.id, t0 = now() }
            end
            if h.id == "card" then
                ui.loading = 0.05
                triggerServerEvent("ngc:selectChar", localPlayer, h.charId)
            elseif h.id == "del" then
                if ui.delArm == h.charId then
                    ui.delArm = nil
                    triggerServerEvent("ngc:deleteChar", localPlayer, h.charId)
                else
                    ui.delArm = h.charId
                end
            elseif h.id == "create" then
                openCreate()
                logToServer("list: CREATE button - luxury LC studio opened")
            elseif h.id == "logout" then
                triggerServerEvent("ngc:logout", localPlayer)
            elseif h.id == "male" or h.id == "female" then
                local g = h.id == "female" and 1 or 0
                if g ~= ui.gender then
                    ui.gender, ui.skinIndex = g, 1
                    if isElement(previewPed) then setElementModel(previewPed, currentSkin()) end
                end
            elseif h.id == "skinPrev" then
                ui.skinIndex = ui.skinIndex - 1
                if ui.skinIndex < 1 then ui.skinIndex = #skins() end
                if isElement(previewPed) then setElementModel(previewPed, currentSkin()) end
            elseif h.id == "skinNext" then
                ui.skinIndex = ui.skinIndex + 1
                if ui.skinIndex > #skins() then ui.skinIndex = 1 end
                if isElement(previewPed) then setElementModel(previewPed, currentSkin()) end
            elseif h.id == "createGo" then
                tryCreate()
            elseif h.id == "back" then
                if #ui.chars > 0 then openList() else setStatus("Create a character to continue.", false) end
            elseif h.id == "random" then
                local firsts = ui.gender == 1 and RANDOM_FIRST_F or RANDOM_FIRST_M
                ui.first = firsts[math.random(#firsts)]
                ui.last = RANDOM_LAST[math.random(#RANDOM_LAST)]
            elseif h.id == "fieldFirst" then
                ui.focus = "first"
            elseif h.id == "fieldLast" then
                ui.focus = "last"
            end
            return
        end
    end
    ui.focus = nil
end)

-- age slider: click anywhere on the track sets the age
addEventHandler("onClientClick", root, function(button, state, cx, cy)
    if not ui.open or ui.screen ~= "create" or button ~= "left" or state ~= "down" then return end
    local r = ui._ageRect
    if inRect(cx, cy, r) then
        local frac = math.max(0, math.min(1, (cx - r[1]) / r[3]))
        ui.age = math.floor(18 + frac * 62 + 0.5)
        ui.focus = nil
    end
end)

-- ============================== typing ==============================

addEventHandler("onClientCharacter", root, function(ch)
    if not ui.open or not ui.focus then return end
    if ui.screen ~= "create" and ui.screen ~= "native" then return end
    if ch and ch:match("%a") then
        appendName(ui.focus, ch)
        if ui.screen == "native" then refreshNativeText() end
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not ui.open or not press then return end

    if ui.screen == "native" then
        -- Arrows + Enter belong to NativeUI. Only name editing/back handling
        -- is owned by this resource here.
        if key == "escape" then
            if #ui.chars > 0 then openList() end
            return
        end
        if key == "q" or key == "e" then
            ui.turn = (ui.turn + ((key == "q") and -15 or 15)) % 360
            cancelEvent()
            return
        end
        if key == "tab" then
            ui.focus = ui.focus == "first" and "last" or "first"
            refreshNativeText()
            cancelEvent()
            return
        end
        if key == "backspace" and ui.focus then
            ui[ui.focus] = ui[ui.focus]:sub(1, -2)
            refreshNativeText()
            cancelEvent()
        end
        return
    end

    if key == "escape" then
        if ui.screen == "create" and #ui.chars > 0 then openList() end
        return
    end
    if ui.screen ~= "create" then return end
    if key == "left" or key == "a" or key == "right" or key == "d" then
        ui.turn = (ui.turn + ((key == "left" or key == "a") and -15 or 15)) % 360
        cancelEvent()
        return
    end
    if key == "enter" then
        tryCreate()
        return
    end
    if key == "tab" then
        ui.focus = ui.focus == "first" and "last" or "first"
        cancelEvent()
        return
    end
    if key == "backspace" and ui.focus then
        ui[ui.focus] = ui[ui.focus]:sub(1, -2)
        cancelEvent()
    end
end)

-- loading bar cosmetics while the server prepares the spawn
setTimer(function()
    if ui.open and ui.loading > 0 and ui.loading < 1 then
        ui.loading = math.min(1, ui.loading + 0.02)
    end
end, 120, 0)

-- ============================== events from server ==============================

addEvent("ngc:showCharList", true)
addEventHandler("ngc:showCharList", root, function(list, level, manual)
    ui.chars = list or {}
    ui.level = level or 0
    ui.open = true
    ui.loading = 0
    showCursor(true)
    fadeCamera(true, 1.0)
    if #ui.chars == 0 and not manual then
        -- Replacement creator: always use the NativeUI GTA V screen.
        openCreate()
        logToServer("charList: 0 chars - NativeUI creator opened")
    else
        openList()
        logToServer("charList: " .. #ui.chars .. " chars - LIST screen opened")
    end
end)

-- server accepted the character and is waiting for the GTA V city sync
-- (spawn-area pre-load) before spawning: start the loading bar cosmetics
addEvent("ngc:cityPreparing", true)
addEventHandler("ngc:cityPreparing", root, function()
    ui.open = true
    ui.loading = 0.05
    logToServer("cityPreparing: waiting for the city sync (loading bar started)")
end)

addEvent("ngc:charSpawned", true)
addEventHandler("ngc:charSpawned", root, function()
    closeAll()
    ui.loading = 0
    setCameraTarget(localPlayer, localPlayer)
    fadeCamera(true, 1.0)
    RP:notify("Character loaded. Press F1 for help.", 74, 163, 255)
end)

addEvent("ngc:status", true)
addEventHandler("ngc:status", root, function(text, ok)
    setStatus(text, ok)
    if not ok then
        ui.loading = 0
        if ui.screen == "native" and nativeUI.menu and isElement(nativeUI.menu) and nativeReady() then
            pcall(function() addNativeEx("setNativeMenuVisible", nativeUI.menu, true) end)
        elseif ui.screen == "list" and selectorUI.menu and isElement(selectorUI.menu) and nativeReady() then
            pcall(function() addNativeEx("setNativeMenuVisible", selectorUI.menu, true) end)
        end
    end
    RP:notify(text, ok and 130 or 240, ok and 230 or 90, ok and 150 or 90)
end)

-- restart-safe: when this resource (re)starts, ask the server to re-send the
-- char list if we are logged-in-but-not-spawned (same pattern as ng-login2)
addEventHandler("onClientResourceStart", root, function(res)
    if res ~= getThisResource() then return end
    setTimer(function()
        if getElementData(localPlayer, "account.id") and not getElementData(localPlayer, "char.spawned") then
            triggerServerEvent("ngc:uiRequest", localPlayer)
        end
    end, 1500, 1)
end)
