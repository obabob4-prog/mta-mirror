local assinature = [[



                 ██████╗ █████╗ ██╗ ██████╗ 
                ██╔════╝██╔══██╗██║██╔═══██╗
                ██║     ███████║██║██║   ██║
                ██║     ██╔══██║██║██║   ██║
                ╚██████╗██║  ██║██║╚██████╔╝

                 ╚═════╝╚═╝  ╚═╝╚═╝ ╚═════╝



  https://caiodeveloper.com ou https://discord.gg/caiodev

           Sistema desenvolvido por Caio Developer


]]


vehiclesVIP = {
    [585] = {'Maça', 'Banana', 'Goiaba', 'Goiabão', 'Natal', 'estafe', 'Patrocinador', 'Policia'},
    [516] = {'Goiaba', 'Goiabão', 'Natal', 'estafe', 'Patrocinador', 'Policia'},
    [411] = {'Goiaba', 'Goiabão', 'Natal', 'estafe', 'Patrocinador'},
    [586] = {'Goiaba', 'Goiabão', 'Natal', 'estafe', 'Patrocinador'},
    [405] = {'Goiabão', 'Patrocinador'},
    [471] = {'Goiabão', 'Patrocinador'},
}

taxPercentage = 5;
taxDays = 7
storePercentage = 50; -- // Porcentagem que a loja paga ao vender o veiculo para a concessionaria

colorDetails = {89, 178, 104}

barcosID = {
    [472] = true,
    [473] = true,
    [453] = true,
    [595] = true,
    [484] = true,
    [452] = true,
    [446] = true,
    [493] = true,
    [454] = true,
}

