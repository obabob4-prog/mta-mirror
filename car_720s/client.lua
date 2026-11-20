-- [LuxuryCars] McLaren 720S
-- Resource: car_720s | Replaces stock model ID: 506
-- Source: https://www.gtaall.com/gta-san-andreas/cars/234833-mclaren-720s-award.html
--
-- Lazy loader: the model is loaded on this client only when a vehicle of
-- this model actually streams in. This keeps client memory low even with
-- a 40-car pack installed.

local VEHICLE_MODEL = 506
local TXD_FILE = "models/elegy.txd"
local DFF_FILE = "models/elegy.dff"
local ALPHA = true   -- transparent windows / lights (set false if a car shows see-through body)

local loaded, broken, scanTimer, attempts = false, false, nil, 0
local txdElement, dffElement = nil, nil

local function stopScan()
    if isTimer(scanTimer) then killTimer(scanTimer) end
    scanTimer = nil
end

local function loadModel()
    if loaded or broken or attempts >= 4 then return end
    if isElement(txdElement) then destroyElement(txdElement) end
    if isElement(dffElement) then destroyElement(dffElement) end
    txdElement, dffElement = nil, nil
    engineRestoreModel(VEHICLE_MODEL)
    if engineResetModelTXD then engineResetModelTXD(VEHICLE_MODEL) end
    if not fileExists(TXD_FILE) or not fileExists(DFF_FILE) then
        broken = true
        stopScan()
        outputDebugString("[LuxuryCars] " .. "car_720s" .. " :: model files missing", 2)
        return
    end

    local txd = engineLoadTXD(TXD_FILE)
    if not txd then
        broken = true
        stopScan()
        outputDebugString("[LuxuryCars] " .. "car_720s" .. " :: TXD failed", 2)
        return
    end
    engineImportTXD(txd, VEHICLE_MODEL)
    txdElement = txd

    local dff = engineLoadDFF(DFF_FILE)
    if not dff then
        broken = true
        stopScan()
        outputDebugString("[LuxuryCars] " .. "car_720s" .. " :: DFF failed", 2)
        return
    end
    dffElement = dff
    if not engineReplaceModel(dff, VEHICLE_MODEL) then
        attempts = attempts + 1
        outputDebugString("[LuxuryCars] " .. "car_720s" .. " :: replace failed", 2)
        if attempts < 4 then
            setTimer(function() broken = false; loadModel() end, 2500 * attempts, 1)
        else
            broken = true
            stopScan()
        end
        return
    end

    loaded = true
    stopScan()
    outputDebugString("[LuxuryCars] McLaren 720S ready (model 506)")
end

local function scan()
    if loaded or broken then return end
    local vehicles = getElementsByType("vehicle")
    for i = 1, #vehicles do
        if getElementModel(vehicles[i]) == VEHICLE_MODEL then
            loadModel()
            return
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    scan()
    if not loaded and not broken then
        scanTimer = setTimer(scan, 4000, 0)
    end
end)

addEventHandler("onClientElementStreamIn", root, function()
    if loaded or broken then return end
    if getElementType(source) == "vehicle" and getElementModel(source) == VEHICLE_MODEL then
        loadModel()
    end
end)

addEventHandler("onClientVehicleEnter", root, function(player)
    if loaded or broken then return end
    if player == localPlayer and getElementModel(source) == VEHICLE_MODEL then
        loadModel()
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    stopScan()
    if loaded then engineRestoreModel(VEHICLE_MODEL) end
    if engineResetModelTXD then engineResetModelTXD(VEHICLE_MODEL) end
    if isElement(txdElement) then destroyElement(txdElement) end
    if isElement(dffElement) then destroyElement(dffElement) end
end)