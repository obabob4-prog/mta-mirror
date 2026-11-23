
-- // UTIL CLIENT 

local screenW, screenH = guiGetScreenSize()
local sx, sy = (screenW/1360), (screenH/768)

local function aToR(X, Y, sX, sY)

    local xd = X/1920 or X
    local yd = Y/1080 or Y
    local xsd = sX/1920 or sX
    local ysd = sY/1080 or sY

    return math.floor(xd * screenW), math.floor(yd * screenH), math.floor(xsd * screenW), math.floor(ysd * screenH)

end

local _dxDrawCircle = dxDrawCircle
local function dxDrawCircle(x, y, w, h, ...)

    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawCircle(x, y, w, h, ...)

end

local _dxDrawRectangle = dxDrawRectangle
local function dxDrawRectangle(x, y, w, h, ...)

    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawRectangle(x, y, w, h, ...)

end

local _dxDrawText = dxDrawText
local function dxDrawText(text, x, y, w, h, color, fontSize, font, ...)

    local x, y, w, h = aToR(x, y, w + x, h + y)
    if not isElement(font) then return end
    return _dxDrawText(text, x, y, w, h, color, fontSize, font, ...)

end

local _dxDrawImage = dxDrawImage
local function dxDrawImage(x, y, w, h, ...)

    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawImage(x, y, w, h, ...)

end

local _dxDrawImageSection = dxDrawImageSection
local function dxDrawImageSection(x, y, w, h, ...)
    
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawImageSection(x, y, w, h, ...)

end

--| Cursor 

local cursor = {};
local function cursorUpdate ()

    cursor.state = isCursorShowing ();
    if (cursor.state) then

        local cursorX, cursorY = getCursorPosition ();
        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;

    end

end

local function isMouseInPosition(x, y, width, heigth)

    local x, y, width, heigth = aToR(x, y, width, heigth)
    if not (cursor.state) then

        return false;

    end

    return (( cursor.x >= x and cursor.x <= x + width ) and ( cursor.y >= y and cursor.y <= y + heigth ));

end

local function isCursorOnElement(x, y, width, heigth)

    local x, y, width, heigth = aToR(x, y, width, heigth)
    if not (cursor.state) then

        return false;

    end

    return (( cursor.x >= x and cursor.x <= x + width ) and ( cursor.y >= y and cursor.y <= y + heigth ));

end

local function isMouseInPosition(x, y, width, heigth)

    local x, y, width, heigth = aToR(x, y, width, heigth)
    if not (cursor.state) then

        return false;

    end

    return (( cursor.x >= x and cursor.x <= x + width ) and ( cursor.y >= y and cursor.y <= y + heigth ));

end

--| SVG Rectangles
local svgRectangles = {}
local function dxDrawRoundedRectangle(x, y, w, h, color, radius, post)

    if not svgRectangles[radius] then

        local Path = string.format([[

            <svg width="%s" height="%s" viewBox="0 0 %s %s" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect opacity="1" width="%s" height="%s" rx="%s" fill="#FFFFFF"/>
            </svg>

        ]], w, h, w, h, w, h, radius)



        svgRectangles[radius] = svgCreate(sx*w, sy*h, Path)
        dxSetTextureEdge(svgRectangles[radius], "border")

    end

    if svgRectangles[radius] then

        --dxSetBlendMode("modulate_add")
        dxDrawImage(x, y, w, h, svgRectangles[radius], 0, 0, 0, color, post)
        --dxSetBlendMode("blend")

    end

end

local function _dxDrawRoundedRectangle(x, y, w, h, color, radius, post)

    if not svgRectangles[radius] then

        local Path = string.format([[

            <svg width="%s" height="%s" viewBox="0 0 %s %s" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect opacity="1" width="%s" height="%s" rx="%s" fill="#FFFFFF"/>
            </svg>

        ]], w, h, w, h, w, h, radius)

        svgRectangles[radius] = svgCreate(sx*w, sy*h, Path)
        dxSetTextureEdge(svgRectangles[radius], "border")

    end

    if svgRectangles[radius] then

        --dxSetBlendMode("modulate_add")
        _dxDrawImage(x, y, w, h, svgRectangles[radius], 0, 0, 0, color, post)
        --dxSetBlendMode("blend")

    end

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

local sizecc = {}
local function _drawBorder ( radius, x, y, width, height, color, colorStroke, sizeStroke, postGUI )

    colorStroke = tostring(colorStroke)
    sizeStroke = tostring(sizeStroke)
    if (not sizecc[height..':'..width]) then

        local raw = string.format([[
            <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'>
                <mask id='path_inside' fill='#FFFFFF' >
                    <rect width='%s' height='%s' rx='%s' />
                </mask>
                <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/>
            </svg>
        ]], width, height, width, height, radius, width, height, radius, colorStroke, sizeStroke)
        sizecc[height..':'..width] = svgCreate(width, height, raw)

    end

    if (sizecc[height..':'..width]) then

        _dxDrawImage(x, y, width, height, sizecc[height..':'..width], 0, 0, 0, color, postGUI)

    end

