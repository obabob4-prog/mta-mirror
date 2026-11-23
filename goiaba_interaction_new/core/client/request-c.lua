--| Screen

local pattern_y = (screen.y / 2) - respc(50/2) - respc(config['request']['positions']['y'])

--| Var's

local request = {}
local rendering
local responseTimer

--| Interface

function renderRequest()
    CreateThread(function()
        while (rendering) do 

            if not (request) then 
                closeRequest()
                return 
            end

            local name = removeHex(getPlayerName(request.owner))
            local id = request.ownerId

            if(getElementData(request.owner, "GB>>FakeID"))then
                id = getElementData(request.owner, "GB>>FakeID")
            end

            if(getElementData(request.owner, "GB>>FakeNAME"))then
                name = getElementData(request.owner, "GB>>FakeNAME")
            end

            --| Position's
            local x, y = screen.x - respc(config['request']['positions']['x']) - respc(request.textWidth + 133), pattern_y

            --| Alpha
            local alpha = getAnimation('r_alpha')

            --| Background
            dxDrawRoundedRectangle('request bg', x, y, respc(request.textWidth + 133), respc(50), tocolor(bgColor[1], bgColor[2], bgColor[3], (alpha/100)*50), respc(6), false)

            --| Text 
            dxDrawText('#E9E9E9'..name..' ('..id..') - #B3B6B6'..request.text, x + respc(15), y, respc(190), respc(50), tocolor(255, 255, 255, (alpha/100)*90), 1, exports['goiaba_fonts']:useFont('sf:medium', 11), 'left', 'center', false, false, false, true)

            --| Button's
            dxDrawStrokedRoundRectangle('decline button', x + respc(15) + respc(request.textWidth + 30), y + respc(8), respc(34), respc(34), tocolor(204, 61, 61, alpha * 0.8), tocolor(255, 255, 255, (alpha/100)*8), respc(1.7), respc(5), false)
            dxDrawText(string.upper(config['request']['binds'].decline), x + respc(15) + respc(request.textWidth + 30), y + respc(9), respc(34), respc(34), tocolor(255, 255, 255, (alpha/100)*65), 1, exports['goiaba_fonts']:useFont('sf:medium', 11), 'center', 'center')

            dxDrawStrokedRoundRectangle('accept button', x + respc(15) + respc(request.textWidth + 30) + respc(34) + respc(5), y + respc(8), respc(34), respc(34), tocolor(61, 204, 109, alpha * 0.8), tocolor(bgColor[1], bgColor[2], bgColor[3], (alpha/100)*45), respc(1.7), respc(5), false)
            dxDrawText(string.upper(config['request']['binds'].accept), x + respc(15) + respc(request.textWidth + 30) + respc(34) + respc(5), y + respc(9), respc(34), respc(34), tocolor(255, 255, 255, (alpha/100)*85), 1, exports['goiaba_fonts']:useFont('sf:medium', 11), 'center', 'center')

            coroutine.yield()

        end
    end)
end

--| Render function's

function receiveRequest(data)
    
    if (rendering) then return end 
    createAnimation('r_alpha', 0, 255, 350, 'OutQuad')

    request = data
    request.textWidth = dxGetTextWidth(removeHex(getPlayerName(request.owner))..' ('..request.ownerId..') - '..request.text, 1, exports['goiaba_fonts']:useFont('sf:medium', 11), true)
    bindKey(config['request']['binds'].accept, 'down', triggerAction, 'accept')
    bindKey(config['request']['binds'].decline, 'down', triggerAction, 'decline')
    
    responseTimer = setTimer(function()
        triggerServerEvent('FS:onRequestAction', resourceRoot, localPlayer, request, 'decline')
        closeRequest()
    end, (config['request']['responseTime'] * 1000), 1)

    rendering = true 
    execAnimation('r_alpha', 0, 255, 350, 'OutQuad')
    renderRequest()

end
addEvent('FS:sendRequest', true)
addEventHandler('FS:sendRequest', resourceRoot, receiveRequest)

function closeRequest()
    if (not rendering) then return end 

    execAnimation('r_alpha', 255, 0, 350, 'OutQuad')
    unbindKey(config['request']['binds'].accept, 'down', triggerAction, 'accept')
    unbindKey(config['request']['binds'].decline, 'down', triggerAction, 'decline')

    if responseTimer and isTimer(responseTimer) then 
        killTimer(responseTimer)
        responseTimer = nil
    end

    setTimer(function()
        rendering = false 
    end, 350, 1)

end

function triggerAction(key, state, value)
    if (not rendering) then return end
    triggerServerEvent('FS:onRequestAction', resourceRoot, localPlayer, request, value)
    closeRequest()
end