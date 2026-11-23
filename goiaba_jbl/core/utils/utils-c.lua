--| Vars

screenW, screenH = guiGetScreenSize()
sx, sy = (screenW/1920), (screenH/1080)

--/ Events

local _Events = {}
_addEventHandler = addEventHandler
_removeEventHandler = removeEventHandler

function addEventHandler(eventName, attachedTo, theFunction, propagate, priority)
    local stt = _addEventHandler(eventName, attachedTo, theFunction, propagate, priority)
    if stt then
        table.insert(_Events, {eventName = eventName, attachedTo = attachedTo, theFunction = theFunction})
        return true
    else
        error('HOUVE UM IMPREVISTO AO EXECUTAR A FUNÇÃO, CHEQUE A LINHA ACIMA', 2)
    end
    return false
end

function removeEventHandler(eventName, attachedTo, theFunction)
    local stt = _removeEventHandler(eventName, attachedTo, theFunction)
    if (stt) then
        for i, evento in ipairs(_Events) do
            if (evento.eventName == eventName and evento.attachedTo == attachedTo and evento.theFunction == theFunction) then
                table.remove(_Events, i)
                return true
            end
        end
    else
        error('HOUVE UM IMPREVISTO AO EXECUTAR A FUNÇÃO, CHEQUE A LINHA ACIMA', 2)
    end
    return false
end

function isEventHandlerAdded(eventName, attachedTo, theFunction)
    for i, evento in ipairs(_Events) do
        if (evento.eventName == eventName and evento.attachedTo == attachedTo and evento.theFunction == theFunction) then
            return true
        end
    end
    return false
end

--/ Ator

function aToR(X, Y, sX, sY)
    local xd = X/1920 or X
    local yd = Y/1080 or Y
    local xsd = sX/1920 or sX
    local ysd = sY/1080 or sY
    return xd * screenW, yd * screenH, xsd * screenW, ysd * screenH
end

_dxDrawCircle = dxDrawCircle
function dxDrawCircle(x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawCircle(x, y, w, h, ...)
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

_dxDrawImageSection = dxDrawImageSection
function dxDrawImageSection(x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawImageSection(x, y, w, h, ...)
end

--| Font's & image's

local screenScale = math.max (0.75, screenH / 768);
local tableTextures = {
    imgElements = { };
    fontsElements = { };
}

_dxDrawImage = dxDrawImage
function dxDrawImage (x, y, w, h, path, ...)
    local x, y, w, h = aToR(x, y, w, h)
    if (type (path) ~= 'string') then
        return _dxDrawImage(x, y, w, h, path, ...)
    end
    if (not tableTextures.imgElements[path]) then
        tableTextures.imgElements[path] = dxCreateTexture (path, 'argb', true, 'clamp')
    end
    if (tableTextures.imgElements[path] and isElement (tableTextures.imgElements[path])) then
        return _dxDrawImage(x, y, w, h, tableTextures.imgElements[path], ...)
    else
        return print ('['..getResourceName (getThisResource ( ))..'] - Erro ao carregar a textura: ' .. path)
    end
end

_dxCreateFont = dxCreateFont
function dxCreateFont(path, size, ...)
    if (not tableTextures.fontsElements[path]) then
        tableTextures.fontsElements[path] = { }
    end
    if (not tableTextures.fontsElements[path][size]) then
        tableTextures.fontsElements[path][size] = _dxCreateFont ('core/assets/fonts/'..path, size * (screenScale / 1.1), false, "cleartype")
    end
    return tableTextures.fontsElements[path][size]
end

--| Cursor 

cursor = {};

function cursorUpdate ()
    cursor.state = isCursorShowing ();
    if (cursor.state) then
        local cursorX, cursorY = getCursorPosition ();
        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;
    end
end

function isCursorOnElement(x, y, width, heigth)
    local x, y, width, heigth = aToR(x, y, width, heigth)
    if not (cursor.state) then
        return false;
    end
    return (( cursor.x >= x and cursor.x <= x + width ) and ( cursor.y >= y and cursor.y <= y + heigth ));
end

--| SVG Area

local svgRectangles = {}

function dxDrawRoundedRectangle(x, y, w, h, color, radius, post)
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
        dxSetBlendMode("modulate_add")
        dxDrawImage(x, y, w, h, svgRectangles[radius], 0, 0, 0, color, post)
        dxSetBlendMode("blend")
    end
end

images = {}
imagesPath = {

    [''] = {w = 0, h = 0, path = [[
    ]]},

}

function loadSVGs()
    images = {}
    for id, data in pairs(imagesPath) do
        images[id] = svgCreate(sx*data["w"], sy*data["h"], data["path"])
        dxSetTextureEdge(images[id], "border")
    end
end

function destroySVGs()
    for id, data in pairs(images) do 
        if images[id] and isElement(images[id]) then 
            destroyElement(images[id])
        end
        images[id] = nil 
    end
    images = {}
end

--| Misc

local interpolates = {}
function interpolatePosition(x, y, w, h, init, final, time, easing, id)

    if not isCursorShowing() then
        return 0
    end

    if not interpolates[id] then 
        interpolates[id] = {
            value = init,
        }
    end

    if isCursorOnElement(x, y, w, h) then 

        if not interpolates[id]["tick"] then 
            interpolates[id]["old"] = interpolates[id]
            interpolates[id]["tick"] = getTickCount()
            interpolates[id]["tick_out"] = nil
        end
        interpolates[id]["value"][1], interpolates[id]["value"][2], interpolates[id]["value"][3] = interpolateBetween(interpolates[id]["old"]["value"][1], interpolates[id]["old"]["value"][2], interpolates[id]["old"]["value"][3], final[1], final[2], final[3], (getTickCount() - interpolates[id]["tick"]) / time, easing)
        
    else

        if not interpolates[id]["tick_out"] then 
            interpolates[id]["old"] = interpolates[id]
            interpolates[id]["tick_out"] = getTickCount()
            interpolates[id]["tick"] = nil
        end
        interpolates[id]["value"][1], interpolates[id]["value"][2], interpolates[id]["value"][3] = interpolateBetween(interpolates[id]["old"]["value"][1], interpolates[id]["old"]["value"][2], interpolates[id]["old"]["value"][3], init[1], init[2], init[3], (getTickCount() - interpolates[id]["tick_out"]) / time, easing)

    end

    return interpolates[id]["value"][1], interpolates[id]["value"][2], interpolates[id]["value"][3]
end