-- Resource produzido e distribuido por Wave Resources
--
-- Nosso site: https://waveresources.com.br/
-- Nosso discord: https://discord.waveresources.com.br/

config = {
    ['gerais'] = {
        ['mensagem'] = true,
        ['color'] = {115, 200, 131},
        ['color:marker'] = {115, 200, 131, 90},
        ['data:emprego'] = 'Emprego',
        ['data:limpador'] = 'Limpador de rua',
        ['tempo:limpando'] = 5,
    },

    ['config'] = {
        {pos = {2690.00293, -1969.87561, 13.54688 -1}, spawn = {2685.56152, -1969.85046, 13.54688}, rotSpawn = {0, 0, 0}, idVeh = 574, nameVeh = 'Limpador de Ruas'}
    },

    ['points'] = {
        {2519.03, -1910.01, 13.38 -1},
        {2670.88, -1929.86, 13.3 -1},
        {2650.15, -2003.83, 13.38 -1},
        {2782.44, -1994.55, 13.38 -1},
        {2513.76, -2009.8, 13.3 -1},
        {2438.35, -1929.51, 13.33 -1},
        {2416.08, -1847.96, 13.38 -1},
        {2411.02, -2035.68, 13.35 -1},
        {2769.26, -1928.76, 13.37 -1},
        {2711.73, -2115.11, 10.9 -1},
    },

};

a1 = {
    [1] = "Veículo:",
    [2] = "Veículo",
    [3] = "Para pegar o veículo clique abaixo.",
    [4] = "Pegar veículo",
    [5] = "Você não trabalha nesse emprego!",
    [6] = "Você saiu do veiculo de trabalho e ele foi destruido!",
    [7] = "Veiculo criado com sucesso!",
    [8] = "",
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