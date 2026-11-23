config = {

    ['general'] = {
        distance = 6, --| Distancia maxima para indentificação do elemento.
        attachName = 'pattach', --| Nome do resource do pattach.
    },

    ['binds'] = {
        toggle = "lalt", --| Tecla para alterar o estado de visibilidade do interaction.
        cancel = "F6" --| Tecla para cancelar qualquer ação com outro jogador ( Carregar, etc... )
    },

    ['functions'] = {

        --| Padrão:
        --| Nome da função, nome da função que será chamada, elemento que será atribuido a função, acl que será usada, ícone ( 45x45 ).

        --{ name = "Enviar dinheiro", func = 'send money', element = "player", acl = "Everyone", data = false, image = 'money.png' },
        --{ name = "Propor troca", func = 'trocaitens', element = "player", acl = "Everyone", data = false, image = 'hood.png' },
        { name = "Beijar", func = 'kiss', element = "player", acl = "Everyone", data = false, image = 'kiss.png' },
        { name = {"Agarrar", "Soltar"}, func = 'grab', element = "player", acl = "Everyone", data = false, image = 'carry.png' },
        --{ name = {"Algemar", "Desalgemar"}, func = 'cuff', element = "player", acl = "Everyone", data = false, image = 'cuff.png' },
        { name = {"Colocar capuz", "Retirar capuz"}, func = 'hood', element = "player", acl = "Everyone", data = false, image = 'hood.png' },
        { name = 'Revistar', func = 'revistar', element = "player", acl = "Everyone", data = false, image = 'hood.png' },
        { name = 'Reanimar', func = 'revive', element = "player", acl = "samu", data = false, service = 'service.paramedico', image = 'medic.png' },
        { name = 'Reanimar', func = 'revive', element = "player", acl = "bombeiros", data = false, service = 'service.paramedico', image = 'medic.png' },
        { name = 'Verificar RG', func = 'showRG', element = "player", acl = "policia", data = false, service = 'service.police', image = 'lupa.png' },
        { name = 'Verificar CNH', func = 'showCNH', element = "player", acl = "policia", data = false, service = 'service.police', image = 'lupa.png' },
        { name = 'Verificar Porte', func = 'showPorte', element = "player", acl = "policia", data = false, service = 'service.police', image = 'lupa.png' },

        { name = "Colocar no Porta-malas", func = 'put trunk', element = "vehicle", vehtype = 'Automobile', acl = "Everyone", data = false, image = 'vehicle.png' },
        { name = 'Abrir Porta-malas', func = 'open trunk', element = "vehicle", acl = "Everyone", data = false, image = 'chest.png' },
        { name = "Checar Porta-malas", func = 'check trunk', element = "vehicle", vehtype = 'Automobile', acl = "Everyone", data = false, image = 'lupa.png' },
        { name = {"Trancar", "Destrancar"}, func = 'lock vehicle', element = "vehicle", acl = "Everyone", data = false, image = 'lock.png' },
        { name = "Entrar na mala", func = 'enter trunk', element = "vehicle", vehtype = 'Automobile', acl = "Everyone", data = false, image = 'chest.png' },

        { name = "Acessar baú", func = 'chest open', element = "object", modelid = 964, acl = "Everyone", data = false, image = 'chest.png' },
        
        { name = "Acessar banco", func = 'bank open', element = "object", modelid = 2942, acl = "Everyone", data = false, image = 'bank.png' },
        { name = "Roubar", func = 'roube bank', element = "object", modelid = 2942, acl = "Everyone", data = false, image = 'robber.png' },

        { name = "Oferecer drogas", func = 'drug', element = "ped", acl = "Everyone", data = 'ID_NPC_DESKCODES', image = 'robber.png' },

        { name = 'Iniciar trabalho', func = 'startJob:container', element = 'ped', acl = 'Everyone', data = 'PED_Container', image = 'job.png'},
        { name = 'Iniciar trabalho', func = 'startJob:caminhoneiro', element = 'ped', acl = 'Everyone', data = 'PED_Caminhoneiro', image = 'job.png'},
        { name = 'Paintball', func = 'paintball', element = 'ped', acl = 'Everyone', data = 'PED_Paintball', image = 'gun.png'},

        { name = 'Conversar', func = 'dialog', element = 'ped', acl = 'Everyone', data = 'npc:dialog', image = 'ped.png'},

        { name = "Deitar", func = 'iniciar trat', element = "object", modelid = 1997, acl = "Everyone", data = 'MACA_TRATAMENTO', image = 'medic.png' },
        { name = "Tratamento", func = 'iniciar trat2', element = "object", modelid = 1997, acl = "Everyone", data = 'MACA_TRATAMENTO_', image = 'hood.png' },
        { name = "Tratar Paciente", func = 'trat', element = "object", modelid = 1997, acl = "samu", data = 'MACA_TRATAMENTO', image = 'medic.png' },

        { name = "Acessar Armamentos", func = 'weapon police', element = "object", modelid = 1775, acl = "Everyone", data = false, image = 'robber.png' },
        
        { name = "Acessar Farmácia", func = 'farmacy', element = "ped", acl = "Everyone", data = 'hp:npc', image = 'medic.png' },
    },

    ['blockers'] = {

        ['commands'] = {'a', 'assaltar'}, --| Comandos a serem bloqueados quando o jogador está algemado.
        ['binds'] = {
            ['b'] = true, --| Teclas a serem bloqueadas quando o jogador está algemado.
            ['c'] = true, --| Teclas a serem bloqueadas quando o jogador está algemado.
        },

    },

    ['vehNames'] = {
        [462] = 'Honda Biz',
        [461] = 'Honda Fan 160',
        [468] = 'Yamaha DT200',
        [581] = 'Yamaha XJ6',
        [521] = 'Honda XRE',
        [545] = 'Fusca',
        [600] = 'Saveiro Surf',
        [436] = 'Voyage',
        [542] = 'Gol GTI',
        [580] = 'Uno Mille',
        [566] = 'Corsa Classic',
        [589] = 'Celta',
        [466] = 'Punto',
        [495] = 'Gol',
        [535] = 'Saveiro Cross',
        [467] = 'Monza',
        [604] = 'Fox',
        [551] = 'Parati Surf',
        [540] = 'I30',
        [400] = 'Captiva',
        [579] = 'Santa Fé',
        [507] = 'Cruze LTZ',
        [554] = 'Raptor',
        [479] = 'S10',
        [529] = 'Focus',
        [445] = 'Classic FIXA',
        [567] = 'Cruze Sedan',
        [550] = 'Corolla',
        [421] = 'Civic',
        [562] = 'BMW M1',
        [561] = 'BMW X7',
        [420] = 'Fiat Toro',
        [415] = 'GTR R35',
        [587] = 'Camaro',
        [404] = 'Audi RS7',
        [410] = 'Lamborghini Huracan',

        [585] = 'Sonata',
        [516] = 'Lancer Evolution',
        [411] = 'Porsche 911',
        [471] = 'Quadriciclo',
        [405] = 'Golf GTI',
        [586] = 'Triumph XC',

        [456] = 'Caminhão Baú',
        [522] = 'BMW R1200',
        [541] = 'Bugatti Nero',
        [422] = 'Saveiro Paredão',
        [503] = 'Phantom',
        [477] = 'Audi R8',
        [547] = 'Audi RS6',
        [426] = 'Mercedes',
        [546] = 'Peugeot 208',
        [559] = 'GTR R34',
        [565] = 'Porsche Cayman',
        [438] = 'Mercedes G63',
        [603] = 'Ferrari',
        [431] = 'Ônibus',

        [596] = "Corola Cross",
        [597] = "L200",
        [598] = "Trailblazer",
        [470] = "S10",
        [523] = "Rocam",
        [497] = "Águia",

        [416] = "Ambulância",
        [525] = "Guincho MEC",
        [443] = "Guincho PRF",
        [427] = "Blindado PF",

        [489] = "Range Rover",
        [489] = "Ferrari",
        [489] = "Ferrari",
        [575] = "Toyota Supra",
        [402] = "Trash",
        [496] = "GTR R35 Tuning",
        [490] = "BMW M3 G20",
        [527] = "Silvia",
        [555] = "AMG GTR",
        [506] = "Carro gabrieldiad",
    },

    ['request'] = {

        responseTime = 15, --| Tempo limite para responder uma proposta.

        ['binds'] = {
            accept = 'e', --| Tecla para aceitar uma proposta.
            decline = 'q', --| Tecla para negar uma proposta.
        },

        ['positions'] = {
            x = 20,
            y = 0,
        },

    },

    ['interface'] = {

        maxActions = 4, --| Quantidade máxima de ações que serão exibidas.

        ['design'] = {
            bgColor = {25, 27, 29}, --| Cor de fundo do interaction.
            themeColor = {2, 250, 83}, --| Cor principal do interaction.
            textColor = {255, 255, 255}, --| Cor do texto do interaction.
        },

    },

}

notify = {
    ['client'] = function(message, style)
        return triggerEvent('addBox', localPlayer, message, style)
    end,
    ['server'] = function(element, message, style)
        return triggerClientEvent(element, 'addBox', resourceRoot, message, style)
    end,
}