vehicles = {
    [462] = {nome = 'XMAX', marca="yamaha", valor = 6000, cash = 1},    
    [461] = {nome = 'Fan 160', marca="honda", valor = 10000, cash = 1},
    [581] = {nome = 'XJ6', marca="yamaha", valor = 15000, cash = 2},
    [468] = {nome = 'XRE', marca="honda", valor = 30000, cash = 2},
    [521] = {nome = 'Tiger 800', marca="triumph", valor = 50000, cash = 3},
    [545] = {nome = 'Fusca', marca="volkswagen", valor = 10000, cash = 1},
    [436] = {nome = 'Voyage', marca="volkswagen", valor = 20000, cash = 2},
    [600] = {nome = 'Saveiro Surf', marca="volkswagen", valor = 35000, cash = 2},
    [542] = {nome = 'Gol GTI', marca="volkswagen", valor = 35000, cash = 2},
    [589] = {nome = 'Celta', marca="chevrolet", valor = 40000, cash = 2},
    [467] = {nome = 'Monza', marca="chevrolet", valor = 40000, cash = 2},
    [604] = {nome = 'Fox', marca="volkswagen", valor = 45000, cash = 3},
    [551] = {nome = 'Parati Surf', marca="volkswagen", valor = 50000, cash = 3},
    [579] = {nome = 'Santa Fé', marca="hyundai", valor = 60000, cash = 3},
    [479] = {nome = 'S10', marca="chevrolet", valor = 72000, cash = 4},
    [466] = {nome = 'Passat Variant', marca="volkswagen", valor = 75000, cash = 4},

    [540] = {nome = 'Polo', marca="volkswagen", valor = 75000, cash = 4},
    [529] = {nome = 'Focus', marca="ford", valor = 78000, cash = 4},
    [567] = {nome = 'Cruze Sedan', marca="chevrolet", valor = 80000, cash = 4},
    [566] = {nome = 'Jetta', marca="volkswagen", valor = 82000, cash = 4},
    [458] = {nome = 'Nivus', marca="volkswagen", valor = 100000, cash = 5}, 
    [445] = {nome = 'Taycan', marca="porsche", valor = 140000, cash = 7},
    [415] = {nome = 'GTR R35', marca="nissan", valor = 200000, cash = 10},
    [587] = {nome = 'Camaro', marca="chevrolet", valor = 215000, notImage = true, cash = 10},
    [402] = {nome = 'Supra Mk4', marca="toyota", valor = 250000, notImage = true, cash = 12},
    [404] = {nome = 'RS7', marca="audi", valor = 275000, cash = 12},
    [480] = {nome = 'Z4', marca="bmw", valor = 300000, cash = 13},
    [507] = {nome = 'X6', marca="bmw", valor = 345000, cash = 15},
    [410] = {nome = 'Huracan', marca="lamborghini", valor = 400000, notImage = true, cash = 15},
    [561] = {nome = 'Urus', marca="lamborghini", valor = 425000, cash = 16},
    [477] = {nome = 'R8', marca="audi", valor = 500000, cash = 18},
    [426] = {nome = 'Classe C', marca="mercedes", valor = 545000, cash = 20},
    [565] = {nome = 'Agera', marca="koenigsegg", valor = 625000, cash = 20},
    [603] = {nome = 'LaFerrari', marca="ferrari", valor = 750000, cash = 22},
    [536] = {nome = 'Supra A90', marca="toyota", valor = 1000000, notImage = true, cash = 25},
    [515] = {nome = '113h', marca="scania", valor = 120000, cash = 6},
    [514] = {nome = 'FH 750', marca="volvo", valor = 120000, cash = 6},

    [472] = {nome = 'Longfin', marca="goiaba", valor = 550000, cash = 20},
    [453] = {nome = 'Reefer', marca="goiaba", valor = 800000, cash = 23},
    [595] = {nome = 'Launch', marca="goiaba", valor = 1000000, cash = 25},
    [452] = {nome = 'Speeder', marca="goiaba", valor = 1200000, cash = 28},
    [446] = {nome = 'Seaking', marca="goiaba", valor = 14000000, cash = 50},
    [493] = {nome = 'Jetmax', marca="goiaba", valor = 16000000, cash = 50},
    [473] = {nome = 'Jetski', marca="goiaba", valor = 20000000, cash = 50},
    [484] = {nome = 'Barco-casa', marca="goiaba", valor = 25000000, cash = 50},
    [454] = {nome = 'Iate', marca="goiaba", valor = 100000000, cash = 100},

    -- Veículos com byPassTax
    [411] = {nome = '911', marca="porsche", valor = 8000000, byPassTax = true, cash = 40},
    [516] = {nome = 'Lancer Evolution', marca="mitsubishi", valor = 8000000, byPassTax = true, cash = 40},
    [586] = {nome = 'Tiger XC', marca="triumph", valor = 8000000, byPassTax = true, cash = 40},
    [471] = {nome = 'Carroça', marca="goiaba", valor = 10000, byPassTax = true, cash = 1},
    [405] = {nome = 'Golf GTI', marca="volkswagen", valor = 8000000, byPassTax = true, cash = 40},
    [585] = {nome = 'Sonata', marca="hyundai", valor = 8000000, byPassTax = true, cash = 40},
    [456] = {nome = 'Caminhão Baú', marca="goiaba", valor = 8000000, byPassTax = true, cash = 40},
    [522] = {nome = 'R1200', marca="bmw", valor = 8000000, byPassTax = true, cash = 40},
    [422] = {nome = 'Saveiro Paredão', marca="volkswagen", valor = 8000000, byPassTax = true, cash = 40},
    [546] = {nome = 'AMG GT 63', marca="mercedes", valor = 8000000, byPassTax = true, notImage = true, cash = 40},
    [559] = {nome = 'Skyline GTR R34', marca="nissan", valor = 8000000, byPassTax = true, notImage = true, cash = 40},
    [496] = {nome = '600LT', marca="mclaren", valor = 8000000, byPassTax = true, notImage = true, cash = 40},
    [431] = {nome = 'Ônibus', marca="goiaba", valor = 8000000, byPassTax = true, notImage = true, cash = 40},
    [409] = {nome = 'Limosine', marca="goiaba", valor = 8000000, byPassTax = true, notImage = true, cash = 40},
    [547] = {nome = 'RS6', marca="audi", valor = 10000000, byPassTax = true, notImage = true, cash = 45},
    [400] = {nome = 'X7', marca="bmw", valor = 12000000, byPassTax = true, cash = 50},
    [438] = {nome = 'G63', marca="mercedes", valor = 12000000, byPassTax = true, cash = 50},
    [602] = {nome = 'Rx7', marca="mazda", valor = 8000000, byPassTax = true, notImage = true, cash = 40},
    [463] = {nome = 'MonoWheel', marca="goiaba", valor = 8000000, byPassTax = true, notImage = true, cash = 40},
    [487] = {nome = 'Helicóptero', marca="goiaba", valor = 8000000, byPassTax = true, cash = 40},

    -- Adicionais
    [576] = {nome = 'R35 Clei' , marca="nissan", valor = 8000000, cash = 40},
    [492] = {nome = 'M8 Vilas' , marca="bmw", valor = 8000000, cash = 40},
    [541] = {nome = 'Lancer claze' , marca="nissan", valor = 8000000, cash = 40},
    [401] = {nome = 'M4 Vilas' , marca="bmw", valor = 8000000, cash = 40},
    [475] = {nome = 'R33 Alonsin' , marca="nissan", valor = 8000000, cash = 40},
}




