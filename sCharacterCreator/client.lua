--[[
    sCharacterCreator / client
    ------------------------------------------------------------------
    Standalone character creator with a 3D preview and a boarding-pass UI.
    It does not depend on sGui, sBinco, sAccounts or any custom framework.
]]

local E = CC.ui.errors

local active = false
local phase = "idle" -- editing | saving | done | closing
local nameText = ""
local gender = 1
local skinIndex = { 1, 1 }
local previewPed = false
local idleTimer = false
local errorText = ""
local errorUntil = 0
local startTick = 0
local finishTick = 0
local closingTick = 0
local character = false
local saved = false
local submitTimer = false

local fonts = {}
local fontsUnit = 0

-- 2026-11-17 gta4gg fix: screenX/screenY were referenced but never defined,
-- which crashed every draw/layout/font call and left the 3D scene with no UI.
local screenX, screenY = guiGetScreenSize()

-- Forward declarations: these handlers are referenced before their bodies
-- appear further down the file.
local drawInterface, keepCamera, onCharacter, onKey, onClick, cancelDamage, stopCreation

local COL = {
    paper = tocolor(243, 238, 227, 255),
    paperDark = tocolor(224, 216, 199, 255),
    ink = tocolor(35, 40, 37, 255),
    inkSoft = tocolor(103, 109, 104, 255),
    accent = tocolor(43, 122, 83, 255),
    accentLight = tocolor(56, 150, 103, 255),
    accentDark = tocolor(31, 90, 61, 255),
    white = tocolor(255, 255, 255, 255),
    whiteSoft = tocolor(255, 255, 255, 190),
    red = tocolor(184, 54, 54, 255),
    shadow = tocolor(0, 0, 0, 120),
}

local WHITE = COL.white

-- ------------------------------------------------------------------
-- Fancy UI assets (gta4gg): gradient button textures + OpenMoji icons
-- ------------------------------------------------------------------
local TEX, ICO = {}, {}
local function buildUiAssets()
    if TEX.btnGreen and isElement(TEX.btnGreen) then return end
    TEX.btnGreen      = dxCreateTexture("ui/btn_green.png", "argb", true, "clamp")
    TEX.btnGreenHover = dxCreateTexture("ui/btn_green_hover.png", "argb", true, "clamp")
    TEX.btnGreenDim   = dxCreateTexture("ui/btn_green_dim.png", "argb", true, "clamp")
    TEX.btnCream      = dxCreateTexture("ui/btn_cream.png", "argb", true, "clamp")
    TEX.btnCreamHover = dxCreateTexture("ui/btn_cream_hover.png", "argb", true, "clamp")
    ICO.male     = dxCreateTexture("ui/icons/male.png", "argb", true, "clamp")
    ICO.female   = dxCreateTexture("ui/icons/female.png", "argb", true, "clamp")
    -- pure-white silhouettes: tinted at draw time so the icons stay readable
    -- on the black-glass buttons (the originals are dark grey)
    ICO.maleWhite   = dxCreateTexture("ui/icons/male_white.png", "argb", true, "clamp")
    ICO.femaleWhite = dxCreateTexture("ui/icons/female_white.png", "argb", true, "clamp")
    ICO.planeWhite  = dxCreateTexture("ui/icons/plane_white.png", "argb", true, "clamp")
    -- white arrow silhouettes, tinted gold / ink at draw time
    ICO.arrowLeft   = dxCreateTexture("ui/icons/arrow_left_white.png", "argb", true, "clamp")
    ICO.arrowRight  = dxCreateTexture("ui/icons/arrow_right_white.png", "argb", true, "clamp")
    ICO.check    = dxCreateTexture("ui/icons/check.png", "argb", true, "clamp")
    ICO.star     = dxCreateTexture("ui/icons/star.png", "argb", true, "clamp")
    ICO.crown    = dxCreateTexture("ui/icons/crown.png", "argb", true, "clamp")
    ICO.plane    = dxCreateTexture("ui/icons/plane.png", "argb", true, "clamp")
    ICO.card     = dxCreateTexture("ui/icons/card.png", "argb", true, "clamp")
    ICO.suitcase = dxCreateTexture("ui/icons/suitcase.png", "argb", true, "clamp")
    -- GTA-style city / palm silhouettes shared with the character-select screen
    TEX.city     = dxCreateTexture("deco_city.png", "argb", true, "clamp")
    TEX.palm     = dxCreateTexture("deco_palm.png", "argb", true, "clamp")
end

-- ------------------------------------------------------------------
-- Small helpers
-- ------------------------------------------------------------------

local function font(name)
    local value = fonts[name]

    if value and isElement(value) then
        return value
    end

    return "default-bold"
end

local function textWidth(text, fontElement)
    return dxGetTextWidth(tostring(text), 1, fontElement, false)
end

local function drawText(text, x, y, width, height, color, fontElement, alignX, alignY, clip)
    dxDrawText(
        tostring(text),
        x, y, x + width, y + height,
        color, 1, fontElement,
        alignX or "left", alignY or "top",
        clip and true or false, false, false, false
    )
end

local function getSkinList()
    return (gender == 1) and CC.skins.male or CC.skins.female
end

local function getSelectedSkin()
    local list = getSkinList()
    local index = skinIndex[gender]

    if index < 1 then
        index = 1
    elseif index > #list then
        index = #list
    end

    skinIndex[gender] = index

    return list[index] or list[1] or 0
end