end
-- // UTIL CLIENT 

slotsTrade = {

    ['main'] = {

        {433, 182, 80, 80},
        {522, 182, 80, 80},
        {611, 182, 80, 80},
        {700, 182, 80, 80},
        {789, 182, 80, 80},

        {433, 273, 80, 80},
        {522, 273, 80, 80},
        {611, 273, 80, 80},
        {700, 273, 80, 80},
        {789, 273, 80, 80},

        {433, 364, 80, 80},
        {522, 364, 80, 80},
        {611, 364, 80, 80},
        {700, 364, 80, 80},
        {789, 364, 80, 80},

        {433, 455, 80, 80},
        {522, 455, 80, 80},
        {611, 455, 80, 80},
        {700, 455, 80, 80},
        {789, 455, 80, 80},

        {433, 546, 80, 80},
        {522, 546, 80, 80},
        {611, 546, 80, 80},
        {700, 546, 80, 80},
        {789, 546, 80, 80},

    },

    ['shortcut'] = {

        {317, 182, 80, 80},
        {317, 273, 80, 80},
        {317, 364, 80, 80},
        {317, 455, 80, 80},
        {317, 546, 80, 80},

    },

}

fontsTrade = {
    exports['goiaba_fonts']:useFont('int:bold', sy * (12 / 1.25));
    exports['goiaba_fonts']:useFont('int:regular', sy * (11 / 1.25));
    exports['goiaba_fonts']:useFont('int:medium', sy * (11 / 1.25));
    exports['goiaba_fonts']:useFont('int:extrabold', sy * (25 / 1.25));
    exports['goiaba_fonts']:useFont('int:semibold', sy * (11 / 1.25));
    exports['goiaba_fonts']:useFont("rc:medium", sx*20, false, "cleartype");
    exports['goiaba_fonts']:useFont('int:regular', sy * (9 / 1.25));
}

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        fontsTrade = {
            exports['goiaba_fonts']:useFont('int:bold', sy * (12 / 1.25));
            exports['goiaba_fonts']:useFont('int:regular', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont('int:medium', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont('int:extrabold', sy * (25 / 1.25));
            exports['goiaba_fonts']:useFont('int:semibold', sy * (11 / 1.25));
            exports['goiaba_fonts']:useFont("rc:medium", sx*20, false, "cleartype");
            exports['goiaba_fonts']:useFont('int:regular', sy * (9 / 1.25));
        }
    end
end)

tradeSlots = {

    {1010, 193, 26, 26};
    {906, 272, 26, 26};
    {975, 272, 26, 26};
    {1044, 272, 26, 26};
    {1113, 272, 26, 26};

}

--| Interface

function renderTrade()


    if not (isElement(tradePlayer)) then 

        closeTrade()

    return end

    --| Cursor

    cursorUpdate ()
    
    --| Render animations
    if not interface["animations"]["base"]["tick_out"] then 

        interface["animations"]["base"]["alpha"] = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount() - interface["animations"]["base"]["tick"]) / 700, "OutQuad")
        
    else
        
        if not interface["animations"]["base"]["last_alpha"] then 
            interface["animations"]["base"]["last_alpha"] = interface["animations"]["base"]["alpha"]
        end

        if ((getTickCount() - interface["animations"]["base"]["tick_out"]) >= 400) then 
            closeTrade()
        end
        
        interface["animations"]["base"]["alpha"] = interpolateBetween(interface["animations"]["base"]["last_alpha"], 0, 0, 0, 0, 0, (getTickCount() - interface["animations"]["base"]["tick_out"]) / 400, "OutQuad")
        
    end
    local alpha = interface["animations"]["base"]["alpha"]
    
    --| General background
    _dxDrawImage(0, 0, screenW, screenH, "core/assets/images/background2.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)
    
    --| Slots
    dxDrawText('Slots', 433, 155, 29,  15, tocolor(255, 255, 255, alpha * 0.9), 1, fontsTrade[3], 'left', 'center')
    dxDrawRectangle(470, 162, 270, 2, tocolor(255, 255, 255, alpha / 20))
    dxDrawImage(317, 182, 552, 444, "core/assets/images/slots.png", 0, 0, 0, tocolor(255, 255, 255, alpha), false)
    --| Hotbar

    dxDrawRectangle(414, 182, 2, 147, tocolor(255, 255, 255, alpha / 20))
    dxDrawText('Barra de slots', 372, 376, 86, 16, tocolor(255, 255, 255, alpha * 0.8), 0.5, fontsTrade[6], 'center', 'center', false, false, false, false, false, -90)
    dxDrawRectangle(414, 438, 2, 188, tocolor(255, 255, 255, alpha / 20))

    dxDrawText("1", 317, 182, 80, 80, tocolor(89, 178, 104, alpha*0.2), 1, fontsTrade[4], "center", "center")
    dxDrawText("2", 317, 273, 80, 80, tocolor(89, 178, 104, alpha*0.2), 1, fontsTrade[4], "center", "center")
    dxDrawText("3", 317, 364, 80, 80, tocolor(89, 178, 104, alpha*0.2), 1, fontsTrade[4], "center", "center")
    dxDrawText("4", 317, 455, 80, 80, tocolor(89, 178, 104, alpha*0.2), 1, fontsTrade[4], "center", "center")
    dxDrawText("5", 317, 546, 80, 80, tocolor(89, 178, 104, alpha*0.2), 1, fontsTrade[4], "center", "center")

    --| Bag 
    if bag[localPlayer] then

        drawItem('weight_bg', 466, 60, tocolor(255, 255, 255, alpha * 0.04), 0, 0, 0, false)
        drawItem('weight', 466, 60, tocolor(89, 178, 104, alpha), 0, 0, 0, false)

        local percentage = 180 * (bag[localPlayer]["personData"]["weight"] / bag[localPlayer]["personData"]["maxWeight"])
        if (tonumber(bag[localPlayer]["personData"]["weight"]) < bag[localPlayer]["personData"]["maxWeight"]) then
            if percentage == 0 then

                setSVGOffset('weight', 0.01, 360 - 0.2)

            else

                setSVGOffset('weight', percentage, 360 - 0.2)

            end

        end

        setSVGOffset('weight_bg', 180, 360 - 0.2)

        dxDrawImage(509, 86, 24, 24, 'core/assets/images/iconpeso.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText(math.round(bag[localPlayer]["personData"]["weight"], 2).."/"..bag[localPlayer]["personData"]["maxWeight"]..'kg', 487, 118, 67, 15, tocolor(255, 255, 255, alpha*0.7), 1, fontsTrade[2], 'center', 'center')
        
        drawBorder(2, 596, 71, 20, 4, tocolor(89, 178, 104, alpha))
        dxDrawText('Inventário', 596, 79, 65, 15, tocolor(89, 178, 104, alpha), 1, fontsTrade[1])
        dxDrawText('Veja as informações da sua mochila.', 596, 95, 65, 15, tocolor(255, 255, 255, alpha * 0.4), 1, fontsTrade[2])

        --| Itens
        local playerItens = bag[localPlayer]["itemData"]
        if playerItens and (#playerItens ~= 0) then

            for i, item in ipairs(playerItens) do

                local id = item["itemID"]
                local name, slot, amount, image = config["itens"][id]["name"], item["itemSlot"], item["itemAmount"], icons[id]

                if interface["selected"]["index"] and interface["selected"]["item"] and (interface["selected"]["index"] == i) and (getTickCount() - interface["selected"]["tick"] >= 100) then 

                    local mx, my = getCursorPosition()
                    mousex, mousey = (mx * screenW), (my * screenH)
                    _dxDrawImage(mousex - sx*(80 / 2), mousey - sy*(80 / 2), sx*80, sy*80, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha / 3))
                    _dxDrawImage(mousex - sx*(config["default"]["itemSize"] / 2), mousey - sy*(config["default"]["itemSize"] / 2), sx*config["default"]["itemSize"], sy*config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)

                    if id == 110 then
                        _dxDrawText(formatNumberC(amount), mousex - sx*(80 / 2), mousey - sy*(80 / 2), sx*80 + (mousex - sx*(80 / 2)), sy*23 + (mousey - sy*(80 / 2)), tocolor(255, 255, 255, alpha*0.65), 0.40, fontsTrade[6], "center", "center")
                    else
                        _dxDrawText(amount..'x', mousex - sx*(80 / 2), mousey - sy*(80 / 2), sx*29 + (mousex - sx*(80 / 2)), sy*23 + (mousey - sy*(80 / 2)), tocolor(255, 255, 255, alpha*0.65), 0.45, fontsTrade[6], "center", "center")
                    end

                else
                    
                    if (slot > 0) and (slot <= 25) then
                        if interface["selected"] and interface["selected"]["item"] and (interface["selected"]["item"]["itemSlot"] == slot) and not interface["selected"]["index"] then
                            dxDrawImage(slotsTrade["main"][slot][1], slotsTrade["main"][slot][2], 80, 80, 'core/assets/images/slot.png', 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                        end
                        if image and image["image"] then
                            dxDrawImage((slotsTrade["main"][slot][1] + slotsTrade["main"][slot][3]) - (slotsTrade["main"][slot][3]/2) - (config["default"]["itemSize"] / 2), (slotsTrade["main"][slot][2] + slotsTrade["main"][slot][4]) - (slotsTrade["main"][slot][4]/2) - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)
                        end
                    
                        
                        if id == 110 then
                            dxDrawText(formatNumberC(amount), slotsTrade["main"][slot][1], slotsTrade["main"][slot][2], 80, 23, tocolor(255, 255, 255, (alpha/100)*65), 0.40, fontsTrade[6], "center", "center")
                        else
                            dxDrawText(amount..'x', slotsTrade["main"][slot][1], slotsTrade["main"][slot][2], 29, 23, tocolor(255, 255, 255, (alpha/100)*65), 0.45, fontsTrade[6], "center", "center")
                        end

                    end 

                end

                --| Hotbar itens
                local action = item["itemAction"]
                if action and (action > 0) and (action <= 5) then     
                    dxDrawImage((slots["shortcut"][action][1] + slots["shortcut"][action][3]) - (slots["shortcut"][action][3]/2) - (config["default"]["itemSize"] / 2), (slots["shortcut"][action][2] + slots["shortcut"][action][4]) - (slots["shortcut"][action][4]/2) - (config["default"]["itemSize"] / 2), config["default"]["itemSize"], config["default"]["itemSize"], image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)           
                end

            end

        end

        drawBorder(8, 317, 641, 552, 90, tocolor(255, 255, 255, alpha * 0.02))

        if (interface["selected"] and interface["selected"]["item"]) then 

            local id = interface["selected"]["item"]['itemID']
            local name, slot, amount, image = config["itens"][id]["name"], interface["selected"]["item"]["itemSlot"], interface["selected"]["item"]["itemAmount"], icons[id]

            dxDrawImage(327, 646, 80, 80, image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText(name, 407, 655, 65, 15, tocolor(89, 178, 104, alpha), 1, fontsTrade[1])
            dxDrawText('#E1E1E1Você possui: #FFFFFF'..amount..'x', 407, 671, 82, 13, tocolor(255, 255, 255, alpha * 0.6), 1, fontsTrade[2], 'left', 'top', false, false, false, true)
            dxDrawText('Essas são as principais informações do item.\nPara usar o item utilize os botões.', 407, 691, 246, 26, tocolor(255, 255, 255, alpha * 0.4), 1, fontsTrade[2])

            dxDrawText('Peso:', 718, 651, 82, 13, tocolor(255, 255, 255, alpha * 0.6), 1, fontsTrade[2], 'left', 'top', false, false, false, true)
            dxDrawText(interface["selected"]["item"]["itemWeight"]..'kg', 718, 664, 65, 15, tocolor(89, 178, 104, alpha), 1, fontsTrade[1])

            dxDrawText('Categoria:', 718, 692, 82, 13, tocolor(255, 255, 255, alpha * 0.6), 1, fontsTrade[2], 'left', 'top', false, false, false, true)
            dxDrawText('Geral', 718, 705, 65, 15, tocolor(89, 178, 104, alpha), 1, fontsTrade[1])

        else 

            dxDrawImage(347, 661, 50, 50, 'core/assets/images/info.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText('Informações do item', 410, 664, 65, 15, tocolor(89, 178, 104, alpha), 1, fontsTrade[1])
            dxDrawText('Essas são as principais informações do item. Você não selecionou nenhum item, para ver as informações selecione algum item no inventário.', 410, 682, 416, 15, tocolor(255, 255, 255, alpha * 0.4), 1, fontsTrade[2], 'left', 'top', false, true)

        end

    end
    
    drawBorder(3, 754, 136, 115, 33, tocolor(255, 255, 255, alpha * 0.03))
    dxDrawText(selectEdit == 1 and guiGetText(tradeAmountEdit)..'|' or guiGetText(tradeAmountEdit), 754, 136, 115, 33, tocolor(255, 255, 255, alpha * 0.25), 1, fontsTrade[2], 'center', 'center')

    if (tradeStep == 1) then 

        local remainTime = interpolateBetween(40, 0, 0, 0, 0, 0, ((getTickCount() - sendTradeTick) / 40000), 'Linear')
        if (remainTime <= 0) then 

            closeTrade()  

        end 

        if not (proposalSend) then 

            dxDrawText('Sua proposta', 889, 136, 78, 15, tocolor(255, 255, 255, alpha), 1, fontsTrade[1])

            dxDrawImage(889, 166, 267, 80, 'core/assets/images/tradeLines.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(889, 255, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(958, 255, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(1027, 255, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(1096, 255, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

            drawBorder(5, 889, 324, 267, 32, tocolor(255, 255, 255, alpha * 0.03))
            dxDrawText('Escolha no mínimo um item para negociar.', 889, 324, 267, 32, tocolor(255, 255, 255, alpha * 0.3), 1, fontsTrade[3], 'center', 'center')

            dxDrawRectangle(889, 374, 115, 1, tocolor(255, 255, 255, alpha * 0.07))
            dxDrawRectangle(1041, 374, 115, 1, tocolor(255, 255, 255, alpha * 0.07))
            dxDrawImage(1014, 366, 17, 17, 'core/assets/images/tradeRefresh.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

            dxDrawImage(889, 393, 14, 14, 'core/assets/images/tradeClock.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText(math.floor(remainTime)..' segundos', 908, 394, 69, 13, tocolor(255, 255, 255, alpha), 1, fontsTrade[3])

            dxDrawText('Recusar', 944, 436, 45, 13, isMouseInPosition(944, 436, 45, 13) and tocolor(255, 255, 255, alpha) or tocolor(255, 255, 255, alpha * 0.4), 1, fontsTrade[1])

            drawBorder(5, 1016, 422, 115, 40, tocolor(255, 255, 255, alpha * 0.05))
            dxDrawText('Confirmar', 1016, 422, 115, 40, tocolor(255, 255, 255, alpha), 1, fontsTrade[1], 'center', 'center')

            if (isMouseInPosition(1016, 422, 115, 40)) then 
            
                if not (buttonTradeTick) then buttonTradeTick = getTickCount() end 
                local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - buttonTradeTick) / 300), 'Linear') 
                drawBorder(5, 1016, 422, 115, 40, tocolor(61, 204, 109, animation))
                dxDrawText('Confirmar', 1016, 422, 115, 40, tocolor(255, 255, 255, animation), 1, fontsTrade[1], 'center', 'center')

            else    

                buttonTradeTick = nil 

            end

            for i = 1, 5 do 

                if (myProposal[i]) then 

                    drawBorder(5, tradeSlots[i][1] - 17, tradeSlots[i][2] - 17, 60, 60, tocolor(255, 255, 255, alpha * 0.03))
                    dxDrawImage(tradeSlots[i][1] - 7, tradeSlots[i][2] - 7, 40, 40, config.itens[myProposal[i].itemID].image, 0, 0, 0, tocolor(255, 255, 255, alpha))
                    dxDrawText(formatNumber(myProposal[i].amount, '.')..'x', tradeSlots[i][1] - 17 + 3, tradeSlots[i][2] - 17 + 3, 10, 10, tocolor(255, 255, 255, alpha * 0.3), 1, fontsTrade[7])

                else 

                    dxDrawImage(tradeSlots[i][1], tradeSlots[i][2], tradeSlots[i][3], tradeSlots[i][4], 'core/assets/images/tradeAdd.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

                end

            end
            
        else 
        

            tradeRotation = tradeRotation + 5 
            drawBorder(30, 958, 136, 130, 130, tocolor(255, 255, 255, alpha * 0.03))
            dxDrawImage(1003, 181, 40, 40, 'core/assets/images/tradeBox.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(968, 146, 110, 110, 'core/assets/images/tradeCircle.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawImage(968, 146, 110, 110, 'core/assets/images/tradeCircle2.png', tradeRotation, 0, 0, tocolor(255, 255, 255, alpha))
                
            drawBorder(5, 889, 280, 267, 32, tocolor(255, 255, 255, alpha * 0.03))
            dxDrawText('Aguardando a resposta do jogador...', 889, 280, 267, 32, tocolor(255, 255, 255, alpha * 0.3), 1, fontsTrade[3], 'center', 'center')

            dxDrawRectangle(889, 330, 115, 1, tocolor(255, 255, 255, alpha * 0.07))
            dxDrawRectangle(1041, 330, 115, 1, tocolor(255, 255, 255, alpha * 0.07))
            dxDrawImage(1014, 322, 17, 17, 'core/assets/images/tradeRefresh.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        end
        
        if (proposalSend and playerProposal) then 

            tradeStep = 2 
            playerAcept = false 
            meAcept = false 

        end
        
    elseif (tradeStep == 2) then 

        dxDrawText('Sua proposta', 889, 136, 78, 15, tocolor(255, 255, 255, alpha), 1, fontsTrade[1])

        dxDrawImage(889, 166, 267, 80, 'core/assets/images/tradeLines.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawImage(889, 255, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawImage(958, 255, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawImage(1027, 255, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawImage(1096, 255, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))


        dxDrawRectangle(889, 374, 115, 1, tocolor(255, 255, 255, alpha * 0.07))
        dxDrawRectangle(1041, 374, 115, 1, tocolor(255, 255, 255, alpha * 0.07))
        dxDrawImage(1014, 366, 17, 17, 'core/assets/images/tradeRefresh.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        for i = 1, 5 do 
        
            if (myProposal[i]) then 
            
                drawBorder(5, tradeSlots[i][1] - 17, tradeSlots[i][2] - 17, 60, 60, tocolor(255, 255, 255, alpha * 0.03))
                dxDrawImage(tradeSlots[i][1] - 7, tradeSlots[i][2] - 7, 40, 40, config.itens[myProposal[i].itemID].image, 0, 0, 0, tocolor(255, 255, 255, alpha))
                dxDrawText(formatNumber(myProposal[i].amount, '.')..'x', tradeSlots[i][1] - 17 + 3, tradeSlots[i][2] - 17 + 3, 10, 10, tocolor(255, 255, 255, alpha * 0.3), 1, fontsTrade[7])
            
            else 
            
                dxDrawImage(tradeSlots[i][1], tradeSlots[i][2], tradeSlots[i][3], tradeSlots[i][4], 'core/assets/images/tradeAdd.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            
            end
        
        end

        drawBorder(5, 889, 324, 267, 32, tocolor(255, 255, 255, alpha * 0.03))
        
        if (meAcept) then 

            dxDrawImage(896, 331, 18, 18, 'core/assets/images/tradeCheck.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText('Pronto', 922, 334, 33, 12, tocolor(255, 255, 255, alpha), 1, fontsTrade[5])

        else

            drawBorder(3, 896, 331, 18, 18, tocolor(255, 255, 255, alpha * 0.03))
            dxDrawText('Confirmar proposta', 922, 334, 33, 12, tocolor(255, 255, 255, alpha), 1, fontsTrade[5])

        end

        dxDrawImage(889, 393, 35, 35, ':goiaba_login/assets/avatares/'..(getElementData(tradePlayer, 'Avatar') or 1)..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText(getPlayerName(tradePlayer), 934, 396, 80, 15, tocolor(255, 255, 255, alpha), 1, fontsTrade[1], 'left', 'top', false, false, false, true)
        dxDrawText('Proposta recebida', 934, 412, 80, 15, tocolor(255, 255, 255, alpha * 0.5), 1, fontsTrade[3])

        dxDrawImage(889, 166 + 277, 267, 80, 'core/assets/images/tradeLines.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawImage(889, 255 + 277, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawImage(958, 255 + 277, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawImage(1027, 255 + 277, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawImage(1096, 255 + 277, 60, 60, 'core/assets/images/tradeLines2.png', 0, 0, 0, tocolor(255, 255, 255, alpha))


        dxDrawRectangle(889, 374 + 277, 115, 1, tocolor(255, 255, 255, alpha * 0.07))
        dxDrawRectangle(1041, 374 + 277, 115, 1, tocolor(255, 255, 255, alpha * 0.07))
        dxDrawImage(1014, 366 + 277, 17, 17, 'core/assets/images/tradeRefresh.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        for i = 1, 5 do 
        
            if (playerProposal[i]) then 
            
                drawBorder(5, tradeSlots[i][1] - 17, tradeSlots[i][2] - 17 + 277, 60, 60, tocolor(255, 255, 255, alpha * 0.03))
                dxDrawImage(tradeSlots[i][1] - 7, tradeSlots[i][2] - 7 + 277, 40, 40, config.itens[playerProposal[i].itemID].image, 0, 0, 0, tocolor(255, 255, 255, alpha))
                dxDrawText(formatNumber(playerProposal[i].amount, '.')..'x', tradeSlots[i][1] - 17 + 3, tradeSlots[i][2] - 17 + 3 + 277, 10, 10, tocolor(255, 255, 255, alpha * 0.3), 1, fontsTrade[7])
            
            else 
            
                dxDrawImage(tradeSlots[i][1], tradeSlots[i][2] + 277, tradeSlots[i][3], tradeSlots[i][4], 'core/assets/images/tradeAdd.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            
            end
        
        end

        drawBorder(5, 889, 324 + 277, 267, 32, tocolor(255, 255, 255, alpha * 0.03))
        
        if (playerAcept) then 

            dxDrawImage(896, 331 + 277, 18, 18, 'core/assets/images/tradeCheck.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText('Pronto', 922, 334 + 277, 33, 12, tocolor(255, 255, 255, alpha), 1, fontsTrade[5])

        else

            drawBorder(3, 896, 331 + 277, 18, 18, tocolor(255, 255, 255, alpha * 0.03))
            dxDrawText('Confirmar proposta', 922, 334 + 277, 33, 12, tocolor(255, 255, 255, alpha), 1, fontsTrade[5])

        end

        dxDrawText('Cancelar', 941, 691, 45, 13, isMouseInPosition(941, 691, 45, 13) and tocolor(255, 255, 255, alpha) or tocolor(255, 255, 255, alpha * 0.4), 1, fontsTrade[1])

        drawBorder(5, 1015, 677, 115, 40, tocolor(255, 255, 255, alpha * 0.05))
        dxDrawText('Confirmar', 1015, 677, 115, 40, tocolor(255, 255, 255, alpha), 1, fontsTrade[1], 'center', 'center')

        if (isMouseInPosition(1015, 677, 115, 40)) then 
        
            if not (buttonTradeTick) then buttonTradeTick = getTickCount() end 
            local animation = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - buttonTradeTick) / 300), 'Linear') 
            drawBorder(5, 1015, 677, 115, 40, tocolor(61, 204, 109, animation))
            dxDrawText('Confirmar', 1015, 677, 115, 40, tocolor(255, 255, 255, animation), 1, fontsTrade[1], 'center', 'center')
        
        else    
        
            buttonTradeTick = nil 
        
        end
        
        if (playerAcept and meAcept) then 

            triggerServerEvent('onPlayerAceptMyProposal', resourceRoot, localPlayer)
            closeTrade()

        end
        
    end

end

tradeRotation = 0 
function openTrade(tradePlayer_)

    if not isEventHandlerAdded('onClientRender', root, renderTrade) then

        interface = {
            
            ['animations'] = {

                ['base'] = {
                    ['alpha'] = 0,
                    ['tick'] = getTickCount(),
                },

                ['nav'] = {
                    ['last'] = 1081,
                    ['x'] = 1081,
                    ['tick'] = getTickCount(),
                },

            },

            ['selected'] = {
                ['index'] = 0,
                ['item'] = false,
            },
            ['category'] = 'foods',

        }

        tradePlayer = tradePlayer_
        tradeStep = 1 

        sendTradeTick = getTickCount()
        proposalSend = false 
        myProposal = {}
        playerProposal = nil 

        setElementData(localPlayer, 'bloqInterface', true)
        setElementData(localPlayer, 'painelAberto', true)
        addEventHandler('onClientRender', root, renderTrade, false, "low-10")
        showCursor(true)
        showChat(false)

        setSVGOffset('weight', 0.01, 360 - 0.2)
        setSVGOffset('weight_bg', 0.01, 360 - 0.2)
        triggerServerEvent('onPlayerUpdateItemInfo', resourceRoot, localPlayer)

        tradeAmountEdit = guiCreateEdit(0, 0, 0, 0, 'Quantidade', false)
        guiEditSetMaxLength(tradeAmountEdit, 4)
        guiSetProperty(tradeAmountEdit, 'ValidationString', '[0-9]*')

    end
end
addEvent("FS:openTrade", true)
addEventHandler("FS:openTrade", root, openTrade)

function closeTrade()
    if isEventHandlerAdded('onClientRender', root, renderTrade) then 

        if not interface['animations']['base']['tick_out'] then 
            interface['animations']['base']['tick_out'] = getTickCount()
            return 
        end

        setElementData(localPlayer, 'bloqInterface', false)
        setElementData(localPlayer, 'painelAberto', false)
        removeEventHandler('onClientRender', root, renderTrade)
        showCursor(false)
        showChat(true)
        triggerServerEvent('onPlayerCancelTrade', resourceRoot, localPlayer)

        if (isElement(tradeAmountEdit)) then 

            destroyElement(tradeAmountEdit)

        end

    end
end
addEvent("FS:closeTrade", true)
addEventHandler("FS:closeTrade", root, closeTrade)

addEventHandler('onClientKey', root, function (key, press)
    if isEventHandlerAdded('onClientRender', root, renderTrade) and press then 
        if key == 'escape' then
            closeTrade()
            cancelEvent()
        elseif key == 'backspace' then
            closeTrade()
        end
    end
end)

--| Click function's

addEventHandler("onClientClick", root, function(button, state)
    if isEventHandlerAdded('onClientRender', root, renderTrade) then 

        selectEdit = 0 

        if (guiGetText(tradeAmountEdit) == '') then 

            guiSetText(tradeAmountEdit, 'Quantidade')

        end

        if (isCursorOnElement(754, 136, 115, 33)) then 

            if (guiEditSetCaretIndex(tradeAmountEdit, #guiGetText(tradeAmountEdit))) then 
            
                guiBringToFront(tradeAmountEdit)
                guiSetInputMode('no_binds_when_editing')
                selectEdit = 1

                if (guiGetText(tradeAmountEdit) == 'Quantidade') then 

                    guiSetText(tradeAmountEdit, '')
        
                end

            end
            
        elseif (tradeStep == 1) then 

            if not (proposalSend) then 

                if (isMouseInPosition(944, 436, 45, 13)) then 

                    closeTrade()

                elseif (isMouseInPosition(1016, 422, 115, 40)) then 

                    proposalSend = true 
                    triggerServerEvent('onPlayerReceiveTradeProposal', resourceRoot, localPlayer, myProposal)
                    setElementData(localPlayer, 'myTrade', myProposal)

                end

            end

        elseif (tradeStep == 2) and not meAcept then 

            if (isMouseInPosition(941, 691, 45, 13)) then 

                triggerServerEvent('onPlayerCancelTrade', resourceRoot, localPlayer)
                closeTrade()

            elseif (isMouseInPosition(1015, 677, 115, 40)) then 

                meAcept = true 
                triggerServerEvent('onPlayerReceiveTradeAceptProposal', resourceRoot, localPlayer)

            end 

        end
        
        --| Item click's
        if bag[localPlayer] then
            local playerItens = bag[localPlayer]["itemData"]
            if playerItens and (#playerItens ~= 0) then 
                
                if (button == "left") and (state == "down") then

                    for i, item in ipairs(playerItens) do
    
                        local slot = item["itemSlot"]
                        if (slot > 0) and (slot <= 25) then

                            if isCursorOnElement(slotsTrade["main"][slot][1], slotsTrade["main"][slot][2], slotsTrade["main"][slot][3], slotsTrade["main"][slot][4]) then
                                interface["selected"] = {
                                    ['item'] = item,
                                    ['index'] = i,
                                    ['tick'] = getTickCount(),
                                }
                                break
                            end

                        end

                    end

                    for i = 1, 5 do 
                        if isCursorOnElement(slots["shortcut"][i][1], slots["shortcut"][i][2], slots["shortcut"][i][3], slots["shortcut"][i][4]) then
                            triggerServerEvent("FS:actionFunctions", localPlayer, i, "delete")
                            break
                        end
                    end

                    for i = 1, 5 do 

                        if (myProposal[i]) then 
        
                            if isMouseInPosition(tradeSlots[i][1] - 17, tradeSlots[i][2] - 17, 60, 60) then 

                                table.remove(myProposal, i)
                            
                            return end 
        
                        end
        
                    end

                elseif (button == "left") and (state == "up") then

                    if (interface["selected"] and interface["selected"]["item"]) then
     
                        if isCursorOnElement(889, 166, 267, 149) then 
                            local ammount = tonumber(guiGetText(tradeAmountEdit))
                            if getKeyState('lshift') or not ammount then
                                ammount = interface["selected"]["item"]["itemAmount"]
                            end


                            if (tonumber(ammount) and tonumber(ammount) > 0) then 

                                if (interface["selected"]["item"]["itemAmount"] >= tonumber(ammount)) then 

                                    if (#myProposal >= 5) then 

                                        table.remove(myProposal, 1)

                                    end 

                                    for i, v in ipairs(myProposal) do 

                                        if (v.itemID == interface["selected"]["item"]["itemID"]) then 

                                            table.remove(myProposal, i)

                                        end

                                    end 

                                    if not (config.itens[interface["selected"]["item"]["itemID"]].takelist) then 


                                        table.insert(myProposal, 
                                        
                                            {
    
                                                itemID = interface["selected"]["item"]["itemID"];
                                                amount = tonumber(ammount);
    
                                            }
                                    
                                        )
                                        
                                    else

                                        exports['goiaba_infobox']:addBox('Você não pode colocar um item bloqueado para troca.', 'infos')

                                    end


                                end 
                                
                            end
                            
                            
                        end
                        
                        interface["selected"] = {
                            ['index'] = 0,
                            ['item'] = false,
                        }

                    end

                end
                
            end
        end

    end
end)


function formatNumber(number, sep)
	assert(type(tonumber(number))=="number", "Bad argument @'formatNumber' [Expected number at argument 1 got "..type(number).."]")
	assert(not sep or type(sep)=="string", "Bad argument @'formatNumber' [Expected string at argument 2 got "..type(sep).."]")
	sep = sep or '.'
	local money = number
	for i = 1, tostring(money):len()/3 do
		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1"..sep.."%2")
	end
	return money
end

addEvent('onClientReceivePlayerTradeProposal', true)
addEventHandler('onClientReceivePlayerTradeProposal', root, 

    function(playerProposal_)

        playerProposal = playerProposal_

    end

)

addEvent('onClientReceivePlayerTradeAceptProposal', true)
addEventHandler('onClientReceivePlayerTradeAceptProposal', root, 

    function(playerProposal_)

        playerAcept = true

    end

)