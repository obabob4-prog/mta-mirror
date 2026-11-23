--[[
    ng-identity c_identity.lua - ID card overlay (client)
]]

local RP = exports["ng-rp"]
local cardData = nil
local cardUntil = 0

addEvent("ngi:showCard", true)
addEventHandler("ngi:showCard", root, function(data)
    cardData = data
    cardUntil = getTickCount() + 10000
end)

addEventHandler("onClientRender", root, function()
    if not cardData or getTickCount() > cardUntil then return end
    local sw, sh = guiGetScreenSize()
    local w, h = math.floor(sw * 0.34), math.floor(sh * 0.30)
    local x, y = math.floor((sw - w) / 2), math.floor((sh - h) / 2)
    dxDrawRectangle(x, y, w, h, tocolor(16, 19, 24, 245))
    dxDrawRectangle(x, y, w, 6, tocolor(74, 163, 255, 255))
    dxDrawText(cardData.title, x + 20, y + 14, x + w - 20, y + 52,
        tocolor(74, 163, 255, 255), 1.0, "default-bold", "left", "center")
    local ly = y + 64
    for _, line in ipairs(cardData.lines) do
        dxDrawText(line, x + 20, ly, x + w - 20, ly + 30,
            tocolor(235, 240, 245, 235), 0.95, "default", "left", "center")
        ly = ly + 30
    end
    dxDrawText("Click to dismiss", x, y + h - 26, x + w, y + h, tocolor(150, 160, 172, 200), 0.8, "default", "center", "center")
end)

addEventHandler("onClientClick", root, function()
    if cardData then cardData = nil end
end)