local function getRandomIdle()
    local idles = CC.scene.idles

    return idles[math.random(#idles)]
end

local function showError(message)
    errorText = tostring(message or E.generic)
    errorUntil = getTickCount() + 4000
end

local function normalizeName(raw)
    if type(raw) ~= "string" then
        return nil, E.characters
    end

    raw = raw:gsub("_", " ")
    raw = raw:gsub("%s+", " ")
    raw = raw:gsub("^%s+", "")
    raw = raw:gsub("%s+$", "")

    if raw == "" then
        return nil, E.tooShort
    end

    local parts = {}

    for word in raw:gmatch("%S+") do
        if not word:match("^[A-Za-z]+$") then
            return nil, E.characters
        end

        parts[#parts + 1] = word:sub(1, 1):upper() .. word:sub(2):lower()
    end

    if #parts < CC.name.minParts or #parts > CC.name.maxParts then
        return nil, E.parts
    end

    local normalized = table.concat(parts, "_")

    if #normalized < CC.name.minLength then
        return nil, E.tooShort
    end

    if #normalized > CC.name.maxLength then
        return nil, E.tooLong
    end

    return normalized
end

-- ------------------------------------------------------------------
-- Fonts
-- ------------------------------------------------------------------

local function buildFonts()
    -- 2026-11-18: floor the design unit so a small MTA window still gets a
    -- legible registration panel instead of a shrunken 1080p sheet.
    local unit = math.max(screenY / 1080, 0.72)

    if fonts.body and math.abs(fontsUnit - unit) < 0.01 then
        return
    end

    fontsUnit = unit

    for key, element in pairs(fonts) do
        if isElement(element) then
            destroyElement(element)
        end
        fonts[key] = nil
    end

    local function create(file, size, minSize)
        local element = dxCreateFont(file, math.max(minSize or 8, math.floor(size * unit)))
        return element or false
    end

    fonts.title = create("fonts/Constantia.ttf", 44, 26)
    fonts.head = create("fonts/BebasNeueRegular.otf", 26, 15)
    fonts.stamp = create("fonts/BebasNeueRegular.otf", 56)
    fonts.body = create("fonts/Ubuntu-L.ttf", 15)
    fonts.bold = create("fonts/Ubuntu-B.ttf", 15)
    fonts.small = create("fonts/Ubuntu-L.ttf", 12)
    -- the name field is typed text, so it uses a clean bold sans (the receipt
    -- mono face was hard to read once the panel went dark)
    fonts.mono = create("fonts/Ubuntu-B.ttf", 18, 11)
    -- 2026-11-18: button labels get a real-pixel floor (10px) and a larger
    -- base size, so the glass buttons keep readable text on a small window
    fonts.button = create("fonts/Ubuntu-B.ttf", 16, 10)
    fonts.logo = create("fonts/Constantia-Italic.ttf", 40, 22)
end

-- LmB wordmark + gold crown, top-right of the screen
local function drawBrand()
    local f = font("logo")
    if not f then return end
    local text = "LmB"
    local tw = textWidth(text, f)
    local x = screenX - 40 * math.max(screenY / 1080, 0.72) - tw
    local y = 26 * math.max(screenY / 1080, 0.72)

    if ICO.crown and isElement(ICO.crown) then
        dxDrawImage(x + tw * 0.5 - 11 * math.max(screenY / 1080, 0.72),
            y - 15 * math.max(screenY / 1080, 0.72),
            22 * math.max(screenY / 1080, 0.72), 22 * math.max(screenY / 1080, 0.72),
            ICO.crown, 0, 0, 0, tocolor(226, 190, 116, 240))
    end

    dxDrawText(text, x + 1, y + 2, x + tw + 1, y + 48, tocolor(0, 0, 0, 170), 1, f, "left", "top")
    dxDrawText(text, x, y, x + tw, y + 46, tocolor(246, 222, 174, 255), 1, f, "left", "top")
    dxDrawText("R O L E P L A Y", x - 14, y + 42, x + tw + 16, y + 60,
        tocolor(168, 174, 186, 210), 1, font("small"), "center", "top")
end

-- GTA city + palms behind the registration panel (same decor as the picker)
local function drawAmbient()
    local sw, sh = guiGetScreenSize()

    if TEX.city and isElement(TEX.city) then
        local dh = math.min(sh * 0.30, 260)
        dxDrawImage(0, sh - dh, sw, dh, TEX.city, 0, 0, 0, tocolor(255, 255, 255, 110))
    end

    if TEX.palm and isElement(TEX.palm) then
        local ph = math.min(sh * 0.44, 420)
        local pw = ph * (520 / 760)
        local py = sh - ph * 0.90

        dxDrawImage(-pw * 0.14, py, pw, ph, TEX.palm, 0, 0, 0, tocolor(255, 255, 255, 85))
        dxDrawImage(sw - pw * 0.86, py, pw, ph, TEX.palm, 0, 0, 0, tocolor(255, 255, 255, 85))
    end
end

-- ------------------------------------------------------------------
-- Scene
-- ------------------------------------------------------------------

local function applySkinModel()
    if not previewPed or not isElement(previewPed) then
        return
    end

    setElementModel(previewPed, getSelectedSkin())

    setTimer(function()
        if previewPed and isElement(previewPed) and active then
            setPedAnimation(previewPed, "playidles", getRandomIdle(), -1, false, false)
        end
    end, 80, 1)
end

local function setGender(newGender)
    if newGender ~= 1 and newGender ~= 2 then
        return
    end

    gender = newGender
    applySkinModel()
end

local function previousSkin()
    local index = skinIndex[gender]

    if index > 1 then
        skinIndex[gender] = index - 1
        applySkinModel()
    end
end

local function nextSkin()
    local index = skinIndex[gender]
    local total = #getSkinList()

    if index < total then
        skinIndex[gender] = index + 1
        applySkinModel()
    end
end

-- ------------------------------------------------------------------
-- Layout
-- ------------------------------------------------------------------

local function getLayout()
    local unit = math.max(screenY / 1080, 0.72)
    local width = math.min(1000 * unit, screenX * 0.92)
    local height = width * 0.315
    local x = (screenX - width) / 2
    local padding = 28 * unit

    -- 2026-11-18: the registration panel now sits above a full action row:
    -- BACK TO SELECTION (left) | CONTINUE (right), matching the reference.
    local btnH = math.max(44 * unit, 34)
    local btnGap = math.max(16 * unit, 10)
    local btnSpace = math.max(18 * unit, 12)
    local margin = math.max(44 * unit, 20)
    local y = screenY - height - margin - btnH - btnGap

    local mainWidth = width * 0.72
    local stubX = x + mainWidth
    local stubWidth = width - mainWidth
    local controlsY = y - 58 * unit
    local btnW = (width - padding * 2 - btnSpace) / 2
    local btnY = y + height + btnGap

    return {
        unit = unit,
        x = x,
        y = y,
        w = width,
        h = height,
        pad = padding,
        mainW = mainWidth,
        stubX = stubX,
        stubW = stubWidth,
        name = {
            x = x + padding,
            y = y + 96 * unit,
            w = mainWidth - padding * 2,
            h = 46 * unit,
        },
        male = {
            x = x + padding,
            y = controlsY,
            w = 142 * unit,
            h = 40 * unit,
        },
        female = {
            x = x + padding + 150 * unit,
            y = controlsY,
            w = 142 * unit,
            h = 40 * unit,
        },
        previous = {
            x = stubX + padding,
            y = controlsY,
            w = 44 * unit,
            h = 40 * unit,
        },
        skin = {
            x = stubX + padding + 52 * unit,
            y = controlsY,
            w = stubWidth - padding * 2 - 104 * unit,
            h = 40 * unit,
        },
        next = {
            x = stubX + stubWidth - padding - 44 * unit,
            y = controlsY,
            w = 44 * unit,
            h = 40 * unit,
        },
        back = {
            x = x + padding,
            y = btnY,
            w = btnW,
            h = btnH,
        },
        submit = {
            x = x + width - padding - btnW,
            y = btnY,
            w = btnW,
            h = btnH,
        },
        cancel = {
            x = screenX - 54 * unit,
            y = 20 * unit,
            w = 34 * unit,
            h = 34 * unit,
        },
    }
end

-- 2026-11-17 gta4gg fix: isMouseInPosition was used but never defined
-- (same class of bug as the missing screenX/screenY) - it crashed every
-- frame right after the title, hiding all buttons and input.
-- NOTE: it MUST be defined BEFORE isMouseOver, otherwise the call inside
-- isMouseOver resolves to a nil global and crashes at runtime.
local function isMouseInPosition(x, y, w, h)
    if not isCursorShowing() then
        return false
    end
    local cx, cy = getCursorPosition()
    if not cx then
        return false
    end
    cx, cy = cx * screenX, cy * screenY
    return cx >= x and cx <= x + w and cy >= y and cy <= y + h
end

local function isMouseOver(rect)
    return isMouseInPosition(rect.x, rect.y, rect.w, rect.h)
end

-- ------------------------------------------------------------------
-- Drawing
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- 2026-11-18 gta4gg: premium black-glass controls.
-- Drawn procedurally (gradient body + gold rim + 3D edge + gloss) instead
-- of stretched bitmaps, so they stay crisp from 640x480 up to 4K and match
-- the gold/black UI used on the character-select screen.
-- ------------------------------------------------------------------
local GLASS = {
    top      = { 47, 50, 58 },
    mid      = { 25, 27, 33 },
    bottom   = { 8, 9, 12 },
    edge     = { 3, 4, 6 },
    rimIdle  = { 96, 92, 78 },
    gold     = { 226, 190, 116 },
    red      = { 214, 92, 86 },
    text     = { 238, 241, 247 },
    textGold = { 246, 222, 174 },
    textMute = { 150, 154, 164 },
}

local function mix(a, b, t)
    return a[1] + (b[1] - a[1]) * t,
           a[2] + (b[2] - a[2]) * t,
           a[3] + (b[3] - a[3]) * t
end

-- button press feedback (set on mouse-down, fades after 130 ms)
local pressKey, pressTick = nil, 0
local function markPress(key)
    pressKey, pressTick = key, getTickCount()
end
local function isPressed(key)
    return key ~= nil and pressKey == key and (getTickCount() - pressTick) <= 130
end

-- state: { active, hover, disabled, pressed, static, accent = "gold"|"red" }
local function drawGlassPanel(rect, state)
    state = state or {}
    local x, y, w, h = rect.x, rect.y, rect.w, rect.h
    local u = math.max(1, h / 40)
    local lw = math.max(1, math.floor(u * 1.2 + 0.5))
    local press = (state.pressed and not state.disabled) and math.max(1, u) or 0
    local depth = math.max(2, math.floor(3 * u + 0.5)) - math.floor(press)
    local A = state.disabled and 175 or 255
    local accent = (state.accent == "red") and GLASS.red or GLASS.gold
    local hot = (state.hover or state.active or state.static) and not state.disabled

    -- soft outer glow on hover / selection
    if hot then
        for i = 3, 1, -1 do
            dxDrawRectangle(x - i * u, y - i * u, w + i * 2 * u, h + i * 2 * u,
                tocolor(accent[1], accent[2], accent[3], 9))
        end
    end

    -- drop shadow + 3D thickness under the top face
    dxDrawRectangle(x + 1 * u, y + h + math.max(1, depth), w, math.max(2, 3 * u),
        tocolor(0, 0, 0, math.floor(85 * A / 255)))

    local by = y + press
    local bands = 8

    for i = 0, bands - 1 do
        local t = i / (bands - 1)
        local r, g, b
        if t < 0.5 then
            r, g, b = mix(GLASS.top, GLASS.mid, t * 2)
        else
            r, g, b = mix(GLASS.mid, GLASS.bottom, (t - 0.5) * 2)
        end
        dxDrawRectangle(x, by + h * i / bands, w, h / bands + 1,
            tocolor(math.floor(r), math.floor(g), math.floor(b),
                math.floor((state.disabled and 205 or 238) * A / 255)))
    end

    -- side face below the top face: the 3D "key" edge
    if depth > 0 then
        dxDrawRectangle(x, by + h, w, depth,
            tocolor(GLASS.edge[1], GLASS.edge[2], GLASS.edge[3], A))
    end

    -- rim: dim steel-gold at rest, bright gold/red when hot
    local rr, rg, rb = accent[1], accent[2], accent[3]
    if not hot then
        rr, rg, rb = GLASS.rimIdle[1], GLASS.rimIdle[2], GLASS.rimIdle[3]
    end
    local rimA = math.floor((hot and 225 or (state.disabled and 70 or 150)) * A / 255)
    local rim = tocolor(rr, rg, rb, rimA)
    dxDrawRectangle(x, by, w, lw, rim)
    dxDrawRectangle(x, by + h - lw, w, lw, rim)
    dxDrawRectangle(x, by, lw, h, rim)
    dxDrawRectangle(x + w - lw, by, lw, h, rim)

    -- glass treatment: top highlight, bottom inner shade, upper sheen
    dxDrawRectangle(x + lw, by + lw, w - lw * 2, lw,
        tocolor(255, 255, 255, math.floor(46 * A / 255)))
    dxDrawRectangle(x + lw, by + h - lw * 2, w - lw * 2, lw,
        tocolor(0, 0, 0, math.floor(120 * A / 255)))
    dxDrawRectangle(x + lw, by + lw, w - lw * 2, math.max(1, h * 0.42),
        tocolor(255, 255, 255, math.floor(10 * A / 255)))

    -- selected tab marker
    if state.active then
        local mh = math.max(2, math.floor(2 * u + 0.5))
        dxDrawRectangle(x + lw * 2, by + h - lw - mh, w - lw * 4, mh,
            tocolor(accent[1], accent[2], accent[3], math.floor(210 * A / 255)))
    end
end

local function glassLabel(text, rect, state, fontElement)
    state = state or {}
    local u = math.max(1, rect.h / 40)
    local hot = (state.hover or state.active or state.static) and not state.disabled
    local col = state.disabled and GLASS.textMute or (hot and GLASS.textGold or GLASS.text)
    local f = fontElement or font("button")
    local a = state.disabled and 200 or 255

    dxDrawText(tostring(text), rect.x, rect.y + u, rect.x + rect.w, rect.y + rect.h + u,
        tocolor(0, 0, 0, math.floor(150 * a / 255)), 1, f, "center", "center")
    dxDrawText(tostring(text), rect.x, rect.y, rect.x + rect.w, rect.y + rect.h,
        tocolor(col[1], col[2], col[3], a), 1, f, "center", "center")
end

local function drawPill(rect, label, selected, disabled, key)
    local hover = (not disabled) and isMouseOver(rect)
    drawGlassPanel(rect, {
        active = selected, hover = hover, disabled = disabled,
        pressed = key and isPressed(key), accent = "gold",
    })

    local u = rect.h / 40
    local icon
    if label == CC.ui.male then
        icon = ICO.maleWhite or ICO.male
    elseif label == CC.ui.female then
        icon = ICO.femaleWhite or ICO.female
    end

    local hot = selected or hover
    local col = disabled and GLASS.textMute or (hot and GLASS.textGold or GLASS.text)
    local shift = 0

    if icon and isElement(icon) then
        local isz = 26 * u
        dxDrawImage(rect.x + 10 * u, rect.y + rect.h / 2 - isz / 2, isz, isz, icon,
            0, 0, 0, tocolor(col[1], col[2], col[3], disabled and 190 or 255))
        shift = 18 * u
    end

    glassLabel(label, {
        x = rect.x + shift, y = rect.y, w = rect.w - shift, h = rect.h,
    }, { active = selected, hover = hover, disabled = disabled })
end

local function drawArrow(rect, symbol, disabled, key)
    local hover = isMouseOver(rect) and not disabled
    drawGlassPanel(rect, {
        hover = hover, disabled = disabled,
        pressed = key and isPressed(key), accent = "gold",
    })

    local hot = hover and not disabled
    local col = disabled and GLASS.textMute or (hot and GLASS.textGold or GLASS.text)
    local a = disabled and 200 or 255

    dxDrawText(symbol, rect.x, rect.y - 1, rect.x + rect.w, rect.y + rect.h - 1,
        tocolor(0, 0, 0, math.floor(140 * a / 255)), 1, font("head"), "center", "center")
    dxDrawText(symbol, rect.x, rect.y - 2, rect.x + rect.w, rect.y + rect.h - 2,
        tocolor(col[1], col[2], col[3], a), 1, font("head"), "center", "center")
end

local function drawBarcode(x, y, width, height, seed)
    local rng = math.max(1, math.floor(seed))
    local cursor = x

    while cursor < x + width do
        rng = (rng * 1103515245 + 12345) % 2147483648
        local lineWidth = 1 + (rng % 3)
        local ratio = 0.65 + ((rng / 2147483648) % 0.35)
        local lineHeight = height * ratio

        if cursor + lineWidth > x + width then
            break
        end

        dxDrawRectangle(cursor, y + (height - lineHeight) / 2, lineWidth, lineHeight, COL.ink)
        cursor = cursor + lineWidth + 2
    end
end

-- 2026-11-18 LmB: charcoal glass registration panel with a gold frame
local function drawRegPanel(x, y, w, h, u)
    dxDrawRectangle(x + 6 * u, y + 8 * u, w, h, tocolor(0, 0, 0, 120))

    local bands = 10

    for i = 0, bands - 1 do
        local t = i / (bands - 1)
        local r, g, b

        if t < 0.5 then
            r, g, b = mix({ 40, 43, 51 }, { 24, 27, 34 }, t * 2)
        else
            r, g, b = mix({ 24, 27, 34 }, { 9, 10, 13 }, (t - 0.5) * 2)
        end
        dxDrawRectangle(x, y + h * i / bands, w, h / bands + 1,
            tocolor(math.floor(r), math.floor(g), math.floor(b), 226))
    end

    -- upper sheen + bottom shade
    dxDrawRectangle(x, y, w, math.max(1, h * 0.38), tocolor(255, 255, 255, 10))
    dxDrawRectangle(x, y + h - math.max(1, h * 0.12), w, math.max(1, h * 0.12), tocolor(0, 0, 0, 60))

    local lw = math.max(1, math.floor(u * 1.5 + 0.5))
    local rim = tocolor(GLASS.gold[1], GLASS.gold[2], GLASS.gold[3], 185)

    dxDrawRectangle(x, y, w, lw, rim)
    dxDrawRectangle(x, y + h - lw, w, lw, rim)
    dxDrawRectangle(x, y, lw, h, rim)
    dxDrawRectangle(x + w - lw, y, lw, h, rim)

    -- inner hairline
    dxDrawRectangle(x + lw, y + lw, w - lw * 2, 1, tocolor(255, 255, 255, 26))

    -- gold corner brackets
    local cl = math.max(10, 22 * u)
    local ct = math.max(2, math.floor(2 * u + 0.5))
    local cc = tocolor(GLASS.gold[1], GLASS.gold[2], GLASS.gold[3], 240)

    dxDrawRectangle(x, y, cl, ct, cc)
    dxDrawRectangle(x, y, ct, cl, cc)
    dxDrawRectangle(x + w - cl, y, cl, ct, cc)
    dxDrawRectangle(x + w - ct, y, ct, cl, cc)
    dxDrawRectangle(x, y + h - ct, cl, ct, cc)
    dxDrawRectangle(x, y + h - cl, ct, cl, cc)
    dxDrawRectangle(x + w - cl, y + h - ct, cl, ct, cc)
    dxDrawRectangle(x + w - ct, y + h - cl, ct, cl, cc)
end

-- shared two-line label block: title on top, small description underneath
local function actionText(tx, ty, avail, h, title, desc, titleCol, descCol)
    local fTitle = font("button")
    local fDesc = font("small")
    local sTitle = 1
    local sDesc = 1
    local tw = textWidth(title, fTitle)

    if tw > avail and tw > 0 then sTitle = avail / tw end

    local dw = textWidth(desc, fDesc)

    if dw > avail and dw > 0 then sDesc = avail / dw end

    dxDrawText(title, tx, ty, tx + avail, ty + h * 0.58, titleCol, sTitle, fTitle, "left", "center")
    dxDrawText(desc, tx, ty + h * 0.46, tx + avail, ty + h * 0.94, descCol, sDesc, fDesc, "left", "center")
end

-- polished champagne-gold call-to-action (dark ink + right arrow)
local function drawGoldButton(rect, title, desc, enabled, hover, pressed)
    local x, y, w, h = rect.x, rect.y, rect.w, rect.h
    local u = math.max(1, h / 44)
    local dp = (pressed and enabled) and math.max(1, 2 * u) or 0
    local by = y + dp

    dxDrawRectangle(x + 2 * u, y + h + math.max(1, 3 * u), w, math.max(2, 4 * u), tocolor(0, 0, 0, 110))

    local bands = 7

    for i = 0, bands - 1 do
        local t = i / (bands - 1)
        local r, g, b

        if enabled then
            r, g, b = mix({ 250, 224, 162 }, { 176, 136, 68 }, t)
            if hover then
                local rr, gg, bb = mix({ 255, 236, 186 }, { 198, 158, 90 }, t)
                r, g, b = rr, gg, bb
            end
        else
            r, g, b = mix({ 108, 99, 83 }, { 66, 60, 50 }, t)
        end
        dxDrawRectangle(x, by + h * i / bands, w, h / bands + 1,
            tocolor(math.floor(r), math.floor(g), math.floor(b), 255))
    end

    local lw = math.max(1, math.floor(u + 0.5))
    local rim = tocolor(255, 240, 200, enabled and 220 or 90)

    dxDrawRectangle(x, by, w, lw, rim)
    dxDrawRectangle(x, by + h - lw, w, lw, tocolor(120, 88, 40, 200))
    dxDrawRectangle(x, by, lw, h, rim)
    dxDrawRectangle(x + w - lw, by, lw, h, rim)
    dxDrawRectangle(x + lw, by + lw, w - lw * 2, math.max(1, h * 0.30), tocolor(255, 255, 255, 55))

    local ink = enabled and tocolor(24, 18, 8, 255) or tocolor(205, 200, 190, 200)
    local ink2 = enabled and tocolor(78, 60, 26, 240) or tocolor(176, 171, 162, 170)

    local isz = h * 0.40
    local ix = x + h * 0.20

    if ICO.arrowRight and isElement(ICO.arrowRight) then
        dxDrawImage(ix, by + h / 2 - isz / 2, isz, isz, ICO.arrowRight, 0, 0, 0, ink)
    end

    local tx = ix + isz + h * 0.20
    local avail = x + w - h * 0.18 - tx

    actionText(tx, by, avail, h, title, desc, ink, ink2)
end

-- charcoal glass "back" card: gold rim, left arrow, title + description
local function drawBackButton(rect, title, desc, hover, pressed)
    drawGlassPanel(rect, {
        hover = hover, pressed = pressed, accent = "gold", static = false,
    })

    local x, y, w, h = rect.x, rect.y, rect.w, rect.h
    local u = math.max(1, h / 40)
    local by = y + ((pressed and 1) or 0) * math.max(1, 2 * u)
    local isz = h * 0.38
    local ix = x + h * 0.20
    local gold = tocolor(226, 190, 116, 255)

    if ICO.arrowLeft and isElement(ICO.arrowLeft) then
        dxDrawImage(ix, by + h / 2 - isz / 2, isz, isz, ICO.arrowLeft, 0, 0, 0, gold)
    end

    local tx = ix + isz + h * 0.20
    local avail = x + w - h * 0.18 - tx
    local titleCol = hover and tocolor(246, 222, 174, 255) or tocolor(238, 241, 247, 255)
    local descCol = hover and tocolor(226, 200, 150, 235) or tocolor(158, 164, 176, 225)

    actionText(tx, by, avail, h, title, desc, titleCol, descCol)
end

local function drawTicket(layout)
    local u = layout.unit
    local x, y, w, h = layout.x, layout.y, layout.w, layout.h
    local pad = layout.pad
    local mainW = layout.mainW

    drawRegPanel(x, y, w, h, u)

    -- header: card mark + gold registration title
    if ICO.card and isElement(ICO.card) then
        dxDrawImage(x + pad, y + 15 * u, 28 * u, 28 * u, ICO.card, 0, 0, 0,
            tocolor(226, 190, 116, 240))
    end
    drawText("CHARACTER REGISTRATION", x + pad + 38 * u, y + 13 * u,
        mainW - pad * 2 - 40 * u, 30 * u, tocolor(246, 222, 174, 255), font("head"))
    drawText("ENLIST YOUR CITIZEN IN LmB ROLEPLAY", x + pad + 38 * u, y + 42 * u,
        mainW - pad * 2 - 40 * u, 18 * u, tocolor(160, 166, 178, 230), font("small"))

    dxDrawRectangle(x + pad, y + 66 * u, w - pad * 2, math.max(1, u),
        tocolor(226, 190, 116, 95))

    -- FIRST NAME field
    local field = layout.name

    drawText("FIRST NAME", x + pad, field.y - 18 * u, mainW - pad * 2, 14 * u,
        tocolor(200, 178, 128, 235), font("small"))

    dxDrawRectangle(field.x, field.y, field.w, field.h, tocolor(8, 9, 12, 225))
    dxDrawRectangle(field.x, field.y, field.w, math.max(1, u), tocolor(255, 255, 255, 24))
    dxDrawRectangle(field.x, field.y, math.max(1, 3 * u), field.h, tocolor(226, 190, 116, 220))
    dxDrawRectangle(field.x, field.y + field.h - math.max(1, 2 * u), field.w,
        math.max(1, 2 * u), tocolor(226, 190, 116, 220))

    local shown = nameText

    if shown == "" then
        shown = CC.ui.namePlaceholder
    end

    local textColor = (nameText == "") and tocolor(128, 132, 142, 230) or tocolor(244, 246, 250, 255)

    dxDrawText(
        shown,
        field.x + 14 * u, field.y,
        field.x + field.w - 14 * u, field.y + field.h,
        textColor, 1, font("mono"), "left", "center",
        true, false, false, false
    )

    -- caret
    if phase == "editing" and math.floor(getTickCount() / 500) % 2 == 0 then
        local caretX = field.x + 14 * u + textWidth(nameText, font("mono"))
        dxDrawRectangle(caretX + 1, field.y + field.h * 0.24, math.max(1, 2 * u),
            field.h * 0.52, tocolor(246, 222, 174, 240))
    end

    local hintColor = tocolor(150, 156, 168, 230)
    local hintText = CC.ui.nameHint

    if getTickCount() < errorUntil and errorText ~= "" then
        hintColor = tocolor(228, 112, 104, 255)
        hintText = errorText
    end

    drawText(hintText, x + pad, field.y + field.h + 7 * u, mainW - pad * 2, 16 * u,
        hintColor, font("small"))

    -- lower data row: DATE / GENDER inside the main column
    local rowY = y + 198 * u
    local now = getRealTime()
    local col2 = x + pad + mainW * 0.46

    drawText("DATE", x + pad, rowY, mainW * 0.4, 13 * u,
        tocolor(200, 178, 128, 225), font("small"))
    drawText(string.format("%04d.%02d.%02d", now.year + 1900, now.month + 1, now.monthday),
        x + pad, rowY + 15 * u, mainW * 0.4, 22 * u, tocolor(242, 245, 250, 255), font("bold"))

    drawText("GENDER", col2, rowY, mainW * 0.4, 13 * u,
        tocolor(200, 178, 128, 225), font("small"))
    drawText(gender == 1 and CC.ui.male or CC.ui.female, col2, rowY + 15 * u, mainW * 0.4, 22 * u,
        tocolor(242, 245, 250, 255), font("bold"))

    -- gold hairlines under the data values
    dxDrawRectangle(x + pad, rowY + 36 * u, mainW * 0.40, math.max(1, u), tocolor(226, 190, 116, 70))
    dxDrawRectangle(col2, rowY + 36 * u, mainW * 0.40, math.max(1, u), tocolor(226, 190, 116, 70))

    -- stub column: FLIGHT
    drawText("FLIGHT", layout.stubX + pad, y + 20 * u, layout.stubW - pad * 2, 14 * u,
        tocolor(200, 178, 128, 225), font("small"))
    drawText(CC.ui.flight, layout.stubX + pad, y + 36 * u, layout.stubW - pad * 2, 34 * u,
        tocolor(246, 222, 174, 255), font("head"))
    dxDrawRectangle(layout.stubX + pad, y + 74 * u, layout.stubW - pad * 2, math.max(1, u),
        tocolor(226, 190, 116, 70))

    -- approved stamp
    if (phase == "done" or phase == "closing") and finishTick > 0 then
        local progress = math.min((getTickCount() - finishTick) / 280, 1)
        local alpha = math.floor(225 * progress)
        local centerX = x + w * 0.86
        local centerY = y + h * 0.42

        dxDrawText(
            CC.ui.approved,
            centerX - 220 * u, centerY - 44 * u,
            centerX + 220 * u, centerY + 44 * u,
            tocolor(184, 54, 54, alpha), 1, font("stamp"),
            "center", "center", false, false, false, false,
            0, -12, centerX, centerY
        )
    end
end

drawInterface = function()
    local layout = getLayout()
    local u = layout.unit

    dxDrawRectangle(0, 0, screenX, screenY, tocolor(0, 0, 0, 95))
    drawAmbient()

    -- title
    dxDrawText(CC.ui.title, 62 * u + 2, 46 * u + 2, screenX, 60 * u, tocolor(0, 0, 0, 170), 1, font("title"))
    drawText(CC.ui.title, 62 * u, 46 * u, screenX, 60 * u, tocolor(246, 222, 174, 255), font("title"))
    drawText(CC.ui.subtitle, 64 * u, 96 * u, screenX * 0.7, 24 * u, COL.whiteSoft, font("body"))
    dxDrawRectangle(62 * u, 126 * u, 120 * u, math.max(1, u), tocolor(226, 190, 116, 150))
    drawBrand()

    -- controls above the ticket
    drawPill(layout.male, CC.ui.male, gender == 1, phase ~= "editing", "male")
    drawPill(layout.female, CC.ui.female, gender == 2, phase ~= "editing", "female")

    drawArrow(layout.previous, "<", phase ~= "editing", "prevSkin")
    drawArrow(layout.next, ">", phase ~= "editing", "nextSkin")

    -- skin counter: static glass capsule between the two arrows
    drawGlassPanel(layout.skin, { static = true, disabled = (phase ~= "editing"), accent = "gold" })
    local skinLabel = CC.ui.skin .. "  " .. skinIndex[gender] .. " / " .. #getSkinList()
    if textWidth(skinLabel, font("button")) > layout.skin.w - 10 * u then
        skinLabel = skinIndex[gender] .. " / " .. #getSkinList()
    end
    glassLabel(skinLabel, layout.skin, { static = true, disabled = (phase ~= "editing") })

    drawTicket(layout)

    -- bottom action row: BACK TO SELECTION | CONTINUE
    local back = layout.back
    local backHover = isMouseOver(back) and phase == "editing"
    drawBackButton(back, CC.ui.back or "BACK TO SELECTION",
        CC.ui.backDesc or "RETURN TO CHARACTER LIST", backHover, isPressed("back"))

    local submit = layout.submit
    local submitHover = isMouseOver(submit) and phase == "editing"
    local submitLabel = CC.ui.next
    local submitDesc = CC.ui.nextDesc or "CREATE CHARACTER"

    if phase == "saving" then
        submitLabel = CC.ui.saving
        submitDesc = CC.ui.checking or ""
    elseif phase == "done" or phase == "closing" then
        submitLabel = CC.ui.approved
        submitDesc = ""
    end

    drawGoldButton(submit, submitLabel, submitDesc, phase == "editing",
        submitHover, isPressed("submit"))

    if CC.allowCancel and phase == "editing" then
        local cancel = layout.cancel
        local hover = isMouseOver(cancel)
        drawGlassPanel(cancel, { hover = hover, pressed = isPressed("cancel"), accent = "red" })
        glassLabel("X", cancel, { hover = hover }, font("bold"))
    end

    -- fade in / out
    local overlay = 0

    if startTick > 0 then
        overlay = 255 * (1 - math.min((getTickCount() - startTick) / 650, 1))
    end

    if phase == "closing" and closingTick > 0 then
        overlay = math.max(overlay, 255 * math.min((getTickCount() - closingTick) / 600, 1))
    end

    if overlay > 0 then
        dxDrawRectangle(0, 0, screenX, screenY, tocolor(0, 0, 0, math.floor(overlay)))
    end
end

-- ------------------------------------------------------------------
-- Start / stop
-- ------------------------------------------------------------------

local function addInputHandlers()
    addEventHandler("onClientRender", root, drawInterface, true, "high+50")
    addEventHandler("onClientPreRender", root, keepCamera)
    addEventHandler("onClientCharacter", root, onCharacter)
    addEventHandler("onClientKey", root, onKey)
    addEventHandler("onClientClick", root, onClick)
    addEventHandler("onClientPlayerDamage", localPlayer, cancelDamage)
end

local function removeInputHandlers()
    removeEventHandler("onClientRender", root, drawInterface)
    removeEventHandler("onClientPreRender", root, keepCamera)
    removeEventHandler("onClientCharacter", root, onCharacter)
    removeEventHandler("onClientKey", root, onKey)
    removeEventHandler("onClientClick", root, onClick)
    removeEventHandler("onClientPlayerDamage", localPlayer, cancelDamage)
end

function startCreation()
    if active then
        return false
    end

    if not localPlayer or not isElement(localPlayer) then
        return false
    end

    active = true
    phase = "editing"
    character = false
    nameText = ""
    gender = 1
    skinIndex = { 1, 1 }
    errorText = ""
    errorUntil = 0
    startTick = getTickCount()
    finishTick = 0
    closingTick = 0
    submitTimer = false

    local hour, minute = getTime()
    local px, py, pz = getElementPosition(localPlayer)
    local rx, ry, rz = getElementRotation(localPlayer)

    saved = {
        x = px,
        y = py,
        z = pz,
        rx = rx,
        ry = ry,
        rz = rz,
        interior = getElementInterior(localPlayer),
        dimension = getElementDimension(localPlayer),
        alpha = getElementAlpha(localPlayer),
        frozen = isElementFrozen(localPlayer),
        hour = hour,
        minute = minute,
        farClip = getFarClipDistance and getFarClipDistance() or false,
        fog = getFogDistance and getFogDistance() or false,
        target = getCameraTarget and getCameraTarget() or false,
        chat = isChatVisible and isChatVisible() or true,
        cursor = isCursorShowing(),
    }

    if CC.hideHud then
        setPlayerHudComponentVisible("all", false)
    end

    showChat(false)
    showCursor(true)
    setElementFrozen(localPlayer, true)
    setElementAlpha(localPlayer, 0)
    setElementInterior(localPlayer, CC.scene.interior)
    -- 2026-11-17: dimension stays as the ng-characters park dimension -
    -- world models (incl. interior 14) render in every dimension, so the
    -- indoor studio is visible without touching other players.
    setElementPosition(localPlayer, 250.0, -35.0, 1002.0)
    setTime(CC.scene.time.hour, CC.scene.time.minute)
    setFarClipDistance(1200)
    setFogDistance(500)

    previewPed = createPed(
        getSelectedSkin(),
        CC.scene.ped.x,
        CC.scene.ped.y,
        CC.scene.ped.z,
        CC.scene.ped.rotation
    )

    if previewPed and isElement(previewPed) then
        setElementInterior(previewPed, CC.scene.interior)
        setElementDimension(previewPed, saved.dimension)
        setPedAnimation(previewPed, "playidles", getRandomIdle(), -1, false, false)
    end

    setCameraMatrix(
        CC.scene.camera.x,
        CC.scene.camera.y,
        CC.scene.camera.z,
        CC.scene.camera.lookX,
        CC.scene.camera.lookY,
        CC.scene.camera.lookZ
    )

    buildFonts()
    buildUiAssets()

    if idleTimer and isTimer(idleTimer) then
        killTimer(idleTimer)
    end

    idleTimer = setTimer(function()
        if active and previewPed and isElement(previewPed) then
            setPedAnimation(previewPed, "playidles", getRandomIdle(), -1, false, false)
        end
    end, 6000, 0)

    addInputHandlers()

    return true
end

function isCreationActive()
    return active
end

stopCreation = function(reason, opts)
    if not active then
        return
    end

    opts = (type(opts) == "table") and opts or {}

    active = false
    phase = "idle"

    removeInputHandlers()

    if idleTimer and isTimer(idleTimer) then
        killTimer(idleTimer)
    end

    idleTimer = false

    if submitTimer and isTimer(submitTimer) then
        killTimer(submitTimer)
    end

    submitTimer = false

    if previewPed and isElement(previewPed) then
        destroyElement(previewPed)
    end

    previewPed = false

    if saved then
        -- 2026-11-18 CRASH FIX (gta_sa.exe+0x1381A5 access violation):
        -- returning to the picker must NOT restore the pre-creator camera /
        -- position. That snapshot is the empty park spot (0,0,0) and calling
        -- setCameraTarget(localPlayer) from there made the game interpolate a
        -- camera out of the sea, which hard-crashed the client as soon as the
        -- character list re-opened. The creator studio is the same room the
        -- picker uses, so on "keepWorld" we stay in the studio, remain
        -- invisible (alpha 0) and let ng-characters fly its own list camera.
        if not opts.keepWorld then
            setElementAlpha(localPlayer, saved.alpha or 255)
            setElementInterior(localPlayer, saved.interior or 0)
            setElementDimension(localPlayer, saved.dimension or 0)
            setElementPosition(localPlayer, saved.x, saved.y, saved.z)
            setElementRotation(localPlayer, saved.rx, saved.ry, saved.rz)
            setElementFrozen(localPlayer, saved.frozen and true or false)

            if saved.target and isElement(saved.target) then
                setCameraTarget(saved.target)
            else
                setCameraTarget(localPlayer)
            end
        end

        if saved.hour and saved.minute then
            setTime(saved.hour, saved.minute)
        end

        if saved.farClip then
            setFarClipDistance(saved.farClip)
        end

        if saved.fog then
            setFogDistance(saved.fog)
        end

        showChat(saved.chat and true or false)

        if CC.hideHud then
            setPlayerHudComponentVisible("all", true)
        end

        showCursor(saved.cursor and true or false)
    end

    saved = false

    if reason == "created" then
        triggerServerEvent("cc:finished", localPlayer)
    elseif reason == "cancelled" then
        triggerServerEvent("cc:cancelled", localPlayer)
    end

    triggerEvent("onClientCharacterCreationFinished", localPlayer, character, reason)
end

-- ------------------------------------------------------------------
-- Camera
-- ------------------------------------------------------------------

keepCamera = function()
    if not active then
        return
    end

    setCameraMatrix(
        CC.scene.camera.x,
        CC.scene.camera.y,
        CC.scene.camera.z,
        CC.scene.camera.lookX,
        CC.scene.camera.lookY,
        CC.scene.camera.lookZ
    )
end

cancelDamage = function()
    cancelEvent()
end

-- ------------------------------------------------------------------
-- Input
-- ------------------------------------------------------------------

local function submit()
    if phase ~= "editing" then
        return
    end

    local normalized, reason = normalizeName(nameText)

    if not normalized then
        showError(reason)
        return
    end

    phase = "saving"
    errorText = ""
    triggerServerEvent("cc:create", localPlayer, normalized, getSelectedSkin(), gender)

    if submitTimer and isTimer(submitTimer) then
        killTimer(submitTimer)
    end

    submitTimer = setTimer(function()
        if active and phase == "saving" then
            phase = "editing"
            showError(E.database)
        end
    end, 8000, 1)
end

onCharacter = function(characterPressed)
    if not active or phase ~= "editing" then
        return
    end

    if characterPressed == " " then
        if nameText == "" or nameText:sub(-1) == " " then
            return
        end
    elseif not characterPressed:match("^[A-Za-z]$") then
        showError(E.characters)
        return
    end

    if #nameText >= 30 then
        return
    end

    nameText = nameText .. characterPressed
    errorText = ""
end

-- ------------------------------------------------------------------
-- BACK TO SELECTION (2026-11-18)
-- Closes the creator without saving anything and asks the existing
-- character system to re-open its own picker. No DB write, no logout.
-- ------------------------------------------------------------------
local function backToSelection()
    if not active or phase ~= "editing" then
        return false
    end

    closingTick = getTickCount()
    phase = "closing"

    setTimer(function()
        if active then
            -- keepWorld: stay in the creator studio (same room as the picker)
            -- and do not touch the camera - see the crash note in stopCreation
            stopCreation("cancelled", { keepWorld = true })
        end
        -- ng-characters re-sends its real character list (read-only)
        triggerServerEvent("ngc:creatorBack", localPlayer)
    end, 600, 1)

    return true
end

onKey = function(key, press)
    if not active or not press then
        return
    end

    if key == "backspace" then
        cancelEvent()

        if phase == "editing" and #nameText > 0 then
            nameText = nameText:sub(1, #nameText - 1)
        end
    elseif key == "enter" or key == "num_enter" then
        cancelEvent()
        submit()
    elseif key == "arrow_left" or key == "arrow_l" then
        cancelEvent()

        if phase == "editing" then
            previousSkin()
        end
    elseif key == "arrow_right" or key == "arrow_r" then
        cancelEvent()

        if phase == "editing" then
            nextSkin()
        end
    elseif key == "escape" then
        cancelEvent()

        if phase == "editing" then
            backToSelection()
        end
    end
end

onClick = function(button, state, absoluteX, absoluteY)
    if not active or button ~= "left" or state ~= "down" then
        return
    end

    local layout = getLayout()

    -- BACK TO SELECTION: return to the existing picker, never saves anything
    if phase == "editing" and isMouseInPosition(
        layout.back.x, layout.back.y, layout.back.w, layout.back.h
    ) then
        markPress("back")
        backToSelection()
        return
    end

    if CC.allowCancel and phase == "editing" and isMouseInPosition(
        layout.cancel.x, layout.cancel.y, layout.cancel.w, layout.cancel.h
    ) then
        markPress("cancel")
        closingTick = getTickCount()
        phase = "closing"
        setTimer(function()
            stopCreation("cancelled")
        end, 600, 1)
        return
    end

    if phase ~= "editing" then
        return
    end

    if isMouseInPosition(layout.male.x, layout.male.y, layout.male.w, layout.male.h) then
        markPress("male")
        setGender(1)
    elseif isMouseInPosition(layout.female.x, layout.female.y, layout.female.w, layout.female.h) then
        markPress("female")
        setGender(2)
    elseif isMouseInPosition(layout.previous.x, layout.previous.y, layout.previous.w, layout.previous.h) then
        markPress("prevSkin")
        previousSkin()
    elseif isMouseInPosition(layout.next.x, layout.next.y, layout.next.w, layout.next.h) then
        markPress("nextSkin")
        nextSkin()
    elseif isMouseInPosition(layout.submit.x, layout.submit.y, layout.submit.w, layout.submit.h) then
        markPress("submit")
        submit()
    end
end

-- ------------------------------------------------------------------
-- Server responses
-- ------------------------------------------------------------------

addEvent("cc:created", true)
addEventHandler("cc:created", root, function(createdCharacter)
    if not active or phase ~= "saving" then
        return
    end

    character = createdCharacter
    phase = "done"
    finishTick = getTickCount()

    if submitTimer and isTimer(submitTimer) then
        killTimer(submitTimer)
    end

    setTimer(function()
        if active and phase == "done" then
            phase = "closing"
            closingTick = getTickCount()

            setTimer(function()
                stopCreation("created")
            end, 600, 1)
        end
    end, 2200, 1)
end)

addEvent("cc:createFailed", true)
addEventHandler("cc:createFailed", root, function(reason)
    if not active or phase ~= "saving" then
        return
    end

    phase = "editing"
    showError(reason)

    if submitTimer and isTimer(submitTimer) then
        killTimer(submitTimer)
    end
end)

addEvent("cc:start", true)
addEventHandler("cc:start", root, function()
    startCreation()
end)

addEvent("onClientCharacterCreationFinished")

-- ------------------------------------------------------------------
-- Resource lifecycle
-- ------------------------------------------------------------------

addEventHandler("onClientResourceStop", root, function(resource)
    if resource ~= getThisResource() then
        return
    end

    if active then
        stopCreation("stop")
    end
end)

-- ------------------------------------------------------------------
-- [gta4gg / luxury pack] Service hook
-- Lets the server close the character creator overlay (used by QA/automated
-- previews). Same routine the Cancel button uses, so the camera, chat and
-- HUD are restored exactly as on a normal cancel.
-- ------------------------------------------------------------------
addEvent("cc:forceStop", true)
addEventHandler("cc:forceStop", root, function()
    stopCreation("cancelled")
end)
