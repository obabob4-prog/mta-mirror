--[[

    --» sᴄʀɪᴘᴛ ғᴇɪᴛᴏ ᴘᴏʀ » Pedro Developer

--]]



config = {
	markerColor = {96, 191, 76, 0};
    notify = function(player, text, type)
        return exports['goiaba_infobox']:addBox(player, text, type);
    end; 
    notifyC = function(text, type)
        return exports['goiaba_infobox']:addBox(text, type)
    end; 

    minBetDouble = 100; 
    maxBetDouble = 250000;
    minBlackjackDouble = 100; 
    maxBlackjackDouble = 250000;
    minMineBet = 100; -- // Aposta minima
    maxMineBet = 250000; -- // Aposta maxima
    mines = {
        5; 
        10;
        15;
    };
    minesMultipliers = { -- // Insira aqui o multiplicador da aposta ao acertar um slot de minas
        [5] = 0.05;
        [10] = 0.20;
        [15] = 0.50;
    };
    betMultiplier = 1.4; -- // Valor multiplicado se a aposta de cavalo ganhar 
    bets = { -- // VALORES DAS APOSTAS DE CAVALO
        5000; 
        10000;
        15000;
        25000;
        50000;
    };
    minTouro = 100; 
    maxTouro = 250000;
    tigerRewards = { -- // Multiplicação que os valores irão ter de acordo com a sequencia de simbolos 
        ['1'] = 0.5; 
        ['2'] = 1.25;
        ['3'] = 1.50;
        ['4'] = 1.75;
        ['5'] = 2;
        ['6'] = 2.2;
        ['wild'] = 10;
    };
	markers = {
		{position = {1251.68, -1742.41, 13.55 - 1}, dimension = 0, interior = 0, game = 'touro'};
		{position = {1249.32, -1742.64, 13.55 - 1}, dimension = 0, interior = 0, game = 'horse'};
		{position = {1248.8, -1739.4, 13.55 - 1}, dimension = 0, interior = 0, game = 'double'};
        {position = {1251.98, -1739.36, 13.55 - 1}, dimension = 0, interior = 0, game = 'mines'};
        {position = {1252.66, -1735.26, 13.55 - 1}, dimension = 0, interior = 0, game = 'crash'};
        {position = {1249.16, -1735.08, 13.55 - 1}, dimension = 0, interior = 0, game = 'blackjack'};    
	};
}
function table.shuffle(array)
    -- fisher-yates

    local output = { }

    local random = math.random

 

    for index = 1, #array do

        local offset = index - 1

        local value = array[index]

        local randomIndex = offset*random()

        local flooredIndex = randomIndex - randomIndex%1

 

        if flooredIndex == offset then

            output[#output + 1] = value

        else

            output[#output + 1] = output[flooredIndex + 1]

            output[flooredIndex + 1] = value

        end

    end

    return output

end



function table.reverse(t)

    local reversedTable = {}

    local itemCount = #t

    for k, v in ipairs(t) do

        reversedTable[itemCount + 1 - k] = v

    end

    return reversedTable

end