local screenW, screenH = guiGetScreenSize()
local size = screenW == 1920 and 1.4 or 1
local screenScale = math.min(math.max(screenH / 768, size), size)

local function respX(x) return parentX + x * screenScale end
local function respY(y) return parentY + y * screenScale end
local function respC(scale) return scale * screenScale end

local function dxDrawText(text, x, y, width, height, ...)
    return _dxDrawText(text, respX(x), respY(y), respX(x) + respC(width), respY(y) + respC(height), ...)
end

local function dxDrawRectangle(x, y, width, height, ...)
    return _dxDrawRectangle(respX(x), respY(y), respC(width), respC(height), ...)
end

local function dxDrawImage(x, y, width, height, image, ...)
    return _dxDrawImage(respX(x), respY(y), respC(width), respC(height), image, ...)
end

foD = {
    exports['goiaba_fonts']:useFont('int:bold', sy * (10 / 1.3));
    exports['goiaba_fonts']:useFont('gn:wind', sy * (35 / 1.3));
}

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        foD = {
            exports['goiaba_fonts']:useFont('int:bold', sy * (10 / 1.3));
            exports['goiaba_fonts']:useFont('gn:wind', sy * (35 / 1.3));
        }
    end
end)

local infosDocument = false

function renderDocument()
    if typeDocument == 'rg' then
        dxDrawImage(0, 0, 420, 270, "core/assets/images/documents/rg.png")
        dxDrawText(infosDocument and infosDocument.nacionalidade, 18, 88, 100, 20, tocolor(0, 0, 0, 170), 1, foD[1], 'left')
        dxDrawText("21/09/2024", 274, 88, 100, 20, tocolor(0, 0, 0, 170), 1, foD[1], 'left')
        dxDrawText(infosDocument and infosDocument.name, 152, 122, 100, 20, tocolor(0, 0, 0, 170), 1, foD[1], 'left')
        dxDrawText("18", 351, 122, 100, 20, tocolor(0, 0, 0, 170), 1, foD[1], 'left')
        dxDrawText(infosDocument and infosDocument.genero, 152, 170, 100, 20, tocolor(0, 0, 0, 170), 1, foD[1], 'left')
        dxDrawText(infosDocument and infosDocument.naturalidade, 293, 170, 100, 20, tocolor(0, 0, 0, 170), 1, foD[1], 'left')
        dxDrawText(infosDocument and infosDocument.registro, 152, 217, 100, 20, tocolor(0, 0, 0, 170), 1, foD[1], 'left')
        dxDrawText("21/09/2024", 256, 217, 100, 20, tocolor(0, 0, 0, 170), 1, foD[1], 'left')
        dxDrawText(infosDocument and infosDocument.ass, 225, 220, 100, 20, tocolor(0, 0, 0, 200), 1, foD[2], 'center')
        dxDrawImage(24, 134, 100, 119, "core/assets/images/documents/"..infosDocument.person..".png")
        dxDrawText("BACKSPACE para fechar", 0, -20, 420, 20, tocolor(255, 255, 255, 255), 1, foD[1], 'center')
    elseif typeDocument == 'cnh' then
        dxDrawImage(0, 0, 440, 270, "core/assets/images/documents/cnh.png")
        dxDrawImage(24, 134, 100, 119, "core/assets/images/documents/"..infosDocument.person..".png")
        dxDrawText(infosDocument and infosDocument.name, 24, 108, 265, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText(infosDocument and infosDocument.primeiraHabilitacao, 300, 108, 120, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText(infosDocument and infosDocument.catHAB, 355, 192.5, 69, 15, tocolor(222, 22, 22, 200), 1, foD[1], 'left', 'center')
        dxDrawText('00000001', 272, 192.5, 69, 15, tocolor(222, 22, 22, 200), 1, foD[1], 'left', 'center')
        dxDrawText('123.456.789-01', 154, 192.5, 69, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText(infosDocument and infosDocument.validadeHabilitacao, 300, 136, 69, 15, tocolor(222, 22, 22, 200), 1, foD[1], 'left', 'center')
        dxDrawText('00'..(infosDocument and infosDocument.registro), 154, 136, 69, 15, tocolor(222, 22, 22, 200), 1, foD[1], 'left', 'center')
        dxDrawText(infosDocument and infosDocument.nacionalidade, 154, 164.5, 69, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText(infosDocument and infosDocument.ass, 145, 215, 270, 35, tocolor(0, 0, 0, 200), 1, foD[2], 'center', 'center')
        dxDrawText("BACKSPACE para fechar", 0, -20, 440, 20, tocolor(255, 255, 255, 255), 1, foD[1], 'center')
    elseif typeDocument == 'porte' then
        dxDrawImage(0, 0, 440, 270, "core/assets/images/documents/porte.png")
        dxDrawText(infosDocument and infosDocument.name, 25, 108, 265, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText('0000001234', 25, 136, 265, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText('01', 123, 136, 265, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText('15/02/2024', 307, 136, 265, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText('ABCD1234', 25, 164, 265, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText('ARMA LEVE', 140, 164, 265, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText('PISTOLA', 311, 164, 265, 15, tocolor(0, 0, 0, 170), 1, foD[1], 'left', 'center')
        dxDrawText('00'..(infosDocument and infosDocument.identidade), 25, 191, 265, 15, tocolor(222, 22, 22, 200), 1, foD[1], 'left', 'center')
        dxDrawText('23/04/2034', 178, 191, 265, 15, tocolor(222, 22, 22, 200), 1, foD[1], 'left', 'center')
        dxDrawText('ESTADO GBA', 310, 191, 265, 15, tocolor(222, 22, 22, 200), 1, foD[1], 'left', 'center')
        dxDrawText('Guilherme Dalcim', 17, 220, 399, 34, tocolor(0, 0, 0, 200), 1, foD[2], 'center', 'center')
        dxDrawText("BACKSPACE para fechar", 0, -20, 440, 20, tocolor(255, 255, 255, 255), 1, foD[1], 'center')
    end
end

addEvent("gba:showDocument", true)
addEventHandler("gba:showDocument", root, function(playerInfos, type)
    if infosDocument then return end
    infosDocument = playerInfos
    typeDocument = type
    if type == 'rg' then
        parentW, parentH = 440 * screenScale, 350 * screenScale
        parentX, parentY = screenW - parentW, screenH - parentH
    else
        parentW, parentH = 460 * screenScale, 350 * screenScale
        parentX, parentY = screenW - parentW, screenH - parentH
    end
    if not infosDocument then return end
    addEventHandler( "onClientRender", root, renderDocument)
    bindKey("backspace", "down", close)
end)

function close()
    if not infosDocument then return end
    infosDocument = false
    removeEventHandler("onClientRender", root, renderDocument)
end