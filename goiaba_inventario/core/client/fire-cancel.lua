addEventHandler ("onClientPlayerWeaponFire", localPlayer, function (weapon)

    if (config["weapons"][weapon]) then

        if getPedTotalAmmo(localPlayer, currentWeaponSlot) < 2 and getPedWeaponSlot (localPlayer) ~= 0  then

            toggleControl("action", false)

            toggleControl("fire", false)

            toggleControl("vehicle_fire", false)

        else

            toggleControl("action", true)

            toggleControl("fire", true)

            toggleControl("vehicle_fire", true)

        end

    else

        toggleControl("action", true)

        toggleControl("fire", true)

        toggleControl("vehicle_fire", true)

    end

end)



function onScriptCancelWeaponFire ()

   local weapon = getPedWeapon(localPlayer, current)

    if (config["weapons"][weapon]) then

        if getPedTotalAmmo(localPlayer, currentWeaponSlot) < 2 and getPedWeaponSlot (localPlayer) ~= 0 then

            playSoundFrontEnd (42)

            toggleControl("action", false)

            toggleControl("fire", false)

            toggleControl("vehicle_fire", false)

        else

            toggleControl("action", true)

            toggleControl("fire", true)

            toggleControl("vehicle_fire", true)

        end

    end

end

bindKey("fire", "down", onScriptCancelWeaponFire)

bindKey("action", "down", onScriptCancelWeaponFire)



addEventHandler ("onClientPlayerWeaponSwitch", localPlayer, function (_, currentWeaponSlot)

    local weapon = getPedWeapon(localPlayer, currentWeaponSlot)

    if not (config["weapons"][weapon]) then

        toggleControl("action", true)

        toggleControl("fire", true)

        toggleControl("vehicle_fire", true)

    else

        if getPedTotalAmmo(localPlayer, currentWeaponSlot) > 1 then

            toggleControl("action", true)

            toggleControl("fire", true)

            toggleControl("vehicle_fire", true)

        else

            toggleControl("action", false)

            toggleControl("fire", false)

            toggleControl("vehicle_fire", false)

        end

    end

end)

addEventHandler('onClientRender', root, function()
    if getElementData(localPlayer,  'emEvento') then
        toggleControl("previous_weapon", true)
        toggleControl("next_weapon", true)
    else
        toggleControl("previous_weapon", true)
        toggleControl("next_weapon", true)
    end
end)