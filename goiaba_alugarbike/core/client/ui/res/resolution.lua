screen = Vector2(guiGetScreenSize())
scale = min(max (0.5, ((screen.y >= 1080 and 768 or screen.y) / 1080)), 0.7)

parent = Vector2((screen.x - (524 * scale)) / 2, (screen.y - (659 * scale)) / 2)
parentWidth = 524 * scale;
parentHeight = 659 * scale;

local _dxDrawText = dxDrawText;
function dxDrawText (text, x, y, w, h, ...)
    return _dxDrawText (text, x, y, w + x, h + y, ...);
end