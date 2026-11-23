--| Vars

screenW, screenH = guiGetScreenSize()
sx, sy = (screenW/1920), (screenH/1080)

createCircleStroke('weight_bg', 110, 110, 7)
createCircleStroke('weight_bg2', 110, 110, 7)
createCircleStroke('weight2', 110, 110, 7)
createCircleStroke('weight', 110, 110, 7)

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

    return math.floor(xd * screenW), math.floor(yd * screenH), math.floor(xsd * screenW), math.floor(ysd * screenH)

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
function dxDrawText(text, x, y, w, h, color, fontSize, font, ...)

    local x, y, w, h = aToR(x, y, w + x, h + y)
    if not isElement(font) then return end
    return _dxDrawText(text, x, y, w, h, color, fontSize, font, ...)

end

_dxDrawImage = dxDrawImage
function dxDrawImage(x, y, w, h, ...)

    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawImage(x, y, w, h, ...)

end

_dxDrawImageSection = dxDrawImageSection
function dxDrawImageSection(x, y, w, h, ...)
    
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawImageSection(x, y, w, h, ...)

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

function isMouseInPosition(x, y, width, heigth)

    local x, y, width, heigth = aToR(x, y, width, heigth)
    if not (cursor.state) then

        return false;

    end

    return (( cursor.x >= x and cursor.x <= x + width ) and ( cursor.y >= y and cursor.y <= y + heigth ));

end

--| SVG Rectangles
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

        --dxSetBlendMode("modulate_add")
        dxDrawImage(x, y, w, h, svgRectangles[radius], 0, 0, 0, color, post)
        --dxSetBlendMode("blend")

    end

end

function _dxDrawRoundedRectangle(x, y, w, h, color, radius, post)

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

--| SVG Images

