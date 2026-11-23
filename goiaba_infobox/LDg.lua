--[[
    --» sᴄʀɪᴘᴛ ғᴇɪᴛᴏ ᴘᴏʀ » Pedrooooo#1554
--]]

config = {
    
    messageTime = 5; -- // tempo que a infobox vai ficar na tela, segundos
    maxInfobox = 5; -- // numero maximo de infobox na tela 
    
    types = {

        ['success'] = {

            sound = 'assets/sons/success.mp3';
            colorBgBar = {130, 178, 80};
            title = 'Sucesso';

        };
        
        ['error'] = {

            sound = 'assets/sons/error.wav';
            colorBgBar = {224, 45, 45};
            title = 'Error';

        };

        ['info'] = {

            sound = 'assets/sons/info.mp3';
            colorBgBar = {61, 182, 243};
            title = 'Informação';

        };

        ['warning'] = {

            sound = 'assets/sons/info.mp3';
            colorBgBar = {224, 135, 45};
            title = 'Aviso';

        };

    };

}