local color_animation = {}

modules.exports ('colorAnimation', function (id, duration, r2, g2, b2, alpha, verify)
    if not color_animation[id] then
        color_animation[id] = {id = id, duration = duration, alpha = alpha, r = r2, g = g2, b = b2, lastR = r2, lastG = g2, lastB = b2, lastA = alpha, tick = nil}
    end
    if r2 ~= color_animation[id].lastR or g2 ~= color_animation[id].lastG or b2 ~= color_animation[id].lastB or alpha ~= color_animation[id].lastA then
        color_animation[id].tick = getTickCount()
        color_animation[id].lastR = r2
        color_animation[id].lastG = g2
        color_animation[id].lastB = b2
        color_animation[id].lastA = alpha
    elseif color_animation[id].r == r2 and color_animation[id].g == g2 and color_animation[id].b == b2 and color_animation[id].alpha == alpha then
        color_animation[id].tick = nil
    end
    if color_animation[id].tick then
        local interpolate = {interpolateBetween(color_animation[id].r, color_animation[id].g, color_animation[id].b, r2, g2, b2, (getTickCount() - color_animation[id].tick) / color_animation[id].duration, 'Linear')}
        local interpolateAlpha = interpolateBetween(color_animation[id].alpha, 0, 0, alpha, 0, 0, (getTickCount() - color_animation[id].tick) / color_animation[id].duration, 'Linear')

        color_animation[id].r = interpolate[1]
        color_animation[id].g = interpolate[2]
        color_animation[id].b = interpolate[3]
        color_animation[id].alpha = interpolateAlpha
    end
    if (verify and ((verify > 0 and verify < 1) and true or false) or false) then
        color_animation[id].alpha = alpha
    end
    return tocolor(color_animation[id].r, color_animation[id].g, color_animation[id].b, color_animation[id].alpha)
end)

modules.exports ('deleteColorAnimations', function ()
    for i in pairs(color_animation) do
        color_animation[i] = nil;
    end
end)

local _tocolor = tocolor
function tocolor(r, g, b, a)
    return _tocolor(math.min(255, math.max(0, r)), math.min(255, math.max(0, g)), math.min(255, math.max(0, b)), math.min(255, math.max(0, a)))
end

modules.exports ('ceh', function (Ename, ...)
    addEvent(Ename, true)
    addEventHandler(Ename, ...)
end)

modules.exports ('lerp', function (a, b, t)
    return a + (b - a) * t
end)

function isTable (variable)
    if (type(variable) == 'table') then
        return true;
    end
    return false;
end

function isFunction (variable)
    if (type(variable) == 'function') then
        return true;
    end
    return false;
end

function isNumber (variable)
    if (type(variable) == 'number') then
        return true;
    end
    return false;
end

function isThread (variable)
    if (type(variable) == 'thread') then
        return true;
    end
    return false;
end

function isString (variable)
    if (type (variable) == 'string') then
        return true;
    end
    return false;
end