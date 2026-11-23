--[[

    --» sᴄʀɪᴘᴛ ғᴇɪᴛᴏ ᴘᴏʀ » Pedro Developer

--]]





local screenW, screenH = guiGetScreenSize();

local screenScale = math.min(math.max(screenH / 768, 0.70), 2); -- Caso o painel seja muito grande, retirar o limite e deixar apenas o (screenH / 768).



parentW, parentH = (760 * screenScale), (520 * screenScale); -- Comprimento e Largura do painel.

parentX, parentY = ((screenW - parentW) / 2), ((screenH - parentH) / 2); -- Posição X e Y do painel.



------------------------------------------------

function respX (x)

    return math.floor(parentX + (x * screenScale));

end

    

function respY (y)

    return math.floor(parentY + (y * screenScale));

end

    

function respC (scale)

    return math.floor(scale * screenScale);

end



local _dxDrawText = dxDrawText;

function dxDrawText(text, x, y, width, height, ...)

    return _dxDrawText(text, respX(x), respY(y+(animationY or 0)), (respX(x) + respC(width)), (respY(y+(animationY or 0)) + respC(height)), ...);

end



local _dxDrawRectangle = dxDrawRectangle;

function dxDrawRectangle(x, y, width, height, ...)

    return _dxDrawRectangle(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);

end



local _dxDrawImage = dxDrawImage;

function dxDrawImage(x, y, width, height, ...)

    return _dxDrawImage(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);

end



local _dxDrawImageSection = dxDrawImageSection;

function dxDrawImageSection(x, y, width, height, ...)

    return _dxDrawImageSection(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);

end



local cursor = {}

function isMouseInPosition (x, y, width, height)

    if (not cursor.state) then

        return false

    end

    if not (cursor.x and cursor.y) then

        return false;

    end

    x, y, width, height = respX(x), respY(y), respC(width), respC(height);

    return ((cursor.x >= x and cursor.x <= x + width) and (cursor.y >= y and cursor.y <= y + height));

end



size = {}

function drawBorder ( radius, x, y, width, height, color, colorStroke, sizeStroke, postGUI )



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



function isEventHandlerAdded( sEventName, pElementAttachedTo, func )

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



local naipes = {



	'paus';

	'ouros';

	'copas';

	'espadas';



}



local cards = {



	'1';

	'2';

	'3';

	'4';

	'5';

	'6';

	'7';

	'8';

	'9';

	'10';

	'j';

	'q';

	'k';



}



local cardEffects = {}

local cardsValues = {



	['1'] = 1;

	['2'] = 2;

	['3'] = 3;

	['4'] = 4;

	['5'] = 5;

	['6'] = 6;

	['7'] = 7;

	['8'] = 8;

	['9'] = 9;

	['10'] = 10;

	['j'] = 10;

	['q'] = 10;

	['k'] = 10;



}



local numbers = {

    { number = 0, color = 'white' },

    { number = 1, color = 'green' },

    { number = 10, color = 'gray' },

    { number = 3, color = 'green' },

    { number = 11, color = 'gray' },

    { number = 4, color = 'green' },

    { number = 12, color = 'gray' },

    { number = 5, color = 'green' },

    { number = 13, color = 'gray' },

    { number = 6, color = 'green' },

    { number = 14, color = 'gray' },

    { number = 7, color = 'green' },

    { number = 8, color = 'green' },

    { number = 9, color = 'gray' },

    { number = 15, color = 'gray' },

    { number = 2, color = 'green' },

    { number = 16, color = 'gray' },

}



local slotMinesCache = {}

local mineSlots = {



    {440, 125, 60, 60};

    {515, 125, 60, 60};

    {590, 125, 60, 60};

    {665, 125, 60, 60};



	{440, 200, 60, 60};

    {515, 200, 60, 60};

    {590, 200, 60, 60};

    {665, 200, 60, 60};



	{440, 275, 60, 60};

    {515, 275, 60, 60};

    {590, 275, 60, 60};

    {665, 275, 60, 60};



	{440, 350, 60, 60};

    {515, 350, 60, 60};

    {590, 350, 60, 60};

    {665, 350, 60, 60};



}



-- // CAVALOS 

local horses = {



	'Coração de Ferro';

	'Estrela Cadente';

	'Lobo Solitário';

	'Serpente Astuta';

	'Espada Flamejante';

    

}



local leaderboard = {



    3;

    5;

    1;

    2;

    4;



}



local aditionPos = {}

local horseColors = {



    {70, 117, 223};

    {209, 76, 77};

    {183, 143, 74};

    {152, 97, 190};

    {56, 178, 136};



}



local ordemHorses = {

	3;

	1;

	2;

	4;

	5;

}

-- // CAVALOS 



-- // FORTUNE TIGER



tigerBet = 1

lastTigerWin = 0

tigerBetPages = 0



-- // FORTUNE TIGER 



local lastSpins = {}

local effects = {}

local crashRegister = {}

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



