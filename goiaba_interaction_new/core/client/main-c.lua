--| Screen

local x, y = (screen.x / 2) + respc(120), (screen.y / 2) - respc(120)
local sub_x = x + respc(35) + respc(250) + respc(14) + respc(4)

--| Var's 

local interface = {}
local data

--| Design

local gap = respc(7)
local totalScrollSize = (respc(45) * config['interface']['maxActions']) + (gap * (config['interface']['maxActions'] - 1))

bgColor = config['interface']['design'].bgColor
themeColor = config['interface']['design'].themeColor
textColor = config['interface']['design'].textColor

--| Interface 
function renderInteraction() 
    CreateThread(function()
        while (interface['state']) do 
            local alpha = getAnimation('alpha')
            if (not data) then 
                local targetElement = getElementAtScreenPosition(x, y)
                if targetElement then  
                    dxDrawImage(x - (respc(15) / 2), y - (respc(15) / 2), respc(40), respc(40), 'core/assets/images/target.png', 0, 0, 0, tocolor(themeColor[1], themeColor[2], themeColor[3], alpha), false)
                else
                    dxDrawImage(x - (respc(15) / 2), y - (respc(15) / 2), respc(40), respc(40), 'core/assets/images/target.png', 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                end
            else
                if (getDistanceBetweenPoints3D(Vector3({getElementPosition(localPlayer)}), Vector3({getElementPosition(data['element'])})) > config['general']['distance']) or not isElement(data['element']) then
                    closeInteraction()
                end
                --| Round spin
                -- dxDrawImage(x - (respc(15) / 2), y - (respc(15) / 2), respc(15), respc(15), 'core/assets/images/ellipse.png', 0, 0, 0, tocolor(themeColor[1], themeColor[2], themeColor[3], (alpha/100)*90), false)
                -- dxDrawImage(x - (respc(25) / 2), y - (respc(25) / 2), respc(25), respc(25), "core/assets/images/round_spin.png", generateRotation('spin'), 0, 0, tocolor(themeColor[1], themeColor[2], themeColor[3], (alpha/100)*90), false)
                dxDrawImage(x - (respc(15) / 2), y - (respc(15) / 2), respc(40), respc(40), 'core/assets/images/target.png', 0, 0, 0, tocolor(themeColor[1], themeColor[2], themeColor[3], alpha), false)
                --| Alpha interaction
                local in_alpha = getAnimation('in_alpha')
                cursorUpdate()
                --| Element indicative
                local elementType = getElementType(data['element'])
                --| Gridlist
                local scroll = interface['scroll']['data'] or 0
                local grid_y = y + respc(35)
                if data['functions'] and (#data['functions'] ~= 0) then
                    for i = 1, config['interface']['maxActions'] do 
                        local functionData = data['functions'][i + scroll]
                        if functionData then 
                            local anim_x, anim_alpha, anim_text = fadeButton('smoothCursor - '..(i + scroll), x + respc(35), grid_y, respc(250), respc(45), {0, 0, 20}, {9, 100, 90}, 600, 'OutQuad')
                            if (not anim_x) or (not anim_alpha) or (not anim_text) then 
                                anim_x, anim_alpha, anim_text = 0, 0, 0
                            end
                            dxDrawRoundedRectangle('grid square', x + respc(35) + respc(anim_x), grid_y, respc(45+195+10), respc(45), tocolor(bgColor[1], bgColor[2], bgColor[3], (in_alpha/100)*70), respc(7), false)
                            if (type(functionData['name']) == 'table') then 
                                local funcName = getElementData(data['element'], 'FS:actionState > '..functionData['func']) and functionData['name'][2] or functionData['name'][1]
                                dxDrawText(funcName, x + respc(87) + respc(anim_x), grid_y + respc(13), respc(165), respc(19), tocolor(textColor[1], textColor[2], textColor[3], (in_alpha/100)*anim_text), 1, exports['goiaba_fonts']:useFont('sf:regular', 11), "left", "top", false, false, false, false, false)
                            elseif functionData['func'] == 'startJob:caminhoneiro' then
                                local text = getElementData(localPlayer, 'player.trailer') and 'Entregar carga' or 'Escolher carga'
                                dxDrawText(text, x + respc(87) + respc(anim_x), grid_y + respc(13), respc(165), respc(19), tocolor(textColor[1], textColor[2], textColor[3], (in_alpha/100)*anim_text), 1, exports['goiaba_fonts']:useFont('sf:regular', 11), "left", "top", false, false, false, false, false)
                            else
                                dxDrawText(functionData['name'], x + respc(87) + respc(anim_x), grid_y + respc(13), respc(165), respc(19), tocolor(textColor[1], textColor[2], textColor[3], (in_alpha/100)*anim_text), 1, exports['goiaba_fonts']:useFont('sf:regular', 11), "left", "top", false, false, false, false, false)
                            end
                            dxDrawImage(x + respc(35) + respc(anim_x), grid_y, respc(45), respc(45), 'core/assets/icons/'..functionData['image'], 0, 0, 0, tocolor(255, 255, 255, (in_alpha/100)*anim_text), false)
                            if (anim_alpha > 0) then 
                                dxDrawImage(x + respc(35) + respc(anim_x) - (respc(27)/2), grid_y + respc(9), respc(27), respc(27), 'core/assets/images/round_detail.png', 0, 0, 0, tocolor(themeColor[1], themeColor[2], themeColor[3], (in_alpha/100)*anim_alpha), false)
                            end
                            grid_y = grid_y + respc(45) + gap
                        end
                    end
                end
                --| Scroll
                if (#data['functions'] > config['interface']['maxActions']) then
                    interface['scroll']['smooth'] = interpolateBetween(interface['scroll']['old'], 0, 0, interface['scroll']['pos'], 0, 0, (getTickCount() - interface['scroll']['tick']) / 250, 'OutQuad')
                    dxDrawRoundedRectangle('scroll bg', x + respc(35) + respc(250) + respc(14), y + respc(35), respc(4), totalScrollSize, tocolor(bgColor[1], bgColor[2], bgColor[3], (in_alpha/100)*40), respc(2), false)
                    dxDrawRoundedRectangle('scroll main', x + respc(35) + respc(250) + respc(14), y + respc(35) + (interface['scroll']['smooth'] or 0), respc(4), respc(70), tocolor(217, 217, 217, in_alpha), respc(2), false)
                end
            end
            coroutine.yield()
        end
    end)
end

--| Scroll with cursor
addEventHandler("onClientCursorMove", root, function(_, _, cx, cy)
    if (not interface['state']) then return end
    if (not data) then return end
    if (isCursorOnElement(x + respc(35 + 250 + 14) - respc(3), y + respc(35) - respc(3), respc(4) + respc(6), totalScrollSize + respc(6))) and getKeyState('mouse1') then 
        local scroll = interface['scroll']['data'] or 0
        local scrollLimit = (totalScrollSize - respc(70))
        local scrollPos = (cy - (y + respc(35))) - respc(35)
        local scrollData = math.min(math.max(0, math.floor(scrollPos/(scrollLimit/(#data['functions'] - config['interface']['maxActions'])))), (#data['functions'] - config['interface']['maxActions']))
        interface['scroll']['data'], interface['scroll']['old'], interface['scroll']['pos'], interface['scroll']['tick'] = scrollData, interface['scroll']['smooth'], (scrollLimit/(#data['functions'] - config['interface']['maxActions'])*scrollData), getTickCount() 
    end

end)

--| Render function's
function openInteraction(infos)
    if (not interface['state']) then return end
    createAnimation('in_alpha', 0, 255, 400, 'OutQuad')
    createAnimation('sub_page: position', 0, 12, 450, 'OutQuad')
    createAnimation('sub_page: alpha', 0, 255, 450, 'OutQuad')
    data = infos
    interface['secondary'] = false
    interface['scroll'] = {
        data = 0,
        old = 0,
        pos = 0,
        tick = getTickCount()
    }
    if not isEventHandlerAdded('onClientClick', root, interactionClick) then
        addEventHandler("onClientClick", root, interactionClick)
    end
    showCursor(true)
    execAnimation('in_alpha', 0, 255, 400, 'OutQuad')
end
addEvent("FS:openInteraction", true)
addEventHandler("FS:openInteraction", root, openInteraction)

function closeInteraction()
    if interface['state'] then 
        execAnimation('alpha', 255, 0, 400, 'OutQuad')
        execAnimation('in_alpha', 255, 0, 400, 'OutQuad')
        if interface['secondary'] then 
            execAnimation('sub_page: alpha', 255, 0, 150, 'OutQuad')
        end
        setTimer(function()
            interface = {}
            data = nil
            clearButtons()
            destroyAnimation('alpha')
            destroyAnimation('in_alpha')
            if interface['secondary'] then 
                destroyAnimation('sub_page: position')
                destroyAnimation('sub_page: alpha')
            end
            if isEventHandlerAdded('onClientClick', root, interactionClick) then
                removeEventHandler("onClientClick", root, interactionClick)
            end
            if isEventHandlerAdded('onClientKey', root, interactionRequestData) then
                removeEventHandler("onClientKey", root, interactionRequestData)
            end
            showCursor(false)
        end, 400, 1)
    end
end
addEvent("FS:closeInteraction", true)
addEventHandler("FS:closeInteraction", root, closeInteraction)
bindKey("backspace", "down", closeInteraction)

function enableInteraction(button, state)
    if (state == "down") then 
        if interface['state'] then return end
        if data then return end
        if getAnimation('alpha') then return end
        if isPedInVehicle(localPlayer) then return end
        interface = {}
        createAnimation('alpha', 0, 255, 250, 'OutQuad')
        execAnimation('alpha', 0, 255, 250, 'OutQuad')
        if not isEventHandlerAdded('onClientKey', root, interactionRequestData) then
            addEventHandler("onClientKey", root, interactionRequestData)
        end
        interface['state'] = true
        renderInteraction()
    elseif (state == "up") then 
        if (not interface['state']) then return end
        if data then return end
        execAnimation('alpha', 255, 0, 400, 'OutQuad')
        if isEventHandlerAdded('onClientKey', root, interactionRequestData) then
            removeEventHandler("onClientKey", root, interactionRequestData)
        end
        setTimer(function()
            clearButtons()
            destroyAnimation('alpha')
            destroyAnimation('in_alpha')
            if interface['secondary'] then 
                destroyAnimation('sub_page: position')
                destroyAnimation('sub_page: alpha')
            end
            if isEventHandlerAdded('onClientClick', root, interactionClick) then
                removeEventHandler("onClientClick", root, interactionClick)
            end
            if isEventHandlerAdded('onClientKey', root, interactionRequestData) then
                removeEventHandler("onClientKey", root, interactionRequestData)
            end
            if isCursorShowing() then 
                showCursor(false)
            end
            interface = {}
            data = nil
        end, 400, 1)
    end
end
bindKey(config['binds']['toggle'], "both", enableInteraction)

function interactionRequestData(button, press)
    if (not interface['state']) then return end
    if data then return end
    if (button == 'mouse1') and (press) then 
        local targetElement = getElementAtScreenPosition(x, y)
        if targetElement then 
            triggerServerEvent("FS:getInteractionData", resourceRoot, localPlayer, targetElement)
        end
        cancelEvent()
    end
end

--| Interaction click's

function interactionClick(button, state)
    if (not interface['state']) then return end
    if (button == 'left') and (state == 'down') then 
        local scroll = interface['scroll']['data'] or 0
        local grid_y = y + respc(35)
        if data['functions'] and (#data['functions'] ~= 0) then
            for i = 1, config['interface']['maxActions'] do 
                local functionData = data['functions'][i + scroll]
                if functionData then 
                    local anim_x, anim_alpha, anim_text = fadeButton('smoothCursor - '..(i + scroll), x + respc(35), grid_y, respc(250), respc(45), {0, 0, 20}, {9, 100, 90}, 600, 'OutQuad')
                    if (not anim_x) or (not anim_alpha) or (not anim_text) then 
                        anim_x, anim_alpha, anim_text = 0, 0, 0
                    end
                    if (isCursorOnElement(x + respc(35) + respc(anim_x), grid_y, respc(250), respc(45))) then 
                        triggerServerEvent("FS:executeInteraction", resourceRoot, localPlayer, data['element'], functionData['func'])
                        closeInteraction()
                        break
                    end
                    grid_y = grid_y + respc(45) + respc(7)
                end
            end
        end
    end
end

--| Scroll 

function scrollInteraction(button)
    if (not interface['state']) then return end
    if (not data) then return end
    local scroll = interface['scroll']['data'] or 0
    if (button == 'mouse_wheel_up') and (scroll > 0) then 
        scroll = (scroll - 1)
    elseif (button == 'mouse_wheel_down') and (scroll < (#data['functions'] - config['interface']['maxActions'])) then 
        scroll = (scroll + 1)
    end
    local scrollLimit = (totalScrollSize - respc(70))
    interface['scroll']['data'], interface['scroll']['old'], interface['scroll']['pos'], interface['scroll']['tick'] = scroll, interface['scroll']['smooth'], (scrollLimit/(#data['functions'] - config['interface']['maxActions'])*scroll), getTickCount() 
end
bindKey("mouse_wheel_up", "down", scrollInteraction)
bindKey("mouse_wheel_down", "down", scrollInteraction)

--| Resource util's
function getElementAtScreenPosition(screenX, screenyY)
    local camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ = getCameraMatrix()
    local screenWorldX, screenWorldY, screenWorldZ = getWorldFromScreenPosition(screenX, screenyY, 50)
    local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(camPosX, camPosY, camPosZ, screenWorldX, screenWorldY, screenWorldZ)
    if hit and hitElement and isElement(hitElement) then
        if (getDistanceBetweenPoints3D(camPosX, camPosY, camPosZ, hitX, hitY, hitZ) > config['general']['distance']) or hitElement == localPlayer then
            return false
        end
        if getElementType(hitElement) == 'ped' or getElementType(hitElement) == 'player' or getElementType(hitElement) == 'vehicle' or (getElementType(hitElement) == 'object' and (getElementModel(hitElement) == 964 or getElementModel(hitElement) == 2942 or getElementModel(hitElement) == 1997)) then 
            return hitElement
        end
    end
    return false
end

local keysLiberada = {
    ['a'] = true,
    ['w'] = true,
    ['s'] = true,
    ['d'] = true,
    ['z'] = true,
    ['t'] = true,
    ['e'] = true,
    ['q'] = true,
    ['f6'] = true,
}

addEventHandler('onClientKey', root, function (key, press)
    if getElementData(localPlayer, 'FS:actionState > cuff') or getElementData(localPlayer, 'FS:actionState > grab') or getElementData(localPlayer, 'jogador na malas') then
        if not keysLiberada[string.lower(key)] and press then
            cancelEvent()
        end
    end
end)