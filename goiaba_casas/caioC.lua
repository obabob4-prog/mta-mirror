    local screenW, screenH = guiGetScreenSize();

    local screenScale = math.min(math.max(screenH / 768, 0.70), 2); -- Caso o painel seja muito grande, retirar o limite e deixar apenas o (screenH / 768).

    

    parentW, parentH = (720 * screenScale), (547 * screenScale); -- Comprimento e Largura do painel.

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

    

    function createEditbox (action, length, number)

        if action then

            if not edit then

                edit = {}

            end

            local editbox = guiCreateEdit(0, 0, 0, 0, '')

            if length then

                guiEditSetMaxLength(editbox, length)

                if number then

                    guiSetProperty(editbox, 'ValidationString', '[0-9]*')

                end

            end

            edit[action] = editbox

        end

    end

    

    function removeEditbox (action)

        if action == 'all' then

            for _, v in pairs(edit) do

                if isElement(v) then

                    destroyElement(v)

                end

            end

            edit = nil

        end

    end

    

    function setEditboxEditing (action)

        if guiEditSetCaretIndex(edit[action], string.len(guiGetText(edit[action]))) then

            guiBringToFront(edit[action])

            guiSetInputMode('no_binds_when_editing')

            editselect = action

        end

    end

    

    function getEditboxValue (action, drawing)

        if (drawing == true) then

            local editbox = guiGetText(edit[action])

            if editselect == action then

                return editbox..'|'

            else

                return (editbox == '' and action or editbox)

            end

        else

            local editbox = guiGetText(edit[action])

            return editbox

        end

    end

    

    local svgs = {

    

        ['homes'] = svgCreate(12, 11, 

    

            [[

                <svg width="12" height="11" viewBox="0 0 12 11" fill="none" xmlns="http://www.w3.org/2000/svg">

                    <g clip-path="url(#clip0_10129_1038)">

                    <path d="M6.56555 0.233503C6.41554 0.083991 6.21211 0 6 0C5.78789 0 5.58446 0.083991 5.43445 0.233503L0.117295 5.53381C0.0801082 5.57088 0.0506097 5.6149 0.0304841 5.66334C0.0103585 5.71178 0 5.7637 0 5.81613C0 5.86856 0.0103585 5.92048 0.0304841 5.96892C0.0506097 6.01736 0.0801082 6.06138 0.117295 6.09845C0.192398 6.17333 0.29426 6.21539 0.400472 6.21539C0.453062 6.21539 0.505138 6.20507 0.553725 6.185C0.602313 6.16494 0.64646 6.13553 0.683648 6.09845L6 0.797348L11.3164 6.09845C11.3915 6.17333 11.4933 6.21539 11.5995 6.21539C11.7057 6.21539 11.8076 6.17333 11.8827 6.09845C11.9578 6.02358 12 5.92202 12 5.81613C12 5.71024 11.9578 5.60869 11.8827 5.53381L9.99966 3.65725V1.03102C9.99966 0.925263 9.95752 0.823838 9.88252 0.749056C9.80751 0.674274 9.70577 0.632262 9.5997 0.632262H8.79976C8.69369 0.632262 8.59195 0.674274 8.51695 0.749056C8.44194 0.823838 8.3998 0.925263 8.3998 1.03102V2.06221L6.56555 0.233503Z" fill="white" fill-opacity="0.8"/>

                    <path d="M6.00004 1.66345L10.7996 6.44856V9.80372C10.7996 10.121 10.6732 10.4253 10.4482 10.6496C10.2232 10.874 9.91797 11 9.59973 11H2.40034C2.08211 11 1.77691 10.874 1.55188 10.6496C1.32686 10.4253 1.20044 10.121 1.20044 9.80372V6.44856L6.00004 1.66345Z" fill="white" fill-opacity="0.8"/>

                    </g>

                    <defs>

                    <clipPath id="clip0_10129_1038">

                    <rect width="12" height="11" fill="white"/>

                    </clipPath>

                    </defs>

                </svg>

            ]]

    

        );

    

    }

    

    local animation = { initial = 0, finish = 0, time = 150, tick = 0, current = 0, easing = 'Linear' }

    

    imoveis = {}

    local buyEffects, eyeEffects = {}, {}

    local tabs = {

    

        {'Imóveis', 506 - 10, 94, 35, 13};

        {'Minhas propriedades', 556 - 10, 94, 92, 13};


    }

    

    local fonts = {
        exports['goiaba_fonts']:useFont('sf:medium', respC(12/1.25)) or 'default',
        exports['goiaba_fonts']:useFont('sf:regular', respC(11/1.25)) or 'default',
        exports['goiaba_fonts']:useFont('sf:regular', respC(10/1.25)) or 'default',
        exports['goiaba_fonts']:useFont('sf:medium', respC(11/1.25)) or 'default',
        exports['goiaba_fonts']:useFont('sf:medium', respC(13/1.25)) or 'default',
    }

    addEventHandler("onClientResourceStart", root, function(res)
        if getResourceName(res) == "goiaba_fonts" then
            fonts = {
                exports['goiaba_fonts']:useFont('sf:medium', respC(12/1.25)) or 'default',
                exports['goiaba_fonts']:useFont('sf:regular', respC(11/1.25)) or 'default',
                exports['goiaba_fonts']:useFont('sf:regular', respC(10/1.25)) or 'default',
                exports['goiaba_fonts']:useFont('sf:medium', respC(11/1.25)) or 'default',
                exports['goiaba_fonts']:useFont('sf:medium', respC(13/1.25)) or 'default',
            }
        end
    end)
    

    function render_imobiliaria ()

    

        cursor.state = isCursorShowing ();

        if (cursor.state) then

            local cursorX, cursorY = getCursorPosition ();

            cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;

        end

    

        animation.current = interpolateBetween (animation.initial, 0, 0, animation.finish, 0, 0, (getTickCount ( ) - animation.tick) / animation.time, animation.easing)     

        local alpha = animation.current

    

        dxDrawImage(0, 0, 720, 547, 'assets/images/bg.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('Imobiliária', 29, 26, 56, 15, tocolor(255, 255, 255, alpha * 0.8), 1, fonts[1])

        dxDrawText('#979797Bem-vindo a imobiliária #FFFFFFGoHouse#979797, onde agente realiza o\nseus sonhos imobiliarios', 29, 42, 246, 26, tocolor(255, 255, 255, alpha * 0.6), 1, fonts[2], 'left', 'top', false, false, false, true)

    

        dxDrawImage(685, 23, 12, 12, 'assets/images/exit.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.15))

    

        if (isMouseInPosition(685, 23, 12, 12)) then 

    

            if not (exitTick) then exitTick = getTickCount() end 

            local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - exitTick) / 300), 'Linear')

            dxDrawImage(685, 23, 12, 12, 'assets/images/exit.png', 0, 0, 0, tocolor(67, 182, 80, animation))

    

        else

    

            exitTick = nil

    

        end

    

        drawBorder(1, 29, 74, 120, 1, tocolor(255, 255, 255, alpha * 0.05))

        dxDrawImage(29, 86, 8, 9, 'assets/images/gps.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(getZoneName(getElementPosition(localPlayer)), 44, 85, 70, 13, tocolor(255, 255, 255, alpha * 0.35), 1, fonts[2])

    

        for i, v in ipairs(tabs) do 

    

            if (select == v[1] or isMouseInPosition(v[2], v[3], v[4], v[5])) then 

    

                dxDrawText(v[1], v[2], v[3], v[4], v[5], tocolor(255, 255, 255, alpha * 0.8), 1, fonts[4])

                

            else

    

                dxDrawText(v[1], v[2], v[3], v[4], v[5], tocolor(255, 255, 255, alpha * 0.05), 1, fonts[3])

            

            end

    

        end

    

        if select == 'Imóveis' then

    

            dxDrawImage(28, 141, 12, 11, 'assets/images/homes.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawText('Imóveis', 44, 139, 44, 16, tocolor(255, 255, 255, alpha * 0.8), 1, fonts[5])

            dxDrawText('Residencias disponiveis para compra na cidade, veja a melhor opção o senhor(a) para viver no maior conforto possivel', 28, 156, 44, 16, tocolor(255, 255, 255, alpha * 0.35), 1, fonts[2])

    

            local x, y = 0, 0 

            if #imoveis > 0 then

    

                linha = 0

                for i, v in ipairs(imoveis) do

    

                    if (i > proxPag and linha < 10) then

    

                        linha = linha + 1

    

                        drawBorder(9, 28 + x, 182 + y, 121, 157, tocolor(255, 255, 255, alpha * 0.01))

                        dxDrawImage(math.floor(88 - (v.image.size[1] / 2)) + x, math.floor(229 - (v.image.size[2]/ 2)) + y, v.image.size[1], v.image.size[2], v.image.file, 0, 0, 0, tocolor(255, 255, 255, alpha))

                        dxDrawText(v.name, 57 + x, 260 + y, 63, 13, tocolor(255, 255, 255, alpha * 0.8), 1, fonts[4], 'center')

                        dxDrawText(getZoneName(Vector3(v.house_outside.pos)), 64 + x, 273 + y, 47, 13, tocolor(255, 255, 255, alpha * 0.25), 1, fonts[2], 'center')

    

                        dxDrawImage(28 + x, 305 + y, 87, 34, 'assets/images/rectangle.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.02))

                        dxDrawText('Marcar', 28 + x, 305 + y, 87, 34, tocolor(255, 255, 255, alpha * 0.6), 1, fonts[4], 'center', 'center')

    

                        if (isMouseInPosition(28 + x, 305 + y, 87, 34)) then 

    

                            if not (buyEffects[i]) then buyEffects[i] = getTickCount() end 

                            local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - buyEffects[i]) / 300), 'Linear')

                            dxDrawImage(28 + x, 305 + y, 87, 34, 'assets/images/rectangle.png', 0, 0, 0, tocolor(67, 182, 80, animation))

                            dxDrawText('Marcar', 28 + x, 305 + y, 87, 34, tocolor(23, 23, 23, animation), 1, fonts[4], 'center', 'center')

                        

    

                        else

    

                            buyEffects[i] = nil 

    

                        end

    

                        dxDrawImage(115 + x, 305 + y, 34, 34, 'assets/images/rectangle2.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.01))

                        dxDrawImage(126 + x, 318 + y, 13, 9, 'assets/images/eye.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.15))

    

                        if (isMouseInPosition(115 + x, 305 + y, 34, 34)) then 

    

                            if not (eyeEffects[i]) then eyeEffects[i] = getTickCount() end 

                            local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - eyeEffects[i]) / 300), 'Linear')

                            dxDrawImage(115 + x, 305 + y, 34, 34, 'assets/images/rectangle2.png', 0, 0, 0, tocolor(67, 182, 80, animation))

                            dxDrawImage(126 + x, 318 + y, 13, 9, 'assets/images/eye.png', 0, 0, 0, tocolor(23, 23, 23, animation))

                        

    

                        else

    

                            eyeEffects[i] = nil 

    

                        end

    

                        x = x + 136 

                        if (x >= 664) then 

    

                            x = 0 

                            y = y + 172 

    

                        end

                    

                    end

    

                end

    

            end

    

        elseif (select == 'Minhas propriedades') then 

    

            dxDrawImage(28, 141, 13, 12, 'assets/images/myHouses.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawText('Suas propriedades', 45, 139, 44, 16, tocolor(255, 255, 255, alpha * 0.8), 1, fonts[5])

            dxDrawText('Cuidado, ao vender sua casa para própria imobiliária você receberá apenas 60% do valor dela.', 28, 156, 44, 16, tocolor(255, 255, 255, alpha * 0.35), 1, fonts[2])

            

            local x, y = 0, 0 

            if #myHouses > 0 then

    

                linha = 0

                for i, v in ipairs(myHouses) do

    

                    if (i > proxPag and linha < 10) then

    

                        linha = linha + 1

    

                        drawBorder(9, 28 + x, 182 + y, 121, 157, tocolor(255, 255, 255, alpha * 0.01))

    

                        dxDrawImage(math.floor(88 - (v.image.size[1] / 2)) + x, math.floor(229 - (v.image.size[2]/ 2)) + y, v.image.size[1], v.image.size[2], v.image.file, 0, 0, 0, tocolor(255, 255, 255, alpha))

                        dxDrawText(v.name, 57 + x, 260 + y, 63, 13, tocolor(255, 255, 255, alpha * 0.8), 1, fonts[4], 'center')

                        dxDrawText(getZoneName(Vector3(v.house_outside.pos)), 64 + x, 273 + y, 47, 13, tocolor(255, 255, 255, alpha * 0.25), 1, fonts[2], 'center')

                        dxDrawText('R$ '..formatNumber(v.price), 64 + x, 286 + y, 47, 13, tocolor(255, 255, 255, alpha * 0.25), 1, fonts[2], 'center')

    

                        dxDrawImage(28 + x, 305 + y, 121, 34, 'assets/images/rectangle3.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.02))

                        dxDrawText('Vender residência', 28 + x, 305 + y, 121, 34, tocolor(255, 255, 255, alpha * 0.6), 1, fonts[4], 'center', 'center')

    

                        if (isMouseInPosition(28 + x, 305 + y, 121, 34)) then 

    

                            if not (buyEffects[i]) then buyEffects[i] = getTickCount() end 

                            local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - buyEffects[i]) / 300), 'Linear')

                            dxDrawImage(28 + x, 305 + y, 121, 34, 'assets/images/rectangle3.png', 0, 0, 0, tocolor(67, 182, 80, animation))

                            dxDrawText('Vender residência', 28 + x, 305 + y, 121, 34, tocolor(23, 23, 23, animation), 1, fonts[4], 'center', 'center')

                        

    

                        else

    

                            buyEffects[i] = nil 

    

                        end

    

                        x = x + 136 

                        if (x >= 664) then 

    

                            x = 0 

                            y = y + 172 

    

                        end

    

                    end

    

                end

    

            end

        end

    

    end

    

    addEvent('impostosClient', true)

    addEventHandler('impostosClient', root, function (valor)

        imposto = valor

    end)

    

    function click_imobiliaria (button, state)

        if visible and not closing then

            if button == 'left' and state == 'down' then

    

                for i, v in ipairs(tabs) do 

    

                    if (isMouseInPosition(v[2], v[3], v[4], v[5])) then 

    

                        select = v[1]

                        proxPag = 0

            

                    return end

            

                end

            

                if (isMouseInPosition(685, 23, 12, 12)) then 

    

                    imobiliariaPanel('close')

    

                end

    

                if select == 'Imóveis' then

                    

                    local x, y = 0, 0 

                    if #imoveis > 0 then

                    

                        linha = 0

                        for i, v in ipairs(imoveis) do

                        

                            if (i > proxPag and linha < 10) then

                            

                                linha = linha + 1

                            

                                if (isMouseInPosition(28 + x, 305 + y, 87, 34)) then 

                                

                                    triggerServerEvent('marcarHouseSystem', localPlayer, localPlayer, v.house_outside.pos)

                                

                                return elseif (isMouseInPosition(115 + x, 305 + y, 34, 34)) then 

                                

                                    imobiliariaPanel('close')

                                    visiteImobiliaria(v)

                                

                                return end

                                

                                x = x + 136 

                                if (x >= 664) then 

                                

                                    x = 0 

                                    y = y + 172 

                                

                                end

                            

                            end

                        

                        end

                    

                    end

    

                elseif select == 'Minhas propriedades' then

    

                    local x, y = 0, 0 

                    if #myHouses > 0 then

                    

                        linha = 0

                        for i, v in ipairs(myHouses) do

                        

                            if (i > proxPag and linha < 10) then

                            

                                linha = linha + 1

                            

                                if (isMouseInPosition(28 + x, 305 + y, 121, 34)) then 

                                

                                    triggerServerEvent('venderHouse', localPlayer, v.name)

                                

                                return end

                            

                                x = x + 136 

                                if (x >= 664) then 

                                

                                    x = 0 

                                    y = y + 172 

                                

                                end

                            

                            end

                        

                        end

                    

                    end

    

                else

                    if (isMouseInPosition(149, 193, 135, 30)) then 

                        triggerServerEvent('pagarImpostos', localPlayer)

                    end

                end

            end

        end

    end

    

    function visiteImobiliaria (infos)

        if infos then

            config.notify('client', _, 'Você está visitando a casa '..infos.name..', você tem 20 segundos.', 'info')

            setElementInterior(localPlayer, infos.house_inside.interior, infos.house_inside.pos[1], infos.house_inside.pos[2], infos.house_inside.pos[3])

            setElementRotation(localPlayer, 0, 0, infos.house_inside.rot)

            setTimer(function ()

                if config.imobiliaria then

                    triggerServerEvent('voltarParaImobiliaria', resourceRoot, localPlayer)

                end

            end, 20000, 1)

        end

    end

    

    function key_imobiliaria (button, press)  

        if (button == 'mouse_wheel_down' and press) then

    

            if (proxPag < ((select == 'Imóveis' and #imoveis or #myHouses) - 10)) then 

    

                proxPag = proxPag + 5 

    

            end 

        elseif (button == 'mouse_wheel_up' and press) then

            if (proxPag > 0) then

                proxPag = proxPag - 5

            end

        end

    end

    

    function imobiliariaPanel (state)

        if state == 'open' and not visible then

            visible = true

            animation.initial, animation.finish, animation.tick = animation.current, 255, getTickCount()

            select = tabs[1]        

            proxPag = 0

            select = 'Imóveis'

            showCursor(true)

            addEventHandler('onClientRender', root, render_imobiliaria)

            addEventHandler('onClientClick', root, click_imobiliaria)

            addEventHandler('onClientKey', root, key_imobiliaria)

            showChat(false)

        elseif state == 'close' and visible then

            if not closing then

                closing = true

                animation.initial, animation.finish, animation.tick = animation.current, 0, getTickCount()

                showCursor(false)

                setTimer (function ()

                    visible = false

                    closing = false

                    removeEventHandler('onClientRender', root, render_imobiliaria)

                    removeEventHandler('onClientClick', root, click_imobiliaria)

                    removeEventHandler('onClientKey', root, key_imobiliaria)

                    showChat(true)

                end, animation.time + 50, 1)

            end

        end

    end

    addEvent('imobiliariaPanel', true)

    addEventHandler('imobiliariaPanel', root, imobiliariaPanel)

    

    addEvent('housesReceiver', true)

    addEventHandler('housesReceiver', root, function (tab, createdHouses)

        local tabbbb = {}

        local backup = {}

        if createdHouses then

            for index, value in ipairs(createdHouses) do

                local infos = fromJSON(value['houseData'])

                table.insert(tabbbb, infos)

                table.insert(backup, infos)

            end

        end

        imoveis = tabbbb

        if tab then

            housesComprada = {}

            for _, value in ipairs(tab) do

                housesComprada[value['namehouse']] = true

            end

            remover = {}

            for i, v in ipairs(imoveis) do

                if (housesComprada[v.name] == true) then

                    table.insert(remover, i)

                elseif (v.house_inside.pos[1] == 2308.79 and v.house_inside.pos[2] == -1212.88 and v.house_inside.pos[3] == 1049.02) then

                    table.insert(remover, i)

                end

            end

            remover = table.reverse(remover)

            for i, v in ipairs(remover) do

                table.remove(imoveis, v)

            end

        end

        myHouses = {}

        if tab then

            local userid = getElementData(localPlayer, 'ID') or 'n/a'

            for i, v in ipairs(tab) do

                local json = fromJSON(v['infos'])

                if json.dono == userid then

                    local info = getHouse(v['namehouse'], backup)

                    if info then

                        table.insert(myHouses, info)

                    end

                end

            end

        end

    end)

    

    function getHouse (casaname, tabela)

        for i, houseData in ipairs(tabela) do

            if houseData.name == casaname then

                return houseData

            end

        end

        return nil

    end

    

    function table.reverse(t) 

        local reversedTable = {} 

        local itemCount = #t  

        for k, v in ipairs(t) do 

            reversedTable[itemCount + 1 - k] = v  

        end 

        return reversedTable  

    end 

    

    -------------------

    

    fonts['house'] = {

    

        exports['goiaba_fonts']:useFont('sf:medium', respC(11/1.25)),

        exports['goiaba_fonts']:useFont('sf:medium', respC(10/1.25)) 

    

    }

    

    function render_house ()

    

        cursor.state = isCursorShowing ();

        if (cursor.state) then

            local cursorX, cursorY = getCursorPosition ();

            cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;

        end

    

        animation.current = interpolateBetween (animation.initial, 0, 0, animation.finish, 0, 0, (getTickCount ( ) - animation.tick) / animation.time, animation.easing)     

        local alpha = animation.current

    

        if (buyHouse) then 

    

            dxDrawText('PRESSIONE [E] PARA COMPRAR A CASA POR R$'..formatNumber(buyHouse.price, '.'), 0, 0, 720, 547, tocolor(255, 255, 255, alpha * 0.85), 1, fonts['house'][1], 'center', 'center')

    

        return end

    

        drawBorder(15, 208, 182, 304, 183, tocolor(22, 22, 22, alpha))

        dxDrawImage(228, 211, 10, 10, 'assets/images/settings.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('Gerencia Casa', 244, 209, 69, 14, tocolor(255, 255, 255, alpha * 0.8), 1, fonts['house'][1])

        dxDrawText('Gerencia as configurações da sua residencia', 228, 223, 69, 14, tocolor(255, 255, 255, alpha * 0.35), 1, fonts['house'][2])

    

        dxDrawImage(480, 210, 12, 12, 'assets/images/exit.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.15))

    

        if (isMouseInPosition(480, 210, 12, 12)) then 

    

            if not (exitTick) then exitTick = getTickCount() end 

            local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - exitTick) / 300), 'Linear')

            dxDrawImage(480, 210, 12, 12, 'assets/images/exit.png', 0, 0, 0, tocolor(67, 182, 80, animation))

    

        else

    

            exitTick = nil

    

        end

    

        if house.status == 'Trancado' then

            text = 'A casa está trancada'

        else

            text = 'A casa está liberada'

        end

        dxDrawText(text, 208, 182-8, 304, 183, tocolor(255, 255, 255, alpha * 0.15), 1, fonts[2], 'center', 'bottom')



        drawBorder(5, 228, 250, 264, 35, isMouseInPosition(228, 250, 264, 35) and tocolor(96, 191, 76, alpha) or tocolor(96, 191, 76, alpha * 0.3))

        dxDrawText('Entrar na casa', 228, 250, 264, 35, isMouseInPosition(228, 250, 264, 35) and tocolor(255, 255, 255, alpha) or tocolor(96, 191, 76, alpha), 1, fonts[2], 'center', 'center')

    

        drawBorder(5, 228, 300, 264, 35, tocolor(255, 255, 255, alpha * 0.01))

    

        if (isMouseInPosition(272, 312, 34, 13)) then 

    

            dxDrawText('Trancar', 272, 312, 34, 13, tocolor(255, 255, 255, alpha * 0.35), 1, fonts[1])

    

        else 

    

            dxDrawText('Trancar', 272, 312, 34, 13, tocolor(255, 255, 255, alpha * 0.15), 1, fonts[1])

    

        end

    

        if (isMouseInPosition(410, 312, 48, 13)) then 

    

            dxDrawText('Destrancar', 410, 312, 48, 13, tocolor(255, 255, 255, alpha * 0.35), 1, fonts[1])

    

        else 

    

            dxDrawText('Destrancar', 410, 312, 48, 13, tocolor(255, 255, 255, alpha * 0.15), 1, fonts[1])

    

        end

    

        dxDrawImage(352, 308, 20, 20, 'assets/images/lock2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

    

    end

    

    addEventHandler('onClientKey', root, 

    

        function(key, press)

    

            if visible and press and buyHouse then

    

                if (key == 'e' or key == 'E') then 

                    

                    triggerServerEvent('buyHouse', resourceRoot, localPlayer, buyHouse)

                    openHouse('close')

    

                end

    

            end

    

    

        end

    

    )

    

    function click_house (button, state)

        if button == 'left' and state == 'down' and visible then

    

            if (buyHouse) then 

    

                return 

    

            end 

    

            editselect = nil

            

            if (isMouseInPosition(480, 210, 12, 12)) then 

    

                openHouse('close')

    

            elseif (isMouseInPosition(228, 250, 264, 35)) then 

    

                triggerServerEvent('enterHouse', localPlayer, house)

    

            elseif (isMouseInPosition(272, 312, 34, 13)) then 

                

                triggerServerEvent('alterStatus', localPlayer, house, 'trancar')

    

            elseif (isMouseInPosition(410, 312, 48, 13)) then 

    

                triggerServerEvent('alterStatus', localPlayer, house, 'destrancar')

    

            end

        end

    end

    

    function openHouse (state, housee, buyHouse_)

        if state == 'open' and not visible then

    

            buyHouse = buyHouse_

            house = housee

            visible = true

            animation.initial, animation.finish, animation.tick = animation.current, 255, getTickCount()     

            showCursor(true)

            addEventHandler('onClientRender', root, render_house)

            addEventHandler('onClientClick', root, click_house)

            createEditbox('Senha', 8)

            createEditbox('Valor', 9, true)

            createEditbox('Passaporte', 8, true)

    

            if (buyHouse) then 

    

                showCursor(false)

    

            end 

            

        elseif state == 'close' and visible then

            if not closing then

                closing = true

                animation.initial, animation.finish, animation.tick = animation.current, 0, getTickCount()

                showCursor(false)

                setTimer (function ()

                    visible = false

                    closing = false

                    removeEventHandler('onClientRender', root, render_house)

                    removeEventHandler('onClientClick', root, click_house)

                    removeEditbox('all')

                end, animation.time + 50, 1)

            end

        elseif (state == 'receive') then

            house = housee

        end

    end

    addEvent('openHouse', true)

    addEventHandler('openHouse', root, openHouse)