Images = {}
ImagesPath = {

    ["bag icon"] = {



        Format = "svg", Width = 24, Height = 24, Path = [[



        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">



        <path fill-rule="evenodd" clip-rule="evenodd" d="M7.292 4.78601V4.72501C7.292 4.38601 7.303 3.94301 7.457 3.50301C7.71542 2.77011 8.19514 2.13561 8.82985 1.68721C9.46455 1.23881 10.2229 0.99868 11 1.00001H13C13.7773 0.998473 14.5358 1.23851 15.1707 1.68692C15.8057 2.13533 16.2855 2.76995 16.544 3.50301C16.697 3.94301 16.709 4.38601 16.709 4.72501V4.78501C17.9315 5.14268 19.0075 5.88225 19.7794 6.89547C20.5513 7.9087 20.9787 9.14239 20.999 10.416L21 10.596V12.919C20.8953 12.919 20.7918 12.9408 20.696 12.983C17.9564 14.1916 14.9949 14.8159 12.0005 14.8159C9.00612 14.8159 6.04462 14.1916 3.305 12.983C3.20885 12.9409 3.10495 12.9195 3 12.92V10.417C3.02055 9.14344 3.44817 7.90987 4.22028 6.89683C4.99238 5.88379 6.06845 5.14445 7.291 4.78701L7.292 4.78601ZM8.874 3.99201C9.02903 3.5522 9.31688 3.17143 9.69774 2.90235C10.0786 2.63327 10.5337 2.48918 11 2.49001H13C13.983 2.49001 14.82 3.11601 15.126 3.99201C15.172 4.12201 15.194 4.27201 15.203 4.46201C13.083 4.10201 10.917 4.10201 8.797 4.46201C8.806 4.27201 8.828 4.12201 8.874 3.99201ZM9.25 12.671C9.25 12.259 9.586 11.926 10 11.926H14C14.414 11.926 14.75 12.259 14.75 12.671C14.7497 12.7692 14.7301 12.8664 14.6923 12.957C14.6544 13.0475 14.5991 13.1298 14.5294 13.199C14.4598 13.2682 14.3772 13.323 14.2863 13.3602C14.1955 13.3974 14.0982 13.4164 14 13.416H10C9.90182 13.4164 9.80452 13.3974 9.71368 13.3602C9.62283 13.323 9.54022 13.2682 9.47056 13.199C9.4009 13.1298 9.34557 13.0475 9.30772 12.957C9.26988 12.8664 9.25026 12.7692 9.25 12.671Z" fill="white"/>



        <path d="M21 14.4771C20.1 14.8591 19.181 15.1811 18.25 15.4431V16.644C18.2497 16.7422 18.2301 16.8394 18.1923 16.93C18.1544 17.0206 18.0991 17.1028 18.0294 17.172C17.9598 17.2412 17.8772 17.296 17.7863 17.3332C17.6955 17.3705 17.5982 17.3894 17.5 17.3891C17.4018 17.3894 17.3045 17.3705 17.2137 17.3332C17.1228 17.296 17.0402 17.2412 16.9706 17.172C16.9009 17.1028 16.8456 17.0206 16.8077 16.93C16.7699 16.8394 16.7503 16.7422 16.75 16.644V15.8121C12.138 16.783 7.33913 16.317 3 14.4771V16.0231C3.00254 17.0472 3.35476 18.0398 3.99834 18.8365C4.64191 19.6332 5.53826 20.1862 6.539 20.404C10.136 21.198 13.864 21.198 17.462 20.404C18.4624 20.1861 19.3584 19.6331 20.0017 18.8366C20.6451 18.0402 20.9973 17.0479 21 16.0241V14.4771Z" fill="white"/>



        </svg> 



    ]]},







    ["shapes icon"] = {



        Format = "svg", Width = 24, Height = 24, Path = [[



        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">



        <g clip-path="url(#clip0_2035_962)">



        <path d="M7.1 16.2934C7.10278 14.8986 7.56547 13.5436 8.41638 12.4384C9.26729 11.3332 10.4589 10.5394 11.8067 10.1801L8.66666 2.00006C8.61869 1.87357 8.53336 1.76467 8.42203 1.68783C8.31069 1.61098 8.17861 1.56982 8.04333 1.56982C7.90805 1.56982 7.77597 1.61098 7.66463 1.68783C7.5533 1.76467 7.46797 1.87357 7.42 2.00006L1.38 17.7067C1.34108 17.8076 1.32727 17.9164 1.33976 18.0237C1.35224 18.1311 1.39065 18.2338 1.45166 18.323C1.51267 18.4123 1.59447 18.4853 1.68999 18.5359C1.78552 18.5865 1.89191 18.6131 2 18.6134H7.54666C7.25265 17.8752 7.10109 17.088 7.1 16.2934Z" fill="white"/>



        <path d="M21.3333 6.6665H13.3333C13.1565 6.6665 12.987 6.73674 12.8619 6.86177C12.7369 6.98679 12.6667 7.15636 12.6667 7.33317V9.99984C13.5332 9.88805 14.4135 9.9581 15.2514 10.2055C16.0893 10.453 16.8665 10.8723 17.5333 11.4369C18.2001 12.0014 18.7419 12.6988 19.1242 13.4844C19.5064 14.2701 19.7207 15.1268 19.7533 15.9998H21.3333C21.5101 15.9998 21.6797 15.9296 21.8047 15.8046C21.9298 15.6796 22 15.51 22 15.3332V7.33317C22 7.15636 21.9298 6.98679 21.8047 6.86177C21.6797 6.73674 21.5101 6.6665 21.3333 6.6665Z" fill="white"/>



        <path d="M13.4333 21.2935C16.1948 21.2935 18.4333 19.0549 18.4333 16.2935C18.4333 13.532 16.1948 11.2935 13.4333 11.2935C10.6719 11.2935 8.43333 13.532 8.43333 16.2935C8.43333 19.0549 10.6719 21.2935 13.4333 21.2935Z" fill="white"/>



        </g>



        <defs>



        <clipPath id="clip0_2035_962">



        <rect width="24" height="24" fill="white"/>



        </clipPath>



        </defs>



        </svg>   



    ]]},







    ["weight bar"] = {



        Format = "svg", Width = 261, Height = 7, Path = [[



        <svg width="261" height="7" viewBox="0 0 261 7" fill="none" xmlns="http://www.w3.org/2000/svg">



        <rect width="261" height="7" rx="3.5" fill="white"/>



        </svg>            



    ]]},







    ["send icon"] = {



        Format = "svg", Width = 16, Height = 16, Path = [[



        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">



        <g clip-path="url(#clip0_2035_1004)">



        <path d="M15.7503 0.0982143C15.9467 0.241071 16.027 0.431548 15.9913 0.669643L13.7056 14.3839C13.6759 14.5565 13.5806 14.6905 13.4199 14.7857C13.3366 14.8333 13.2443 14.8571 13.1431 14.8571C13.0776 14.8571 13.0062 14.8423 12.9288 14.8125L8.88419 13.1607L6.72347 15.7946C6.61633 15.9315 6.4705 16 6.28597 16C6.20859 16 6.14312 15.9881 6.08955 15.9643C5.97645 15.9226 5.88568 15.8527 5.81722 15.7545C5.74877 15.6563 5.71455 15.5476 5.71455 15.4286V12.3125L13.4288 2.85714L3.88419 11.1161L0.357403 9.66964C0.137164 9.58631 0.0181168 9.42262 0.000259642 9.17857C-0.0116451 8.94048 0.083593 8.76488 0.285974 8.65179L15.1431 0.0803571C15.2324 0.0267857 15.3276 0 15.4288 0C15.5479 0 15.655 0.0327381 15.7503 0.0982143Z" fill="white"/>



        </g>



        <defs>



        <clipPath id="clip0_2035_1004">



        <rect width="16" height="16" fill="white"/>



        </clipPath>



        </defs>



        </svg>              



    ]]},







    ["market icon"] = {



        Format = "svg", Width = 24, Height = 24, Path = [[



        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">



        <path fill-rule="evenodd" clip-rule="evenodd" d="M8.41828 3.25C8.69828 2.66 9.30228 2.25 10.0003 2.25H14.0003C14.6983 2.25 15.3013 2.66 15.5823 3.25C16.2653 3.256 16.7983 3.287 17.2743 3.473C17.8425 3.69527 18.3367 4.07301 18.7003 4.563C19.0673 5.057 19.2403 5.69 19.4763 6.561L20.2183 9.283L20.4983 10.124L20.5223 10.154C21.4233 11.308 20.9943 13.024 20.1363 16.455C19.5903 18.638 19.3183 19.729 18.5043 20.365C17.6903 21 16.5653 21 14.3153 21H9.68528C7.43528 21 6.31028 21 5.49628 20.365C4.68228 19.729 4.40928 18.638 3.86428 16.455C3.00628 13.024 2.57728 11.308 3.47828 10.154L3.50228 10.124L3.78228 9.283L4.52428 6.561C4.76128 5.69 4.93428 5.056 5.30028 4.562C5.664 4.07238 6.15817 3.695 6.72628 3.473C7.20228 3.287 7.73428 3.255 8.41828 3.25ZM8.42028 4.752C7.75828 4.759 7.49228 4.784 7.27228 4.87C6.96624 4.98968 6.70009 5.19311 6.50428 5.457C6.32828 5.694 6.22428 6.025 5.93428 7.092L5.36428 9.181C6.38428 9 7.77828 9 9.68428 9H14.3153C16.2223 9 17.6153 9 18.6353 9.18L18.0663 7.091C17.7763 6.024 17.6723 5.693 17.4963 5.456C17.3005 5.19211 17.0343 4.98868 16.7283 4.869C16.5083 4.783 16.2423 4.758 15.5803 4.751C15.4383 5.04985 15.2145 5.30232 14.9348 5.47914C14.6552 5.65596 14.3311 5.74987 14.0003 5.75H10.0003C9.66952 5.74996 9.34555 5.6562 9.06591 5.47956C8.78627 5.30293 8.56241 5.05066 8.42028 4.752Z" fill="white"/>



        </svg>              



    ]]},







    ["confirm button"] = {



        Format = "svg", Width = 333, Height = 64, Path = [[



        <svg width="333" height="64" viewBox="0 0 333 64" fill="none" xmlns="http://www.w3.org/2000/svg">



        <rect width="333" height="64" rx="6" fill="url(#paint0_radial_2035_1432)"/>



        <defs>



        <radialGradient id="paint0_radial_2035_1432" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(166.5 32) rotate(-21.3941) scale(131.586 466.997)">



        <stop stop-color="#4D99B1"/>



        <stop offset="1" stop-color="#3C7587"/>



        </radialGradient>



        </defs>



        </svg> 



    ]]},







    ["key icon"] = {



        Format = "svg", Width = 24, Height = 24, Path = [[



        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">



        <path d="M10.2233 7.8375C10.2233 8.44687 10.2233 9.0375 10.4155 9.59063C8.39522 11.9625 2.56396 18.7078 2.56396 18.7078L2.6999 20.4094C2.6999 20.4094 4.33115 21.9562 4.5749 21.7219C5.29678 21.0187 5.7374 20.5406 5.7374 20.5406L6.07678 18.5086L8.28506 18.3459L8.46225 16.1522L10.7887 16.1077L10.8116 13.7597L13.2815 13.8581L13.7033 12.975C14.4299 13.2891 15.0908 13.4156 15.9393 13.4156C19.1502 13.4156 21.7518 10.9125 21.7518 7.82812C21.7518 4.74375 19.1483 2.25 15.9374 2.25C12.7265 2.25 10.2233 4.75312 10.2233 7.8375ZM19.071 6.75C19.071 7.11018 18.9642 7.46227 18.7641 7.76175C18.564 8.06122 18.2796 8.29464 17.9468 8.43247C17.614 8.57031 17.2479 8.60637 16.8946 8.5361C16.5414 8.46584 16.2169 8.29239 15.9622 8.03771C15.7075 7.78302 15.5341 7.45854 15.4638 7.10528C15.3935 6.75202 15.4296 6.38586 15.5674 6.0531C15.7053 5.72034 15.9387 5.43592 16.2382 5.23582C16.5376 5.03571 16.8897 4.92891 17.2499 4.92891C17.4891 4.92866 17.726 4.9756 17.9471 5.06703C18.1682 5.15846 18.369 5.29259 18.5382 5.46174C18.7073 5.6309 18.8414 5.83175 18.9329 6.05281C19.0243 6.27386 19.0712 6.51078 19.071 6.75Z" fill="#4D99B1"/>



        </svg> 



    ]]},







    ["password icon"] = {



        Format = "svg", Width = 22, Height = 22, Path = [[



        <svg width="22" height="22" viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">



        <path d="M11 1.375C11.7293 1.375 12.4288 1.66473 12.9445 2.18046C13.4603 2.69618 13.75 3.39565 13.75 4.125V9.625H8.25V4.125C8.25 3.39565 8.53973 2.69618 9.05546 2.18046C9.57118 1.66473 10.2707 1.375 11 1.375ZM15.125 9.625V4.125C15.125 3.03098 14.6904 1.98177 13.9168 1.20818C13.1432 0.434597 12.094 0 11 0C9.90598 0 8.85677 0.434597 8.08318 1.20818C7.3096 1.98177 6.875 3.03098 6.875 4.125V9.625C6.14565 9.625 5.44618 9.91473 4.93046 10.4305C4.41473 10.9462 4.125 11.6457 4.125 12.375V19.25C4.125 19.9793 4.41473 20.6788 4.93046 21.1945C5.44618 21.7103 6.14565 22 6.875 22H15.125C15.8543 22 16.5538 21.7103 17.0695 21.1945C17.5853 20.6788 17.875 19.9793 17.875 19.25V12.375C17.875 11.6457 17.5853 10.9462 17.0695 10.4305C16.5538 9.91473 15.8543 9.625 15.125 9.625Z" fill="#4D99B1"/>



        </svg>



    ]]},







    ["user icon"] = {



        Format = "svg", Width = 24, Height = 24, Path = [[



        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">



        <path d="M12 4C13.0609 4 14.0783 4.42143 14.8284 5.17157C15.5786 5.92172 16 6.93913 16 8C16 9.06087 15.5786 10.0783 14.8284 10.8284C14.0783 11.5786 13.0609 12 12 12C10.9391 12 9.92172 11.5786 9.17157 10.8284C8.42143 10.0783 8 9.06087 8 8C8 6.93913 8.42143 5.92172 9.17157 5.17157C9.92172 4.42143 10.9391 4 12 4ZM12 14C16.42 14 20 15.79 20 18V20H4V18C4 15.79 7.58 14 12 14Z" fill="#4D99B1"/>



        </svg>     



    ]]},







    ["info icon"] = {



        Format = "svg", Width = 19, Height = 19, Path = [[



        <svg width="19" height="19" viewBox="0 0 19 19" fill="none" xmlns="http://www.w3.org/2000/svg">



        <path d="M1.35742 9.49979C1.35742 13.9967 5.00339 17.6426 9.50028 17.6426C13.9972 17.6426 17.6431 13.9967 17.6431 9.49979C17.6431 5.0029 13.9972 1.35693 9.50028 1.35693C5.00339 1.35693 1.35742 5.0029 1.35742 9.49979ZM10.3485 5.42836C10.3485 5.65332 10.2591 5.86907 10.1001 6.02814C9.94099 6.18721 9.72524 6.27658 9.50028 6.27658C9.27532 6.27658 9.05957 6.18721 8.9005 6.02814C8.74143 5.86907 8.65207 5.65332 8.65207 5.42836C8.65207 5.2034 8.74143 4.98766 8.9005 4.82858C9.05957 4.66951 9.27532 4.58015 9.50028 4.58015C9.72524 4.58015 9.94099 4.66951 10.1001 4.82858C10.2591 4.98766 10.3485 5.2034 10.3485 5.42836ZM9.50028 7.46408C9.68025 7.46408 9.85285 7.53557 9.9801 7.66283C10.1074 7.79008 10.1789 7.96268 10.1789 8.14265V13.5712C10.1789 13.7512 10.1074 13.9238 9.9801 14.051C9.85285 14.1783 9.68025 14.2498 9.50028 14.2498C9.32031 14.2498 9.14771 14.1783 9.02046 14.051C8.8932 13.9238 8.82171 13.7512 8.82171 13.5712V8.14265C8.82171 7.96268 8.8932 7.79008 9.02046 7.66283C9.14771 7.53557 9.32031 7.46408 9.50028 7.46408Z" fill="#59B268"/>



        </svg>       



    ]]},







}







