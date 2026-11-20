--[[
    gta4hud / vitals.lua
    Health / armour / hunger / thirst readout, drawn directly under the radar.

    style = "segments"  GTA IV: solid black strip, 10 health + 10 armour ticks
    style = "glass"     GTA V: rounded glass panel with icons and smooth bars
]]

VITALS = {}

local function fraction(value, fallback)
    local v = tonumber(value)
    if not v then v = fallback or 0 end
    return HUD.clamp(v / 100, 0, 1)
end

local function healthColor(cfg, health)
    local base = cfg.colors.health
    if health >= 0.25 then return base end
    local pulse = math.sin(getTickCount() / 190) * 0.5 + 0.5
    local low = cfg.colors.healthLow
    return {
        math.floor(HUD.lerp(base[1], low[1], pulse)),
        math.floor(HUD.lerp(base[2], low[2], pulse)),
        math.floor(HUD.lerp(base[3], low[3], pulse)),
    }
end

-- Segmented bar: `segs` ticks across w, filled continuously.
local function ticks(x, y, w, h, frac, color, segs, gap, trackA)
    local segW = (w - gap * (segs - 1)) / segs
    local exact = frac * segs
    for i = 1, segs do
        local sx = x + (i - 1) * (segW + gap)
        dxDrawRectangle(sx, y, segW, h, HUD.tocol(HUD.rgba(255, 255, 255, trackA or 26)))
        if exact >= i then
            dxDrawRectangle(sx, y, segW, h, HUD.tocol(HUD.color(color)))
        elseif exact > i - 1 then
            dxDrawRectangle(sx, y, segW * (exact - (i - 1)), h, HUD.tocol(HUD.color(color)))
        end
    end
end

local function renderSegments(cfg, x, y, w, h, health, armour, hunger, thirst)
    local v = cfg.vitals
    local S = HUD.s

    dxDrawRectangle(x, y, w, h, HUD.tocol(HUD.color(cfg.colors.strip)))

    local pad = S(v.padding)
    local innerW = w - pad * 2
    local segs = v.segments

    -- health
    ticks(x + pad, y + S(8), innerW, S(v.healthHeight), health,
        healthColor(cfg, health), segs, S(v.segmentGap))

    -- armour
    ticks(x + pad, y + S(8 + v.healthHeight + 6), innerW, S(v.armorHeight), armour,
        cfg.colors.armor, segs, S(v.segmentGap))

    -- hunger / thirst (thin, split in two halves with small icons)
    local rowY = y + h - S(v.thinHeight) - S(5)
    local iconSize = S(9)
    local halfGap = S(10)
    local halfW = (innerW - halfGap) / 2
    local barW = halfW - iconSize - S(4)

    HUD.icon("icons/hunger.png", x + pad, rowY - S(1.5), iconSize, HUD.color(cfg.colors.hunger, 0.8))
    local hx = x + pad + iconSize + S(4)
    dxDrawRectangle(hx, rowY, barW, S(v.thinHeight), HUD.tocol(HUD.rgba(255, 255, 255, 20)))
    dxDrawRectangle(hx, rowY, barW * hunger, S(v.thinHeight), HUD.tocol(HUD.color(cfg.colors.hunger, 0.9)))

    local tx = x + pad + halfW + halfGap
    HUD.icon("icons/thirst.png", tx, rowY - S(1.5), iconSize, HUD.color(cfg.colors.thirst, 0.8))
    local bx = tx + iconSize + S(4)
    dxDrawRectangle(bx, rowY, barW, S(v.thinHeight), HUD.tocol(HUD.rgba(255, 255, 255, 20)))
    dxDrawRectangle(bx, rowY, barW * thirst, S(v.thinHeight), HUD.tocol(HUD.color(cfg.colors.thirst, 0.9)))
end

local function renderGlass(cfg, x, y, w, h, health, armour, hunger, thirst)
    local S = HUD.s

    HUD.panel(x, y, w, h, S(16), cfg.colors.panel, cfg.colors.border, 1)

    local padX = S(12)
    local iconSize = S(14)
    local barX = x + padX + iconSize + S(8)
    local barW = (x + w - padX) - barX
    local barH = S(7)

    local row1 = y + S(12)
    HUD.icon("icons/heart.png", x + padX, row1 - S(3), iconSize, HUD.color(healthColor(cfg, health), 0.95))
    HUD.bar(barX, row1, barW, barH, health, HUD.color(healthColor(cfg, health)), HUD.color({ 0, 0, 0, 165 }))

    local row2 = y + S(28)
    HUD.icon("icons/shield.png", x + padX, row2 - S(3), iconSize, HUD.color(cfg.colors.armor, 0.9))
    HUD.bar(barX, row2, barW, barH, armour, HUD.color(cfg.colors.armor), HUD.color({ 0, 0, 0, 165 }))

    local row3 = y + S(52)
    local miniIcon = S(12)
    local halfW = (w - padX * 2 - S(10)) * 0.5

    HUD.icon("icons/hunger.png", x + padX, row3 - S(2), miniIcon, HUD.color(cfg.colors.hunger, 0.75))
    HUD.bar(x + padX + miniIcon + S(6), row3 + S(3), halfW - miniIcon - S(6), S(5),
        hunger, HUD.color(cfg.colors.hunger, 0.85), HUD.color({ 0, 0, 0, 140 }))

    local tx = x + padX + halfW + S(10)
    HUD.icon("icons/thirst.png", tx, row3 - S(2), miniIcon, HUD.color(cfg.colors.thirst, 0.75))
    HUD.bar(tx + miniIcon + S(6), row3 + S(3), halfW - miniIcon - S(6), S(5),
        thirst, HUD.color(cfg.colors.thirst, 0.85), HUD.color({ 0, 0, 0, 140 }))
end

function VITALS.render(mapX, mapY, mapSize)
    local cfg = HUDCFG
    local S = HUD.s

    local x = mapX
    local y = mapY + mapSize + S(cfg.minimap.gapBelow)
    local w = mapSize
    local h = S(cfg.vitals.height)

    local health = HUD.clamp((getElementHealth(localPlayer) or 0) / 100, 0, 1)
    local armour = HUD.clamp((getPedArmor(localPlayer) or 0) / 100, 0, 1)
    local hunger = fraction(getElementData(localPlayer, "char.hunger"), 100)
    local thirst = fraction(getElementData(localPlayer, "char.thirst"), 100)

    if cfg.vitals.style == "segments" then
        renderSegments(cfg, x, y, w, h, health, armour, hunger, thirst)
    else
        renderGlass(cfg, x, y, w, h, health, armour, hunger, thirst)
    end
end
