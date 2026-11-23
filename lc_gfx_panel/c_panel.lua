--[[
    lc_gfx_panel / client
    Standalone, opt-in graphics settings panel. It never edits another
    resource's UI. Quality presets go through luxury_graphics' existing
    persistent quality service; effect toggles go through the option event
    exposed by luxury_graphics. All preferences are stored locally in this
    resource's client XML file.
]]

local PANEL_VERSION = "1.0"
local SAVE_FILE = "lc_gfx_settings.xml"

local PRESETS = {
    { id = "ultra",  label = "ULTRA GRAPHICS" },
    { id = "high",   label = "HIGH GRAPHICS" },
    { id = "medium", label = "BALANCED GRAPHICS" },
    { id = "low",    label = "PERFORMANCE MODE" },
}
local LEVEL_NAMES = { "LOW", "MEDIUM", "HIGH", "ULTRA" }
local WATER_COLORS = {
    { 58, 100, 128, 255 },
    { 50,  93, 122, 255 },
    { 43,  84, 114, 255 },
    { 38,  76, 106, 255 },
}
local SHADOW_STRENGTH = { 0.35, 0.60, 0.82, 1.00 }

local settings = {
    preset = "high",
    wet = true,
    reflections = true,
    rain = true,
    water = 3,
    shadow = 3,
    texture = 3,
    shader = 3,
}

local visible = false
local scale = 1
local px, py, pw, ph = 0, 0, 560, 600
local buttons = {}
local activePreset = "high"
local lastQualitySend = 0

addEvent("luxuryGraphics:setOption", true)

local function clamp(n, lo, hi)
    n = tonumber(n) or lo
    if n < lo then return lo end
    if n > hi then return hi end
    return n
end

local function validPreset(id)
    for _, p in ipairs(PRESETS) do
        if p.id == id then return true end
    end
    return false
end

local function log(line)
    outputDebugString("[lc_gfx_panel] " .. tostring(line), 0, 120, 200, 255)
end

-- ---------------------------------------------------------------- persistence
local function loadSettings()
    local rootNode = xmlLoadFile(SAVE_FILE)
    if not rootNode then return false end
    local function read(name, fallback)
        local child = xmlFindChild(rootNode, name, 0)
        if not child then return fallback end
        return xmlNodeGetAttribute(child, "value") or fallback
    end
    local preset = read("preset", settings.preset)
    settings.preset = validPreset(preset) and preset or settings.preset
    settings.wet = read("wet", "1") == "1"
    settings.reflections = read("reflections", "1") == "1"
    settings.rain = read("rain", "1") == "1"
    settings.water = clamp(tonumber(read("water", 3)), 1, 4)
    settings.shadow = clamp(tonumber(read("shadow", 3)), 1, 4)
    settings.texture = clamp(tonumber(read("texture", 3)), 1, 4)
    settings.shader = clamp(tonumber(read("shader", 3)), 1, 4)
    xmlUnloadFile(rootNode)
    return true
end

local function saveSettings()
    local rootNode = xmlCreateFile(SAVE_FILE, "settings")
    if not rootNode then return false end
    local function write(name, value)
        local child = xmlCreateChild(rootNode, name)
        if child then xmlNodeSetAttribute(child, "value", tostring(value)) end
    end
    write("preset", settings.preset)
    write("wet", settings.wet and "1" or "0")
    write("reflections", settings.reflections and "1" or "0")
    write("rain", settings.rain and "1" or "0")
    write("water", settings.water)
    write("shadow", settings.shadow)
    write("texture", settings.texture)
    write("shader", settings.shader)
    local ok = xmlSaveFile(rootNode)
    xmlUnloadFile(rootNode)
    return ok
end

-- ------------------------------------------------------------------- applying
local function applyShadow()
    if type(setWorldProperty) ~= "function" then return end
    local ok = pcall(setWorldProperty, "ShadowStrength", SHADOW_STRENGTH[settings.shadow] or 0.82)
    if not ok then log("ShadowStrength is not available on this client") end
end

local function applyWater()
    if type(setWaterColor) ~= "function" then return end
    local c = WATER_COLORS[settings.water] or WATER_COLORS[3]
    local ok = pcall(setWaterColor, c[1], c[2], c[3], c[4])
    if not ok then log("setWaterColor failed") end
end

local function applyQuality(silent)
    local now = getTickCount()
    if now - lastQualitySend < 600 then return end
    lastQualitySend = now
    activePreset = settings.preset
    triggerServerEvent("luxuryGraphics:setQuality", localPlayer, settings.preset, false)
    if not silent then log("quality -> " .. settings.preset) end
end

local function applyOptions()
    triggerEvent("luxuryGraphics:setOption", root, "wet", settings.wet)
    triggerEvent("luxuryGraphics:setOption", root, "reflections", settings.reflections)
    triggerEvent("luxuryGraphics:setOption", root, "rain", settings.rain)
    applyShadow()
    applyWater()
end

local function applyAll(silent)
    applyQuality(silent)
    applyOptions()
    saveSettings()
