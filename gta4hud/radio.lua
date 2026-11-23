--[[
    gta4hud / radio.lua
    Small radio readout above the radar. MTA exposes the station id and name
    only (no song / volume), so this shows the real station plus its genre.
    It appears when the station changes and fades out on its own.
]]

RADIO = {}

local lastChannel = -1
local showUntil = 0
local fade = 0

local function stationName(channel)
    local name = getRadioChannelName(channel)
    if not name or name == "" then return "RADIO" end
    return name
end

function RADIO.render(mapX, mapY, mapSize)
    local cfg = HUDCFG
    local S = HUD.s

    local channel = tonumber(getRadioChannel()) or 0

    if channel ~= lastChannel then
        lastChannel = channel
        if channel > 0 then
            showUntil = getTickCount() + cfg.radio.visibleTime
        else
            showUntil = 0
        end
    end

    local target = (channel > 0 and getTickCount() < showUntil) and 1 or 0
    fade = fade + (target - fade) * 0.12
    if fade < 0.01 then fade = 0 end
    if fade <= 0 then return end

    local w = S(cfg.radio.width)
    local h = S(cfg.radio.height)
    local x = mapX
    local y = mapY - S(cfg.radio.gapAbove) - h

    HUD.alpha = HUD.alpha * fade

    local classic = cfg.radio.style == "classic"

    if classic then
        dxDrawRectangle(x, y, w, h, HUD.tocol(HUD.color(cfg.colors.strip)))
        dxDrawRectangle(x, y, S(4), h, HUD.tocol(HUD.color(cfg.colors.hunger, 0.9)))
        HUD.icon("icons/radio.png", x + S(12), y + (h - S(20)) / 2, S(20), HUD.color(cfg.colors.radio, 0.92))
    else
        HUD.panel(x, y, w, h, S(10), cfg.colors.panel, cfg.colors.border, 1)
        HUD.icon("icons/radio.png", x + S(11), y + (h - S(20)) / 2, S(20), HUD.color(cfg.colors.radio, 0.9))
    end

    local name = stationName(channel)
    local genre = HUDCFG.radioGenres[channel] or "ON AIR"

    HUD.text(name, x + S(40), y + S(6), x + w - S(12), y + S(24),
        HUD.color(cfg.colors.radio), 15, "default-bold", "left", "center")
    HUD.text(genre, x + S(40), y + S(21), x + w - S(12), y + h - S(5),
        HUD.color(cfg.colors.textDim, 0.92), 11, "default-bold", "left", "center")

    -- small "live" dot
    local dot = S(5)
    dxDrawCircle(x + w - S(16), y + h * 0.5, dot * 0.5, 0, 360,
        HUD.tocol(HUD.color(cfg.colors.moneyGain)), HUD.tocol(HUD.color(cfg.colors.moneyGain)), 12)

    HUD.alpha = HUD.alpha / fade
end
