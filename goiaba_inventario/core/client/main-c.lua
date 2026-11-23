--| Var's

interface = {}
bag = {}

--| Slot's

slots = {

    ['main'] = {

        {605, 350, 87, 87},
        {707, 350, 87, 87},
        {809, 350, 87, 87},
        {911, 350, 87, 87},
        {1013, 350, 87, 87},

        {605, 450, 87, 87},
        {707, 450, 87, 87},
        {809, 450, 87, 87},
        {911, 450, 87, 87},
        {1013, 450, 87, 87},

        {605, 550, 87, 87},
        {707, 550, 87, 87},
        {809, 550, 87, 87},
        {911, 550, 87, 87},
        {1013, 550, 87, 87},

        {605, 650, 87, 87},
        {707, 650, 87, 87},
        {809, 650, 87, 87},
        {911, 650, 87, 87},
        {1013, 650, 87, 87},

        {605, 750, 87, 87},
        {707, 750, 87, 87},
        {809, 750, 87, 87},
        {911, 750, 87, 87},
        {1013, 750, 87, 87},

    },

    ['shortcut'] = {

        {1182, 350, 87, 87},
        {1182, 450, 87, 87},
        {1182, 550, 87, 87},
        {1182, 650, 87, 87},
        {1182, 750, 87, 87},

    },

}

--| Interface

createdFonts = {}
function getFont(font, size)

    if (createdFonts[font..':'..size]) then 

        return createdFonts[font..':'..size]

    else

        createdFonts[font..':'..size] = exports['goiaba_fonts']:useFont('sf:'..font, sy * (size / 1.4));
        return createdFonts[font..':'..size]
        
    end

end

local scrollOffset = 0
local maxVisibleRows = 5
local itemsPerRow = 5
local slotSize = 87
local slotSpacing = 15

function scrollInventory(key)
    local totalItems = #bag[localPlayer]["itemData"]
    local totalRows = math.ceil(totalItems / itemsPerRow)

    if key == "mouse_wheel_up" then
        if scrollOffset > 0 then
            scrollOffset = scrollOffset - 1
        end
    elseif key == "mouse_wheel_down" then
        if (scrollOffset + maxVisibleRows) < totalRows then
            scrollOffset = scrollOffset + 1
        end
    end
end

bindKey("mouse_wheel_up", "down", scrollInventory)
bindKey("mouse_wheel_down", "down", scrollInventory)



