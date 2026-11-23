local screenW, screenH = guiGetScreenSize();
local screenScale = math.min(math.max(screenH / 1080, 0.70), 2); -- Caso o painel seja muito grande, retirar o limite e deixar apenas o (screenH / 76

local parentW, parentH = 390 * screenScale, 79 * screenScale
local parentX, parentY = (screenW - parentW) / 2, screenH - parentH - (screenScale * 30)

local function respX(x) return parentX + x * screenScale end
local function respY(y) return parentY + y * screenScale end
local function respC(scale) return scale * screenScale end

local function dxDrawText(text, x, y, width, height, ...)
    return _dxDrawText(text, respX(x), respY(y), respX(x) + respC(width), respY(y) + respC(height), ...)
end

local function dxDrawRectangle(x, y, width, height, ...)
    return _dxDrawRectangle(respX(x), respY(y), respC(width), respC(height), ...)
end

local function dxDrawImage(x, y, width, height, image, ...)
    return _dxDrawImage(respX(x), respY(y), respC(width), respC(height), image, ...)
end

local actions = {
    {317, 182, 80, 80},
    {317, 273, 80, 80},
    {317, 364, 80, 80},
    {317, 455, 80, 80},
    {317, 546, 80, 80},
}


local fontAction = exports['goiaba_fonts']:useFont("sf:bold", 16 / 1.4)
local fontAction2 = exports['goiaba_fonts']:useFont("rc:medium", 13 / 1.25)

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        fontAction = exports['goiaba_fonts']:useFont("rc:medium", 18 / 1.25)
        fontAction2 = exports['goiaba_fonts']:useFont("rc:medium", 13 / 1.25)
    end
end)
-- local posx, posy = screenW / 2 - 270 / 2, screenH - 24 - 47

-- addEventHandler('onClientRender', root, function()  
--     local alpha = 255
--     if bag[localPlayer] then
--         if getElementData(localPlayer, 'bloqInterface') then return end

--         posAction = {}
--         slotOcupado = {}

--         local playerItens = bag[localPlayer]["itemData"]
--         if playerItens and #playerItens ~= 0 then
--             for _, item in ipairs(playerItens) do
--                 local action = item["itemAction"]
--                 if action and action > 0 and action <= 5 then
--                     slotOcupado[action] = true
--                 end
--             end
--         end

--         for i = 1, 5 do
--             local px = 82 * (i - 1)
--             if not slotOcupado[i] then
--                 dxDrawImage(px, 17, 62, 62, 'core/assets/images/action2.png', 0, 0, 0, tocolor(255, 255, 255, 255*0.5))
--             else
--                 dxDrawImage(px, 17, 62, 62, 'core/assets/images/action2.png', 0, 0, 0, tocolor(255, 255, 255, 255))
--             end

--             dxDrawImage(px + 19, 0, 24, 24, 'core/assets/images/circleAction.png', 0, 0, 0, tocolor(255, 255, 255, alpha))
--             dxDrawText(i, px + 19, 0, 24, 24, tocolor(0, 0, 0, alpha * 0.85), 1, fontAction, 'center', 'center')

--             posAction[i] = {px, 17, 45, 50}
--         end

--          local playerItens = bag[localPlayer]["itemData"]
--          if playerItens and #playerItens ~= 0 then
--              for _, item in ipairs(playerItens) do
--                  local action = item["itemAction"]
--                  if action and action > 0 and action <= 5 then

--                      local id = item["itemID"]
--                      local name, slot, amount, image = config["itens"][id]["name"], item["itemSlot"], item["itemAmount"], icons[id]
--                      dxDrawImage(posAction[action][1] + 10, posAction[action][2] + 10, 42, 42, image["image"], 0, 0, 0, tocolor(255, 255, 255, alpha), false)

--                  end
--              end
--          end
--     end
-- end)


function dxGetFontSizeFromHeight( height, font )
    if type( height ) ~= "number" then return false end
    font = font or "default"
    local ch = dxGetFontHeight( 1, font )
    return height/ch
end 