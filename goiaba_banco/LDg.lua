---[[

    --» sᴄʀɪᴘᴛ ғᴇɪᴛᴏ ᴘᴏʀ » Pedro Developer

--]]



config = {

    markerColor = {96, 191, 76, 0}; -- // Cor do marker

    notify = function(player, text, type)

        return triggerClientEvent(player, 'addBox', player, text, type);

    end; 

    notifyC = function(text, type)

        return triggerEvent('addBox', text, type);

    end;   



    geral = {

        blip = 52, 
        id_object = 2942, 
        element_data = 'moneybank'; 
        delay_operation = 10, -- segundos para ter um delay de uma operação para outra 

    },  



    atms = { -- x, y, z, rx, ry, rz
        -- LS
        {1315.327, -1367.874, 13.549, -0, 0, 183.286, hasBlip = true}; -- Conce Princi
        {1675.918, -1671.951, 13.541, -0, 0, 269.26, hasBlip = true}; -- Loja Roupas
        {1864.612, -1331.247, 13.555, -0, 0, 178.661, hasBlip = true, safeZone = true}; -- Pedreiro
        {1928.58, -1768.06, 13.55, 0, 0, 274, hasBlip = false}; -- Posto Pizzaria CJ
        {1885.37, -1729.85, 13.5, 0, 0, 178.5, hasBlip = true}; -- Outlet
        {2713.42, -1112.24, 69.57, 0, 0, 270.48, hasBlip = true}; -- Perto DP
        {2733.47, -2480.19, 13.65, 0, 0, 272.06, hasBlip = true}; -- Porto
        {1809.05, -1567.02, 13.47, 0, 0, 220.93, safeZone = true}; -- Prefeitura
        {2038.13, -1433.08, 17.07, 0, 0, 90.82, safeZone = true}; -- HP
        {1544.71, -1714.16, 13.20, 0, 0, 179.42}; -- DP
        {2228.63, -1696.66, 13.8, 0, 0, 82.99, safeZone = true}; -- Mec
        {1156.67, -1415.55, 13.63, 0, 0, 359.14, hasBlip = true};  -- Praça
        -- LV
        {2180.596, 1966.414, 10.82, 0, 0, 3.596, hasBlip = true}; -- Starfish
        {2022.512, 1020.314, 10.82, 0, 0, 268.07, hasBlip = true}; -- Four Dragons
        {1972.26, 1188.38, -86, 0, 0, 78.41, safeZone = true}; -- Cassino
        -- SF
        {-2127.75, 578.397, 35.172, 0, 0, 177.706, hasBlip = true}; 
        {-2626.261, 553.686, 14.609, 0, 0, 6.814, hasBlip = true};  -- Hospital
        {-1983.921, 620.45, 35.172, 0, 0, 179.617, hasBlip = true};
        {-2715.553, 94.476, 4.336, 0, 0, 273.248, hasBlip = true};

        {690.85, -571.63, 16.34, 0, 0, 92.59, hasBlip = true};
        {-841, 2749.23, 45.85, 0, 0, 271.81, hasBlip = true};
        {-69.53, 1208.84, 19.74, 0, 0, 185.92, hasBlip = true};

        {793.06, 659.31, 11.77, 0, 0, 12.78}; -- PRF
        {1046.06, 993.25, 11.1, 0, 0, 52.55}; -- PF
        {2895.94, -1965.91, 11.11, 0, 0, 90.82}; -- PF
        -- Lojinhas
        {1212.13, -1130.98, 24.61 , 0, 0, 266.35};
        {362.9, -2053.46, 8.21, 0, 0, 268.44};
        {2070.37, -1865.61, 13.9, 0, 0, 178.16}; 
        {1032.56, -1842.71, 14.01, 0, 0, 174.29};
        {1322.18, -895.79, 40.01, 0, 0, 87.04};
        {2425.18, -1790.13, 13.9, 0, 0, 355.77};
        {2508.94, -1515.8, 24.4, 0, 0, 268.01};
        {412.7, -1323.35, 15.41, 0, 0, 122.04};

        -- Bombeiros
        {2037.72, -1228.6, 24.60, 0, 0, 176.57};
        --dp
        {2947.47, -1152.07, 11.21, 0, 0, 268.98};
    };
}





function formatNumber(number, sep)

    if not sep then

        sep = '.'

    end

	assert(type(tonumber(number))=="number", "Bad argument @'formatNumber' [Expected number at argument 1 got "..type(number).."]")

	assert(not sep or type(sep)=="string", "Bad argument @'formatNumber' [Expected string at argument 2 got "..type(sep).."]")

	local money = number

	for i = 1, tostring(money):len()/3 do

		money = string.gsub(money, "^(-?%d+)(%d%d%d)", "%1"..sep.."%2")

	end

	return money

end



