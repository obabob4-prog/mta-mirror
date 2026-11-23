function rgba(r, g, b, a)

    a = a or 1

    return tocolor(r, g, b, a * 255)

end



function lerp(from, to, progress)

    return from + (to - from) * progress

end



function getNearestVehicle(player, distance)
    local x, y, z = getElementPosition(player)
    local vehicles = getElementsByType('vehicle', root, true)
    local nearest = nil
    local nearestDistance = distance
    for i, vehicle in ipairs(vehicles) do
        local vx, vy, vz = getElementPosition(vehicle)
        local dis = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
        if (dis < nearestDistance) then
            nearest = vehicle
            nearestDistance = dis
        end
    end
    if nearest ~= nil then
        return nearest
    else
        local vehicles = getElementsByType('player', root, true)
        local nearestVehicle = nil
        local nearestDistanceVehicle = distance
        for i, vehicle in ipairs(vehicles) do
            if vehicle ~= localPlayer then
                local vx, vy, vz = getElementPosition(vehicle)
                local dis = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
                if (dis < nearestDistanceVehicle) then
                    nearestVehicle = vehicle
                    nearestDistanceVehicle = dis
                end
            end
        end
        return nearestVehicle
    end
end

function createPulseAnimation(duration, multiplier)

    local from = 0

    local to = multiplier

    local startTime = getTickCount()



    return function()

        local tick = getTickCount()

        local passed = tick - startTime

        local progress = passed / duration



        local value = interpolateBetween(

            from, 0, 0, 

            to, 0, 0, 

            progress, 

            'InOutQuad'

        )



        if (progress > 1) then

            local _to = to

            to = from

            from = _to



            startTime = tick

        end



        return value

    end

end