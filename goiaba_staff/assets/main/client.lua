---- FLY ----



local flyingState = false

local keys = {}

keys.up = "up"

keys.down = "up"

keys.f = "up"

keys.b = "up"

keys.l = "up"

keys.r = "up"

keys.a = "up"

keys.s = "up"

keys.m = "up"



addEvent("onClientFlyToggle",true)

addEventHandler("onClientFlyToggle",getLocalPlayer(),function()

	flyingState = not flyingState

	

	if flyingState then

		addEventHandler("onClientRender",getRootElement(),flyingRender)

		bindKey("lshift","both",keyH)

		bindKey("rshift","both",keyH)

		bindKey("lctrl","both",keyH)

		bindKey("rctrl","both",keyH)

		

		bindKey("forwards","both",keyH)

		bindKey("backwards","both",keyH)

		bindKey("left","both",keyH)

		bindKey("right","both",keyH)

		

		bindKey("lalt","both",keyH)

		bindKey("space","both",keyH)

		bindKey("ralt","both",keyH)

		bindKey("mouse1","both",keyH)

		--setElementFrozen(getLocalPlayer(),true)

		setElementCollisionsEnabled(getLocalPlayer(),false)

	else

		removeEventHandler("onClientRender",getRootElement(),flyingRender)

		unbindKey("mouse1","both",keyH)

		unbindKey("lshift","both",keyH)

		unbindKey("rshift","both",keyH)

		unbindKey("lctrl","both",keyH)

		unbindKey("rctrl","both",keyH)

		

		unbindKey("forwards","both",keyH)

		unbindKey("backwards","both",keyH)

		unbindKey("left","both",keyH)

		unbindKey("right","both",keyH)

		

		unbindKey("space","both",keyH)

		

		keys.up = "up"

		keys.down = "up"

		keys.f = "up"

		keys.b = "up"

		keys.l = "up"

		keys.r = "up"

		keys.a = "up"

		keys.s = "up"

		--setElementFrozen(getLocalPlayer(),false)

		setElementCollisionsEnabled(getLocalPlayer(),true)

	end

end)



function flyingRender()

	local x,y,z = getElementPosition(getLocalPlayer())

	local speed = 10

	if keys.a=="down" then

		speed = 3

	elseif keys.s=="down" then

		speed = 50

	elseif keys.m=="down" then

		speed = 300

	end

	

	if keys.f=="down" then

		local a = rotFromCam(0)

		setElementRotation(getLocalPlayer(),0,0,a)

		local ox,oy = dirMove(a)

		x = x + ox * 0.1 * speed

		y = y + oy * 0.1 * speed

	elseif keys.b=="down" then

		local a = rotFromCam(180)

		setElementRotation(getLocalPlayer(),0,0,a)

		local ox,oy = dirMove(a)

		x = x + ox * 0.1 * speed

		y = y + oy * 0.1 * speed

	end

	

	if keys.l=="down" then

		local a = rotFromCam(-90)

		setElementRotation(getLocalPlayer(),0,0,a)

		local ox,oy = dirMove(a)

		x = x + ox * 0.1 * speed

		y = y + oy * 0.1 * speed

	elseif keys.r=="down" then

		local a = rotFromCam(90)

		setElementRotation(getLocalPlayer(),0,0,a)

		local ox,oy = dirMove(a)

		x = x + ox * 0.1 * speed

		y = y + oy * 0.1 * speed

	end

	

	if keys.up=="down" then

		z = z + 0.1*speed

	elseif keys.down=="down" then

		z = z - 0.1*speed

	end

	

	setElementPosition(getLocalPlayer(),x,y,z)

end



function keyH(key,state)

	if key=="lshift" or key=="rshift" then

		keys.s = state

	end	

	if key=="lctrl" or key=="rctrl" then

		keys.down = state

	end	

	if key=="forwards" then

		keys.f = state

	end	

	if key=="backwards" then

		keys.b = state

	end	

	if key=="left" then

		keys.l = state

	end	

	if key=="right" then

		keys.r = state

	end	

	if key=="lalt" or key=="ralt" then

		keys.a = state

	end	

	if key=="space" then

		keys.up = state

	end	

	if key=="mouse1" then

		keys.m = state

	end	

