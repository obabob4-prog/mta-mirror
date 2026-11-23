local function formatNumber(number)

	local money = number

	for i = 1, tostring(money):len()/3 do

		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1.%2")

	end

	return money

end



local screenW, screenH = guiGetScreenSize();

local screenScale = math.min(math.max(screenH / 768, 0.70), 2); -- Caso o painel seja muito grande, retirar o limite e deixar apenas o (screenH / 768).



local parentW, parentH = (620 * screenScale), (440 * screenScale); -- Comprimento e Largura do painel.

local parentX, parentY = ((screenW - parentW) / 2), ((screenH - parentH) / 2); -- Posição X e Y do painel.



local function respX (x)

    return (parentX + (x * screenScale));

end



local function respY (y)

    return (parentY + (y * screenScale));

end



local function respC (scale)

    return (scale * screenScale);

end



local _dxDrawImageSection = dxDrawImageSection;

local function dxDrawImageSection(x, y, width, height, u, v, uSize, vSize, ...)

    return _dxDrawImageSection(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), 0, 0, uSize, vSize, ...);

end



local _dxDrawText = dxDrawText;

local function dxDrawText(text, x, y, width, height, ...)

    return _dxDrawText(text, respX(x), respY(y+(animationY or 0)), (respX(x) + respC(width)), (respY(y+(animationY or 0)) + respC(height)), ...);

end



local _dxDrawRectangle = dxDrawRectangle;

local function dxDrawRectangle(x, y, width, height, ...)

    return _dxDrawRectangle(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);

end



local _dxDrawImage = dxDrawImage;

local function dxDrawImage(x, y, width, height, ...)

    return _dxDrawImage(respX(x), respY(y+(animationY or 0)), respC(width), respC(height), ...);

end



size = {}

