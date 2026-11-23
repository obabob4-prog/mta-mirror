--[[

            █▅▃▃▃▃▃▃▃▅█ https://discord.gg/SQUDj3DVU7 █▅▃▃▃▃▃▃▃▅█ 



    ██████╗  ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗██████╗ ███████╗██╗   ██╗

    ██╔══██╗██╔═══██╗████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝██║   ██║

    ██████╔╝██║   ██║██╔████╔██║███████║██╔██╗ ██║██║  ██║█████╗  ██║   ██║

    ██╔══██╗██║   ██║██║╚██╔╝██║██╔══██║██║╚██╗██║██║  ██║██╔══╝  ╚██╗ ██╔╝

    ██║  ██║╚██████╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║██████╔╝███████╗ ╚████╔╝ 

    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝  ╚═══╝  



            █▅▃▃▃▃▃▃▃▅█ https://discord.gg/SQUDj3DVU7 █▅▃▃▃▃▃▃▃▅█ 

]]--



_CMDs = {

}



_KEYs = {

	"F1",

	"U",

	"Z",

	"M",

	"O",

	"B",

	"F2",

	"F3",

	"F4",

	"F5",

	"F6",

	"F7",

	"F8",

	"F9",

	"F10",

}



system = {

    ['attributes'] = {

        hud = { -- Configurações da interface do seu servidor.

            use = false, -- Opção para aparecer / sumir a interface (hud, velocimetro e minimapa) do seu servidor (true para sim e false para não).

            showHud = function(element, state) -- função para aparecer / sumir a interface (hud, velocimetro e minimapa).

                setPlayerHudComponentVisible("all", state); -- element = jogador que está abrindo o celular /// state = true para aparecer a interface ou false para sumir a interface.

                return;

            end 

        },



        panel = {

            command = "evento",

            permissions = {"Staff", "Console"}

        }

    }

};



others = {

    ['getPlayerID'] = function(element)

        return getElementData(element, "ID") or "N/A";

    end

};



notify = {

    ['success'] = "success",

    ['warning'] = "warning",

    ['error'] = "error",

    ['info'] = "info"

};



geral = {

    ['sNotify'] = function(element, message, type)

        return exports['goiaba_infobox']:addBox(element, message, notify[type]);

    end,



    ['cNotify'] = function(element, message, type)

        return triggerEvent("addBox", element, message, notify[type]);

    end

};