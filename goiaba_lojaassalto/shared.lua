config = {

    colorHex = '#73c883',

    blipLiberado = 17, -- blip quando está liberado para assaltar
    blipAssalto = 20, -- blip quando estiver em assalto ou progresso de recuperação

    markers = {
        {
            1315.06, -880.87, 40.01, 'Lojinha Vinewood',
            porta = {
                {1313.8, -896.59998, 39, 0, 0, 0},
                {1316.8, -896.59998, 39, 0, 0, 179},
            },
        },
        {
            2437.83, -1778.79, 13.9, 'Lojinha CJ',
            porta = {
                {2424.28, -1781.9399, 12.9, 0, 0, 270},
                {2424.2998, -1785.0996, 12.9, 0, 0, 89.247},
            },
        },
        {
            1017.97, -1854.31, 14.01, 'Lojinha Praia',
            porta = {
                {1033.5996, -1851.2002, 13, 0, 0, 91.747},
                {1033.5, -1848.2002 ,13 ,0 ,0 , -89.011},
            },
        },
        {
            2520.2, -1528.43, 24.4, 'Lojinha Açougueiro',
            porta = {
                {2513.8999, -1515, 23.4, 0, 0, 0},
                {2517.1001, -1514.95, 23.4, 0, 0, 179.5},
                {2512, -1526.24, 23.4, 0, 0, 269.5},
            },
        },
        {
            397.23, -1315.6, 15.41, 'Lojinha Tunel',
            porta = {
                {406, -1328.7002, 14.4, 0, 0, 33.75},
                {408.5, -1327, 14.4, 0, 0, -146.008},
            },
        },
        {
            371.69, -2068.23, 8.21, 'Lojinha Pier',
            porta = {
                {368.29999, -2052.7, 7.2, 0, 0, 0},
                {371.29999, -2052.7, 7.2, 0, 0, 179.5},
            },
        },
        {
            1202.1, -1116.17, 24.61, 'Lojinha Fama',
            porta = {
                {1203.5996, -1131.9004, 23.6, 0, 0, 0},
                {1206.5996, -1131.9004, 23.6, 0, 0, 178.995},
            },
        },
        {
            2057.67, -1876.25, 13.9, 'Lojinha Pizzaria',
            porta = {
                {2071.3, -1870.6, 12.9, 0, 0, 269.247},
                {2071.2998, -1873.7998, 12.9, 0, 0, 89.247},
                {2060, -1868.7, 12.9, 0, 0, 180},
            },
        },
    },

    tempoassaltando = 2, -- tempo assaltando
    animation = {'bomber', 'bom_plant_loop'}, -- adicione a animação: bloco e name

    maxPolice = 6, -- Quantidade minima de policial online para poder assaltar.
    police = 'policia', -- grupo de policial
    cooldown = 30, -- minutos para assaltar denovo.

    quantia = {50000, 100000}, -- valor aleatório para receber após assalto.

    giveDinheiro = function (player, value)
        exports['goiaba_inventario']:giveItem(player, 33, value)
    end,

    webhook = 'https://discord.com/api/webhooks/1453063477999698093/07CvyzChyXodqd0_Wt2XK1HoMFp0qeaJMB1qWzuBVYv9XU4QYBx5VVQLuy2J4SZsitzA',

    embed = {
        title = 'Assalto a lojinhas',
        avatar_icon = 'https://cdn.discordapp.com/attachments/1148009216691404890/1148012906630365195/logoold.png',
        thumbnail = 'https://cdn.discordapp.com/attachments/1148009216691404890/1148012906630365195/logoold.png',
        color = '5763719', -- Pegue as cores aqui: https://gist.github.com/thomasbnt/b6f455e2c7d743b796917fa3c205f812
    },

    notify = function (src, player, message, type)
        if src == 'client' then
            exports['goiaba_infobox']:addBox(message, type)
        elseif src == 'server' then
            exports['goiaba_infobox']:addBox(player, message, type)
        end
    end,

}