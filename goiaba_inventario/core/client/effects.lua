screenW, screenH = guiGetScreenSize()

local controlTable = {
  "fire", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right",
  "jump", "sprint", "crouch", "action", "walk", "aim_weapon",
  "group_control_forwards", "group_control_back", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
  "steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn", "sub_mission",
  "handbrake", "special_control_left", "special_control_right",
  "special_control_down", "special_control_up",
}

local trip_objects = {
  1609, 1608, 1607, 1606, 1605, 1604, 1603, 1602, 1601, 1600, 1599, 1598,
}

local trip_sfxes = {
  [1] = {"Beats", 9},
  [2] = {"Beats", 2},
  [3] = {"Beats", 3},
  [4] = {"Ambience", 1},
}


function dxMaconha()
  dxDrawImage(0, 0, screenW, screenH, "core/assets/images/efeito.png", 0, 0, 0, tocolor(0, 254, 6, 255), false)
end
  
addEvent('usarMaconha', true)
addEventHandler('usarMaconha', root, function ()
    addEventHandler("onClientRender", root, dxMaconha)
    setCameraShakeLevel(90)
    setWaterColor(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    setPedWalkingStyle(getLocalPlayer(), 126) 
    setGameSpeed(0.6)
    setWaterColor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
    setSkyGradient(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
    setMoonSize(15)
    setSunSize(15)
    sound = playSound("core/assets/images/smoke.mp3")
    setTimer(function()
        stopSound(sound)
        resetWindVelocity()
        setPedWalkingStyle(getLocalPlayer(), 0) 
        setCameraShakeLevel(1)
        setGameSpeed(1)
        resetSunSize()
        resetMoonSize()
        resetSkyGradient()
        resetWaterColor()
        removeEventHandler ( "onClientRender", root, dxMaconha)
    end, 30000,1)
end)

addEvent('usarCocaina', true)
addEventHandler('usarCocaina', root, function ()
  --setPedWalkingStyle(localPlayer,126) 
  --setGameSpeed(2)
  if not (isTimer(trip_expire_timer)) and not (isTimer(trip_timer)) then
    setWindVelocity(100, 100, 0)
    trip_timer = setTimer(function()
        setSkyGradient(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
        setWaterColor(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
        setFogDistance(math.random(0, 500))
        setHeatHaze(math.random(100, 255))
        local x, y, z = getElementPosition(localPlayer)
        local m = math.random(400, 500)
        -- local random_control = controlTable[math.random(#controlTable)]
        -- setPedControlState(localPlayer, random_control, true)
        -- setTimer(setPedControlState, 100, 1, localPlayer, random_control, false)
        if (getPedOccupiedVehicle(localPlayer)) then
            m = getElementModel(getPedOccupiedVehicle(localPlayer))
        end
        if not (isElement(trip_sfx)) then
            local rsfx = trip_sfxes[math.random(#trip_sfxes)]
            trip_sfx = playSFX("radio", rsfx[1], rsfx[2])
            setSoundEffectEnabled(trip_sfx, "chorus", true)
            setSoundSpeed(trip_sfx, 0.8)
            setSoundVolume(trip_sfx, 1.5)
        end
        if not (isTimer(trip_sfx_timer)) then
            trip_sfx_timer = setTimer(function()
                if (isElement(trip_sfx)) then
                    stopSound(trip_sfx)
                end
            end, math.random(1000, 30000), 1)
        end
        local trip_ped = createPed(getElementModel(localPlayer), math.random(x - 50, x + 50), math.random(y - 50, y + 50), math.random(z - 50, z + 50), math.random(-180, 180))
        setElementCollisionsEnabled(trip_ped, false)
        setTimer(function()
            if (isElement(trip_ped)) then
                destroyElement(trip_ped)
            end
        end, 500, 1)
        local trip_object = createObject(trip_objects[math.random(#trip_objects)], math.random(x - 50, x + 50), math.random(y - 50, y + 50), math.random(z - 50, z + 50), math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
        setElementCollisionsEnabled(trip_object, false)
        setObjectScale(trip_object, math.random(10, 1000) / 1000, math.random(0.1, 5), math.random(0.1, 5))
        moveObject(trip_object, 2000, math.random(x - 50, x + 50), math.random(y - 50, y + 50), math.random(z - 50, z + 50))
        setTimer(function()
            if (isElement(trip_object)) then
                destroyElement(trip_object)
            end
        end, 2000, 1)
        setSunColor(math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
    end, 100, 0)
    trip_expire_timer = setTimer(function()
        killTimer(trip_timer)
        resetSkyGradient()
        resetWaterColor()
        resetFogDistance()
        resetWindVelocity()
        resetSunColor()
        resetHeatHaze()
        --setPedWalkingStyle(getLocalPlayer(), 0) 
        if (isElement(trip_sfx)) then
            destroyElement(trip_sfx)
        end
      --setGameSpeed(1)
    end, math.random(10000, 30000), 1)	
  end
end)
