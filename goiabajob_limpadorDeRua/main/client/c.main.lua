-- responsive
local parentWidth, parentHeight = 310 * screenScale, 216 * screenScale;
local parentX, parentY = (screenWidth - parentWidth) / 2, (screenHeight - parentHeight) / 2;

local color = config['gerais']['color']

local function respX (value)
    return parentX + respc (value);
end;

local function respY (value)
    return parentY + respc (value);
end;

local function isCursorOnElement (x, y, width, height)
    return ((cursors[1] >= x and cursors[1] <= x + width) and (cursors[2] >= y and cursors[2] <= y + height))
end;

core = {
    events = {
        start = function()
            instance.start()
        end
    }
}

local markerCreate = {}
local sound = {}
local redcircle = dxCreateTexture("assets/ui/sujeira.png")

instance = {
    state = false;
    render = function ()
        if isCursorShowing () then
            local c = {getCursorPosition ()};
            cursors = {c[1] * screenWidth, c[2] * screenHeight};
        end;
        fade = animation.get('fade.alpha')
        parentY = animation.get('fade.move')
        
        dxDrawImage(parentX, parentY, parentWidth, parentHeight, 'assets/ui/background.png', 0, 0, 0, tocolor (255, 255, 255, fade))
        dxDrawImage(parentX, parentY, parentWidth, parentHeight, 'assets/ui/linear.png', 0, 0, 0, tocolor (color[1], color[2], color[3], fade))
        dxDrawImage(respX(20), respY(20), respc(16), respc(16), 'assets/ui/icon-alert.png', 0, 0, 0, tocolor (color[1], color[2], color[3], fade))
        dxDrawRectangle(respX(44), respY(23), respc(1), respc(10), tocolor(255, 255, 255, fade * 0.2))
        dxDrawText(config['gerais']['data:limpador'], respX(53), respY(21), respc(117), respc(15), tocolor(255, 255, 255, fade * 0.8), 1.0, getFont('medium', 12), "left", "center")
        dxDrawImage(respX(20), respY(52), respc(270), respc(35), 'assets/ui/bg1.png', 0, 0, 0, tocolor (255, 255, 255, fade * 0.8))
        dxDrawText(a1[1], respX(35), respY(63), respc(117), respc(14), tocolor(255, 255, 255, fade * 0.4), 1.0, getFont('regular', 11), "left", "center")
        dxDrawText(config['config'][index].nameVeh, respX(218), respY(63), respc(54), respc(14), tocolor(255, 255, 255, fade * 0.8), 1.0, getFont('medium', 11), "right", "center")
        dxDrawImage(respX(20), respY(97), respc(270), respc(50), 'assets/ui/bg2.png', 0, 0, 0, tocolor (255, 255, 255, fade * 0.8))
        dxDrawText(a1[2], respX(81), respY(107), respc(54), respc(15), tocolor(255, 255, 255, fade * 0.8), 1.0, getFont('medium', 11), "left", "center")
        dxDrawText(a1[3], respX(81), respY(123), respc(54), respc(14), tocolor(255, 255, 255, fade * 0.4), 1.0, getFont('regular', 11), "left", "center")
        dxDrawRectangle(respX(70), respY(117), respc(1), respc(10), tocolor(255, 255, 255, fade * 0.2))
        dxDrawImage(respX(21.5), respY(99), respc(47), respc(47), 'assets/ui/bg.png', 0, 0, 0, tocolor (color[1], color[2], color[3], fade))
        dxDrawImage(respX(36), respY(113), respc(18), respc(18), 'assets/ui/car.png', 0, 0, 0, tocolor (255, 255, 255, fade))
        
        dxDrawImage(respX(278), respY(20), respc(12), respc(12), 'assets/ui/close.png', 0, 0, 0, isCursorOnElement(respX(278), respY(20), respc(12), respc(12)) and tocolor(255, 255, 255, fade * 0.8) or tocolor (255, 255, 255, fade * 0.2))
        dxDrawImage(respX(20), respY(161), respc(270), respc(35), 'assets/ui/button.png', 0, 0, 0, isCursorOnElement(respX(20), respY(161), respc(270), respc(35)) and tocolor(color[1] , color[2], color[3], fade * 0.3) or tocolor (color[1], color[2], color[3], fade * 0.8))
        dxDrawText(a1[4], respX(20), respY(161), respc(270), respc(35), tocolor(color[1], color[2], color[3], fade), 1.0, getFont('sbold', 11), "center", "center")
    end;
    
    createBlip = function()
        if isElement(markerCreate[localPlayer]) then 
            destroyElement(markerCreate[localPlayer]) 
            triggerEvent("deletePoint >> wave", localPlayer, localPlayer)
            removeEventHandler('onClientRender', root, instance.setSujeira)
            return
        end
        if isElement(sound[localPlayer]) then 
            destroyElement(sound[localPlayer]) 
            triggerEvent("deletePoint >> wave", localPlayer, localPlayer)
            return
        end
        
        matIndex = math.random (1, #config['points'])

        triggerEvent("marcador3D", localPlayer, 'open', {config['points'][matIndex][1], config['points'][matIndex][2], config['points'][matIndex][3] + 1}, 'Local para limpar', 10)
        markerCreate[localPlayer] = createMarker(config['points'][matIndex][1], config['points'][matIndex][2], config['points'][matIndex][3], 'CheckPoint', 1.3, 255, 255, 255, 0)
        addEventHandler('onClientRender', root, instance.setSujeira)  
        alphaOBJ = 255
        
        addEventHandler('onClientMarkerHit', markerCreate[localPlayer], function(player)
            if player == element then
                local vehicle = getPedOccupiedVehicle(player)
                if vehicle and getElementData(vehicle, 'vehicle.limpadorRua') and getElementData(vehicle, 'vehicle.limpadorRua') == player then
                    animation.exec('fade.object', 255, 2)
                    triggerServerEvent('frozen >> wave', player, player, true)
                    sound[localPlayer] = playSound3D('assets/ui/somMaquina.mp3', config['points'][matIndex][1], config['points'][matIndex][2], config['points'][matIndex][3]) 
                    setSoundMaxDistance(sound[localPlayer], 30)
                    setSoundVolume(sound[localPlayer], 20)
                    triggerEvent('FS:addProgress', localPlayer, 'Limpando', config['gerais']['tempo:limpando'])
                    setTimer ( function()
                        removeEventHandler('onClientRender', root, instance.setSujeira)
                        if isElement(markerCreate[localPlayer]) then destroyElement(markerCreate[localPlayer]) end
                        if isElement(sound[localPlayer]) then destroyElement(sound[localPlayer]) end
                        instance.createBlip()
                        triggerServerEvent('frozen >> wave', player, player, false)
                        triggerServerEvent("Wave >> rewardWork.limpadorRuas", resourceRoot, localPlayer, localPlayer)
                    end, config['gerais']['tempo:limpando'] * 1000, 1 )
                else
                    notify['client']('Você precisa estar em seu veículo de limpar a rua.', 'warning')
                end
            end
        end)
    end;

    
    setSujeira = function() 
        alphaOBJ = animation.get('fade.object')

        if alphaOBJ <= 2 then 
            alphaOBJ = 255
        end

        x,y,z = config['points'][matIndex][1], config['points'][matIndex][2], config['points'][matIndex][3] + 1
        size = 2
        dxDrawMaterialLine3D(x+size, y+size, z-0.95, x-size, y-size, z-0.95, redcircle, size*2,tocolor(255, 255, 255, alphaOBJ), false, x, y, z)
    end;
    
    key = function()
        if instance.state then
            if isCursorOnElement(respX(278), respY(20), respc(12), respc(12)) then 
                instance.toggle(false)
                
            elseif isCursorOnElement(respX(20), respY(161), respc(270), respc(35)) then 
                instance.toggle(false)
                triggerServerEvent('pegarVehLimpador >> wave', localPlayer, localPlayer, index)
            end
        end
    end;
    
    set = function(player, number)
        element = player;
        index = number;
    end;
    
    toggle = function(state) 
        if state then 
            if not instance.state then
                animation.exec('fade.alpha', 0, 255)
                animation.exec('fade.move', 0, parentY)
                addEventHandler ('onClientRender', root, instance.render) 
                showCursor(true)
            end
        else
            if instance.state then 
                parentY = (screenHeight - parentHeight) / 2
                animation.exec('fade.alpha', 255, 0)
                setTimer ( function()
                    removeEventHandler ('onClientRender', root, instance.render)
                end, 500, 1 )
                showCursor(false)
            end
        end
        instance.state = state
    end;
    
    start = function()
        animation.create('fade.alpha', 350, 'Linear')
        animation.create('fade.move', 350, 'OutQuad')
        animation.create('fade.object', config['gerais']['tempo:limpando'] * 1000, 'Linear')
        
        addEvent('render--limpadorderuas >> wave', true)
        addEventHandler('render--limpadorderuas >> wave', localPlayer, instance.toggle)
        addEvent('setLimpador >> wave', true)
        addEventHandler('setLimpador >> wave', localPlayer, instance.set)
        addEvent('criarPointLimpador >> wave', true)
        addEventHandler('criarPointLimpador >> wave', localPlayer, instance.createBlip)
    end;
}
addEventHandler('onClientResourceStart', resourceRoot, core.events.start)
addEventHandler('onClientClick', root, instance.key)