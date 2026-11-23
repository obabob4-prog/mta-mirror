local screenW, screenH = guiGetScreenSize()

local size = screenW == 1920 and 1.4 or 1

local screenScale = math.min(math.max(screenH / 768, size), size)



local parentW, parentH = 160 * screenScale, (95 + 45) * screenScale

local parentX, parentY = (screenW - parentW) / 2, screenH - parentH



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



--| Var's

local notify = {}

local showTime = (4 * 1000) --| Tempo que a notificação irá ficar visivel na tela do jogador.

local position = {

    ['gap'] = 5,

}



local fontsNotify = {
    exports['goiaba_fonts']:useFont('int:regular', 10);
    exports['goiaba_fonts']:useFont('int:bold', 10);
    exports['goiaba_fonts']:useFont('int:regular', 9);
}

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        fontsNotify = {
            exports['goiaba_fonts']:useFont('int:regular', 10);
            exports['goiaba_fonts']:useFont('int:bold', 10);
            exports['goiaba_fonts']:useFont('int:regular', 9);
        }
    end
end)



function renderNotify()

    if notify and (#notify ~= 0) then 

        for i = 1, #notify do 

            local box = notify[i]

            if box then

                if (getTickCount() - box["tick"]) >= showTime then 

                    table.remove(notify, i)

                end


                if (getTickCount() - box["tick"]) >= (showTime - 700) then

                    if not box["animations"]["out"] then 

                        box["animations"]["out"] = getTickCount()

                    end

                    box["animations"]["alpha"] = interpolateBetween(255, 0, 0, 0, 0, 0, (getTickCount() - box["animations"]["out"]) / 700, "OutQuad")

                    box["animations"]["position"] = interpolateBetween(0, 0, 0, 1080, 0, 0, (getTickCount() - box["animations"]["out"]) / 700, "InQuad")

                else

                    box["animations"]["alpha"] = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount() - box["tick"]) / 700, "OutQuad")

                    box["animations"]["position"] = interpolateBetween(60, 0, 0, 0, 0, 0, (getTickCount() - box["tick"]) / 700, "OutQuad")

                end



                local alpha = box["animations"]["alpha"]

                local x, y;

                

                x, y = 0, (box["animations"]["position"] - (50 * (i - 1)))



                dxDrawImage(x, y-110, 160, 45, "core/assets/images/"..box['action']..".png", 0,0,0,tocolor(255, 255, 255, 200))

                if(box['action'] == 'give')then

                    dxDrawText("Adicionado", x+61, y+10-113, 50, 15, tocolor ( 255, 255, 255, 160 ), 1, fontsNotify[1])

                else

                    dxDrawText("Removido", x+61, y+10-110, 50, 15, tocolor ( 255, 255, 255, 160 ), 1, fontsNotify[1])

                end

                dxDrawText(box['name'], x+61, y+22-110, 80, 15, tocolor ( 255, 255, 255, 160 ), 1, fontsNotify[2])



                dxDrawText(box['amount'].."x", x+139, y+18-110, 50, 15, tocolor ( 255, 255, 255, 100 ), 1, fontsNotify[3])



                dxDrawImage(x+20, y+5-110, 35, 35, box['image'])



            end

        end

    end

end

addEventHandler("onClientRender", root, renderNotify, false, "low-10")



function triggerNotify(id, amount, action)

    if not id then 

        return 

    end



    local item = config["itens"][id] 

    if not item then 

        return 

    end



    if (#notify >= 2) then 

        table.remove(notify, 1)

    end 



    notify[#notify + 1] = {

        ['tick'] = getTickCount(),

        ['animations'] = {

            ['alpha'] = 0,

        },

        ['action'] = action, 

        ['amount'] = amount, 

        ['name'] = item['name'],

        ['image'] = item['image']

    }

    return options

end

addEvent("FS:triggerNotify", true)

addEventHandler("FS:triggerNotify", root, triggerNotify)