screenWidth, screenHeight = guiGetScreenSize ();
screenScale = math.min (math.max (0.65, (screenHeight / 768)), 1.5);

cursors = {0, 0}

function respc (value)
    return value * screenScale;
end;

_dxDrawText = dxDrawText
function dxDrawText (text, x, y, width, height, ...)
    return _dxDrawText (text, x, y, x + width, y + height, ...);
end;