local function dxDrawRounded (x, y, w, h, radius, ...)

    if not size[w..'.'..h..':'..radius] then

        local svg = string.format([[ <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'> <mask id='path_inside' fill='#FFFFFF' > <rect width='%s' height='%s' rx='%s' /> </mask> <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/> </svg> ]], w, h, w, h, radius, w, h, radius, tostring(''), tostring(''))

        size[w..'.'..h..':'..radius] = svgCreate(w, h, svg)

    else

        dxDrawImage(x, y, w, h, size[w..'.'..h..':'..radius], 0, 0, 0, ...)

    end

end



local cursor = {}

local function isMouseInPosition (x, y, width, height)

    if (not cursor.state) then

        return false

    end

    if not (cursor.x and cursor.y) then

        return false;

    end

    x, y, width, height = respX(x), respY(y), respC(width), respC(height);

    return ((cursor.x >= x and cursor.x <= x + width) and (cursor.y >= y and cursor.y <= y + height));

end



local font = {}

local function getFont (name, size)

    if not font[name] then

        font[name] = {}

    end

    if not font[name][size] then

        font[name][size] = dxCreateFont('assets/fonts/'..name..'.ttf', respC(size/1.25))

    end

    return font[name][size]

end



local _svgCreate = svgCreate

local function svgCreate (w, h, ...)

    return _svgCreate(w*4, h*4, ...)

end



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

    else

        if isElement(edit[action]) then

            destroyElement(edit[action])

            edit[action] = nil

        end

    end

end



function setEditboxEditing (action)

    if guiEditSetCaretIndex(edit[action], string.len(guiGetText(edit[action]))) then

        guiBringToFront(edit[action])

        guiSetInputMode('no_binds_when_editing')

        selectEditbox = action

    end

end



function getEditboxValue (action, drawing)

    if (drawing == true) then

        local editbox = guiGetText(edit[action])

        if action == 'Valor' then

            if selectEditbox == action then

                return (editbox == '' and '' or 'R$ '..formatNumber(editbox))..'|'

            else

                return (editbox == '' and action or 'R$ '..formatNumber(editbox))

            end

        else

            if selectEditbox == action then

                return editbox..'|'

            else

                return (editbox == '' and action or editbox)

            end

        end

    else

        local editbox = guiGetText(edit[action])

        return editbox

    end

end



local svg = {



    ['background'] = svgCreate(620, 440,

        [[

            <svg width="620" height="440" viewBox="0 0 620 440" fill="none" xmlns="http://www.w3.org/2000/svg">

                <rect x="0.5" y="0.5" width="619" height="439" rx="11.5" fill="#191919" fill-opacity="0.98" stroke="#222222"/>

            </svg>            

        ]]

    ),



    ['myVehicles'] = svgCreate(120, 30,

        [[

            <svg width="120" height="30" viewBox="0 0 120 30" fill="none" xmlns="http://www.w3.org/2000/svg">

                <path d="M0 0H105C113.284 0 120 6.71573 120 15C120 23.2843 113.284 30 105 30H0V0Z" fill="white"/>

            </svg>

        ]]

    ),



    ['close'] = svgCreate(36, 36,

        [[

            <svg width="36" height="36" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">

                <path d="M0 0H24C30.6274 0 36 5.37258 36 12V36H12C5.37258 36 0 30.6274 0 24V0Z" fill="white" fill-opacity="0.5"/>

                <path d="M18 19.2776L13.5285 23.749C13.3612 23.9163 13.1483 24 12.8897 24C12.6312 24 12.4183 23.9163 12.251 23.749C12.0836 23.5817 12 23.3688 12 23.1103C12 22.8517 12.0836 22.6388 12.251 22.4715L16.7224 18L12.251 13.5285C12.0836 13.3612 12 13.1483 12 12.8897C12 12.6312 12.0836 12.4183 12.251 12.251C12.4183 12.0836 12.6312 12 12.8897 12C13.1483 12 13.3612 12.0836 13.5285 12.251L18 16.7224L22.4715 12.251C22.6388 12.0836 22.8517 12 23.1103 12C23.3688 12 23.5817 12.0836 23.749 12.251C23.9163 12.4183 24 12.6312 24 12.8897C24 13.1483 23.9163 13.3612 23.749 13.5285L19.2776 18L23.749 22.4715C23.9163 22.6388 24 22.8517 24 23.1103C24 23.3688 23.9163 23.5817 23.749 23.749C23.5817 23.9163 23.3688 24 23.1103 24C22.8517 24 22.6388 23.9163 22.4715 23.749L18 19.2776Z" fill="white"/>

            </svg>

        ]]

    ),



    ['button'] = svgCreate(137.38, 35,

        [[

            <svg width="138" height="35" viewBox="0 0 138 35" fill="none" xmlns="http://www.w3.org/2000/svg">

                <rect x="0.539673" width="137.381" height="35" rx="17.5" fill="white"/>

            </svg>

        ]]

    ),



    ['border'] = svgCreate(577, 266,

        [[

            <svg width="577" height="266" viewBox="0 0 577 266" fill="none" xmlns="http://www.w3.org/2000/svg">

                <rect width="577" height="266" rx="7" fill="#1E1E1E" fill-opacity="0.95" />

            </svg>

        ]]

    ),



    ['click'] = svgCreate(13*2, 15*2,

        [[

            <svg width="13" height="15" viewBox="0 0 13 15" fill="none" xmlns="http://www.w3.org/2000/svg">

                <path d="M2.47873 4.15831C2.47873 3.05546 2.87065 1.99778 3.56828 1.21794C4.26591 0.438107 5.2121 0 6.19869 0C7.18529 0 8.13147 0.438107 8.8291 1.21794C9.52673 1.99778 9.91865 3.05546 9.91865 4.15831C9.91865 4.30536 9.8664 4.44638 9.77338 4.55036C9.68036 4.65434 9.5542 4.71275 9.42266 4.71275C9.29111 4.71275 9.16495 4.65434 9.07194 4.55036C8.97892 4.44638 8.92666 4.30536 8.92666 4.15831C8.92666 3.34955 8.63925 2.57392 8.12766 2.00204C7.61606 1.43016 6.92219 1.10888 6.19869 1.10888C5.47519 1.10888 4.78132 1.43016 4.26972 2.00204C3.75813 2.57392 3.47072 3.34955 3.47072 4.15831C3.47072 4.30536 3.41846 4.44638 3.32544 4.55036C3.23243 4.65434 3.10627 4.71275 2.97472 4.71275C2.84318 4.71275 2.71702 4.65434 2.624 4.55036C2.53099 4.44638 2.47873 4.30536 2.47873 4.15831ZM11.1586 7.20774C10.8693 7.20738 10.5845 7.28816 10.3303 7.44268C10.2544 7.17995 10.1291 6.93835 9.96298 6.73404C9.79682 6.52973 9.59358 6.36741 9.36682 6.25793C9.14006 6.14844 8.89501 6.09431 8.64804 6.09914C8.40107 6.10398 8.15786 6.16768 7.93467 6.28598V4.15831C7.93467 3.64365 7.75178 3.15006 7.42622 2.78614C7.10066 2.42222 6.6591 2.21777 6.19869 2.21777C5.73828 2.21777 5.29673 2.42222 4.97117 2.78614C4.64561 3.15006 4.46271 3.64365 4.46271 4.15831V9.70273L4.22587 9.27789C3.99427 8.83298 3.61404 8.50914 3.16884 8.3776C2.72364 8.24607 2.24992 8.31762 1.85192 8.57652C1.45391 8.83541 1.1642 9.26044 1.04654 9.75811C0.92887 10.2558 0.992879 10.7853 1.22448 11.2302L3.0423 14.6955C3.07279 14.763 3.1153 14.8228 3.16723 14.8712C3.21916 14.9197 3.2794 14.9557 3.34425 14.9772C3.40911 14.9987 3.47721 15.0051 3.54436 14.996C3.61151 14.987 3.6763 14.9627 3.73474 14.9246C3.79318 14.8866 3.84404 14.8355 3.88419 14.7747C3.92435 14.7139 3.95294 14.6445 3.96822 14.5708C3.98351 14.4972 3.98515 14.4208 3.97305 14.3464C3.96096 14.272 3.93538 14.2012 3.89789 14.1383L2.08193 10.673C2.03095 10.5783 1.99735 10.4733 1.9831 10.3639C1.96885 10.2546 1.97423 10.1432 1.99894 10.0362C2.02364 9.92921 2.06716 9.8288 2.12697 9.74083C2.18678 9.65285 2.26167 9.57909 2.34726 9.52383C2.43286 9.46858 2.52745 9.43294 2.6255 9.41901C2.72356 9.40508 2.82312 9.41313 2.91836 9.44268C3.0136 9.47224 3.10262 9.52272 3.18021 9.59117C3.2578 9.65962 3.32242 9.74466 3.37028 9.84134L3.37896 9.85728L4.53711 11.9364C4.59397 12.039 4.67921 12.118 4.7799 12.1615C4.88059 12.205 4.99122 12.2106 5.09501 12.1775C5.1988 12.1443 5.29007 12.0742 5.35499 11.9778C5.4199 11.8814 5.45491 11.7639 5.4547 11.6433V4.15831C5.4547 3.93774 5.53308 3.7262 5.67261 3.57024C5.81213 3.41427 6.00137 3.32665 6.19869 3.32665C6.39601 3.32665 6.58525 3.41427 6.72477 3.57024C6.8643 3.7262 6.94268 3.93774 6.94268 4.15831V8.87106C6.94268 9.01811 6.99494 9.15914 7.08796 9.26311C7.18097 9.36709 7.30713 9.42551 7.43868 9.42551C7.57022 9.42551 7.69638 9.36709 7.7894 9.26311C7.88242 9.15914 7.93467 9.01811 7.93467 8.87106V8.0394C7.93467 7.81883 8.01306 7.60729 8.15258 7.45133C8.29211 7.29536 8.48135 7.20774 8.67867 7.20774C8.87598 7.20774 9.06522 7.29536 9.20475 7.45133C9.34427 7.60729 9.42266 7.81883 9.42266 8.0394V9.42551C9.42266 9.57255 9.47491 9.71358 9.56793 9.81756C9.66095 9.92153 9.78711 9.97995 9.91865 9.97995C10.0502 9.97995 10.1764 9.92153 10.2694 9.81756C10.3624 9.71358 10.4146 9.57255 10.4146 9.42551V9.14828C10.4146 8.92771 10.493 8.71618 10.6326 8.56021C10.7721 8.40424 10.9613 8.31662 11.1586 8.31662C11.356 8.31662 11.5452 8.40424 11.6847 8.56021C11.8242 8.71618 11.9026 8.92771 11.9026 9.14828V11.6433C11.9026 13.141 11.4624 14.159 11.4587 14.1674C11.4 14.2989 11.3903 14.4511 11.432 14.5906C11.4736 14.73 11.563 14.8453 11.6807 14.911C11.7495 14.9499 11.8255 14.9701 11.9026 14.9699C11.9948 14.97 12.0851 14.9414 12.1635 14.8873C12.2419 14.8332 12.3053 14.7557 12.3465 14.6636C12.3695 14.613 12.8952 13.4161 12.8952 11.6433V9.14828C12.8952 8.89339 12.8503 8.64099 12.763 8.40551C12.6758 8.17003 12.5478 7.95607 12.3866 7.77587C12.2253 7.59566 12.0339 7.45274 11.8232 7.35526C11.6125 7.25778 11.3867 7.20765 11.1586 7.20774Z" fill="white"/>

            </svg>

        ]]

    ),



    ['sell'] = svgCreate(24, 24,

        [[

            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">

                <path d="M14.25 21.4C13.8667 21.7833 13.3917 21.975 12.825 21.975C12.2583 21.975 11.7833 21.7833 11.4 21.4L2.60001 12.6C2.41667 12.4167 2.27067 12.2 2.16201 11.95C2.05334 11.7 1.99934 11.4333 2.00001 11.15V4C2.00001 3.45 2.19601 2.979 2.58801 2.587C2.98001 2.195 3.45067 1.99934 4.00001 2H11.15C11.4333 2 11.7 2.05434 11.95 2.163C12.2 2.27167 12.4167 2.41733 12.6 2.6L21.4 11.425C21.7833 11.8083 21.975 12.2793 21.975 12.838C21.975 13.3967 21.7833 13.8673 21.4 14.25L14.25 21.4ZM6.50001 8C6.91667 8 7.27101 7.854 7.56301 7.562C7.85501 7.27 8.00067 6.916 8.00001 6.5C8.00001 6.08334 7.85401 5.729 7.56201 5.437C7.27001 5.145 6.91601 4.99934 6.50001 5C6.08334 5 5.72901 5.146 5.43701 5.438C5.14501 5.73 4.99934 6.084 5.00001 6.5C5.00001 6.91667 5.14601 7.271 5.43801 7.563C5.73001 7.855 6.08401 8.00067 6.50001 8Z" fill="#AFAFAF"/>

            </svg>

        ]]

    ),



    ['passaporte'] = svgCreate(24, 24,

        [[

            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">

                <path d="M14 15L15.5 16.5M8.5 12.5C8.5 13.2956 8.81607 14.0587 9.37868 14.6213C9.94129 15.1839 10.7044 15.5 11.5 15.5C12.2956 15.5 13.0587 15.1839 13.6213 14.6213C14.1839 14.0587 14.5 13.2956 14.5 12.5C14.5 11.7044 14.1839 10.9413 13.6213 10.3787C13.0587 9.81607 12.2956 9.5 11.5 9.5C10.7044 9.5 9.94129 9.81607 9.37868 10.3787C8.81607 10.9413 8.5 11.7044 8.5 12.5Z" stroke="#AFAFAF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>

                <path d="M4 21.4V2.6C4 2.44087 4.06321 2.28826 4.17574 2.17574C4.28826 2.06321 4.44087 2 4.6 2H16.252C16.4111 2.00014 16.5636 2.06345 16.676 2.176L19.824 5.324C19.88 5.3799 19.9243 5.44632 19.9545 5.51943C19.9847 5.59254 20.0002 5.6709 20 5.75V21.4C20 21.4788 19.9845 21.5568 19.9543 21.6296C19.9242 21.7024 19.88 21.7685 19.8243 21.8243C19.7685 21.88 19.7024 21.9242 19.6296 21.9543C19.5568 21.9845 19.4788 22 19.4 22H4.6C4.52121 22 4.44319 21.9845 4.37039 21.9543C4.29759 21.9242 4.23145 21.88 4.17574 21.8243C4.12002 21.7685 4.07583 21.7024 4.04567 21.6296C4.01552 21.5568 4 21.4788 4 21.4Z" stroke="#AFAFAF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>

                <path d="M16 2V5.4C16 5.55913 16.0632 5.71174 16.1757 5.82426C16.2883 5.93679 16.4409 6 16.6 6H20" stroke="#AFAFAF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>

            </svg>

        ]]

    ),



    ['value'] = svgCreate(24, 24,

        [[

            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">

                <path fill-rule="evenodd" clip-rule="evenodd" d="M12.0194 3C9.76094 3 7.70344 3.746 6.48594 4.3555C6.37594 4.4105 6.27344 4.4645 6.17794 4.5165C5.98894 4.6195 5.82794 4.7155 5.69994 4.8L7.08494 6.839L7.73694 7.0985C10.2849 8.384 13.7019 8.384 16.2504 7.0985L16.9904 6.7145L18.2999 4.8C18.0287 4.62303 17.7467 4.46322 17.4554 4.3215C16.2439 3.7185 14.2354 3 12.0199 3H12.0194ZM8.79844 5.308C8.308 5.21623 7.8236 5.09467 7.34794 4.944C8.48844 4.4375 10.1879 3.9 12.0194 3.9C13.2879 3.9 14.4874 4.158 15.4794 4.485C14.3169 4.6485 13.0764 4.926 11.8944 5.2675C10.9644 5.5365 9.87744 5.5075 8.79844 5.308ZM16.7784 7.84L16.6554 7.902C13.8524 9.316 10.1344 9.316 7.33144 7.902L7.21494 7.843C3.00394 12.4635 -0.21106 20.9985 12.0194 20.9985C24.2499 20.9985 20.9564 12.304 16.7784 7.84ZM11.4999 12C11.2347 12 10.9804 12.1054 10.7928 12.2929C10.6053 12.4804 10.4999 12.7348 10.4999 13C10.4999 13.2652 10.6053 13.5196 10.7928 13.7071C10.9804 13.8946 11.2347 14 11.4999 14V12ZM12.4999 11V10.5H11.4999V11C10.9695 11 10.4608 11.2107 10.0857 11.5858C9.71066 11.9609 9.49994 12.4696 9.49994 13C9.49994 13.5304 9.71066 14.0391 10.0857 14.4142C10.4608 14.7893 10.9695 15 11.4999 15V17C11.0649 17 10.6944 16.7225 10.5564 16.3335C10.536 16.2699 10.5029 16.211 10.4593 16.1603C10.4157 16.1097 10.3623 16.0683 10.3024 16.0386C10.2425 16.0089 10.1773 15.9916 10.1105 15.9875C10.0438 15.9835 9.97693 15.9929 9.9139 16.0152C9.85086 16.0375 9.79293 16.0721 9.74354 16.1172C9.69414 16.1622 9.65428 16.2167 9.62631 16.2775C9.59835 16.3382 9.58284 16.4039 9.58072 16.4707C9.57859 16.5376 9.58989 16.6041 9.61394 16.6665C9.75186 17.0565 10.0073 17.3941 10.345 17.6329C10.6828 17.8718 11.0863 18 11.4999 18V18.5H12.4999V18C13.0304 18 13.5391 17.7893 13.9142 17.4142C14.2892 17.0391 14.4999 16.5304 14.4999 16C14.4999 15.4696 14.2892 14.9609 13.9142 14.5858C13.5391 14.2107 13.0304 14 12.4999 14V12C12.9349 12 13.3054 12.2775 13.4434 12.6665C13.4639 12.7301 13.4969 12.789 13.5406 12.8397C13.5842 12.8903 13.6376 12.9317 13.6975 12.9614C13.7574 12.9911 13.8226 13.0084 13.8894 13.0125C13.9561 13.0165 14.0229 13.0071 14.086 12.9848C14.149 12.9625 14.2069 12.9279 14.2563 12.8828C14.3057 12.8378 14.3456 12.7833 14.3736 12.7225C14.4015 12.6618 14.417 12.5961 14.4192 12.5293C14.4213 12.4624 14.41 12.3959 14.3859 12.3335C14.248 11.9435 13.9926 11.6059 13.6548 11.3671C13.3171 11.1282 12.9136 11 12.4999 11ZM12.4999 15V17C12.7652 17 13.0195 16.8946 13.207 16.7071C13.3946 16.5196 13.4999 16.2652 13.4999 16C13.4999 15.7348 13.3946 15.4804 13.207 15.2929C13.0195 15.1054 12.7652 15 12.4999 15Z" fill="#AFAFAF"/>

            </svg>            

        ]]

    ),



}

local stateSelected = 'normal'


local function render ()



    cursor.state = isCursorShowing ();

    if (cursor.state) then

        local cursorX, cursorY = getCursorPosition ();

        cursor.x, cursor.y = cursorX * screenW, cursorY * screenH;

    end

    

    local alpha = interpolateBetween(effect[1], 0, 0, effect[2], 0, 0, ((getTickCount()-effect[3])/effect[4]), 'Linear')

    animationY = interpolateBetween(animation[1], 0, 0, animation[2], 0, 0, ((getTickCount()-animation[3])/animation[4]), 'InOutQuad')

    

    dxDrawImage(0, 0, 620, 440, svg['background'], 0, 0, 0, tocolor(255, 255, 255, alpha))

    dxDrawImage(217, 20, 37, 56, 'assets/images/logo.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

    dxDrawRounded(267, 40, 3, 15, 1, tocolor(255, 255, 255, alpha * 0.1))

    dxDrawText('Detran', 283, 20, 62, 18, tocolor(255, 255, 255, alpha * 0.95), 1, getFont('bold', 12), 'left', 'center')

    dxDrawImage(288, 46, 120, 30, svg['myVehicles'], 0, 0, 0, tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha))

    dxDrawText((#vehiclesDetran or 0)..' Veículo(s)', 298, 46, 105, 30, tocolor(22, 22, 22, alpha), 1, getFont('medium', 10), 'left', 'center')

    dxDrawRounded(20, 89, 580, 2, 1, tocolor(255, 255, 255, alpha * 0.1))

    dxDrawImage(584, 0, 36, 36, svg['close'], 0, 0, 0, isMouseInPosition(584, 0, 36, 36) and tocolor(217, 55, 55, alpha) or tocolor(68, 68, 68, alpha))



    dxDrawImage(20, 104, 577, 266, svg['border'], 0, 0, 0, tocolor(255, 255, 255, alpha))

    dxDrawText('Nome', 35, 119, 240, 14, tocolor(255, 255, 255, alpha * 0.7), 1, getFont('medium', 12), 'left', 'center')

    dxDrawText('Placa', 225, 119, 29, 14, tocolor(255, 255, 255, alpha * 0.7), 1, getFont('medium', 12), 'center', 'center')

    dxDrawText('Seguro', 370, 119, 38, 14, tocolor(255, 255, 255, alpha * 0.7), 1, getFont('medium', 12), 'center', 'center')

    dxDrawText('Rastreador', 544, 119, 38, 14, tocolor(255, 255, 255, alpha * 0.7), 1, getFont('medium', 12), 'right', 'center')



    local linha = 0

    for i, v in ipairs(vehiclesDetran) do
        if (i > proxPag and linha < 5) then

            linha = linha + 1

            local py = 142 + (38 * (linha - 1))

            mouseIn = false

            if isMouseInPosition(20, py, 577, 35) then
                mouseIn = true
            end

            local state_ = v[6].state >= 2 and 'detido' or 'normal'

            if (selectVehicle == i) then
                dxDrawRectangle(20, py, 577, 35, tocolor(255, 255, 255, alpha * 0.03))
            end

            

            dxDrawText(v[2], 35, py, 240, 35, (mouseIn or (selectVehicle == i)) and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(124, 124, 124, alpha), 1, getFont('medium', 12), 'left', 'center')
            dxDrawText(v[3], 225, py, 29, 35, (mouseIn or (selectVehicle == i)) and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(124, 124, 124, alpha), 1, getFont('medium', 12), 'center', 'center')
            if state_ == 'detido' then
                dxDrawText('Indisponível', 370, py, 38, 35, (mouseIn or (selectVehicle == i)) and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(124, 124, 124, alpha), 1, getFont('medium', 12), 'center', 'center')
                dxDrawText('Indisponível', 544, py, 38, 35, (mouseIn or (selectVehicle == i)) and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(124, 124, 124, alpha), 1, getFont('medium', 12), 'right', 'center')
            else
                dxDrawText(v[5], 370, py, 38, 35, (mouseIn or (selectVehicle == i)) and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(124, 124, 124, alpha), 1, getFont('medium', 12), 'center', 'center')
                dxDrawText(v[4], 544, py, 38, 35, (mouseIn or (selectVehicle == i)) and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(124, 124, 124, alpha), 1, getFont('medium', 12), 'right', 'center')
            end


        end
    end



    if vehiclesDetran and #vehiclesDetran > 5 then

        dxDrawImage(239, 337, 129, 18, 'assets/images/maisscroll.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

    end



    buttonRastreador = false

    buttonEmplacar = false

    buttonSeguro = false

    buttonTransferir = false



    if isMouseInPosition(20, 386, 137.38, 35) then

        buttonRastreador = true

    elseif isMouseInPosition(166.54, 386, 137.38, 35) then

        buttonEmplacar = true

    elseif isMouseInPosition(313.08, 386, 137.38, 35) then

        buttonSeguro = true

    elseif isMouseInPosition(459.62, 386, 137.38, 35) then

        buttonTransferir = true

    end



    dxDrawImage(20, 386, 137.38, 35, svg['button'], 0, 0, 0, buttonRastreador and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha * 0.3))

    dxDrawText('Rastreador', 20, 386, 137.38, 35, buttonRastreador and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha), 1, getFont('medium', 10), 'center', 'center')

    dxDrawImage(128.99, 396, 11.91, 15, svg['click'], 0, 0, 0, buttonRastreador and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha))

    

    dxDrawImage(166.54, 386, 137.38, 35, svg['button'], 0, 0, 0, buttonEmplacar and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha * 0.3))

    dxDrawText('Emplacar', 166.54, 386, 137.38, 35, buttonEmplacar and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha), 1, getFont('medium', 10), 'center', 'center')

    dxDrawImage(166.54+108.99, 396, 11.91, 15, svg['click'], 0, 0, 0, buttonEmplacar and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha))

    

    dxDrawImage(313.08, 386, 137.38, 35, svg['button'], 0, 0, 0, buttonSeguro and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha * 0.3))

    dxDrawText('Seguro', 313.08, 386, 137.38, 35, buttonSeguro and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha), 1, getFont('medium', 10), 'center', 'center')

    dxDrawImage(313.08+108.99, 396, 11.91, 15, svg['click'], 0, 0, 0, buttonSeguro and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha))

    
    dxDrawImage(459.62, 386, 137.38, 35, svg['button'], 0, 0, 0, buttonTransferir and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha * 0.3))
    if stateSelected == 'detido' then
        dxDrawText('Pagar Taxa', 459.62, 386, 137.38, 35, buttonTransferir and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha), 1, getFont('medium', 10), 'center', 'center')
    else
        dxDrawText('Transferir', 459.62, 386, 137.38, 35, buttonTransferir and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha), 1, getFont('medium', 10), 'center', 'center')
    end
    dxDrawImage(459.624+108.99, 396, 11.91, 15, svg['click'], 0, 0, 0, buttonTransferir and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha))





    if transferir then

        dxDrawImage(0, 0, 620, 440, svg['background'], 0, 0, 0, tocolor(255, 255, 255, alpha*0.95))

        dxDrawRounded(170, 157, 280, 126, 10, tocolor(32, 32, 32, alpha))

        dxDrawImage(180, 167, 24, 24, svg['sell'], 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('Preencha as informações para transferir seu veículo.', 209, 164, 228, 31, tocolor(175, 175, 175, alpha), 1, getFont('medium', 10), 'left', 'center', false, true)

        dxDrawRounded(180, 204, 103, 32, 10, tocolor(40, 40, 40, alpha))

        dxDrawImage(186, 209, 22, 22, svg['passaporte'], 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(getEditboxValue('Passaporte', true), 180-10, 204, 103, 32, tocolor(170, 170, 170, alpha), 1, getFont('medium', 10), 'right', 'center')

        dxDrawRounded(288, 204, 152, 32, 10, tocolor(40, 40, 40, alpha))

        dxDrawImage(293, 208, 24, 24, svg['value'], 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText(getEditboxValue('Valor', true), 288-10, 204, 152, 32, tocolor(170, 170, 170, alpha), 1, getFont('medium', 10), 'right', 'center')

        dxDrawRounded(180, 241, 223, 32, 10, isMouseInPosition(180, 241, 223, 32) and tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha * 0.3))

        dxDrawText('Enviar proposta', 180, 241, 223, 32, isMouseInPosition(180, 241, 223, 32) and tocolor(22, 22, 22, alpha) or tocolor(colorDetails[1], colorDetails[2], colorDetails[3], alpha), 1, getFont('medium', 10), 'center', 'center')

        dxDrawRounded(408, 241, 32, 32, 10, isMouseInPosition(408, 241, 32, 32) and tocolor(217, 71, 71, alpha*0.5) or tocolor(40, 40, 40, alpha))

        dxDrawText('X', 408.5, 241, 32, 32, tocolor(170, 170, 170, alpha), 1, getFont('medium', 12), 'center', 'center')

    end



end



function number (str)

    return type(str) == "string" and str:match("^%d+$") ~= nil

end



local function click (button, state)

    if button == 'left' and state == 'down' then

        selectEditbox = nil

        if transferir then

            if isMouseInPosition(408, 241, 32, 32) then

                transferir = false

            elseif isMouseInPosition(288, 204, 152, 32) then

                setEditboxEditing('Valor')

            elseif isMouseInPosition(180, 204, 103, 32) then

                setEditboxEditing('Passaporte')

            elseif isMouseInPosition(180, 241, 223, 32) then

                local value = getEditboxValue('Valor')

                local passaport = getEditboxValue('Passaporte')

                if value and value ~= '' and number(value) then

                    if passaport and passaport ~= '' and number(passaport) then

                        triggerServerEvent('enviarPropostaVehicle', localPlayer, transferir, tonumber(passaport), tonumber(value))

                        detranPanel(w)

                    else

                        others['notify']('client', _, 'Você precisa digitar um número no passaporte.', 'info')

                    end

                else

                    others['notify']('client', _, 'Você precisa digitar um número no valor.', 'info')

                end 

            end

            return

        end

        if isMouseInPosition(584, 0, 36, 36) then

            detranPanel () 

        elseif isMouseInPosition(20, 386, 137.38, 35) then

            if selectVehicle and vehiclesDetran[selectVehicle] then

                if string.lower(vehiclesDetran[selectVehicle][4]) == 'não' then

                    triggerServerEvent('onDetranAction', localPlayer, 'rastreador', vehiclesDetran[selectVehicle][1])

                else

                    others['notify']('client', _, 'Este veículo já possui rastreador.', 'info')

                end

            end

        elseif isMouseInPosition(166.54, 386, 137.38, 35) then

            if selectVehicle and vehiclesDetran[selectVehicle] then

                if string.lower(vehiclesDetran[selectVehicle][3]) == 'sem placa' then

                    triggerServerEvent('onDetranAction', localPlayer, 'emplacar', vehiclesDetran[selectVehicle][1])

                else

                    others['notify']('client', _, 'Este veículo já está emplacado.', 'info')

                end

            end

        elseif isMouseInPosition(313.08, 386, 137.38, 35) then

            if selectVehicle and vehiclesDetran[selectVehicle] then

                if string.lower(vehiclesDetran[selectVehicle][5]) == 'não' then

                    triggerServerEvent('onDetranAction', localPlayer, 'seguro', vehiclesDetran[selectVehicle][1])

                else

                    others['notify']('client', _, 'Este veículo já possui seguro.', 'info')

                end

            end

        elseif isMouseInPosition(459.62, 386, 137.38, 35) then

            if(stateSelected == 'detido') then

                if vehicles[vehiclesDetran[selectVehicle][1]] and vehicles[vehiclesDetran[selectVehicle][1]] and vehicles[vehiclesDetran[selectVehicle][1]].valor > 0 then
                    valor = vehicles[vehiclesDetran[selectVehicle][1]].valor
                else
                    valor = 80000
                end

                poupTaxa = {
                    name = vehiclesDetran[selectVehicle][2],
                    price = math.floor((valor / 100) * 30),
                    model = vehiclesDetran[selectVehicle][1],
                }

                triggerServerEvent('pagarTaxaVehicle', resourceRoot, localPlayer, poupTaxa)
                return
            end

            if selectVehicle and vehiclesDetran[selectVehicle] then

                carsSellBlocked = {
                    [411] = true,
                    [516] = true,
                    [586] = true,
                    [471] = true,
                    [405] = true,
                    [585] = true,
                    [522] = true,
                    [541] = true,
                    [422] = true,
                    [494] = true,
                    [503] = true,
                    [477] = true,
                    [547] = true,
                    [426] = true,
                    [546] = true,
                    [559] = true,
                    [565] = true,
                    [456] = true,
                    [431] = true,
                    [603] = true,
                    [438] = true,
                }

                if carsSellBlocked[vehiclesDetran[selectVehicle][1]] then

                    return others['notify']('client', _, 'Este veículo não pode ser transferido.', 'info')

                else

                    transferir = vehiclesDetran[selectVehicle][1]

                    guiSetText(edit['Valor'], '')

                    guiSetText(edit['Passaporte'], '')

                end

            end

        else

            local linha = 0

            for i, v in ipairs(vehiclesDetran) do

                if (i > proxPag and linha < 5) then

                    linha = linha + 1

                    local py = 142 + (38 * (linha - 1))

                    if isMouseInPosition(20, py, 577, 35) then

                        selectVehicle = i
                        stateSelected = v[6].state >= 2 and 'detido' or 'normal'

                    end

                end

            end

        end

    end

end



local function key (button, press)

    if (button == 'mouse_wheel_down' and press) then

        proxPag = proxPag + 1

        if (proxPag > (#vehiclesDetran - 5)) then

            proxPag = (#vehiclesDetran - 5)

        end

    elseif (button == 'mouse_wheel_up' and press) then

        if (proxPag > 0) then

            proxPag = proxPag - 1

        end

    end

end



addEvent('detranUpdate', true)

addEventHandler('detranUpdate', root, function (tableVehicles)

    selectVehicle = nil

    vehiclesDetran = tableVehicles

    proxPag = 0

end)



function detranPanel  (tableVehicles)

    if not visible and tableVehicles then

        selectVehicle = nil

        vehiclesDetran = tableVehicles

        proxPag = 0

        effect = {0, 255, getTickCount(), 150}

        animation = {150, 0, getTickCount(), 150}

        visible = true

        createEditbox('Passaporte', 10, true)

        createEditbox('Valor', 10, true)

        showCursor(true)

        addEventHandler('onClientRender', root, render)

        addEventHandler('onClientClick', root, click)

        addEventHandler('onClientKey', root, key)

    elseif visible then

        if not closing then

            showCursor(false)

            removeEventHandler('onClientClick', root, click)

            removeEventHandler('onClientKey', root, key)

            closing = true

            effect = {255, 0, getTickCount(), 150}

            animation = {0, 150, getTickCount(), 150}

            setTimer(function ()

                closing = false

                visible = false

                removeEventHandler('onClientRender', root, render)

            end, effect[4] + 50, 1)

        end

    end

end

addEvent('detranStatePanel', true)

addEventHandler('detranStatePanel', root, detranPanel)