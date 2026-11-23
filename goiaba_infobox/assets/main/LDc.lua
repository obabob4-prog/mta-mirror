--[[
    --» sᴄʀɪᴘᴛ ғᴇɪᴛᴏ ᴘᴏʀ » Pedrooooo#1554
--]]

local x, y = guiGetScreenSize()
local screenScale = math.min(math.max(y / 768, 0.70), 2); -- Caso o painel seja muito grande, retirar o limite e deixar apenas o (screenH / 768).

local tick = getTickCount()
local infos, time, alpha, progress, progressCircle, progressCircle2 = {}, {}, {}, {}, {}, {}

local fonts = {
    exports['goiaba_fonts']:useFont('sf:regular', (14/1.25));
    exports['goiaba_fonts']:useFont('sf:regular', (13/1.25));
}

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        fonts = {
            exports['goiaba_fonts']:useFont('sf:regular', (14/1.25));
            exports['goiaba_fonts']:useFont('sf:regular', (13/1.25));
        }
    end
end)

function infobox()


    local totalHeight = 0
    for i, v in ipairs(infos) do 

        local dataType = config.types[v[2]]
        time[i] = interpolateBetween((config.messageTime * 1000), 0, 0, 0, 0, 0, ((getTickCount() - v[3]) / (config.messageTime * 1000)), 'Linear')
        progress[i] = interpolateBetween(0, 0, 0, 100, 0, 0, ((getTickCount() - v[3]) / (config.messageTime * 1000)), 'Linear')
        
        if not (v[4]) then 
            
            alpha[i] = interpolateBetween(0, 0, 0, 255, 0, 0, ((getTickCount() - v[5]) / 500), 'Linear')
            
            if (time[i] <= 500) then 
                
                v[4], v[5] = true, getTickCount() 
                
            end
            
        else 
            
            alpha[i] = interpolateBetween(255, 0, 0, 0, 0, 0, ((getTickCount() - v[5]) / 500), 'Linear')
            
        end 
        
        local textSize = {dxGetTextSize(v[1], 220, 1, 1, fonts[2], true)}

        if textSize[2] >= 20 then
            widthRectangle, heightRectangle = 250, textSize[2] + 20
        else
            widthRectangle, heightRectangle = 250, textSize[2] + 35
        end
        local startX, startY = x - 310, (y / 2 - 150) + (totalHeight) + 30

        if (i == 1) then 
            if (#infos == 1) then 
                drawBorder(10, startX, startY, widthRectangle, heightRectangle, tocolor(15, 15, 15, alpha[i] * 0.84), true)
            else
                drawRoundedTopBorder(10, startX, startY, widthRectangle, heightRectangle, tocolor(15, 15, 15, alpha[i] * 0.84), true)
            end
        elseif (i == #infos) then 
            drawRoundedBottomBorder(10, startX, startY, widthRectangle, heightRectangle, math.fmod(i, 2) == 0 and tocolor(15, 15, 15, alpha[i] * 0.8) or tocolor(15, 15, 15, alpha[i] * 0.84), true)
        else 
            dxDrawRectangle(startX, startY, widthRectangle, heightRectangle, math.fmod(i, 2) == 0 and tocolor(15, 15, 15, alpha[i] * 0.8) or tocolor(15, 15, 15, alpha[i] * 0.84))
        end
    
        dxDrawImage(startX + 5, startY + 5, 40, 40, 'assets/images/'..v[2]..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha[i] * 0.3), true)
        dxDrawImageSection(startX + 5, startY + 5 + 40, 40, math.floor(- 40 * (progress[i] / 100)), 0, 0, 40, math.floor(- 40 * (progress[i] / 100)), 'assets/images/'..v[2]..'.png', 0, 0, 0, tocolor(255, 255, 255, alpha[i]), true)

        dxDrawText(v[1], startX + 50, startY + 20, textSize[1], 14, tocolor(255, 255, 255, alpha[i] * 0.4), 1, fonts[2], 'left', 'center', false, true, true)

        if (v[6] > 1) then 
            dxDrawText(v[6]..'x', (startX + 219), startY + 10, 12, 14, tocolor(255, 255, 255, alpha[i] * 0.3), 1, fonts[1], 'left', 'top', false, false, true)
        end

        local currentTime = math.floor(getRealTime().timestamp - v.timestamp)
        --dxDrawText(currentTime == 0 and 'agora' or currentTime..'s', (startX + 171), startY + heightRectangle - 22, 24, 14, tocolor(255, 255, 255, alpha[i] * 0.3), 1, fonts[1], 'right', 'top', false, false, true)
        if time[i] == 0 then 
            table.remove(infos, i)
        end
        totalHeight = totalHeight + heightRectangle
    end
end
addEventHandler('onClientRender', root, infobox) 


function addBox(message, type) 

    if (config.types[type]) then
    
        local dataType =  config.types[type]
        if (#infos >= config.maxInfobox) then 
        
            table.remove(infos, 1)
        
        end
    
        for i, v in ipairs(infos) do 
            
            if (v[1] == message and v[2] == type) then 
            
                v[6] = (v[6] + 1)
            
            return end
            
        end
    
        table.insert(infos, {message, type, getTickCount(), false, getTickCount(), 1, timestamp = getRealTime().timestamp})
        local sound = playSound(dataType.sound)
        setSoundVolume(sound, 0.4)
    
    end

end
addEvent('addBox', true)
addEventHandler('addBox', root, addBox)

------------------------------------------------
function table.reverse(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end


_dxDrawText = dxDrawText
function dxDrawText (text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGui, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY, fLineSpacing, normalPos)

    return _dxDrawText (text, x, y, (w + x), (h + y), color, scale, font, alignX, alignY, clip, wordBreak, postGui, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY, fLineSpacing, normalPos)

end



size = {}
function drawBorder ( radius, x, y, width, height, color, postGUI, colorStroke, sizeStroke)
    colorStroke = tostring(colorStroke)
    sizeStroke = tostring(sizeStroke)
    if (not size[height..':'..width]) then
        local raw = string.format([[
            <svg width='%s' height='%s' fill='none' xmlns='http://www.w3.org/2000/svg'>
                <mask id='path_inside' fill='#FFFFFF' >
                    <rect width='%s' height='%s' rx='%s' />
                </mask>
                <rect opacity='1' width='%s' height='%s' rx='%s' fill='#FFFFFF' stroke='%s' stroke-width='%s' mask='url(#path_inside)'/>
            </svg>
        ]], width, height, width, height, radius, width, height, radius, colorStroke, sizeStroke)
        size[height..':'..width] = svgCreate(width, height, raw)
    end
    if (size[height..':'..width]) then
        dxDrawImage(x, y, width, height, size[height..':'..width], 0, 0, 0, color, postGUI)
    end
end

function drawRoundedTopBorder(radius, x, y, width, height, color, postGUI, colorStroke, sizeStroke)
    colorStroke = tostring(colorStroke)
    sizeStroke = tostring(sizeStroke)

    local cacheKey = height..':'..width..':'..radius

    if not size[cacheKey] then
        local svgHeight = math.ceil(height / width * 205) -- Calcula a altura proporcional
        local raw = "<svg width='"..width.."' height='"..svgHeight.."' viewBox='0 0 "..width.." "..svgHeight.."' fill='none' xmlns='http://www.w3.org/2000/svg'>"
        raw = raw.."<path d='M0 8C0 3.58172 3.58172 0 8 0H"..(width - 8).."C"..(width - 3.58172).." 0 "..width.." 3.58172 "..width.." 8V"..svgHeight.."H0V8Z' fill='white' fill-opacity='1'/>"
        raw = raw.."</svg>"
        size[cacheKey] = svgCreate(width, svgHeight, raw)
    end

    if size[cacheKey] then
        dxDrawImage(x, y, width, height, size[cacheKey], 0, 0, 0, color, postGUI)
    end
end

function drawRoundedBottomBorder(radius, x, y, width, height, color, postGUI, colorStroke, sizeStroke)
    colorStroke = tostring(colorStroke)
    sizeStroke = tostring(sizeStroke)

    local cacheKey = height..':'..width..':'..radius..' BOTTOM'

    if not size[cacheKey] then
        local svgHeight = math.ceil(height / width * 205) -- Calcula a altura proporcional
        local raw = "<svg width='"..width.."' height='"..svgHeight.."' viewBox='0 0 "..width.." "..svgHeight.."' fill='none' xmlns='http://www.w3.org/2000/svg'>"
        raw = raw.."<path d='M0 0H"..width.."V"..(svgHeight - 8).."C"..width.." "..(svgHeight - 3.58172).." "..(width - 3.58172).." "..svgHeight.." "..(width - 8).." "..svgHeight.."H8C3.58173 "..svgHeight.." 0 "..(svgHeight - 3.58172).." 0 "..(svgHeight - 8).."V0Z' fill='white' fill-opacity='1'/>"
        raw = raw.."</svg>"
        size[cacheKey] = svgCreate(width, svgHeight, raw)
    end

    if size[cacheKey] then
        dxDrawImage(x, y, width, height, size[cacheKey], 0, 0, 0, color, postGUI)
    end
end
------------------------------------------------      