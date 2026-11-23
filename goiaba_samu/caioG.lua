--== Script feito por:
--== ● Caio ●
--== Discord: Caio#8888
--===================================================
--== Qualquer problema procure pelo meu discord.
--===================================================

color = '#FD5A5A'

config = {
    ['Quant.Caido'] = 20, -- Abaixo desse hp o jogador fica caído.
    ['headshot'] = true, -- Utilize 'true' para ativar e 'false' para desativar.
    vida_desanimado = 30, -- Quantos de vida precisa ter pra ficar desanimado.
    Money = {1000, 2000},
    time = {
        ["default"] = 8*60000,
        ["Maça"] = 6*60000,
        ["Banana"] = 5*60000,
        ["Goiaba"] = 3*60000,
        ["Goiabão"] = 2*60000,
        ["Patrocinador"] = 50000,
    },
    tempo_dead = (10*50000), --// Em milisegundos.
    acl_samu = 'samu', --// ACL de samu.
    system_id = 'ID', -- elementdata do seu ID
}

info = {
    ['warning'] = "warning",
    ['success'] = "success",
    ['error'] = "error",
    ['info'] = "info"
};

notify = {
    ['server'] = function(element, message, type)
        return exports['goiaba_infobox']:addBox(element, message, info[type])
    end,
    ['client'] = function(message, type)
        return exports['goiaba_infobox']:addBox(message, info[type])
    end
};