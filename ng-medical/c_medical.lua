--[[
    ng-medical c_medical.lua - downed overlay (client)
]]

local RP = exports["ng-rp"]
local downedUntil = 0

addEvent("ngm:downed", true)
addEventHandler("ngm:downed", root, function(seconds)
    downedUntil = getTickCount() + seconds * 1000
end)

addEvent("ngm:revived", true)
addEventHandler("ngm:revived", root, function()
    downedUntil = 0
end)

addEventHandler("onClientRender", root, function()
    if downedUntil <= getTickCount() then return end
    if not getElementData(localPlayer, "med.downed") then return end
    local sw, sh = guiGetScreenSize()
    local left = math.max(0, math.ceil((downedUntil - getTickCount()) / 1000))
    dxDrawText("YOU ARE DOWN", 0, sh * 0.32, sw, sh * 0.38, tocolor(214, 61, 61, 255), 2.2, "default-bold", "center", "center")
    dxDrawText("Waiting for a medic... or respawn at the hospital in " .. left .. "s (fee $300)",
        0, sh * 0.38, sw, sh * 0.42, tocolor(235, 240, 245, 235), 1.1, "default-bold", "center", "center")
end)
