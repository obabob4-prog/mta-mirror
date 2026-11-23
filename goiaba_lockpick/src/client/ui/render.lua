local screenWidth, screenHeight = getResponsiveValues()
local settings = getSettings()
local rendering = false
local toggleRender
local tickStart
local pinHit = 0
local pinValues = {}
local rot = 0
local nearestVehicle
local unlocked = {}
local parentW, parentH = respc(375), respc(288)
local parentX, parentY = (screenWidth - parentW) / 2, screenHeight - parentH - respc(219)
local barPositionX = new 'Animation'()
local barRotation = new 'Animation'()
local pinColor = settings.colors.pin
local barColor = settings.colors.bar
local bgColor = settings.colors.background
local timeDuration = settings.time * 1000
local getAnimatedValue = createPulseAnimation(350, 2)

local function generateRandomPinValues()
    local randomGap = math.random(10, 62)
    return {
        gap = randomGap,
        attempts = 4,
        c = 0,
        i = parentY + respc(104),
        f = parentY + respc(104)
    }
end

local function renderHandler()
    local timeElapsed = getTickCount() - tickStart
    local duration = timeElapsed / timeDuration
    dxDrawImage(parentX, parentY, parentW, parentH,'public/images/bg_lockpick.png')
    dxDrawImage(parentX, parentY + parentH + respc(6), parentW, respc(38), 'public/images/bg_bar.png')
    dxDrawImage(parentX, parentY + parentH + respc(56), parentW, respc(10), 'public/images/bg_bar_attempts.png', 0, 0, 0, rgba(unpack(bgColor)))
    dxDrawText(textoPainel,parentX, parentY,parentW, respc(43),rgba(255, 255, 255),1, means.fonts['montserrat13'], 'center', 'center')
    local pulse = getAnimatedValue()
    dxDrawImage(parentX + (parentW - respc(12)) / 2 - pulse, parentY + respc(57) - pulse,respc(12 + (pulse * 2)), respc(14 + (pulse * 2)),'public/images/clock.png')
    dxDrawImage( parentX + respc(28), parentY + respc(83), respc(319), respc(6), 'public/images/bar_time.png', 0, 0, 0, rgba(37, 37, 37, 1) )
    local barTimeW = respc(319) / 100 * (100 - (duration * 100))
    dxDrawImageSection( parentX + respc(28), parentY + respc(83), math.max(barTimeW, 0), respc(6), 0, 0, math.max(barTimeW, 0), respc(6), 'public/images/bar_time.png', 0, 0, 0, rgba(barColor[1], barColor[2], barColor[3], 1))
    local gapX = 0
    for i = 1, 5 do
        local gapY = pinValues[i].gap
        local pinX = parentX + respc(18) + gapX
        local pinY = parentY + respc(104) + respc(gapY)
        pinValues[i].c = lerp(pinValues[i].i, pinValues[i].f, 0.1)
        pinValues[i].i = pinValues[i].c
        pinValues[i].f = pinY
        dxDrawImage( pinX + (respc(40) - respc(4)) / 2, parentY + respc(104), respc(4), respc(62), 'public/images/line.png', 0, 0, 0, rgba(37, 37, 37, 1))
        dxDrawImage( pinX, pinValues[i].c, respc(40), respc(105), means.textures.pin, 0, 0, 0, rgba(pinColor[1], pinColor[2], pinColor[3]) )
        local a = (pinValues[i].attempts * .25)
        dxDrawRectangle( parentX + respc(18) + gapX, parentY + parentH + respc(56), respc(40), respc(10), rgba(barColor[1], barColor[2], barColor[3], a))
        gapX = gapX + respc(40 + 32)
    end
    dxDrawImage( barPositionX:get(), parentY + parentH + respc(14), respc(382), respc(17), means.textures.bar, barRotation:get(), 0, 0, rgba(134, 134, 134) )
    if (barPositionX:isFinish()) then
        local current = barPositionX:get()
        if (current >= parentX + parentW - respc(382 + 20)) then
            barPositionX:exec(current, parentX + parentW - respc(382 + 354), 1000, 'Linear')
        else
            barPositionX:exec(current, parentX + parentW - respc(382 + 20), 1000, 'Linear')
        end
    end
    if (barRotation:isFinish()) then
        local current = barRotation:get() or 0
        if (current >= 0) then
            barRotation:exec(current, 0, 100, 'Linear')
        else
            barRotation:exec(current, 0, 100, 'Linear')
        end
    end
    local text = settings.text
    dxDrawText( text:gsub('${cor}', string.format('%s', settings.colorTheme)), parentX, parentY + parentH + respc(82), parentW, respc(16), rgba(255, 255, 255), 1, means.fonts['epilogue_semiBold14'], 'center', 'center', false, false, false, true )
    for i = 1, 5 do
        local pin = pinValues[i]
        if (pin) then
            if (not (pin.gap > 0) and not unlocked[i] and pin.attempts <= 0) then
                unlocked[i] = true
            end
        end
    end
    if (#unlocked >= 5) then
        return toggleRender.hide()
    end
    if (duration >= 1) then
        return toggleRender.hide()
    end
end

local function keyHandler(k, p)
    if (not p) then return end
    if (k == settings.key) then
        if cooldownClick then
            local tick = getTickCount()
            if tick < (cooldownClick + 200) then
                cancelEvent()
                return
            end
        end
        cooldownClick = getTickCount()
        local gapX = 0
        for i = 1, 5 do
            local pin = pinValues[i]
            local pinX = parentX + respc(18) + gapX
            local pinW = respc(40)
            local barX = (barPositionX:get() + respc(382 - 7))
            if (barX >= pinX and barX <= (pinX + pinW)) then
                if (pin.attempts > 0) then
                    pinHit = i
                    pin.attempts = pin.attempts - 1
                    local diff = pin.gap - 0
                    local reduce = diff ~= 0 and math.floor(diff / pin.attempts) or 0
                    pin.gap = math.max(pin.gap - reduce, 0)
                    break
                end
            end
            gapX = gapX + respc(40 + 32)
        end
        if (pinValues[pinHit]) then 
            local pinY = parentY + respc(104) + respc(pinValues[pinHit].gap)
            local barDiff = (pinY) - (parentY + parentH + respc(14))
            local rotation = math.deg(math.atan2(barDiff, respc(382)))
            barRotation:exec(rot, rotation, 100, 'Linear')
        end
        cancelEvent()
    else
        cancelEvent()
    end
end

useCount = 0
toggleRender = {
    show = function()
        local vehicle = getNearestVehicle(localPlayer, 4)
        if (not vehicle) then
            triggerServerEvent('onStopPlayerAnimation', resourceRoot, localPlayer)
            return settings.sendNotification('client','Você precisa estar próximo de um veículo para usar a LockPick','error')
        end
        if vehicle and getElementType(vehicle) == 'vehicle' then
            if (not isVehicleLocked(vehicle) or (getElementData(vehicle, 'veh:lock') or false) == false) then
                triggerServerEvent('onStopPlayerAnimation', resourceRoot, localPlayer)
                return settings.sendNotification( 'client', 'Este veículo já está destravado', 'error')
            end
            textoPainel = 'Destrave o carro'
            textoNaoConseguiu = 'Você não conseguiu destravar o carro.'
        else
            if vehicle then
                local stateAlgema = getElementData(vehicle, 'FS:actionState > cuff')
                if not stateAlgema then
                    return settings.sendNotification('client', 'O jogador precisa estar algemado.', 'error')
                end
            end
            textoPainel = 'Destrave a algema'
            textoNaoConseguiu = 'Você não conseguiu destravar a algema.'
        end
        if (rendering) then return end
        nearestVehicle = vehicle
        useCount = useCount + 1
        if useCount >= 3 then
            useCount = 0
            triggerServerEvent('removeLockPick', resourceRoot, 'remove', localPlayer)
        end
        triggerServerEvent('removeLockPick', resourceRoot, 'animation', localPlayer)
        for i = 1, 5 do
            pinValues[i] = generateRandomPinValues()
        end
        tickStart = getTickCount()
        barPositionX:exec((parentX + parentW) - respc(382 + 354), parentX + parentW - respc(382 + 20), 1000, 'Linear')
        toggleControl('jump', false)
        addEventHandler('onClientRender', root, renderHandler)
        addEventHandler('onClientKey', root, keyHandler)
        rendering = true
        unlocked = {}
    end,

    hide = function()
        if (not rendering) then return end
        tickStart = nil
        toggleControl('jump', true)
        removeEventHandler('onClientRender', root, renderHandler)
        removeEventHandler('onClientKey', root, keyHandler)
        rendering = false
        for i = 1, 5 do
            local pin = pinValues[i]
            if (pin) then
                if (pin.gap > 0) then
                    triggerServerEvent('onStopPlayerAnimation', resourceRoot, localPlayer)
                    return settings.sendNotification( 'client', textoNaoConseguiu, 'error')
                end
            end
        end
        triggerServerEvent('onServerLockpick', resourceRoot, localPlayer, nearestVehicle)
        nearestVehicle = nil
    end
}

addEvent('onClientShowLockpick', true)
addEventHandler('onClientShowLockpick', resourceRoot, function()
    toggleRender.show()
end)

function useLockPick()
    if (rendering) then return end
    toggleRender.show()
end