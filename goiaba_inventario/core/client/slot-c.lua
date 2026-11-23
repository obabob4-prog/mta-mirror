--| Change slot 



function changeSlot(index, new)

    if bag[localPlayer]["itemData"] and #bag[localPlayer]["itemData"] ~= 0 then

        

        if (bag[localPlayer]["itemData"][index] and bag[localPlayer]["itemData"][index]["itemSlot"] ~= new) then 

            

            local newIndex = getIndexBySlot(new)

            if not newIndex then     

                    

                bag[localPlayer]["itemData"][index]["itemSlot"] = new

                

            else

                

                local oldSlot = bag[localPlayer]["itemData"][index]["itemSlot"]

                

                bag[localPlayer]["itemData"][index]["itemSlot"] = new

                bag[localPlayer]["itemData"][newIndex]["itemSlot"] = oldSlot



            end

            triggerServerEvent("FS:updateServer", localPlayer, localPlayer, bag[localPlayer]["itemData"])



        end

    end

end



function changeAction(index, new)

    if (bag[localPlayer]["itemData"] and bag[localPlayer]["itemData"][index]) then



        local actionIndex = isActionFree(new)

        if not actionIndex then

            bag[localPlayer]["itemData"][index]["itemAction"] = new

        else

            if actionIndex ~= index then 

                bag[localPlayer]["itemData"][index]["itemAction"] = new

                bag[localPlayer]["itemData"][actionIndex]["itemAction"] = 0

            end

        end

        

        triggerServerEvent("FS:updateServer", localPlayer, localPlayer, bag[localPlayer]["itemData"])



    end

end



--| Action use

addEventHandler("onClientKey", root, function(button, press)
    if isEventHandlerAdded('onClientRender', root, renderStore) then 
        return 
    end
    if isEventHandlerAdded('onClientRender', root, renderBag) then 
        return 
    end
    if isEventHandlerAdded('onClientRender', root, renderChest) then 
        return 
    end
    if press then 
        local slot = tonumber(button)
        if slot and (slot > 0 and slot < 6) then
            if isChatBoxInputActive() or guiGetInputEnabled() then
                return
            end
            if (getElementData(localPlayer, 'FS:actionState > cuff') or getElementData(localPlayer, 'amarrado/algemado')) then
                return
            end
            triggerServerEvent("FS:actionFunctions", localPlayer, slot, "use")
        end
    end
end)

--| Misc



function getIndexBySlot(slot)

    local index

    if bag[localPlayer]["itemData"] and #bag[localPlayer]["itemData"] ~= 0 then 

        for i = 1, #bag[localPlayer]["itemData"] do 

            if slot == bag[localPlayer]["itemData"][i]["itemSlot"] then 

                index = i

                break

            end

        end

    end

    return index

end



function isActionFree(slot)

    local slotIndex 

    

    for i = 1, #bag[localPlayer]["itemData"] do 

        if (bag[localPlayer]["itemData"][i]["itemAction"] == slot) then

            slotIndex = i

        end

    end

    return slotIndex

end



--| Slot chest



function changeChestSlot(index, new)

    if chest["data"]["itemData"] and #chest["data"]["itemData"] ~= 0 then

        

        if (chest["data"]["itemData"][index] and chest["data"]["itemData"][index]["itemSlot"] ~= new) then 

            

            local newIndex = getChestIndexBySlot(new)

            if not newIndex then     

                    

                chest["data"]["itemData"][index]["itemSlot"] = new

                

            else

                

                local oldSlot = chest["data"]["itemData"][index]["itemSlot"]

                

                chest["data"]["itemData"][index]["itemSlot"] = new

                chest["data"]["itemData"][newIndex]["itemSlot"] = oldSlot



            end

            triggerServerEvent("FS:updateChest", localPlayer, localPlayer, chest["data"]["itemData"])



        end

    end

end



function getChestIndexBySlot(slot)

    local index

    if chest["data"]["itemData"] and #chest["data"]["itemData"] ~= 0 then 

        for i = 1, #chest["data"]["itemData"] do 

            if slot == chest["data"]["itemData"][i]["itemSlot"] then 

                index = i

                break

            end

        end

    end

    return index

end



--| Slot trunk



function changeTrunkSlot(index, new)

    if trunk["data"]["itemData"] and #trunk["data"]["itemData"] ~= 0 then

        

        if (trunk["data"]["itemData"][index] and trunk["data"]["itemData"][index]["itemSlot"] ~= new) then 

            

            local newIndex = getTrunkIndexBySlot(new)

            if not newIndex then     

                    

                trunk["data"]["itemData"][index]["itemSlot"] = new

                

            else

                

                local oldSlot = trunk["data"]["itemData"][index]["itemSlot"]

                

                trunk["data"]["itemData"][index]["itemSlot"] = new

                trunk["data"]["itemData"][newIndex]["itemSlot"] = oldSlot



            end

            triggerServerEvent("FS:updateTrunk", localPlayer, localPlayer, trunk['vehData'], trunk["data"]["itemData"])



        end

    end

end



function getTrunkIndexBySlot(slot)

    local index

    if trunk["data"]["itemData"] and #trunk["data"]["itemData"] ~= 0 then 

        for i = 1, #trunk["data"]["itemData"] do 

            if slot == trunk["data"]["itemData"][i]["itemSlot"] then 

                index = i

                break

            end

        end

    end

    return index

end