end

-- ------------------------------------------------------------------- geometry
local function metrics()
    local sw, sh = guiGetScreenSize()
    scale = clamp(math.min(sw / 1360, sh / 768), 0.72, 1.45)
    pw, ph = 560 * scale, 600 * scale
    px, py = (sw - pw) / 2, (sh - ph) / 2
end

local function resetButtons()
    buttons = {}
end

local function button(id, x, y, w, h, label, kind, value)
    buttons[#buttons + 1] = { id = id, x = x, y = y, w = w, h = h, label = label, kind = kind, value = value }
end

local function inBox(b, mx, my)
    return mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h
end

-- ---------------------------------------------------------------------- render
local frames, fpsStart, fps = 0, getTickCount(), 0
local lastPerfSend = 0

local function countFps()
    frames = frames + 1
    local now = getTickCount()
    if now - fpsStart >= 1000 then
        fps = frames * 1000 / (now - fpsStart)
        frames, fpsStart = 0, now
        if now - lastPerfSend >= 5000 then
            lastPerfSend = now
            triggerServerEvent("lcGfx:perf", localPlayer, math.floor(fps), activePreset)
        end
    end
end
addEventHandler("onClientRender", root, countFps, true, "low-20")

local function drawPanel()
    if not visible then return end
    metrics()
    resetButtons()

    local bg = tocolor(10, 15, 22, 238)
    local panelBg = tocolor(15, 22, 32, 248)
    local line = tocolor(70, 105, 135, 210)
    local text = tocolor(232, 240, 248, 255)
    local dim = tocolor(150, 170, 188, 255)
    local gold = tocolor(212, 175, 55, 255)
    local accent = tocolor(70, 150, 205, 255)
    local okColor = tocolor(88, 190, 130, 255)
    local offColor = tocolor(128, 138, 148, 255)

    dxDrawRectangle(0, 0, guiGetScreenSize(), bg)
    dxDrawRectangle(px, py, pw, ph, panelBg, false)
    dxDrawRectangle(px, py, pw, 3 * scale, gold)
    dxDrawRectangle(px, py + ph - 3 * scale, pw, 3 * scale, line)

    local f = scale
    dxDrawText("ULTRA GRAPHICS  /  LIBERTY CITY", px + 22 * f, py + 16 * f, px + pw - 20 * f, py + 48 * f,
        text, 1.25 * f, "default-bold", "left", "center")
    dxDrawText("REALISTIC WEATHER  -  WET ROADS  -  CLEAN LIGHTING", px + 22 * f, py + 47 * f, px + pw - 20 * f, py + 68 * f,
        dim, 0.78 * f, "default", "left", "center")
    dxDrawText(string.format("FPS %d   |   preset %s   |   v%s", math.floor(fps), activePreset:upper(), PANEL_VERSION),
        px + pw - 24 * f, py + 20 * f, px + pw - 20 * f, py + 42 * f, gold, 0.8 * f, "default", "right", "center")

    local y = py + 82 * f
    dxDrawText("QUALITY PRESET", px + 22 * f, y, px + pw - 22 * f, y + 18 * f, gold, 0.85 * f, "default-bold", "left", "center")
    y = y + 24 * f

    local bw, bh, gap = (pw - 56 * f) / 2, 46 * f, 12 * f
    for i, p in ipairs(PRESETS) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local bx = px + 22 * f + col * (bw + gap)
        local by = y + row * (bh + 8 * f)
        local selected = (settings.preset == p.id)
        dxDrawRectangle(bx, by, bw, bh, selected and tocolor(45, 105, 150, 235) or tocolor(32, 43, 58, 230))
        dxDrawRectangle(bx, by, 3 * f, bh, selected and gold or line)
        dxDrawText(p.label, bx + 8 * f, by, bx + bw - 6 * f, by + bh, selected and text or dim,
            0.9 * f, "default-bold", "center", "center")
        button("preset_" .. p.id, bx, by, bw, bh, p.label, "preset", p.id)
    end

    y = y + 2 * (bh + 8 * f) + 18 * f
    dxDrawText("EFFECTS", px + 22 * f, y, px + pw - 22 * f, y + 18 * f, gold, 0.85 * f, "default-bold", "left", "center")
    y = y + 24 * f

    local toggles = {
        { key = "wet", label = "WET ROADS" },
        { key = "reflections", label = "REFLECTIONS / PUDDLES" },
        { key = "rain", label = "RAIN EFFECTS" },
    }
    for i, t in ipairs(toggles) do
        local col = (i - 1) % 3
        local tw = (pw - 56 * f - 16 * f) / 3
        local tx = px + 22 * f + col * (tw + 8 * f)
        local on = settings[t.key] == true
        dxDrawRectangle(tx, y, tw, 40 * f, tocolor(30, 41, 55, 230))
        dxDrawRectangle(tx + 8 * f, y + 12 * f, 12 * f, 12 * f, on and okColor or offColor)
        dxDrawText(t.label, tx + 26 * f, y, tx + tw - 4 * f, y + 40 * f,
            on and text or dim, 0.66 * f, "default-bold", "left", "center")
        button("toggle_" .. t.key, tx, y, tw, 40 * f, t.label, "toggle", t.key)
    end
    y = y + 54 * f

    dxDrawText("DETAIL QUALITY", px + 22 * f, y, px + pw - 22 * f, y + 18 * f, gold, 0.85 * f, "default-bold", "left", "center")
    y = y + 24 * f

    local rows = {
        { key = "water", label = "WATER QUALITY" },
        { key = "shadow", label = "SHADOW QUALITY" },
        { key = "texture", label = "TEXTURE QUALITY" },
        { key = "shader", label = "SHADER QUALITY" },
    }
    for i, r in ipairs(rows) do
        local ry = y + (i - 1) * 38 * f
        dxDrawRectangle(px + 22 * f, ry, pw - 44 * f, 32 * f, tocolor(28, 38, 51, 225))
        dxDrawText(r.label, px + 34 * f, ry, px + 240 * f, ry + 32 * f, dim, 0.78 * f, "default", "left", "center")
        local ax = px + pw - 176 * f
        dxDrawRectangle(ax, ry + 4 * f, 26 * f, 24 * f, tocolor(46, 62, 80, 240))
        dxDrawText("<", ax, ry + 2 * f, ax + 26 * f, ry + 30 * f, text, 0.9 * f, "default-bold", "center", "center")
        dxDrawText(LEVEL_NAMES[settings[r.key]] or "-", ax + 30 * f, ry, ax + 100 * f, ry + 32 * f,
            accent, 0.78 * f, "default-bold", "center", "center")
        local bx = ax + 104 * f
        dxDrawRectangle(bx, ry + 4 * f, 26 * f, 24 * f, tocolor(46, 62, 80, 240))
        dxDrawText(">", bx, ry + 2 * f, bx + 26 * f, ry + 30 * f, text, 0.9 * f, "default-bold", "center", "center")
        button("dec_" .. r.key, ax, ry + 4 * f, 26 * f, 24 * f, "<", "dec", r.key)
        button("inc_" .. r.key, bx, ry + 4 * f, 26 * f, 24 * f, ">", "inc", r.key)
    end

    y = y + #rows * 38 * f + 12 * f
    dxDrawText("Texture / shader levels share the selected preset. Water and shadow levels apply instantly.",
        px + 22 * f, y, px + pw - 22 * f, y + 34 * f, dim, 0.68 * f, "default", "left", "top", false, false, false, true)

    local closeW, closeH = 110 * f, 34 * f
    local cx, cy = px + pw - 22 * f - closeW, py + ph - 18 * f - closeH
    dxDrawRectangle(cx, cy, closeW, closeH, tocolor(120, 50, 50, 235))
    dxDrawText("CLOSE  [F7]", cx, cy, cx + closeW, cy + closeH, text, 0.8 * f, "default-bold", "center", "center")
    button("close", cx, cy, closeW, closeH, "CLOSE", "close", nil)
    dxDrawText("/gfxpanel opens this panel. Settings are saved locally.", px + 22 * f, cy, cx - 16 * f, cy + closeH,
        dim, 0.68 * f, "default", "left", "center")
end
addEventHandler("onClientRender", root, drawPanel, true, "high+1")

-- ---------------------------------------------------------------- interaction
local function handleButton(b)
    if b.kind == "preset" then
        settings.preset = b.value
        applyQuality(false)
    elseif b.kind == "toggle" then
        settings[b.value] = not settings[b.value]
        applyOptions()
    elseif b.kind == "dec" or b.kind == "inc" then
        local delta = (b.kind == "inc") and 1 or -1
        settings[b.value] = clamp(settings[b.value] + delta, 1, 4)
        if b.value == "water" then
            applyWater()
        elseif b.value == "shadow" then
            applyShadow()
        else
            -- Texture and shader detail are supplied by the quality preset.
            settings.preset = PRESETS[5 - settings[b.value]].id
            applyQuality(false)
        end
    elseif b.kind == "close" then
        visible = false
        showCursor(false)
    end
    saveSettings()
end

addEventHandler("onClientClick", root, function(buttonName, state, absX, absY)
    if not visible or buttonName ~= "left" or state ~= "down" then return end
    for _, b in ipairs(buttons) do
        if inBox(b, absX, absY) then
            handleButton(b)
            return
        end
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not press then return end
    if key == "f7" and visible then
        visible = false
        showCursor(false)
        cancelEvent()
    end
end)

local function openPanel()
    visible = not visible
    showCursor(visible)
    metrics()
end

addCommandHandler("gfxpanel", openPanel)
addCommandHandler("graphicsmenu", openPanel)

addEventHandler("onClientResourceStart", resourceRoot, function()
    metrics()
    loadSettings()
    setTimer(function()
        applyAll(true)
    end, 2600, 1)
    outputChatBox("#d4af37[LC Graphics] #ffffffPanel ready - type /gfxpanel", 255, 255, 255, true)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    saveSettings()
end)
