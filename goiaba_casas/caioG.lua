config = {



    taxPercentage = 10;
    imobiliaria = {1800.97, -1555.39, 14.1, 0, 0}, -- x, y, z, interior, dimension

    impostos = 30, -- % de impostos que gerá ao valor de todas casas adquiridas.



    createCommand = 'addcasa';

    adminAcls = {



        'Console';

        'Admin +'



    };



    casas = { -- NÃO DUPLIQUE O NOME DAS CASAS (ELAS SÃO USADA PARA O SALVAMENTO DENTRO DA DATABASE)

        -------------------------------------- Imobiliária --------------------------------------

        [1] = { -- KITNET FAVELA

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 6,

                pos = {2308.79, -1212.88, 1049.02},

                rot = 0,

                chestPosition = {2311.97, -1212.3, 1049.02, 0, 0, 270.98},

                dormirPosition = {2305.79, -1209.39, 1049.55},

            },

        },

        [2] = {

            nameType = 'Praia',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 8,

                pos = {2365.17, -1135.51, 1050.88},

                rot = 7.21,

                chestPosition = {2361.81, -1120.57, 1050.88, 0, 0, 86.69};

                dormirPosition = {2358.69, -1132.93, 1051.4};

            },

        },

        [3] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 1,

                pos = {223.18, 1287.21, 1082.14},

                rot = 353.27,

                chestPosition = {220.19, 1289.57, 1082.14, 0, 0, 1.02};

                dormirPosition = {232.05, 1287.57, 1082.88};

            },

        },

        [4] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 5,

                pos = {2233.55, -1115.26, 1050.88},

                rot = 0,

                chestPosition = {2229.91, -1108.91, 1050.88, 0, 0, 89.61};

                dormirPosition = {2230.53, -1106.28, 1051.6};

            },

        },

        [5] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 11,

                pos = {2282.91, -1140.29, 1050.9},

                rot = 0,

                chestPosition = {2286, -1139.83, 1050.9, 0, 0, 44.29};

                dormirPosition = {2285.12, -1135.2, 1051.53};

            },

        },

        [6] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 1,

                pos = {2218.19, -1076.28, 1050.48},

                rot = 92.47,

                chestPosition = {2213.92, -1077.98, 1050.48, 0, 0, 179.96};

                dormirPosition = {2209.86, -1071.99, 1051.33};

            },

        },

        [7] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 2,

                pos = {2237.37, -1081.51, 1049.02}, 

                rot = 359.2,

                chestPosition = {2245.09, -1076.84, 1049.02, 0, 0, 268.86};

                dormirPosition = {2244.05, -1080.22, 1049.56};

            },

        },

        [8] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 4,

                pos = {261, 1284.3, 1080.26},

                rot = 5.37,

                chestPosition = {254.45, 1285.91, 1080.26, 0, 0, 179.4};

                dormirPosition = {266.41, 1287.87, 1081};

            },

        },

        [9] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 8,

                pos = {-42.58, 1405.61, 1084.43},

                rot = 0,

                chestPosition = {-46.95, 1401.81, 1084.43, 0, 0, 359.46};

                dormirPosition = {-51.24, 1408.73, 1084.91};

            },

        },

        [10] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 6,

                pos = {-68.96, 1351.43, 1080.21},

                rot = 356.39,

                chestPosition = {-71.59, 1366.56, 1080.22, 0, 0, 2.41};

                dormirPosition = {-71.25, 1362.62, 1080.83};

            },

        },

        [11] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 6,

                pos = {2333.11, -1077.1, 1049.02},

                rot = 0,

                chestPosition = {2340.29, -1068.71, 1049.03, 0, 0, 181.75};

                dormirPosition = {2342.13, -1067.96, 1049.71};

            },

        },

        [12] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 10,

                pos = {2270.27, -1210.36, 1047.56},

                rot = 86.84,

                chestPosition = {2262.25, -1222.08, 1049.02, 0, 0, 268.26};

                dormirPosition = {2258.02, -1223.53, 1049.79};

            },

        },

        [13] = {

            nameType = '',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 6,

                pos = {2196.68, -1204.44, 1049.02},

                rot = 85.56,

                chestPosition = {2186.07, -1213.52, 1049.02, 0, 0, 180.06};

                dormirPosition = {2188.13, -1209.96, 1049.71};

            },

        },

        -------------------------------------- Pagas --------------------------------------

        [14] = {

            nameType = 'Premium',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 4,

                pos = {-260.59, 1456.65, 1084.37},

                rot = 84.87,

                chestPosition = {-269.18, 1447.04, 1088.87, 0, 0, 179.04};

                dormirPosition = {-275.06, 1448.57, 1089.42};

            },

        },

        [15] = {

            nameType = 'Premium',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 5,

                pos = {140.23, 1366.18, 1083.86},

                rot = 2.86,

                chestPosition = {145.37, 1386.49, 1088.37, 0, 0, 268.23};

                dormirPosition = {135.59, 1385.31, 1089.05};

            },

        },

        [16] = {

            nameType = 'Premium',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 9,

                pos = {82.95, 1322.44, 1083.87},

                rot = 0,

                chestPosition = {88.31, 1332.87, 1088.36, 0, 0, 177.65};

                dormirPosition = {92.27, 1340.78, 1089.03};

            },

        },

        [17] = {

            nameType = 'Premium',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 15,

                pos = {-283.61, 1470.96, 1084.38},

                rot = 89.11,

                chestPosition = {-287.74, 1475.99, 1088.88, 0, 0, 178.52};

                dormirPosition = {-295.33, 1480.17, 1089.62};

            },

        },

        [18] = { -- Madd dogg

            nameType = 'Premium',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 5,

                pos = {1260.83, -785.47, 1091.91},

                rot = 265.91,

                chestPosition = {1277.72, -797.68, 1089.94, 0, 0, 178.89};

                dormirPosition = {1272.53, -792.11, 1090.68};

            },

        },

        [19] = { -- CJ

            nameType = 'Premium',

            image = {

                file = 'assets/images/houses/1.png', -- imagem da casa

                size = {57, 48}, -- tamanho da imagem

            },

            -- configuração dentro da casa

            house_inside = {

                interior = 3,

                pos = {2496.23, -1692.08, 1014.74},

                rot = 177.07,

                chestPosition = {2492.5, -1700.75, 1018.34, 0, 0, 357.74};

                dormirPosition = {2495.11, -1702.4, 1019.04};

            },

        },

    },

    

    notify = function (src, element, message, type)

        if src == 'server' then

            exports['goiaba_infobox']:addBox(element, message, type)

        elseif src == 'client' then

            exports['goiaba_infobox']:addBox(message, type)

        end

    end



}



function formatNumber(number)

	local money = number

	for i = 1, tostring(money):len()/3 do

		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1.%2")

	end

	return money

end



