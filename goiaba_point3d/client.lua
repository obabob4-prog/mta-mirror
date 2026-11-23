_dxDrawText = dxDrawText
function dxDrawText (text, x, y, w, h, ...)
    return _dxDrawText(text, x, y, w + x, h + y, ...)
end

font = {
    ['regular'] = exports['goiaba_fonts']:useFont('sf:regular', 10),
    ['bold'] = exports['goiaba_fonts']:useFont('sf:bold', 10),
}

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        font = {
            ['regular'] = exports['goiaba_fonts']:useFont('sf:regular', 10),
            ['bold'] = exports['goiaba_fonts']:useFont('sf:bold', 8),
        }
    end
end)

function render ()
    if position then
	    local pos = {getElementPosition(localPlayer)}
	    local x, y = getScreenFromWorldPosition(position[1], position[2], position[3], 1, true)
        local distance = getDistanceBetweenPoints3D(pos[1], pos[2], pos[3], position[1], position[2], position[3])
	    if x and y then
            dxDrawImage(x, y+2.5, 210, 45, 'assets/images/gb.png', 0, 0, 0, tocolor(255, 255, 255, 255 * 0.8))
            dxDrawImage(x+8, y+8, 34, 34, 'assets/images/loc.png', 0, 0, 0, tocolor(255, 255, 255, 255 * 0.8))
            dxDrawText('Localização', x+50, y+11, 58, 13, tocolor(255, 255, 255, 255 * 0.3), 1, font['regular'], 'left', 'center')
            dxDrawText(title, x+50, y+25, 106, 16, tocolor(255, 255, 255, 255 * 0.9), 1, font['bold'], 'left', 'center', true)
            dxDrawText(math.floor(distance)..'m', x+155, y+14, 45, 24, tocolor(61, 204, 109, 255 * 0.9), 1, font['regular'], 'center', 'center', true)
            if distance < distanceSumir then
                painelOpen('close')
            end
	    end
    end
end

function painelOpen (action, position_, title_, distanceSumir_)
    if not visible and action == 'open' then
        distanceSumir = distanceSumir_ or 5
        position = position_
        title = title_
        removeEventHandler('onClientRender', root, render)
        addEventHandler('onClientRender', root, render)
    elseif visible or action == 'close' then
        removeEventHandler('onClientRender', root, render)
    end
end
addEvent('marcador3D', true)
addEventHandler('marcador3D', root, painelOpen)
