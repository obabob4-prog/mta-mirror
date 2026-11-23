--[[

    --» sᴄʀɪᴘᴛ ғᴇɪᴛᴏ ᴘᴏʀ » Pedrooooo#1554

--]]





local screenW, screenH = guiGetScreenSize();

local screenScale = math.min(math.max(screenH / 768, 0.70), 2); -- Caso o painel seja muito grande, retirar o limite e deixar apenas o (screenH / 768).



local parentW, parentH = (310 * screenScale), (430 * screenScale); -- Comprimento e Largura do painel.

local parentX, parentY = ((screenW - parentW) / 2), ((screenH - parentH) / 2); -- Posição X e Y do painel.



------------------------------------------------

local function respX (x)

    return (parentX + (x * screenScale));

end

    

local function respY (y)

    return (parentY + (y * screenScale));

end

    

local function respC (scale)

    return (scale * screenScale);

end



local _dxDrawText = dxDrawText;

local function dxDrawText(text, x, y, width, height, ...)

    return _dxDrawText(text, respX(x), respY(y+(animationY or 0)), (respX(x) + respC(width)), (respY(y+(animationY or 0)) + respC(height)), ...);

end



local _dxDrawRectangle = dxDrawRectangle;

local function dxDrawRectangle(x, y, width, height, ...)

    return _dxDrawRectangle(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);

end



local _dxDrawImage = dxDrawImage;

local function dxDrawImage(x, y, width, height, ...)

    return _dxDrawImage(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);

end



local cursor = {}

local function isMouseInPosition (x, y, width, height)

    if (not cursor.state) then

        return false

    end

    if not (cursor.x and cursor.y) then

        return false;

    end

    x, y, width, height = respX(x), respY(y), respC(width), respC(height);

    return ((cursor.x >= x and cursor.x <= x + width) and (cursor.y >= y and cursor.y <= y + height));

end



local size = {}

local function drawBorder ( radius, x, y, width, height, color, colorStroke, sizeStroke, postGUI )



    colorStroke = tostring(colorStroke)

    sizeStroke = tostring(sizeStroke)

    if (not size[height..':'..width]) then

        local raw = string.format([[

            <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'>

                <mask id='path_inside' fill='#FFFFFF' >

                    <rect width='%s' height='%s' rx='%s' />

                </mask>

                <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/>

            </svg>

        ]], width, height, width, height, radius, width, height, radius, colorStroke, sizeStroke)

        size[height..':'..width] = svgCreate(width, height, raw)

    end



    if (size[height..':'..width]) then

        dxDrawImage(x, y, width, height, size[height..':'..width], 0, 0, 0, color, postGUI)

    end



end



local function _drawBorder ( radius, x, y, width, height, color, colorStroke, sizeStroke, postGUI )



    colorStroke = tostring(colorStroke)

    sizeStroke = tostring(sizeStroke)

    if (not size[height..':'..width]) then

        local raw = string.format([[

            <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'>

                <mask id='path_inside' fill='#FFFFFF' >

                    <rect width='%s' height='%s' rx='%s' />

                </mask>

                <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/>

            </svg>

        ]], width, height, width, height, radius, width, height, radius, colorStroke, sizeStroke)

        size[height..':'..width] = svgCreate(width, height, raw)

    end



    if (size[height..':'..width]) then

        _dxDrawImage(x, y, width, height, size[height..':'..width], 0, 0, 0, color, postGUI)

    end



end



local function isEventHandlerAdded( sEventName, pElementAttachedTo, func )

    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then

        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )

        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then

            for i, v in ipairs( aAttachedFunctions ) do

                if v == func then

                    return true

                end

            end

        end

    end

    return false

end



function timerFormatCounter(milissegundos)

    local segundos = math.floor(milissegundos / 1000)

    local minutos = math.floor(segundos / 60)

    local horas = math.floor(minutos / 60)



    local segundosRestantes = segundos % 60

    local minutosRestantes = minutos % 60



    return string.format("%02d:%02d:%02d", horas, minutosRestantes, segundosRestantes)

