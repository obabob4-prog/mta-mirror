--| Var's



interface = {}

trunk = {}



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

local scrollOffset = 0
local maxVisibleRows = 5
local itemsPerRow = 5
local slotSize = 87
local slotSpacing = 15


function renderTrunk()



    --| Cursor



    cursorUpdate ()

    

    --| Button's

    interface['buttons'] = {



        ['actions'] = {

            ['use'] = {interpolatePosition(844, 317, 261, 64, {255, 255, 255}, {77, 153, 177}, 1200, "OutQuad", "use")},

            ['use alpha'] = {interpolatePosition(844, 317, 261, 64, {15, 2, 0}, {100, 15, 0}, 1600, "OutQuad", "use alpha")},

            

            ['send'] = {interpolatePosition(844, 389, 261, 64, {255, 255, 255}, {77, 153, 177}, 1200, "OutQuad", "send")},

            ['send alpha'] = {interpolatePosition(844, 389, 261, 64, {15, 2, 0}, {100, 15, 0}, 1600, "OutQuad", "send alpha")},

        },



    }



    --| Render animations

    if not interface["animations"]["base"]["tick_out"] then 



        interface["animations"]["base"]["alpha"] = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount() - interface["animations"]["base"]["tick"]) / 700, "OutQuad")

        

    else

        

        if not interface["animations"]["base"]["last_alpha"] then 

            interface["animations"]["base"]["last_alpha"] = interface["animations"]["base"]["alpha"]

        end



        if ((getTickCount() - interface["animations"]["base"]["tick_out"]) >= 400) then 

            closeTrunk()

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

    dxDrawText('S    l    o    t    s            do            i    n    v    e    n    t    á    r    i    o', 0, 580, 487, 26, tocolor(255, 255, 255, alpha * 0.15), 1, getFont('bold', 22), 'left', 'top', false, false, false, false, false, - 90)
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
    dxDrawText(interface["selected"]["trunk"]["item"] and 'Retirar item' or 'Enviar item', 266, 876, 228, 64, isMouseInPosition(266, 876, 228, 64) and tocolor(255, 255, 255, alpha) or tocolor(89, 178, 104, alpha), 1, getFont('bold', 20), 'center', 'center')


    --| Trunk itens 

    dxDrawText(trunk['data']['personData'] and trunk['data']['personData']['vehName'] or 'Porta-Malas', 1164, 220, 294, 36, tocolor(255, 255, 255, alpha), 1, getFont('bold', 30))
    dxDrawText('Você está acessando o porta-malas do veículo selecionado veja\nos itens que possui.', 1164, 275, 496, 42, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 18))


    dxDrawText('S    l    o    t    s            do            i    n    v    e    n    t    á    r    i    o', 866, 580, 487, 26, tocolor(255, 255, 255, alpha * 0.15), 1, getFont('bold', 22), 'left', 'top', false, false, false, false, false, - 90)
    dxDrawImage(1164, 362, 495, 487, "core/assets/images/slots2.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)


    local trunkItens = trunk['data']["itemData"]
    if trunkItens and (#trunkItens ~= 0) then

        local scroll = interface['scroll']['data'] or 0  
        for i, item in ipairs(trunkItens) do

            local id = item["itemID"]
            local name, slot, amount, image = config["itens"][id]["name"], (item["itemSlot"] - scroll), item["itemAmount"], icons[id]

            if interface["selected"]["trunk"]["index"] and interface["selected"]["trunk"]["item"] and (interface["selected"]["trunk"]["index"] == i) and (getTickCount() - interface["selected"]["trunk"]["tick"] >= 100) then 

                local mx, my = getCursorPosition()
                mousex, mousey = (mx * screenW), (my * screenH)
                _dxDrawImage(mousex - sx*(87 / 2), mousey - sy*(87 / 2), sx*87, sy*87, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha / 3))
                _dxDrawImage(mousex - sx*(config["default"]["itemSize"] / 2), mousey - sy*(config["default"]["itemSize"] / 2), sx*config["default"]["itemSize"], sy*config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)

            else
                
                if (slot > 0) and (slot <= 25) then

                    if interface["selected"]["trunk"] and interface["selected"]["trunk"]["item"] and interface["selected"]["trunk"]["item"]['itemID'] == id then
                        dxDrawImage(slots['interaction']["secondary"][slot][1], slots['interaction']["secondary"][slot][2], 87, 87, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                    end
                    if image and image["image"] then
                        dxDrawImage((slots['interaction']["secondary"][slot][1] + slots['interaction']["secondary"][slot][3]) - (slots['interaction']["secondary"][slot][3]/2) - (config["default"]["itemSize"] / 2), (slots['interaction']["main"][slot][2] + slots['interaction']["main"][slot][4]) - (slots['interaction']["main"][slot][4]/2) - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                    end
                    
                    if (isMouseInPosition(slots['interaction']["secondary"][slot][1], slots['interaction']["secondary"][slot][2], 87, 87)) then 

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

    

    dxDrawRectangle(1684, 362, 3, 487, tocolor(255, 255, 255, alpha * 0.03))
    dxDrawRectangle(1684, 362 + ((487 - 150) * ((interface['scroll'] and interface['scroll']['data'] or 0) / 40)), 3, 150, tocolor(89, 178, 104, alpha))

    

end



--| Render



local function removeFonts ()

    if fontsTrunk then

        for i, v in ipairs(fontsTrunk) do

            if isElement(v) then

                destroyElement(v)

            end

        end

    end

end



function openTrunk(trunkData)



    if isEventHandlerAdded('onClientRender', root, renderStore) then 

        return 

    end



    if isEventHandlerAdded('onClientRender', root, renderInspect) then

        return 

    end



    if isEventHandlerAdded('onClientRender', root, renderBag) then 

        return 

    end



    if isEventHandlerAdded('onClientRender', root, renderChest) then 

        return 

    end



    if not isEventHandlerAdded('onClientRender', root, renderTrunk) then 



        --removeFonts()



        fontsTrunk = {
            exports['goiaba_fonts']:useFont('int:bold', sy * (12 / 1.25));
            exports['goiaba_fonts']:useFont('int:regular', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont('int:medium', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont('int:semibold', sy * (12 / 1.25));
            exports['goiaba_fonts']:useFont('int:extrabold', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont("rc:medium", sx*20, false, "cleartype");
        }

        addEventHandler("onClientResourceStart", root, function(res)
            if getResourceName(res) == "goiaba_fonts" then
                fontsTrunk = {
                    exports['goiaba_fonts']:useFont('int:bold', sy * (12 / 1.25));
                    exports['goiaba_fonts']:useFont('int:regular', sy * (11 / 1.25));
                    exports['goiaba_fonts']:useFont('int:medium', sy * (11 / 1.25));
                    exports['goiaba_fonts']:useFont('int:semibold', sy * (12 / 1.25));
                    exports['goiaba_fonts']:useFont('int:extrabold', sy * (11 / 1.25));
                    exports['goiaba_fonts']:useFont("rc:medium", sx*20, false, "cleartype");
                }
            end
        end)


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



                ['trunk'] = {

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

        trunk = trunkData



        setElementData(localPlayer, 'bloqInterface', true)

        setElementData(localPlayer, 'painelAberto', true)

        addEventHandler('onClientRender', root, renderTrunk, false, "low-10")

        showCursor(true)

        showChat(false)



    end

end

addEvent("FS:openTrunk", true)

addEventHandler("FS:openTrunk", root, openTrunk)



function closeTrunk()

    if isEventHandlerAdded('onClientRender', root, renderTrunk) then 



        if not interface['animations']['base']['tick_out'] then 

            interface['animations']['base']['tick_out'] = getTickCount()

            return 

        end



        setElementData(localPlayer, 'bloqInterface', false)

        setElementData(localPlayer, 'painelAberto', false)

        triggerServerEvent("FS:closeTrunk", localPlayer, trunk["vehData"])

        removeEventHandler('onClientRender', root, renderTrunk)

        showCursor(false)

        showChat(true)

        destroyBox()

        --removeFonts()



    end

end

addEvent("FS:closeTrunk", true)

addEventHandler("FS:closeTrunk", root, closeTrunk)

bindKey("backspace", "down", closeTrunk)



addEventHandler('onClientKey', root, function (key, press)

    if isEventHandlerAdded('onClientRender', root, renderTrunk) and press then 

        if key == 'escape' then

            closeTrunk()

            cancelEvent()

        end

    end

end)



--| Click function's



addEventHandler("onClientClick", root, function(button, state)

    if isEventHandlerAdded('onClientRender', root, renderTrunk) then 



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



            local trunkItens = trunk['data']["itemData"]

            if trunkItens and (#trunkItens ~= 0) then

                local scroll = interface['scroll']['data'] or 0  

                for i, item in ipairs(trunkItens) do

                    local scroll = (interface['scroll']['data'] or 0)

                    local slot = (item["itemSlot"] - scroll)

                    if (slot > 0) and (slot <= 25) then

                        if isCursorOnElement(slots['interaction']["secondary"][slot][1], slots['interaction']["secondary"][slot][2], slots['interaction']["secondary"][slot][3], slots['interaction']["secondary"][slot][4]) then

                            interface["selected"]["trunk"] = {

                                ['item'] = item,

                                ['index'] = i,

                                ['tick'] = getTickCount(),

                            }

                            break

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

                        elseif isCursorOnElement(slots['interaction']["secondary"][i][1], slots['interaction']["secondary"][i][2], slots['interaction']["secondary"][i][3], slots['interaction']["secondary"][i][4]) or isMouseInPosition(266, 876, 228, 64) then 

                            local ammount = (#getEditboxText("amount") ~= 0 and tonumber(getEditboxText("amount")) or 1)

                            if getKeyState('lshift') then

                                ammount = interface["selected"]['main']["item"]["itemAmount"]

                            end

                            triggerServerEvent("FS:sendItemToTrunk", localPlayer, localPlayer, trunk['vehData'], interface["selected"]["main"]["item"], ammount)

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

            elseif (interface["selected"]["trunk"] and interface["selected"]["trunk"]["item"]) then 

                if (getTickCount() - interface["selected"]["trunk"]["tick"] >= 100) then 

                    for i = 1, 20 do

                        if isCursorOnElement(slots['interaction']["secondary"][i][1], slots['interaction']["secondary"][i][2], slots['interaction']["secondary"][i][3], slots['interaction']["secondary"][i][4]) then

                            local scroll = (interface['scroll']['data'] or 0)

                            changeTrunkSlot( interface["selected"]["trunk"]["index"], (i + scroll))

                        elseif isCursorOnElement(slots['interaction']["main"][i][1], slots['interaction']["main"][i][2], slots['interaction']["main"][i][3], slots['interaction']["main"][i][4]) or isMouseInPosition(266, 876, 228, 64) then 

                            local ammount = (#getEditboxText("amount") ~= 0 and tonumber(getEditboxText("amount")) or 1)

                            if getKeyState('lshift') then

                                ammount = interface["selected"]['trunk']["item"]["itemAmount"]

                            end

                            triggerServerEvent("FS:takeItemFromTrunk", localPlayer, localPlayer, trunk['vehData'], interface["selected"]["trunk"]["item"], ammount)

                            break

                        end

                    end

                    interface["selected"]["trunk"] = {

                        ['index'] = 0,

                        ['item'] = false,

                    }

                else

                    interface["selected"]["trunk"]["index"] = nil

                end

            end

        end

    end

end)



--| Scroll


function scrollTrunk(button)
	if isEventHandlerAdded("onClientRender", getRootElement(), renderTrunk) then
        if isCursorOnElement(1020, 0, 900, 1080) then 
            if trunk and trunk["data"] then 
                local scroll = interface['scroll']['data'] or 0
                if (button == "mouse_wheel_up") and (scroll > 0) then
                    scroll = scroll - 5
                elseif (button == "mouse_wheel_down") and (scroll < 40) then 
                    scroll = scroll + 5
                end
                interface['scroll']['data'], interface['scroll']['old'], interface['scroll']['position'], interface['scroll']['tick'] = scroll, interface['scroll']['smooth'], (369/40*scroll), getTickCount()
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



--| Update trunk



addEvent("FS:updateClientTrunk", true)

addEventHandler("FS:updateClientTrunk", getRootElement(), function(infos)

    trunk = infos

end)