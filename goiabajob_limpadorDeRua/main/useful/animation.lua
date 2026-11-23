animation = {
    data = {},
    running = false,

    create = function(index, duration, easing)
        if not animation.data[index] then
            animation.data[index] = {
                initial = 0,
                final = 0,
                duration = duration,
                easing = easing,
                tick = 0
            }

            return animation.data[index]
        end

        return false
    end,

    exec = function(index, initial, final, duration, easing)
        if animation.data[index] then
            animation.data[index].initial = initial
            animation.data[index].final = final
            animation.data[index].duration = duration or animation.data[index].duration
            animation.data[index].easing = easing or animation.data[index].easing
            animation.data[index].tick = getTickCount()

            return true
        end

        return false
    end,

    get = function(index)
        local animation = animation.data[index]
        local progress = (getTickCount() - animation.tick) / animation.duration

        if progress >= 1 then
            animation.running = false
            return animation.final
        end

        animation.running = true

        return interpolateBetween(animation.initial, 0, 0, animation.final, 0, 0, progress, animation.easing)
    end,

    isRunning = function(index) 
        local animation = animation.data[index]
        local progress = (getTickCount () - animation.tick) / animation.duration

        if progress >= 1 then
            return false
        end

        return true
    end
}