config = {

    ['general'] = {
        ['loseDie'] = true,
    },

    ['binds'] = {
        ['toggle'] = "b", --| Tecla de alternancia de visibilidade da mochila.
    },

    ['default'] = {
        ['itemSize'] = 40,
		['weight'] = {
			["default"] = 10,
			["maca"] = 50,
			["banana"] = 70,
			["morango"] = 100,
			["goiaba"] = 120,
			["goiabao"] = 150,
            ["Policia"] = 150,
            ["Natal"] = 150,
            ["estafe"] = 150,
            ["Patrocinador"] = 250,
			["console"] = 500
		},
    },

    ['elements'] = {
        ["thirst"] = "sede", --| elementData da sede do servidor.
        ["hunger"] = "hunger", --| elementData da fome do servidor.
    },

    ['commands'] = {
        ["allowedACLs"] = {"Console", "Diretor"}, --| ACL's permitidas a utilizar os comandos de risco.
        ["giveItem"] = "giveitem", --| Comando para dar item a algum jogador ( /giveitem <id> <item> <quantidade> )
        ["takeItem"] = "takeitem", --| Comando para retirar o item de algum jogador ( /takeitem <id> <item> <quantidade> )
        ["resetInventory"] = "resetinv", --| Comando para resetar o inventario de um jogador ( /resetinv <id> )
        ["keepWeapons"] = "garma", --| Comando para guardar uma arma equipada ( Segurar a arma na mão )
        ["createChest"] = "cchest", --| Comando para criar um baú na sua posição atual ( /cchest <peso> ).
        ["deleteChest"] = "dchest", --| Comando para deletar o baú mais proximo a você ( /dchest ).
        ["inspectPlayer"] = "revistar", --| Comando para revistar um jogador próximo a você.
        ["lootPlayer"] = "saquear", --| Comando para saquear um jogador próximo a você.
    },

    ['trashs'] = {
        -- {732.76, -1343.81, 13.52-0.3, 0, 0, 0};
        -- {2037.57, -1402.42, 17.31-0.3, 0, 0, 0};
        -- {2235.42, -1664.1, 15.44-0.3, 0, 0, 0};
        -- {2244.65, -1982.31, 13.55-0.3, 0, 0, 0};
        -- {2185.31, -1974.67, 13.55-0.3, 0, 0, 0};
        -- {1928.58, -1766.93, 13.55-0.3, 0, 0, 0};
        -- {1672.82, -1883.34, 13.55-0.3, 0, 0, 0};
        -- {1617.2, -1861.3, 13.55-0.3, 0, 0, 0};
        -- {1113.36, -1840.17, 13.59-0.3, 0, 0, 0};
        -- {997.18, -1820.12, 13.83-0.3, 0, 0, 0};
        -- {610.29, -1489.61, 14.79-0.3, 0, 0, 0};
        -- {1305.5, -1368.24, 13.54-0.3, 0, 0, 0};
        -- {1260.73, -1415.79, 13.61-0.3, 0, 0, 0};
        -- {1545.65, -1772.64, 13.55-0.3, 0, 0, 0};
        -- {1554.21, -1673.5, 16.2-0.3, 0, 0, 0};
        -- {1607.08, -1603.51, 13.54-0.3, 0, 0, 0};
        -- {1610.09, -1451.81, 13.55-0.3, 0, 0, 0};
        -- {2633.36, -1433.42, 30.48-0.3, 0, 0, 0};
        -- {2419.38, -1470.33, 23.98-0.3, 0, 0, 0};
        -- {2171.66, -1504.83, 23.95-0.3, 0, 0, 0};
        -- {2106.11, -1790.49, 13.55-0.3, 0, 0, 0};
        -- {435.22, -1732.96, 9.42-0.3, 0, 0, 0};
        -- {1331.75, -1231.51, 13.55-0.3, 0, 0, 0};
        -- {1388.66, -956.67, 34.51-0.3, 0, 0, 0};
        -- {2796.71, -1078.57, 30.72-0.3, 0, 0, 0};
        -- {344.93, -1635.15, 33.29-0.3, 0, 0, 0};
        -- {1194.8, -916.6, 43.16-0.3, 0, 0, 0};
        -- {2260.15, -1029.4, 52.75-0.3, 0, 0, 0};
        -- {1972.17, -2175.82, 13.54-0.3, 0, 0, 0};
        -- {1098.48, -1370.04, 13.99-0.1, 0, 0, 0};
        -- {1542.66, -1643.38, 13.98-0.3, 0, 0, 0};
        -- {1248, -1561.44, 13.55-0.3, 0, 0, 0};
        -- {1704.13, -1140.35, 24.09-0.3, 0, 0, 0};
        -- {1722.02, -1613.39, 13.55-0.3, 0, 0, 0};
        -- {1862.33, -1330.45, 13.55-0.3, 0, 0, 0};
        -- {-75.65, -1188.98, 1.75-0.3, 0, 0, 0};
        -- {465.54, -1283.19, 15.43-0.3, 0, 0, 0};
        -- {1305.34, -865.43, 39.58-0.3, 0, 0, 0};
        -- {1276.37, -1786.85, 13.61-0.3, 0, 0, 0};
        -- {1134.76, -1765.23, 13.6-0.3, 0, 0, 0};
        -- {832.95, -1990.3, 12.87-0.3, 0, 0, 0};
        -- {823.17, -2050.4, 12.87-0.3, 0, 0, 0};
        -- {150.47, -1946.17, 3.77-0.3, 0, 0, 0};
        -- {1206.23, -918, 43.08-0.3, 0, 0, 0};
        -- {2991.44, -1173.71, 11.21-0.3, 0, 0, 0};
        -- {3049.99, -1138.77, 11.21-0.3, 0, 0, 0};
        -- -- Favelas
        -- {-151.9, -1185.71, 6.4-0.3, 0, 0, 0};
        -- {1071.06, -2134.78, 68.7-0.3, 0, 0, 0};
        -- {2777.14, -536.89, 53-0.3, 0, 0, 0};
        -- {2547.23, -945.99, 83.1-0.3, 0, 0, 0};
        -- {1101.23, -359.84, 74-0.3, 0, 0, 0};
        -- {2342.5, -661.33, 130.6-0.3, 0, 0, 0};
        -- {-644.5, -588.32, 30.7-0.3, 0, 0, 0};
    };



    ['trunk'] = {
        ["vehicles"] = {
            [545] = {nome = 'VolksWagen Fusca', weight = 25},
            [436] = {nome = 'VolksWagen Voyage', weight = 25},
            [600] = {nome = 'VolksWagen Saveiro Surf', weight = 25},
            [542] = {nome = 'VolksWagen Gol GTI', weight = 25},
            [580] = {nome = 'Fiat Uno Mille', weight = 25},
            [589] = {nome = 'Chevrolet Celta', weight = 25},
            [495] = {nome = 'VolksWagen Gol', weight = 50},
            [535] = {nome = 'VolksWagen Saveiro Cross', weight = 50},
            [467] = {nome = 'Chevrolet Monza', weight = 50},
            [604] = {nome = 'VolksWagen Fox', weight = 50},
            [551] = {nome = 'VolksWagen Parati Surf', weight = 50},
            [540] = {nome = 'Hyundai I30', weight = 50},
            [579] = {nome = 'Hyundai Santa Fé', weight = 75},
            [554] = {nome = 'Ford Raptor', weight = 75},
            [479] = {nome = 'Chevrolet S10', weight = 75},
            [466] = {nome = 'VW Passat Variant', weight = 75},
            [490] = {nome = 'VW Polo', weight = 75},
            [529] = {nome = 'Ford Focus', weight = 75},
            [567] = {nome = 'Chevrolet Cruze Sedan', weight = 100},
            [550] = {nome = 'Toyota Corolla', weight = 100},
            [421] = {nome = 'Honda Civic', weight = 100},
            [566] = {nome = 'VW Jetta', weight = 100},
            [562] = {nome = 'Porsche Cayman', weight = 100},
            [507] = {nome = 'BMW X6', weight = 125},
            [420] = {nome = 'Fiat Toro', weight = 125}, 
            [458] = {nome = 'Nivus', weight = 125}, 
            [445] = {nome = 'Porsche Taycan', weight = 100},
            [415] = {nome = 'Nissan GTR R35', weight = 125},
            [587] = {nome = 'Chevrolet Camaro', weight = 125},
            [404] = {nome = 'Audi RS7', weight = 125},
            [480] = {nome = 'BMW Z4', weight = 125},
            [410] = {nome = 'Lamborghini Huracan', weight = 150},
            [561] = {nome = 'Lamborghini Urus', weight = 200},
            [536] = {nome = 'Supra A90', weight = 200},
            [496] = {nome = 'McLaren 600LT', weight = 200},
            [426] = {nome = 'Mercedes Classe C', weight = 200},
            [561] = {nome = 'Lamborghini Urus', weight = 200},
            [515] = {nome = 'VW Constellation 19.320', weight = 40},
            [514] = {nome = 'Volvo FH 750', weight = 40},
            -- VIP
            [411] = {nome = 'Porsche 911', weight = 500},
            [516] = {nome = 'Mitsubishi Lancer Evolution', weight = 500},
            [586] = {nome = 'Tiger Triumph XC', weight = 500},
            [471] = {nome = 'Carroça', weight = 500},
            [405] = {nome = 'VolksWagen Golf GTI', weight = 500},
            [585] = {nome = 'Hyundai Sonata', weight = 500},
            -- F2
            [456] = {nome = 'Caminhão Baú', weight = 20000},
            [522] = {nome = 'BMW R1200', weight = 500},
            [541] = {nome = 'Bugatti Nero', weight = 500},
            [422] = {nome = 'Saveiro Paredão', weight = 500},
            [503] = {nome = 'Rolls Royce Phantom', weight = 500},
            [477] = {nome = 'Audi R8', weight = 500},
            [547] = {nome = 'Audi RS6', weight = 500},
            [546] = {nome = 'Mercedes AMG GT63', weight = 500},
            [559] = {nome = 'Nissan Skyline GTR R34', weight = 500},
            [565] = {nome = 'Koenisegg Agera', weight = 500},
            [603] = {nome = 'LaFerrari', weight = 500},
            [438] = {nome = 'Mercedes G63 Blindada', weight = 500},
            [400] = {nome = 'BMW X7', weight = 500},
            [487] = {nome = 'Swift Deluxe', weight = 500},
            [602] = {nome = 'Mazda Rx7', weight = 500},
            [431] = {nome = 'Ônibus', weight = 500},
            [409] = {nome = 'Limosine', weight = 500},
            -- Privados
            [576] = {nome = 'R35 Clei', weight = 500},
            [492] = {nome = 'M8 Vilas', weight = 500},
            [475] = {nome = 'R33 Alonsin', weight = 500},
        },
    },

    ['weights'] = {
		[1] = 20, 
		[2] = 30, 
		[3] = 50,
    },

    ['weapons'] = {
        --| Ao adicionar uma nova arma no inventario, não esqueça de também colocar aqui seguindo o padrão. |--
        [31] = {item = 5, ammo = 13},
        [30] = {item = 6, ammo = 13},
        [29] = {item = 7, ammo = 16},
        [22] = {item = 8, ammo = 15},
        [32] = {item = 9, ammo = 16},
        [23] = {item = 10, ammo = 15},
        [34] = {item = 11, ammo = 14},
    },

    protectItens = {
        [78] = true;
        [79] = true;
        [80] = true;
        [81] = true;
        [82] = true;
        [83] = true;
        [92] = true;
        [93] = true;
        [94] = true;
        [95] = true;
        [96] = true;
        [111] = true;
    };

    ammosProtection = {
        [31] = {item = 78, ammo = 81};
        [29] = {item = 79, ammo = 83};
        [22] = {item = 80, ammo = 82};
        [23] = {item = 93, ammo = 82};
        [32] = {item = 94, ammo = 83};
        [30] = {item = 95, ammo = 81};
        [34] = {item = 96, ammo = 92};
        [32] = {item = 111, ammo = 83};
    };


    positionMask = {
        ["Diabo"] = {1512, 1, 0, -0, -0.61, 0, 0, 90},
        ["Anonymous"] = {1455, 1, 0, 0.04, -0.56, 0, 0, 90},
        ["Jedi"] = {1484, 1, 0, 0.02, -0.61, 0, 0, 90},
        ["Macaco"] = {1485, 1, 0, 0.-0.02, -0.61, 0, 0, 90},
        ["Gas"] = {1487, 1, 0, 0.02, -0.61, 0, 0, 90},
        ["Chapeu"] = {1543, 1, 0, -0.0010, -0.59, 0, 0, 90},
        ["Cachorro"] = {1546, 1, 0, -0.04, -0.61, 0, 0, 90},
        ["Saco"] = {1551, 1, 0, -0, -0.61, 0, 0, 90},
        --["Terror"] = {1855, 1, 0, 0.02, -0.61, 0, 0, 90},
    },

    itensParaNaoRemoverQuandoMorrer = {
        [119] = true,
        [120] = true,
        [121] = true,
        [112] = true,
        [113] = true,
        [114] = true,
        [115] = true,
        [122] = true,
    },

    itensIlegais = {
        [5] = true,
        [6] = true,
        [7] = true,
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true,
        [12] = true,
        [13] = true,
        [14] = true,
        [15] = true,
        [16] = true,
        [17] = true,
        [19] = true,
        [20] = true,
        [21] = true,
        [22] = true,
        [29] = true,
        [31] = true,
        [32] = true,
        [33] = true,
        [44] = true,
        [45] = true,
        [46] = true,
        [47] = true,
        [48] = true,
        [49] = true,
        [50] = true,
        [51] = true,
        [52] = true,
        [53] = true,
        [54] = true,
        [55] = true,
        [56] = true,
        [57] = true,
        [78] = true,
        [79] = true,
        [80] = true,
        [81] = true,
        [82] = true,
        [83] = true,
        [84] = true,
        [85] = true,
        [92] = true,
        [93] = true,
        [94] = true,
        [95] = true,
        [96] = true,
        [124] = true,
        [125] = true,
        [126] = true,
        [127] = true,
        [128] = true,
        [129] = true,
        [130] = true,
        [131] = true,
        [132] = true,
    },

    itensComData = {
        [123] = true,
        [129] = true,
        [130] = true,
        [131] = true,
        [132] = true,
    },
    ['itens'] = {
        [1] =   {name = "Hot Dog", weight = 0.25, action = "food", satisfy = 20, wetList=true, image = "core/assets/icons/1.png",},
        [2] =   {name = "Água", weight = 0.25, action = "drink", satisfy = 20, image = "core/assets/icons/2.png",},
        [3] =   {name = "Mochila", weight = 1, action = "backpack", wetList=true, image = "core/assets/icons/3.png",},
        [4] =   {name = "Algemas", weight = 0.5, action = "cuff", takelist = true, image = "core/assets/icons/4.png",},
        [5] =   {name = "Parafal", weight = 5, action = "weapon", wetList=true, weapon = 31, ammo = 13, image = "core/assets/icons/5.png",},
        [6] =   {name = "G36C", weight = 5, action = "weapon", wetList=true, weapon = 30, ammo = 13, image = "core/assets/icons/6.png",},
        [7] =   {name = "MP5", weight = 5, action = "weapon", wetList=true, weapon = 29, ammo = 16, image = "core/assets/icons/7.png",},
        [8] =   {name = "Glock-G25", weight = 3,action = "weapon", wetList=true, weapon = 22,ammo = 15, image = "core/assets/icons/8.png",},
        [9] =   {name = "Tec-9", weight = 3, action = "weapon", wetList=true, weapon = 32, ammo = 16, image = "core/assets/icons/9.png",},
        [10] =  {name = "Glock-18", weight = 3,  action = "weapon", wetList=true,weapon = 23, ammo = 15, image = "core/assets/icons/10.png",},
        [11] =  {name = "AWP", weight = 8, action = "weapon", wetList=true, weapon = 34, ammo = 14, image = "core/assets/icons/11.png",},
        [12] =  {name = "Taser", weight = 3, action = "weapon", wetList=true, weapon = 24, ammo = 82, takelist = true, image = "core/assets/icons/12.png",},
        [13] =  {name = "Munição 5.56", weight = 0, action = "ammo", wetList=true, image = "core/assets/icons/13.png",},
        [14] =  {name = "Munição 7.62", weight = 0, action = "ammo", wetList=true, image = "core/assets/icons/14.png",},
        [15] =  {name = "Munição 9mm", weight = 0, action = "ammo", wetList=true, image = "core/assets/icons/15.png",},
        [16] =  {name = "Munição .45", weight = 0, action = "ammo", wetList=true, image = "core/assets/icons/16.png",},
        [17] =  {name = "Faca", weight = 0.5, action = "weapon", weapon = 4, image = "core/assets/icons/17.png",},
        [18] =  {name = "Picareta", weight = 1, action = "weapon", weapon = 2, image = "core/assets/icons/18.png",},
        [19] =  {name = "Soco Inglês", weight = 0.5, action = "weapon", weapon = 1, image = "core/assets/icons/19.png",},
        [20] =  {name = "Bastão", weight = 1, action = "weapon", weapon = 5, image = "core/assets/icons/20.png",},
        [21] =  {name = "Katana", weight = 1, action = "weapon", weapon = 8, image = "core/assets/icons/21.png",},
        [22] =  {name = "Pá", weight = 1, action = "weapon", weapon = 6, image = "core/assets/icons/22.png",},
        [23] =  {name = "Cacetete", weight = 0.5, action = "weapon", weapon = 3, takelist = true, image = "core/assets/icons/23.png",},
        [24] =  {name = "Vara de Pesca", weight = 0.5, action = "weapon", weapon = 10, image = "core/assets/icons/24.png",},
        [25] =  {name = "Band-Aid", weight = 0.1, action = "others", wetList=true, image = "core/assets/icons/25.png",},
        [26] =  {name = "Kit Médico", weight = 1, action = "others", wetList=true, image = "core/assets/icons/26.png",},
        [27] =  {name = "Colete Leve", weight = 1, action = "others", image = "core/assets/icons/27.png",},
        [28] =  {name = "Kit de Reparo", weight = 1, action = "others", image = "core/assets/icons/28.png",},
        [29] =  {name = "Lockpick", weight = 0.5, action = "others", image = "core/assets/icons/29.png",},
        [30] =  {name = "Celular", weight = 0.5, action = "others", wetList=true, image = "core/assets/icons/30.png",},
        [31] =  {name = "Rádio", weight = 0.5, action = "others", wetList=true, image = "core/assets/icons/31.png",},
        [32] =  {name = "C4", weight = 0.5, action = "others",wetList=true, image = "core/assets/icons/32.png",},
        [33] =  {name = "Dinheiro Sujo", weight = 0, action = "others",wetList=true, image = "core/assets/icons/33.png",},
        [34] =  {name = "Salgadinho", weight = 0.25, action = "food", satisfy = 20,wetList=true, image = "core/assets/icons/34.png",},
        [35] =  {name = "Donut", weight = 0.25, action = "food", satisfy = 20,wetList=true, image = "core/assets/icons/35.png",},
        [36] =  {name = "Hambúrguer", weight = 0.25, action = "food", satisfy = 20,wetList=true, image = "core/assets/icons/36.png",},
        [37] =  {name = "Pizza", weight = 0.25, action = "food", satisfy = 20, wetList=true, image = "core/assets/icons/37.png",},
        [38] =  {name = "Café", weight = 0.25, action = "drink", satisfy = 20, wetList=true, image = "core/assets/icons/38.png",},
        [39] =  {name = "Refrigerante", weight = 0.25, action = "drink", satisfy = 20, image = "core/assets/icons/39.png",},
        [40] =  {name = "Energético", weight = 0.25, action = "others", image = "core/assets/icons/40.png",},
        [41] =  {name = "Vodka", weight = 0.25, action = "drink", satisfy = 20, image = "core/assets/icons/41.png",},
        [42] =  {name = "Gin", weight = 0.25, action = "drink", satisfy = 20, image = "core/assets/icons/42.png",},
        [43] =  {name = "Cerveja", weight = 0.25, action = "drink", satisfy = 20, image = "core/assets/icons/43.png",},
        [44] =  {name = "Ziplock", weight = 0.01, action = "others", image = "core/assets/icons/44.png",},
        [45] =  {name = "Erva", weight = 0.01, action = "others",wetList=true, image = "core/assets/icons/45.png",},
        [46] =  {name = "Pó", weight = 0.01, action = "others",wetList=true, image = "core/assets/icons/46.png",},
        [47] =  {name = "Cristal", weight = 0.01, action = "others", wetList=true, image = "core/assets/icons/47.png",},
        [48] =  {name = "Seda", weight = 0.01, action = "others",wetList=true, image = "core/assets/icons/48.png",},
        [49] =  {name = "Baseado", weight = 0.1, action = "others",wetList=true, image = "core/assets/icons/49.png",},
        [50] =  {name = "Cocaína", weight = 0.1, action = "others", image = "core/assets/icons/50.png",},
        [51] =  {name = "Metanfetamina", weight = 0.1, action = "others", image = "core/assets/icons/51.png",},
        [52] =  {name = "Metal", weight = 0.01, action = "others", image = "core/assets/icons/52.png",},
        [53] =  {name = "Pólvora", weight = 0.01, action = "others", image = "core/assets/icons/53.png",},
        [54] =  {name = "Gatilho", weight = 0.01, action = "others", image = "core/assets/icons/54.png",},
        [55] =  {name = "Peça de Pistola", weight = 0.01, action = "others", image = "core/assets/icons/55.png",},
        [56] =  {name = "Peça de Fuzil", weight = 0.01, action = "others", image = "core/assets/icons/56.png",},
        [57] =  {name = "Mola", weight = 0.01, action = "others", image = "core/assets/icons/57.png",},
        [58] =  {name = "Galão", weight = 1, action = "others", image = "core/assets/icons/58.png",},
        [59] =  {name = "Bic", weight = 0.1, action = "others",wetList=true, image = "core/assets/icons/59.png",},
        [60] =  {name = "Atum", weight = 0.1, action = "others", image = "core/assets/icons/60.png",},
        [61] =  {name = "Bagre", weight = 0.1, action = "others", image = "core/assets/icons/61.png",},
        [62] =  {name = "Baiacu", weight = 0.1, action = "others", image = "core/assets/icons/62.png",},
        [63] =  {name = "Pacu", weight = 0.1, action = "others", image = "core/assets/icons/63.png",},
        [64] =  {name = "Pirarucu", weight = 0.1, action = "others", image = "core/assets/icons/64.png",},
        [65] =  {name = "Sardinha", weight = 0.1, action = "others", image = "core/assets/icons/65.png",},
        [66] =  {name = "Tilápia", weight = 0.1, action = "others", image = "core/assets/icons/66.png",},
        [67] =  {name = "Cobre", weight = 0.1, action = "others", image = "core/assets/icons/67.png",},
        [68] =  {name = "Diamante", weight = 0.1, action = "others", image = "core/assets/icons/68.png",},
        [69] =  {name = "Esmeralda", weight = 0.1, action = "others", image = "core/assets/icons/69.png",},
        [70] =  {name = "Ouro", weight = 0.1, action = "others", image = "core/assets/icons/70.png",},
        [71] =  {name = "Pedra", weight = 0.1, action = "others", image = "core/assets/icons/71.png",}, 
        [72] =  {name = "Prata", weight = 0.1, action = "others", image = "core/assets/icons/72.png",},
        [73] =  {name = "Rubi", weight = 0.1, action = "others", image = "core/assets/icons/73.png",},
        [74] =  {name = "Safira", weight = 0.1, action = "others", image = "core/assets/icons/74.png",},
        [75] =  {name = "Ticket", weight = 0.1, action = "others", wetList=true, image = "core/assets/icons/75.png",},
        [76] =  {name = "Caixa Misteriosa", weight = 0.1, action = "others", image = "core/assets/icons/76.png",},
        [77] =  {name = "JBL", weight = 0.5, action = "others", takelist = true, chestPoliceBlock = true, image = "core/assets/icons/77.png",},
        [78] =  {name = "Parafal Restrita", weight = 5, action = "weapon", wetList=true, weapon = 31, ammo = 81, takelist = true, image = "core/assets/icons/5.png",},
        [79] =  {name = "MP5 Restrita", weight = 5, action = "weapon", wetList=true, weapon = 29, ammo = 83, takelist = true, image = "core/assets/icons/7.png",},
        [80] =  {name = "Glock Restrita", weight = 3, action = "weapon", wetList=true, weapon = 22, ammo = 82, takelist = true, image = "core/assets/icons/8.png",},
        [81] =  {name = "Munição 5.56 Restrita", weight = 0, action = "ammo", wetList=true, takelist = true, image = "core/assets/icons/13.png",},
        [82] =  {name = "Munição 9mm Restrita", weight = 0, action = "ammo", wetList=true, takelist = true, image = "core/assets/icons/15.png",},
        [83] =  {name = "Munição .45 Restrita", weight = 0, action = "ammo", wetList=true, takelist = true, image = "core/assets/icons/16.png",},
        [84] =  {name = "Corda", weight = 0.25, action = "others",wetList=true, image = "core/assets/icons/84.png",},
        [85] =  {name = "Capuz", weight = 0.25, action = "others",wetList=true, image = "core/assets/icons/85.png",},
        [86] =  {name = "Alvejante", weight = 0.1, action = "others", image = "core/assets/icons/86.png",},
        [87] =  {name = "Tinta", weight = 0.1, action = "others", image = "core/assets/icons/87.png",},
        [88] =  {name = "Papel", weight = 0.01, action = "others", wetList=true, image = "core/assets/icons/88.png",},
        [89] =  {name = "Chave Quebrada", weight = 0.01, action = "others", image = "core/assets/icons/89.png",},
        [90] =  {name = "Lixa", weight = 0.01, action = "others", image = "core/assets/icons/90.png",},
        [91] =  {name = "Elástico", weight = 0.01, action = "others", image = "core/assets/icons/91.png",},
        [92] =  {name = "Munição 7.62 Restrita", weight = 0, action = "ammo", wetList=true, takelist = true, image = "core/assets/icons/16.png",},
        [93] =  {name = "Glock-18 Restrita", weight = 3 ,action = "weapon", wetList=true, weapon = 23, ammo = 82, takelist = true, image = "core/assets/icons/10.png",},
        [94] =  {name = "Tec-9 Restrita", weight = 3, action = "weapon", wetList=true, weapon = 32, ammo = 83, takelist = true, image = "core/assets/icons/9.png",},
        [95] =  {name = "G36C Restrita", weight = 5, action = "weapon", wetList=true, weapon = 30, ammo = 81, takelist = true, image = "core/assets/icons/6.png",},
        [96] =  {name = "AWP Restrita", weight = 8, action = "weapon", wetList=true, weapon = 34, ammo = 92, takelist = true, image = "core/assets/icons/11.png",},
        [97] =  {name = "Mascara Diabo", weight = 0, action = "mask", image = "core/assets/icons/97.png"},
        [98] =  {name = "Mascara Anonymous", weight = 0, action = "mask", image = "core/assets/icons/98.png"},
        [99] =  {name = "Mascara Jedi", weight = 0, action = "mask", image = "core/assets/icons/99.png"},
        [100] = {name = "Mascara Macaco", weight = 0, action = "mask", image = "core/assets/icons/100.png"},
        [101] = {name = "Mascara Gas", weight = 0, action = "mask", image = "core/assets/icons/101.png"},
        [102] = {name = "Mascara Chapeu", weight = 0, action = "mask", image = "core/assets/icons/102.png"},
        [103] = {name = "Mascara Cachorro", weight = 0, action = "mask", image = "core/assets/icons/103.png"},
        [104] = {name = "Mascara Terror", weight = 0, action = "mask", image = "core/assets/icons/104.png"},
        [105] = {name = "Tablet Policial", weight = 0, action = "others", wetList=true, takelist = true, image = "core/assets/icons/105.png"},
        [106] = {name = "Tecido", weight = 0.01, action = "others", image = "core/assets/icons/106.png"},
        [107] = {name = "Pé de Cabra", weight = 0.5, action = "others", image = "core/assets/icons/107.png"},
        [108] = {name = "Adrenalina", weight = 0.25, action = "others", wetList=true, image = "core/assets/icons/108.png"},
        [109] = {name = "Analgésico", weight = 0.1, action = "others", wetList=true, image = "core/assets/icons/109.png"},
        [110] = {name = "Dinheiro", weight = 0, action = "others", wetList=true, takelist = true, chestPoliceBlock = true, sendItem = true, image = "core/assets/icons/110.png",},
        [111] = {name = "Kevlar", weight = 0.1, action = "weapon", wetList=true, image = "core/assets/icons/111.png",},
        [112] = {name = "Telefone Personalizado", weight = 0.1, action = "others", takelist = true, chestPoliceBlock = true, image = "core/assets/icons/112.png",},
        [113] = {name = "Placa Personalizada", weight = 0.1, action = "others", takelist = true, chestPoliceBlock = true, image = "core/assets/icons/113.png",},
        [114] = {name = "Troca de Nome", weight = 0.1, action = "others", takelist = true, chestPoliceBlock = true, image = "core/assets/icons/114.png",},
        [115] = {name = "Resetar Aparência", weight = 0.1, action = "others", takelist = true, chestPoliceBlock = true, image = "core/assets/icons/115.png",},
        [116] = {name = "Plástico", weight = 0.1, action = "others", image = "core/assets/icons/116.png",},
        [117] = {name = "Ciclonita", weight = 0.1, action = "others", image = "core/assets/icons/117.png",},
        [118] = {name = "Capacete", weight = 0.1, action = "others", image = "core/assets/icons/118.png",},
        [119] = {name = "CNH", weight = 0.1, action = "others", takelist = true, chestPoliceBlock = true, image = "core/assets/icons/119.png",},
        [120] = {name = "RG", weight = 0.1, action = "others", takelist = true, chestPoliceBlock = true, image = "core/assets/icons/120.png",},
        [121] = {name = "Porte de Armas", weight = 0.1, action = "others", takelist = true, chestPoliceBlock = true, image = "core/assets/icons/121.png",},
        [122] = {name = "Relógio Digital", weight = 0.1, action = "others", wetList=true, takelist = true, chestPoliceBlock = true, image = "core/assets/icons/122.png",},
        [123] = {name = "Chave de casa", weight = 0.1, action = "others", takelist = true, chestPoliceBlock = true, sendItem = true, image = "core/assets/icons/123.png",},
        [124] = {name = "Relógio", weight = 0.1, action = "others", image = "core/assets/icons/124.png",},
        [125] = {name = "Cartão", weight = 0.1, action = "others", image = "core/assets/icons/125.png",},
        [126] = {name = "Colar", weight = 0.1, action = "others", image = "core/assets/icons/126.png",},
        [127] = {name = "Pulseira", weight = 0.1, action = "others", image = "core/assets/icons/127.png",},
        [128] = {name = "Quadro", weight = 0.25, action = "others", image = "core/assets/icons/128.png",},
        [129] = {name = "Roda", weight = 1, action = "others", image = "core/assets/icons/129.png",},
        [130] = {name = "Capô", weight = 1, action = "others", image = "core/assets/icons/130.png",},
        [131] = {name = "Porta-Malas", weight = 1, action = "others", image = "core/assets/icons/131.png",},
        [132] = {name = "Porta", weight = 1, action = "others", image = "core/assets/icons/132.png",},
        [133] = {name = "Colete Médio", weight = 1, action = "others", image = "core/assets/icons/133.png",},
        [134] = {name = "Colete Pesado", weight = 1, action = "others", image = "core/assets/icons/134.png",},
        [135] = {name = "Garrafa Vazia", weight = 0.25, action = "others", image = "core/assets/icons/135.png",},
        [136] = {name = "Garrafa de Leite", weight = 0.25, action = "others", image = "core/assets/icons/136.png",},
        [137] = {name = "Café", weight = 0.25, action = "others", image = "core/assets/icons/137.png",},
        [138] = {name = "G3C6 Quebrada", weight = 0.25, action = "others", image = "core/assets/icons/138.png",},
        [139] = {name = "Parafal Quebrada", weight = 0.25, action = "others", image = "core/assets/icons/139.png",},
        [140] = {name = "Lata", weight = 0.1, action = "others", image = "core/assets/icons/140.png",},
        [141] = {name = "Composto Energético", weight = 0.1, action = "others", image = "core/assets/icons/141.png",},
        [142] = {name = "Reparo Temporário", weight = 1, action = "others", image = "core/assets/icons/142.png",},
        [143] = {name = "Paraquedas", weight = 1, action = "others", image = "core/assets/icons/143.png",},
        [144] = {name = "M4A1", weight = 5, action = "weapon", wetList=true, weapon = 30, ammo = 13, image = "core/assets/icons/144.png",},
    },
}

message = function(element, message, style)
    if (element and isElement(element) and getElementType(element) == "player") then 
        triggerClientEvent(element, "addBox", element, message, style)
    end
end

function math.round(num, decimals)
    decimals = math.pow(10, decimals or 0)
    num = num * decimals
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num / decimals
end

function getVehicleKG (model)
    if config['trunk']['vehicles'] then
        if config['trunk']['vehicles'][model] then
            return config['trunk']['vehicles'][model].weight
        end
    end
    return 0
end