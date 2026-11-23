local cursor = {};

function cursorUpdate ()
    cursor.state = isCursorShowing ();
    if (cursor.state) then
        local cursorX, cursorY = getCursorPosition ();
        cursor.x, cursor.y = cursorX * screen.x, cursorY * screen.y;
    end
end

function isCursorInPosition (x, y, width, heigth)
    if not (cursor.state) then
        return false;
    end
    return (( cursor.x >= x and cursor.x <= x + width ) and ( cursor.y >= y and cursor.y <= y + heigth ));
end