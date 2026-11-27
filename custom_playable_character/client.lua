-- Art The Clown - client side
-- The model is loaded on a NEW custom ped ID (engineRequestModel).
-- GTA:SA skin 0 (CJ) and every stock character are left completely untouched.
-- Nothing is replaced globally: the custom model is applied only to elements
-- explicitly marked by this resource (the player who opts in, and preview peds).

local BASE_MODEL = 7          -- male01: skeleton template only, never replaced
local item = nil              -- { model, txd, dff }
local loadFailedAt = 0        -- avoid spamming load errors every second
local originalModels = {}     -- per-player original model, remembered locally
local selfOriginal = nil

local function log(msg, r, g, b)
    outputChatBox("[ArtClown] " .. msg, r or 200, g or 220, b or 255)
end

local function dbg(msg)
    outputDebugString("[ART-CLOWN] " .. msg)
end

local function markLoadFailed()
    loadFailedAt = getTickCount()
end

local function ensureLoaded()
    if item then return item end
    -- retry at most once every 10 seconds so a transient download problem
    -- does not flood the client log
    if loadFailedAt > 0 and getTickCount() - loadFailedAt < 10000 then return nil end

    local model = engineRequestModel("ped", BASE_MODEL)
    if not model then
        dbg("engineRequestModel failed")
        markLoadFailed()
        return nil
    end

    local txd = engineLoadTXD("textures/artclown.txd", true)
    local dff = engineLoadDFF("models/artclown.dff")
    if not txd or not dff then
        dbg("load failed txd=" .. tostring(isElement(txd)) .. " dff=" .. tostring(isElement(dff)))
        if isElement(txd) then destroyElement(txd) end
        if isElement(dff) then destroyElement(dff) end
        engineFreeModel(model)
        markLoadFailed()
        return nil
    end

    engineImportTXD(txd, model)
    if not engineReplaceModel(dff, model) then
        dbg("engineReplaceModel failed on custom ID " .. tostring(model))
        destroyElement(txd)
        destroyElement(dff)
        engineFreeModel(model)
        markLoadFailed()
        return nil
    end

    item = { model = model, txd = txd, dff = dff }
    loadFailedAt = 0
    dbg("ready custom=" .. model .. " base=" .. BASE_MODEL)
    return item
end

-- Apply the custom model to NPCs/characters marked by this resource or by
-- ng-characters ("artclown.character" = a saved character using the sentinel 900).
-- Only take over a neutral template or our own previous model, so job uniforms
-- and other model systems are never overwritten.
local lastApplied = {}
local applyAnnounced = false
local blockedLog = {}
local STORED_CLOWN_ID = 900

local function isMarked(element)
    return getElementData(element, "artclown.preview") or
           getElementData(element, "artclown.character") or false
end

local function applyToMarkedElements()
    -- Load the model on demand: a marked character must not stay on the
    -- neutral template (model 7) while nothing ever calls ensureLoaded().
    local markedElements = {}
    for _, ped in ipairs(getElementsByType("ped")) do
        if isMarked(ped) then markedElements[#markedElements + 1] = ped end
    end
    for _, player in ipairs(getElementsByType("player")) do
        if isMarked(player) then markedElements[#markedElements + 1] = player end
    end
    if #markedElements == 0 then return end

    local loaded = ensureLoaded()
    if not loaded then return end

    for _, element in ipairs(markedElements) do
        local current = getElementModel(element)
        local previous = lastApplied[element]
        -- Only take over a neutral template / stored sentinel / our own model,
        -- so job uniforms and other model systems are never overwritten.
        local safe = (current == loaded.model or current == BASE_MODEL or
                      current == STORED_CLOWN_ID or (previous and current == previous))
        if element == localPlayer and not safe then
            local key = tostring(current)
            if not blockedLog[key] then
                blockedLog[key] = true
                dbg("marked self not applied: current=" .. key .. " expected=" .. loaded.model)
            end
        end
        if safe and current ~= loaded.model then
            setElementModel(element, loaded.model)
            lastApplied[element] = loaded.model
            if element == localPlayer and not applyAnnounced then
                applyAnnounced = true
                log("saved Art The Clown character applied (model " .. loaded.model .. ").", 120, 255, 150)
            end
        end
    end
end

-- Apply / restore for a specific player element (works for self and remote players
-- because every client uses its own allocated model ID).
local function applyToPlayer(player)
    if not isElement(player) then return end
    local loaded = ensureLoaded()
    if not loaded then
        if player == localPlayer then
            log("failed to load the custom model (see clientscript.log)", 255, 90, 90)
        end
        return
    end
    if originalModels[player] == nil then
        originalModels[player] = getElementModel(player)
    end
    setElementModel(player, loaded.model)
    if player == localPlayer then selfOriginal = originalModels[player] end
    if player == localPlayer then
        log("custom skin applied (model " .. loaded.model .. "), CJ untouched.", 120, 255, 150)
    end
end

local function restorePlayer(player)
    if not isElement(player) then return end
    local original = originalModels[player]
    if original == nil then
        if player == localPlayer then log("no custom skin is active", 200, 220, 255) end
        return
    end
    setElementModel(player, original)
    originalModels[player] = nil
    if player == localPlayer then selfOriginal = nil end
    if player == localPlayer then log("your original skin restored.", 200, 220, 255) end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(applyToMarkedElements, 500, 1)
    setTimer(applyToMarkedElements, 1000, 0)
    log("ready - /clownnpc (separate character), /clownme (wear it), /clownoff", 120, 255, 150)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if selfOriginal ~= nil and isElement(localPlayer) then
        setElementModel(localPlayer, selfOriginal)
    end
    for player, original in pairs(originalModels) do
        if isElement(player) then setElementModel(player, original) end
    end
    originalModels = {}
    if item then
        if isElement(item.txd) then destroyElement(item.txd) end
        if isElement(item.dff) then destroyElement(item.dff) end
        engineFreeModel(item.model)
        item = nil
    end
end)

addEvent("artclown:apply", true)
addEventHandler("artclown:apply", root, function(player) applyToPlayer(player) end)

addEvent("artclown:restore", true)
addEventHandler("artclown:restore", root, function(player) restorePlayer(player) end)

addCommandHandler("clownme", function()
    triggerServerEvent("artclown:requestApply", localPlayer)
end)

addCommandHandler("clownoff", function()
    triggerServerEvent("artclown:requestRestore", localPlayer)
end)

addCommandHandler("clowninfo", function()
    log("custom=" .. tostring(item and item.model) ..
        " previewPeds=" .. tostring(#getElementsByType("ped")) ..
        " selfModel=" .. tostring(isElement(localPlayer) and getElementModel(localPlayer)) ..
        " (CJ/model 0 is never replaced)", 180, 220, 255)
end)
