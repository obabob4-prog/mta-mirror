--| Var's



interface = {}

inspected = {}



--| Slot's


slots['interaction'] = {



    ['main'] = {

        {605 - 308, 350 + 12, 87, 87},
        {707 - 308, 350 + 12, 87, 87},
        {809 - 308, 350 + 12, 87, 87},
        {911 - 308, 350 + 12, 87, 87},
        {1013 - 308, 350 + 12, 87, 87},
        {605 - 308, 450 + 12, 87, 87},
        {707 - 308, 450 + 12, 87, 87},
        {809 - 308, 450 + 12, 87, 87},
        {911 - 308, 450 + 12, 87, 87},
        {1013 - 308, 450 + 12, 87, 87},
        {605 - 308, 550 + 12, 87, 87},
        {707 - 308, 550 + 12, 87, 87},
        {809 - 308, 550 + 12, 87, 87},
        {911 - 308, 550 + 12, 87, 87},
        {1013 - 308, 550 + 12, 87, 87},
        {605 - 308, 650 + 12, 87, 87},
        {707 - 308, 650 + 12, 87, 87},
        {809 - 308, 650 + 12, 87, 87},
        {911 - 308, 650 + 12, 87, 87},
        {1013 - 308, 650 + 12, 87, 87},
        {605 - 308, 750 + 12, 87, 87},
        {707 - 308, 750 + 12, 87, 87},
        {809 - 308, 750 + 12, 87, 87},
        {911 - 308, 750 + 12, 87, 87},
        {1013 - 308, 750 + 12, 87, 87},

    },



    ['secondary'] = {

        {605 + 559, 350 + 12, 87, 87},
        {707 + 559, 350 + 12, 87, 87},
        {809 + 559, 350 + 12, 87, 87},
        {911 + 559, 350 + 12, 87, 87},
        {1013 + 559, 350 + 12, 87, 87},
        {605 + 559, 450 + 12, 87, 87},
        {707 + 559, 450 + 12, 87, 87},
        {809 + 559, 450 + 12, 87, 87},
        {911 + 559, 450 + 12, 87, 87},
        {1013 + 559, 450 + 12, 87, 87},
        {605 + 559, 550 + 12, 87, 87},
        {707 + 559, 550 + 12, 87, 87},
        {809 + 559, 550 + 12, 87, 87},
        {911 + 559, 550 + 12, 87, 87},
        {1013 + 559, 550 + 12, 87, 87},
        {605 + 559, 650 + 12, 87, 87},
        {707 + 559, 650 + 12, 87, 87},
        {809 + 559, 650 + 12, 87, 87},
        {911 + 559, 650 + 12, 87, 87},
        {1013 + 559, 650 + 12, 87, 87},
        {605 + 559, 750 + 12, 87, 87},
        {707 + 559, 750 + 12, 87, 87},
        {809 + 559, 750 + 12, 87, 87},
        {911 + 559, 750 + 12, 87, 87},
        {1013 + 559, 750 + 12, 87, 87},


    },



}



--| Interface

local scrollOffset = 0
local scrollOffset_ = 0
local maxVisibleRows = 5
local itemsPerRow = 5
local slotSize = 87
local slotSpacing = 15