end



function formatNumber(number, sep)

	assert(type(tonumber(number))=="number", "Bad argument @'formatNumber' [Expected number at argument 1 got "..type(number).."]")

	assert(not sep or type(sep)=="string", "Bad argument @'formatNumber' [Expected string at argument 2 got "..type(sep).."]")

	local money = number

	for i = 1, tostring(money):len()/3 do

		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1"..sep.."%2")

	end

	return money

end

------------------------------------------------    

local createdFonts = {}
local cachedFonts = {}
local function getFont(font, size)

    if not cachedFonts[font..':'..size] then
        cachedFonts[font..':'..size] = {font, size}
    end

    if (createdFonts[font..':'..size]) then 
        return createdFonts[font..':'..size] 
    else 
        createdFonts[font..':'..size] = exports['goiaba_fonts']:useFont('sf:'..font, respC(size/1.25))
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


function drawApplyFines()



	cursor.state = isCursorShowing ();

    if (cursor.state) then



        local cursorX, cursorY = getCursorPosition ();

        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;



    end 



	local alpha = interpolateBetween(interpolate[1], 0, 0, interpolate[2], 0, 0, ((getTickCount() - tick) / 150), 'Linear')

	animationY = interpolateBetween(animation[1], 0, 0, animation[2], 0, 0, ((getTickCount() - tick)/ 150), 'InOutQuad')



	dxDrawImage(0, 0, 310, 430, 'assets/images/bg.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawImage(100, 20, 110, 40, 'assets/images/logo.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



	drawBorder(7, 20, 80, 270, 30, tocolor(255, 255, 255, alpha * 0.03))

	dxDrawImage(35, 87, 16, 16, 'assets/images/search.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText(selectEdit == 1 and guiGetText(searchEdit)..'|' or guiGetText(searchEdit), 56, 88, 69, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))



	local totalPrice = 0

	drawBorder(7, 20, 120, 270, 130, tocolor(255, 255, 255, alpha * 0.03))



	pages[3] = #config.fines - 4

	local line = 0

	for i, v in ipairs(config.fines) do



		local selected = isFineSelect(i)

		if (selected) then 



			totalPrice = totalPrice + v[2]



		end 



		if (i > pages[1] and line < 4) then 



			line = (line + 1)



			if (selected) then 



				dxDrawRectangle(20, 125 + (30 * (line - 1)), 267, 30, tocolor(255, 255, 255, alpha * 0.04))

				dxDrawText(v[1], 35, 134 + (30 * (line - 1)), 82, 13, tocolor(2, 253, 83, alpha), 1, getFont('sbold', 11))

				dxDrawText('$'..formatNumber(v[2], '.'), 227, 134 + (30 * (line - 1)), 28, 13, tocolor(2, 253, 83, alpha), 1, getFont('sbold', 11), 'right')

				dxDrawImage(263, 134 + (30 * (line - 1)), 12, 12, 'assets/images/circle2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



			elseif (isMouseInPosition(20, 125 + (30 * (line - 1)), 267, 30)) then 



				dxDrawRectangle(20, 125 + (30 * (line - 1)), 267, 30, tocolor(255, 255, 255, alpha * 0.04))

				dxDrawText(v[1], 35, 134 + (30 * (line - 1)), 82, 13, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 11))

				dxDrawText('$'..formatNumber(v[2], '.'), 227, 134 + (30 * (line - 1)), 28, 13, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 11), 'right')

				dxDrawImage(263, 134 + (30 * (line - 1)), 12, 12, 'assets/images/circle2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



			else



				dxDrawText(v[1], 35, 134 + (30 * (line - 1)), 82, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('sbold', 11))

				dxDrawText('$'..formatNumber(v[2], '.'), 227, 134 + (30 * (line - 1)), 28, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('sbold', 11), 'right')

				dxDrawImage(263, 134 + (30 * (line - 1)), 12, 12, 'assets/images/circle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



			end



		end



	end



	if (pages[3] > 0) then 

	

		dxDrawRectangle(287, 125, 3, 120, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawRectangle(287, 125 + ((120 - 50) * (pages[2] / pages[3])), 3, 50, tocolor(2, 253, 83, alpha))



		if (moving) then 



			local start, finish = parentY + (125 * screenScale), parentY + ((125 + 120) * screenScale)

			local cx, cy = getCursorPosition()

			local mx, my = (cx * screenW), (cy * screenH)

			

			if (my < start) then 

			

				pages[1], pages[2] = 0, 0 

			

			elseif (my > finish) then 

			

				pages[1], pages[2] = pages[3], pages[3] 

			

			else 



				local progress = my - start

				local height = screenScale * 120

				local percentage  = (progress / height) * 100

				local new_page = (pages[3] / 100) * percentage 

				pages[1], pages[2] = math.floor(new_page), new_page 



			end



			if not (getKeyState('mouse1')) then 



				moving = nil 



			end 

		

		end



	end



	drawBorder(7, 20, 260, 270, 50, tocolor(255, 255, 255, alpha * 0.03))

	dxDrawImage(35, 270, 30, 30, 'assets/images/description.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText('Selecione as multas e as aplique no\ncidadão desejado.', 80, 272, 195, 26, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))

	

	dxDrawText('Valor total', 20, 325, 49, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('sbold', 11))

	dxDrawImage(20, 340, 18, 18, 'assets/images/diamond.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText('$'..formatNumber(totalPrice, '.'), 45, 341, 46, 16, tocolor(255, 255, 255, alpha), 1, getFont('bold', 13))



	drawBorder(7, 50, 373, 90, 35, tocolor(255, 255, 255, alpha * 0.03))

	dxDrawText('Cancelar', 50, 373, 90, 35, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12), 'center', 'center')



	if (isMouseInPosition(50, 373, 90, 35)) then 



		if not (cancelTick) then cancelTick = getTickCount() end 

		local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - cancelTick) / 300), 'Linear')

		drawBorder(7, 50, 373, 90, 35, tocolor(2, 254, 83, animation))

		dxDrawText('Cancelar', 50, 373, 90, 35, tocolor(0, 0, 0, animation), 1, getFont('bold', 12), 'center', 'center')



	else



		cancelTick = nil 



	end



	drawBorder(7, 150, 373, 110, 35, tocolor(255, 255, 255, alpha * 0.03))

	dxDrawText('Multar', 150, 373, 110, 35, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12), 'center', 'center')



	if (isMouseInPosition(150, 373, 110, 35)) then 



		if not (confirmTick) then confirmTick = getTickCount() end 

		local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - confirmTick) / 300), 'Linear')

		drawBorder(7, 150, 373, 110, 35, tocolor(2, 254, 83, animation))

		dxDrawText('Multar', 150, 373, 110, 35, tocolor(0, 0, 0, animation), 1, getFont('bold', 12), 'center', 'center')



	else



		confirmTick = nil 



	end



