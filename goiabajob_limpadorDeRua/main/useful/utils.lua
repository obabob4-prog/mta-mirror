local createdFonts = {}
local cachedFonts = {}
function getFont(font, size)
    if not cachedFonts[font..':'..size] then
        cachedFonts[font..':'..size] = {font, size}
    end
    if (createdFonts[font..':'..size]) then 
        return createdFonts[font..':'..size] 
    else
        if font == "digital" or font == "heavy" then
            createdFonts[font..':'..size] = exports['goiaba_fonts']:useFont('gn:'..font, respc(size / 1.25))
        else
            createdFonts[font..':'..size] = exports['goiaba_fonts']:useFont('sf:'..font, respc(size / 1.25))
        end
        return createdFonts[font..':'..size]
    end
end

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        for i,v in pairs(cachedFonts) do
            getFont(v[1], v[2])
            createdFonts = {}
        end
    end
end)

local buttons = {}

function drawRect(x, y, width, height, radius, color, colorStroke, sizeStroke, postGUI)
    colorStroke = tostring(colorStroke)
    sizeStroke = tostring(sizeStroke)
    
    if (not buttons[radius]) then
        local raw = string.format([[
        <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'>
        <mask id='path_inside' fill='#FFFFFF' >
        <rect width='%s' height='%s' rx='%s' />
        </mask>
        <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/>
        </svg>
        ]], width, height, width, height, radius, width, height, radius, colorStroke, sizeStroke)
        buttons[radius] = svgCreate(width, height, raw)
    end
    if (buttons[radius]) then -- Se já existir um botão com o mesmo Radius, reaproveitaremos o mesmo, para não criar outro.
        dxDrawImage(x, y, width, height, buttons[radius], 0, 0, 0, color, postGUI)
    end
end


function formatNumber(number)
	return string.gsub(number, '^(-?%d+)(%d%d%d)', '%1.%2')
end

removeHex = 
function(str) 
    return str:gsub("#%x%x%x%x%x%x", "") 
end 

--local vehicle, model, dimension, interior = getVehicleProx(player, 4.0, 'vehicle')

-- getVehicleProx = function(player, dist, type_action)
--     if player and dist and type_action then
--         for i, v in ipairs(getElementsByType(type_action)) do
--             local x, y, z = getElementPosition(v)
--             local ax, ay, az = getElementPosition(player)
--             if getDistanceBetweenPoints3D(x, y, z, ax, ay, az) <= tonumber(dist) then
--                 return v, getElementModel(v), getElementDimension(v), getElementInterior(v)
--             end
--         end
--     end
--     return false
-- end


-- getAclPlayer = 
-- function(player,acl)
--     if aclGetGroup ( acl ) then
--         if isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(player)), aclGetGroup(acl)) then
--             return true
--         end
--     else
--         outputDebugString ( "O Sistema não identificou a acl "..acl..", por favor crie a acl informada!", 3,5,162,238 ) 
--     end
--     return false
-- end

-- resultAcls = 
-- function(player,acl)
--     result = 0
--     for i, players in ipairs (getElementsByType("player")) do
--         if not aclGetGroup ( acl ) then 
--             outputDebugString ( "O Sistema não identificou a acl "..acl..", por favor crie a acl informada!", 3,5,162,238 ) 
--             return
--         end
--         tableacl = aclGroupListObjects(aclGetGroup(acl))
--         for i, v in ipairs(tableacl) do
--             result = i
--         end
--     end
--     return result
-- end