function renderInspect()



    --| Cursor



    cursorUpdate ()

    

    --| Button's

    interface['buttons'] = {



        ['actions'] = {

            ['use'] = {interpolatePosition(844, 317, 261, 64, {255, 255, 255}, {89, 178, 104}, 1200, "OutQuad", "use")},

            ['use alpha'] = {interpolatePosition(844, 317, 261, 64, {15, 2, 0}, {100, 15, 0}, 1600, "OutQuad", "use alpha")},

            

            ['send'] = {interpolatePosition(844, 389, 261, 64, {255, 255, 255}, {89, 178, 104}, 1200, "OutQuad", "send")},

            ['send alpha'] = {interpolatePosition(844, 389, 261, 64, {15, 2, 0}, {100, 15, 0}, 1600, "OutQuad", "send alpha")},

        },



    }

    local inspectedPlayer = inspected['inspectData']
    if not isElement(inspectedPlayer) then
        closeInspect()
        return
    end
    
    local player = localPlayer
    local x, y, z = getElementPosition(player)
    local xx, yy, zz = getElementPosition(inspectedPlayer)
    if getDistanceBetweenPoints3D(x, y, z, xx, yy, zz) > 5 then
        closeInspect()
    end


    --| Render animations

    if not interface["animations"]["base"]["tick_out"] then 



        interface["animations"]["base"]["alpha"] = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount() - interface["animations"]["base"]["tick"]) / 700, "OutQuad")

        

    else

        

        if not interface["animations"]["base"]["last_alpha"] then 

            interface["animations"]["base"]["last_alpha"] = interface["animations"]["base"]["alpha"]

        end



        if ((getTickCount() - interface["animations"]["base"]["tick_out"]) >= 400) then 

            closeInspect()

        end

        

        interface["animations"]["base"]["alpha"] = interpolateBetween(interface["animations"]["base"]["last_alpha"], 0, 0, 0, 0, 0, (getTickCount() - interface["animations"]["base"]["tick_out"]) / 400, "OutQuad")

        

    end

    local alpha = interface["animations"]["base"]["alpha"]

    

    --| General background

    _dxDrawImage(0, 0, screenW, screenH, "core/assets/images/background2.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)

    dxDrawImage(478, 269, 19, 29, 'core/assets/images/logo.png', 0, 0, 0, tocolor(89, 178, 104, alpha))
    dxDrawText('Goiaba Roleplay', 526, 272, 148, 24, tocolor(89, 178, 104, alpha), 1, getFont('bold', 20))
    dxDrawText('Inventário', 499, 304, 92, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 20), 'center')


    --| Slots

    dxDrawText('S    l    o    t    s            d  o            i    n    v    e    n    t    á    r    i    o', 0, 580, 487, 26, tocolor(255, 255, 255, alpha * 0.15), 1, getFont('bold', 22), 'left', 'top', false, false, false, false, false, - 90)
    dxDrawImage(292, 362, 495, 487, "core/assets/images/slots2.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)
    drawBorder(1, 815, 549, 3, 113, tocolor(255, 255, 255, alpha * 0.02))
    drawBorder(1, 1038, 549, 3, 113, tocolor(255, 255, 255, alpha * 0.02))


    --| Bag 

    if bag[localPlayer] then

        local playerItens = bag[localPlayer]["itemData"]
        if playerItens and (#playerItens ~= 0) then
            for row = 1, maxVisibleRows do
                local rowIndex = row + scrollOffset
                for col = 1, itemsPerRow do
                    local index = ((rowIndex - 1) * itemsPerRow) + col
                
                    if playerItens[index] then
                        local item = playerItens[index]
                        local id = item["itemID"]
                        local name, slot, amount, image = config["itens"][id]["name"], item["itemSlot"], item["itemAmount"], icons[id]
                    
                        local posX = 294 + ((col - 1) * (slotSize + slotSpacing))
                        local posY = 362 + ((row - 1) * (slotSize + 13))

                        if interface["selected"]["main"]["index"] and interface["selected"]["main"]["item"] and (interface["selected"]["main"]["index"] == index) and (getTickCount() - interface["selected"]["main"]["tick"] >= 100) then
                            local mx, my = getCursorPosition()
                            mousex, mousey = (mx * screenW), (my * screenH)
                            _dxDrawImage(mousex - (slotSize / 2), mousey - (slotSize / 2), slotSize, slotSize, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha / 2))
                            _dxDrawImage(mousex - (config["default"]["itemSize"] / 2), mousey - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                        else
                            dxDrawImage(posX, posY, slotSize, slotSize, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.2), false)

                            if image and image["image"] then
                                dxDrawImage(posX + (slotSize / 2) - (config["default"]["itemSize"] / 2), posY + (slotSize / 2) - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                            end
        
                            dxDrawText(formatNumberEffect(amount), posX + 5, posY + 5, 5, 5, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15))
        
                            if isMouseInPosition(posX, posY, slotSize, slotSize) then 
                                local mx, my = getCursorPosition()
                                if not mx or not my then return end
                                mousex, mousey = (mx * screenW), (my * screenH)
        
                                if id == 110 then
                                    dxDrawText('Dinheiro', mousex - 50, mousey, 115, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15), "center", "center")
                                    dxDrawText(formatNumberC(amount), mousex - 50, mousey + 20, 115, 24, tocolor(89, 178, 104, alpha), 1, getFont('bold', 15), "center", "center")
                                else
                                    if id == 123 or id == 120 then
                                        local itemData = fromJSON(item["itemInfos"])
                                        if itemData[1] then
                                            dxDrawText(itemData[1], mousex - 50, mousey, 115, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15), "center", "center")
                                        end
                                    else
                                        dxDrawText(name, mousex - 50, mousey, 115, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15), "center", "center")
                                    end
                                    dxDrawText(amount..'x', mousex - 50, mousey + 20, 115, 24, tocolor(89, 178, 104, alpha), 1, getFont('bold', 15), "center", "center")
                                end
                            end
                        end
                    end
                end
            end
            local totalItems = #bag[localPlayer]["itemData"]
            local totalRows = math.ceil(totalItems / itemsPerRow)

            if totalRows > maxVisibleRows then
                local scrollbarHeight = (maxVisibleRows / totalRows) * 200
                local scrollbarY = 350 + ((scrollOffset / (totalRows - maxVisibleRows)) * (487 - scrollbarHeight))
            
                drawBorder(4, 800, 350, 3, 490, tocolor(255, 255, 255, alpha * 0.05))
                drawBorder(4, 800, scrollbarY, 3, scrollbarHeight, tocolor(89, 178, 104, alpha))
            end
        end

    end

    -- // OPTIONS 
    dxDrawImage(507, 876, 248, 64, 'core/assets/images/amountStroke2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    if isBoxActive("amount") then 
    
        dxDrawText(getEditboxText("amount"), 594, 896, 107, 24, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('bold', 20))
    
    else
    
        dxDrawText(#getEditboxText("amount") ~= 0 and getEditboxText("amount") or "Quantidade", 594, 896, 107, 24, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('bold', 20))
    
    end

    --| Amount input
    dxDrawEditbox(507, 876, 248, 64, 9, "amount", true)

    drawBorder(32, 266, 876, 228, 64, (isMouseInPosition(266, 876, 228, 64) and tocolor(89, 178, 104, alpha) or tocolor(255, 255, 255, alpha * 0.02)))
    dxDrawText('Retirar item', 266, 876, 228, 64, isMouseInPosition(266, 876, 228, 64) and tocolor(255, 255, 255, alpha) or tocolor(89, 178, 104, alpha), 1, getFont('bold', 20), 'center', 'center')
    

    --| Inspect itens 

    dxDrawText(getPlayerName(inspected['inspectData']).." ("..(getElementData(inspected['inspectData'], "ID") or 0)..')', 1164, 220, 294, 36, tocolor(255, 255, 255, alpha), 1, getFont('bold', 30))
    dxDrawText('Você está acessando o inventário do cidadão selecionado\nveja os itens que ele possui.', 1164, 275, 496, 42, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 18))
    
    dxDrawText('S    l    o    t    s            do            i    n    v    e    n    t    á    r    i    o', 866, 580, 487, 26, tocolor(255, 255, 255, alpha * 0.15), 1, getFont('bold', 22), 'left', 'top', false, false, false, false, false, - 90)
    dxDrawImage(1164, 362, 495, 487, "core/assets/images/slots2.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)

    if inspected['data']["itemData"] then
        local playerItens = inspected['data']["itemData"]
        if playerItens and (#playerItens ~= 0) then
            for row = 1, maxVisibleRows do
                local rowIndex = row + scrollOffset_
                for col = 1, itemsPerRow do
                    local index = ((rowIndex - 1) * itemsPerRow) + col
                
                    if playerItens[index] then
                        local item = playerItens[index]
                        local id = item["itemID"]
                        local name, slot, amount, image = config["itens"][id]["name"], item["itemSlot"], item["itemAmount"], icons[id]
                    
                        local posX = 1166 + ((col - 1) * (slotSize + slotSpacing))
                        local posY = 365 + ((row - 1) * (slotSize + 13))

                        if interface["selected"]["inspected"]["index"] and interface["selected"]["inspected"]["item"] and (interface["selected"]["inspected"]["index"] == index) and (getTickCount() - interface["selected"]["inspected"]["tick"] >= 100) then
                            local mx, my = getCursorPosition()
                            mousex, mousey = (mx * screenW), (my * screenH)
                            _dxDrawImage(mousex - (slotSize / 2), mousey - (slotSize / 2), slotSize, slotSize, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha / 2))
                            _dxDrawImage(mousex - (config["default"]["itemSize"] / 2), mousey - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                        else
                            dxDrawImage(posX, posY, slotSize, slotSize, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.2), false)

                            if image and image["image"] then
                                dxDrawImage(posX + (slotSize / 2) - (config["default"]["itemSize"] / 2), posY + (slotSize / 2) - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                            end
        
                            dxDrawText(formatNumberEffect(amount), posX + 5, posY + 5, 5, 5, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15))
        
                            if isMouseInPosition(posX, posY, slotSize, slotSize) then 
                                local mx, my = getCursorPosition()
                                mousex, mousey = (mx * screenW), (my * screenH)
        
                                if id == 110 then
                                    dxDrawText('Dinheiro', mousex - 50, mousey, 115, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15), "center", "center")
                                    dxDrawText(formatNumberC(amount), mousex - 50, mousey + 20, 115, 24, tocolor(89, 178, 104, alpha), 1, getFont('bold', 15), "center", "center")
                                else
                                    if id == 123 or id == 120 then
                                        local itemData = fromJSON(item["itemInfos"])
                                        if itemData[1] then
                                            dxDrawText(itemData[1], mousex - 50, mousey, 115, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15), "center", "center")
                                        end
                                    else
                                        dxDrawText(name, mousex - 50, mousey, 115, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15), "center", "center")
                                    end
                                    dxDrawText(amount..'x', mousex - 50, mousey + 20, 115, 24, tocolor(89, 178, 104, alpha), 1, getFont('bold', 15), "center", "center")
                                end
                            end
                        end
                    end
                end
            end
            local totalItems = #inspected['data']["itemData"]
            local totalRows_ = math.ceil(totalItems / itemsPerRow)

            if totalRows_ > maxVisibleRows then
                local scrollbarHeight = (maxVisibleRows / totalRows_) * 200
                local scrollbarY = 350 + ((scrollOffset_ / (totalRows_ - maxVisibleRows)) * (487 - scrollbarHeight))
            
                drawBorder(4, 1675, 350, 3, 490, tocolor(255, 255, 255, alpha * 0.05))
                drawBorder(4, 1675, scrollbarY, 3, scrollbarHeight, tocolor(89, 178, 104, alpha))
            end
        end
    end


