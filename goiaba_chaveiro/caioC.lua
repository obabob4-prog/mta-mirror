screen = Vector2 (guiGetScreenSize ());
scale = math.min(math.max(screen.y / 766, 0.70), 2); 

local offset = Vector2 ((screen.x - (290 * scale)) / 2, (screen.y - (424 * scale)) / 2);

_dxCreateFont = dxCreateFont
function dxCreateFont (path, size, ...)
    local size = size * scale
    return _dxCreateFont (path, size, ...)
end

_dxDrawImage = dxDrawImage
function dxDrawImage (x, y, width, height, image, ...)
    return _dxDrawImage (offset.x + (x * scale), offset.y + (y * scale), (width * scale), (height * scale), image, ...);
end

_dxDrawText = dxDrawText
function dxDrawText (text, x, y, width, height, ...)
    return _dxDrawText (text, offset.x + (x * scale), offset.y + (y * scale), (offset.x + (x * scale)) + (width * scale), (offset.y + (y * scale)) + (height * scale), ...);
end

_dxDrawRectangle = dxDrawRectangle
function dxDrawRectangle (x, y, width, height, ...)
    return _dxDrawRectangle (offset.x + (x * scale), offset.y + (y * scale), (width * scale), (height * scale), ...);
end
_svgCreate = svgCreate
function svgCreate (w, h, ...)
    return _svgCreate(w * 2, h * 2, ...)
end

function isMouseInPosition (x, y, width, height)
    if not isCursorShowing () then
        return false;
    end
    local cursor = {getCursorPosition ()};
    local cursorX, cursorY = (cursor[1] * screen.x), (cursor[2] * screen.y);
    local x, y = offset.x + (x * scale), offset.y + (y * scale);
    return ((cursorX >= x and cursorX <= (x + (width * scale))) and (cursorY >= y and cursorY <= (y + (height * scale))));
end

