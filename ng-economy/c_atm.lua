--[[
    ng-economy c_atm.lua - ATM / banking UI (client)
]]

local RP = exports["ng-rp"]

local function openAtm(cash, bank)
    RP:openWindow("atm", "SAN ANDREAS NATIONAL BANK", 760, 300, 420, 420)
    RP:windowClear("atm")
    RP:windowLabel("atm", "cash", "Cash on hand: $" .. tostring(cash), 0.06, 0.12, 0.88, 0.06, 1.0, nil, "center", "center")
    RP:windowLabel("atm", "bank", "Bank balance: $" .. tostring(bank), 0.06, 0.19, 0.88, 0.06, 1.0, tocolor(64, 178, 96, 255), "center", "center")
    RP:windowLabel("atm", "amt", "Amount:", 0.07, 0.28, 0.4, 0.04, 0.85)
    RP:windowEdit("atm", "amount", "", 0.07, 0.32, 0.86, 0.08)
    RP:windowButton("atm", "dep", "DEPOSIT", 0.07, 0.45, 0.40, 0.10, function()
        triggerServerEvent("nge:deposit", localPlayer, tonumber(RP:windowGetEdit("atm", "amount")))
    end)
    RP:windowButton("atm", "wd", "WITHDRAW", 0.53, 0.45, 0.40, 0.10, function()
        triggerServerEvent("nge:withdraw", localPlayer, tonumber(RP:windowGetEdit("atm", "amount")))
    end, tocolor(40, 96, 160, 200))
    RP:windowLabel("atm", "tgt", "Transfer to (player name):", 0.07, 0.57, 0.9, 0.04, 0.85)
    RP:windowEdit("atm", "target", "", 0.07, 0.61, 0.86, 0.08)
    RP:windowButton("atm", "tr", "TRANSFER", 0.07, 0.71, 0.86, 0.10, function()
        triggerServerEvent("nge:transfer", localPlayer, RP:windowGetEdit("atm", "target"), tonumber(RP:windowGetEdit("atm", "amount")))
    end, tocolor(40, 96, 160, 200))
    RP:windowLabel("atm", "status", "", 0.06, 0.82, 0.88, 0.05, 0.85, tocolor(150, 160, 172, 255), "center", "center")
    RP:windowButton("atm", "close", "CLOSE", 0.30, 0.89, 0.40, 0.08, function()
        RP:closeWindow("atm")
    end, tocolor(120, 30, 30, 200))
end

addEvent("nge:openAtm", true)
addEventHandler("nge:openAtm", root, openAtm)

addEvent("nge:refresh", true)
addEventHandler("nge:refresh", root, function(cash, bank)
    if RP:isWindowOpen("atm") then
        RP:windowLabel("atm", "cash", "Cash on hand: $" .. tostring(cash), 0.06, 0.12, 0.88, 0.06, 1.0, nil, "center", "center")
        RP:windowLabel("atm", "bank", "Bank balance: $" .. tostring(bank), 0.06, 0.19, 0.88, 0.06, 1.0, tocolor(64, 178, 96, 255), "center", "center")
    end
end)

addEvent("nge:status", true)
addEventHandler("nge:status", root, function(text, ok)
    if RP:isWindowOpen("atm") then
        RP:windowLabel("atm", "status", text, 0.06, 0.82, 0.88, 0.05, 0.85,
            ok and tocolor(64, 178, 96, 255) or tocolor(214, 61, 61, 255), "center", "center")
    end
    RP:notify(text, ok and 64 or 214, ok and 178 or 61, ok and 96 or 61)
end)
