---[[

    --» sᴄʀɪᴘᴛ ғᴇɪᴛᴏ ᴘᴏʀ » Pedro Developer

--]]



config = {



    markerColor = {2, 253, 83, 0};



    notify = function(player, text, type)



        return exports['goiaba_infobox']:addBox(player, text, type)

        

    end; 



    notifyC = function(text, type)



        return exports['goiaba_infobox']:addBox(text, type)

        

    end; 



    fineTimeDelay = 60;

    command = 'multar';



    acls = { -- // ACLS QUE PODEM MULTAR



        'policia';



    };

    

    fines = {

        {'Estacionamento irregular', 5000};

        {'Ultrapassagem em local proibido', 8000};

        {'Dirigir na contramão', 12000};

        {'Uso do celular enquanto dirige', 7000};

        {'Dirigir sob efeito de substâncias', 15000};

        {'Falta de inspeção veicular(Placa)', 10000};

        {'Estacionamento em local proibido', 6000};

        {'Excesso de velocidade', 5000};

        {'Sem Capacete', 5000};

    };



    markers = {
        {position = {1958.46, 2145.6, 12.65 - 1}; interior = 0; dimension = 0;};
    },
}