end



--| Render



local function removeFonts ()

    if fontsInspect then

        for i, v in ipairs(fontsInspect) do

            if isElement(v) then

                destroyElement(v)

            end

        end

    end

end



function openInspect(inspectData)
    if isEventHandlerAdded('onClientRender', root, renderStore) then 
        return 
    end

    if isEventHandlerAdded('onClientRender', root, renderBag) then 
        return 
    end

    if isEventHandlerAdded('onClientRender', root, renderChest) then 
        return 
    end

    if isEventHandlerAdded('onClientRender', root, renderTrunk) then 
        return 
    end

    if not isEventHandlerAdded('onClientRender', root, renderInspect) then
        fontsInspect = {
            exports['goiaba_fonts']:useFont('int:bold', sy * (12 / 1.25));
            exports['goiaba_fonts']:useFont('int:regular', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont('int:medium', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont('int:semibold', sy * (12 / 1.25));
            exports['goiaba_fonts']:useFont('int:extrabold', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont("rc:medium", sx*20);
        }

        interface = {
            ['animations'] = {
                ['base'] = {
                    ['alpha'] = 0,
                    ['tick'] = getTickCount(),
                },
            },
            ['selected'] = {
                ['main'] = {
                    ['index'] = 0,
                    ['item'] = false,
                },
                ['inspected'] = {
                    ['index'] = 0,
                    ['item'] = false,
                },
            },
            ['scroll'] = {
                ['data'] = 0,
                ['old'] = 0,
                ['position'] = 0,
                ['tick'] = 0,
            },
        }
        inspected = inspectData
        setElementData(localPlayer, 'bloqInterface', true)
        setElementData(localPlayer, 'painelAberto', true)
        addEventHandler('onClientRender', root, renderInspect, false, "low-10")
        showCursor(true)
        showChat(false)
    end
end
addEvent("FS:openInspect", true)
addEventHandler("FS:openInspect", root, openInspect)

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        fontsInspect = {
            exports['goiaba_fonts']:useFont('int:bold', sy * (12 / 1.25));
            exports['goiaba_fonts']:useFont('int:regular', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont('int:medium', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont('int:semibold', sy * (12 / 1.25));
            exports['goiaba_fonts']:useFont('int:extrabold', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont("rc:medium", sx*20);
        }
    end
end)


function closeInspect()

    if isEventHandlerAdded('onClientRender', root, renderInspect) then 



        if not interface['animations']['base']['tick_out'] then 

            interface['animations']['base']['tick_out'] = getTickCount()

            return 

        end

        setElementData(localPlayer, 'bloqInterface', false)

        setElementData(localPlayer, 'painelAberto', false)

        triggerServerEvent("FS:stopInspect", localPlayer, inspected["inspectData"])

        removeEventHandler('onClientRender', root, renderInspect)

        showCursor(false)

        showChat(true)

        destroyBox()
    end
end
addEvent("FS:closeInspect", true)
addEventHandler("FS:closeInspect", root, closeInspect)

bindKey("backspace", "down", closeInspect)



addEventHandler('onClientKey', root, function (key, press)

    if isEventHandlerAdded('onClientRender', root, renderInspect) and press then 

        if key == 'escape' then

            closeInspect()

            cancelEvent()

        end

    end

end)



--| Click function's



addEventHandler("onClientClick", root, function(button, state)

    if isEventHandlerAdded('onClientRender', root, renderInspect) then 



        if (button == "left") and (state == "down") then

            --| Item click's

            if bag[localPlayer] then
                local playerItens = bag[localPlayer]["itemData"]
                if playerItens and (#playerItens ~= 0) then
                    for row = 1, maxVisibleRows do
                        local rowIndex = row + scrollOffset
                        for col = 1, itemsPerRow do
                            local index = ((rowIndex - 1) * itemsPerRow) + col
                        
                            if playerItens[index] then
                                local item = playerItens[index]
                                local id = item["itemID"]
                                local name, slot, amount, image = config["itens"][id]["name"], item["itemSlot"], item["itemAmount"], icons[id]
                            
                                local posX = 294 + ((col - 1) * (slotSize + slotSpacing))
                                local posY = 362 + ((row - 1) * (slotSize + 13))
    
                                if isCursorOnElement(posX, posY, slotSize, slotSize) then
                                    interface["selected"]["main"] = {
                                        ['item'] = item,
                                        ['index'] = index,
                                        ['tick'] = getTickCount(),
                                    }
                                    break
                                end
                            end
                        end
                    end
                end
            end

            if inspected['canTake'] then 

                local playerItens = inspected['data']["itemData"]
                if playerItens and (#playerItens ~= 0) then
                    for row = 1, maxVisibleRows do
                        local rowIndex = row + scrollOffset_
                        for col = 1, itemsPerRow do
                            local index = ((rowIndex - 1) * itemsPerRow) + col
                        
                            if playerItens[index] then
                                local item = playerItens[index]
                                local id = item["itemID"]
                                local name, slot, amount, image = config["itens"][id]["name"], item["itemSlot"], item["itemAmount"], icons[id]
                            
                                local posX = 1166 + ((col - 1) * (slotSize + slotSpacing))
                                local posY = 365 + ((row - 1) * (slotSize + 13))

                                if isCursorOnElement(posX, posY, slotSize, slotSize) then
                                    interface["selected"]["inspected"] = {
                                        ['item'] = item,
                                        ['index'] = index,
                                        ['tick'] = getTickCount(),
                                    }
                                    break
                                end
                            end
                        end
                    end
                end
            end

        elseif (button == "left") and (state == "up") then

            if (interface["selected"]["main"] and interface["selected"]["main"]["item"]) then

                if (getTickCount() - interface["selected"]["main"]["tick"] >= 100) then 

                    for i = 1, 20 do

                        if isCursorOnElement(slots['interaction']["main"][i][1], slots['interaction']["main"][i][2], slots['interaction']["main"][i][3], slots['interaction']["main"][i][4]) then

                            changeSlot( interface["selected"]["main"]["index"], i)

                            break

                        end

                    end

                    interface["selected"]["main"] = {

                        ['index'] = 0,

                        ['item'] = false,

                    }

                else

                    interface["selected"]["main"]["index"] = nil

                end

            elseif (interface["selected"]["inspected"] and interface["selected"]["inspected"]["item"]) then 

                if (getTickCount() - interface["selected"]["inspected"]["tick"] >= 100) then 

                    for i = 1, 20 do

                        if isCursorOnElement(slots['interaction']["main"][i][1], slots['interaction']["main"][i][2], slots['interaction']["main"][i][3], slots['interaction']["main"][i][4]) or isMouseInPosition(570, 455, 220, 40) then 

                            if inspected['canTake'] then 

                                local ammount = (#getEditboxText("amount") ~= 0 and tonumber(getEditboxText("amount")) or 1)

                                if getKeyState('lshift') then

                                    ammount = interface["selected"]['inspected']["item"]["itemAmount"]

                                end

                                triggerServerEvent("FS:takeInspected", localPlayer, localPlayer, inspected['inspectData'], interface["selected"]["inspected"]["item"], ammount)

                            end

                            break

                        end

                    end

                    interface["selected"]["inspected"] = {

                        ['index'] = 0,

                        ['item'] = false,

                    }

                else

                    interface["selected"]["inspected"]["index"] = nil

                end

            end

        end

    end

end)



--| Update inspected



addEvent("FS:updateClientInspect", true)

addEventHandler("FS:updateClientInspect", getRootElement(), function(infos)

    inspected = infos

end)



--| Inspect proposal - Render

function respc(number)

    return number

end

local proposal = {}
local request = {}
local pattern_y = (screenH / 2) - respc(50/2)

function renderProposal()



    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount() - proposal['animations']['tick']) / 700, "OutQuad")
    local timer = interpolateBetween(10, 0, 0, 0, 0, 0, (getTickCount() - proposal['animations']['tick']) / 10000, "Linear")
    local x, y = screenW - respc(20) - respc(request.textWidth + 133), pattern_y

    print('asdadasdadaa')

    --| Background
    _drawBorder(13, x, y, respc(request.textWidth + 133), respc(50), tocolor(25, 27, 29, (alpha/100)*50), respc(6), false)

    --| Text 
    _dxDrawText("O jogador "..proposal['data']['owner']['name'].." ("..proposal['data']['owner']['id']..") está querendo te "..(proposal['data']['canTake'] and "saquear" or "revistar")..".", x + respc(15), y, respc(190), respc(50), tocolor(255, 255, 255, (alpha/100)*90), 1, fontsProposal[1], 'left', 'center', false, false, false, true)

    --| Button's
    _drawBorder(13, x + respc(15) + respc(request.textWidth + 30), y + respc(8), respc(34), respc(34), tocolor(255, 255, 255, (alpha/100)*3))
    _dxDrawText('R', x + respc(15) + respc(request.textWidth + 30), y + respc(9), respc(34), respc(34), tocolor(255, 255, 255, (alpha/100)*65), 1, fontsProposal[1], 'center', 'center')

    _drawBorder(13, x + respc(15) + respc(request.textWidth + 30) + respc(34) + respc(5), y + respc(8), respc(34), respc(34), tocolor(25, 27, 29, (alpha/100)*10))
    _dxDrawText('Y', x + respc(15) + respc(request.textWidth + 30) + respc(34) + respc(5), y + respc(9), respc(34), respc(34), tocolor(255, 255, 255, (alpha/100)*85), 1, fontsProposal[1], 'center', 'center')

end





--| Inspect proposal - Event's



local function removeFonts2 ()

    if fontsProposal then

        for i, v in ipairs(fontsProposal) do

            if isElement(v) then

                destroyElement(v)

            end

        end

    end

end



function openProposal(proposalData)

    if not isEventHandlerAdded('onClientRender', root, renderProposal) then 



        --removeFonts2()



        fontsProposal = {
            [1] = exports['goiaba_fonts']:useFont("rc:medium", sx*16);
        }
        addEventHandler("onClientResourceStart", root, function(res)
            if getResourceName(res) == "goiaba_fonts" then
                fontsProposal = {
                    [1] = exports['goiaba_fonts']:useFont("rc:medium", sx*16);
                }
            end
        end)



        proposal = {

            ['animations'] = {

                ['tick'] = getTickCount(),

            },



            ['data'] = proposalData,

            ['closeTimer'] = setTimer(function()

                triggerServerEvent("FS:proposalActions", localPlayer, "recuse", proposalData)

                closeProposal()

            end, (10 * 1000), 1)



        }

        addEventHandler('onClientRender', root, renderProposal)
        request.textWidth = dxGetTextWidth("O jogador "..proposal['data']['owner']['name'].." ("..proposal['data']['owner']['id']..") está querendo te "..(proposal['data']['canTake'] and "saquear" or "revistar")..".", 1, fontsProposal[1], true)


    end

end

addEvent("FS:openProposal", true)
addEventHandler("FS:openProposal", root, openProposal)



function closeProposal()

    if isEventHandlerAdded('onClientRender', root, renderProposal) then 

        removeEventHandler('onClientRender', root, renderProposal)

        if proposal['closeTimer'] and isTimer(proposal['closeTimer']) then 

            killTimer(proposal['closeTimer'])

            proposal['closeTimer'] = nil 

        end

        proposal = {}

        --removeFonts2()

    end

end

addEvent("FS:closeProposal", true)

addEventHandler("FS:closeProposal", root, closeProposal)



--| Inspect proposal - Function's



addEventHandler("onClientKey", root, function(button, press)

    if proposal and proposal['data'] then 

        if press then 

            if (button == "y") then 

                triggerServerEvent("FS:proposalActions", localPlayer, "accept", proposal['data'])

                closeProposal()

                cancelEvent()

            elseif (button == "r") then 

                triggerServerEvent("FS:proposalActions", localPlayer, "recuse", proposal['data'])

                closeProposal()

            end

        end

    end

end)



--| Inspect proposal - Render



local proposal2 = {}

function renderProposal2()



    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount() - proposal2['animations']['tick']) / 700, "OutQuad")

    local timer = interpolateBetween(10, 0, 0, 0, 0, 0, (getTickCount() - proposal2['animations']['tick']) / 10000, "Linear")



    dxDrawImage(664 - 500, 898 - 500, 19, 19, Images["info icon"], 0, 0, 0, tocolor(255, 255, 255, 255), false)



    dxDrawText("Informação", 700 - 500, 883 - 500, 89, 23, tocolor(89, 178, 104, alpha), 0.68, fontsProposal2[1], "left", "top")

    dxDrawText("O jogador "..proposal2['data']['owner']['name'].." ("..proposal2['data']['owner']['id']..") quer revistar seu veículo.", 700 - 500, 909 - 500, 361, 23, tocolor(255, 255, 255, (alpha/100)*65), 0.60, fontsProposal2[1], "left", "top")

    

    dxDrawRoundedRectangle(1076 - 500, 883 - 500, 51, 51, tocolor(255, 255, 255, (alpha/100)*4), 12, false)

    dxDrawText(""..math.ceil(timer).."s", 1076 - 500, 883 - 500, 51, 51, tocolor(89, 178, 104, alpha), 0.68, fontsProposal2[6], "center", "center")

    

    dxDrawText("Para aceitar aperte a tecla", 664 - 500, 972 - 500, 361, 23, tocolor(255, 255, 255, (alpha/100)*25), 0.68, fontsProposal2[1], "left", "top")

    dxDrawRoundedRectangle(881 - 500, 958 - 500, 51, 51, tocolor(255, 255, 255, (alpha/100)*4), 12, false)

    dxDrawText("Y", 881 - 500, 958 - 500, 51, 51, tocolor(89, 178, 104, alpha), 0.68, fontsProposal2[6], "center", "center")

    

    dxDrawText("Para recusar aperte a tecla", 960 - 500, 972 - 500, 361, 23, tocolor(255, 255, 255, (alpha/100)*25), 0.68, fontsProposal2[1], "left", "top")

    dxDrawRoundedRectangle(1183 - 500, 958 - 500, 51, 51, tocolor(255, 255, 255, (alpha/100)*4), 12, false)

    dxDrawText("R", 1183 - 500, 958 - 500, 51, 51, tocolor(89, 178, 104, alpha), 0.68, fontsProposal2[6], "center", "center")



end



--| Inspect proposal - Event's



local function removeFonts3 ()

    if fontsProposal2 then

        for i, v in ipairs(fontsProposal2) do

            if isElement(v) then

                destroyElement(v)

            end

        end

    end

end



function openProposal2(proposalData)

    if not isEventHandlerAdded('onClientRender', root, renderProposal2) then 



        --removeFonts3()



        fontsProposal2 = {
            [1] = exports['goiaba_fonts']:useFont('int:bold', sx*20);
            [6] = exports['goiaba_fonts']:useFont("rc:medium", sx*20);
        }

        addEventHandler("onClientResourceStart", root, function(res)
            if getResourceName(res) == "goiaba_fonts" then
                fontsProposal2 = {
                    [1] = exports['goiaba_fonts']:useFont('int:bold', sx*20);
                    [6] = exports['goiaba_fonts']:useFont("rc:medium", sx*20);
                }
            end
        end)



        proposal2 = {

            ['animations'] = {

                ['tick'] = getTickCount(),

            },



            ['data'] = proposalData,

            ['closeTimer'] = setTimer(function()

                triggerServerEvent("FS:proposalActions", localPlayer, "recuse", proposalData)

                closeProposal()

            end, (10 * 1000), 1)



        }



        addEventHandler('onClientRender', root, renderProposal2)



    end

end

addEvent("FS:openProposal2", true)

addEventHandler("FS:openProposal2", root, openProposal2)



function closeProposal2()

    if isEventHandlerAdded('onClientRender', root, renderProposal2) then 

        removeEventHandler('onClientRender', root, renderProposal2)

        if proposal2['closeTimer'] and isTimer(proposal2['closeTimer']) then 

            killTimer(proposal2['closeTimer'])

            proposal2['closeTimer'] = nil 

        end

        proposal2 = {}

        --removeFonts2()

    end

end

addEvent("FS:closeProposal2", true)

addEventHandler("FS:closeProposal2", root, closeProposal)



--| Inspect proposal2 - Function's



addEventHandler("onClientKey", root, function(button, press)

    if proposal2 and proposal2['data'] then 

        if press then 

            if (button == "y") then



                triggerServerEvent('FS:openTrunk', resourceRoot, proposal2['data']['owner']['data'], proposal2['data']['owner']['vehicle'], localPlayer)

                closeProposal2()

                cancelEvent()

            elseif (button == "r") then 

                closeProposal2()

            end

        end

    end

end)

function scrollTrunk(button)
	if isEventHandlerAdded("onClientRender", getRootElement(), renderInspect) then
        if isCursorOnElement(1020, 0, 900, 1080) then 
            if inspected['data']["itemData"] then 
                local totalItems = #inspected['data']["itemData"]
                local totalRows_ = math.ceil(totalItems / itemsPerRow)
                if button == "mouse_wheel_up" then
                    if scrollOffset_ > 0 then
                        scrollOffset_ = scrollOffset_ - 1
                    end
                elseif button == "mouse_wheel_down" then
                    if (scrollOffset_ + maxVisibleRows) < totalRows_ then
                        scrollOffset_ = scrollOffset_ + 1
                    end
                end
            end
        elseif isCursorOnElement(0, 0, 900, 1080) then
            local totalItems = #bag[localPlayer]["itemData"]
            local totalRows = math.ceil(totalItems / itemsPerRow)
            
            if button == "mouse_wheel_up" then
                if scrollOffset > 0 then
                    scrollOffset = scrollOffset - 1
                end
            elseif button == "mouse_wheel_down" then
                if (scrollOffset + maxVisibleRows) < totalRows then
                    scrollOffset = scrollOffset + 1
                end
            end
        end
	end
end
bindKey("mouse_wheel_up", "down", scrollTrunk)
bindKey("mouse_wheel_down", "down", scrollTrunk)
