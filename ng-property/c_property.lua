--[[
    ng-property c_property.lua - shop UI (24/7 + pharmacy) (client)
]]

local RP = exports["ng-rp"]

local SHOP_ITEMS = {
    shop = {
        {item = "burger", label = "Burger", price = 12},
        {item = "pizza", label = "Pizza slice", price = 18},
        {item = "water", label = "Water", price = 5},
        {item = "soda", label = "Soda", price = 6},
        {item = "phone", label = "Phone", price = 350},
        {item = "radio", label = "Radio", price = 80},
        {item = "repairkit", label = "Repair kit", price = 220},
        {item = "fuelcan", label = "Fuel canister", price = 60},
        {item = "weapon_pistol", label = "Pistol + ammo", price = 900},
    },
    pharmacy = {
        {item = "medkit", label = "Medkit", price = 90},
        {item = "water", label = "Water", price = 5},
    },
}

addEvent("ngp2:showShop", true)
addEventHandler("ngp2:showShop", root, function(propId, name, ptype)
    local list = SHOP_ITEMS[ptype] or SHOP_ITEMS.shop
    RP:openWindow("shop", tostring(name) .. " - SHOP", 720, 200, 480, 560)
    RP:windowClear("shop")
    local y = 0.10
    for _, it in ipairs(list) do
        RP:windowLabel("shop", "l" .. it.item, it.label, 0.06, y, 0.5, 0.055, 0.9, nil, "left", "center")
        RP:windowLabel("shop", "p" .. it.item, "$" .. it.price, 0.58, y, 0.15, 0.055, 0.9, tocolor(64, 178, 96, 255), "left", "center")
        RP:windowButton("shop", "b" .. it.item, "BUY", 0.75, y, 0.18, 0.055, function()
            triggerServerEvent("ngp2:buyItem", localPlayer, propId, it.item)
        end)
        y = y + 0.075
    end
    RP:windowLabel("shop", "status", "", 0.06, 0.85, 0.88, 0.05, 0.85, tocolor(150, 160, 172, 255), "center", "center")
    RP:windowButton("shop", "close", "CLOSE", 0.30, 0.92, 0.4, 0.06, function()
        RP:closeWindow("shop")
    end, tocolor(120, 30, 30, 200))
end)

addEvent("ngp2:status", true)
addEventHandler("ngp2:status", root, function(text, ok)
    if RP:isWindowOpen("shop") then
        RP:windowLabel("shop", "status", text, 0.06, 0.85, 0.88, 0.05, 0.85,
            ok and tocolor(64, 178, 96, 255) or tocolor(214, 61, 61, 255), "center", "center")
    end
    RP:notify(text, ok and 64 or 214, ok and 178 or 61, ok and 96 or 61)
end)