function renderBag()

    --| Cursor

    cursorUpdate ()
    
    --| Render animations
    if not interface["animations"]["base"]["tick_out"] then 

        interface["animations"]["base"]["alpha"] = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount() - interface["animations"]["base"]["tick"]) / 700, "OutQuad")
        
    else
        
        if not interface["animations"]["base"]["last_alpha"] then 
            interface["animations"]["base"]["last_alpha"] = interface["animations"]["base"]["alpha"]
        end

        if ((getTickCount() - interface["animations"]["base"]["tick_out"]) >= 400) then 
            closeBag()
        end
        
        interface["animations"]["base"]["alpha"] = interpolateBetween(interface["animations"]["base"]["last_alpha"], 0, 0, 0, 0, 0, (getTickCount() - interface["animations"]["base"]["tick_out"]) / 400, "OutQuad")
        
    end

    local alpha = interface["animations"]["base"]["alpha"]

    --| General background
    _dxDrawImage(0, 0, screenW, screenH, "core/assets/images/background2.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)
    _dxDrawImage(0, 0, screenW, screenH, "core/assets/images/bg.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)

    dxDrawText('INVENTÁRIO', 650, 300, 92, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 30), 'center')

    --| Slots
    dxDrawText('S    L    O    T    S            D  O            I    N    V    E    N    T    Á    R    I    O', 330, 590, 487, 26, tocolor(255, 255, 255, alpha * 0.15), 1, getFont('bold', 20), 'left', 'top', false, false, false, false, false, - 90)
    dxDrawImage(605, 350, 715, 487, "core/assets/images/slots.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)
    drawBorder(1, 1123, 537, 3, 113, tocolor(255, 255, 255, alpha * 0.02))
    drawBorder(1, 1346, 537, 3, 113, tocolor(255, 255, 255, alpha * 0.02))

    --| Bag 
    if bag[localPlayer] then    

        dxDrawText('PESO', 277-100, 200-60+30+30, 45, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 30), 'center')
        dxDrawText('Peso de sua\nmochila em total', 226-100, 240-60+30+30, 147, 42, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 20), 'center')
        dxDrawText(math.round(bag[localPlayer]["personData"]["weight"], 2).."/#214227"..(bag[localPlayer]["personData"]["maxWeight"] or 0)..' KG', 209-100, 300-60+30+30, 189, 50, tocolor(89, 178, 104, alpha), 1, getFont('bold', 42), 'center', 'center', false, false, false, true)

        -- dxDrawImage(264-100, 395-60+10, 70, 42, 'core/assets/images/user.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        -- dxDrawText(getPlayerName(localPlayer), 250-100, 446-60+10, 96, 26, tocolor(89, 178, 104, alpha), 1, getFont('bold', 25), 'center', 'center', false, false, false, true)

        dxDrawText('Carteira', 178+30+5-100, 516-60-120+30, 62, 21, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 18), 'center')
        dxDrawText('Ativo há', 357-30+5-100, 516-60-120+30, 63, 21, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 18), 'center')

        dxDrawText('Banco', 184+30+5-100, 589-60-120+30, 50, 21, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 18), 'center')
        dxDrawText('Identidade', 347-30+5-100, 589-60-120+30, 83, 21, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 18), 'center')

        dxDrawText('Porte', 188+30+5-100, 662-60-120+30, 42, 21, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 18), 'center')
        dxDrawText('CNH', 369-30+5-100, 662-60-120+30, 38, 21, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 18), 'center')

        dxDrawText('$'..formatNumber(getPlayerMoney(localPlayer), '.'), 178+30+5-100, 548-60-120+30, 62, 21, tocolor(255, 255, 255, alpha), 1, getFont('bold', 18), 'center')
        dxDrawText(minutes..' min', 357-30+5-100, 548-60-120+30, 63, 21, tocolor(255, 255, 255, alpha   ), 1, getFont('bold', 18), 'center')

        dxDrawText('$'..formatNumber((getElementData(localPlayer, 'moneybank') or 0), '.'), 184+30+5-100, 621-60-120+30, 50, 21, tocolor(255, 255, 255, alpha), 1, getFont('bold', 18), 'center')
        dxDrawText((getElementData(localPlayer, 'ID') or '???'), 347-30+5-100, 621-60-120+30, 83, 21, tocolor(255, 255, 255, alpha), 1, getFont('bold', 18), 'center')

        dxDrawText(getElementData(localPlayer, 'Porte:lowCaliber') and 'Sim' or 'Não', 188+30+5-100, 694-60-120+30, 42, 21, tocolor(255, 255, 255, alpha), 1, getFont('bold', 18), 'center') 

        local cnhText = ''
        if (getElementData(localPlayer, 'Category(A)')) then 

            cnhText = cnhText..'A'

        end

        if (getElementData(localPlayer, 'Category(B)')) then 

            cnhText = cnhText..'B'

        end

        if (cnhText == '') then 

            cnhText = 'Nenhuma' 

        end

        dxDrawText(cnhText, 369-30+5-100, 694-60-120+30, 38, 21, tocolor(255, 255, 255, alpha), 1, getFont('bold', 18), 'center')

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
                    
                        local posX = 605 + ((col - 1) * (slotSize + slotSpacing))
                        local posY = 350 + ((row - 1) * (slotSize + 13))

                        if interface["selected"]["index"] and interface["selected"]["item"] and (interface["selected"]["index"] == index) and (getTickCount() - interface["selected"]["tick"] >= 100) then 
                            local mx, my = getCursorPosition()
                            mousex, mousey = (mx * 1920), (my * 1080)
                            dxDrawImage(mousex - (slotSize / 2), mousey - (slotSize / 2), slotSize, slotSize, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha / 2))
                            dxDrawImage(mousex - (config["default"]["itemSize"] / 2), mousey - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                        else
                            dxDrawImage(posX, posY, slotSize, slotSize, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.2), false)

                            if image and image["image"] then
                                dxDrawImage(posX + (slotSize / 2) - (config["default"]["itemSize"] / 2), posY + (slotSize / 2) - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                            end
        
                            dxDrawText(formatNumberEffect(amount), posX + 5, posY + 5, 5, 5, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15))
                            dxDrawText(name, posX, posY + 70, slotSize, 5, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11), "center", "center")
        
                            -- if isMouseInPosition(posX, posY, slotSize, slotSize) then 
                            --     local mx, my = getCursorPosition()
                            --     mousex, mousey = (mx * screenW), (my * screenH)
        
                            --     if id == 110 then
                            --         dxDrawText('Dinheiro', mousex - 50, mousey, 115, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15), "center", "center")
                            --         dxDrawText(formatNumberC(amount), mousex - 50, mousey + 20, 115, 24, tocolor(89, 178, 104, alpha), 1, getFont('bold', 15), "center", "center")
                            --     else
                            --         if id == 123 or id == 120 then
                            --             local itemData = fromJSON(item["itemInfos"])
                            --             if itemData[1] then
                            --                 dxDrawText(itemData[1], mousex - 50, mousey, 115, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15), "center", "center")
                            --             end
                            --         else
                            --             dxDrawText(name, mousex - 50, mousey, 115, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15), "center", "center")
                            --         end
                            --         dxDrawText(amount..'x', mousex - 50, mousey + 20, 115, 24, tocolor(89, 178, 104, alpha), 1, getFont('bold', 15), "center", "center")
                            --     end
                            -- end
                        end
                    
                        local action = item["itemAction"]
                        if action and (action > 0) and (action <= 5) then     
                            dxDrawImage((slots["shortcut"][action][1] + slots["shortcut"][action][3]) - (slots["shortcut"][action][3] / 2) - (config["default"]["itemSize"] / 2), (slots["shortcut"][action][2] + slots["shortcut"][action][4]) - (slots["shortcut"][action][4] / 2) - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)           
                        end
                    end
                end
            end
            local totalItems = #bag[localPlayer]["itemData"]
            local totalRows = math.ceil(totalItems / itemsPerRow)

            if totalRows > maxVisibleRows then
                local scrollbarHeight = (maxVisibleRows / totalRows) * 200
                local scrollbarY = 350 + ((scrollOffset / (totalRows - maxVisibleRows)) * (487 - scrollbarHeight))
            
                drawBorder(4, 1110, 350, 3, 490, tocolor(255, 255, 255, alpha * 0.05))
                drawBorder(4, 1110, scrollbarY, 3, scrollbarHeight, tocolor(89, 178, 104, alpha))
            end

        end


        dxDrawImage(1551, 119, 32, 32, 'core/assets/images/polygon.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('CUSTOMIZAÇÃO', 1501, 185, 131, 24, tocolor(255, 255, 255, alpha), 1, getFont('bold', 25), 'center')
        dxDrawText('Clique na peça para remover!\nArraste um item para equipar! ', 1501, 225, 131, 24, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('medium', 18), 'center')

        dxDrawImage(1286, 313, 593, 593, 'core/assets/images/skeleton.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

    end
    
    --| Options 
    dxDrawImage(1001, 864, 248, 64, 'core/assets/images/amountStroke2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    if isBoxActive("amount") then 
        dxDrawText(getEditboxText("amount"), 1088, 884, 107, 24, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('bold', 20))
    else
        dxDrawText(#getEditboxText("amount") ~= 0 and getEditboxText("amount") or "Quantidade", 1088, 884, 107, 24, tocolor(255, 255, 255, alpha * 0.25), 1, getFont('bold', 20))
    end

    --| Amount input
    dxDrawEditbox(1001, 864, 248, 64, 9, "amount", true)

    drawBorder(32, 821, 864, 161, 64, (isMouseInPosition(821, 864, 161, 64) and tocolor(89, 178, 104, alpha) or tocolor(255, 255, 255, alpha * 0.02)))
    dxDrawText('Enviar item', 821, 864, 161, 64, isMouseInPosition(821, 864, 161, 64) and tocolor(255, 255, 255, alpha) or tocolor(89, 178, 104, alpha), 1, getFont('bold', 20), 'center', 'center')

    drawBorder(32, 574, 864, 228, 64, (isMouseInPosition(574, 864, 228, 64) and tocolor(89, 178, 104, alpha) or tocolor(255, 255, 255, alpha * 0.02)))
    dxDrawText('Usar item', 574, 864, 228, 64, isMouseInPosition(574, 864, 228, 64) and tocolor(255, 255, 255, alpha) or tocolor(89, 178, 104, alpha), 1, getFont('bold', 20), 'center', 'center')
end

local iconsvg = svgCreate(26, 26, [[<svg width="8" height="9" viewBox="0 0 8 9" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M1 6.23205C-0.333333 5.46225 -0.333334 3.53775 0.999999 2.76795L4.75 0.602885C6.08333 -0.166915 7.75 0.795334 7.75 2.33494L7.75 6.66506C7.75 8.20466 6.08333 9.16691 4.75 8.39711L1 6.23205Z" fill="#29CC44"/> </svg>]])
local fontAction = exports['goiaba_fonts']:useFont("rc:medium", 18 / 1.25)
local fontAction2 = exports['goiaba_fonts']:useFont("rc:medium", 13 / 1.25)

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        fontAction = exports['goiaba_fonts']:useFont("rc:medium", 18 / 1.25)
        fontAction2 = exports['goiaba_fonts']:useFont("rc:medium", 13 / 1.25)
    end
end)
local posx, posy = screenW/2-270/2, screenH-24-47

--| Render

local function removeFonts ()
    if fontsInventory then
        for i, v in ipairs(fontsInventory) do
            if isElement(v) then
                destroyElement(v)
            end
        end
    end
end

setElementData(localPlayer, 'painelAberto', false)
function openBag()

    if isEventHandlerAdded('onClientRender', root, renderStore) then 
        return 
    end

    if isEventHandlerAdded('onClientRender', root, renderChest) then 
        return 
    end

    if isEventHandlerAdded('onClientRender', root, renderTrunk) then 
        return 
    end

    if isEventHandlerAdded('onClientRender', root, renderInspect) then
        return
    end

    if getElementData(localPlayer, "inspected") then
        return
    end

    if getElementData(localPlayer, "enviandoItem") then
        return
    end

    if not isEventHandlerAdded('onClientRender', root, renderBag) then

        --removeFonts()

        fontsInventory = {
        }

        addEventHandler("onClientResourceStart", root, function(res)
            if getResourceName(res) == "goiaba_fonts" then
                fontsInventory = {
                }
            end
        end)

        interface = {
            
            ['animations'] = {

                ['base'] = {
                    ['alpha'] = 0,
                    ['tick'] = getTickCount(),
                },

                ['nav'] = {
                    ['last'] = 1081,
                    ['x'] = 1081,
                    ['tick'] = getTickCount(),
                },

            },

            ['selected'] = {
                ['index'] = 0,
                ['item'] = false,
            },
            ['category'] = 'foods',

        }

        setElementData(localPlayer, 'bloqInterface', true)
        setElementData(localPlayer, 'painelAberto', true)
        addEventHandler('onClientRender', root, renderBag, false, "low-10")
        showCursor(true)
        showChat(false)

        setSVGOffset('weight', 0.01, 360 - 0.2)
        setSVGOffset('weight_bg', 0.01, 360 - 0.2)
        triggerServerEvent('onPlayerUpdateItemInfo', resourceRoot, localPlayer)

    end
end
addEvent("FS:openBag", true)
addEventHandler("FS:openBag", root, openBag)

function closeBag()
    if isEventHandlerAdded('onClientRender', root, renderBag) then 

        if not interface['animations']['base']['tick_out'] then 
            interface['animations']['base']['tick_out'] = getTickCount()
            return 
        end

        setElementData(localPlayer, 'bloqInterface', false)
        setElementData(localPlayer, 'painelAberto', false)
        removeEventHandler('onClientRender', root, renderBag)
        showCursor(false)
        showChat(true)
        destroyBox()
        --removeFonts()

    end
end
addEvent("FS:closeBag", true)
addEventHandler("FS:closeBag", root, closeBag)

addEventHandler('onClientKey', root, function (key, press)
    if isEventHandlerAdded('onClientRender', root, renderBag) and press then 
        if key == 'escape' then
            closeBag()
            cancelEvent()
        elseif key == 'backspace' then
            closeBag()
        end
    end
end)

function toggleBag()
    if not isEventHandlerAdded('onClientRender', root, renderBag) then 
        openBag()
    else
        closeBag()
    end
end
bindKey(config["binds"]["toggle"], "down", toggleBag)

--| Click function's

addEventHandler("onClientClick", root, function(button, state)
    if isEventHandlerAdded('onClientRender', root, renderBag) then 

        if (button == "left") and (state == "down") then
            if isCursorOnElement(1048, 64, 79, 23) then 
                interface['category'], interface['animations']['nav']['last'], interface['animations']['nav']['x'], interface['animations']['nav']['tick'] = "foods", interface['animations']['nav']['smooth'], 1081, getTickCount() 
            elseif isCursorOnElement(1155, 64, 51, 23) then 
                interface['category'], interface['animations']['nav']['last'], interface['animations']['nav']['x'], interface['animations']['nav']['tick'] = "weapons", interface['animations']['nav']['smooth'], 1174, getTickCount() 
            elseif isCursorOnElement(1234, 64, 52, 23) then 
                interface['category'], interface['animations']['nav']['last'], interface['animations']['nav']['x'], interface['animations']['nav']['tick'] = "others", interface['animations']['nav']['smooth'], 1253, getTickCount() 
                return
            end
        end

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
                    
                        local posX = 605 + ((col - 1) * (slotSize + slotSpacing))
                        local posY = 350 + ((row - 1) * (slotSize + 13))

                        if isMouseInPosition(posX, posY, slotSize, slotSize) then
                            interface["selected"] = {
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

        --| Item click's
        if bag[localPlayer] then
            local playerItens = bag[localPlayer]["itemData"]
            if playerItens and (#playerItens ~= 0) then 
                
                if (button == "left") and (state == "down") then

                    -- for i, item in ipairs(playerItens) do
    
                    --     local slot = item["itemSlot"]
                    --     if (slot > 0) and (slot <= 25) then

                    --         if isCursorOnElement(slots["main"][slot][1], slots["main"][slot][2], slots["main"][slot][3], slots["main"][slot][4]) then
                    --             interface["selected"] = {
                    --                 ['item'] = item,
                    --                 ['index'] = i,
                    --                 ['tick'] = getTickCount(),
                    --             }
                    --             break
                    --         end

                    --     end

                    -- end

                    for i = 1, 5 do 
                        if isCursorOnElement(slots["shortcut"][i][1], slots["shortcut"][i][2], slots["shortcut"][i][3], slots["shortcut"][i][4]) then
                            triggerServerEvent("FS:actionFunctions", localPlayer, i, "delete")
                            break
                        end
                    end

                elseif (button == "left") and (state == "up") then

                    if (interface["selected"] and interface["selected"]["item"]) then
     
                        if isCursorOnElement(574, 864, 228, 64) then 
                            local ammount = (#getEditboxText("amount") ~= 0 and tonumber(getEditboxText("amount")) or 1)
                            if getKeyState('lshift') then
                                ammount = interface["selected"]["item"]["itemAmount"]
                            end
                            triggerServerEvent("FS:useItem", localPlayer, ammount, interface["selected"]["item"])
                            interface["selected"] = {
                                ['index'] = 0,
                                ['item'] = false,
                            }
                        elseif (isMouseInPosition(1458, 313, 254, 593)) then 

                            -- // USAR ROUPA 

                            -- ~ Colocar verificações necessárias aqui

                            triggerServerEvent("FS:useItem", localPlayer, 1, interface["selected"]["item"])
                            interface["selected"] = {
                                ['index'] = 0,
                                ['item'] = false,
                            }

                        elseif isCursorOnElement(821, 864, 161, 64) then 
                            local ammount = (#getEditboxText("amount") ~= 0 and tonumber(getEditboxText("amount")) or 1)
                            if getKeyState('lshift') then
                                ammount = interface["selected"]["item"]["itemAmount"]
                            end
                            triggerServerEvent("FS:sendItem", localPlayer, ammount, interface["selected"]["item"]["itemID"], interface["selected"]["item"])
                            interface["selected"] = {
                                ['index'] = 0,
                                ['item'] = false,
                            }
                        end

                        if interface["selected"] and interface["selected"]["tick"] and (getTickCount() - interface["selected"]["tick"] >= 100) then 

                            for i = 1, 25 do
                                if isCursorOnElement(slots["main"][i][1], slots["main"][i][2], slots["main"][i][3], slots["main"][i][4]) then
                                    changeSlot( interface["selected"]["index"], i)
                                    break
                                end

                                if (i <= 5) then 
                                    if isCursorOnElement(slots["shortcut"][i][1], slots["shortcut"][i][2], slots["shortcut"][i][3], slots["shortcut"][i][4]) then
                                        changeAction( interface["selected"]["index"], i )
                                        break
                                    end
                                end

                            end

                            interface["selected"] = {
                                ['index'] = 0,
                                ['item'] = false,
                            }

                        else
                            interface["selected"]["index"] = nil
                        end

                    end

                end
                
            end
        end

    end
end)

--| Update inventory

addEvent("FS:updateInventory", true)
addEventHandler("FS:updateInventory", getRootElement(), function(infos)
    bag[source] = infos
end)

function getClientData(player)
    return bag[player] or {}
end

function drawProposal()

    cursorUpdate ()

    local alpha = interpolateBetween(interpolate[1], 0, 0, interpolate[2], 0, 0, ((getTickCount() - proposalTick) / 300), 'Linear')

    if not (isElement(receiver)) then 

        removeProposal()

    return end 

    _dxDrawImage(0, 0, screenW, screenH, "core/assets/images/background2.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)


    dxDrawText('Você recebeu uma solicitação de item de\n'..getPlayerName(receiver)..' ('..(getElementData(receiver, 'ID') or '???')..'), escolha a opção.', 557, 226, 246, 30, tocolor(255, 255, 255, alpha * 0.4), 1, fontsProposal2[3], 'center', 'center', false, false, false, true)

    local itemData = config.itens[item]

    dxDrawImage(640, 271, 80, 80, itemData.image, 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText(itemData.name, 654, 355, 53, 17, tocolor(89, 178, 104, alpha), 1, fontsProposal2[2], 'center')
    dxDrawText(amount..'x', 635, 373, 90, 15, tocolor(255, 255, 255, alpha * 0.4), 1, fontsProposal2[3], 'center')

    dxDrawText('Peso:', 593, 407, 29, 13, tocolor(255, 255, 255, alpha * 0.4), 1, fontsProposal2[3])
    dxDrawText('Categoria:', 709, 407, 29, 13, tocolor(255, 255, 255, alpha * 0.4), 1, fontsProposal2[3])

    dxDrawText(itemData.weight..'kg', 593, 423, 29, 13, tocolor(89, 178, 104, alpha), 1, fontsProposal2[2])
    dxDrawText('Geral', 709, 423, 29, 13, tocolor(89, 178, 104, alpha), 1, fontsProposal2[2])

    drawBorder(8, 570, 451, 220, 40, tocolor(255, 255, 255, alpha * 0.04))
    dxDrawText('Aceitar item', 570, 451, 220, 40, tocolor(89, 178, 104, alpha * 0.7), 1, fontsProposal2[4], 'center', 'center')
    dxDrawImage(761, 463, 14, 16, 'core/assets/images/use2.png', 0, 0, 0, tocolor(89, 178, 104, alpha * 0.7))

    if (isMouseInPosition(570, 451, 220, 40)) then 

        if not (sendTick) then sendTick = getTickCount() end 
        local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - sendTick) / 500), 'Linear')

        drawBorder(8, 570, 451, 220, 40, tocolor(89, 178, 104, animation))
        dxDrawText('Aceitar item', 570, 451, 220, 40, tocolor(31, 31, 31, animation), 1, fontsProposal2[4], 'center', 'center')
        dxDrawImage(761, 463, 14, 16, 'core/assets/images/use2.png', 0, 0, 0, tocolor(31, 31, 31, animation))

    else

        sendTick = nil 

    end
    
    drawBorder(20, 660, 503, 40, 40, tocolor(255, 255, 255, alpha * 0.04))
    dxDrawImage(671, 514, 18, 18, 'core/assets/images/exit.png', 0, 0, 0, tocolor(89, 178, 104, alpha * 0.7))

    if (isMouseInPosition(660, 503, 40, 40)) then 

        if not (cancelTick) then cancelTick = getTickCount() end 
        local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - cancelTick) / 500), 'Linear')
        drawBorder(20, 660, 503, 40, 40, tocolor(89, 178, 104, animation))
        dxDrawImage(671, 514, 18, 18, 'core/assets/images/exit.png', 0, 0, 0, tocolor(31, 31, 31, animation))

    else

        cancelTick = nil 

    end

end

addEventHandler('onClientClick', root, 

    function(b, s)

        if (b == 'left' and s == 'down') then 

            if (isEventHandlerAdded('onClientRender', root, drawProposal)) then 

                if (isMouseInPosition(570, 451, 220, 40)) then 

                    triggerServerEvent('onPlayerAceptItemProposal', resourceRoot, localPlayer)
                    removeProposal()
                    
                elseif (isMouseInPosition(660, 503, 40, 40)) then 

                    triggerServerEvent('recuseProposal', localPlayer, localPlayer)
                    removeProposal()

                end

            end

        end

    end

)

local function removeFonts2 ()
    if fontsProposal2 then
        for i, v in ipairs(fontsProposal2) do
            if isElement(v) then
                destroyElement(v)
            end
        end
    end
end

addEvent('onClientDrawItemProposal', true)
addEventHandler('onClientDrawItemProposal', root, 

    function(receiver_, item_, amount_)

        if not (isEventHandlerAdded('onClientRender', root, drawProposal)) then 

            --removeFonts2()

            fontsProposal2 = {
                exports['goiaba_fonts']:useFont('int:medium', sy * (12 / 1.25));
                exports['goiaba_fonts']:useFont('int:bold', sy * (13 / 1.25));
                exports['goiaba_fonts']:useFont('int:regular', sy * (12 / 1.25));
                exports['goiaba_fonts']:useFont('int:semibold', sy * (12 / 1.25));
            }

            addEventHandler("onClientResourceStart", root, function(res)
                if getResourceName(res) == "goiaba_fonts" then
                    fontsProposal2 = {
                        exports['goiaba_fonts']:useFont('int:medium', sy * (12 / 1.25));
                        exports['goiaba_fonts']:useFont('int:bold', sy * (13 / 1.25));
                        exports['goiaba_fonts']:useFont('int:regular', sy * (12 / 1.25));
                        exports['goiaba_fonts']:useFont('int:semibold', sy * (12 / 1.25));
                    }
                end
            end)

            proposalTick, interpolate, receiver, item, amount = getTickCount(), {0, 255}, receiver_, item_, amount_
            addEventHandler('onClientRender', root, drawProposal)
            showCursor(true)

        end 

    end

)

function removeProposal()

    if (isEventHandlerAdded('onClientRender', root, drawProposal)) then
        
        if (interpolate[1] == 0) then 

            tick, interpolate = getTickCount(), {255, 0}
            showCursor(false)

            setTimer(function()
            
                removeEventHandler('onClientRender', root, drawProposal)
                --removeFonts2()

            end, 300, 1)

        end 

    end

end
addEvent('removeProposal', true)
addEventHandler('removeProposal', root, removeProposal)

function getItemName(item)
    local itemName
    if config["itens"][item] then 
        itemName = config["itens"][item]["name"]
    end
    return itemName
end

addEventHandler('onClientRender', root, 
    function()
    
        if (getElementData(localPlayer, 'amarrado/algemado') or false) ~= false then 
            toggleControl('fire', false)
        end
    
        if (getElementData(localPlayer, 'capuz') or false) ~= false then
            toggleControl('fire', false)
            _dxDrawImage(0, 0, screenW, screenH, "core/assets/images/capuz.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
            _dxDrawText('Você está vendado!', 0+1, screenH/2, screenW+1, 0, tocolor(22, 22, 22, 255), 3, 'arial', 'center', 'top', false, false, true)
            _dxDrawText('Você está vendado!', 0, screenH/2, screenW, 0, tocolor(255, 255, 255, 255), 3, 'arial', 'center', 'top', false, false, true)
        end

    end
)

addEventHandler('onClientKey', root, 
    function(button, press)
        if button ~= 'z' and button ~= 't' and button ~= 'w' and button ~= 's' and button ~= 'd' and button ~= 'a' then
            if (getElementData(localPlayer, 'amarrado/algemado') or false) ~= false or (getElementData(localPlayer, 'capuz') or false) ~= false then 
                cancelEvent()
            end
        end
    end
)

addEvent('alterSpeed', true)
addEventHandler('alterSpeed', root, function (type, aumentar)
    if type == 'add' then
        if aumentar then
            gamespeed = 1.3 + (1.3 / 100 * aumentar)
        else
            gamespeed = 1.3
        end
    else
        gamespeed = 1
    end
    setGameSpeed(gamespeed)
end)

addEvent('alterSpeedCoca', true)
addEventHandler('alterSpeedCoca', root, function (type, aumentar)
    if type == 'add' then
        -- if aumentar then
        --     gamespeed = 1.3 + (1.3 / 100 * aumentar)
        -- else
        --     gamespeed = 1.3
        -- end
        setCameraGoggleEffect('thermalvision')
    else
        -- gamespeed = 1
        setCameraGoggleEffect('normal')
    end
    --setGameSpeed(gamespeed)
end)


local txd = engineLoadTXD("core/assets/models/algema.txd")
engineImportTXD(txd, 1918)

local dff = engineLoadDFF("core/assets/models/algema.dff")
engineReplaceModel(dff, 1918)

for i, v in pairs(config.positionMask) do
    engineImportTXD(engineLoadTXD("core/assets/models/"..v[1]..".txd"), v[1])
    engineReplaceModel(engineLoadDFF("core/assets/models/"..v[1]..".dff"), v[1])
end


addEventHandler ("onClientResourceStart", resourceRoot,
function()
    setTimer(function()
        local task = getPedSimplestTask(localPlayer)
        if task == "TASK_SIMPLE_SWIM" then
			triggerServerEvent("FS:UpdateWater", localPlayer, localPlayer)
        end
    end,10000, 0 )
end)

minutes = 0 
setTimer(function()

    minutes = minutes + 1
    
end, 60000, 0)

function formatNumberEffect(value)
    if value >= 1e9 then
        return string.format(value % 1e9 == 0 and "%dB" or "%.1fB", value / 1e9) -- Bilhão
    elseif value >= 1e6 then
        return string.format(value % 1e6 == 0 and "%dM" or "%.1fM", value / 1e6) -- Milhão
    elseif value >= 1e3 then
        return string.format(value % 1e3 == 0 and "%dK" or "%.1fK", value / 1e3) -- Milhar
    else
        return tostring(value) -- Número normal se for menor que 1000
    end
end
