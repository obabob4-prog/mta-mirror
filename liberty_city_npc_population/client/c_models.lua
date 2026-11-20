--[[
    liberty_city_npc_population / client/c_models.lua
    ------------------------------------------------------------------
    View layer only.  The server owns every NPC, its position, rotation,
    animation and state.  This file merely loads the seven supplied skin
    packs as custom ped models (never stock replacements) and paints them
    onto synced peds using the server-provided lcnpc.skin index.

    STRICT RULE: no ped on this server may ever be visible with a stock
    (default GTA) model.  Population peds get the skin chosen by the server.
    All other peds (shopkeepers, job givers, showroom, character preview,
    or any future spawner) are assigned one of the seven supplied skins
    deterministically and are hidden until that skin is confirmed applied.

    Model IDs are requested in a FIXED order on every client, so the same
    skin index always maps to the same custom model ID on every player.
]]

local models = {}
local loaded = false

-- Server.log mirror (no chat/GUI).
addEvent("lcnpc:clientLog", true)
local function log(msg)
    if LCNPC.debug then outputDebugString("[lcnpc] " .. tostring(msg), 0, 232, 197, 107) end
    triggerServerEvent("lcnpc:clientLog", localPlayer, tostring(msg))
end

local function loadModels()
    if loaded then return end
    loaded = true

    for i, skin in ipairs(LCNPC.skins) do
        local id = engineRequestModel("ped")
        if not id then
            log("engineRequestModel failed for skin " .. i .. " - no model added")
            models[i] = false
        else
            local txd = engineLoadTXD(skin.txd)
            local dff = engineLoadDFF(skin.dff, id)
            if txd then engineImportTXD(txd, id) end
            if dff then engineReplaceModel(dff, id) end
            if txd and dff then
                engineSetModelLODDistance(id, 300)
                models[i] = id
                log(("skin %d '%s' -> custom model %d"):format(i, skin.name, id))
            else
                models[i] = false
                log(("FAILED to load files for skin %d '%s' (txd=%s dff=%s)")
                    :format(i, skin.name, tostring(txd ~= false), tostring(dff ~= false)))
            end
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    loadModels()
    local n = 0
    for i = 1, #LCNPC.skins do if models[i] then n = n + 1 end end
    setElementData(localPlayer, "lcnpc.clientAlive", n, true)
    log("CLIENT READY models=" .. n .. "/" .. #LCNPC.skins)
end)

function LCNPCGetModel(index)
    return models[tonumber(index) or 0]
end

local function isCustomModel(id)
    if not id then return false end
    for i = 1, #LCNPC.skins do
        if models[i] and models[i] == id then return true end
    end
    return false
end

local function isLCNPCPed(ped)
    return isElement(ped) and getElementData(ped, "lcnpc.id") ~= false
end

-- Population peds: use the skin index chosen by the server.
local function paintPed(ped)
    if not isElement(ped) or getElementType(ped) ~= "ped" then return end
    if not isLCNPCPed(ped) then return end
    local idx = tonumber(getElementData(ped, "lcnpc.skin") or 0)
    if not idx or idx < 1 then
        setElementAlpha(ped, 0)
        return
    end
    local id = models[idx]
    if id then
        if getElementModel(ped) ~= id then setElementModel(ped, id) end
        setElementAlpha(ped, 255)
    else
        -- Model not ready/failed: hide it so a STOCK ped can never appear.
        setElementAlpha(ped, 0)
    end
end

-- Deterministic supplied-skin pick for peds owned by other resources.
-- Position + stock model is stable on every client, so all players see the
-- same skin for the same ped.  No coordinates are changed.
local function externalSkinIndex(ped)
    local m = tonumber(getElementModel(ped)) or 0
    local x, y = getElementPosition(ped)
    local h = math.floor(math.abs(x) * 13) + math.floor(math.abs(y) * 7) + m
    return (h % #LCNPC.skins) + 1
end

local function paintExternalPed(ped)
    if not isElement(ped) or getElementType(ped) ~= "ped" then return end
    if isLCNPCPed(ped) then return end
    local id = models[externalSkinIndex(ped)]
    if id then
        if getElementModel(ped) ~= id then setElementModel(ped, id) end
        setElementAlpha(ped, 255)
    else
        setElementAlpha(ped, 0)
    end
end

local function paintAnyPed(ped)
    if isLCNPCPed(ped) then paintPed(ped) else paintExternalPed(ped) end
end

-- Hide on stream-in before the first paint so no stock frame can flash.
addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "ped" then
        setElementAlpha(source, 0)
        paintAnyPed(source)
    end
end)

addEventHandler("onClientElementDataChange", root, function(name)
    if name == "lcnpc.skin" and getElementType(source) == "ped" then paintPed(source) end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, ped in ipairs(getElementsByType("ped")) do paintAnyPed(ped) end
end)

-- Slow compliance sweep: catches peds created later by other resources and
-- re-applies a supplied skin if anything resets a ped to a stock model.
setTimer(function()
    for _, ped in ipairs(getElementsByType("ped")) do
        if not isCustomModel(getElementModel(ped)) then paintAnyPed(ped) end
    end
end, 3000, 0)

-- Diagnostic: report which model IDs loaded and whether EVERY ped is painted.
-- Reports only to server.log; never to chat/GUI.
addEvent("lcnpc:diag", true)
addEventHandler("lcnpc:diag", root, function()
    log("DIAG REQUEST RECEIVED")
    local loadedCount = 0
    for i = 1, #LCNPC.skins do if models[i] then loadedCount = loadedCount + 1 end end
    local painted, stock, total = 0, 0, 0
    local extPainted, extStock, extTotal = 0, 0, 0
    for _, ped in ipairs(getElementsByType("ped")) do
        local m = getElementModel(ped)
        local custom = isCustomModel(m)
        if isLCNPCPed(ped) then
            total = total + 1
            if custom then painted = painted + 1 else stock = stock + 1 end
        else
            extTotal = extTotal + 1
            if custom then extPainted = extPainted + 1 else extStock = extStock + 1 end
        end
    end
    triggerServerEvent("lcnpc:diagResult", localPlayer,
        loadedCount, painted, stock, total, extPainted, extStock, extTotal)
end)

-- Return the custom IDs to MTA when the resource stops (no leaks).
addEventHandler("onClientResourceStop", resourceRoot, function()
    for i = 1, #models do
        if models[i] then
            engineFreeModel(models[i])
            models[i] = nil
        end
    end
    loaded = false
end)
