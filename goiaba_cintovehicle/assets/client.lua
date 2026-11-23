addEventHandler( "onClientVehicleDamage", root, function( attacker, _, power )
    if not attacker and getPedOccupiedVehicle( localPlayer ) and not settings[ "Vehicles Blocked" ][ getVehicleID( getPedOccupiedVehicle( localPlayer ) ) ] then
        local power = math.floor( power / settings[ "Colision Damage Divisor" ] );
        if not getElementData( localPlayer, "veh:belt" ) then
            triggerServerEvent( "beltVehicle > min_health", resourceRoot, localPlayer, power )
        end
    end
end )

bindKey( settings[ "Bind" ], "up", function( )
    if getPedOccupiedVehicle( localPlayer ) and not settings[ "Vehicles Blocked" ][ getVehicleID( getPedOccupiedVehicle( localPlayer ) ) ] then
        if getElementData( localPlayer, "veh:belt" ) then
            setElementData( localPlayer, "veh:belt", false )
            if not sound then
                sound = playSound( "assets/belt.mp3", false );
            end
            playSound( "assets/belt2.mp3", false );
            triggerEvent('addBox', localPlayer, "Pressione '"..settings[ "Bind" ].."' para equipar o cinto de segurança!", "warning")
        else
            triggerEvent('addBox', localPlayer, "Você equipou o cinto de segurança.", "info")
            setElementData( localPlayer, "veh:belt", true )
            playSound( "assets/belt1.mp3", false );
            if sound and isElement( sound ) then
                stopSound( sound )
                sound = nil;
            end
        end
    end
end )

addEvent( "beltVehicle > playsound", true )
addEventHandler( "beltVehicle > playsound", root, function( path, loop )
    sound = playSound( path, false, loop or false );
end )

addEvent( "beltVehicle > stopsound", true )
addEventHandler( "beltVehicle > stopsound", root, function( )
    if sound and isElement( sound ) then
        stopSound( sound )
        sound = nil;
    end
end )