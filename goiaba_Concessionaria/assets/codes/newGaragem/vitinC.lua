--[[local vehiclesCache = {}
local pedCache = {}
local musicCache = {}
local garageInfos = {}

local screenW, screenH = guiGetScreenSize();
local screenScale = (screenH / 768); -- Caso o painel seja muito grande, retirar o limite e deixar apenas o (screenH / 768).

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

function renderGarageInfos()
    if getElementData(localPlayer, 'bloqInterface') then return end
    local px, py, pz = getElementPosition(localPlayer)
    local dist = getDistanceBetweenPoints3D(px, py, pz, config.ped[2], config.ped[3], config.ped[4])

    if(dist > 5) then return end
    aX, aY = getScreenFromWorldPosition(config.ped[2], config.ped[3], config.ped[4], 1, true)
    if not aX or not aY then return end
    dxDrawText('Bem-vindo de volta, chefe!', aX-90, aY-20, 28, 28, tocolor(255, 255, 255, 255), 1, getFont('bold', 10), 'left', 'center', false, false, false, true)
    dxDrawText('Vagas na Garagem:              '..(#vehiclesCache - qntVehiclesVIP).."/"..garageInfos['slots'], aX-90, aY + 20, 28, 28, tocolor(255, 255, 255, 255 * 0.7), 1, getFont('bold', 9), 'left', 'center', false, false, false, true)
    dxDrawText('Veículos Detidos:                     '..garageInfos['detidos'], aX-90, aY + 55, 28, 28, tocolor(255, 255, 255, 255 * 0.7), 1, getFont('bold', 9), 'left', 'center', false, false, false, true)
    dxDrawText('Veículos Com Impostos:     '..garageInfos['impostos'], aX-90, aY + 90, 28, 28, tocolor(255, 255, 255, 255 * 0.7), 1, getFont('bold', 9), 'left', 'center', false, false, false, true)
end


addEvent("gba:createGarageVehicles", true)
addEventHandler("gba:createGarageVehicles", root, function(dim, vehicles, slots, vipsNaoAutorizados, slotsVips)
    garageInfos['slots'] = slots
    garageInfos['detidos'] = 0
    garageInfos['impostos'] = 0
    local iX = 0
    local iY = 0
    local iZ = 1
    local vehs = 0
    local timestamp = getRealTime().timestamp
    qntVehiclesVIP = slotsVips
    slots = slots + slotsVips
    for i = 1, slots do
        if(vehicles[i])then
            if(not config.barcosID[vehicles[i][1])then
                if(iY == config.max)then
                    iX = iX + 1;
                    iY = 0
                end

                if (vehs == config.up) then
                    iZ = iZ + 1
                    iX = 0
                    iY = 0
                end
    
                local state = vehicles[i][6].state == 1 and 'guardar' or (vehicles[i][6].state == 0 and 'spawn' or 'detido')
    
                x = config.defaultPos[iZ][1] - (iX * config.spaces[1])
                y = config.defaultPos[iZ][2] - (iY * config.spaces[2])
                z = config.defaultPos[iZ][3]
    
                if(vehicles[i][1] == 514 or vehicles[i][1] == 515) then
                    z = z + 1
                end
    
    
                vehiclesCache[i] = createVehicle(vehicles[i][1], 0,0,-300, config.defaultPos[iZ][4], config.defaultPos[iZ][5], config.defaultPos[iZ][6], vehicles[i][3])
                setVehicleColor(vehiclesCache[i], unpack(vehicles[i][6].color))
                setElementDimension(vehiclesCache[i], dim)
                setElementInterior(vehiclesCache[i], 1, x, y, z)
                setElementRotation(vehiclesCache[i], config.defaultPos[iZ][4], config.defaultPos[iZ][5], config.defaultPos[iZ][6])
                setElementHealth(vehiclesCache[i], vehicles[i][6].vida)
    
                others['setVehicleInfos'](vehiclesCache[i], vehicles[i][6])
    
                if state == 'detido'then
                    garageInfos['detidos'] = garageInfos['detidos'] + 1
                end
    
                if vehicles[i][7] >= 2 then
                    garageInfos['impostos'] = garageInfos['impostos'] + 1
                end
    
                setTimer(function()
                    if (vehicles[i][7] >= 2 or state == 'detido' or state == 'guardar' or vipsNaoAutorizados[vehicles[i][1] or ((vehicles[i][8] and tonumber(vehicles[i][8])) and tonumber(vehicles[i][8]) <= timestamp)) then
                        setElementAlpha(vehiclesCache[i], 30)
                        setElementCollisionsEnabled(vehiclesCache[i], false)
                    end
                    setElementFrozen(vehiclesCache[i], true)
                end, 2000, 1)
    
                iY = iY + 1;
                vehs = vehs + 1
            end
        end
    end

    pedCache = createPed(config.ped[1], config.ped[2], config.ped[3], config.ped[4])
    setElementInterior(pedCache, 1, config.ped[2], config.ped[3], config.ped[4])
    setElementRotation(pedCache, config.ped[5], config.ped[6], config.ped[7])
    setElementDimension(pedCache, dim)
    setPedAnimation(pedCache, "COP_AMBIENT", "Coplook_shake", -1, true, false, false)

    musicCache = playSound3D("assets/music.mp3", 1386.45, -16.25, 1012.26)
    setElementDimension(musicCache, dim)
    setElementInterior(musicCache, 1, 1386.45, -16.25, 1012.26)
    setSoundVolume(musicCache, 0.3)
    setSoundMaxDistance(musicCache, 50)
    setSoundEffectEnabled(musicCache, "compressor", true)

    addEventHandler("onClientRender", root, renderGarageInfos)
end)

addEvent("gba:applyCollision", true)
addEventHandler("gba:applyCollision", root, function(player, veh)
    if not player then return end
    if not veh then return end

    for i,v in pairs(getElementsByType("vehicle")) do
        setElementCollidableWith(v, veh, not isElementCollidableWith(v, veh))
    end

end)

addEvent("gba:destroyCacheVehicles", true)
addEventHandler("gba:destroyCacheVehicles", root, function(player)
    if not player then return end

    for i,v in pairs(vehiclesCache) do
        destroyElement(v)
    end
    vehiclesCache = {}

    destroyElement(pedCache)
    pedCache = {}

    if musicCache then
        destroyElement(musicCache)
        musicCache = {}
    end

    removeEventHandler("onClientRender", root, renderGarageInfos)
end)]]