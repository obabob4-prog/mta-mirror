-- resource's config

config = getConfig();



-- resource's global

Global = {}

-- resource's util

function changeClotheInPlayer(c, onlyClient, t)

    if c:find(';') then

        for _, d in pairs(split(c, ';')) do

            if d:find('tone') then

                toneSelect = d:gsub('tone:', '');

            end



            triggerEvent('MST.' .. (d:find('tone') and 'changeTone' or 'changeClothesElement'), localPlayer,

                (t and t or localPlayer), (d:find('tone') and d:gsub('tone:', '') or d), nil, onlyClient);

        end

    else

        if c:find('tone') then

            toneSelect = c:gsub('tone:', '');

        end



        triggerEvent('MST.' .. (c:find('tone') and 'changeTone' or 'changeClothesElement'), localPlayer,

            (t and t or localPlayer), (c:find('tone') and c:gsub('tone:', '') or c), nil, onlyClient);

    end

end

