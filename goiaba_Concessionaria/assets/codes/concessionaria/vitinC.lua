local function formatNumber(number)
	local money = number
	for i = 1, tostring(money):len()/3 do
		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1.%2")
	end
	return money
end

local screen = {guiGetScreenSize()}
local screenW, screenH = guiGetScreenSize();

local function aToR(x, y, w, h)
    local xd = x/1920 or x
    local yd = y/1080 or y
    local xsd = w/1920 or w
    local ysd = h/1080 or h
    return xd * screenW, yd * screenH, xsd * screenW, ysd * screenH
end

local _dxDrawRectangle = dxDrawRectangle
local function dxDrawRectangle(x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawRectangle(x, y, w, h, ...)
end

local _dxDrawText = dxDrawText
local function dxDrawText(text, x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w + x, h + y)
    return _dxDrawText(text, x, y, w, h, ...)
end

imageFile = {}
local _dxDrawImage = dxDrawImage
local function dxDrawImage(x, y, w, h, image, ...)
    local x, y, w, h = aToR(x, y, w, h)
	if not imageFile[image] then
		imageFile[image] = dxCreateTexture(image)
	end
    return _dxDrawImage(x, y, w, h, imageFile[image], ...)
end

local function dxDrawImage2(x, y, w, h, ...)
    local x, y, w, h = aToR(x, y, w, h)
    return _dxDrawImage(x, y, w, h, ...)
end

local svgFile = {}
local function dxDrawRounded (x, y, w, h, radius, ...)
    if not svgFile[w..'.'..h..':'..radius] then
        local svg = string.format([[ <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'> <mask id='path_inside' fill='#FFFFFF' > <rect width='%s' height='%s' rx='%s' /> </mask> <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/> </svg> ]], w, h, w, h, radius, w, h, radius, tostring(''), tostring(''))
        svgFile[w..'.'..h..':'..radius] = svgCreate(w, h, svg)
    end
    dxDrawImage2(x, y, w, h, svgFile[w..'.'..h..':'..radius], 0, 0, 0, ...)
end

local cursor = {}
local function isMouseInPosition (x, y, width, height)
    if (not cursor.state) then
        return false
    end
    if not (cursor.x and cursor.y) then
        return false;
    end
    local x, y, width, height = aToR(x, y, width, height)
    return ((cursor.x >= x and cursor.x <= x + width) and (cursor.y >= y and cursor.y <= y + height));
end

local font = {}
local function getFont (name, size, ...)
    if not font[name] then
        font[name] = {}
    end
    if not font[name][size] then
        font[name][size] = dxCreateFont('assets/fonts/'..name..'.ttf', (size/1080)*screenH, ...)
    end
    return font[name][size]
end

local _svgCreate = svgCreate
local function svgCreate (w, h, ...)
    return _svgCreate(w*4, h*4, ...)
end

local color = tocolor
local function rgba(r,g,b,a)
    return color(r,g,b,a * 255)
end

local _svgCreate = svgCreate
local function svgCreate (w, h, ...)
    return _svgCreate(w*4, h*4, ...)
end

local color = tocolor
local function rgba(r,g,b,a)
    return color(r,g,b,a * 255)
end


------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------
------------------------------------

local svg = {
    ['iconDoor'] = svgCreate(96, 96,
        [[
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clip-path="url(#clip0_7374_2)">
                    <path fill-rule="evenodd" clip-rule="evenodd" d="M16 3.76998V20.23C15.9999 20.4478 15.9524 20.663 15.8607 20.8606C15.7691 21.0583 15.6355 21.2335 15.4692 21.3743C15.3029 21.515 15.108 21.6179 14.898 21.6757C14.688 21.7335 14.4679 21.7449 14.253 21.709L5.671 20.279C5.20401 20.2011 4.77979 19.9601 4.47381 19.5988C4.16784 19.2375 3.99994 18.7794 4 18.306V5.69398C3.99994 5.22055 4.16784 4.76244 4.47381 4.40116C4.77979 4.03988 5.20401 3.79886 5.671 3.72098L14.253 2.29098C14.4679 2.2551 14.6881 2.26648 14.8982 2.32434C15.1083 2.38219 15.3033 2.48514 15.4696 2.626C15.6359 2.76686 15.7695 2.94227 15.8611 3.14C15.9527 3.33774 16.0001 3.55206 16 3.76998ZM18 4.99998C18.5046 4.99982 18.9906 5.19039 19.3605 5.53348C19.7305 5.87657 19.9572 6.34683 19.995 6.84998L20 6.99998V17C20.0002 17.5046 19.8096 17.9906 19.4665 18.3605C19.1234 18.7305 18.6532 18.9571 18.15 18.995L18 19H17V4.99998H18ZM11.5 10.5C11.1022 10.5 10.7206 10.658 10.4393 10.9393C10.158 11.2206 10 11.6022 10 12C10 12.3978 10.158 12.7793 10.4393 13.0606C10.7206 13.3419 11.1022 13.5 11.5 13.5C11.8978 13.5 12.2794 13.3419 12.5607 13.0606C12.842 12.7793 13 12.3978 13 12C13 11.6022 12.842 11.2206 12.5607 10.9393C12.2794 10.658 11.8978 10.5 11.5 10.5Z" fill="white"/>
                </g>
                <defs>
                    <clipPath id="clip0_7374_2">
                        <rect width="24" height="24" fill="white"/>
                    </clipPath>
                </defs>
            </svg>        
        ]]
    ),
}


local components = {"bonnet_dummy", "boot_dummy", "door_lf_dummy", "door_rf_dummy", "door_lr_dummy", "door_rr_dummy"}
table_veh = {}
selectcar = 1
popup = false
popupInfos = {"dinheiro", 850, 590}

local _,_,tw, th = aToR(0,0,1800, 203)
local _,_,cw, ch = aToR(0,0,344, 190)
local renderTargetWidth, renderTargetHeight = 1800, 203
local renderTarget = dxCreateRenderTarget(renderTargetWidth, renderTargetHeight, true)
local scrollOffset = 0

local scrollSpeed = 344 + 20
local isScrollingLeft = false
local isScrollingRight = false
local canScroll = true

local function scrollLeft()
    if scrollOffset < 0 then
        scrollOffset = math.min(scrollOffset + scrollSpeed, 0)
    end
end

local function scrollRight()
    local maxOffset = -(#table_veh * (344 + 20 - (20 / #table_veh)) - tw)
    if scrollOffset > maxOffset then
        scrollOffset = math.max(scrollOffset - scrollSpeed, maxOffset)
    end
end

local function concePanel ()
    cursor.state = isCursorShowing ()
    if (cursor.state) then
        local cursorX, cursorY = getCursorPosition ()
        cursor.x, cursor.y = cursorX * screen[1], cursorY * screen[2]
    end

    dxDrawImage(0,0, 1920, 1080, "assets/images/concessionaria/bg.png")

    dxDrawText("Para sair pressione “ESC”", 1602, 74, 178, 19, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'right', 'center')
    dxDrawRounded(1792, 64, 68, 38, 8, rgba(61, 204, 109, 1))
    dxDrawText("ESC", 1792, 64, 68, 38, rgba(23, 23, 23, 1), 1, getFont('bold', 16), 'center', 'center')

    dxDrawText("Carteira", 1755, 157, 69, 24, rgba(255, 255, 255, 0.35), 1, getFont('medium', 18), 'right', 'center')
    dxDrawText("R$ "..formatNumber(getPlayerMoney()), 1755, 183+5, 69, 24, rgba(255, 255, 255, 1), 1, getFont('bold', 16), 'right', 'center')
    dxDrawImage(1836, 170, 24, 24, "assets/images/concessionaria/dolar.png")

    dxDrawText("Banco", 1755, 222, 69, 24, rgba(255, 255, 255, 0.35), 1, getFont('medium', 18), 'right', 'center')
    dxDrawText("R$ "..formatNumber((getElementData(localPlayer, "moneybank") or 0)), 1755, 248+5, 69, 24, rgba(255, 255, 255, 1), 1, getFont('bold', 16), 'right', 'center')
    dxDrawImage(1836, 234, 24, 24, "assets/images/concessionaria/porkin.png")

    dxDrawText("Moedas", 1755, 287, 69, 24, rgba(255, 255, 255, 0.35), 1, getFont('medium', 18), 'right', 'center')
    dxDrawText("G$ "..formatNumber((getElementData(localPlayer, "Cash") or 0)), 1755, 313+5, 69, 24, rgba(255, 255, 255, 1), 1, getFont('bold', 16), 'right', 'center')
    dxDrawImage(1836, 300, 24, 24, "assets/images/concessionaria/cash.png")

    if table_veh then
        if isScrollingLeft then
            scrollOffset = math.min(scrollOffset + scrollSpeed * getTickCount() / 1000, 0)
        elseif isScrollingRight then
            local maxOffset = -(#table_veh * (344 + 20) - 1800)
            scrollOffset = math.max(scrollOffset - scrollSpeed * getTickCount() / 1000, maxOffset)
        end

        if renderTarget then
            --dxSetRenderTarget(renderTarget, true)
                --dxSetBlendMode("modulate_add")
                    for i, veh in ipairs(table_veh) do
                        if vehicles[veh] then
                            local y = 1080 - 260
                            local x = (i - 1) * (344 + 20) + scrollOffset
                            if x + 344 > 0 and x < 1800 then
                                dxDrawRounded(x+60, y, 344, 190, 12, (isMouseInPosition(x+60, y, 344, 190) or selectcar == i) and rgba(255, 255, 255, 0.1) or rgba(255, 255, 255, 0.05))
                                dxDrawText(vehicles[veh].nome, x+86, y + 25, 150, 21, rgba(255, 255, 255, 0.9), 1, getFont('bold', 13), 'left', 'center')
                                dxDrawRounded(x+275+60, y + 20, 45, 45, 8, rgba(61, 204, 109, 1))
                                dxDrawImage(x+282.5+60, y + 27.5, 31, 30, "assets/images/concessionaria/marcas/"..vehicles[veh].marca..".png")
                                if vehicles[veh].notImage then
                                    dxDrawImage(x+110, y + 47, 230, 130, "assets/images/concessionaria/carros/veh.png")
                                else
                                    dxDrawImage(x+110, y + 47, 230, 130, "assets/images/concessionaria/carros/"..veh..".png")
                                end
                            end
                        end
                    end
            --     dxSetBlendMode("blend")
            -- dxSetRenderTarget()

            --dxDrawImage2(1860 - renderTargetWidth, 1080 - 260, renderTargetWidth, renderTargetHeight, renderTarget)
        end
    end

    if selectcar then
        local price = math.floor(tonumber((vehicles[table_veh[selectcar]].valor / 100) * taxPercentage) * 1)
        dxDrawRounded(544, 64, 45, 45, 12, rgba(61, 204, 109, 1))
        dxDrawImage(554.5, 75, 24, 24, "assets/images/concessionaria/weight.png", 0, 0, 0, rgba(0,0,0,1))
        dxDrawText("Porta-Malas", 601, 64, 62, 24, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')
        dxDrawText(kgVehicleMalas.." KG", 601, 86, 62, 24, rgba(255, 255, 255, 0.7), 1, getFont('bold', 15), 'left', 'center')

        dxDrawRounded(806, 64, 45, 45, 12, rgba(61, 204, 109, 1))
        dxDrawImage(816.5, 75, 24, 24, "assets/images/concessionaria/users.png", 0, 0, 0, rgba(0,0,0,1))
        dxDrawText("Capacidade", 863, 64, 62, 24, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')
        dxDrawText((maxPassagers+1).." Pessoas", 863, 86, 62, 24, rgba(255, 255, 255, 0.7), 1, getFont('bold', 15), 'left', 'center')

        dxDrawRounded(1027, 64, 45, 45, 12, rgba(61, 204, 109, 1))
        dxDrawImage(1037.5, 75, 24, 24, "assets/images/concessionaria/shield.png", 0, 0, 0, rgba(0,0,0,1))
        dxDrawText("IPVA", 1084, 64, 62, 24, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')
        dxDrawText("R$ "..formatNumber(price), 1084, 86, 62, 24, rgba(255, 255, 255, 0.7), 1, getFont('bold', 15), 'left', 'center')

        dxDrawRounded(1229, 64, 45, 45, 12, rgba(61, 204, 109, 1))
        dxDrawImage(1239.5, 74, 24, 24, "assets/images/concessionaria/dolar.png", 0, 0, 0, rgba(0,0,0,1))
        dxDrawText("Seguro", 1286, 64, 62, 24, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')
        dxDrawText("R$ 50.000", 1286, 86, 62, 24, rgba(255, 255, 255, 0.7), 1, getFont('bold', 15), 'left', 'center')

        dxDrawRounded(60, 64, 85, 85, 22, rgba(61, 204, 109, 1))
        dxDrawImage(74, 79, 56, 56, "assets/images/concessionaria/marcas/"..vehicles[table_veh[selectcar]].marca..".png")
        dxDrawText(string.upper(vehicles[table_veh[selectcar]].nome), 60, 193, 143, 38, rgba(255, 255, 255, 1), 1, getFont('bold', 20), 'left', 'center')
        dxDrawText(string.upper(vehicles[table_veh[selectcar]].marca), 61, 220, 143, 38, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')

        dxDrawText("Dinheiro", 61, 333, 143, 38, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')
        if discountPorcentage and discountPorcentage ~= 0 then
            dxDrawText("#3dcc6dR$ #CCCCCC"..formatNumber(vehicles[table_veh[selectcar]].valor).."   #FFFFFF"..formatNumber((vehicles[table_veh[selectcar]].valor - (vehicles[table_veh[selectcar]].valor / 100) * discountPorcentage)), 61, 362, 143, 38, rgba(255, 255, 255, 1), 1, getFont('bold', 22), 'left', 'center', false, false, false, true)
            dxDrawRounded(61, 380, dxGetTextSize(formatNumber(vehicles[table_veh[selectcar]].valor), #formatNumber(vehicles[table_veh[selectcar]].valor), 1, getFont('bold', 22)) + 45, 2, 1, rgba(255, 255, 255, 1))
        else
            dxDrawText("#3dcc6dR$ #FFFFFF"..formatNumber(vehicles[table_veh[selectcar]].valor).."   "..formatNumber(vehicles[table_veh[selectcar]].valor), 61, 362, 143, 38, rgba(255, 255, 255, 1), 1, getFont('bold', 22), 'left', 'center', false, false, false, true)
        end

        dxDrawText("Moedas", 61, 411, 143, 38, rgba(255, 255, 255, 0.5), 1, getFont('medium', 15), 'left', 'center')
        dxDrawText("#cacc3dG$ #FFFFFF"..formatNumber(vehicles[table_veh[selectcar]].cash), 61, 440, 143, 38, rgba(255, 255, 255, 1), 1, getFont('bold', 22), 'left', 'center', false, false, false, true)

        dxDrawRounded(1575, 675, 285, 56, 6, isMouseInPosition(1575, 675, 285, 56) and rgba(61, 204, 109, 1) or rgba(61, 204, 109, 0.8))
        dxDrawText("Comprar", 1575, 675, 285, 56, rgba(23, 23, 23, 1), 1, getFont('bold', 15), 'center', 'center')
        dxDrawImage(1593, 691, 24, 24, "assets/images/concessionaria/buy.png", 0, 0, 0, rgba(0,0,0,1))

        dxDrawRounded(1575, 739, 285, 56, 6, isMouseInPosition(1575, 739, 285, 56) and rgba(255, 255, 255, 0.4) or rgba(255, 255, 255, 0.2))
        dxDrawText("Test-Drive", 1575, 739, 285, 56, rgba(255, 255, 255, 1), 1, getFont('bold', 15), 'center', 'center')
    end

    dxDrawRounded(39, 897, 42, 45, 10, isMouseInPosition(39, 897, 42, 45) and rgba(61, 204, 109, 1) or rgba(255, 255, 255, 1))
    dxDrawImage(47, 907, 24, 24, "assets/images/concessionaria/arrow.png", 0, 0, 0, rgba(0,0,0,1))

    dxDrawRounded(1839, 897, 42, 45, 10, isMouseInPosition(1839, 897, 42, 45) and rgba(61, 204, 109, 1) or rgba(255, 255, 255, 1))
    dxDrawImage(1850, 907, 24, 24, "assets/images/concessionaria/arrow2.png", 0, 0, 0, rgba(0,0,0,1))

    if atualizarCamera then
        local tick = atualizarCamera[1]
        zoomCamera = interpolateBetween(atualizarCamera[2], 0, 0, atualizarCamera[3], 0, 0, ((getTickCount()-tick)/300), 'InOutQuad')
        local posCamera = {getCameraMatrix(localPlayer)}
        setCameraMatrix(posCamera[1], posCamera[2], posCamera[3], posCamera[4], posCamera[5], posCamera[6], 0, 70 / zoomCamera)
    end

    if isElement(vehicle) then
        local _, _, vehicleRotZ = getElementRotation(vehicle)
		local cameraX, cameraY, cameraZ = getCameraMatrix()
		for i = 1, #components do
			local componentX, componentY, componentZ = getVehicleComponentPosition(vehicle, components[i], "world")
			if componentX then
				if string.find(components[i], "door") then
					componentX, componentY = rotateAround(vehicleRotZ, 0, -1, componentX, componentY)
				end
				if getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, componentX, componentY, componentZ) <= 7 then
					local screenPosX, screenPosY = getScreenFromWorldPosition(componentX, componentY, componentZ)
					if screenPosX and screenPosY then
						local buttonSize = 25
						local doorRatio = getVehicleDoorOpenRatio(vehicle, i - 1)
						_dxDrawImage(screenPosX, screenPosY, buttonSize, buttonSize, svg['iconDoor'], 0, 0, 0, doorRatio == 1 and tocolor(200, 50, 50) or tocolor(222, 222, 222, 180))
					end
				end
			end
		end
    end

    if popup then
        dxDrawImage(0,0, 1920, 1080, "assets/images/concessionaria/bgoun.png")
        dxDrawImage(931, 192, 58, 58, "assets/images/concessionaria/buyg.png", 0, 0, 0, rgba(255,255,255,1))
        dxDrawText("Confirmação de Compra", 805, 282, 311, 33, rgba(255, 255, 255, 1), 1, getFont('bold', 18), 'center', 'center')
        dxDrawText("Confira as informações abaixo antes de finalizar a\ncompra do veículo.", 701, 331, 519, 58, rgba(255, 255, 255, 0.3), 1, getFont('bold', 17), 'center', 'center')

        dxDrawText("Veículo", 773, 435, 519, 58, rgba(255, 255, 255, 0.3), 1, getFont('medium', 14), 'left', 'center')
        dxDrawText(string.upper(vehicles[table_veh[selectcar]].nome), 773, 462, 519, 58, rgba(255, 255, 255, 1), 1, getFont('medium', 14), 'left', 'center')

        dxDrawText("Valor", 940, 435, 519, 58, rgba(255, 255, 255, 0.3), 1, getFont('medium', 14), 'left', 'center')
        dxDrawText("R$"..formatNumber(vehicles[table_veh[selectcar]].valor), 940, 462, 519, 58, rgba(255, 255, 255, 1), 1, getFont('medium', 14), 'left', 'center')

        dxDrawText("Moedas", 1075, 435, 519, 58, rgba(255, 255, 255, 0.3), 1, getFont('medium', 14), 'left', 'center')
        dxDrawText("R$"..formatNumber(vehicles[table_veh[selectcar]].cash), 1075, 462, 519, 58, rgba(255, 255, 255, 1), 1, getFont('medium', 14), 'left', 'center')

        dxDrawText("Selecione uma forma de pagamento", 782, 538, 359, 26, rgba(255, 255, 255, 1), 1, getFont('bold', 16), 'center', 'center')

        dxDrawRounded(844, 584, 32, 32, 10, isMouseInPosition(39, 897, 42, 45) and rgba(255, 255, 255, 0.06) or rgba(255, 255, 255, 0.04))
        dxDrawText("Dinheiro", 888, 587, 359, 26, rgba(255, 255, 255, 1), 1, getFont('medium', 14), 'left', 'center')

        dxDrawRounded(995, 584, 32, 32, 10, isMouseInPosition(39, 897, 42, 45) and rgba(255, 255, 255, 0.06) or rgba(255, 255, 255, 0.04))
        dxDrawText("Moeda Virtual", 1039, 587, 359, 26, rgba(255, 255, 255, 1), 1, getFont('medium', 14), 'left', 'center')

        dxDrawImage(popupInfos[2], popupInfos[3], 20, 20, "assets/images/concessionaria/check.png")

        dxDrawRounded(730, 660, 300, 64, 6, isMouseInPosition(730, 660, 300, 64) and rgba(61, 204, 109, 1) or rgba(61, 204, 109, 0.8))
        dxDrawText("Finalizar Compra", 730, 660, 300, 64, rgba(24, 24, 24, 1), 1, getFont('bold', 16), 'center', 'center')

        dxDrawRounded(1050, 660, 175, 64, 6, isMouseInPosition(1050, 660, 175, 64) and rgba(255, 255, 255, 0.4) or rgba(255, 255, 255, 0.2))
        dxDrawText("Cancelar", 1050, 660, 175, 64, rgba(255, 255, 255, 1), 1, getFont('bold', 16), 'center', 'center')
    end
end


local function renderCamera ()
    if (moving and isCursorShowing()) then
        local mx, my = getCursorPosition()
        local cx, cy = mx * screen[1], my * screen[2]
        if (not lastCursorPos) then
            lastCursorPos = { onMoveStartX = cx, onMoveStartY = cy, yawStart = camera.rotation, pitchStart = camera.height }
        end
        camera.rotation = lastCursorPos.yawStart - (cx - lastCursorPos.onMoveStartX) / screen[1] * 270
        camera.height = lastCursorPos.pitchStart + (cy - lastCursorPos.onMoveStartY) / screen[2] * 20
        camera.rotation = camera.rotation
        local maxZ = math.abs(getElementDistanceFromCentreOfMassToBaseOfModel(vehicle) - 1)
        camera.height = math.min(maxZ, math.max(-2, camera.height))
        local deltaX = camera.position[1] - camera.position[4]
        local deltaY = camera.position[2] - camera.position[5]
        local theta = math.rad(camera.rotation)
        setCameraMatrix(camera.position[4] + deltaX * math.cos(theta) - deltaY * math.sin(theta),camera.position[5] + deltaX * math.sin(theta) + deltaY * math.cos(theta),camera.position[3] + camera.height,camera.position[4],camera.position[5],camera.position[6],0, 70 / (zoomCamera or camera.zoomLevel))
    elseif (lastCursorPos) then
        lastCursorPos = false
    end
end

function rotateAround(angle, x, y, x2, y2)
	local radiant = math.rad(angle)
	local rotatedX = (x2 or 0) + x * math.cos(radiant) - y * math.sin(radiant)
	local rotatedY = (y2 or 0) + x * math.sin(radiant) + y * math.cos(radiant)
	return rotatedX, rotatedY
end


addEvent('refreshGaragemVehicles', true)
addEventHandler('refreshGaragemVehicles', root, function (tableVehicles)
    vehiclesGaragem = tableVehicles
    poupTaxa = false
end)

function removePanel ()
    visibleConcessionaria = false
    setElementDimension(localPlayer, 0)
    removeEventHandler('onClientRender', root, concePanel)

    removeEventHandler('onClientClick', root, onClientClick)

    removeEventHandler('onClientKey', root, onClientKey)
    removeEventHandler('onClientPreRender', root, renderCamera)
    showCursor(false)
    others['hudState'](true)
    setElementFrozen(localPlayer, false)
    setCameraTarget(localPlayer)
    if isElement(vehicle) then
        destroyElement(vehicle)
    end
    select_payment = false
    selectcar = 1
end

function onClientClick(button, state, x, y)
    if state == "down" then

        if popup then
            if isMouseInPosition(730, 660, 300, 64) then
                triggerServerEvent('onBuyVehicle', localPlayer, table_veh[selectcar], popupInfos[1], table_position_spawn, selectedColor)
                popup = false
            elseif isMouseInPosition(1050, 660, 175, 64)then
                popup = false
            elseif isMouseInPosition(844, 584, 32, 32)then
                popupInfos = {"dinheiro", 850, 590}
            elseif isMouseInPosition(995, 584, 32, 32)then
                popupInfos = {"cash", 1001, 590}
            end
        end

        if isMouseInPosition(39, 897, 42, 45) then
            if canScroll then
                canScroll = false
                scrollLeft()
            end
        elseif isMouseInPosition(1839, 897, 42, 45) then
            if canScroll then
                canScroll = false
                scrollRight()
            end
        elseif isMouseInPosition(1575, 675, 285, 56)then
            if selectcar then
                popup = true
            end
        elseif isMouseInPosition(1575, 739, 285, 56)then
            if table_veh[selectcar] then
                triggerServerEvent('startTesteDrive.dealership', resourceRoot, localPlayer, table_veh[selectcar])
                removePanel()
            end
        else
            for i, veh in ipairs(table_veh) do
                if vehicles[veh] then
                    local y = 1080 - 260
                    local x = (i - 1) * (344 + 20) + scrollOffset
                    if x + 344 > 0 and x < 1800 then
                        if isMouseInPosition(x+60, y, 344, 190) then
                            selectcar = i

                            if isElement(vehicle) then
                                destroyElement(vehicle)
                            end

                            if conceBarco then
                                vehicle = createVehicle(table_veh[selectcar], 786.27, -1921.24, 1.85 - 2, 0, 0, 171.28)
                            else
                                vehicle = createVehicle(table_veh[selectcar], 1314.82, -1425.81, 13.98, 0, 0, 124.5)
                            end
                            maxPassagers = getVehicleMaxPassengers(vehicle)
                            kgVehicleMalas = exports['goiaba_inventario']:getVehicleKG(table_veh[selectcar])

                            setElementDimension(vehicle, 1)

                            setVehicleColor(vehicle, 61, 204, 109)
                        end
                    end
                end
            end

            if isElement(vehicle) then
                local _, _, vehicleRotZ = getElementRotation(vehicle)
                local cameraX, cameraY, cameraZ = getCameraMatrix()
                for i = 1, #components do
                    local componentX, componentY, componentZ = getVehicleComponentPosition(vehicle, components[i], "world")
                    if componentX then
                        if string.find(components[i], "door") then
                            componentX, componentY = rotateAround(vehicleRotZ, 0, -1, componentX, componentY)
                        end
                        if getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, componentX, componentY, componentZ) <= 7 then
                            local screenPosX, screenPosY = getScreenFromWorldPosition(componentX, componentY, componentZ)
                            if screenPosX and screenPosY then
                                local buttonSize = 25
                                if isMouseInPosition(screenPosX, screenPosY, buttonSize, buttonSize) then
                                    local doorRatio = getVehicleDoorOpenRatio(vehicle, i - 1)
                                    if doorRatio == 0 then
                                        setVehicleDoorOpenRatio(vehicle, i - 1, 1, 1000)
                                    else
                                        setVehicleDoorOpenRatio(vehicle, i - 1, 0, 1000)
                                    end
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
        moving = true
    elseif state == "up" then
        canScroll = true
        moving = false
    end
end

function onClientKey (button, press)
    if visibleConcessionaria then
        if button == 'escape' and press or button == 'backspace' and press then
            if not select_payment then
                removePanel()
                cancelEvent()
            end
        end
        if select_payment then
            return
        end
        if (button == 'mouse_wheel_down' and press) then
            if not atualizarCamera or atualizarCamera == nil then
                if (camera.zoomLevel-0.3) > 0.9 then
                    atualizarCamera = {getTickCount(), camera.zoomLevel, camera.zoomLevel - 0.3}
                    camera.zoomLevel = camera.zoomLevel - 0.3
                    setTimer(function ()
                        atualizarCamera = nil
                    end, 320, 1)
                end
            end
        elseif (button == 'mouse_wheel_up' and press) then
            if not atualizarCamera or atualizarCamera == nil then
                if camera.zoomLevel < 1.9 then
                    atualizarCamera = {getTickCount(), camera.zoomLevel, camera.zoomLevel + 0.3}
                    camera.zoomLevel = camera.zoomLevel + 0.3
                    setTimer(function ()
                        atualizarCamera = nil
                    end, 320, 1)
                end
            end
        end
    end
end

function onPreEvent( sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ... )
    local args = {...}
    if visibleConcessionaria and args[1] == "escape" then
        removePanel()
        return "skip"
    end
end
addDebugHook( "preEvent", onPreEvent, {"onClientKey"})

addEvent('onClientConcessionaria', true)
addEventHandler('onClientConcessionaria', root, function (vehicles, position, barco, discountPorcentage_)
    if not visibleConcessionaria and position then
        visibleConcessionaria = true
        colorPickerX = screen[1]-(150+15)
        colorPickerY = screen[2]-(150+115)
        selectedColor = {255, 255, 255}
        cursorLastPositionX, cursorLastPositionY = 150/2, 0

        table_veh = vehicles
        table_position_spawn = position
        discountPorcentage = discountPorcentage_
        conceBarco = false
        if barco then
            conceBarco = true
            vehicle = createVehicle(table_veh[selectcar], 786.27, -1921.24, 1.85 - 2, 0, 0, 171.28)
        else
            vehicle = createVehicle(table_veh[selectcar], 1314.82, -1425.81, 13.98, 0, 0, 124.5)
        end
        maxPassagers = getVehicleMaxPassengers(vehicle)
        kgVehicleMalas = exports['goiaba_inventario']:getVehicleKG(table_veh[selectcar])

        setElementDimension(vehicle, 1)
        setVehicleColor(vehicle, 61, 204, 109)
        setElementDimension(localPlayer, 1)
        addEventHandler('onClientRender', root, concePanel)
        addEventHandler('onClientClick', root, onClientClick)
        addEventHandler('onClientKey', root, onClientKey)

        addEventHandler('onClientPreRender', root, renderCamera)
        showCursor(true)
        others['hudState'](false)
        setElementFrozen(localPlayer, true)

        if conceBarco then
            x, y, z = 786.27, -1921.24, 1.85 - 2
        else
            x, y, z = 1314.82, -1425.81, 13.98
        end
        rz = 1
        camera = {
            rotation = 45,
            height = -1.5,
            zoomLevel = 1.3,
            position = { x - 7.5 * math.sin(rz), y + 7.5 * math.cos(rz), z + 2.5, x, y, z }
        }
        if conceBarco then
            camera.zoomLevel = 0
        end
        moving = true
        setTimer(function()
            moving = false
        end, 100, 1)
    else
        removePanel()
    end
end)