end



function rotFromCam(rzOffset)

	local cx,cy,_,fx,fy = getCameraMatrix(getLocalPlayer())

	local deltaY,deltaX = fy-cy,fx-cx

	local rotZ = math.deg(math.atan((deltaY)/(deltaX)))

	if deltaY >= 0 and deltaX <= 0 then

		rotZ = rotZ+180

	elseif deltaY <= 0 and deltaX <= 0 then 

		rotZ = rotZ+180

	end

	return -rotZ+90 + rzOffset

end



function dirMove(a)

	local x = math.sin(math.rad(a))

	local y = math.cos(math.rad(a))

	return x,y

end





function math.round(number, decimals, method)

    decimals = decimals or 0

    local factor = 10 ^ decimals

    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor

    else return tonumber(("%."..decimals.."f"):format(number)) end

end



function onStealthKill (targetPed)

    if (getElementData (targetPed, "onProt")) then

        cancelEvent()

    end

end

addEventHandler ("onPlayerStealthKill", root, onStealthKill)



function cancelDamage()

    if (getElementData (source, "onProt")) then

        cancelEvent()

    end

end

addEventHandler ("onClientPlayerDamage", root, cancelDamage)

local screenW, screenH = guiGetScreenSize()

function formatTime(segundosTotais)
    local minutos = math.floor(segundosTotais / 60)
    local segundos = segundosTotais % 60
    local tempoFormatado = string.format("%02d:%02d", minutos, segundos)
    return tempoFormatado
end

_dxDrawText = dxDrawText
function dxDrawText (text, x, y, w, h, ...)
	return _dxDrawText(text, x, y, w + x, h + y, ...)
end

local svgFile = {}
local function dxDrawRounded (x, y, w, h, radius, ...)
    if not svgFile[w..'.'..h..':'..radius] then
        local svg = string.format([[ <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'> <mask id='path_inside' fill='#FFFFFF' > <rect width='%s' height='%s' rx='%s' /> </mask> <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/> </svg> ]], w, h, w, h, radius, w, h, radius, tostring(''), tostring(''))
        svgFile[w..'.'..h..':'..radius] = svgCreate(w, h, svg)
    end
    dxDrawImage(x, y, w, h, svgFile[w..'.'..h..':'..radius], ...)
end

addEventHandler('onClientRender', root, function ()
	local timeIniciado = getElementData(localPlayer, 'onProt')
	if timeIniciado then
		local timeAtual = os.time()
		local time = formatTime(timeAtual - timeIniciado)
		if isPedInVehicle(localPlayer) then
			dxDrawRounded(35-1, screenH - (240+30)-1, 200+2, 30+2, 5, 0, 0, 0, tocolor(14,14,14,110))
			dxDrawRounded(35, screenH - (240+30), 200, 30, 5, 0, 0, 0, tocolor(14,14,14, 210))
			dxDrawText('Tempo de atendimento: '..time, 35, screenH - (240+30), 200, 30, tocolor(222, 222, 222, 255), 1, 'default-bold', 'center', 'center')
			--dxDrawText('É necessário pelo menos\n#2f5e2210 minutos #ffffffpara finalizar', 35, screenH - (240+30+35), 200, 30, tocolor(255, 255, 255, 255), 1, 'default-bold', 'center', 'center', false, false, false, true)
		else
			dxDrawRounded(35-1, screenH - (35+30)-1, 200+2, 30+2, 5, 0, 0, 0, tocolor(14,14,14,110))
			dxDrawRounded(35, screenH - (35+30), 200, 30, 5, 0, 0, 0, tocolor(14,14,14, 210))
			dxDrawText('Tempo de atendimento: '..time, 35, screenH - (35+30), 200, 30, tocolor(222, 222, 222, 255), 1, 'default-bold', 'center', 'center')
			--dxDrawText('É necessário pelo menos\n#2f5e2210 minutos #ffffffpara finalizar', 35, screenH - (35+30+35), 200, 30, tocolor(255, 255, 255, 255), 1, 'default-bold', 'center', 'center', false, false, false, true)
		end
	end
end)