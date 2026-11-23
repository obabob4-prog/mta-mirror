config = {



    key = {

        fome = 'hunger',

        sede = 'sede',

        fuel = 'veh:fuel',

        sono = "AirNew:Sono"

    },



  acl = {
    ['noclip'] = {'Support', 'Administrativo', 'Staff', 'Head Staff', 'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['teleport'] = {'Support', 'Administrativo', 'Staff', 'Head Staff', 'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['pull'] = {'Support', 'Administrativo', 'Staff', 'Head Staff', 'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['gv'] = {'Administrativo', 'Staff', 'Head Staff', 'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['heart'] = {'Staff', 'Head Staff', 'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['skin'] = {'Head Staff', 'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['destroy'] = {'Staff', 'Head Staff', 'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['repair'] = {'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['destroyprox'] = {'Support', 'Administrativo', 'Staff', 'Head Staff', 'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['armor'] = {'Coordinator', 'Diretor', 'Console'},
    ['travar'] = {'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['holdelement'] = {'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['cv'] = {'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['setfome'] = {'Diretor', 'Console'},
    ['setsono'] = {'Diretor', 'Console'},
    ['fixprox'] = {'Head Staff', 'Manager', 'Coordinator', 'Diretor', 'Console'},
    ['blindar'] = {'Diretor', 'Console'},
    ['fuel'] = {'Diretor', 'Console'},
    ['kick'] = {'Diretor', 'Console'},
    ['pro'] = {'Manager', 'Diretor', 'Console'},
},

    commands = {
        ['teleport'] = 'tp', -- Dar tp (argumentos: ID)
        ['pull'] = 'puxar', -- Puxar jogador (argumentos: ID)
        ['repair'] = 'fix', -- Concertar vehicle (argumentos: ID (caso não insira, repara o seu veículo.))
        ['blindar'] = 'blindar',-- Blinde um veículo
        ['skin'] = 'ss', -- Setar skin (argumentos: ID, Model (caso não insira model, o argumento id virará uma model e será setada em você.))
        ['destroy'] = 'dv', -- Destruir veículo (argumentos: ID (caso não insira, destruirá o seu veículo.))
        ['destroyprox'] = 'dvproximo', -- Destruir veículo proximo
        ['fixprox'] = 'fixproximo', -- Destruir veículo proximo
        ['setfome'] = 'setfome', -- Setar fome / colete (argumentos: ID (caso não insira, será o seu.))
        ['setsono'] = 'setsono', -- Setar sono (argumentos: ID (caso não insira, será o seu.))
        ['heart'] = 'setvida', -- Setar vida (argumentos: ID (caso não insira, será o seu.))
        ['armor'] = 'setcolete', -- Setar colete (argumentos: ID (caso não insira, será o seu.))
        ['fuel'] = 'setgas', -- Setar gasolina (argumentos: ID (caso não insira, será o seu.))
        ['kick'] = 'expulsar', -- Expulsar jogador (argumentos: ID)
        ['gv'] = 'gv', -- Grudar veículo
        ['travar'] = 'travar', -- travar/destravar player (argumentos: ID)
        ['holdelement'] = 'segurar', -- Agarra o jogador (argumentos: ID)
        ['noclip'] = 'nc', -- Noclip
        ['pro'] = 'staff', -- inicia modo staff
        ['cv'] = 'cv' -- Cria um carro
    },

    wings = {
        ["Support"] = {6,22},
        ["Support"] = {5,21},
        ["Support"] = {4,1},
        ["Support"] = {3,11},
        ["Support"] = {2,12},
        ["Support"] = {1,5},
    },



    notify = function (src, player, message, type)

        if src == 'client' then -- Coloque aqui o exports client-side

            exports.goiaba_infobox:addBox(message, type)

        elseif src == 'server' then -- Coloque aqui o exports server-side

            exports.goiaba_infobox:addBox(player, message, type)

        end

    end



}