end



addEventHandler('onClientKey', root, 



	function(key, press)



		if (isEventHandlerAdded('onClientRender', root, drawApplyFines) and press) then 



			if (key == 'mouse_wheel_down') then 

			

				if (pages[1] < pages[3]) then 

				

					pages[1] = pages[1] + 1 

					pages[2] = pages[1]

				

				end 

			

			elseif (key == 'mouse_wheel_up') then 

			

				if (pages[1] > 0) then 

				

					pages[1] = pages[1] - 1 

					pages[2] = pages[1]

				

				end 

			

			end



		end



	end



)



addEventHandler('onClientClick', root, 

	

	function(b, s)



		if (b == 'left' and s == 'down') then 



			if (isEventHandlerAdded('onClientRender', root, drawApplyFines)) then 



				selectEdit = 0



				if (guiGetText(searchEdit) == '') then 



					guiSetText(searchEdit, 'ID do jogador')



				end

				

				if (isMouseInPosition(50, 373, 90, 35)) then  



					removeApplyFines()



				elseif (isMouseInPosition(150, 373, 110, 35)) then



					triggerServerEvent('onPlayerApplyFines', resourceRoot, localPlayer, guiGetText(searchEdit), finesSelects)

					removeApplyFines()



				elseif (isMouseInPosition(20, 91, 220, 30)) then 



					if (guiEditSetCaretIndex(searchEdit, #guiGetText(searchEdit))) then 



						guiBringToFront(searchEdit)

						guiSetInputMode('no_binds_when_editing')



						selectEdit = 1 

						if (guiGetText(searchEdit) == 'ID do jogador') then 



							guiSetText(searchEdit, '')

		

						end



					end



				elseif (isMouseInPosition(287, 125, 3, 120)) then 



					moving = true



				else



					local line = 0

					for i, v in ipairs(config.fines) do

				

						if (i > pages[1] and line < 4) then 

				

							line = (line + 1)

							

							if (isMouseInPosition(20, 125 + (30 * (line - 1)), 267, 30)) then 



								local index = isFineSelect(v[1])

								if (index) then 



									table.remove(finesSelects, index)



								else



									finesSelects[#finesSelects + 1] = i



								end



							return end 

				

						end

				

					end



				end



			end



		end



	end



)



addEvent('onClientDrawApplyFines', true)

addEventHandler('onClientDrawApplyFines', root, 



	function(players_)



		if (isEventHandlerAdded('onClientRender', root, drawFines)) then 



			return 



		end 



		if not (isEventHandlerAdded('onClientRender', root, drawApplyFines)) then 



			parentW, parentH = (310 * screenScale), (430 * screenScale); -- Comprimento e Largura do painel.

			parentX, parentY = ((screenW - parentW) / 2), ((screenH - parentH) / 2); -- Posição X e Y do painel.



			tick, interpolate, animation, pages = getTickCount(), {0, 255}, {150, 0}, {0, 0, 0}

			finesSelects = {}

			

			addEventHandler('onClientRender', root, drawApplyFines)

			showCursor(true)

			showChat(false)



			searchEdit = guiCreateEdit(0, 0, 0, 0, 'ID do jogador', false)

			guiEditSetMaxLength(searchEdit, 100)



		else



			removeApplyFines()



		end



	end



)



function removeApplyFines()

	

	if (isEventHandlerAdded('onClientRender', root, drawApplyFines)) then 



		if (interpolate[1] == 0) then 



			tick, interpolate, animation = getTickCount(), {255, 0}, {0, 150}



			showCursor(false)

			setTimer(function()

			

				removeEventHandler('onClientRender', root, drawApplyFines)

				showChat(true)

				

				if (isTimer(searchEdit)) then 



					destroyElement(searchEdit)

	

				end



			end, 150, 1)



		end



	end



end

bindKey('backspace', 'down', removeApplyFines)



function isFineSelect(fine)



	for i, v in ipairs(finesSelects) do 



		if (v == fine) then 



			return i 



		end



	end



end 



function drawFines()



	cursor.state = isCursorShowing ();

    if (cursor.state) then



        local cursorX, cursorY = getCursorPosition ();

        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;



    end 



	local alpha = interpolateBetween(interpolate[1], 0, 0, interpolate[2], 0, 0, ((getTickCount() - tick) / 150), 'Linear')

	animationY = interpolateBetween(animation[1], 0, 0, animation[2], 0, 0, ((getTickCount() - tick)/ 150), 'InOutQuad')



	dxDrawImage(0, 0, 500, 310, 'assets/images/bg2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawImage(20, 20, 110, 40, 'assets/images/logo.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	

	dxDrawImage(470, 20, 10, 10, 'assets/images/exit.png', 0, 0, 0, tocolor(64, 64, 64, alpha))



	if (isMouseInPosition(470, 20, 10, 10)) then 



		if not (exitTick) then exitTick = getTickCount() end 

		local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - exitTick) / 300), 'Linear')

		dxDrawImage(470, 20, 10, 10, 'assets/images/exit.png', 0, 0, 0, tocolor(2, 254, 83, animation))



	else



		exitTick = nil 



	end



	dxDrawRectangle(20, 75, 460, 1, tocolor(255, 255, 255, alpha * 0.05))



	drawBorder(7, 20, 85, 460, 155, tocolor(255, 255, 255, alpha * 0.03))

	dxDrawText('Motivo', 35, 95, 28, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('regular', 11))

	dxDrawText('Autor', 227, 95, 28, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('regular', 11))

	dxDrawText('Valor', 366, 95, 28, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('regular', 11))



	local totalPrice = 0 

	if (#fines == 0) then 



		dxDrawText('Sem multas', 214, 141, 70, 16, tocolor(255, 255, 255, alpha), 1, getFont('bold', 13), 'center')

		dxDrawText('Você não possui nenhuma multa\nativa atualmente.', 214, 159, 70, 16, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('sbold', 11), 'center')



	else



		pages[3] = #fines - 4 



		local line = 0

		for i, v in ipairs(fines) do 



			if (i > pages[1] and line < 4) then 



				line = (line + 1)



				if (isMouseInPosition(20, 115 + (30 * (line - 1)), 457, 30) or selectFine == i) then 



					dxDrawRectangle(20, 115 + (30 * (line - 1)), 457, 30, tocolor(255, 255, 255, alpha * 0.04))

					dxDrawText(v[1], 35, 124 + (30 * (line - 1)), 82, 13, tocolor(2, 253, 83, alpha), 1, getFont('sbold', 11))

					dxDrawText(v[3], 227, 124 + (30 * (line - 1)), 82, 13, tocolor(2, 253, 83, alpha), 1, getFont('sbold', 11))

					dxDrawText('R$ '..formatNumber(v[2], '.'), 366, 124 + (30 * (line - 1)), 82, 13, tocolor(2, 253, 83, alpha), 1, getFont('sbold', 11))



				else



					dxDrawText(v[1], 35, 124 + (30 * (line - 1)), 82, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('sbold', 11))

					dxDrawText(v[3], 227, 124 + (30 * (line - 1)), 82, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('sbold', 11))

					dxDrawText('R$ '..formatNumber(v[2], '.'), 366, 124 + (30 * (line - 1)), 82, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('sbold', 11))



				end



			end



			totalPrice = totalPrice + v[2]



		end



		if (pages[3] > 0) then 

	

			dxDrawRectangle(477, 115, 3, 120, tocolor(255, 255, 255, alpha * 0.03))

			dxDrawRectangle(477, 115 + ((120 - 50) * (pages[2] / pages[3])), 3, 50, tocolor(2, 253, 83, alpha))

	

			if (moving) then 

	

				local start, finish = parentY + (115 * screenScale), parentY + ((115 + 120) * screenScale)

				local cx, cy = getCursorPosition()

				local mx, my = (cx * screenW), (cy * screenH)

				

				if (my < start) then 

				

					pages[1], pages[2] = 0, 0 

				

				elseif (my > finish) then 

				

					pages[1], pages[2] = pages[3], pages[3] 

				

				else 

	

					local progress = my - start

					local height = screenScale * 120

					local percentage  = (progress / height) * 100

					local new_page = (pages[3] / 100) * percentage 

					pages[1], pages[2] = math.floor(new_page), new_page 

	

				end

	

				if not (getKeyState('mouse1')) then 

	

					moving = nil 

	

				end 

			

			end

	

		end



	end



	dxDrawText('Total de multas', 20, 255, 73, 13, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('sbold', 11))

	dxDrawImage(20, 270, 18, 18, 'assets/images/diamond.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText('R$ '..formatNumber(totalPrice, '.'), 45, 271, 17, 16, tocolor(255, 255, 255, alpha), 1, getFont('bold', 13))



	drawBorder(7, 370, 255, 110, 35, tocolor(255, 255, 255, alpha * 0.03))

	dxDrawText(selectFine ~= 0 and 'Pagar multa' or 'Pagar todas', 370, 255, 110, 35, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12), 'center', 'center')



	if (isMouseInPosition(370, 255, 110, 35)) then 



		if not (buyTick) then buyTick = getTickCount() end 

		local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - buyTick) / 300), 'Linear')

		drawBorder(7, 370, 255, 110, 35, tocolor(2, 254, 83, animation))

		dxDrawText(selectFine ~= 0 and 'Pagar multa' or 'Pagar todas', 370, 255, 110, 35, tocolor(0, 0, 0, animation), 1, getFont('bold', 12), 'center', 'center')



	else



		buyTick = nil 



	end



