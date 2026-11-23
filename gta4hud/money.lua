--[[
    gta4hud / money.lua
    Premium "cash card" in the top-right corner:

        +-------------------------------+
        | CASH                          |
        |                      $12,540  |   <- big, soft green glow
        | ----------------------------- |
        | ($) BANK              $54,000 |
        +-------------------------------+

    Cash/bank animate towards the real element data values and every change
    spawns a floating +$/-$ delta above the card.
]]

MONEY = {}

local displayedCash = 0
local displayedBank = 0
local popups = {}
local cashFlashUntil = 0
local cashFlashGain = true
local lastCash = nil
local lastBank = nil

local function pushPopup(amount)
    if amount == 0 then return end
    popups[#popups + 1] = { amount = amount, t = getTickCount() }
    cashFlashUntil = getTickCount() + 900
    cashFlashGain = amount > 0
    while #popups > 4 do table.remove(popups, 1) end
end

function MONEY.update()
    local cash = tonumber(getElementData(localPlayer, "char.cash")) or 0
    local bank = tonumber(getElementData(localPlayer, "char.bank")) or 0

    if lastCash == nil then lastCash, displayedCash = cash, cash end
    if lastBank == nil then lastBank, displayedBank = bank, bank end

    if cash ~= lastCash then
        pushPopup(cash - lastCash)
        lastCash = cash
    end
    if bank ~= lastBank then
        pushPopup(bank - lastBank)
        lastBank = bank
    end

    displayedCash = displayedCash + (cash - displayedCash) * 0.22
    if math.abs(cash - displayedCash) < 0.6 then displayedCash = cash end

    displayedBank = displayedBank + (bank - displayedBank) * 0.22
    if math.abs(bank - displayedBank) < 0.6 then displayedBank = bank end
end

-- soft glow behind the cash amount (MTA has no text shadow blur, so we stack
-- a few offset copies with low alpha instead)
local function glow(txt, x, y, w, h, color, sizePx, font, ax, ay)
    local packed = HUD.tocol({ color[1], color[2], color[3], 46 })
    local scale = HUD.fs(sizePx)
    local off = math.max(1, HUD.s(1.4))
    local o = { { -off, 0 }, { off, 0 }, { 0, -off }, { 0, off } }
    for i = 1, 4 do
        dxDrawText(txt, x + o[i][1], y + o[i][2], w + o[i][1], h + o[i][2],
            packed, scale, font, ax, ay, false, false, false, false)
    end
end

--- Draws the cash card. Returns the Y coordinate right below the wanted stars,
--- so other top-right elements can stack underneath.
function MONEY.render()
    local cfg = HUDCFG
    local m = cfg.money
    local k = m.scale or 1          -- 2026-11-18: one dial for the card size
    local S = function(v) return HUD.s(v * k) end
    local right = HUD.sw - HUD.s(cfg.marginRight)
    local now = getTickCount()

    local cardW = S(m.cardWidth)
    local cardH = S(m.cardHeight)
    local cardX = right - cardW
    local cardY = S(m.cardY)

    -- fonts follow the same scale so the card stays balanced when it grows
    local cashSize  = m.cashSize * k
    local bankSize  = m.bankSize * k
    local labelSize = m.labelSize * k
    local deltaSize = m.deltaSize * k

    -- card body
    HUD.panel(cardX, cardY, cardW, cardH, S(m.cardRadius), m.fill, m.border, S(m.borderWidth))

    -- left accent bar with a fake vertical fade (no gradient fill in MTA)
    local ax = cardX + S(1.5)
    local ay = cardY + S(10)
    local ah = cardH - S(20)
    local accent = cfg.colors.accent
    local segs = 5
    local segH = ah / segs
    for i = 1, segs do
        local k = (i - 1) / (segs - 1)
        local a = 235 * (1 - k) + 8
        dxDrawRectangle(ax, ay + (i - 1) * segH, S(3), segH + 1,
            HUD.tocol(HUD.rgba(accent[1], accent[2], accent[3], a)))
    end

    -- small avatar badge (initials) - luxury HUD touch used across the server
    local avatarSize = S(36)
    local avX, avY = cardX + S(18), cardY + S(17)
    HUD.panel(avX - S(2), avY - S(2), avatarSize + S(4), avatarSize + S(4), S(10),
        { 232, 197, 107, 210 }, nil, 0)
    HUD.panel(avX, avY, avatarSize, avatarSize, S(8),
        { 40, 96, 160, 235 }, { 74, 166, 255, 150 }, S(1.2))
    local pname = tostring(getElementData(localPlayer, "char.name") or getPlayerName(localPlayer) or "LC")
    local ini = ""
    for w in pname:gmatch("%S+") do
        local c = w:sub(1, 1):upper()
        if c:match("%w") then ini = ini .. c end
        if #ini >= 2 then break end
    end
    if ini == "" then ini = "LC" end
    HUD.text(ini, avX, avY, avX + avatarSize, avY + avatarSize,
        HUD.color({ 238, 243, 250, 255 }), labelSize + 4, "default-bold", "center", "center")

    -- "CASH" caption (shifted right to clear the avatar)
    HUD.text("C A S H", cardX + S(64), cardY + S(16), cardX + cardW - S(22), cardY + S(30),
        HUD.color(cfg.colors.textDim, 0.95), labelSize, "default-bold", "left", "top")

    -- cash amount
    local cashColor = cfg.colors.money
    local flash = 0
    if now < cashFlashUntil then
        flash = (cashFlashUntil - now) / 900
        cashColor = cashFlashGain and cfg.colors.moneyGain or cfg.colors.moneyLoss
    end
    local cashText = "$" .. HUD.comma(displayedCash)
    local cashY = cardY + S(30)
    local cashH = S(40)
    glow(cashText, cardX, cashY, right - S(18), cashY + cashH,
        cashColor, cashSize, "default-bold", "right", "top")
    HUD.text(cashText, cardX, cashY, right - S(18), cashY + cashH,
        HUD.color(cashColor), cashSize, "default-bold", "right", "top")

    -- divider
    dxDrawRectangle(cardX + S(22), cardY + S(74), cardW - S(40), 1,
        HUD.tocol(HUD.rgba(255, 255, 255, 26)))

    -- bank row
    HUD.icon("icons/money.png", cardX + S(22), cardY + S(86), S(13), HUD.color(cfg.colors.textDim, 0.85))
    HUD.text("B A N K", cardX + S(42), cardY + S(84), cardX + cardW - S(80), cardY + S(96),
        HUD.color(cfg.colors.textDim, 0.9), labelSize + 1, "default-bold", "left", "top")
    HUD.text("$" .. HUD.comma(displayedBank), cardX + S(80), cardY + S(80), right - S(18), cardY + S(100),
        HUD.color(cfg.colors.text, 0.95), bankSize, "default-bold", "right", "top")

    -- ---------------------------------------------------------- delta
    -- Only the latest change is shown (fades up above the card). Stacking many
    -- would run off the top of the screen on small resolutions.
    local py = cardY - S(4)
    for i = #popups, 1, -1 do
        local p = popups[i]
        local age = now - p.t
        if age > m.deltaLife or i < #popups then
            table.remove(popups, i)
        else
            local k = age / m.deltaLife
            local a = 1 - k * k
            if a > 0.05 then
                local rise = S(14) * k
                local sign = p.amount > 0 and "+" or "-"
                local col = p.amount > 0 and cfg.colors.moneyGain or cfg.colors.moneyLoss
                HUD.alpha = HUD.alpha * a
                HUD.text(sign .. "$" .. HUD.comma(math.abs(p.amount)),
                    cardX, py - rise - S(18), right, py - rise,
                    HUD.color(col), deltaSize, "default-bold", "right", "bottom")
                HUD.alpha = HUD.alpha / a
            end
        end
    end

    -- ---------------------------------------------------------- stars
    local wanted = math.floor(tonumber(getElementData(localPlayer, "char.wanted")) or 0)
    local starsY = cardY + cardH + S(20)
    local starSize = S(19)
    if wanted > 0 then
        local gap = S(3)
        local totalW = 6 * starSize + 5 * gap
        for i = 1, 6 do
            local lit = wanted >= i
            HUD.icon("icons/star.png", right - totalW + (i - 1) * (starSize + gap), starsY, starSize,
                lit and HUD.color(cfg.colors.star) or HUD.rgba(255, 255, 255, 38))
        end
        starsY = starsY + starSize + S(10)
    end

    -- a subtle breathing glow while cash just changed
    if flash > 0 then
        dxDrawRectangle(cardX + S(18), cardY + S(1), cardW - S(36), S(1.5),
            HUD.tocol(HUD.rgba(cashColor[1], cashColor[2], cashColor[3], 120 * flash)))
    end

    return starsY
end