function drawCassino()



	cursor.state = isCursorShowing ();

    if (cursor.state) then



        local cursorX, cursorY = getCursorPosition ();

        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;



    end 



	local alpha = interpolateBetween(interpolate[1], 0, 0, interpolate[2], 0, 0, ((getTickCount() - tick) / 150), 'Linear')

	animationY = interpolateBetween(animation[1], 0, 0, animation[2], 0, 0, ((getTickCount() - tick)/ 150), 'InOutQuad')



	dxDrawImage(0, 0, 760, 520, 'assets/images/bg.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawImage(20, 20, 21, 17, 'assets/images/title.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText('GoBet', 51, 20, 37, 16, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 13))

	dxDrawImage(112, 16, 112, 25, 'assets/images/arrow.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



	dxDrawText('#636363Fichas: #FFFFFF'..formatNumber((getElementData(localPlayer, 'cassino.balance') or 0), '.'), 516, 18, 62, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right', 'top', false, false, false, true)

	dxDrawRectangle(603, 18, 1, 15, tocolor(255, 255, 255, alpha * 0.07))



	drawBorder(5, 619, 10, 90, 31, tocolor(255, 255, 255, alpha * 0.03))

	dxDrawText('Sacar', 619, 10, 90, 31, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')



	if (isMouseInPosition(619, 10, 90, 31)) then 



		if not (withdrawTick) then withdrawTick = getTickCount() end 

		local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - withdrawTick) / 300), 'Linear')



		drawBorder(5, 619, 10, 90, 31, tocolor(96, 191, 76, animation))

		dxDrawText('Sacar', 619, 10, 90, 31, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')



	else 



		withdrawTick = nil 



	end



	dxDrawImage(729, 20, 11, 11, 'assets/images/exit.png', 0, 0, 0, tocolor(64, 64, 64, alpha))



	if (isMouseInPosition(729, 20, 11, 11)) then 



		if not (exitTick) then exitTick = getTickCount() end 

		local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - exitTick) / 300), 'Linear')

		dxDrawImage(729, 20, 11, 11, 'assets/images/exit.png', 0, 0, 0, tocolor(96, 191, 76, animation))



	else



		exitTick = nil 



	end



	dxDrawRectangle(20, 53, 720, 1, tocolor(255, 255, 255, alpha * 0.04))



	if (gameSelect == 'double') then 



		drawBorder(10, 20, 70, 190, 430, tocolor(255, 255, 255, alpha * 0.02))



		dxDrawImage(35, 85, 25, 25, 'assets/images/double/infos/green.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Vitória x2', 72, 90, 50, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Sua aposta:', 35, 121, 61, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(formatNumber((myBets['green'] or 0), '.'), 142, 121, 53, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12), 'right')

		dxDrawText('#636363E mais #FFFFFF'..randomBets[1]..' apostas', 35, 151, 90, 14, tocolor(255, 255, 255, alpha), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)

		dxDrawRectangle(35, 190, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 245, 25, 25, 'assets/images/double/infos/gray.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Vitória x14', 72, 410, 50, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Sua aposta:', 35, 281, 61, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(formatNumber((myBets['gray'] or 0), '.'), 142, 281, 53, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12), 'right')

		dxDrawText('#636363E mais #FFFFFF'..randomBets[2]..' apostas', 35, 311, 90, 14, tocolor(255, 255, 255, alpha), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)

		dxDrawRectangle(35, 350, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 405, 25, 25, 'assets/images/double/infos/white.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Vitória x2', 72, 250, 50, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Sua aposta:', 35, 441, 61, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(formatNumber((myBets['white'] or 0), '.'), 142, 441, 53, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12), 'right')

		dxDrawText('#636363E mais #FFFFFF'..randomBets[3]..' apostas', 35, 471, 90, 14, tocolor(255, 255, 255, alpha), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawText('R$'..formatNumber(getPlayerMoney(localPlayer), '.'), 230, 386, 52, 16, tocolor(255, 255, 255, alpha), 1, getFont('bold', 13))

		dxDrawText('Minha carteira', 230, 404, 52, 16, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText('Selecionar cor', 230, 436, 52, 16, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12))



		drawBorder(5, 230, 460, 80, 40, (isMouseInPosition(230, 460, 80, 40) or selectColor == 'green') and tocolor(96, 191, 76, alpha) or tocolor(96, 191, 76, alpha * 0.5))

		dxDrawText('x2', 230, 460, 80, 40, (isMouseInPosition(230, 460, 80, 40) or selectColor == 'green') and tocolor(255, 255, 255, alpha) or tocolor(255, 255, 255, alpha * 0.5), 1, getFont('medium', 12), 'center', 'center')



		drawBorder(5, 320, 460, 80, 40, (isMouseInPosition(320, 460, 80, 40) or selectColor == 'white') and tocolor(242, 242, 242, alpha) or tocolor(242, 242, 242, alpha * 0.5))

		dxDrawText('x14', 320, 460, 80, 40, tocolor(96, 191, 76, alpha), 1, getFont('medium', 12), 'center', 'center')



		drawBorder(5, 410, 460, 80, 40, (isMouseInPosition(410, 460, 80, 40) or selectColor == 'gray') and tocolor(255, 255, 255, alpha * 0.06) or tocolor(255, 255, 255, alpha * 0.03))

		dxDrawText('x2', 410, 460, 80, 40, (isMouseInPosition(410, 460, 80, 40) or selectColor == 'gray') and tocolor(255, 255, 255, alpha) or tocolor(255, 255, 255, alpha * 0.5), 1, getFont('medium', 12), 'center', 'center')



		drawBorder(5, 400, 385, 90, 35, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawText('Depositar', 400, 385, 90, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(400, 385, 90, 35)) then 



			if not (depositTick) then depositTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - depositTick) / 300), 'Linear')



			drawBorder(5, 400, 385, 90, 35, tocolor(96, 191, 76, animation))

			dxDrawText('Depositar', 400, 385, 90, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')



		else 



			depositTick = nil 



		end



		dxDrawText('Insira a quantidade', 510, 382, 52, 16, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12))



		drawBorder(8, 510, 406, 230, 40, tocolor(255, 255, 255, alpha * 0.02))

		dxDrawText(selectEdit == 1 and guiGetText(amountEdit)..'|' or guiGetText(amountEdit), 525, 419, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12))

		dxDrawText('Fichas', 690, 419, 35, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('sbold', 12), 'right')



		drawBorder(8, 510, 460, 230, 40, tocolor(96, 191, 76, alpha * 0.4))

		dxDrawText('Iniciar aposta', 510, 460, 230, 40, tocolor(96, 191, 76, alpha), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(510, 460, 230, 40)) then 

		

			if not (gameButtonTick) then gameButtonTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - gameButtonTick) / 300), 'Linear')

		

			drawBorder(8, 510, 460, 230, 40, tocolor(96, 191, 76, animation))

			dxDrawText('Iniciar aposta', 510, 460, 230, 40, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')

		

		else 

		

			gameButtonTick = nil 

		

		end



		dxDrawImage(230, 70, 510, 300, 'assets/images/double/rectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Double', 245, 85, 42, 16, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 13))

		dxDrawImage(684, 85, 41, 12, 'assets/images/double/x.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawRectangle(230, 113, 510, 1, tocolor(255, 255, 255, alpha * 0.04))



		drawBorder(6, 245, 129, 480, 35, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawImage(260, 137, 19, 19, 'assets/images/double/clock.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText(spinning and 'Girando roleta' or '#636363Girando em: #FFFFFF'..(isTimer(startSpinDouble) and convertDoubleTime(getTimerDetails(startSpinDouble)) or '0'), 408, 140, 95, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12), 'center', 'center', false, false, false, true)



		dxDrawRectangle(230, 184, 510, 90, tocolor(255, 255, 255, alpha * 0.02))

		dxDrawImage(230, 170, 510, 118, doubleRender, 0, 0, 0, tocolor(255, 255, 255, alpha))



		if (spinning) then 



			updateDoubleRender()



		end 



		dxDrawText('Giros anteriores', 245, 285, 91, 16, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 13))

		dxDrawRectangle(230, 313, 510, 1, tocolor(255, 255, 255, alpha * 0.04))



		dxDrawImage(700, 326, 30, 30, 'assets/images/double/lastSpins.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



		for i, v in ipairs(table.reverse(lastSpins)) do 



			if (i <= 11) then 



				if (v.color == 'green') then 



					drawBorder(6, 660 - (40 * (i - 1)), 326, 30, 30, tocolor(96, 191, 76, alpha))

					dxDrawText(v.number, 660 - (40 * (i - 1)), 326, 30, 30, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12), 'center', 'center')



				elseif (v.color == 'gray') then 



					drawBorder(6, 660 - (40 * (i - 1)), 326, 30, 30, tocolor(255, 255, 255, alpha * 0.03))

					dxDrawText(v.number, 660 - (40 * (i - 1)), 326, 30, 30, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12), 'center', 'center')



				else 



					dxDrawImage(660 - (40 * (i - 1)), 326, 30, 30, 'assets/images/double/white2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



				end



			end 



		end 



	elseif (gameSelect == 'mines') then 



		drawBorder(10, 20, 70, 190, 430, tocolor(255, 255, 255, alpha * 0.02))

		

		dxDrawImage(35, 85, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 1º', 72, 90, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 121, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[1] and formatNumber(rankCache[1].amount, '.') or '???', 161, 121, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[1] and rankCache[1].name or '???', 35, 151, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawRectangle(35, 190, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 245, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 2º', 72, 250, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 281, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[2] and formatNumber(rankCache[2].amount, '.') or '???', 161, 281, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[2] and rankCache[2].name or '???', 35, 311, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawRectangle(35, 350, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 405, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 3º', 72, 410, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 441, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[3] and formatNumber(rankCache[3].amount, '.') or '???', 161, 441, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[3] and rankCache[3].name or '???', 35, 471, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawText('R$'..formatNumber(getPlayerMoney(localPlayer), '.'), 440, 448, 52, 16, tocolor(255, 255, 255, alpha), 1, getFont('bold', 13))

		dxDrawText('Minha carteira', 440, 466, 52, 16, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))



		drawBorder(5, 635, 447, 90, 35, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawText('Depositar', 635, 447, 90, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(635, 447, 90, 35)) then 



			if not (depositTick) then depositTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - depositTick) / 300), 'Linear')



			drawBorder(5, 635, 447, 90, 35, tocolor(96, 191, 76, animation))

			dxDrawText('Depositar', 635, 447, 90, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')



		else 



			depositTick = nil 



		end



		dxDrawImage(230, 70, 510, 430, 'assets/images/mines/rectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawImage(684, 85, 41, 12, 'assets/images/double/x.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Mines', 245, 85, 35, 16, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 13))

		dxDrawRectangle(230, 113, 510, 1, tocolor(255, 255, 255, alpha * 0.04))



		drawBorder(8, 245, 318, 175, 40, tocolor(255, 255, 255, alpha * 0.02))

		dxDrawText(selectEdit == 1 and guiGetText(amountEdit)..'|' or guiGetText(amountEdit), 260, 331, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12))

		dxDrawText('Fichas', 370, 331, 35, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('sbold', 12), 'right')



        if (playingMines) then 



			drawBorder(8, 245, 370, 175, 40, tocolor(96, 191, 76, alpha * 0.4))

			dxDrawText('Resgatar '..formatNumber(betValue, '.')..',00', 245, 370, 175, 40, tocolor(96, 191, 76, alpha), 1, getFont('bold', 12), 'center', 'center')

	

			if (isMouseInPosition(245, 370, 175, 40)) then 

			

				if not (gameButtonTick) then gameButtonTick = getTickCount() end 

				local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - gameButtonTick) / 300), 'Linear')

			

				drawBorder(8, 245, 370, 175, 40, tocolor(96, 191, 76, animation))

				dxDrawText('Resgatar '..formatNumber(betValue, '.')..',00', 245, 370, 175, 40, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')

			

			else 

			

				gameButtonTick = nil 

			

			end



		else



			drawBorder(8, 245, 370, 175, 40, tocolor(96, 191, 76, alpha * 0.4))

			dxDrawText('Iniciar aposta', 245, 370, 175, 40, tocolor(96, 191, 76, alpha), 1, getFont('bold', 12), 'center', 'center')

	

			if (isMouseInPosition(245, 370, 175, 40)) then 

			

				if not (gameButtonTick) then gameButtonTick = getTickCount() end 

				local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - gameButtonTick) / 300), 'Linear')

			

				drawBorder(8, 245, 370, 175, 40, tocolor(96, 191, 76, animation))

				dxDrawText('Iniciar aposta', 245, 370, 175, 40, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')

			

			else 

			

				gameButtonTick = nil 

			

			end



		end



		dxDrawText('Número de minas', 245, 125, 91, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12))



		for i, v in ipairs(config.mines) do 



			drawBorder(8, 245, 145 + (43 * (i - 1)), 175, 40, tocolor(255, 255, 255, alpha * 0.02))



			if (isMouseInPosition(245, 145 + (43 * (i - 1)), 175, 40) or minesNumber == v) then 

			

				dxDrawText(v, 260, 158 + (43 * (i - 1)), 8, 14, tocolor(96, 191, 76, alpha), 1, getFont('regular', 12))

				dxDrawText('Minas', 373, 158 + (43 * (i - 1)), 32, 14, tocolor(96, 191, 76, alpha), 1, getFont('sbold', 12), 'right')



			else



				dxDrawText(v, 260, 158 + (43 * (i - 1)), 8, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12))

				dxDrawText('Minas', 373, 158 + (43 * (i - 1)), 32, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('sbold', 12), 'right')



			end



		end



		dxDrawImage(503, 142, 160, 250, 'assets/images/mines/logoWhite.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.1))



		for i, v in ipairs(mineSlots) do 



			if (slotMinesCache[i]) then 

	

				dxDrawImage(v[1], v[2], v[3], v[4], 'assets/images/mines/'..slotMinesCache[i]..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	

			else

				

				drawBorder(10, v[1], v[2], v[3], v[4], tocolor(255, 255, 255, alpha * 0.02))

			

			end 

	

		end



	elseif (gameSelect == 'blackjack') then 



		drawBorder(10, 20, 70, 190, 430, tocolor(255, 255, 255, alpha * 0.02))



		dxDrawImage(35, 85, 25, 25, 'assets/images/blackjack/green.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Lucro', 72, 90, 31, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Meu lucro', 35, 121, 51, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(formatNumber(profitBlackjack, '.'), 154, 121, 41, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')



		dxDrawImage(35, 165, 25, 25, 'assets/images/blackjack/green.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Apostado', 72, 170, 31, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Aposta', 35, 201, 51, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(formatNumber(valueTotalBets, '.'), 154, 201, 41, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')



		dxDrawRectangle(35, 245, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 305, 25, 25, 'assets/images/blackjack/white.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Vitórias', 72, 310, 31, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Vitórias', 35, 341, 51, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(formatNumber(victorys, '.'), 154, 341, 41, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')



		dxDrawImage(35, 385, 25, 25, 'assets/images/blackjack/white.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Derrotas', 72, 390, 31, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Derrotas', 35, 421, 51, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(formatNumber(fails, '.'), 154, 421, 41, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')



		

		dxDrawText('R$'..formatNumber(getPlayerMoney(localPlayer), '.'), 230, 440, 52, 16, tocolor(255, 255, 255, alpha), 1, getFont('bold', 13))

		dxDrawText('Minha carteira', 230, 458, 52, 16, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))



		drawBorder(5, 375, 439, 90, 35, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawText('Depositar', 375, 439, 90, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(375, 439, 90, 35)) then 



			if not (depositTick) then depositTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - depositTick) / 300), 'Linear')



			drawBorder(5, 375, 439, 90, 35, tocolor(96, 191, 76, animation))

			dxDrawText('Depositar', 375, 439, 90, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')



		else 



			depositTick = nil 



		end



		dxDrawText('Insira a quantidade', 230, 355, 98, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12))

		drawBorder(8, 230, 379, 235, 40, tocolor(255, 255, 255, alpha * 0.02))

		dxDrawText(selectEdit == 1 and guiGetText(amountEdit)..'|' or guiGetText(amountEdit), 245, 392, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12))

		dxDrawText('Fichas', 415, 392, 35, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('sbold', 12), 'right')



		drawBorder(8, 480, 379, 260, 40, tocolor(96, 191, 76, alpha * 0.4))

		dxDrawText('Iniciar aposta', 480, 379, 260, 40, tocolor(96, 191, 76, alpha), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(480, 379, 260, 40)) then 

		

			if not (gameButtonTick) then gameButtonTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - gameButtonTick) / 300), 'Linear')

		

			drawBorder(8, 480, 379, 260, 40, tocolor(96, 191, 76, animation))

			dxDrawText('Iniciar aposta', 480, 379, 260, 40, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')

		

		else 

		

			gameButtonTick = nil 

		

		end 



		dxDrawImage(230, 75, 120, 190, 'assets/images/blackjack/cardsStroke.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawImage(620, 75, 120, 190, 'assets/images/blackjack/cardsStroke.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



		myCardsTotal = 0

		cassinoCardsTotal = 0



		for i, v in ipairs(myCards) do 



			if not (cardEffects[i]) then 



				cardEffects[i] = getTickCount()



			end 



			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - cardEffects[i]) / 500), 'Linear')



			dxDrawImage(240 + (15 * (i - 1)), 75, 120, 190, 'assets/images/blackjack/cards/'..v.naipe..'/'..v.card..'.png', 0, 0, 0, tocolor(255, 255, 255, animation))

			myCardsTotal = myCardsTotal + v.value 



		end 



		for i, v in ipairs(cassinoCards) do 



			if not (cardEffects[i..' CASSINO']) then 



				cardEffects[i..' CASSINO'] = getTickCount()



			end 



			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - cardEffects[i..' CASSINO']) / 500), 'Linear')



			dxDrawImage(610 - (15 * (i - 1)), 75, 120, 190, 'assets/images/blackjack/cards/'..v.naipe..'/'..v.card..'.png', 0, 0, 0, tocolor(255, 255, 255, animation))

			cassinoCardsTotal = cassinoCardsTotal + v.value 



		end 



		dxDrawImage(230, 280, 21, 17, 'assets/images/blackjack/title.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Minhas cartas', 261, 280, 30, 16, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 13))

		dxDrawText('Total', 230, 310, 25, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12))

		drawBorder(12, 267, 305, 60, 25, tocolor(242, 242, 242, alpha))

		dxDrawText(myCardsTotal, 267, 305, 60, 25, tocolor(0, 0, 0, alpha * 0.9), 1, getFont('bold', 12), 'center', 'center')



		dxDrawImage(719, 280, 21, 17, 'assets/images/blackjack/title.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Casa', 628, 280, 81, 16, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 13), 'right')

		dxDrawText('Total', 715, 310, 25, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		drawBorder(12, 643, 305, 60, 25, tocolor(242, 242, 242, alpha))

		dxDrawText(cassinoCardsTotal, 643, 305, 60, 25, tocolor(0, 0, 0, alpha * 0.9), 1, getFont('bold', 12), 'center', 'center')



		if (playingBlackjack) then 



			if not (stopedPlay) then 



				drawBorder(5, 370, 295, 100, 35, tocolor(255, 255, 255, alpha * 0.03))

				dxDrawText('Permanecer', 370, 295, 100, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')

				

				if (isMouseInPosition(370, 295, 100, 35)) then 

				

					if not (blackjackButtonTick) then blackjackButtonTick = getTickCount() end 

					local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - blackjackButtonTick) / 300), 'Linear')

				

					drawBorder(5, 370, 295, 100, 35, tocolor(96, 191, 76, animation))

					dxDrawText('Permanecer', 370, 295, 100, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')

				

				else 

				

					blackjackButtonTick = nil 

				

				end



				drawBorder(5, 480, 295, 120, 35, tocolor(255, 255, 255, alpha * 0.03))

				dxDrawText('Adicionar carta', 480, 295, 120, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')

			

				if (isMouseInPosition(480, 295, 120, 35)) then 

				

					if not (blackjackButtonTick2) then blackjackButtonTick2 = getTickCount() end 

					local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - blackjackButtonTick2) / 300), 'Linear')

				

					drawBorder(5, 480, 295, 120, 35, tocolor(96, 191, 76, animation))

					dxDrawText('Adicionar carta', 480, 295, 120, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')

				

				else 

				

					blackjackButtonTick2 = nil 

				

				end



				if (myCardsTotal > 21) then 



					playingBlackjack = false 

					config.notifyC('Você estourou a sua mão e perdeu a aposta.', 'error')

					playSound('assets/sounds/perdeu.mp3')

					fails = fails + 1



				elseif (myCardsTotal == 21) then



					stopedPlay = true 

					verifyBlackjackCards()



				end



			else 



				if (cassinoCardsTotal > 21) then 



					playingBlackjack = false 

					triggerServerEvent('onPlayerRequestOthersPermissionsToInteractionTimer', resourceRoot, localPlayer)

					config.notifyC('A casa estourou a mão e você ganhou.', 'error')

					playSound('assets/sounds/ganhou.mp3')

					victorys = victorys + 1

					profitBlackjack = profitBlackjack + (betValueBlackjack * 2)



				elseif (cassinoCardsTotal == 21) then 



					playingBlackjack = false 

					config.notifyC('A casa fez 21, e você perdeu.', 'error')

					playSound('assets/sounds/perdeu.mp3')

					fails = fails + 1



				elseif (cassinoCardsTotal == myCardsTotal) then 



					playingBlackjack = false

					config.notifyC('A casa empatou com você.', 'error')

					playSound('assets/sounds/empate.mp3')

					triggerServerEvent('onPlayerRequestOthersPermissionsToInteractionTimer', resourceRoot, localPlayer, true)



				elseif (cassinoCardsTotal > myCardsTotal) then 

	

					playingBlackjack = false 

					config.notifyC('A casa teve uma mão melhor que a sua e ela ganhou.', 'error')

					playSound('assets/sounds/perdeu.mp3')

					fails = fails + 1



				end



			end



		end

		

	elseif (gameSelect == 'crash') then 



		drawBorder(10, 20, 70, 190, 430, tocolor(255, 255, 255, alpha * 0.02))

		

		dxDrawImage(35, 85, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 1º', 72, 90, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 121, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[1] and formatNumber(rankCache[1].amount, '.') or '???', 161, 121, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[1] and rankCache[1].name or '???', 35, 151, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawRectangle(35, 190, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 245, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 2º', 72, 250, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 281, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[2] and formatNumber(rankCache[2].amount, '.') or '???', 161, 281, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[2] and rankCache[2].name or '???', 35, 311, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawRectangle(35, 350, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 405, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 3º', 72, 410, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 441, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[3] and formatNumber(rankCache[3].amount, '.') or '???', 161, 441, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[3] and rankCache[3].name or '???', 35, 471, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawText('R$'..formatNumber(getPlayerMoney(localPlayer), '.'), 230, 386, 52, 16, tocolor(255, 255, 255, alpha), 1, getFont('bold', 13))

		dxDrawText('Minha carteira', 230, 404, 52, 16, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))



		drawBorder(5, 400, 385, 90, 35, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawText('Depositar', 400, 385, 90, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(400, 385, 90, 35)) then 



			if not (depositTick) then depositTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - depositTick) / 300), 'Linear')



			drawBorder(5, 400, 385, 90, 35, tocolor(96, 191, 76, animation))

			dxDrawText('Depositar', 400, 385, 90, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')



		else 



			depositTick = nil 



		end



		dxDrawText('Insira a quantidade', 510, 382, 98, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12))

		drawBorder(8, 510, 406, 230, 40, tocolor(255, 255, 255, alpha * 0.02))

		dxDrawText(selectEdit == 1 and guiGetText(amountEdit)..'|' or guiGetText(amountEdit), 525, 419, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12))

		dxDrawText('Fichas', 690, 419, 35, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('sbold', 12), 'right')



		drawBorder(8, 510, 460, 230, 40, tocolor(96, 191, 76, alpha * 0.4))

		dxDrawText(subindostate and 'Retirar R$ '..formatNumber(math.floor(valoraposta * subindo), '.') or 'Iniciar aposta', 510, 460, 230, 40, tocolor(96, 191, 76, alpha), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(510, 460, 230, 40)) then 

		

			if not (gameButtonTick) then gameButtonTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - gameButtonTick) / 300), 'Linear')

		

			drawBorder(8, 510, 460, 230, 40, tocolor(96, 191, 76, animation))

			dxDrawText(subindostate and 'Retirar R$ '..formatNumber(math.floor(valoraposta * subindo), '.') or 'Iniciar aposta', 510, 460, 230, 40, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')

		

		else 

		

			gameButtonTick = nil 

		

		end



		dxDrawText('Auto retirar', 230, 436, 58, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12))

		drawBorder(8, 230, 460, 260, 40, tocolor(255, 255, 255, alpha * 0.02))

		dxDrawText(selectEdit == 2 and guiGetText(autoStopEdit)..'|' or guiGetText(autoStopEdit), 245, 473, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12))

		dxDrawImage(455, 470, 20, 20, 'assets/images/clearEdit.png', 0, 0, 0, (isMouseInPosition(455, 470, 20, 20) and tocolor(96, 191, 76, alpha) or tocolor(255, 255, 255, alpha * 0.2)))



		if (subindostate and tonumber(guiGetText(autoStopEdit)) and tonumber(guiGetText(autoStopEdit)) > 0) then 



			if (subindo >= tonumber(guiGetText(autoStopEdit))) then 



				if not crashou and not retirou then



					playSound('assets/sounds/success.mp3')

					retirou = true

					triggerServerEvent('onServerEmploymentSimulated', resourceRoot, localPlayer, tonumber(math.floor(valoraposta * subindo)), sha256('BMR_SECURITY_HAHAKKK_RandomWord1_BMR_RandomWord2_SECURITY_HAHAKKK_RandomWord3_BMR_SECURITY_RandomWord4_HAHAKKK_RandomWord5'), 'BMR_SECURITY_HAHAKKK_')

					config.notifyC('Você retirou '..formatNumber(math.floor(valoraposta * subindo), '.'), 'info')



				end



			end 



		end 



		dxDrawImage(230, 70, 510, 300, 'assets/images/crash/rectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Crash', 245, 85, 35, 16, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 13))

		dxDrawImage(684, 85, 41, 12, 'assets/images/double/x.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawRectangle(245, 129, 480, 1, tocolor(255, 255, 255, alpha *  0.05))

		dxDrawRectangle(245, 165, 480, 1, tocolor(255, 255, 255, alpha *  0.05))

		dxDrawRectangle(245, 201, 480, 1, tocolor(255, 255, 255, alpha *  0.05))

		dxDrawRectangle(245, 237, 480, 1, tocolor(255, 255, 255, alpha *  0.05))



		dxDrawText('0s', 245, 253, 14, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText('2s', 401, 253, 14, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText('4s', 556, 253, 14, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText('6s', 712, 253, 14, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))



		dxDrawText('Anteriores', 245, 285, 60, 16, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 13))

		dxDrawRectangle(230, 313, 510, 1, tocolor(255, 255, 255, alpha * 0.04))

		dxDrawImage(700, 326, 30, 30, 'assets/images/double/lastSpins.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



        for i, v in ipairs(table.reverse(crashRegister)) do 



            if (i < 7) then 



                local c = tocolor(255, 255, 255, alpha)

                local c2 = tocolor(255, 255, 255, alpha)



                if v > 2 then



                    c = tocolor(96, 191, 76, alpha)

                    c2 = tocolor(255, 255, 255, alpha)



                else



                    c = tocolor(255, 255, 255, alpha * 0.03)

                    c2 = tocolor(255, 255, 255, alpha * 0.4)



                end



				drawBorder(6, 640 - (60 * (i - 1)), 326, 50, 30, c)

				dxDrawText(v..'x', 640 - (60 * (i - 1)), 326, 50, 30, c2, 1, getFont('sbold', 11), 'center', 'center')



            end



        end

            

        if subindo then

            if not secondssub then



				secondssub = math.random(1, 6)

				timing = (secondssub * 8) * 1000

				if secondssub > 3 then

					secondssub = math.random(1, 6)

					timing = (secondssub * 8) * 1000

					if secondssub > 3 then

						secondssub = math.random(1, 6)

						timing = (secondssub * 8) * 1000

					end

				end

				subindostate = true

				if isTimer(timingcrashar) then

					killTimer(timingcrashar)

				end

				timingcrashar = setTimer(function()

					crashou = true

					playSound('assets/sounds/explosao.mp3')

				end, secondssub * 1000, 1)

				ticksub = getTickCount()



            end

            if retirou then

                subindo = sub

                subindostate = false

                if isTimer(timingcrashar) then

                    killTimer(timingcrashar)

                end

			

            elseif crashou then

                subindo = sub

                subindostate = false

                if isTimer(timingcrashar) then

                    killTimer(timingcrashar)

                end                    

            else

                subindo = interpolateBetween(0, 0, 0, secondssub, 0, 0, ((getTickCount()-ticksub)/timing), 'Linear')

            end

            sub = subindo

            local w, h = 163 * (subindo < 1 and subindo or 1), 96 * (subindo < 1 and subindo or 1)

            dxDrawImage(245, 142+96-h, w, h, 'assets/images/crash/line.png', 0, 0, 0, tocolor(255, 255, 255, 255))

            dxDrawImage(245 - 10+w, 220+5-h, 28, 24, 'assets/images/crash/plane.png', 0, 0, 0, tocolor(255, 255, 255, 255))

            subindo = subindo + 1

            if retirou then

				

				dxDrawText(math.round(subindo, 2)..'X', 469, 285, 33, 16, tocolor(96, 191, 76, alpha), 1, getFont('sbold', 13), 'center')

			

                if not (insertOnRegisterCrash) then 

				

                    insertOnRegisterCrash = true 

                    table.insert(crashRegister, math.round(subindo, 2))

				

                end

			

            elseif crashou then



				dxDrawText(math.round(subindo, 2)..'X', 469, 285, 33, 16, tocolor(255, 74, 74, alpha), 1, getFont('sbold', 13), 'center')

			

                if not (insertOnRegisterCrash) then 

				

                    insertOnRegisterCrash = true 

                    table.insert(crashRegister, math.round(subindo, 2))

				

                end 

			

            else

			

				dxDrawText(math.round(subindo, 2)..'X', 469, 285, 33, 16, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 13), 'center')

			

            end



        end



	elseif (gameSelect == 'horse') then 



		drawBorder(10, 20, 70, 190, 430, tocolor(255, 255, 255, alpha * 0.02))

		

		dxDrawImage(35, 85, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 1º', 72, 90, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 121, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[1] and formatNumber(rankCache[1].amount, '.') or '???', 161, 121, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[1] and rankCache[1].name or '???', 35, 151, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawRectangle(35, 190, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 245, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 2º', 72, 250, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 281, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[2] and formatNumber(rankCache[2].amount, '.') or '???', 161, 281, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[2] and rankCache[2].name or '???', 35, 311, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawRectangle(35, 350, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 405, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 3º', 72, 410, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 441, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[3] and formatNumber(rankCache[3].amount, '.') or '???', 161, 441, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[3] and rankCache[3].name or '???', 35, 471, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawText('R$'..formatNumber(getPlayerMoney(localPlayer), '.'), 230 + 100, 440 + 25, 52, 16, tocolor(255, 255, 255, alpha), 1, getFont('bold', 13))

		dxDrawText('Minha carteira', 230 + 100, 458 + 25, 52, 16, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))



		drawBorder(5, 445, 465, 90, 35, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawText('Depositar', 445, 465, 90, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(445, 465, 90, 35)) then 



			if not (depositTick) then depositTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - depositTick) / 300), 'Linear')



			drawBorder(5, 445, 465, 90, 35, tocolor(96, 191, 76, animation))

			dxDrawText('Depositar', 445, 465, 90, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')



		else 



			depositTick = nil 



		end



		drawBorder(5, 540, 465, 90, 35, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawText('Apostar', 540, 465, 90, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(540, 465, 90, 35)) then 



			if not (betTick) then betTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - betTick) / 300), 'Linear')



			drawBorder(5, 540, 465, 90, 35, tocolor(96, 191, 76, animation))

			dxDrawText('Apostar', 540, 465, 90, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')



		else 



			betTick = nil 



		end



		dxDrawRectangle(228, 70, 512, 30, tocolor(96, 191, 76, alpha))

		dxDrawImage(454, 78, 18, 14, 'assets/images/horse/title.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('HorseBet', 479, 78, 50, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawRectangle(228, 100, 512, 350, tocolor(255, 255, 255, alpha * 0.02))



		if (horseWindow == 1) then 



			for i, v in ipairs(horses) do 

				

				dxDrawImage(344, 117 + (50 * (i - 1)), 40, 40, 'assets/images/icons/'..i..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



				if (horseSelect == i) then 

					

					dxDrawImage(394, 117 + (50 * (i - 1)), 230, 40, 'assets/images/horse/rectangleEffect.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

					drawBorder(13, 535, 124 + (50 * (i - 1)), 75, 26, tocolor(horseColors[i][1], horseColors[i][2], horseColors[i][3], alpha))

					dxDrawText('Selecionado', 535, 124 + (50 * (i - 1)), 75, 26, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 11), 'center', 'center')



				elseif (isMouseInPosition(394, 117 + (50 * (i - 1)), 230, 40)) then 



					dxDrawImage(394, 117 + (50 * (i - 1)), 230, 40, 'assets/images/horse/rectangleEffect.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

					drawBorder(20, 583, 124 + (50 * (i - 1)), 26, 26, tocolor(horseColors[i][1], horseColors[i][2], horseColors[i][3], alpha))

					dxDrawText(i, 583, 124 + (50 * (i - 1)), 26, 26, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11), 'center', 'center')



				else

					

					dxDrawImage(394, 117 + (50 * (i - 1)), 230, 40, 'assets/images/horse/rectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

					drawBorder(20, 583, 124 + (50 * (i - 1)), 26, 26, tocolor(horseColors[i][1], horseColors[i][2], horseColors[i][3], alpha))

					dxDrawText(i, 583, 124 + (50 * (i - 1)), 26, 26, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11), 'center', 'center')



				end 

	

				dxDrawText(v, 409, 131 + (50 * (i - 1)), 98, 18, tocolor(255, 255, 255, alpha), 1, getFont('bold', 11))



			end

			

			dxDrawImage(344, 367, 280, 40, 'assets/images/horse/betRectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(354, 374, 26, 26, (isMouseInPosition(354, 374, 26, 26) and 'assets/images/horse/arrowEffect.png' or 'assets/images/horse/arrow.png'), 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(588, 374, 26, 26, (isMouseInPosition(588, 374, 26, 26) and 'assets/images/horse/arrowEffect.png' or 'assets/images/horse/arrow.png'), 180, 0, 0, tocolor(255, 255, 255, alpha))

			

			dxDrawImage(444, 380, 15, 15, 'assets/images/horse/betTitle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawText('$'..formatNumber(config.bets[bet], '.'), 468, 381, 310, 50, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('sbold', 11))



			dxDrawText('Ganho potencial:', 344, 420, 78, 13, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 11))

			dxDrawText('$'..formatNumber(math.floor(config.bets[bet] * config.betMultiplier), '.'), 573, 420, 51, 13, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 11), 'right')

	

		elseif (horseWindow == 2) then 

			

			dxDrawImage(228, 165, 512, 335, 'assets/images/horse/bg.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



			aditionPos[1] = interpolateBetween(0, 0, 0, 434, 0, 0, ((getTickCount() - raceTick) / horseTimes[3]), 'Linear') 

			dxDrawImage(233 + aditionPos[1], 295, 78, 78, 'assets/images/horses/'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(259 + aditionPos[1], 302, 34, 17, 'assets/images/horses/3_'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		

			aditionPos[2] = interpolateBetween(0, 0, 0, 434, 0, 0, ((getTickCount() - raceTick) / horseTimes[1]), 'Linear') 

			dxDrawImage(233 + aditionPos[2], 325, 78, 78, 'assets/images/horses/'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(259 + aditionPos[2], 332, 34, 17, 'assets/images/horses/1_'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		

			aditionPos[3] = interpolateBetween(0, 0, 0, 434, 0, 0, ((getTickCount() - raceTick) / horseTimes[2]), 'Linear') 

			dxDrawImage(233 + aditionPos[3], 355, 78, 78, 'assets/images/horses/'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(259 + aditionPos[3], 362, 34, 17, 'assets/images/horses/2_'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		

			aditionPos[4] = interpolateBetween(0, 0, 0, 434, 0, 0, ((getTickCount() - raceTick) / horseTimes[4]), 'Linear') 

			dxDrawImage(233 + aditionPos[4], 385, 78, 78, 'assets/images/horses/'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(259 + aditionPos[4], 392, 34, 17, 'assets/images/horses/4_'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			

			aditionPos[5] = interpolateBetween(0, 0, 0, 434, 0, 0, ((getTickCount() - raceTick) / horseTimes[5]), 'Linear') 

			dxDrawImage(233 + aditionPos[5], 415, 78, 78, 'assets/images/horses/'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(259 + aditionPos[5], 422, 34, 17, 'assets/images/horses/5_'..index_an..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

	

			for i = 1, 5 do 

	

				if (aditionPos[i] == 434) then 





					horseWinner = ordemHorses[i]

					horseWindow = 3

					setTimer(function()



						horseWindow = 1

					

					end, 4 * 1000, 1)

					

					if (race_horse == horseWinner) then 

	

						triggerServerEvent('onPlayerPlusTshirCJ', resourceRoot, localPlayer, race_bet)

	

					else

	

						setElementData(localPlayer, 'hs_stoped', nil)

	

					end 

	

				end 

	

			end 



			dxDrawRectangle(228, 100, 512, 65, tocolor(255, 255, 255, alpha * 0.05))



			for i, v in ipairs(leaderboard) do 

				

				dxDrawImage(248 + (54 * (i - 1)), 108, 40, 49, 'assets/images/icons2/'..v..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

				dxDrawText(places[v]..'º', 262 + (54 * (i - 1)), 140, 11, 13, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 11), 'center')



			end 

	

			dxDrawText('Valor', 524, 117, 24, 13, tocolor(255, 255, 255, alpha * 0.5), 1, getFont('regular', 11))

			dxDrawImage(524, 133, 14, 14, 'assets/images/horse/betTitle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawText('$'..formatNumber(math.floor(config.bets[race_bet]), '.'), 546, 132, 45, 16, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('bold', 13))



			dxDrawText('Apostado', 656, 117, 24, 13, tocolor(255, 255, 255, alpha * 0.5), 1, getFont('regular', 11))

			dxDrawImage(656, 133, 18, 14, 'assets/images/horse/title.png', 0, 0, 0, tocolor(horseColors[race_horse][1], horseColors[race_horse][2], horseColors[race_horse][3], alpha))

			dxDrawText(race_horse, 678, 132, 45, 16, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('bold', 13))



			

			

		elseif (horseWindow == 3) then 	

			

			dxDrawImage(0, 0, 760, 520, 'assets/images/horse/blur.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			

			dxDrawImage(240, 85, 280, 50, 'assets/images/horse/leaderRectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(325, 112, 18, 14, 'assets/images/horse/title.png', 0, 0, 0, tocolor(horseColors[race_horse][1], horseColors[race_horse][2], horseColors[race_horse][3], alpha))

			dxDrawText('Apostado', 356, 93, 49, 14, tocolor(255, 255, 255, alpha * 0.5), 1, getFont('regular', 12), 'center')

			dxDrawText(horses[race_horse], 347, 111, 49, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('bold', 13))

			

			dxDrawImage(240, 395, 280, 50, 'assets/images/horse/leaderRectangle2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(331, 408, 15, 15, 'assets/images/horse/betTitle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			

			if (horseWinner == race_horse) then 

				

				dxDrawText('Ganhou: $'..formatNumber(math.floor(config.bets[bet] * config.betMultiplier), '.'), 355, 409, 74, 13, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 11))

	

			else 

	

				dxDrawText('Perdeu: $'..formatNumber(math.floor(config.bets[bet]), '.'), 355, 409, 74, 13, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 11))

	

			end 

	

			dxDrawText('Aguarde para retornar ao menu do\njogo inicial.', 290, 462, 180, 29, tocolor(255, 255, 255, alpha * 0.5), 1, getFont('medium', 12), 'center')

				

			for i, v in ipairs(places) do 

			

				dxDrawImage(240, 145 + (50 * (i - 1)), 40, 40, 'assets/images/icons/'..v..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

				dxDrawImage(290, 145 + (50 * (i - 1)), 230, 40, 'assets/images/horse/rectangleEffect.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

				dxDrawText(horses[v], 305, 159 + (50 * (i - 1)), 98, 18, tocolor(255, 255, 255, alpha), 1, getFont('bold', 11))



				if (race_horse == v) then 

					

					drawBorder(13, 405, 152 + (50 * (i - 1)), 75, 26, tocolor(horseColors[v][1], horseColors[v][2], horseColors[v][3], alpha))

					dxDrawText('Selecionado', 405, 152 + (50 * (i - 1)), 75, 26, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 11), 'center', 'center')

				

				else

					

					drawBorder(20, 479, 152 + (50 * (i - 1)), 26, 26, tocolor(horseColors[v][1], horseColors[v][2], horseColors[v][3], alpha))

					dxDrawText(i, 479, 152 + (50 * (i - 1)), 26, 26, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11), 'center', 'center')

				

				end 

			

			end



		end 



	elseif (gameSelect == 'touro') then



		drawBorder(10, 20, 70, 190, 430, tocolor(255, 255, 255, alpha * 0.02))

		

		dxDrawImage(35, 85, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 1º', 72, 90, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 121, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[1] and formatNumber(rankCache[1].amount, '.') or '???', 161, 121, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[1] and rankCache[1].name or '???', 35, 151, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawRectangle(35, 190, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 245, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 2º', 72, 250, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 281, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[2] and formatNumber(rankCache[2].amount, '.') or '???', 161, 281, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[2] and rankCache[2].name or '???', 35, 311, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawRectangle(35, 350, 1, 30, tocolor(255, 255, 255, alpha * 0.08))



		dxDrawImage(35, 405, 25, 25, 'assets/images/mines/trophy.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

		dxDrawText('Rank 3º', 72, 410, 40, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))

		dxDrawText('Ganhos:', 35, 441, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))

		dxDrawText(rankCache[3] and formatNumber(rankCache[3].amount, '.') or '???', 161, 441, 34, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 12), 'right')

		dxDrawText(rankCache[3] and rankCache[3].name or '???', 35, 471, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12), 'left', 'top', false, false, false, true)



		dxDrawText('R$'..formatNumber(getPlayerMoney(localPlayer), '.'), 228, 440 + 25, 52, 16, tocolor(255, 255, 255, alpha), 1, getFont('bold', 13))

		dxDrawText('Minha carteira', 228, 458 + 25, 52, 16, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('medium', 12))



		drawBorder(8, 360, 465, 160, 35, tocolor(255, 255, 255, alpha * 0.02))

		dxDrawText(selectEdit == 1 and guiGetText(amountEdit)..'|' or guiGetText(amountEdit), 375, 476, 40, 14, tocolor(255, 255, 255, alpha * 0.3), 1, getFont('regular', 12))

		dxDrawText('Fichas', 470, 475, 35, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('sbold', 12), 'right')



		drawBorder(5, 530, 465, 100, 35, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawText('Depositar', 530, 465, 100, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(530, 465, 100, 35)) then 



			if not (depositTick) then depositTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - depositTick) / 300), 'Linear')



			drawBorder(5, 530, 465, 100, 35, tocolor(96, 191, 76, animation))

			dxDrawText('Depositar', 530, 465, 100, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')



		else 



			depositTick = nil 



		end



		drawBorder(5, 640, 465, 100, 35, tocolor(255, 255, 255, alpha * 0.03))

		dxDrawText('Apostar', 640, 465, 100, 35, tocolor(255, 255, 255, alpha * 0.2), 1, getFont('bold', 12), 'center', 'center')



		if (isMouseInPosition(640, 465, 100, 35)) then 



			if not (betTick) then betTick = getTickCount() end 

			local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - betTick) / 300), 'Linear')



			drawBorder(5, 640, 465, 100, 35, tocolor(96, 191, 76, animation))

			dxDrawText('Apostar', 640, 465, 100, 35, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')



		else 



			betTick = nil 



		end



		dxDrawImage(228, 36, 512, 412, 'assets/images/touro/bg.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



		if (running) then 



			dxDrawImage(248, 130, 472, 268, tigerRender, 0, 0, 0, tocolor(255, 255, 255, alpha))



			local aditionalPositionInterpolate = interpolateBetween(- 30, 0, 0, 0, 0, 0, ((getTickCount() - spinTick) / (5 * 1000)), 'Linear')



			dxSetRenderTarget(tigerRender, true)



			for index = 1, 7 do 



				for i, v in ipairs(tigerTable[index]) do 



					if (index == 1) then 



						if not (addPosition[i]) then 

						

							addPosition[i] = 0 

						

						end

						addPosition[i] = addPosition[i] + aditionalPositionInterpolate



					end



					local startY = (7 + (68 * (i - 1))) + addPosition[i]

					if (startY >= - 150 and startY < 268) then 



						_dxDrawImage(7 + (68 * (index - 1)), startY, 50, 50, 'assets/images/touro/icons/'..v..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha), false, true)



						if (startY < 55) then 



							tigerSelectImages[0 + index] = v



						elseif (startY > 77 and startY < 125) then 



							tigerSelectImages[7 + index] = v



						elseif (startY > 143 and startY < 197) then 



							tigerSelectImages[14 + index] = v



						elseif (startY > 211 and startY < 389) then 



							tigerSelectImages[21 + index] = v



						end

					

					end



				end



			end



			dxSetRenderTarget()



			if (aditionalPositionInterpolate == 0) then 



				running = nil 



				if (isTimer(delay)) then 



					return 



				end



				delay = setTimer(function() end, 1000, 1)

				triggerServerEvent('onPlayerRefreshSwimOxygen', resourceRoot, localPlayer, tigerValue, tigerSelectImages)





			end



		else    



			local x, y = 0, 0

			for i = 1, 28 do 



				if (tigerSelectImages[i]) then 

				

					dxDrawImage(255 + x, 137 + y, 50, 50, 'assets/images/touro/icons/'..tigerSelectImages[i]..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



					x = x + 68 



					if (x >= 458) then 



						x = 0 

						y = y + 68 



					end 



				end



			end



		end 



		if (winPopup) then 



            local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - winTick) / 300), 'Linear')

            local winValue = interpolateBetween(0, 0, 0, lastTigerWin, 0, 0, ((getTickCount() - winTick) / 3000), 'Linear')



            dxDrawImage(0, 0, 760, 520, 'assets/images/touro/win.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawText('MEGA GANHO', 344, 351, 73, 16, tocolor(255, 255, 255, alpha), 1, getFont('mogra', 13), 'center')

            dxDrawText('R$'..formatNumber(math.floor(winValue), '.')..',00', 344, 368, 73, 16, tocolor(96, 191, 76, alpha), 1, getFont('mogra', 25), 'center')

			dxDrawText('Aguarde para retornar ao menu do\njogo inicial.', 290, 462, 180, 29, tocolor(255, 255, 255, alpha * 0.5), 1, getFont('medium', 12), 'center')



		end



	end



	if (balancePopup) then 



		local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - popupTick) / 150), 'Linear')

		drawBorder(15, 0, 0, 760, 520, tocolor(27, 29, 33, alpha * 0.92))



		if (balancePopup == 'withdraw') then 



			amountCassinoBalance = 0

			if (tonumber(guiGetText(balanceEdit))) then 



				amountCassinoBalance = tonumber(guiGetText(balanceEdit))



			end 



			drawBorder(10, 260, 110, 240, 300, tocolor(255, 255, 255, alpha * 0.03))

			dxDrawText('Sacar fichas', 275, 130, 66, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))



			dxDrawImage(275, 159, 210, 36, 'assets/images/balanceEdit.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(290, 167, 20, 20, 'assets/images/clearEdit.png', 0, 0, 0, (isMouseInPosition(290, 167, 20, 20) and tocolor(96, 191, 76, alpha) or tocolor(255, 255, 255, alpha * 0.2)))

			dxDrawText(selectEdit == 1 and guiGetText(balanceEdit)..'|' or guiGetText(balanceEdit), 407, 170, 63, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('regular', 12), 'right')



			dxDrawText('Suas fichas', 275, 215, 60, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12))

			

			drawBorder(15, 395, 205, 90, 30, tocolor(242, 242, 242, alpha))

			dxDrawText(formatNumber((getElementData(localPlayer, 'cassino.balance') or 0), '.'), 395, 205, 90, 30, tocolor(0, 0, 0, alpha * 0.9), 1, getFont('bold', 12), 'center', 'center')



			dxDrawRectangle(260, 250, 240, 85, tocolor(255, 255, 255, alpha * 0.03))

			dxDrawImage(275, 289, 210, 1, 'assets/images/bordedLine.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawText('Valor em fichas', 275, 265, 79, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 12))

			dxDrawText(formatNumber(amountCassinoBalance, '.'), 477, 265, 8, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 12), 'right')



			dxDrawText('Valor que irá receber', 275, 306, 79, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 12))

			dxDrawText('R$'..formatNumber(amountCassinoBalance, '.'), 477, 306, 8, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12), 'right')



			drawBorder(8, 275, 350, 210, 40, tocolor(96, 191, 76, alpha * 0.4))

			dxDrawText('Sacar dinheiro', 275, 350, 210, 40, tocolor(96, 191, 76, alpha), 1, getFont('bold', 12), 'center', 'center')



			if (isMouseInPosition(275, 350, 210, 40)) then 

			

				if not (popupButtonTick) then popupButtonTick = getTickCount() end 

				local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - popupButtonTick) / 300), 'Linear')

			

				drawBorder(8, 275, 350, 210, 40, tocolor(96, 191, 76, animation))

				dxDrawText('Sacar dinheiro', 275, 350, 210, 40, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')

			

			else 

			

				popupButtonTick = nil 

			

			end



		elseif (balancePopup == 'deposit') then 



			amountCassinoBalance = 0

			if (tonumber(guiGetText(balanceEdit))) then 



				amountCassinoBalance = tonumber(guiGetText(balanceEdit))



			end 



			drawBorder(10, 260, 110, 240, 300, tocolor(255, 255, 255, alpha * 0.03))

			dxDrawText('Depositar fichas', 275, 130, 66, 14, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 12))



			dxDrawImage(275, 159, 210, 36, 'assets/images/balanceEdit.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawImage(290, 167, 20, 20, 'assets/images/clearEdit.png', 0, 0, 0, (isMouseInPosition(290, 167, 20, 20) and tocolor(96, 191, 76, alpha) or tocolor(255, 255, 255, alpha * 0.2)))

			dxDrawText(selectEdit == 1 and guiGetText(balanceEdit)..'|' or guiGetText(balanceEdit), 407, 170, 63, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('regular', 12), 'right')



			dxDrawText('Suas fichas', 275, 215, 60, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12))

			

			drawBorder(15, 395, 205, 90, 30, tocolor(242, 242, 242, alpha))

			dxDrawText(formatNumber((getElementData(localPlayer, 'cassino.balance') or 0), '.'), 395, 205, 90, 30, tocolor(0, 0, 0, alpha * 0.9), 1, getFont('bold', 12), 'center', 'center')



			dxDrawRectangle(260, 250, 240, 85, tocolor(255, 255, 255, alpha * 0.03))

			dxDrawImage(275, 289, 210, 1, 'assets/images/bordedLine.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

			dxDrawText('Valor', 275, 265, 79, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 12))

			dxDrawText('R$'..formatNumber(amountCassinoBalance, '.'), 477, 265, 8, 14, tocolor(255, 255, 255, alpha * 0.9), 1, getFont('medium', 12), 'right')



			dxDrawText('Fichas', 275, 306, 79, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 12))

			dxDrawText(formatNumber(amountCassinoBalance, '.'), 477, 306, 8, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 12), 'right')



			drawBorder(8, 275, 350, 210, 40, tocolor(96, 191, 76, alpha * 0.4))

			dxDrawText('Depositar', 275, 350, 210, 40, tocolor(96, 191, 76, alpha), 1, getFont('bold', 12), 'center', 'center')



			if (isMouseInPosition(275, 350, 210, 40)) then 

			

				if not (popupButtonTick) then popupButtonTick = getTickCount() end 

				local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - popupButtonTick) / 300), 'Linear')

			

				drawBorder(8, 275, 350, 210, 40, tocolor(96, 191, 76, animation))

				dxDrawText('Depositar', 275, 350, 210, 40, tocolor(255, 255, 255, animation), 1, getFont('bold', 12), 'center', 'center')

			

			else 

			

				popupButtonTick = nil 

			

			end



		end



	end