end



addEventHandler('onClientClick', root, 



	function(b, s)



		if (b == 'left' and s == 'down') then 



			if (isEventHandlerAdded('onClientRender', root, drawFines)) then 



				if (isMouseInPosition(470, 20, 10, 10)) then 



					removeFines()



				elseif (isMouseInPosition(370, 255, 110, 35)) then



					if (selectFine ~= 0) then 



						triggerServerEvent('onPlayerPayFine', resourceRoot, localPlayer, selectFine)

						selectFine = 0

					else

						triggerServerEvent('onPlayerPayFine', resourceRoot, localPlayer, 'all')

					end



				elseif (isMouseInPosition(477, 115, 3, 120)) then 

					

					moving = true



				else



					local line = 0

					for i, v in ipairs(fines) do 

					

						if (i > pages[1] and line < 4) then 

						

							line = (line + 1)

						

							if (isMouseInPosition(20, 115 + (30 * (line - 1)), 457, 30)) then 

							

								selectFine = i



							return end

						

						end

					

					end



				end 





			end



		end



	end



)



addEventHandler('onClientKey', root, 



	function(key, press)



		if (isEventHandlerAdded('onClientRender', root, drawFines) and press) then 



			if (key == 'mouse_wheel_down') then 

			

				if (pages[1] < pages[3]) then 

				

					pages[1] = pages[1] + 1 

					pages[2] = pages[1]

				

				end 

			

			elseif (key == 'mouse_wheel_up') then 

			

				if (pages[1] > 0) then 

				

					pages[1] = pages[1] - 1 

					pages[2] = pages[1]

				

				end 

			

			end



		end



	end



)