function loadImages()



    Images = {}



    for i, v in pairs(ImagesPath) do



        if v["Format"] == "svg" then



            Images[i] = svgCreate(sx*v["Width"], sy*v["Height"], v["Path"])



            dxSetTextureEdge(Images[i], "border")



        else



            Images[i] = v["Path"]



        end



    end



end



addEventHandler("onClientResourceStart", resourceRoot, loadImages)







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







--| Sort's







local cache = {}



function sortTableByText(id, tbl, text)







    if not cache[id] then 



        cache[id] = {



            ['text'] = (text or ""),



            ['sorted'] = {},



        }



    end



    



    if (#cache[id]["text"] ~= #text) then 







        cache[id] = {



            ['text'] = (text or ""),



            ['sorted'] = {},



        }







        for i = 1, #tbl do



            if string.find(string.upper( config['itens'][ tbl[i]['item'] ]['name'] ), string.upper(text)) then 



                cache[id]['sorted'][ #cache[id]['sorted'] + 1 ] = tbl[i]



            end



        end







    end







    return (#cache[id]['text'] ~= 0 and cache[id]['sorted'] or tbl)



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

sizecc = {}
function _drawBorder ( radius, x, y, width, height, color, colorStroke, sizeStroke, postGUI )

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



function formatNumberC (number, sep)

	local money = number

	for i = 1, tostring(money):len()/3 do

		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1.%2")

	end

	return money

end