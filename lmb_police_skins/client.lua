--[[
    lmb_police_skins / client.lua
    ------------------------------------------------------------------
    Runtime ped-model replacements for the GTA V-derived LCPD uniforms.

    Target IDs are police-specific GTA:SA ped models already used by
    lmb_police/config.lua (PD.uniforms):
        280 = Patrol Uniform (male)
        281 = Senior Patrol (male)
        284 = Sergeant / Motors (male)

    Nothing in gta3.img is modified. Models load lazily per client and
    are restored to stock when this resource stops.
    ------------------------------------------------------------------
]]

local SKINS = {
    { model = 280, name = "Patrol Uniform",  txd = "models/lcpd_skin_patrol.txd", dff = "models/lcpd_skin_patrol.dff" },
    { model = 281, name = "Senior Patrol",   txd = "models/lcpd_skin_senior.txd",  dff = "models/lcpd_skin_senior.dff" },
    { model = 284, name = "Sergeant / Motors", txd = "models/lcpd_skin_motors.txd", dff = "models/lcpd_skin_motors.dff" },
}

local state = {}
for _, v in ipairs(SKINS) do
    state[v.model] = { entry = v, loaded = false, broken = false, attempts = 0, txd = nil, dff = nil }
end

local scanTimer = nil

local function stopScan()
    if isTimer(scanTimer) then killTimer(scanTimer) end
    scanTimer = nil
end

local function loadModel(model)
    local s = state[model]
    if not s or s.loaded or s.broken or s.attempts >= 4 then return end
    if isElement(s.txd) then destroyElement(s.txd) end
    if isElement(s.dff) then destroyElement(s.dff) end
    s.txd, s.dff = nil, nil

    engineRestoreModel(model)
    if engineResetModelTXD then engineResetModelTXD(model) end

    if not fileExists(s.entry.txd) or not fileExists(s.entry.dff) then
        s.broken = true
        outputDebugString("[LCPD Skins] " .. s.entry.name .. " :: model files missing", 2)
        return
    end

    local txd = engineLoadTXD(s.entry.txd)
    if not txd then
        s.broken = true
        outputDebugString("[LCPD Skins] " .. s.entry.name .. " :: TXD failed", 2)
        return
    end
    engineImportTXD(txd, model)
    s.txd = txd

    local dff = engineLoadDFF(s.entry.dff)
    if not dff then
        s.broken = true
        outputDebugString("[LCPD Skins] " .. s.entry.name .. " :: DFF failed", 2)
        return
    end
    s.dff = dff

    if not engineReplaceModel(dff, model) then
        s.attempts = s.attempts + 1
        outputDebugString("[LCPD Skins] " .. s.entry.name .. " :: replace failed (" .. s.attempts .. "/4)", 2)
        if s.attempts < 4 then
            setTimer(function() s.broken = false; loadModel(model) end, 2500 * s.attempts, 1)
        else
            s.broken = true
        end
        return
    end

    s.loaded = true
    outputDebugString("[LCPD Skins] " .. s.entry.name .. " ready (model " .. model .. ")")
end

local function scan()
    local peds = getElementsByType("ped")
    for i = 1, #peds do
        local model = getElementModel(peds[i])
        if state[model] then loadModel(model) end
    end
    local players = getElementsByType("player")
    for i = 1, #players do
        local model = getElementModel(players[i])
        if state[model] then loadModel(model) end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    scan()
    if not isTimer(scanTimer) then
        scanTimer = setTimer(scan, 4000, 0)
    end
end)

addEventHandler("onClientElementStreamIn", root, function()
    local t = getElementType(source)
    if t ~= "ped" and t ~= "player" then return end
    local model = getElementModel(source)
    if state[model] then loadModel(model) end
end)

addEventHandler("onClientPlayerSpawn", root, function()
    local model = getElementModel(source)
    if state[model] then loadModel(model) end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    stopScan()
    for model, s in pairs(state) do
        if s.loaded then engineRestoreModel(model) end
        if engineResetModelTXD then engineResetModelTXD(model) end
        if isElement(s.txd) then destroyElement(s.txd) end
        if isElement(s.dff) then destroyElement(s.dff) end
    end
end)
