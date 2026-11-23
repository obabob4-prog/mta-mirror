---[[

    --» sᴄʀɪᴘᴛ ғᴇɪᴛᴏ ᴘᴏʀ » Pedro Developer

---]]



local screenW, screenH = guiGetScreenSize();
local screenScale = math.min(math.max(screenH / 768, 0.70), 2); -- Caso o painel seja muito grande, retirar o limite e deixar apenas o (screenH / 768).

local parentW, parentH = (750 * screenScale), (480 * screenScale); -- Comprimento e Largura do painel.
local parentX, parentY = ((screenW - parentW) / 2), ((screenH - parentH) / 2); -- Posição X e Y do painel.

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

local visibleBalance = true
local effects = {}
local windowEffects = {}
local windows = {

    {25, 295, 18, 18, 'withdraw', 'Saque'};
    {25, 338, 18, 18, 'deposit', 'Depósito'};
    {25, 381, 18, 18, 'transfer', 'Transferir'};
    {25, 424, 18, 18, 'tax', 'Impostos'};

}

local fasts = {

    150;
    300;
    450;
    600;
    750;
    900;

}

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

function drawBank()

    cursor.state = isCursorShowing ();

    if (cursor.state) then

        local cursorX, cursorY = getCursorPosition ();
        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;

    end

    local alpha = interpolateBetween(interpolate[1], 0, 0, interpolate[2], 0, 0, ((getTickCount() - tick) / 500), 'Linear')

    dxDrawImage(0, 0, 750, 480, 'assets/images/bg.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawImage(33, 24, 131, 39, 'assets/images/logo.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

    local realTime = getRealTime()
    dxDrawText((realTime.hour < 10 and '0'..realTime.hour or realTime.hour)..':'..(realTime.minute < 10 and '0'..realTime.minute or realTime.minute), 703, 28, 27, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11), 'right')
    dxDrawRectangle(692, 30, 1, 10, tocolor(255, 255, 255, alpha * 0.11))
    dxDrawImage(637, 20, 30, 30, ':goiaba_login/assets/avatares/'..(getElementData(localPlayer, 'avatar') or 1)..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText(getPlayerName(localPlayer)..'('..(getElementData(localPlayer, 'ID') or '???')..')', 591, 28, 38, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11), 'right', 'top', false, false, false, true)

    dxDrawImage(0, 85, 220, 395, 'assets/images/windowRectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawImage(15, 100, 18, 18, 'assets/images/card.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText('Meu cartão', 38, 102, 59, 14, tocolor(255, 255, 255, alpha), 1, getFont('bold', 11))

    dxDrawImage(15, 128, 190, 110, 'assets/images/mastercard.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText('Conta', 30, 143, 32, 14, tocolor(255, 255, 255, alpha * 0.5), 1, getFont('medium', 11))
    dxDrawText(visibleBalance and 'R$'..formatNumber((getElementData(localPlayer, config.geral.element_data) or 0), '.')..',00' or '****', 30, 160, 81, 19, tocolor(255, 255, 255, alpha), 1, getFont('bold', 15))
    dxDrawImage(172, 143, 18, 18, visibleBalance and 'assets/images/eye.png' or 'assets/images/eye2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

    dxDrawImage(15, 258, 18, 18, 'assets/images/windows.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText('Categorias', 38, 260, 57, 14, tocolor(255, 255, 255, alpha), 1, getFont('bold', 11))

    for i, v in ipairs(windows) do 

        if (window == v[5] or isMouseInPosition(15, 286 + (43 * (i - 1)), 190, 35)) then 

            dxDrawImage(15, 286 + (43 * (i - 1)), 190, 35, 'assets/images/windows/rectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(v[1], v[2], v[3], v[4], 'assets/images/windows/'..i..'.png', 0, 0, 0, tocolor(2, 250, 83, alpha))
            dxDrawRectangle(50, 299 + (43 * (i - 1)), 1, 9, tocolor(255, 255, 255, alpha * 0.2))

        else

            dxDrawImage(15, 286 + (43 * (i - 1)), 190, 35, 'assets/images/windows/stroke.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(v[1], v[2], v[3], v[4], 'assets/images/windows/'..i..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.2))
            dxDrawRectangle(50, 299 + (43 * (i - 1)), 1, 9, tocolor(255, 255, 255, alpha * 0.09))

        end

        dxDrawText(v[6], 87, 297 + (43 * (i - 1)), 32, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11))
        
    end

    dxDrawText('Olá,', 240, 85, 21, 14, tocolor(255, 255, 255, alpha * 0.5), 1, getFont('medium', 11))
    dxDrawText(string.gsub(getPlayerName(localPlayer), '_', ' '), 240, 99, 21, 14, tocolor(255, 255, 255, alpha), 1, getFont('bold', 16))

    if (window == 'withdraw') then 

        drawBorder(15, 240, 130, 355, 140, tocolor(255, 255, 255, alpha * 0.04))
        dxDrawText('Saque', 255, 145, 35, 15, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12))
        dxDrawImage(562, 145, 18, 18, 'assets/images/card.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        drawBorder(9, 255, 170, 210, 40, tocolor(255, 255, 255, alpha * 0.08))
        dxDrawText(selectEdit == 1 and guiGetText(amountEdit)..'|' or guiGetText(amountEdit), 270, 182, 22, 15, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12))
        dxDrawText('R$', 437, 183, 13, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11), 'right')
        dxDrawImage(255, 225, 40, 30, 'assets/images/amount.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Insira a quantidade desejada.', 305, 233, 150, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))

        drawBorder(10, 480, 215, 100, 40, tocolor(255, 255, 255, alpha * 0.08))
        dxDrawText('Concluir', 480, 215, 100, 40, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12), 'center', 'center')

        if (isMouseInPosition(480, 215, 100, 40)) then 

            if not (buttonTick) then buttonTick = getTickCount() end 
            local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - buttonTick) / 300), 'Linear')
            drawBorder(10, 480, 215, 100, 40, tocolor(2, 250, 83, animation))
            dxDrawText('Concluir', 480, 215, 100, 40, tocolor(0, 0, 0, animation), 1, getFont('bold', 12), 'center', 'center')

        else

            buttonTick = nil

        end

        dxDrawImage(610, 130, 120, 140, 'assets/images/visa.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Conta', 625, 180, 32, 14, tocolor(0, 0, 0, alpha * 0.5), 1, getFont('medium', 11))
        dxDrawText(visibleBalance and 'R$'..formatNumber((getElementData(localPlayer, config.geral.element_data) or 0), '.')..',00' or '****', 625, 194, 81, 19, tocolor(0, 0, 0, alpha), 1, getFont('bold', 13))
        
    elseif (window == 'deposit') then 

        drawBorder(15, 240, 130, 355, 140, tocolor(255, 255, 255, alpha * 0.04))
        dxDrawText('Depósito', 255, 145, 35, 15, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12))
        dxDrawImage(562, 145, 18, 18, 'assets/images/card.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        drawBorder(9, 255, 170, 210, 40, tocolor(255, 255, 255, alpha * 0.08))
        dxDrawText(selectEdit == 1 and guiGetText(amountEdit)..'|' or guiGetText(amountEdit), 270, 182, 22, 15, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12))
        dxDrawText('R$', 437, 183, 13, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11), 'right')
        dxDrawImage(255, 225, 40, 30, 'assets/images/amount.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Insira a quantidade desejada.', 305, 233, 150, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))

        drawBorder(10, 480, 215, 100, 40, tocolor(255, 255, 255, alpha * 0.08))
        dxDrawText('Concluir', 480, 215, 100, 40, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12), 'center', 'center')

        if (isMouseInPosition(480, 215, 100, 40)) then 

            if not (buttonTick) then buttonTick = getTickCount() end 
            local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - buttonTick) / 300), 'Linear')
            drawBorder(10, 480, 215, 100, 40, tocolor(2, 250, 83, animation))
            dxDrawText('Concluir', 480, 215, 100, 40, tocolor(0, 0, 0, animation), 1, getFont('bold', 12), 'center', 'center')

        else

            buttonTick = nil

        end

        dxDrawImage(610, 130, 120, 140, 'assets/images/visa.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Conta', 625, 180, 32, 14, tocolor(0, 0, 0, alpha * 0.5), 1, getFont('medium', 11))
        dxDrawText(visibleBalance and 'R$'..formatNumber((getElementData(localPlayer, config.geral.element_data) or 0), '.')..',00' or '****', 625, 194, 81, 19, tocolor(0, 0, 0, alpha), 1, getFont('bold', 13))

    elseif (window == 'transfer') then  

        drawBorder(15, 240, 130, 355, 140, tocolor(255, 255, 255, alpha * 0.04))
        dxDrawText('Transferir', 255, 145, 35, 15, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12))
        dxDrawImage(562, 145, 18, 18, 'assets/images/card.png', 0, 0, 0, tocolor(255, 255, 255, alpha))


        drawBorder(9, 255, 170, 45, 40, tocolor(255, 255, 255, alpha * 0.08))
        dxDrawText(selectEdit == 1 and guiGetText(idEdit)..'|' or guiGetText(idEdit), 255, 170, 45, 40, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12), 'center', 'center')

        drawBorder(9, 310, 170, 155, 40, tocolor(255, 255, 255, alpha * 0.08))
        dxDrawText(selectEdit == 2 and guiGetText(amountEdit)..'|' or guiGetText(amountEdit), 325, 182, 22, 15, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12))
        dxDrawText('R$', 437, 183, 13, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11), 'right')
        
        dxDrawImage(255, 225, 40, 30, 'assets/images/amount.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Insira a quantidade desejada.', 305, 233, 150, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))

        drawBorder(10, 480, 215, 100, 40, tocolor(255, 255, 255, alpha * 0.08))
        dxDrawText('Concluir', 480, 215, 100, 40, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12), 'center', 'center')

        if (isMouseInPosition(480, 215, 100, 40)) then 

            if not (buttonTick) then buttonTick = getTickCount() end 
            local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - buttonTick) / 300), 'Linear')
            drawBorder(10, 480, 215, 100, 40, tocolor(2, 250, 83, animation))
            dxDrawText('Concluir', 480, 215, 100, 40, tocolor(0, 0, 0, animation), 1, getFont('bold', 12), 'center', 'center')

        else

            buttonTick = nil

        end

        dxDrawImage(610, 130, 120, 140, 'assets/images/visa.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('Conta', 625, 180, 32, 14, tocolor(0, 0, 0, alpha * 0.5), 1, getFont('medium', 11))
        dxDrawText(visibleBalance and 'R$'..formatNumber((getElementData(localPlayer, config.geral.element_data) or 0), '.')..',00' or '****', 625, 194, 81, 19, tocolor(0, 0, 0, alpha), 1, getFont('bold', 13))

    elseif (window == 'tax') then 

        drawBorder(15, 240, 130, 490, 280, tocolor(255, 255, 255, alpha * 0.04))
        dxDrawText('Impostos', 255, 145, 53, 15, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12))

        dxDrawText('Nome', 265, 175, 31, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))
        dxDrawText('Valor', 448, 175, 31, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))
        dxDrawText('Data', 558, 175, 31, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))

        local totalPrice = 0
        local line = 0 
        for i, v in ipairs(taxes) do 
            totalPrice = totalPrice + v.price 
            local preco = v.price
            if discounts and tonumber(discounts) then
                preco = preco - (preco / 100 * discounts)
            end
            if (i > pages[1] and line < 5) then 
                line = (line + 1)
                local finishTime = getRealTime(v['taxTimestamp'])
                local finishTime = string.format ( "%02d/%02d/%d", finishTime.monthday, finishTime.month +1, finishTime.year +1900)
                if (selectTax == i or isMouseInPosition(250, 197 + (42 * (line - 1)), 470, 35)) then 
                    dxDrawImage(250, 197 + (42 * (line - 1)), 470, 35, 'assets/images/tax/rectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawImage(265, 206 + (42 * (line - 1)), 17, 17, 'assets/images/card.png', 0, 0, 0, tocolor(2, 250, 83, alpha))
                    dxDrawText(v.name, 289, 208 + (42 * (line - 1)), 80, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11))
                    dxDrawText('R$'..formatNumber(preco, '.'), 448, 208 + (42 * (line - 1)), 80, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11))
                    dxDrawText(finishTime, 558, 208 + (42 * (line - 1)), 80, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11))
                    dxDrawImage(678, 204 + (42 * (line - 1)), 35, 21, 'assets/images/tax/other.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
                else
                    dxDrawImage(250, 197 + (42 * (line - 1)), 470, 35, 'assets/images/tax/stroke.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawImage(265, 206 + (42 * (line - 1)), 17, 17, 'assets/images/card.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.4))
                    dxDrawText(v.name, 289, 208 + (42 * (line - 1)), 80, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))
                    dxDrawText('R$'..formatNumber(preco, '.'), 448, 208 + (42 * (line - 1)), 80, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))
                    dxDrawText(finishTime, 558, 208 + (42 * (line - 1)), 80, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))
                    dxDrawImage(678, 204 + (42 * (line - 1)), 35, 21, 'assets/images/tax/check.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.4))
                end
            end
        end

        if discounts and tonumber(discounts) then
            totalPrice = totalPrice - (totalPrice / 100 * discounts)
        end

        if (pages[3] > 0) then 
    
            dxDrawImage(746, 160, 4, 245, 'assets/images/tax/scroll.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(746, 160 + ((245 - 95) * (pages[2] / pages[3])), 4, 95, 'assets/images/tax/scroll2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    
            if (moving) then 
    
                local start, finish = parentY + (160 * screenScale), parentY + ((160 + 245) * screenScale)
                local cx, cy = getCursorPosition()
                local mx, my = (cx * screenW), (cy * screenH)
                
                if (my < start) then 
                
                    pages[1], pages[2] = 0, 0 
                
                elseif (my > finish) then 
                
                    pages[1], pages[2] = pages[3], pages[3] 
                
                else 
    
                    local progress = my - start
                    local height = screenScale * 245
                    local percentage  = (progress / height) * 100
                    local new_page = (pages[3] / 100) * percentage 
                    pages[1], pages[2] = math.floor(new_page), new_page 
    
                end
    
                if not (getKeyState('mouse1')) then 
    
                    moving = nil 
    
                end 
            
            end
    
        end

        dxDrawImage(242, 425, 40, 30, 'assets/images/tax/card.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText('#686868Impostos: #FFFFFFR$'..formatNumber(totalPrice, '.'), 292, 433, 97, 14, tocolor(255, 255, 255, alpha), 1, getFont('medium', 11), 'left', 'top', false, false, false, true)

        dxDrawImage(630, 420, 100, 40, 'assets/images/tax/button.png', 0, 0, 0, (isMouseInPosition(630, 420, 100, 40) and tocolor(255, 255, 255, alpha) or tocolor(255, 255, 255, alpha * 0.5)))
        dxDrawText('Pagar', 630, 420, 100, 40, (isMouseInPosition(630, 420, 100, 40) and tocolor(0, 0, 0, alpha) or tocolor(0, 0, 0, alpha * 0.5)), 1, getFont('bold', 12), 'center', 'center')

    end


    if (window ~= 'tax') then   
        
        drawBorder(15, 240, 285, 490, 175, tocolor(255, 255, 255, alpha * 0.04))
        dxDrawText('Transações', 255, 300, 63, 15, tocolor(255, 255, 255, alpha), 1, getFont('bold', 12))

        local line = 0 
        for i, v in ipairs(table.reverse(registers)) do 
    
            if (i > registerPages[1] and line < 3) then 
    
                line = (line + 1)
    
                local logRealTime = getRealTime(v[3])
                local logRealTimeText = string.format ( "%02d/%02d/%d", logRealTime.monthday, logRealTime.month +1, logRealTime.year +1900)
    
                dxDrawText(logRealTimeText, 639, 336 + (40 * (line - 1)), 76, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11), 'right')
    
                if (v[2] == 'Saque') then 

                    dxDrawImage(255, 327 + (40 * (line - 1)), 40, 30, 'assets/images/negative.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawText('Você sacou R$'..v[1], 307, 335 + (40 * (line - 1)), 186, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))

                elseif (v[2] == 'Transferência') then 

                    dxDrawImage(255, 327 + (40 * (line - 1)), 40, 30, 'assets/images/negative.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawText('Você transferiu R$'..v[1], 307, 335 + (40 * (line - 1)), 186, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))

                elseif (v[2] == 'Pagamento') then 

                    dxDrawImage(255, 327 + (40 * (line - 1)), 40, 30, 'assets/images/positive.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawText('Você recebeu R$'..v[1], 307, 335 + (40 * (line - 1)), 186, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))

                else
    
                    dxDrawImage(255, 327 + (40 * (line - 1)), 40, 30, 'assets/images/positive.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawText('Você depositou R$'..v[1], 307, 335 + (40 * (line - 1)), 186, 14, tocolor(255, 255, 255, alpha * 0.4), 1, getFont('medium', 11))
    
                end
    
            end
    
        end 

        if (registerPages[3] > 0) then 
    
            dxDrawImage(746, 285, 4, 175, 'assets/images/scroll.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(746, 285 + ((175 - 95) * (registerPages[2] / registerPages[3])), 4, 95, 'assets/images/scroll2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
    
            if (moving) then 
    
                local start, finish = parentY + (285 * screenScale), parentY + ((285 + 175) * screenScale)
                local cx, cy = getCursorPosition()
                local mx, my = (cx * screenW), (cy * screenH)
                
                if (my < start) then 
                
                    registerPages[1], registerPages[2] = 0, 0 
                
                elseif (my > finish) then 
                
                    registerPages[1], registerPages[2] = registerPages[3], registerPages[3] 
                
                else 
    
                    local progress = my - start
                    local height = screenScale * 175
                    local percentage  = (progress / height) * 100
                    local new_page = (registerPages[3] / 100) * percentage 
                    registerPages[1], registerPages[2] = math.floor(new_page), new_page 
    
                end
    
                if not (getKeyState('mouse1')) then 
    
                    moving = nil 
    
                end 
            
            end
    
        end

    end

end



addEventHandler('onClientKey', root, 



    function(key, press) 



        if (isEventHandlerAdded('onClientRender', root, drawBank) and press) then 

            if (window == 'tax') then 

                if (key == 'mouse_wheel_down') then 
    
    
    
                    pages[1] = pages[1] + 1
    
                    if (pages[1] > #taxes - 5) then
    
                    
    
                        pages[1] = #taxes - 5
    
                    
    
                    end
    
                    pages[2] = pages[1]
    
    
    
                elseif (key == 'mouse_wheel_up') then 
    
    
    
                    if (pages[1] > 0) then
    
    
    
                        pages[1] = pages[1] - 1
    
                        pages[2] = pages[1]
    
    
    
                    end
    
    
    
                end

            else

                if (key == 'mouse_wheel_down') then 
    
    
    
                    registerPages[1] = registerPages[1] + 1
    
                    if (registerPages[1] > #registers - 3) then
    
                    
    
                        registerPages[1] = #registers - 3
    
                    
    
                    end
    
                    registerPages[2] = registerPages[1]
    
    
    
                elseif (key == 'mouse_wheel_up') then 
    
    
    
                    if (registerPages[1] > 0) then
    
    
    
                        registerPages[1] = registerPages[1] - 1
    
                        registerPages[2] = registerPages[1]
    
    
    
                    end
    
    
    
                end

            end


        end



    end



)


addEventHandler('onClientClick', root, 



    function(b, s) 



        if (b == 'left' and s == 'down') then 



            if (isEventHandlerAdded('onClientRender', root, drawBank)) then 


                selectEdit = 0

                if (guiGetText(amountEdit) == '') then 

                    guiSetText(amountEdit, 'Valor')

                end

                if (guiGetText(idEdit) == '') then 

                    guiSetText(idEdit, 'ID')

                end

                for i, v in ipairs(windows) do 

                    if (isMouseInPosition(15, 286 + (43 * (i - 1)), 190, 35)) then 

                        window = v[5]
                        windowBarTick = getTickCount()

                    return end

                end

                if (isMouseInPosition(172, 143, 18, 18)) then 

                    visibleBalance = not visibleBalance 

                elseif (isMouseInPosition(746, 285, 4, 175)) or (isMouseInPosition(746, 160, 4, 245)) then 

                    moving = true

                elseif (window == 'tax') then 

                    if (isMouseInPosition(630, 420, 100, 40)) then
                        
                        if (selectTax ~= 0) then 

                            if (taxes[selectTax].typeTax == 'house') then

                                triggerServerEvent('onPlayerBuyHomeTax', root, localPlayer, taxes[selectTax].name)
                                
                            else
                                
                                triggerServerEvent('onPlayerBuyVehicleTax', root, localPlayer, taxes[selectTax].model)

                            end

                            triggerServerEvent('onPlayerRefreshTaxBank', resourceRoot, localPlayer)
                            selectTax = 0

                        end 

                    else

                        local line = 0 
                        for i, v in ipairs(taxes) do 
                
                            if (i > pages[1] and line < 5) then 
                
                                line = (line + 1)
                
                                if (isMouseInPosition(250, 197 + (42 * (line - 1)), 470, 35)) then 
                                    
                                    selectTax = i 
                
                                return end 
                
                            end
                            
                        end

                    end

                elseif (window == 'deposit') then 

                    if (isMouseInPosition(255, 170, 210, 40)) then 

                        if (guiEditSetCaretIndex(amountEdit, #guiGetText(amountEdit))) then 



                            guiBringToFront(amountEdit)

                            guiSetInputMode('no_binds_when_editing')

    

                            selectEdit = 1

                            if (guiGetText(amountEdit) == 'Valor') then 



                                guiSetText(amountEdit, '')



                            end



                        end

                    elseif (isMouseInPosition(480, 215, 100, 40)) then 

                        if verifyNumber(guiGetText(amountEdit)) then 

                            return config.notifyC('Digite uma quantidade válida!', 'error') 
    
                        end 

                        triggerServerEvent('onPlayerDeposit', localPlayer, localPlayer, guiGetText(amountEdit))

                    end
                    

                elseif (window == 'withdraw') then 

                    if (isMouseInPosition(255, 170, 210, 40)) then 

                        if (guiEditSetCaretIndex(amountEdit, #guiGetText(amountEdit))) then 

                            guiBringToFront(amountEdit)
                            guiSetInputMode('no_binds_when_editing')

                            selectEdit = 1
                            if (guiGetText(amountEdit) == 'Valor') then 

                                guiSetText(amountEdit, '')

                            end

                        end

                    elseif (isMouseInPosition(480, 215, 100, 40)) then 

                        if verifyNumber(guiGetText(amountEdit)) then 

                            return config.notifyC('Digite uma quantidade válida!', 'error') 
    
                        end 

                        triggerServerEvent('onPlayerWithdraw', localPlayer, localPlayer, guiGetText(amountEdit))

                    end

                elseif (window == 'transfer') then 

                    if (isMouseInPosition(255, 170, 45, 40)) then 

                        if (guiEditSetCaretIndex(idEdit, #guiGetText(idEdit))) then 

                            guiBringToFront(idEdit)
                            guiSetInputMode('no_binds_when_editing')

                            selectEdit = 1
                            if (guiGetText(idEdit) == 'ID') then 

                                guiSetText(idEdit, '')

                            end

                        end

                    elseif (isMouseInPosition(310, 170, 155, 40)) then 

                        if (guiEditSetCaretIndex(amountEdit, #guiGetText(amountEdit))) then 

                            guiBringToFront(amountEdit)
                            guiSetInputMode('no_binds_when_editing')

                            selectEdit = 2
                            if (guiGetText(amountEdit) == 'Valor') then 

                                guiSetText(amountEdit, '')

                            end

                        end

                    elseif (isMouseInPosition(480, 215, 100, 40)) then  

                        if verifyNumber(guiGetText(amountEdit)) then 

                            return config.notifyC('Digite uma quantidade válida!', 'error') 
    
                        end 

                        triggerServerEvent('onPlayerTransfer', localPlayer, localPlayer, guiGetText(idEdit), guiGetText(amountEdit))

                    end

                end

            end

        end

    end

)



addEvent('onClientDrawBank', true)

addEventHandler('onClientDrawBank', root, 



    function(registers_, index_, bankData_, taxes_, discounts_)



        if not (isEventHandlerAdded('onClientRender', root, drawBank)) then 

            discounts = discounts_
            tick, interpolate, window, page, index, registers, confirmAction, bankData, windowBarTick = getTickCount(), {0, 255}, 'withdraw', 0, index_, registers_, nil, bankData_, getTickCount()
            taxes, pages, selectTax = taxes_, {0, 0, #taxes_ - 5}, 0

            addEventHandler('onClientRender', root, drawBank)

            showCursor(true)

            showChat(false)



            if (isElement(amountEdit)) then 

                destroyElement(amountEdit) 

            end



            amountEdit = guiCreateEdit(0, 0, 0, 0, 'Valor', false)

            guiEditSetMaxLength(amountEdit, 11)

            guiSetProperty(amountEdit, 'ValidationString', '[0-9]*')



            if (isElement(idEdit)) then 

                destroyElement(idEdit) 

            end



            idEdit = guiCreateEdit(0, 0, 0, 0, 'ID', false)

            guiEditSetMaxLength(idEdit, 11)



            registerPages = {0, 0, #registers - 3}



        end



    end



)



function removeBank()



    if (isEventHandlerAdded('onClientRender', root, drawBank)) then 



        if (interpolate[1] == 0) then 



            tick, interpolate = getTickCount(), {255, 0}

            showCursor(false)

            showChat(true)

            setTimer(function()



                removeEventHandler('onClientRender', root, drawBank)



            end, 500, 1)



        end



    end



end
bindKey('backspace', 'down', removeBank)

addEvent('onClientCloseBank', true)

addEventHandler('onClientCloseBank', root, removeBank)

addEvent('onClientReceiveTaxesBank', true)
addEventHandler('onClientReceiveTaxesBank', root, 

    function(taxes_)

        taxes, pages, selectTax = taxes_, {0, 0, #taxes_ - 5}, 0

    end

)


addEvent('onClientReceiveBankRegisters', true)

addEventHandler('onClientReceiveBankRegisters', root, 



    function(registers_)



        registers = registers_

        registerPages[3] = #registers - 3



    end



)