garagemBlip = 46 -- blip da garagem

garagens = {
    {pos = {1159.6, -1383.88, 14.22-1}, spawn = {1154.68, -1380.02, 13.91+1, 0, 0, 196.71}},
    {pos = {2265.89, -1720.59, 13.56-1}, spawn = {2270.6, -1717, 13.56+1, 0, 0, 28.09}},
    {pos = {1572.07, -1718.49, 13.55-1}, spawn = {1580.3, -1720.14, 13.55+1, 0, 0, 180.45}},  --Garagem Dp
    {pos = {1876.84, -1744.87, 13.55-1}, spawn = {1870.41, -1737.17, 13.39+1, 0, 0, 268.58}},
    {pos = {2547.72, 747.64, 10.82-1}, spawn = {2553.23, 740.74, 10.82+1, 0, 0, 268.59}}, -- 
    {blipDisabled = true, pos = {2004.76, -1408.74, 16.99-1}, spawn = {2001.95, -1414.55, 16.99+1, 0, 0, 177.34}},
    {blipDisabled = true, pos = {2645.12, -1992.14, 13.55-1}, spawn = {2651.91, -1987.34, 13.55+1, 0, 0, 180.32}},
    {blipDisabled = true, pos = {-128.92, -1726.97, 3.83-1}, spawn = {-134.72, -1722.85, 3.78, 0, 0, 0.95}},
    {blipDisabled = true, pos = {1254.9, -1787.92, 13.43-1}, spawn = {1241.43, -1793.95, 13.43, 0, 0, 178.26}},
    {blipDisabled = true, pos = {590.88, -946.22, 81.33-1}, spawn = {588.33, -940.3, 81.33, 0, 0, 54.53}},
    {pos = {1062.27, -1733.41, 13.72-1}, spawn = {1069.35, -1737.36, 13.49+1, 0, 0, 267.63}}, 
    {pos = {1910.76, 703.06, 11.13-1}, spawn = {1909.42, 713.57, 10.82+1, 0, 0, 90.69}}, 
    {pos = {2529.82, 936.73, 10.82-1}, spawn = {2523.54, 931.52, 10.82+1, 0, 0, 87.62}}, 
    {pos = {2566.13, 2289.24, 11.06-1}, spawn = {2571.89, 2285.27, 10.82+1, 0, 0, 267.76}}, 
    {pos = {1516.81, 2786.02, 10.82-1}, spawn = {1519.51, 2795.04, 10.82+1, 0, 0, 2.34}}, 
    {pos = {1588.37, 1851.49, 10.82-1}, spawn = {1594.22, 1845.91, 10.82+1, 0, 0, 267.8}}, 
    {pos = {1639.84, 1286.6, 10.82-1}, spawn = {1651, 1292.19, 10.83+1, 0, 0, 269.69}}, 
    {pos = {-2622.46, -19.19, 4.34-1}, spawn = {-2618.86, -27.28, 4.34+1, 0, 0, 178.75}}, 
    {pos = {-2594.1, 661.85, 14.45-1}, spawn = {-2581.54, 654.42, 14.45+1, 0, 0, 178.91}},
    {pos = {-1639.28, 649.97, 7.19-1}, spawn = {-1629.93, 658.77, 7.19+1, 0, 0, 270.62}},
    {pos = {-2651.21, 1378.32, 7.19-1}, spawn = {-2638.44, 1378.5, 7.14+1, 0, 0, 269.65}},
    {pos = {-2271.66, 2285.16, 4.82-1}, spawn = {-2263.18, 2296.22, 4.82+1, 0, 0, 0.69}},
    {pos = {-198.85, 2595.28, 62.7-1}, spawn = {-205.16, 2603.1, 62.7+1, 0, 0, 88.78}},
    {pos = {-103.98, 1222.8, 19.74-1}, spawn = {-101.13, 1214.25, 19.74+1, 0, 0, 180.5}},
    {pos = {2557, 14, 27.08-1}, spawn = {2545.87, 11.96, 26.75+1, 0, 0, 87.42}},
    {pos = {709.63, -454.75, 16.34-1}, spawn = {701.66, -459.24, 16.34+1, 0, 0, 180.2}},
    {pos = {311.66, -1799.98, 4.52-1}, spawn = {311.57, -1809.1, 4.48+1, 0, 0, 0.98}},
    {blipDisabled = true, pos = {1273.12, -1430.94, 13.64-1}, spawn = {1273.12, -1430.94, 13.64+1, 0, 0, 358.52}},
    
    {type = 'barco', pos = {125.45, -1943.78, 3.13-1, 0, 0, 2.18}, spawn = {97.58, -1954.86, -0.55+1, 80, 100, 30.54},},
    {type = 'barco', pos = {112.49, -2094.24, 1.66-1, 0, 0, 2.18}, spawn = {112.41, -2115.34, 4.94, 0, 0, 94.41},},
    -- Favelas
    {blipDisabled = true, pos = {1270.97, -2051.35, 59.14-1}, spawn = {1274.81, -2053.94, 59.03, 0, 0, 85.76}},
    {blipDisabled = true, pos = {-162.59, -1123.96, 5.22-1}, spawn = {-160.65, -1118.04, 5.37+1, 0, 0, 281.33}},
    {blipDisabled = true, pos = {2801.79, -2361.68, 13.63-1}, spawn = {2763.34, -2362.92, 13.63}},
    {blipDisabled = true, pos = {1545.65, 982.5, 10.82-1}, spawn = {1551.76, 976.53, 10.82, 80, 80, 35.43}},
    {blipDisabled = true, pos = {1101.42, -2146.87, 68.6-1}, spawn = {1099.68, -2154.04, 68.5+1, 0, 0, 280.8}},
    {blipDisabled = true, pos = {2751.75, -577.76, 52.08-1}, spawn = {2755.67, -575.6, 51.93+1, 0, 0, 190.63}},
    {blipDisabled = true, pos = {2569.15, -973.62, 81.94-1}, spawn = {2563.33, -971.7, 82.47+1, 0, 0, 181.94}},
    {blipDisabled = true, pos = {1084.82, -331.58, 73.99-1}, spawn = {1083.51, -338.13, 73.99+1, 0, 0, 87.26}},
    {blipDisabled = true, pos = {2403.97, -643.11, 127.03-1}, spawn = {2400.27, -638.03, 126.48+1, 0, 0, 349.96}},
    {blipDisabled = true, pos = {652.69, -1119.79, 44.41-1}, spawn = {658.76, -1118.38, 44.42+1, 0, 0, 46.96}},
    {blipDisabled = true, pos = {1777.18, -1936.13, 13.55-1}, spawn = {1781.48, -1936.32, 13.55+1, 0, 0, 359.95}},
    {blipDisabled = true, pos = {-27.49, -1196.5, 6.1-1}, spawn = {-24.01, -1198.05, 6.15+1, 0, 0, 143.52}},
    {blipDisabled = true, pos = {1007.95, -10.94, 92.9-1}, spawn = {1007.46, -5.89, 92.12+1, 0, 0, 279.82}},
    {blipDisabled = true, pos = {2514.64, -2013.46, 13.28-1}, spawn = {2498.86, -2022.72, 13.55, 0, 0, 97.81}},
    --{blipDisabled = true, pos = {1857.28, 166.23, 33.4-1}, spawn = {1858.32, 170.44, 32.6+1, 0, 0, 52.93}},
}

