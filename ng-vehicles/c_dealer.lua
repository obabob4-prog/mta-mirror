--[[
    ng-vehicles c_dealer.lua - vehicle dealer UI (client)
]]

local RP = exports["ng-rp"]

addEvent("ngv:showDealer", true)
addEventHandler("ngv:showDealer", root, function(catalog)
    RP:openWindow("dealer", "NEXT GENERATION AUTOS", 660, 120, 600, 700)
    RP:windowClear("dealer")
    local y = 0.09
    for _, v in ipairs(catalog) do
        RP:windowLabel("dealer", "n" .. v.model, v.name, 0.05, y, 0.24, 0.05, 0.9, nil, "left", "center")
        RP:windowLabel("dealer", "p" .. v.model, "$" .. tostring(v.price), 0.30, y, 0.20, 0.05, 0.9, tocolor(64, 178, 96, 255), "left", "center")
        RP:windowButton("dealer", "b" .. v.model, "BUY", 0.52, y, 0.12, 0.05, function()
            triggerServerEvent("ngv:buy", localPlayer, v.model)
        end)
        y = y + 0.06
    end
    RP:windowLabel("dealer", "note", "Vehicles are bought from your BANK balance. Max 2 per character.", 0.05, 0.92, 0.9, 0.045, 0.8, tocolor(150, 160, 172, 255), "center", "center")
    RP:windowButton("dealer", "close", "CLOSE", 0.35, 0.96, 0.3, 0.04, function()
        RP:closeWindow("dealer")
    end, tocolor(120, 30, 30, 200))
end)