local tableNumberAccents = { ["{"] = true, ["}"] = true, ["["] = true, ["]"] = true, ["!"] = true, ["@"] = true, ["#"] = true, ["$"] = true, ["%"] = true, ["¨"] = true, ["&"] = true, ["*"] = true, ["("] = true, [")"] = true, ["-"] = true, ["="] = true, ["_"] = true, ["+"] = true, ["/"] = true, ["\\"] = true, ["|"] = true, ["."] = true, [","] = true, ["<"] = true, [">"] = true, [":"] = true, [";"] = true, ["~"] = true, ["^"] = true, ["`"] = true, ["?"] = true, ['"'] = true,  ["'"] = true,  [' '] = true, ["Ç"] = true, ["ü"] = true, ["é"] = true, ["â"] = true, ["ä"] = true, ["à"] = true, ["å"] = true, ["ç"] = true, ["ê"] = true, ["ë"] = true, ["è"] = true, ["ï"] = true, ["î"] = true, ["ì"] = true, ["Ä"] = true, ["Å"] = true, ["É"] = true, ["æ"] = true, ["Æ"] = true, ["ô"] = true, ["ö"] = true, ["ò"] = true, ["û"] = true, ["ù"] = true, ["ÿ"] = true, ["Ö"] = true, ["Ü"] = true, ["¢"] = true, ["£"] = true, ["¥"] = true, ["₧"] = true, ["ƒ"] = true, ["á"] = true, ["í"] = true, ["ó"] = true, ["ú"] = true, ["ñ"] = true, ["Ñ"] = true, ["ª"] = true, ["º"] = true, ["¿"] = true, ["⌐"] = true, ["¬"] = true, ["½"] = true, ["¼"] = true, ["¡"] = true, ["«"] = true, ["»"] = true, ["░"] = true, ["▒"] = true, ["▓"] = true, ["│"] = true, ["┤"] = true, ["╡"] = true, ["╢"] = true, ["╖"] = true, ["╕"] = true, ["╣"] = true, ["║"] = true, ["╗"] = true, ["╝"] = true, ["╜"] = true, ["╛"] = true, ["┐"] = true, ["└"] = true, ["┴"] = true, ["┬"] = true, ["├"] = true, ["─"] = true, ["┼"] = true, ["╞"] = true, ["╟"] = true, ["╚"] = true, ["╔"] = true, ["╩"] = true, ["╦"] = true, ["╠"] = true, ["═"] = true, ["╬"] = true, ["╧"] = true, ["╨"] = true, ["╤"] = true, ["╥"] = true, ["╙"] = true, ["╘"] = true, ["╒"] = true, ["╓"] = true, ["╫"] = true, ["╪"] = true, ["┘"] = true, ["┌"] = true, ["█"] = true, ["▄"] = true, ["▌"] = true, ["▐"] = true, ["▀"] = true, ["α"] = true, ["ß"] = true, ["Γ"] = true, ["π"] = true, ["Σ"] = true, ["σ"] = true, ["µ"] = true, ["τ"] = true, ["Φ"] = true, ["Θ"] = true, ["Ω"] = true, ["δ"] = true, ["∞"] = true, ["φ"] = true, ["ε"] = true, ["∩"] = true, ["≡"] = true, ["±"] = true, ["≥"] = true, ["≤"] = true, ["⌠"] = true, ["⌡"] = true, ["÷"] = true, ["≈"] = true, ["°"] = true, ["∙"] = true, ["·"] = true, ["√"] = true, ["ⁿ"] = true, ["²"] = true, ["■"] = true, ["´"] = true, ["à"] = true, ["á"] = true, ["â"] = true, ["ã"] = true, ["ä"] = true, ["ç"] = true, ["è"] = true, ["é"] = true, ["ê"] = true, ["ë"] = true, ["ì"] = true, ["í"] = true, ["î"] = true, ["ï"] = true, ["ñ"] = true, ["ò"] = true, ["ó"] = true, ["ô"] = true, ["õ"] = true, ["ö"] = true, ["ù"] = true, ["ú"] = true, ["û"] = true, ["ü"] = true, ["ý"] = true, ["ÿ"] = true, ["À"] = true, ["Á"] = true, ["Â"] = true, ["Ã"] = true, ["Ä"] = true, ["Ç"] = true, ["È"] = true, ["É"] = true, ["Ê"] = true, ["Ë"] = true, ["Ì"] = true, ["Í"] = true, ["Î"] = true, ["Ï"] = true, ["Ñ"] = true, ["Ò"] = true, ["Ó"] = true, ["Ô"] = true, ["Õ"] = true, ["Ö"] = true, ["Ù"] = true, ["Ú"] = true, ["Û"] = true, ["Ü"] = true, ["Ý"] = true,}

function verifyNumber(str)

    local noAccentsStr = false

    for strChar in string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)") do

        if (tableNumberAccents[strChar]) then

            noAccentsStr = tableNumberAccents[strChar]

        end

    end

    return noAccentsStr

end





function table.reverse(t)

    local reversedTable = {}

    local itemCount = #t

    for k, v in ipairs(t) do

        reversedTable[itemCount + 1 - k] = v

    end

    return reversedTable

end

