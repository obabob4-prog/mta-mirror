--| Create item icon's



icons = {}



addEventHandler("onClientResourceStart", resourceRoot, function()

    for i, v in pairs(config["itens"]) do 

        if fileExists(v["image"]) then 

            --local texture = dxCreateTexture(v["image"])

            --if texture then 

                --local w, h = dxGetMaterialSize(texture)

                icons[i] = {

                    ['image'] = v['image'],

                    --['w'] = w,

                    --['h'] = h,

                }

                --destroyElement(texture)

           -- end

        end

    end

end)