concessionariaBlip = 55 -- blip da concessionaria

concessionarias = {

    --LS

    {

        x = 1294.39, y = -1429.3, z = 13.58 - 1,

        spawn = {1263.27, -1418.38, 13.63, 269.5}, -- Coloque aqui o spawn do veículo quando comprado.

        vehicles = { -- Configure aqui os id de veículo que serão vendidos nessa loja.

        462, 461, 581, 468, 521, 545, 436, 600, 542, 589, 467, 604, 551, 579, 479, 466, 540, 529, 567, 566, 458, 445, 415, 587, 402, 404, 480, 507, 410, 561, 477, 426, 565, 603, 536, 515, 514

        },

    },

    -- LV

    {

        x = 2131.765, y = 1414.442, z = 10.955 - 1,  -- Coloque aqui a posição do marker da loja.

        spawn = {2128.586, 1424.346, 10.82, 268.48}, -- Coloque aqui o spawn do veículo quando comprado.

        vehicles = { -- Configure aqui os id de veículo que serão vendidos nessa loja.

        462, 461, 581, 468, 521, 545, 436, 600, 542, 589, 467, 604, 551, 579, 479, 466, 540, 529, 567, 566, 458, 445, 415, 587, 402, 404, 480, 507, 410, 561, 477, 426, 565, 603, 536, 515, 514

        },

    },

    -- SF

    {

        x = -1958.731, y = 258.759, z = 35.469 - 1,  -- Coloque aqui a posição do marker da loja.

        spawn = {-1936.102, 274.346, 41.047, 178.782}, -- Coloque aqui o spawn do veículo quando comprado.

        vehicles = { -- Configure aqui os id de veículo que serão vendidos nessa loja.

        462, 461, 581, 468, 521, 545, 436, 600, 542, 589, 467, 604, 551, 579, 479, 466, 540, 529, 567, 566, 458, 445, 415, 587, 402, 404, 480, 507, 410, 561, 477, 426, 565, 603, 536, 515, 514

        },

    },

    -- Barcos

    {

        barco = true,

        x = 811.55, y = -1848.62, z = 8.41 - 1,

        spawn = {807.13, -1907.45, -0.54, 178.31}, -- Coloque aqui o spawn do veículo quando comprado.

        vehicles = { -- Configure aqui os id de veículo que serão vendidos nessa loja.

        472,473,453,595,484,452,446,493,454

        },

    },

}




