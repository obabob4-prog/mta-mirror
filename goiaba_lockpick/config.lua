local settings = {

    time = 24, -- Tempo em segundos para abrir o veículo
    colors = { -- Cores dos pinos e da barra
        pin = { 118, 225, 145 },
        bar = { 103, 210, 115 },
        background = { 25, 27, 29 }
    },

    -- O pré-fixo `${cor}` será substituído pela cor do tema da LockPick.
    text = 'APERTE ${cor}[ESPAÇO] #FFFFFFNO TEMPO CERTO.', -- Texto que aparece no centro da LockPick

    key = 'space', -- Tecla para abrir a LockPick
    colorTheme = '#73C883', -- Cor do tema da LockPick

    vehiclesNotAllowed = { 411, 516, 586, 471, 405, 585, 522, 541, 422, 494, 503, 477, 547, 426, 546, 559, 562, 565 }, -- Veículos que não podem ser abertos com a LockPick

    animation = { 'BOMBER', 'BOM_Plant', -1, true, false, true, false }, -- Animação do jogador ao usar a LockPick

    sendNotification = function(side, ...)

        local typesNotification = { -- -> Tipos das notificações.
            ["success"] = "success", -- -> Tipo "success" é para sucesso.
            ["info"] = "info", -- -> Tipo "info" é o padrão.
            ["error"] = "error", -- -> Tipo "error" é para erros.
        }

        if (side == "server") then
            local element, message, notificationType = ...
            return exports["goiaba_infobox"]:addBox(element, message, typesNotification[notificationType] or "info") -- -> Envia a notificação para o servidor.
        elseif (side == "client") then
            local message, notificationType = ...
            return exports["goiaba_infobox"]:addBox(message, typesNotification[notificationType] or "info") -- -> Envia a notificação para o cliente.
        end
    end,
}

function getSettings()
    return settings
end