size = {}
function dxDrawRounded (x, y, w, h, radius, ...)
    if not size[w..'.'..h..':'..radius] then
        local svg = string.format([[ <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'> <mask id='path_inside' fill='#FFFFFF' > <rect width='%s' height='%s' rx='%s' /> </mask> <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/> </svg> ]], w, h, w, h, radius, w, h, radius, tostring(''), tostring(''))
        size[w..'.'..h..':'..radius] = svgCreate(w, h, svg)
    else
        dxDrawImage(x, y, w, h, size[w..'.'..h..':'..radius], 0, 0, 0, ...)
    end
end

local createdFonts = {}
local cachedFonts = {}
local function getFont(font, size)

    if not cachedFonts[font..':'..size] then
        cachedFonts[font..':'..size] = {font, size}
    end

    if (createdFonts[font..':'..size]) then 
        return createdFonts[font..':'..size] 
    else
        createdFonts[font..':'..size] = exports['goiaba_fonts']:useFont('sf:'..font, (size/1.4)*scale)
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

effectButtons = {}
function  render ()

    dxDrawImage(0, 0, 290, 424, 'images/background.png', 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText('Chaveiro', 119, 66, 53, 15, tocolor(61, 204, 109, 255), 1, getFont('bold', 12), 'center', 'center')
    dxDrawText('Selecione a residência para poder realizar\numa cópia da chave.', 30, 85, 230, 23, tocolor(255, 255, 255, 255 * 0.4), 1, getFont('regular', 10), 'center', 'center', false, true)
    
    dxDrawText('Cada chave custa um valor de R$ 10.000', 30, 265, 230, 20, tocolor(255, 255, 255, 255 * 0.4), 1, getFont('regular', 10), 'center', 'center')
    dxDrawRectangle(30, 285, 230, 1, tocolor(255, 255, 255, 255 * 0.1))

    dxDrawRounded(30, 295, 230, 50, 4, tocolor(255, 255, 255, 255 * 0.04))
    dxDrawText('Criar chave cópia', 30, 295, 230, 50, tocolor(255, 255, 255, 255), 1, getFont('bold', 12), 'center', 'center')

    if isMouseInPosition(30, 295, 230, 50) then
        if not effectButton1 then effectButton1 = getTickCount() end
        local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount()-effectButton1)/350), 'Linear')
        dxDrawRounded(30, 295, 230, 50, 4, tocolor(61, 204, 109, alpha))
        dxDrawText('Criar chave cópia', 30, 295, 230, 50, tocolor(0, 0, 0, alpha * 0.9), 1, getFont('bold', 12), 'center', 'center')
    else
        effectButton1 = nil
    end

    dxDrawRounded(30, 352, 230, 40, 4, tocolor(255, 255, 255, 255 * 0.04))
    dxDrawText('Cancelar', 30, 352, 230, 40, tocolor(255, 255, 255, 255), 1, getFont('bold', 12), 'center', 'center')

    if isMouseInPosition(30, 352, 230, 40) then
        if not effectButton2 then effectButton2 = getTickCount() end
        local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount()-effectButton2)/350), 'Linear')
        dxDrawRounded(30, 352, 230, 40, 4, tocolor(61, 204, 109, alpha))
        dxDrawText('Cancelar', 30, 352, 230, 40, tocolor(0, 0, 0, alpha * 0.9), 1, getFont('bold', 12), 'center', 'center')
    else
        effectButton2 = nil
    end

    if #houses > 0 then
        for i, v in ipairs(houses) do
            local py = 104 + (28 * i - 1)
            dxDrawImage(30, py, 230, 26, 'images/grid.png', 0, 0, 0, tocolor(255, 255, 255, 255 * 0.04))
            dxDrawText(v[1], 50, py, 230, 26, tocolor(255, 255, 255, 255 * 0.49), 1, getFont('medium', 10), 'left', 'center')

            if isMouseInPosition(30, py, 230, 26) or selectButton == i then
                if not effectButtons[i] then
                    effectButtons[i] = getTickCount()
                end
                local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount()-effectButtons[i])/350), 'Linear')
                dxDrawImage(30, py, 230, 26, 'images/grid.png', 0, 0, 0, tocolor(61, 204, 109, alpha))
                dxDrawText(v[1], 50, py, 230, 26, tocolor(0, 0, 0, alpha * 0.9), 1, getFont('medium', 10), 'left', 'center')
            else
                effectButtons[i] = nil
            end

        end
    else
        dxDrawRounded(10, 12, 270, 400, 20, tocolor(0, 0, 0, 255 * 0.7))
        dxDrawText('Você não possui nenhuma residência\nem seu nome.', 30, 114, 230, 166, tocolor(255, 255, 255, 255 * 0.4), 1, getFont('regular', 12), 'center', 'center', false, true)
    end

end

function  click (button, state)
    if visible and button == 'left' and state == 'down' then

        if #houses > 0 then
            for i, v in ipairs(houses) do
                local py = 104 + (28 * i - 1)
                if isMouseInPosition(30, py, 230, 26) then
                    selectButton = i
                end
            end
        end

        if isMouseInPosition(30, 295, 230, 50) then
            if selectButton then
                if houses[selectButton] then
                    triggerServerEvent('caio.comprarChaveResidencia', resourceRoot, localPlayer, houses[selectButton])
                end
            end
        elseif isMouseInPosition(30, 352, 230, 40) then
            close()
        end

    end
end

addEvent('Caio.Chaveiro', true)
addEventHandler('Caio.Chaveiro', root, function (action, houses_)
    if action == 'open' and not visible then
        selectButton = nil
        visible = true
        houses = houses_
        showCursor(visible)
        addEventHandler('onClientRender', root, render)
        addEventHandler('onClientClick', root, click)
    else
        close()
    end
end)

function close ()
    if visible then
        visible = false
        showCursor(visible)
        removeEventHandler('onClientRender', root, render)
        removeEventHandler('onClientClick', root, click)
    end
end