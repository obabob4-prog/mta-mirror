local function formatNumber(number)
	local money = number
	for i = 1, tostring(money):len()/3 do
		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1.%2")
	end
	return money
end

local screen = {guiGetScreenSize()}
local screenW, screenH = guiGetScreenSize();

local function aToR(x, y, w, h)
    local xd = x/1920 or x
    local yd = y/1080 or y
    local xsd = w/1920 or w
    local ysd = h/1080 or h
    return xd * screenW, yd * screenH, xsd * screenW, ysd * screenH
end

local _dxDrawRectangle = dxDrawRectangle
local function dxDrawRectangle(x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawRectangle(x, y, w, h, ...)
end

local _dxDrawText = dxDrawText
local function dxDrawText(text, x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w + x, h + y)
    return _dxDrawText(text, x, y, w, h, ...)
end

imageFile = {}
local _dxDrawImage = dxDrawImage
local function dxDrawImage(x, y, w, h, image, ...)
    local x, y, w, h = aToR(x, y, w, h)
	if not imageFile[image] then
		imageFile[image] = dxCreateTexture(image)
	end
    return _dxDrawImage(x, y, w, h, imageFile[image], ...)
end

local function dxDrawImage2(x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawImage(x, y, w, h, ...)
end

local svgFile = {}
local function dxDrawRounded (x, y, w, h, radius, ...)
    if not svgFile[w..'.'..h..':'..radius] then
        local svg = string.format([[ <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'> <mask id='path_inside' fill='#FFFFFF' > <rect width='%s' height='%s' rx='%s' /> </mask> <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/> </svg> ]], w, h, w, h, radius, w, h, radius, tostring(''), tostring(''))
        svgFile[w..'.'..h..':'..radius] = svgCreate(w, h, svg)
    end
    dxDrawImage2(x, y, w, h, svgFile[w..'.'..h..':'..radius], 0, 0, 0, ...)
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

local font = {}
local function getFont (name, size, ...)
    if not font[name] then
        font[name] = {}
    end
    if not font[name][size] then
        font[name][size] = dxCreateFont('assets/fonts/'..name..'.ttf', (size/1080)*screenH, ...)
    end
    return font[name][size]
end

local _svgCreate = svgCreate
local function svgCreate (w, h, ...)
    return _svgCreate(w*4, h*4, ...)
end

local color = tocolor
local function rgba(r,g,b,a)
    return color(r,g,b,a * 255)
end

local _svgCreate = svgCreate
local function svgCreate (w, h, ...)
    return _svgCreate(w*4, h*4, ...)
end

local color = tocolor
local function rgba(r,g,b,a)
    return color(r,g,b,a * 255)
end

------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------

local _,_,tw, th = aToR(0,0,1800, 203)
local _,_,cw, ch = aToR(0,0,344, 190)
local renderTargetWidth, renderTargetHeight = 1800, 203
local renderTarget = dxCreateRenderTarget(renderTargetWidth, renderTargetHeight, true)
local scrollOffset = 0

local scrollSpeed = 344 + 20
local isScrollingLeft = false
local isScrollingRight = false
local canScroll = true
local selectGarage = 1
local timerOpen = setTimer(function() end, 1000, 1)

notExist = 0

local function scrollLeft()
    if scrollOffset < 0 then
        scrollOffset = math.min(scrollOffset + scrollSpeed, 0)
    end
end

local function scrollRight()
    local maxOffset = -((#vehiclesGaragem - notExist) * (344 + 20 - (20 / (#vehiclesGaragem - notExist))) - tw)
    if scrollOffset >= maxOffset then
        scrollOffset = math.max(scrollOffset - scrollSpeed, maxOffset)
    end
end

local function render()
    cursor.state = isCursorShowing ();
    if (cursor.state) then
        local cursorX, cursorY = getCursorPosition ();
        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;
    end

    dxDrawImage(0,0, 1920, 1080, "assets/images/concessionaria/bg.png")

    dxDrawText("Para sair pressione “ESC”", 1602, 74, 178, 19, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'right', 'center')
    dxDrawRounded(1792, 64, 68, 38, 8, rgba(61, 204, 109, 1))
    dxDrawText("ESC", 1792, 64, 68, 38, rgba(23, 23, 23, 1), 1, getFont('bold', 16), 'center', 'center')

    if isScrollingLeft then
        scrollOffset = math.min(scrollOffset + scrollSpeed * getTickCount() / 1000, 0)
    elseif isScrollingRight then
        local maxOffset = -((#vehiclesGaragem - notExist) * (344 + 20) - 1800)
        scrollOffset = math.max(scrollOffset - scrollSpeed * getTickCount() / 1000, maxOffset)
    end

    notExist_ = 0
    for i, veh in ipairs(vehiclesGaragem) do
        if vehicles[veh[1]] then
            local y = 1080 - 260
            local x = (i - 1 - notExist_) * (344 + 20) + scrollOffset
            if x + 344 > 0 and x < 1800 then
                dxDrawRounded(x+60, y, 344, 190, 12, (isMouseInPosition(x+60, y, 344, 190) or selectGarage == i) and rgba(255, 255, 255, 0.1) or rgba(255, 255, 255, 0.05))
                dxDrawText(veh[2], x+86, y + 25, 150, 21, rgba(255, 255, 255, 0.9), 1, getFont('bold', 13), 'left', 'center')
                dxDrawRounded(x+275+60, y + 20, 45, 45, 8, rgba(61, 204, 109, 1))
                dxDrawImage(x+282.5+60, y + 27.5, 31, 30, "assets/images/concessionaria/marcas/"..vehicles[veh[1]].marca..".png")
                if vehicles[veh[1]].notImage then
                    dxDrawImage(x+110, y + 47, 230, 130, "assets/images/concessionaria/carros/veh.png")
                else
                    dxDrawImage(x+110, y + 47, 230, 130, "assets/images/concessionaria/carros/"..veh[1]..".png")
                end
            end
        else
            notExist_ = notExist_ + 1
        end
    end

    if selectGarage and vehiclesGaragem[selectGarage] and vehiclesGaragem[selectGarage][1] and vehicles[vehiclesGaragem[selectGarage][1]] then
    local vehicleData = vehicles[vehiclesGaragem[selectGarage][1]]
        dxDrawRounded(60, 64, 85, 85, 22, rgba(61, 204, 109, 1))
        dxDrawImage(74, 79, 56, 56, "assets/images/concessionaria/marcas/"..vehicles[vehiclesGaragem[selectGarage][1]].marca..".png")
        dxDrawText(string.upper(vehicles[vehiclesGaragem[selectGarage][1]].nome), 60, 193, 143, 38, rgba(255, 255, 255, 1), 1, getFont('bold', 20), 'left', 'center')
        dxDrawText(string.upper(vehicles[vehiclesGaragem[selectGarage][1]].marca), 61, 220, 143, 38, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')

        local timestamp = vehiclesGaragem[selectGarage][8]

        if timestamp and timestamp ~= "permanente" and timestamp <= getRealTime().timestamp then
            vehState = "Vencido"
            vehState_ = "None"
        elseif vehiclesGaragem[selectGarage][6].state == 0 then
            vehState = "Guardado"
            vehState_ = "Retirar"
        elseif vehiclesGaragem[selectGarage][6].state == 1 then
            vehState = "Retirado"
            vehState_ = "Guardar"
        elseif vehiclesGaragem[selectGarage][6].state == 2 then
            vehState = "Detido"
            vehState_ = "Pagar"
        end

        dxDrawText("Status", 61, 331, 143, 38, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')
        dxDrawText(vehState and vehState or "Retirado", 61, 357, 143, 38, rgba(255, 255, 255, 1), 1, getFont('bold', 16), 'left', 'center')

        dxDrawText("Motor", 61, 404, 143, 38, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')
        dxDrawText(((vehiclesGaragem[selectGarage][6].vida * 100) / 1000).."%", 61, 430, 143, 38, rgba(255, 255, 255, 1), 1, getFont('bold', 16), 'left', 'center')

        dxDrawText("Gasolina", 61, 474, 143, 38, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')
        dxDrawText(vehiclesGaragem[selectGarage][6].gasolina.."%", 61, 500, 143, 38, rgba(255, 255, 255, 1), 1, getFont('bold', 16), 'left', 'center')

        if vehState == "Detido" then
            dxDrawText("Valor Taxa: ", 1575, 690, 285, 56, rgba(255, 255, 255, 1), 1, getFont('medium', 15), 'left', 'center')
            dxDrawText("R$ "..formatNumber(math.floor((vehicles[vehiclesGaragem[selectGarage][1]].valor / 100) * 30)), 1575, 690, 285, 56, rgba(255, 255, 255, 1), 1, getFont('medium', 15), 'right', 'center')
        end

        if vehState_ ~= "None" then
            dxDrawRounded(1575, 739, 285, 56, 6, isMouseInPosition(1575, 739, 285, 56) and rgba(61, 204, 109, 1) or rgba(61, 204, 109, 0.8))
            dxDrawText(vehState_.." Veículo", 1575, 739, 285, 56, rgba(23, 23, 23, 1), 1, getFont('bold', 15), 'center', 'center')
            dxDrawImage(1593, 755, 24, 24, "assets/images/concessionaria/buy.png", 0, 0, 0, rgba(0,0,0,1))
        else
            dxDrawRounded(1575, 739, 285, 56, 6, isMouseInPosition(1575, 739, 285, 56) and rgba(200, 200, 200, 0.8) or rgba(200, 200, 200, 0.8))
            dxDrawText("Veículo Vencido", 1575, 739, 285, 56, rgba(24, 24, 24, 1), 1, getFont('bold', 15), 'center', 'center')
            dxDrawImage(1593, 755, 24, 24, "assets/images/concessionaria/buy.png", 0, 0, 0, rgba(255, 255, 255, 1))
        end
    end

    dxDrawRounded(39, 897, 42, 45, 10, isMouseInPosition(39, 897, 42, 45) and rgba(61, 204, 109, 1) or rgba(255, 255, 255, 1))
    dxDrawImage(47, 907, 24, 24, "assets/images/concessionaria/arrow.png", 0, 0, 0, rgba(0,0,0,1))

    dxDrawRounded(1839, 897, 42, 45, 10, isMouseInPosition(1839, 897, 42, 45) and rgba(61, 204, 109, 1) or rgba(255, 255, 255, 1))
    dxDrawImage(1850, 907, 24, 24, "assets/images/concessionaria/arrow2.png", 0, 0, 0, rgba(0,0,0,1))
end

function click(button, state, x, y)
    if state == "down" then
        if isMouseInPosition(1575, 739, 285, 56) then
            local timestamp = vehiclesGaragem[selectGarage][8]
            if timestamp and timestamp ~= "permanente" and timestamp <= getRealTime().timestamp then
                return
            end
            if vehiclesGaragem[selectGarage][6].state == 0 then
                triggerServerEvent('onGaragemAction', localPlayer, 'puxar veículo', vehiclesGaragem[selectGarage][1])
                garagemPanel()
            elseif vehiclesGaragem[selectGarage][6].state == 1 then
                triggerServerEvent('onGaragemAction', localPlayer, 'puxar veículo', vehiclesGaragem[selectGarage][1])
            elseif vehiclesGaragem[selectGarage][6].state == 2 then
                poupTaxa = {
                    model = vehiclesGaragem[selectGarage][1],
                    price = math.floor((vehicles[vehiclesGaragem[selectGarage][1]].valor / 100) * 30),
                    name = vehiclesGaragem[selectGarage][2]
                }
                triggerServerEvent('pagarTaxaVehicle', resourceRoot, localPlayer, poupTaxa)
            end


        elseif isMouseInPosition(39, 897, 42, 45) then
            if canScroll then
                canScroll = false
                scrollLeft()
            end
        elseif isMouseInPosition(1839, 897, 42, 45) then
            if canScroll then
                canScroll = false
                scrollRight()
            end
        else
            notExists = 0
            for i, veh in ipairs(vehiclesGaragem) do
                if vehicles[veh[1]] then
                    local y = 1080 - 260
                    local x = (i - 1 - notExists) * (344 + 20) + scrollOffset
                    if x + 344 > 0 and x < 1800 then
                        if isMouseInPosition(x+60, y, 344, 190) then
                            selectGarage = i
                        end
                    end
                else
                    notExists = notExists + 1
                end
            end
        end
    elseif state == "up" then
        canScroll = true
    end
end

function onPreEvent( sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ... )
    local args = {...}
    if visible and args[1] == "escape" then
        garagemPanel()
        return "skip"
    end
end
addDebugHook( "preEvent", onPreEvent, {"onClientKey"})


addEvent('refreshGaragemVehicles', true)
addEventHandler('refreshGaragemVehicles', root, function (tableVehicles)
    vehiclesGaragem = tableVehicles

    notExist = 0
    for i, veh in ipairs(vehiclesGaragem) do
        if not vehicles[veh[1]] then
            notExist = notExist + 1
        end
    end

    poupTaxa = false
end)

function garagemPanel  (tableVehicles)
    if not visible and tableVehicles then
        if not timerOpen or  isTimer(timerOpen)then return end
        selectVehicle = nil
        vehiclesGaragem = tableVehicles

        notExist = 0
        for i, veh in ipairs(vehiclesGaragem) do
            if not vehicles[veh[1]] then
                notExist = notExist + 1
            end
        end

        proxPag = 0
        poupTaxa = false
        effect = {0, 255, getTickCount(), 150}
        animation = {150, 0, getTickCount(), 150}
        visible = true
        showCursor(true)
        showChat(false)
        others['hudState'](false)
        addEventHandler('onClientRender', root, render)
        addEventHandler('onClientClick', root, click)
    elseif visible then
        if not closing then
            showCursor(false)
            showChat(true)
            removeEventHandler('onClientClick', root, click)
            closing = true
            others['hudState'](true)
            effect = {255, 0, getTickCount(), 150}
            animation = {0, 150, getTickCount(), 150}
            setTimer(function ()
                closing = false
                visible = false
                removeEventHandler('onClientRender', root, render)
            end, effect[4] + 50, 1)
            timerOpen = setTimer(function() end, 1000, 1)
        end
    end
end
addEvent('garagemStatePanel', true)
addEventHandler('garagemStatePanel', root, garagemPanel )