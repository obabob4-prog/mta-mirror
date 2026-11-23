config = {

    ['commands'] = {
        ['drop'] = "soltar", --| Comando para deixar a JBL no chão.
        ['get'] = "pegar", --| Comando para pegar a JBL do chão.
    },

}

message = function(element, message, style)
    if (element and isElement(element) and getElementType(element) == "player") then 
        triggerClientEvent(element, "addBox", element, message, style)
    end
end