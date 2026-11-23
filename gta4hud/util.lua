--[[
    gta4hud / util.lua
    Screen scaling, colour helpers and shared draw primitives (rounded panels,
    text with a soft shadow, bars).
]]

HUD = {
    sw    = 1920,
    sh    = 1080,
    scale = 1,
    alpha = 0,       -- master fade (0..1)
}

function HUD.refresh()
    local w, h = guiGetScreenSize()
    HUD.sw, HUD.sh = w, h
    HUD.scale = math.min(w / HUDCFG.designWidth, h / HUDCFG.designHeight)
    if HUD.scale <= 0 then HUD.scale = 1 end
end

HUD.refresh()

-- Design pixel -> screen pixel
function HUD.s(value)
    return value * HUD.scale
end

-- Design pixel font size -> dxDrawText scale (1.0 ~= 22px tall at 1080p)
function HUD.fs(sizePx)
    return (sizePx * HUD.scale) / 22
end

function HUD.clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

function HUD.lerp(a, b, t)
    return a + (b - a) * t
end

function HUD.color(c, mul)
    local a = (c[4] or 255) * (mul or 1) * HUD.alpha
    return { c[1], c[2], c[3], HUD.clamp(a, 0, 255) }
end

function HUD.rgba(r, g, b, a)
    return { r, g, b, HUD.clamp((a or 255) * HUD.alpha, 0, 255) }
end

--- Converts an internal {r,g,b,a} table into an MTA packed colour.
function HUD.tocol(c)
    return tocolor(c[1] or 0, c[2] or 0, c[3] or 0, math.floor(HUD.clamp(c[4] or 255, 0, 255)))
end

function HUD.comma(value)
    local n = math.floor(tonumber(value) or 0)
    local sign = ""
    if n < 0 then sign = "-" ; n = -n end
    local s = tostring(n)
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    out = out:gsub("^,", "")
    return sign .. out
end

-- ---------------------------------------------------------------- draw utils

local shaderPanel     -- RoundedPanel.fx
local shaderTexture   -- RoundedTexture.fx

function HUD.createShaders()
    if not shaderPanel or not isElement(shaderPanel) then
        shaderPanel = dxCreateShader("shaders/RoundedPanel.fx")
    end
    if not shaderTexture or not isElement(shaderTexture) then
        shaderTexture = dxCreateShader("shaders/RoundedTexture.fx")
    end
end

function HUD.destroyShaders()
    if shaderPanel and isElement(shaderPanel) then destroyElement(shaderPanel) end
    if shaderTexture and isElement(shaderTexture) then destroyElement(shaderTexture) end
    shaderPanel, shaderTexture = nil, nil
end

function HUD.getTextureShader()
    return shaderTexture
end

--- Rounded rectangle. radius/fill/border in design pixels / colour tables.
function HUD.panel(x, y, w, h, radius, fill, border, borderWidth)
    if not shaderPanel or not isElement(shaderPanel) then return end
    if w <= 0 or h <= 0 then return end

    local r = math.min(radius or 8, math.min(w, h) * 0.5)

    dxSetShaderValue(shaderPanel, "sSize", w, h)
    dxSetShaderValue(shaderPanel, "sRadius", r)
    dxSetShaderValue(shaderPanel, "sFeather", 1.0)

    if fill then
        dxSetShaderValue(shaderPanel, "sFill", fill[1] / 255, fill[2] / 255, fill[3] / 255, (fill[4] or 255) / 255 * HUD.alpha)
    else
        dxSetShaderValue(shaderPanel, "sFill", 0, 0, 0, 0)
    end

    if border then
        dxSetShaderValue(shaderPanel, "sBorder", border[1] / 255, border[2] / 255, border[3] / 255, (border[4] or 255) / 255 * HUD.alpha)
    else
        dxSetShaderValue(shaderPanel, "sBorder", 0, 0, 0, 0)
    end

    dxSetShaderValue(shaderPanel, "sBorderWidth", borderWidth or 0)
    dxDrawImage(x, y, w, h, shaderPanel, 0, 0, 0, tocolor(255, 255, 255, 255), false)
end

--- Texture clipped to a rounded rectangle (used for the minimap).
function HUD.roundedTexture(x, y, w, h, texture, radius, feather)
    if not shaderTexture or not isElement(shaderTexture) or not texture then return end

    dxSetShaderValue(shaderTexture, "sTexture", texture)
    dxSetShaderValue(shaderTexture, "sTextureSize", w, h)
    dxSetShaderValue(shaderTexture, "sRadius", radius or 0)
    dxSetShaderValue(shaderTexture, "sFeather", feather or 1.25)
    dxDrawImage(x, y, w, h, shaderTexture, 0, 0, 0, tocolor(255, 255, 255, math.floor(255 * HUD.alpha)), false)
end

--- Text with a soft shadow. bx/by is the box, alignment via ax/ay.
function HUD.text(txt, x, y, w, h, color, sizePx, font, ax, ay)
    if txt == nil or txt == "" then return end
    local scale = HUD.fs(sizePx)
    local shadow = tocolor(0, 0, 0, math.floor(150 * HUD.alpha))
    local packed = HUD.tocol(color)
    dxDrawText(txt, x + 1, y + 1, w + 1, h + 1, shadow, scale, font or "default-bold", ax or "left", ay or "top", false, false, false, false)
    dxDrawText(txt, x, y, w, h, packed, scale, font or "default-bold", ax or "left", ay or "top", false, false, false, false)
end

function HUD.textRight(txt, right, y, color, sizePx, font)
    local s = tostring(txt)
    HUD.text(s, right - 620, y - 18, right, y + 18, color, sizePx, font, "right", "center")
end

--- Horizontal bar with rounded ends.
function HUD.bar(x, y, w, h, frac, fg, bg)
    frac = HUD.clamp(frac or 0, 0, 1)
    local radius = h * 0.5

    HUD.panel(x, y, w, h, radius, bg or { 0, 0, 0, 150 })
    if frac > 0.001 then
        HUD.panel(x, y, math.max(h, w * frac), h, radius, fg)
    end
end

function HUD.icon(path, x, y, size, color)
    dxDrawImage(x, y, size, size, path, 0, 0, 0, HUD.tocol(color or { 255, 255, 255, 255 }), false)
end

function HUD.isBigmapOpen()
    local res = getResourceFromName("Radar_Core")
    if not res or getResourceState(res) ~= "running" then return false end
    return call(res, "isBigmapVisible") == true
end
