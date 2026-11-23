--[[
    lmb_police_fleet / client.lua
    ------------------------------------------------------------------
    Runtime model replacements for the LCPD fleet.

    Every entry replaces one of the stock GTA:SA vehicle IDs already
    used by lmb_police/config.lua (PD.vehicles). No gta3.img files are
    touched. Models are loaded lazily, per client, only when a vehicle
    of that ID streams in or is entered, so client RAM stays low.

    On resource stop every replaced model is restored to stock.
    ------------------------------------------------------------------
]]

local FLEET = {
    { model = 596, name = "Patrol Cruiser",   txd = "models/lcpd_cruiser.txd",    dff = "models/lcpd_cruiser.dff" },
    { model = 523, name = "Traffic Bike",     txd = "models/lcpd_bike.txd",       dff = "models/lcpd_bike.dff" },
    { model = 599, name = "Patrol SUV",       txd = "models/lcpd_suv.txd",        dff = "models/lcpd_suv.dff" },
    { model = 490, name = "Unmarked Unit",    txd = "models/lcpd_unmarked.txd",   dff = "models/lcpd_unmarked.dff" },
    { model = 597, name = "Interceptor",      txd = "models/lcpd_interceptor.txd",dff = "models/lcpd_interceptor.dff" },
    { model = 427, name = "Enforcer",         txd = "models/lcpd_enforcer.txd",   dff = "models/lcpd_enforcer.dff" },
    { model = 598, name = "Command Vehicle",  txd = "models/lcpd_command.txd",    dff = "models/lcpd_command.dff" },
    { model = 601, name = "Tactical Unit",    txd = "models/lcpd_tactical.txd",   dff = "models/lcpd_tactical.dff" },
    { model = 528, name = "Federal Truck",    txd = "models/lcpd_federal.txd",    dff = "models/lcpd_federal.dff" },
    { model = 497, name = "Police Maverick",  txd = "models/lcpd_air.txd",        dff = "models/lcpd_air.dff" },
}

local state = {}
for _, v in ipairs(FLEET) do
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
        outputDebugString("[LCPD Fleet] " .. s.entry.name .. " :: model files missing", 2)
        return
    end

    local txd = engineLoadTXD(s.entry.txd)
    if not txd then
        s.broken = true
        outputDebugString("[LCPD Fleet] " .. s.entry.name .. " :: TXD failed", 2)
        return
    end
    engineImportTXD(txd, model)
    s.txd = txd

    local dff = engineLoadDFF(s.entry.dff)
    if not dff then
        s.broken = true
        outputDebugString("[LCPD Fleet] " .. s.entry.name .. " :: DFF failed", 2)
        return
    end
    s.dff = dff

    if not engineReplaceModel(dff, model) then
        s.attempts = s.attempts + 1
        outputDebugString("[LCPD Fleet] " .. s.entry.name .. " :: replace failed (" .. s.attempts .. "/4)", 2)
        if s.attempts < 4 then
            setTimer(function() s.broken = false; loadModel(model) end, 2500 * s.attempts, 1)
        else
            s.broken = true
        end
        return
    end

    s.loaded = true
    outputDebugString("[LCPD Fleet] " .. s.entry.name .. " ready (model " .. model .. ")")
end

local function scan()
    local vehicles = getElementsByType("vehicle")
    for i = 1, #vehicles do
        local model = getElementModel(vehicles[i])
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
    if getElementType(source) ~= "vehicle" then return end
    local model = getElementModel(source)
    if state[model] then loadModel(model) end
end)

addEventHandler("onClientVehicleEnter", root, function(player)
    if player ~= localPlayer then return end
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