addEvent('onClientDrawFines', true)

addEventHandler('onClientDrawFines', root, 



	function(fines_)



		if not (isEventHandlerAdded('onClientRender', root, drawFines)) then 



			parentW, parentH = (500 * screenScale), (310 * screenScale); -- Comprimento e Largura do painel.

			parentX, parentY = ((screenW - parentW) / 2), ((screenH - parentH) / 2); -- Posição X e Y do painel.

			

			tick, interpolate, animation, pages = getTickCount(), {0, 255}, {150, 0}, {0, 0, 0}

			pages, selectFine, fines = {0, 0, 0}, 0, fines_

			

			addEventHandler('onClientRender', root, drawFines)

			showCursor(true)

			showChat(false)



		end 



	end



)



function removeFines()



	if (isEventHandlerAdded('onClientRender', root, drawFines)) then 



		if (interpolate[1] == 0) then 



			tick, interpolate, animation = getTickCount(), {255, 0}, {0, 150}



			showCursor(false)

			setTimer(function()

			

				removeEventHandler('onClientRender', root, drawFines)

				showChat(true)



			end, 150, 1)



		end



	end



end

bindKey('backspace', 'down', removeFines)



addEvent('onClientReceiveFines', true)

addEventHandler('onClientReceiveFines', root,



	function(fines_)



		fines = fines_



	end



)



function timerFormatCounter(milissegundos)

    local segundos = math.floor(milissegundos / 1000)

    local minutos = math.floor(segundos / 60)

    local horas = math.floor(minutos / 60)



    local segundosRestantes = segundos % 60

    local minutosRestantes = minutos % 60



    return string.format("%02d:%02d:%02d", horas, minutosRestantes, segundosRestantes)

end