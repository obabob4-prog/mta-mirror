--[[
    ng-inventory c_inventory.lua - inventory UI (client)
    5x4 slot grid, click a slot for Use/Drop/Give actions.
]]

local RP = exports["ng-rp"]
local currentItems = {}
local selectedIndex = 0

-- when the premium CEF inventory (gta4inver) is running, keep this legacy
-- DX window dormant so the two UIs never open on top of each other
local function luxuryInventoryActive()
    local r = getResourceFromName("gta4inver")
    return r and getResourceState(r) == "running"
end

local function drawSlots()
    local sw, sh = guiGetScreenSize()
    local iw, ih = 500, 520
    RP:openWindow("inv", "INVENTORY", math.floor((sw - iw) / 2), math.floor((sh - ih) / 2), iw, ih)
    RP:windowClear("inv")
    local cols, rows = 5, 4
    local padX, padY = 0.02, 0.03
    local cellW = (1.0 - padX * (cols + 1)) / cols
    local cellH = (0.72 - padY * (rows + 1)) / rows
    for i = 1, cols * rows do
        local c = (i - 1) % cols
        local r = math.floor((i - 1) / cols)
        local rx = padX + c * (cellW + padX)
        local ry = padY * 2 + r * (cellH + padY)
        local it = currentItems[i]
        if it then
            RP:windowButton("inv", "slot" .. i,
                (it.icon or it.item:sub(1, 2):upper()) .. "\n" .. it.name .. (it.amount > 1 and (" x" .. it.amount) or ""),
                rx, ry, cellW, cellH, function()
                selectedIndex = i
                drawSlots()
            end, i == selectedIndex and tocolor(74, 163, 255, 90) or nil)
        else
            RP:windowLabel("inv", "slot" .. i, "", rx, ry, cellW, cellH)
        end
    end
    local it = currentItems[selectedIndex]
    if it then
        RP:windowLabel("inv", "selName", it.name .. " (x" .. it.amount .. ")", 0.04, 0.76, 0.6, 0.05, 0.9, nil, "left", "center")
        RP:windowButton("inv", "use", "USE", 0.04, 0.83, 0.28, 0.09, function()
            triggerServerEvent("ngi:use", localPlayer, it.item)
            setTimer(refreshInventory, 400, 1)
        end, tocolor(40, 96, 160, 220))
        RP:windowButton("inv", "drop", "DROP", 0.36, 0.83, 0.28, 0.09, function()
            triggerServerEvent("ngi:drop", localPlayer, it.item)
            setTimer(refreshInventory, 400, 1)
        end)
        RP:windowButton("inv", "give", "GIVE", 0.68, 0.83, 0.28, 0.09, function()
            RP:openWindow("give", "GIVE ITEM", 800, 400, 360, 180)
            RP:windowClear("give")
            RP:windowEdit("give", "name", "", 0.08, 0.20, 0.84, 0.14)
            RP:windowButton("give", "ok", "GIVE TO PLAYER", 0.08, 0.42, 0.84, 0.14, function()
                triggerServerEvent("ngi:give", localPlayer, it.item, RP:windowGetEdit("give", "name"))
                RP:closeWindow("give")
                setTimer(refreshInventory, 400, 1)
            end)
            RP:windowButton("give", "cancel", "CANCEL", 0.08, 0.62, 0.84, 0.14, function()
                RP:closeWindow("give")
            end, tocolor(120, 30, 30, 200))
        end)
    else
        RP:windowLabel("inv", "selName", "Click an item to manage it. Slots: " .. #currentItems .. "/20", 0.04, 0.76, 0.9, 0.05, 0.85, tocolor(150, 160, 172, 255), "left", "center")
    end
    RP:windowButton("inv", "close", "CLOSE", 0.04, 0.93, 0.92, 0.055, function()
        RP:closeWindow("inv")
    end, tocolor(120, 30, 30, 200))
end

function refreshInventory()
    triggerServerEvent("ngi:open", localPlayer)
end

addEvent("ngi:show", true)
addEventHandler("ngi:show", root, function(items)
    currentItems = items or {}
    if RP:isWindowOpen("inv") then drawSlots() end
end)

addEvent("ngi:toggle", true)
addEventHandler("ngi:toggle", root, function()
    if luxuryInventoryActive() then return end
    if RP:isWindowOpen("inv") then
        RP:closeWindow("inv")
    else
        RP:openWindow("inv", "PERSONAL INVENTORY", 560, 220, 800, 560)
        refreshInventory()
        drawSlots()
    end
end)

bindKey("i", "down", function()
    if luxuryInventoryActive() then return end
    if getElementData(localPlayer, "char.spawned") then
        triggerServerEvent("ngi:open", localPlayer)
        triggerEvent("ngi:toggle", localPlayer)
    end
end)
