local screenW, screenH = guiGetScreenSize();

function aToR(x, y, w, h)
    local xd = x/1366 or x
    local yd = y/768 or y
    local xsd = w/1366 or w
    local ysd = h/768 or h
    return xd * screenW, yd * screenH, xsd * screenW, ysd * screenH
end

_dxDrawRectangle = dxDrawRectangle
function dxDrawRectangle(x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawRectangle(x, y, w, h, ...)
end

_dxDrawText = dxDrawText
function dxDrawText(text, x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w + x, h + y)
    return _dxDrawText(text, x, y, w, h, ...)
end

imageFile = {}
_dxDrawImage = dxDrawImage
function dxDrawImage(x, y, w, h, image, ...)
    local x, y, w, h = aToR(x, y, w, h)
	if not imageFile[image] then
		imageFile[image] = dxCreateTexture(image)
	end
    return _dxDrawImage(x, y, w, h, imageFile[image], ...)
end

function dxDrawImage2(x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawImage(x, y, w, h, ...)
end

local svgFile = {}
local function dxDrawRounded (x, y, w, h, radius, ...)
    if not svgFile[w..'.'..h..':'..radius] then
        local svg = string.format([[ <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'> <mask id='path_inside' fill='#FFFFFF' > <rect width='%s' height='%s' rx='%s' /> </mask> <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/> </svg> ]], w, h, w, h, radius, w, h, radius, tostring(''), tostring(''))
        svgFile[w..'.'..h..':'..radius] = svgCreate(w*2, h*2, svg)
    end
    dxDrawImage2(x, y, w, h, svgFile[w..'.'..h..':'..radius], ...)
end

local function _dxDrawRounded (x, y, w, h, radius, ...)
    if not svgFile[w..'.'..h..':'..radius] then
        local svg = string.format([[ <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'> <mask id='path_inside' fill='#FFFFFF' > <rect width='%s' height='%s' rx='%s' /> </mask> <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/> </svg> ]], w, h, w, h, radius, w, h, radius, tostring(''), tostring(''))
        svgFile[w..'.'..h..':'..radius] = svgCreate(w*2, h*2, svg)
    end
    _dxDrawImage(x, y, w, h, svgFile[w..'.'..h..':'..radius], ...)
end

local cursor = {}
local function isMouseInPosition (x, y, width, height)
    if (not cursor.state) then
        return false
    end
    if not (cursor.x and cursor.y) then
        return false;
    end
    local x, y, width, height = aToR(x, y, width, height)
    return ((cursor.x >= x and cursor.x <= x + width) and (cursor.y >= y and cursor.y <= y + height));
end

local createdFonts = {}
local cachedFonts = {}
function getFont(font, size)
    if not cachedFonts[font..':'..size] then
        cachedFonts[font..':'..size] = {font, size}
    end

    if (createdFonts[font..':'..size]) then 
        return createdFonts[font..':'..size] 
    else
        if font == "integral" or font == "black" then
            createdFonts[font..':'..size] = exports['goiaba_fonts']:useFont('gn:'..font, size)
        else
            createdFonts[font..':'..size] = exports['goiaba_fonts']:useFont('sf:'..font, size)
        end
        return createdFonts[font..':'..size]
    end
end

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        for i,v in pairs(cachedFonts) do
            getFont(v[1], v[2])
            createdFonts = {}
        end
    end
end)



local function destroyElements ()
    if svgFile and type(svgFile) == 'table' then
        for name in pairs(svgFile) do
            if svgFile[name] then
                destroyElement(svgFile[name])
                svgFile[name] = nil
            end
        end
    end
    if imageFile and type(imageFile) == 'table' then
        for name in pairs(imageFile) do
            if imageFile[name] then
                destroyElement(imageFile[name])
                imageFile[name] = nil
            end
        end
    end
end

function convertTime(ms) 
    local min = math.floor ( ms/60000 ) 
    local sec = math.floor( (ms/1000)%60 ) 
    return min, sec 
end

timeDeath = false

function contador()

    cursor.state = isCursorShowing()
    if (cursor.state) then
        local cursorX, cursorY = getCursorPosition()
        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH
    end

    local timer = interpolateBetween(timeDeath, 0, 0, 0, 0, 0, ((getTickCount() - tick) / timeDeath), 'Linear')
    local progress = interpolateBetween(100, 0, 0, 0, 0, 0, ((getTickCount() - tick) / timeDeath), 'Linear')

    minutes2, seconds2 = convertTime(timer)
    local minutes, seconds = convertTime(timer)
    if minutes < 10 then
        minutes = '0'..minutes
    end
    if seconds < 10 then
        seconds = '0'..seconds
    end
    
    local x, y, z = getElementPosition(localPlayer)
    setCameraMatrix(x+1.2, y-1, z + 6, x+1.2, y-1, z)
    
    dxDrawImage(0, 0, 1366, 768, 'images/blur.png', 0, 0, 0, tocolor(255, 255, 255, 255))
    
    dxDrawText('Você está desmaiado, aguarde o tempo finalizar\npara conseguir se finalizar e renascer.', 589, 30, 218, 26, tocolor(255, 255, 255, 255 * 0.4), 1, getFont('regular', 11), 'left', 'center')
    dxDrawImage(559, 33, 20, 20, 'images/info.png', 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText(minutes..':'..seconds, 569, 354, 119, 48, tocolor(255, 255, 255, 255), 1, getFont('bold', 40), 'center', 'center')
    dxDrawRounded(700, 360, 100, 35, 17, 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText(math.floor(timer/1000)..' segundos', 700, 360, 100, 35, tocolor(34, 34, 34, 255), 1, getFont('sbold', 11), 'center', 'center')
    dxDrawRectangle(528, 417, 310, 1, tocolor(255, 255, 255, 255 * 0.07))
    dxDrawText('Após o término do tempo você pode escolher o local\nque deseja renascer.', 559, 433, 239, 26, tocolor(255, 255, 255, 255 * 0.4), 1, getFont('regular', 11), 'center', 'center')
        
    local morte = getElementData(localPlayer, 'responsableDeath')
    if (morte) then
        dxDrawRectangle(656+15, 713, 1, 20, tocolor(255, 255, 255, 255 * 0.1))
        if (morte.weaponName) then 
            dxDrawImage(514+15, 714, 18, 18, 'images/morte.png', 0, 0, 0, tocolor(255, 255, 255, 255 * 0.3))
            dxDrawText('Morte', 542+15, 709, 28, 13, tocolor(255, 255, 255, 255 * 0.5), 1, getFont('regular', 11), 'left', 'center')
            dxDrawText(morte.weaponName, 542+15, 723, 58, 14, tocolor(255, 255, 255, 255), 1, getFont('sbold', 12), 'left', 'center')
        end 
        if (morte.playerName) then 
            dxDrawImage(707+15, 714, 18, 18, 'images/resp.png', 0, 0, 0, tocolor(255, 255, 255, 255))
            dxDrawText('Responsável', 735+15, 709, 59, 13, tocolor(61, 204, 109, 255), 1, getFont('regular', 11), 'left', 'center')
            dxDrawText(morte.playerName, 735+15, 723, 117, 14, tocolor(61, 204, 109, 255), 1, getFont('sbold', 12), 'left', 'center')
        end 
    end 

    if minutes2 <= 0 and seconds2 <= 0 then
        if not tickEffect2 then tickEffect2 = getTickCount() end
        local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount()-tickEffect2)/300), 'Linear')
        dxDrawImage(528, 479, 310, 60, 'images/border.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Você morreu!', 571, 494, 62, 13, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'center')
        dxDrawText('Clique para renascer.', 571, 508, 112, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12), 'left', 'center')
        dxDrawImage(717, 490, 110, 38, 'images/button2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Escolher local', 717, 490, 110, 38, tocolor(255, 255, 255, alpha * 0.7), 1, getFont('bold', 11), 'center', 'center')
        if isMouseInPosition(717, 490, 110, 38) then
            if not tickEffect then tickEffect = getTickCount() end
            local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount()-tickEffect)/300), 'Linear')
            dxDrawImage(717, 490, 110, 38, 'images/button1.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText('Escolher local', 717, 490, 110, 38, tocolor(255, 255, 255, alpha), 1, getFont('bold', 11), 'center', 'center')
        else
            tickEffect = nil
        end
    end

end

addEventHandler('onClientClick', root, function (button, state)
    if button == 'left' and state == 'down' then
        if visible then
            if isMouseInPosition(717, 490, 110, 38) then
                if minutes2 <= 0 and seconds2 <= 0 then
                    stopDead()
                    triggerServerEvent('onPlayerPressECaido', resourceRoot, localPlayer)
                else
                    notify['client']('Você precisa aguardar o tempo terminar para poder renascer.', 'error')
                end
            end
        end
    end
end)

addEventHandler('onClientKey', root, function(key)
    if getElementData(localPlayer, 'Caio.PlayerCaido') == true or getElementData(localPlayer, 'sendoCurado') == true or getElementData(localPlayer, 'sendoTratado') == true then
        cancelEvent()
    end
end)

function startDead (timerVip)
    if not visible then
        timeDeath = timerVip or 3000000
        tickEffect2 = false
        tick = getTickCount()
        showChat(false)
        showCursor(true)
        addEventHandler('onClientRender', root, contador)
        visible = true
    end
end
addEvent('Caio.onStartTimerMorte', true)
addEventHandler('Caio.onStartTimerMorte', root, startDead)

function stopDead ()
    if visible then
        showCursor(false)
        showChat(true)
        removeEventHandler('onClientRender', root, contador)
        visible = false
        setCameraTarget(localPlayer)
        destroyElements()
    end
end

addEvent('Caio.onStopTimerMorte', true)
addEventHandler('Caio.onStopTimerMorte', root, function ()
    stopDead()
end)

setTimer(function()
    if getElementHealth(localPlayer) > config.vida_desanimado then
        if getElementData(localPlayer, 'desanimado') then
            triggerServerEvent('andar-desanimado', localPlayer, localPlayer, 'Normal')
        end
    else
        local vida = getElementHealth(localPlayer)
        if vida >= config['Quant.Caido'] and vida < config.vida_desanimado then
            if not getElementData(localPlayer, 'desanimado') then
                triggerServerEvent('andar-desanimado', localPlayer, localPlayer, 'Desanimado')
            end
        end
    end
end, 1000, 0)

setTimer(function()
	for i,v in ipairs(getElementsByType("player")) do
		if (getElementData(v, "Caio.PlayerCaido")) then
			block, anim = getPedAnimation(v)
			if(anim ~= 'ko_skid_front')then
				setPedAnimation(v, 'ped', 'ko_skid_front', -1, false, false, false, true)
			end
		end
	end
end, 5000, 0)

border = {}
local function dxDrawRectangleBorder(x, y, width, height, color)
    if not border[width..':'..height] then
        local rx = 2
        local raw = string.format(
            '<svg width="%d" height="%d" viewBox="0 0 %d %d" fill="none" xmlns="http://www.w3.org/2000/svg">\n' ..
            '  <rect width="%d" height="%d" rx="%d" fill="url(#paint0_linear)" fill-opacity="0.7"/>\n' ..
            '  <defs>\n' ..
            '    <linearGradient id="paint0_linear" x1="0" y1="%d" x2="%d" y2="%d" gradientUnits="userSpaceOnUse">\n' ..
            '      <stop stop-color="%s"/>\n' ..
            '      <stop offset="1" stop-color="%s" stop-opacity="0.6"/>\n' ..
            '    </linearGradient>\n' ..
            '  </defs>\n' ..
            '</svg>', width, height, width, height, width, height, rx, height / 2, width, height / 2, '#1C1D1F', '#1C1D1F'
        )
        border[width..':'..height] = svgCreate(width, height, raw)
    end
    _dxDrawImage(x, y, width, height, border[width..':'..height], 0, 0, 0, color)
end

killsNotify = {}

addEventHandler('onClientRender', root, function ()
    for i, v in ipairs(killsNotify) do
        if i == 1 then
            local text = 'Você incapacitou '..v[1]
            local width = dxGetTextWidth(text, 1, getFont('medium', 10))
            if not v[2] then 
                v[2] = getTickCount()
            end
            if v[3] then
                alpha = interpolateBetween(255, 0, 0, 0, 0, 0, ((getTickCount()-v[3])/250), 'Linear')
                if alpha <= 1 then
                    table.remove(killsNotify, 1)
                end
            else
                alpha = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount()-v[2])/250), 'Linear')
            end
            local timer = interpolateBetween(0, 0, 0, 100, 0, 0, ((getTickCount()-v[2])/3000), 'Linear')
            dxDrawRectangleBorder((screenW-(width+20))/2, 85, width+20, 35, tocolor(255, 255, 255, alpha))
            _dxDrawText(text, (screenW-width)/2, 93.5, 0, 0, tocolor(255, 255, 255, alpha), 1, getFont('medium', 10))
            if timer == 100 then
                if not v[3] then
                    v[3] = getTickCount()
                end
            end
        end
    end
end)

addEvent('caio.receiveKillNotify', true)
addEventHandler('caio.receiveKillNotify', root, function (info)
    table.insert(killsNotify, {info})
end)

addEventHandler('onClientPedDamage', root, function ()
    if getElementData(source, 'hp:pnc') then
        cancelEvent()
    end
end)