end



addEventHandler('onClientClick', root, 

	function(b, s)



		if (b == 'left' and s == 'down') then 



			if (isEventHandlerAdded('onClientRender', root, drawCassino)) then 



				if (balancePopup) then 



					if (balancePopup == 'withdraw') then 



						selectEdit = 0



						if (guiGetText(balanceEdit) == '') then 



							guiSetText(balanceEdit, 'Insira o valor')



						end



						if (isMouseInPosition(290, 167, 20, 20)) then 



							balancePopup = nil



						elseif (isMouseInPosition(275, 159, 210, 36)) then 



							if (guiEditSetCaretIndex(balanceEdit, #guiGetText(balanceEdit))) then 

								

								guiBringToFront(balanceEdit)

								guiSetInputMode('no_binds_when_editing')



								selectEdit = 1 

								if (guiGetText(balanceEdit) == 'Insira o valor') then 



									guiSetText(balanceEdit, '')

		

								end



							end



						elseif (isMouseInPosition(275, 350, 210, 40)) then 



							triggerServerEvent('onPlayerWithdrawCassinoBalance', resourceRoot, localPlayer, guiGetText(balanceEdit))

							

						end



					elseif (balancePopup == 'deposit') then 



						selectEdit = 0



						if (guiGetText(balanceEdit) == '') then 



							guiSetText(balanceEdit, 'Insira o valor')



						end



						if (isMouseInPosition(290, 167, 20, 20)) then 



							balancePopup = nil



						elseif (isMouseInPosition(275, 159, 210, 36)) then 



							if (guiEditSetCaretIndex(balanceEdit, #guiGetText(balanceEdit))) then 

								

								guiBringToFront(balanceEdit)

								guiSetInputMode('no_binds_when_editing')



								selectEdit = 1 

								if (guiGetText(balanceEdit) == 'Insira o valor') then 



									guiSetText(balanceEdit, '')

		

								end



							end



						elseif (isMouseInPosition(275, 350, 210, 40)) then 



							triggerServerEvent('onPlayerDepositCassinoBalance', resourceRoot, localPlayer, guiGetText(balanceEdit))

							

						end



					end



				return end 



				if (isMouseInPosition(619, 10, 90, 31)) then



					balancePopup = 'withdraw'

					popupTick = getTickCount()

					guiSetText(balanceEdit, 'Insira o valor')



				elseif (isMouseInPosition(729, 20, 11, 11)) then



					removeCassino()



				elseif (gameSelect == 'double') then 



					selectEdit = 0 



					if (guiGetText(amountEdit) == '') then 



						guiSetText(amountEdit, 'Quantia')



					end



					if (isMouseInPosition(400, 385, 90, 35)) then 



						balancePopup = 'deposit'

						popupTick = getTickCount()

						guiSetText(balanceEdit, 'Insira o valor')



					elseif (isMouseInPosition(230, 460, 80, 40)) then 

						

						selectColor = 'green'



					elseif (isMouseInPosition(320, 460, 80, 40)) then 

						

						selectColor = 'white'



					elseif (isMouseInPosition(410, 460, 80, 40)) then 

						

						selectColor = 'gray'



					elseif (isMouseInPosition(510, 406, 230, 40)) then

						

						if (guiEditSetCaretIndex(amountEdit, #guiGetText(amountEdit))) then 

								

							guiBringToFront(amountEdit)

							guiSetInputMode('no_binds_when_editing')



							selectEdit = 1 

							if (guiGetText(amountEdit) == 'Quantia') then 



								guiSetText(amountEdit, '')

	

							end



						end



					elseif (isMouseInPosition(510, 460, 230, 40)) then 



						if (spinning) then 



							return 



						end



						triggerServerEvent('onPlayerBetOnDouble', resourceRoot, localPlayer, selectColor, guiGetText(amountEdit))



					end



				elseif (gameSelect == 'mines') then 



					selectEdit = 0 



					if (guiGetText(amountEdit) == '') then 



						guiSetText(amountEdit, 'Quantia')



					end



					if (isMouseInPosition(635, 447, 90, 35)) then 



						balancePopup = 'deposit'

						popupTick = getTickCount()

						guiSetText(balanceEdit, 'Insira o valor')



					elseif (playingMines) then 



						if (isMouseInPosition(245, 370, 175, 40)) then 

						

							playingMines = nil
							local random = math.random(1, 9999999999999999999)

							triggerServerEvent('onPlayerHavePermissionsFromJob', resourceRoot, localPlayer, tonumber(betValue), tonumber(originialValue), random)

							config.notifyC('Você resgatou sua recompensa com sucesso.', 'success')

							playSound('assets/sounds/success.mp3')

						

						else

						

							for i, v in ipairs(mineSlots) do 

							

								if (isMouseInPosition(unpack(v))) then 

								

									if not (slotMinesCache[i]) then 

									

										slotMinesCache[i] = minesStates[i]

									

									else

									

										return

									

									end 

								

									if (minesStates[i] == 'bomb') then 

									

										playingMines = nil 

										config.notifyC('Você acertou uma bomba e perdeu sua aposta.', 'error')

										playSound('assets/sounds/explosao.mp3')



										for index, v in ipairs(mineSlots) do 

											if not slotMinesCache[index] then

												slotMinesCache[index] = minesStates[index]

											end

										end

										

									else

									

										betValue = betValue + (originialValue * config.minesMultipliers[minesNumber])

									

									end

								

								end

							

							

							end

						

						end



					elseif (isMouseInPosition(245, 318, 175, 40)) then 



						if (guiEditSetCaretIndex(amountEdit, #guiGetText(amountEdit))) then 

								

							guiBringToFront(amountEdit)

							guiSetInputMode('no_binds_when_editing')



							selectEdit = 1 

							if (guiGetText(amountEdit) == 'Quantia') then 



								guiSetText(amountEdit, '')

	

							end



						end



					elseif (isMouseInPosition(245, 370, 175, 40)) then

						

						triggerServerEvent('onPlayerStartBetOnMines', resourceRoot, localPlayer, guiGetText(amountEdit))



					else



						for i, v in ipairs(config.mines) do 



							if (isMouseInPosition(245, 145 + (43 * (i - 1)), 175, 40)) then 



								minesNumber = v

							

							return end

				

						end



					end



				elseif (gameSelect == 'blackjack') then 



					if (playingBlackjack) then 



						if not (stopedPlay) then 



							if (isMouseInPosition(370, 295, 100, 35)) then 





								if myCards and #myCards < 2 then

									return config.notifyC('Você não pode permanecer sem pegar pelo menos 2 carta.', 'warning')

								end



								stopedPlay = true 

								

								verifyBlackjackCards()

								



							elseif (isMouseInPosition(480, 295, 120, 35)) then 



								local randomNaipe = naipes[math.random(#naipes)]

								local randomCard = cards[math.random(#cards)]



								table.insert(myCards, 

							

									{

										naipe = randomNaipe;

										card = randomCard;

										value = cardsValues[randomCard];

									}



								)



							end



						end

						

					return end



					selectEdit = 0 



					if (guiGetText(amountEdit) == '') then 



						guiSetText(amountEdit, 'Quantia')



					end



					if (isMouseInPosition(375, 439, 90, 35)) then 



						balancePopup = 'deposit'

						popupTick = getTickCount()

						guiSetText(balanceEdit, 'Insira o valor')





					elseif (isMouseInPosition(230, 379, 235, 40)) then 

						

						if (guiEditSetCaretIndex(amountEdit, #guiGetText(amountEdit))) then 

								

							guiBringToFront(amountEdit)

							guiSetInputMode('no_binds_when_editing')



							selectEdit = 1 

							if (guiGetText(amountEdit) == 'Quantia') then 



								guiSetText(amountEdit, '')

	

							end



						end



					elseif (isMouseInPosition(480, 379, 260, 40)) then 



						triggerServerEvent('onPlayerBetInBlackjack', resourceRoot, localPlayer, guiGetText(amountEdit))





					end



				elseif (gameSelect == 'crash') then



					selectEdit = 0 



					if (guiGetText(amountEdit) == '') then 



						guiSetText(amountEdit, 'Quantia')



					end



					if (guiGetText(autoStopEdit) == '') then 



						guiSetText(autoStopEdit, 'Quantia')



					end



					if (isMouseInPosition(400, 385, 90, 35)) then 



						balancePopup = 'deposit'

						popupTick = getTickCount()

						guiSetText(balanceEdit, 'Insira o valor')



					elseif (isMouseInPosition(510, 406, 230, 40)) then 



						if (guiEditSetCaretIndex(amountEdit, #guiGetText(amountEdit))) then 

								

							guiBringToFront(amountEdit)

							guiSetInputMode('no_binds_when_editing')



							selectEdit = 1 

							if (guiGetText(amountEdit) == 'Quantia') then 



								guiSetText(amountEdit, '')

	

							end



						end



					elseif (isMouseInPosition(455, 470, 20, 20)) then 



						guiSetText(autoStopEdit, 'Quantia')



					elseif (isMouseInPosition(230, 460, 260, 40)) then 



						if (guiEditSetCaretIndex(autoStopEdit, #guiGetText(autoStopEdit))) then 

								

							guiBringToFront(autoStopEdit)

							guiSetInputMode('no_binds_when_editing')



							selectEdit = 2 

							if (guiGetText(autoStopEdit) == 'Quantia') then 



								guiSetText(autoStopEdit, '')

	

							end



						end



					elseif (isMouseInPosition(510, 460, 230, 40)) then



						if not subindostate then

							local number = guiGetText(amountEdit)

							if number and tonumber(number) and tonumber(number) > 0 then

								if not string.find(number, '+') and not string.find(number, '-') then

									if (getElementData(localPlayer, 'cassino.balance') or 0) >= tonumber(number) then

										if tonumber(number) >= 100 and tonumber(number) <= 50000 then



											if (isTimer(crashTimer)) then 



												return config.notifyC('Espere um pouco para apostar novamente.', 'info')

											

											end



											triggerServerEvent('onTechConnectLearn', resourceRoot, localPlayer, tonumber(number))

											subindo = true

											crashou = false

											retirou = false

											secondssub = false

											valoraposta = number

											insertOnRegisterCrash = false

											config.notifyC('Você apostou', 'info')

											crashTimer = setTimer(function() end, 10 * 1000, 1)



											CRASHpercentage = math.random(0, 100)

											if (CRASHpercentage <= 60) then 



												setTimer(function()

												

													subindo = 1.0

													crashou = true 



												end, 100, 1)



											end 



										else

											config.notifyC('O limite de aposta esta dentro de 100 a 50.000!', 'info')

										end

									end

								end

							end

						else

							if subindo then

								if not crashou and not retirou then

									playSound('assets/sounds/success.mp3')

									retirou = true

									triggerServerEvent('onServerEmploymentSimulated', resourceRoot, localPlayer, tonumber(math.floor(valoraposta * subindo)), sha256('BMR_SECURITY_HAHAKKK_RandomWord1_BMR_RandomWord2_SECURITY_HAHAKKK_RandomWord3_BMR_SECURITY_RandomWord4_HAHAKKK_RandomWord5'), 'BMR_SECURITY_HAHAKKK_')

									config.notifyC('Você retirou '..formatNumber(math.floor(valoraposta * subindo), '.'), 'info')

								end

							end

						end



					end 



				elseif (gameSelect == 'horse') then 



					if (horseWindow == 1) then 	



						if (isMouseInPosition(445, 465, 90, 35)) then 



							balancePopup = 'deposit'

							popupTick = getTickCount()

							guiSetText(balanceEdit, 'Insira o valor')



						elseif (isMouseInPosition(540, 465, 90, 35)) then  

	

							triggerServerEvent('onPlayerDevFunc33', resourceRoot, localPlayer, horseSelect, bet)

	

						elseif (isMouseInPosition(354, 374, 26, 26)) then 

	

							if (bet > 1) then 

	

								bet = bet - 1 

	

							else 

	

								bet = #config.bets

	

							end 

	

						elseif (isMouseInPosition(588, 374, 26, 26)) then 

	

							if (bet < #config.bets) then 

								

								bet = bet + 1 

	

							else 

	

								bet = 1 

	

							end

	

						else 

	

							for i, v in ipairs(horses) do 

		

		

								if (isMouseInPosition(394, 117 + (50 * (i - 1)), 230, 40)) then 

		

									horseSelect = i

									

								return end 

		

							end

	

						end

	

					elseif (horseWindow == 3) then 

	

						if (isMouseInPosition(573, 624, 220, 50)) then 

	

							horseWindow = 1

	

						end

						

					end





				elseif (gameSelect == 'touro') then 



					if (winPopup) then 



                        if (isMouseInPosition(29, 391, 225, 40)) then 



                            winPopup = nil



                        end

                

                    return end 



					if (running) then 



						return

	

					end



					selectEdit = 0 



					if (guiGetText(amountEdit) == '') then 



						guiSetText(amountEdit, 'Quantia')



					end



					if (isMouseInPosition(360, 465, 160, 35)) then 



						if (guiEditSetCaretIndex(amountEdit, #guiGetText(amountEdit))) then 

								

							guiBringToFront(amountEdit)

							guiSetInputMode('no_binds_when_editing')



							selectEdit = 1 

							if (guiGetText(amountEdit) == 'Quantia') then 



								guiSetText(amountEdit, '')

	

							end



						end



					elseif (isMouseInPosition(530, 465, 100, 35)) then



						balancePopup = 'deposit'

						popupTick = getTickCount()

						guiSetText(balanceEdit, 'Insira o valor')



					elseif (isMouseInPosition(640, 465, 100, 35)) then 



						if not (running) then 



                            if (isTimer(tigerDelay)) then 



                                return 



                            end 



                            tigerDelay = setTimer(function() end, 2 * 1000, 1)



                            triggerServerEvent('onPlayerBetOnFortuneTiger', resourceRoot, localPlayer, guiGetText(amountEdit))	

							makeTigerTable()



                        else



                            config.notifyC('Aguarde a roleta terminar de girar.', 'error')



                        end 



					end 



                    if (winPopup) then 



                        if (isMouseInPosition(29, 391, 225, 40)) then 



                            winPopup = nil



                        end

                

                    return end





				end

				

			end



		end



	end

)



addEvent('onClientDrawCassino', true)

addEventHandler('onClientDrawCassino', root, 



	function(gameSelect_, rankCache_)



		if not (isEventHandlerAdded('onClientRender', root, drawCassino)) then 



			tick, interpolate, animation = getTickCount(), {0, 255}, {150, 0}



			addEventHandler('onClientRender', root, drawCassino)

			showCursor(true)

			showChat(false)



			balancePopup = false

			gameSelect = gameSelect_ 



			balanceEdit = guiCreateEdit(0, 0, 0, 0, 'Insira o valor', false)

			guiEditSetMaxLength(balanceEdit, 8)

			guiSetProperty(balanceEdit, 'ValidationString', '[0-9]*')



			amountEdit = guiCreateEdit(0, 0, 0, 0, 'Quantia', false)

			guiEditSetMaxLength(amountEdit, 8)

			guiSetProperty(amountEdit, 'ValidationString', '[0-9]*')



			autoStopEdit = guiCreateEdit(0, 0, 0, 0, 'Quantia', false)

			guiEditSetMaxLength(autoStopEdit, 5)

			

			if (gameSelect == 'double') then 



				doubleRender = dxCreateRenderTarget(respC(510), respC(118), true)	

				selectColor = 'green'

				myBets = {}

				spinning = false 

				spinRemovePos = 0 



				randomBets = {



					math.random(2, 18);

					math.random(2, 18);

					math.random(2, 18);

					

				}



				startSpinDouble = setTimer(function()

				

					spinning = true 

					spinTick = getTickCount()

					spinRemovePos = 0 



				end, 10 * 1000, 1)

				updateDoubleRender()



			elseif (gameSelect == 'mines') then 



				playingMines, minesNumber = nil, 5



				rankCache = rankCache_



				table.sort(rankCache, 

			

					function(a, b)



						if (a.amount > b.amount) then 



							return true 



						end



					end



				)



			elseif (gameSelect == 'blackjack') then 



				playingBlackjack = false 

				myCards = {}

				cassinoCards = {}

				stopedPlay = false



				valueTotalBets = 0

				profitBlackjack = 0



				victorys = 0 

				fails = 0



				if (isTimer(addCartTimer)) then 



					killTimer(addCartTimer)

			

				end

				

			elseif (gameSelect == 'crash') then 



				rankCache = rankCache_



				table.sort(rankCache, 

			

					function(a, b)



						if (a.amount > b.amount) then 



							return true 



						end



					end



				)



			elseif (gameSelect == 'horse') then 



				horseWindow = 1

				bet = 1

				horseSelect = 1



				if (isTimer(indexTimer)) then 



					killTimer(indexTimer)

	

				end

	

				index_an = 1

				indexTimer = setTimer(function()

					if (index_an+1) > 8 then

						index_an = 0

					end

					index_an = index_an + 1

				end, 120, 0)



				rankCache = rankCache_



				table.sort(rankCache, 

			

					function(a, b)



						if (a.amount > b.amount) then 



							return true 



						end



					end



				)



			elseif (gameSelect == 'touro') then 



				rankCache = rankCache_



				table.sort(rankCache, 

			

					function(a, b)



						if (a.amount > b.amount) then 



							return true 



						end



					end



				)



				makeTigerTable()



				if not (isElement(tigerRender)) then 

	

					tigerRender =  dxCreateRenderTarget(472, 268, true)

	

				end

	



			end 

			

		else



			removeCassino()



		end



	end



)



function removeCassino()

	

	if (isEventHandlerAdded('onClientRender', root, drawCassino)) then 



		if (interpolate[1] == 0) then 



			if (gameSelect == 'horse') then 



				if (horseWindow == 2) then 



					return 



				end



			elseif (gameSelect == 'touro') then 



				if (running) then 



					return



				end



			end



			tick, interpolate, animation = getTickCount(), {255, 0}, {0, 150}



			showCursor(false)

			setTimer(function()

			

				removeEventHandler('onClientRender', root, drawCassino)

				showChat(true)



				if (isElement(doubleRender)) then 



					destroyElement(doubleRender)



				end



				if (isElement(tigerRender)) then 



					destroyElement(tigerRender)



				end



				if (isElement(balanceEdit)) then 



					destroyElement(balanceEdit)



				end



				if (isElement(amountEdit)) then 



					destroyElement(amountEdit)



				end



				if (isElement(autoStopEdit)) then 



					destroyElement(autoStopEdit)



				end



				if (isTimer(startSpinDouble)) then 



					killTimer(startSpinDouble)



				end



				if (isTimer(indexTimer)) then 



					killTimer(indexTimer)

	

				end



			end, 150, 1)



		end



	end



end

bindKey('backspace', 'down', removeCassino)



addEvent('onClientStartHorseBet', true)

addEventHandler('onClientStartHorseBet', root, 



    function(horse_, bet_)



        raceTick = getTickCount()

        race_horse, race_bet = horse_, bet_

        horseWindow = 2 



        horseTimes = {}

        for i = 1, 5 do 



            horseTimes[i] = math.random(20000, 30000)



        end 



        horseTimesCache = {}

        for i, v in ipairs(horseTimes) do 



            table.insert(horseTimesCache, 



                {

                    placed = i; 

                    time = v; 

                }



            )



        end 



        table.sort(horseTimesCache, 



            function(a, b) 

                

                return a.time < b.time 

            

            end 

        

        )



        places = {}

        for i, v in ipairs(horseTimesCache) do 



            places[v.placed] = i



        end 

        



    end



)



-- // TIGER 



addEvent('onClientStartFortuneTigerRoulette', true)

addEventHandler('onClientStartFortuneTigerRoulette', root, 



    function(tigerValue_)



        running = true 

        spinTick = getTickCount()

        tigerValue = tigerValue_ 



    end



)



addEvent('onClientReceiveFortuneTigerWin', true)

addEventHandler('onClientReceiveFortuneTigerWin', root, 



    function(lastTigerWin_)



        lastTigerWin = lastTigerWin_

        winPopup = true 

        winTick = getTickCount()



		setTimer(function()



			winPopup = false

		

		end, 5 * 1000, 1)





    end



)



local tigerImages = {'1', '2', '3', '4', '5', '6', 'wild'}

function makeTigerTable()



    tigerSelectImages = {};

    addPosition = {}

    tigerTable = {



        [1] = {};

        [2] = {};

        [3] = {};

        [4] = {};

        [5] = {};

        [6] = {};

        [7] = {};





    }





    for _, image in ipairs(tigerImages) do 



        for i = 1, math.random(300, 600) do 



            table.insert(tigerTable[1], image)

            table.insert(tigerTable[2], image)

            table.insert(tigerTable[3], image)

            table.insert(tigerTable[4], image)

            table.insert(tigerTable[5], image)

            table.insert(tigerTable[6], image)

            table.insert(tigerTable[7], image)



        end



    end





    for i = 1, 15 do 



        tigerTable[1] = table.shuffle(tigerTable[1])

        tigerTable[2] = table.shuffle(tigerTable[2])

        tigerTable[3] = table.shuffle(tigerTable[3])

        tigerTable[4] = table.shuffle(tigerTable[3])

        tigerTable[5] = table.shuffle(tigerTable[3])

        tigerTable[6] = table.shuffle(tigerTable[3])

        tigerTable[7] = table.shuffle(tigerTable[3])



    end



end



function alfabeticOrder(a, b)



    return a.name < b.name



end





-- // TIGER 



addEvent('onClientStartMinesGame', true)

addEventHandler('onClientStartMinesGame', root, 



    function(betValue_)

        

        originialValue, betValue = tonumber(betValue_), tonumber(betValue_)

        slotMinesCache = {}

        playingMines = true 



        minesStates = {}

        for i, v in ipairs(mineSlots) do

            

            if (i <= minesNumber) then 

            

                table.insert(minesStates, 'bomb')

            

            else

            

                table.insert(minesStates, 'diamond')

            

            end

        

        

        end

    

        for i = 1, 15 do 

        

            minesStates = table.shuffle(minesStates)

        

        end



    end



)



addEvent('onClientStartBlackjackGame', true)

addEventHandler('onClientStartBlackjackGame', root, 



	function(betValue)



		playingBlackjack = true 

		stopedPlay = false

		myCards = {}

		cassinoCards = {}

		valueTotalBets = valueTotalBets + betValue

		cardEffects = {}

		betValueBlackjack = betValue



		profitBlackjack = profitBlackjack - betValueBlackjack



		if (isTimer(addCartTimer)) then 



			killTimer(addCartTimer)

	

		end



	end 



)



addEvent('onClientReceiveDoubleBets', true)

addEventHandler('onClientReceiveDoubleBets', root, 



	function(myBets_)



		myBets = myBets_



	end



)



function verifyBlackjackCards()



	if not (playingBlackjack) then 



		return 



	end



	if (isTimer(addCartTimer)) then 



		killTimer(addCartTimer)



	end



	addCartTimer = setTimer(function()



		if not (playingBlackjack) then 



			return 

	

		end



		local randomNaipe = naipes[math.random(#naipes)]

		local randomCard = cards[math.random(#cards)]

	

		table.insert(cassinoCards, 

	

			{

				naipe = randomNaipe;

				card = randomCard;

				value = cardsValues[randomCard];

			}

		

		)

	

		verifyBlackjackCards()

	

	end, 2000, 1)



end



function convertDoubleTime(tempoEmMilissegundos)

    local segundos = tempoEmMilissegundos / 1000

    return string.format("%.2f", segundos)

end



function makeRandomNumbers()



    rouletteTable = {}

    while (#rouletteTable < 330) do 

        

        for i, v in ipairs(numbers) do

        

            table.insert(rouletteTable, { number = v.number, color = v.color })

        

        end

    

    end

    

    for i = 1, 20 do 

    

        rouletteTable = table.shuffle(rouletteTable)

    

    end





end

makeRandomNumbers()



function updateDoubleRender()



	dxSetRenderTarget(doubleRender, true)



		dxSetBlendMode ('modulate_add');



			for i, v in ipairs(rouletteTable) do 



				local startX, startY = (80 * (i - 1)), 24 

				startX = startX - spinRemovePos



				if (startX > - 70 and startX <= (510 + 70)) then 



					_dxDrawImageRENDER(startX, startY, 70, 70, 'assets/images/double/'..v.color..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



					if (v.color ~= 'white') then 



						_dxDrawTextRENDER(v.number, startX + 12, startY + 12, 46, 46, tocolor(255, 255, 255, alpha), 1, getFont('sbold', 16), 'center', 'center')

					

					end 



					if (spinning) then 



						local positionScale = interpolateBetween(5, 0, 0, 0, 0, 0, ((getTickCount() - spinTick) / 10000), 'Linear')

						local remainTime = interpolateBetween(10000, 0, 0, 0, 0, 0, ((getTickCount() - spinTick) / 10000), 'Linear')

						spinRemovePos = spinRemovePos + positionScale



						if (startX >= 248 and startX < (248 + 14)) then 



							selectItem = v



						end 



						if (remainTime == 0) then 	



							if (myBets[selectItem.color]) then 

							

								triggerServerEvent('quantumEntropyDiscombobulator', resourceRoot, localPlayer, selectItem.color)

								playSound('assets/sounds/ganhou.mp3')

							

							else

								

								if myBets and (myBets['green'] or myBets['gray'] or myBets['white']) then

									playSound('assets/sounds/perdeu.mp3')

								end

								

							end 

							

							triggerServerEvent('onPlayerClearDoubleBets', resourceRoot, localPlayer)

							

							lastSpins[#lastSpins + 1] = selectItem

							spinning = false 

							myBets = {}



							randomBets = {



								math.random(2, 18);

								math.random(2, 18);

								math.random(2, 18);

								

							}



							startSpinDouble = setTimer(function()

							

								spinning = true 

								spinTick = getTickCount()

								spinRemovePos = 0 

								makeRandomNumbers()

			

							end, 10 * 1000, 1)



						end 



					end 



				end 



			end	



			_dxDrawImageRENDER(248, 0, 14, 118, 'assets/images/double/arrows.png', 0, 0, 0, tocolor(255, 255, 255, alpha))



		dxSetBlendMode ('blend');



	dxSetRenderTarget()



end



function _dxDrawTextRENDER (text, x, y, width, height, ...)



    return _dxDrawText (text, x * screenScale, y * screenScale, (screenScale * x) + (screenScale * width), (screenScale * y) + (screenScale * height), ...);



end



function _dxDrawImageRENDER (x, y, width, height, ...)



    return _dxDrawImage (x * screenScale, y * screenScale, (screenScale * width), (screenScale * height), ...);



end



function _dxDrawRectangleRENDER (x, y, width, height, ...)



    return _dxDrawRectangle (x * screenScale, y * screenScale, (screenScale * width), (screenScale * height), ...);



end



function _drawBorderRENDER ( radius, x, y, width, height, color, colorStroke, sizeStroke, postGUI )



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

        _dxDrawImageRENDER(x, y, width, height, size[height..':'..width], 0, 0, 0, color, postGUI)

    end



end



function math.round(num, decimals)

    decimals = math.pow(10, decimals or 0)

    num = num * decimals

    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end

    return num / decimals

end