detranBlip = 24

detran = {

    {

        x = 1792.88, y = -1560.73, z = 14.1 - 1,

    },

    {

        x = 1291.65, y = -1443.98, z = 13.58 - 1,

    }

}



detranPrices = {

    ['emplacar'] = 2743, -- valor para realizar emplacamento do veículo.

    ['rastreador'] = 2676, -- valor para colocar rastreador no veículo.

    ['seguro'] = 6000, -- valor para colocar seguro no veículo.

}

vipsDiscount = {

}

slots = { -- Coloque aqui a quantidade de veículos  jogador pode ter.

    { group = 'Console', limit = 99 },

    { group = 'Patrocinador', limit = 30},

    { group = 'Goiabão', limit = 20 },

    { group = 'Goiaba', limit = 14 },

    { group = 'Banana', limit = 7 },

    { group = 'Maça', limit = 7 },

    { group = 'Everyone', limit = 5 },

}



others = {



    vehicleDestroyInExit = true, -- Deixe true para os veículos desaprecer quando o jogador sair do servidor

    permissionEstoque = 'Console', -- Coloque aqui a acl que pode alterar estoque. /setestoque [model] [quantidade]

    

    ['hudState'] = function (state)

        showChat(state)

        setElementData(localPlayer, 'bloqInterface', not state)

    end,



    ['Cash'] = function (type, element, value) -- Configure aqui o seu sistema de cash

        if type == 'get' then

            return (getElementData(element, 'Cash') or 0)

        elseif type == 'take' then

            local ammount = (getElementData(element, 'Cash') or 0)

            setElementData(element, 'Cash', ammount - value)

            return true

        end

    end,



    ['createMarker'] = function (x, y, z)

        return createMarker(x, y, z, 'cylinder', 1.5, 115, 200, 131, 0)

    end,



    ['getAccountName'] = function (element) -- Caso você utilize algum tipo de conta sem ser padrão do jogo mude aqui.

        return getAccountName(getPlayerAccount(element))

    end,



    ['notify'] = function (src, player, mensagem, type) -- Configure a infobox do seu servidor.
        if src == 'server' then
            exports['goiaba_infobox']:addBox(player, mensagem, type)
        elseif src == 'client' then
            exports['goiaba_infobox']:addBox(mensagem, type)
        end
    end,



    ['getInfosSaveVehicle'] = function (vehicle) -- Configure aqui o salvamento de dados do veículo.

        if vehicle then

            dados_veh = { 

                vida = getElementHealth(vehicle), 

                tunagem = getVehicleUpgrades(vehicle), 

                color = {getVehicleColor(vehicle, true)}, 

                light = {getVehicleHeadLightColor(vehicle)}, 

                gasolina = (getElementData(vehicle, 'veh:fuel') or 100),

                placa = getVehiclePlateText(vehicle),

                state_farol = {

                    [0] = getVehicleLightState(vehicle, 0), 

                    [1] = getVehicleLightState(vehicle, 1), 

                    [2] = getVehicleLightState(vehicle, 2), 

                    [3] = getVehicleLightState(vehicle, 3)

                },

                state_rodas = {getVehicleWheelStates(vehicle)},

                state_portas = {

                    [0] = getVehicleDoorState(vehicle, 0),

                    [1] = getVehicleDoorState(vehicle, 1),

                    [2] = getVehicleDoorState(vehicle, 2),

                    [3] = getVehicleDoorState(vehicle, 3),

                    [4] = getVehicleDoorState(vehicle, 4),

                    [5] = getVehicleDoorState(vehicle, 5)

                },

                tunningnew = {

                    ['tunning.Motor'] = getElementData(vehicle, 'tunning.Motor') or false,

                    ['tunning.Turbo'] = getElementData(vehicle, 'tunning.Turbo') or false,

                    ['tunning.Pneu'] = getElementData(vehicle, 'tunning.Pneu') or false,

                    ['tunning.Freios'] = getElementData(vehicle, 'tunning.Freios') or false,

                    ['tunning.Suspensão'] = getElementData(vehicle, 'tunning.Suspensão') or false,

                    ['tunning.Peso'] = getElementData(vehicle, 'tunning.Peso') or false,

                    ['tunning.Roda'] = getElementData(vehicle, 'tunning.Roda') or false,

                    ['tunning.Tração'] = getElementData(vehicle, 'tunning.Tração') or false,

                    ['tunning.Porta'] = getElementData(vehicle, 'tunning.Porta') or false,

                    ['tunning.Pintura'] = getElementData(vehicle, 'tunning.Pintura') or false,

                    ['tunning.Upgrades'] = getElementData(vehicle, 'tunning.Upgrades') or false,

                    ['tuning.lsdDoor'] = getElementData(vehicle, 'tuning.lsdDoor') or false,

                    ['tunning.lsdDoor'] = getElementData(vehicle, 'tunning.lsdDoor') or false,

                    ['TUNNED_VEHICLE'] = getElementData(vehicle, 'TUNNED_VEHICLE') or false,

                },

                variants = {getVehicleVariant(vehicle)},

            }

            return dados_veh

        end

    end,



    ['setVehicleInfos'] = function (vehicle, dados_veh) -- Configure aqui os dados do veículo.

        if vehicle then

            if dados_veh.vida < 300 then

                dados_veh.vida = 300

            end

            setVehiclePlateText(vehicle, dados_veh.placa)

            setVehicleColor(vehicle, unpack(dados_veh.color))

            setVehicleHeadLightColor(vehicle, unpack(dados_veh.light))

            setElementData(vehicle, 'veh:fuel', tonumber(dados_veh.gasolina))

            if dados_veh.tunagem then

                for _, upgrades in ipairs(dados_veh.tunagem) do

                    addVehicleUpgrade(vehicle, tonumber(upgrades))

                end

            end

            if dados_veh.state_farol then

                for light, value in pairs(dados_veh.state_farol) do

                    setVehicleLightState(vehicle, light, value)

                end

            end

            if dados_veh.state_portas then

                for door, value in pairs(dados_veh.state_portas) do

                    setVehicleDoorState(vehicle, door, value)

                end

            end

            if dados_veh.state_rodas and dados_veh.state_rodas[1] and dados_veh.state_rodas[2] and dados_veh.state_rodas[3] and dados_veh.state_rodas[4] then

                local frontLeft, rearLeft, frontRight, rearRight = dados_veh.state_rodas[1], dados_veh.state_rodas[2], dados_veh.state_rodas[3], dados_veh.state_rodas[4]

                setVehicleWheelStates(vehicle, frontLeft, rearLeft, frontRight, rearRight)

            end

            if dados_veh.tunningnew and type(dados_veh.tunningnew) == 'table' then

                for tunning, value in pairs(dados_veh.tunningnew) do

                    if value ~= false then

                        setElementData(vehicle, tunning, value)

                    end

                end

            end

            if dados_veh.variants then

                setVehicleVariant(vehicle, dados_veh.variants[1], dados_veh.variants[2])

            else

                setVehicleVariant(vehicle, 5, 5)

            end

        end

    end,



}



function getVehiclePrice(model)

    model = tonumber(model)

    return vehicles[model].valor

end



function getVehicleName(model)

    model = tonumber(model)

    return vehicles[model].nome

end