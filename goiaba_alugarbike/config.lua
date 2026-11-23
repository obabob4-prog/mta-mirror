config = {

    ['Interface'] = {



        ['Colors'] = { -- Configurações gerais de cor

            ['MainColor'] = {143, 232, 121}; -- r, g, b

            ['BackgroundColor'] = {23, 23, 23, 250}; -- r, g, b, a

            ['GridColor'] = {inHover = {47, 48, 49}, notHover = {47, 48, 49, 80}}; -- Quando estiver com o cursor em cima (r, g, b), quando não estiver com o cursor em cima (r, g, b, a)

            ['GridTexts'] = {tittles = {255, 255, 255, 40}, subtittles = {255, 255, 255, 60}}; -- Cor do titulo e subtitulo (r, g, b, a)

            ['ButtonsColor'] = {notHover = {47, 48, 49, 50}}; -- (r, g, b, a)

            ['ButtonsTextColor'] = {inHover = {43, 45, 46}, notHover = {74, 75, 76}}; -- Quando estiver com o cursor em cima (r, g, b), quando não estiver com o cursor em cima (r, g, b)

            ['TopContentColor'] = {255, 255, 255, 40}; -- (r, g, b, a)

            ['MiddleContentColor'] = {tittle = {255, 255, 255, 115}, subtittle = {255, 255, 255, 63}}; -- Cor do titulo e subtitulo (r, g, b, a)

        };



        ['BlurActive'] = true; -- Defina se você quer um inside-blur, que é um blur radial dentro do painel

        ['Language'] = 'pt-br'; -- Defina a linguagem do seu sistema

        ['MoneyText'] = 'R$'; -- Simbolo da moeda



        ['Texts'] = { -- Textos editaveis

            ['pt-br'] = {

                ['TopContent'] = {Tittle = 'Alugar Bike', SubTittle = 'Alugue sua bicicleta para poder se deslocar na cidade'};

                ['MiddleContent'] = {Tittle = 'Informação', SubTittle = 'Caso você saia da bicicleta será mandando para a\nlocadora'};

                ['BottomContent'] = {Buy = 'Comprar Bike', Quit = 'Fechar Painel'};

                ['Market'] = {Tittle = 'Bicicleta', Price = 'Preço'};

                ['Notify'] = {notenoughMoney = 'Você não possui dinheiro!', buySuccessfully = 'Você comprou sua %s com sucesso!', quitBike = 'Você saiu da bike e ela voltou para a locadora!'};

            };

            ['english'] = {

                ['TopContent'] = {Tittle = 'Rent Bike', SubTittle = 'Rent your bike to get around the city'};

                ['MiddleContent'] = {Tittle = 'Information', SubTittle = 'If you leave the bike, it will be sent to the\nrental company.'};

                ['BottomContent'] = {Buy = 'Buy Bike', Quit = 'Close Panel'};

                ['Market'] = {Tittle = 'Bike', Price = 'Price'};

                ['Notify'] = {notenoughMoney = 'You dont have money!', buySuccessfully = 'You have successfully purchased your bike %s!', quitBike = 'You got off the bike and it went back to the rental shop!'};

            };

        };



    };

    ['System'] = {



        ['TimeToDestroy'] = 15000; -- Tempo em milissegundos para a bike ser destruida ao sair dela (5000 = 5 segundos)



        ['Bikes'] = {

            {name = 'Mountain Bike', price = 50, model = 510}; -- Nome do veiculo, preço dele, id do veiculo

            {name = 'BMX', price = 50, model = 481}; -- Nome do veiculo, preço dele, id do veiculo

            {name = 'Bike', price = 50, model = 509}; -- Nome do veiculo, preço dele, id do veiculo

        };



        ['Markers'] = {

            ['Color'] = {255, 255, 255, 255}; -- Cor dos markers (r, g, b, a)

            ['Size'] = 1.5; -- Tamanho do marker

            ['Positions'] = {

                {1497.706, -1743.051, 13.547-1}; -- Posição {X, Y, Z} do Aluguel.

                {1183.182, -1308.744, 14.15-1};

                {2119.09, -1117.352, 25.312-1}; 

                {1860.232, -1392.798, 13.562-1};

                {1363.931, -1289.906, 13.547-1};

                {1148.206, -1414.748, 13.671-1};

                {361.032, -1654.897, 32.873-1}; 

                {996.025, -1815.608, 14.148-1}; 

                {1679.912, -2243.929, 13.55-1}; 

                {1143.788, -1759.842, 13.642-1}; 

                {2141.664, -1157.674, 23.992-1};

                {811.342, -1846.141, 8.41-1};

                {-384.821, -1418.597, 25.727-1};

            };

        };



    };

};



function returnInterface ()

    return config['Interface'];

end



function returnSystem ()

    return config['System'];

end



function returnMessage (player, message, type)

    return triggerClientEvent (player, 'addBox', player, message, type);

end