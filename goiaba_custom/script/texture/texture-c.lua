-- config's resource
--ATTACH = exports[config.pAttach]

Async:setPriority(500, 8)

-- client's main
local Global = {
    firstRequest = false,
    clothesElements = {},
    objectsElements = {},
    textureElements = {},
}

local shaderFile = [[
    texture Tex0;

    technique simple
    {
        pass P0
        {
            Texture[0] = Tex0;
        }
    }
]]

-- texture's manager
function createTextureElement(textureArchive, textureFormat, ...)
    if not Global.textureElements[textureArchive] then
        Global.textureElements[textureArchive] = {};
    end
    if not Global.textureElements[textureArchive][textureFormat] then
        Global.textureElements[textureArchive][textureFormat] = dxCreateTexture(textureArchive, textureFormat, ...);
    end

    return Global.textureElements[textureArchive][textureFormat];
end

function createTextureEncrypted(textureArchive, textureFormat, ...)
    textureArchive = 'assets/textures/' .. textureArchive;

    if Global.textureElements[textureArchive] and Global.textureElements[textureArchive][textureFormat] then
        return Global.textureElements[textureArchive][textureFormat];
    end

    local split_string = split(textureArchive, '.');
    local decrypted = nil;

    if (split_string[#split_string]):sub(-10) == '_encrypted' then
        local compiledStr
        local compiledFile = File.open(textureArchive, true)
        if compiledFile then
            compiledStr = fileRead(compiledFile, fileGetSize(compiledFile));
            fileClose(compiledFile);
        end

        compiledStr = decodeString('base64', decodeString('tea', compiledStr, { key = config.imagePassword }));
        decrypted = compiledStr;
    else
        return createTextureElement(textureArchive, textureFormat, ...);
    end

    if not Global.textureElements[textureArchive] then
        Global.textureElements[textureArchive] = {};
    end

    if not Global.textureElements[textureArchive][textureFormat] then
        Global.textureElements[textureArchive][textureFormat] = dxCreateTexture(decrypted, textureFormat, ...);
    end

    return Global.textureElements[textureArchive][textureFormat];
end

function getPlayersInRender()
    local newTable = {};
    local players = getElementsByType('player', getRootElement(), true);

    for i = 1, #players do
        local theElement = players[i];
        if theElement ~= localPlayer then
            table.insert(newTable, theElement);
        end
    end

    return newTable;
end

-- manager's resource
function setApplyShader(theElement, textureName, localArchive, overlap, overlapVariable, encrypt)
    if not (theElement and textureName and localArchive) then
        return false;
    end

    if getElementType(theElement) ~= 'object' then
        if not isElementStreamedIn(theElement) then
            return false;
        end

        local personInfo = getElementData(theElement, 'GOIABA.Clothes');
        if personInfo then
            textureName = textureName:gsub('${genderStart}', personInfo.gender:sub(1, 1)):gsub('${headModel}',
                tostring(personInfo.face));
        end
    end

    local variableName = textureName;
    if overlap then
        variableName = textureName .. '@' .. overlapVariable;
    end

    if Global.clothesElements[theElement] and Global.clothesElements[theElement][variableName] then
        removeShader(theElement, variableName);
    end

    if not Global.clothesElements[theElement] then
        Global.clothesElements[theElement] = {};
    end

    if not Global.clothesElements[theElement][variableName] then
        Global.clothesElements[theElement][variableName] = {
            Count = 0,
            Encrypt = encrypt,
            ArchiveName = localArchive,
            Texture = (encrypt and createTextureEncrypted(localArchive, 'dxt3') or createTextureElement(localArchive, 'dxt3')),
            Shader = DxShader(shaderFile, 0, 0, (overlap == true),
                (theElement:getType() == 'player' and 'ped' or theElement:getType()))
        };
    end

    Global.clothesElements[theElement][variableName].Count = Global.clothesElements[theElement][variableName].Count + 1;

    if Global.clothesElements[theElement][variableName].Shader then
        dxSetShaderValue(Global.clothesElements[theElement][variableName].Shader, 'Tex0',
            Global.clothesElements[theElement][variableName].Texture);
        engineRemoveShaderFromWorldTexture(Global.clothesElements[theElement][variableName].Shader, textureName,
            theElement);
        engineApplyShaderToWorldTexture(Global.clothesElements[theElement][variableName].Shader, textureName, theElement);
    end
end

addEvent('MST.setApplyShader', true);
addEventHandler('MST.setApplyShader', getRootElement(), setApplyShader);

function removeShader(theElement, variableName)
    if not (theElement and variableName) then
        return false;
    end

    if theElement:getType() ~= 'object' then
        local personData = getElementData(theElement, 'GOIABA.Clothes');
        if personData then
            variableName = variableName:gsub('${genderStart}', personData.gender:sub(1, 1)):gsub('${headModel}',
                tostring(personData.face));
        end
    end

    if not (Global.clothesElements[theElement] and Global.clothesElements[theElement][variableName]) then
        return false;
    end

    engineRemoveShaderFromWorldTexture(Global.clothesElements[theElement][variableName].Shader,
        (variableName:find('@') and split(variableName, '@')[1] or variableName), theElement);

    Global.clothesElements[theElement][variableName].Count = Global.clothesElements[theElement][variableName].Count - 1;
    if (Global.clothesElements[theElement][variableName].Count <= 0) then
        destroyElement(Global.clothesElements[theElement][variableName].Shader);
        Global.clothesElements[theElement][variableName] = nil;
    end
end

addEvent('MST.removeShader', true);
addEventHandler('MST.removeShader', getRootElement(), removeShader);

function setApplyObject(theElement, type, model, textureName, localArchive, position, name, encrypt)
    if not (theElement and type and model) then
        return false;
    end

    if Global.objectsElements[theElement] and Global.objectsElements[theElement][type] then
        removeObject(theElement, type);
    end

    if not Global.objectsElements[theElement] then
        Global.objectsElements[theElement] = {};
    end

    if not Global.objectsElements[theElement][type] then
        Global.objectsElements[theElement][type] = {
            Name = name or 'Indefinido',
            Type = type,
            ModelId = model,
            Position = position,
            Object = createObject(model, 0, 0, 0)
        };
    end

    if Global.objectsElements[theElement][type].Object then
        setElementDoubleSided(Global.objectsElements[theElement][type].Object, true);
        ATTACH:attach(Global.objectsElements[theElement][type].Object, theElement, unpack(position));
        setApplyShader(Global.objectsElements[theElement][type].Object, textureName, localArchive, false, false, encrypt);

        if type ~= 'hair' then
            local personInfo = getElementData(theElement, 'GOIABA.Clothes');
            if personInfo then
                personInfo.HaveObject = true;
                setElementData(theElement, 'GOIABA.Clothes', personInfo);
            end

            setElementData(Global.objectsElements[theElement][type].Object, 'ryan-acessorie',
                Global.objectsElements[theElement][type]);
        end
    end
end

addEvent('MST.setApplyObject', true);
addEventHandler('MST.setApplyObject', getRootElement(), setApplyObject);

function removeObject(theElement, type)
    if not (theElement and type) then
        return false;
    end

    if not (Global.objectsElements[theElement] and Global.objectsElements[theElement][type]) then
        return false;
    end

    local personInfo = getElementData(localPlayer, 'GOIABA.Clothes');
    if personInfo and table.size(Global.objectsElements[theElement]) <= 1 then
        personInfo.HaveObject = false;
        setElementData(localPlayer, 'GOIABA.Clothes', theElement);
    end

    destroyElement(Global.objectsElements[theElement][type].Object);
    Global.objectsElements[theElement][type] = nil;
end

addEvent('MST.removeObject', true);
addEventHandler('MST.removeObject', getRootElement(), removeObject);

-- export's resource
function changeClothesElement(theElement, clotheName, positionObject, onlyClient, loginPlayer)
    if not (theElement and clotheName) then
        return false;
    end

    if not isElement(theElement) then
        return false;
    end

    local clotheData = config.texturesClothes[clotheName];
    if not clotheData then
        return false;
    end

    if clotheData[5] then -- Is Object
        if (onlyClient) then
            return setApplyObject(theElement, clotheData[5].Type, clotheData[5].ModelID, clotheData[2], clotheData[1],
                clotheData[5].PositionDefault, clotheData[5].Name, clotheData[7])
        end
        return triggerServerEvent('MST.EveryoneObject', theElement, getPlayersInRender(), theElement, clotheData[5].Type,
            clotheData[5].ModelID, clotheData[2], clotheData[1], clotheData[5].PositionDefault, clotheData[5].Name,
            clotheData[7])
    end

    if getElementData(theElement, 'GOIABA.Clothes') then -- Is player data
        if clotheData[2] and type(clotheData[2]) == 'table' then
            for _, textureName in pairs(clotheData[2]) do
                if textureName:find('tone:') then
                    local tonePlayer = getElementData(theElement, 'GOIABA.Clothes').tone or 1
                    changeToneElement(theElement, tonePlayer, textureName:gsub('tone:', ''), onlyClient)
                else
                    if onlyClient then
                        setApplyShader(theElement, textureName, clotheData[1], (clotheData[4] ~= false and clotheData[4] ~= nil), clotheData[4], clotheData[7])
                    else
                        triggerServerEvent('MST.EveryoneShader', theElement, getPlayersInRender(), theElement, textureName, clotheData[1], (clotheData[4] ~= false and clotheData[4] ~= nil), clotheData[4], clotheData[7])
                    end
                end
            end
        else
            if onlyClient then
                setApplyShader(theElement, clotheData[2], clotheData[1],(clotheData[4] ~= false and clotheData[4] ~= nil), clotheData[4], clotheData[7])
            else
                triggerServerEvent('MST.EveryoneShader', theElement, getPlayersInRender(), theElement, clotheData[2],
                    clotheData[1], (clotheData[4] ~= false and clotheData[4] ~= nil), clotheData[4], clotheData[7])
            end
        end
    end

    if clotheData[3] then -- Remove Txd variable
        if type(clotheData[3] == 'table') then
            for _, textureName in pairs(clotheData[3]) do
                removeFormatClotheInElementClient(theElement, textureName, onlyClient)
            end
        else
            removeFormatClotheInElementClient(theElement, clotheData[3], onlyClient)
        end
    end
end

addEvent('MST.changeClothesElement', true);
addEventHandler('MST.changeClothesElement', getRootElement(), changeClothesElement);

function removeClothesElement(theElement, clotheName, onlyClient, removeActual)
    if not (theElement and clotheName) then
        return false;
    end

    local clotheData = config.texturesClothes[clotheName]
    if not clotheData then
        return false;
    end

    if clotheData[5] then -- Is Object
        if onlyClient then
            return removeObject(theElement, clotheData[5].Type);
        end
        return triggerServerEvent('MST.EveryoneObjectRemove', theElement, getPlayersInRender(), theElement,
            clotheData[5].Type);
    end

    if clotheData[3] then -- Remove Txd variable
        if type(clotheData[3]) == 'table' then
            for _, textureName in pairs(clotheData[3]) do
                removeTextureElement(theElement, textureName, onlyClient);
            end
        else
            removeTextureElement(theElement, clotheData[3], onlyClient);
        end
    end

    if clotheData[2] and removeActual then
        if type(clotheData[2]) == 'table' then
            for _, textureName in pairs(clotheData[2]) do
                variableName = textureName .. (clotheData[4] and '@' .. clotheData[4] or '');
                removeTextureElement(theElement, variableName, onlyClient);
            end
            return false;
        end

        variableName = clotheData[2] .. (clotheData[4] and '@' .. clotheData[4] or '');
        return removeTextureElement(theElement, variableName, onlyClient);
    end
end

addEvent('MST.removeClothesElement', true);
addEventHandler('MST.removeClothesElement', getRootElement(), removeClothesElement);

function removeTextureElement(theElement, textureName, onlyClient)
    if not (theElement and textureName) then
        return false;
    end

    if onlyClient then
        return removeShader(theElement, textureName);
    else
        triggerServerEvent('MST.EveryoneShaderRemove', theElement, getPlayersInRender(), theElement, textureName);
        return removeShader(theElement, textureName);
    end
end

addEvent('MST.removeTextureElement', true);
addEventHandler('MST.removeTextureElement', getRootElement(), removeTextureElement);

function changeToneElement(theElement, tone, presetPart, onlyClient)
    if not (theElement and tone) then
        return false;
    end

    local personData = getElementData(theElement, 'GOIABA.Clothes');
    if not personData then
        return false;
    end

    local gender = personData.gender;
    if not gender then
        return false;
    end

    if presetPart then
        changeClothesElement(theElement,
            config['presetClothesTone'][tone][presetPart]:gsub('${genderStart}', gender:sub(1, 1)), nil, onlyClient);
        return true;
    end

    if theElement == localPlayer then
        for clothePart in pairs(config['presetClothesTone'][tone]) do
            changeClothesElement(theElement,config['presetClothesTone'][tone][clothePart]:gsub('${genderStart}', gender:sub(1, 1)), nil, onlyClient);
        end
    else
        Async:foreach(config['presetClothesTone'][tone], true, function(_, clothePart)
            changeClothesElement(theElement,
                config['presetClothesTone'][tone][clothePart]:gsub('${genderStart}', gender:sub(1, 1)), nil, onlyClient);
        end);
    end
    -- changeClothesElement(theElement,
    --     config['presetClothesTone'][tone]['torso']:gsub('${genderStart}', gender:sub(1, 1)), nil, onlyClient);
    -- changeClothesElement(theElement,
    --     config['presetClothesTone'][tone]['legs']:gsub('${genderStart}', gender:sub(1, 1)), nil, onlyClient);
    -- changeClothesElement(theElement,
    --     config['presetClothesTone'][tone]['feet']:gsub('${genderStart}', gender:sub(1, 1)), nil, onlyClient);
end

addEvent('MST.changeToneElement', true);
addEventHandler('MST.changeToneElement', getRootElement(), changeToneElement);

function loadPlayer(theElement)
    local model = getElementModel(theElement);
    if Global.clothesElements[theElement] then
        for variable in pairs(Global.clothesElements[theElement]) do
            removeShader(theElement, variable);
        end
    end

    if Global.objectsElements[theElement] then
        for type in pairs(Global.objectsElements[theElement]) do
            removeObject(theElement, type);
        end
    end

    if config.customSkin[model] then
        local infosPerson = getElementData(theElement, 'GOIABA.Clothes');
        if infosPerson then
            changeToneElement(theElement, infosPerson.tone, nil, true);
            if theElement == localPlayer then
                for clotheType, clotheName in pairs(infosPerson.clothes) do
                    changeFormatClotheInElement(theElement, clotheName, true);
                end
            else
                Async:foreach(infosPerson.clothes, true, function(clotheName)
                    changeFormatClotheInElement(theElement, clotheName, true);
                end);
            end
        end
    end

    if config.otherSkin[model] then
        local infosPerson = getElementData(theElement, 'GOIABA.Clothes');
        if infosPerson then
            changeToneElement(theElement, infosPerson.tone, nil, true);
            if theElement == localPlayer then
                for _, clotheType in ipairs(config.otherSkin[model]) do
                    changeFormatClotheInElement(theElement, infosPerson.clothes[clotheType], true);
                end
            else
                Async:foreach(config.otherSkin[model], false, function(clotheType)
                    changeFormatClotheInElement(theElement, infosPerson.clothes[clotheType], true);
                end);
            end

            if config.skinPresetClothes[getElementModel(theElement)] then
                if theElement == localPlayer then
                    for _, clotheName in ipairs(config.skinPresetClothes[getElementModel(theElement)]) do
                        changeFormatClotheInElement(theElement, clotheName, true);
                    end
                else
                    Async:foreach(config.skinPresetClothes[getElementModel(theElement)], false, function(clotheName)
                        changeFormatClotheInElement(theElement, clotheName, true);
                    end);
                end
            end

            if infosPerson.clothesCorp then
                if theElement == localPlayer then
                    for _, clotheName in pairs(infosPerson.clothesCorp) do
                        changeFormatClotheInElement(theElement, clotheName, true);
                    end
                else
                    Async:foreach(infosPerson.clothesCorp, true, function(clotheName)
                        changeFormatClotheInElement(theElement, clotheName, true);
                    end);
                end
            end
        end
    end
end

addEvent('MST.loadPlayer', true);
addEventHandler('MST.loadPlayer', getRootElement(), loadPlayer);

function changeFormatClotheInElement(t, c, onlyClient)
    if t and c then
        if c:find(';') then
            for _, d in pairs(split(c, ';')) do
                if not d:find('tone:') then
                    triggerEvent('MST.' .. (d:find('tone:') and 'changeToneElement' or 'changeClothesElement'),
                        localPlayer, (t and t or localPlayer), (d:find('tone:') and d:gsub('tone:', '') or d), nil,
                        onlyClient);
                end
            end
        else
            if not c:find('tone:') then
                triggerEvent('MST.' .. (c:find('tone:') and 'changeToneElement' or 'changeClothesElement'), localPlayer,
                    (t and t or localPlayer), (c:find('tone:') and c:gsub('tone:', '') or c), nil, onlyClient);
            end
        end
    end
end

function removeClotheInPlayer(c)
    if c:find(';') then
        for _, d in pairs(split(c, ';')) do
            triggerEvent('MST.removeShader', localPlayer, localPlayer, d);
        end
    else
        triggerEvent('MST.removeShader', localPlayer, localPlayer, c);
    end
end

function removeFormatClotheInElementClient(t, c, onlyClient)
    if c:find(';') then
        for _, d in pairs(split(c, ';')) do
            if onlyClient then
                if config.removeObjectByTexture[d] then
                    removeObject(t, config.removeObjectByTexture[d]);
                else
                    removeShader(t, d);
                end
            else
                if config.removeObjectByTexture[d] then
                    triggerServerEvent('MST.EveryoneObjectRemove', localPlayer, getPlayersInRender(), t,
                        config.removeObjectByTexture[d]);
                else
                    triggerServerEvent('MST.EveryoneShaderRemove', localPlayer, getPlayersInRender(), t, d);
                end
            end
        end
    else
        if onlyClient then
            if config.removeObjectByTexture[c] then
                removeObject(t, config.removeObjectByTexture[c]);
            else
                removeShader(t, c);
            end
        else
            if config.removeObjectByTexture[c] then
                triggerServerEvent('MST.EveryoneObjectRemove', localPlayer, getPlayersInRender(), t,
                    config.removeObjectByTexture[c]);
            else
                triggerServerEvent('MST.EveryoneShaderRemove', localPlayer, getPlayersInRender(), t, c);
            end
        end
    end
end

-- listener's function's
addEventHandler('onClientResourceStart', resourceRoot, function()
    loadPlayer(localPlayer);
    Async:foreach(getElementsByType('player', getRootElement(), true), false, function(theElement, _)
        if theElement == localPlayer then
            return false;
        end
        
        local infosPerson = getElementData(theElement, 'GOIABA.Clothes');
        if not infosPerson then
            return false;
        end

        if config.customSkin[getElementModel(theElement)] then
            changeToneElement(theElement, infosPerson.tone, nil, true);

            Async:foreach(infosPerson.clothes, true, function(clotheName)
                changeFormatClotheInElement(theElement, clotheName, true);
            end);
        elseif config.otherSkin[getElementModel(theElement)] then
            changeToneElement(theElement, infosPerson.tone, nil, true);

            Async:foreach(config.otherSkin[getElementModel(theElement)], false, function(clotheType)
                changeFormatClotheInElement(theElement, infosPerson.clothes[clotheType], true);
            end);

            if config.skinPresetClothes[getElementModel(theElement)] then
                Async:foreach(config.skinPresetClothes[getElementModel(theElement)], false, function(clotheName)
                    changeFormatClotheInElement(theElement, clotheName, true);
                end);
            end

            if infosPerson.clothesCorp then
                Async:foreach(infosPerson.clothesCorp, true, function(clotheName)
                    changeFormatClotheInElement(theElement, clotheName, true);
                end);
            end
        end
    end)
end)

addEventHandler('onClientElementStreamIn', getRootElement(), function()
    local theElement = source;
    if not theElement then
        return false;
    end

    if getElementType(theElement) ~= 'player' and getElementType(theElement) ~= 'ped' then
        return false;
    end

    local infosPerson = getElementData(theElement, 'GOIABA.Clothes');
    if not infosPerson then
        return false;
    end

    loadPlayer(theElement);
end);

addEventHandler('onClientElementStreamOut', getRootElement(), function()
    local theElement = source;
    if not theElement then
        return false;
    end

    if getElementType(theElement) ~= 'player' and getElementType(theElement) ~= 'ped' then
        return false;
    end

    if not Global.firstRequest then
        Global.firstRequest = true
        return false;
    end

    if Global.clothesElements[theElement] then
        for variable in pairs(Global.clothesElements[theElement]) do
            removeShader(theElement, variable);
        end
    end

    if Global.objectsElements[theElement] then
        for type in pairs(Global.objectsElements[theElement]) do
            removeObject(theElement, type);
        end
    end
end);

addEventHandler('onClientPlayerQuit', getRootElement(), function()
    local theElement = source;
    if not theElement then
        return false;
    end

    if getElementType(theElement) ~= 'player' and getElementType(theElement) ~= 'ped' then
        return false;
    end

    if Global.clothesElements[theElement] then
        for variable in pairs(Global.clothesElements[theElement]) do
            removeShader(theElement, variable);
        end
    end

    if Global.objectsElements[theElement] then
        for type in pairs(Global.objectsElements[theElement]) do
            removeObject(theElement, type);
        end
    end
end);

addEventHandler('onClientElementModelChange', getRootElement(), function(oldModel, newModel)
    local theElement = source;
    if not theElement then
        return false;
    end

    loadPlayer(theElement);
end);

local txd = engineLoadTXD("assets/loader/Male.txd")
local dff = engineLoadDFF("assets/loader/Male.dff")
if txd and dff then
    engineImportTXD(txd, 1)
    engineReplaceModel(dff, 1)
end

local txd = engineLoadTXD("assets/loader/Female.txd")
local dff = engineLoadDFF("assets/loader/Female.dff")
if txd and dff then
    engineImportTXD(txd, 2)
    engineReplaceModel(dff, 2)
end

setTimer( function()
    collectgarbage ("collect")
end, 10000, 0)