-- GTA V weapon pack -> MTA global model replacement.
-- Source: GTAinside "GTA V Weapon Pack" (id 81041), DFF/TXD only.
-- No CLEO/ASI, no edits inside the GTA game folder.
--
-- Loading is deliberately spread over timer ticks. Loading 30 large weapon
-- TXDs in one frame can stall the client, and blocking model requests can
-- make the player time out. Each model is requested asynchronously and
-- imported only once the GTA streamer reports it as loaded.

local REPLACEMENTS = {
    { name = "ak47",          model = 355 },
    { name = "bat",           model = 336 },
    { name = "bomb",          model = 364 },
    { name = "chromegun",     model = 349 },
    { name = "colt45",        model = 346 },
    { name = "cuntgun",       model = 357 },
    { name = "desert_eagle",  model = 348 },
    { name = "fire_ex",       model = 366 },
    { name = "golfclub",      model = 333 },
    { name = "grenade",       model = 342 },
    { name = "gun_dildo2",    model = 322 },
    { name = "gun_para",      model = 371 },
    { name = "gun_vibe1",     model = 323 },
    { name = "heatseek",      model = 360 },
    { name = "katana",        model = 339 },
    { name = "knifecur",      model = 335 },
    { name = "m4",            model = 356 },
    { name = "micro_uzi",     model = 352 },
    { name = "minigun",       model = 362 },
    { name = "molotov",       model = 344 },
    { name = "mp5lng",        model = 353 },
    { name = "nitestick",     model = 334 },
    { name = "poolcue",       model = 338 },
    { name = "rocketla",      model = 359 },
    { name = "satchel",       model = 363 },
    { name = "sawnoff",       model = 350 },
    { name = "shotgspa",      model = 351 },
    { name = "silenced",      model = 347 },
    { name = "sniper",        model = 358 },
    { name = "teargas",       model = 343 },
}

local requestedModels = {}
local queue = {}
local index = 1
local appliedCount = 0
local failedList = {}
local waitAttempts = {}
local running = false

local function loadState(model)
    if type(engineStreamingGetModelLoadState) ~= "function" then
        return "unavailable"
    end
    local ok, state = pcall(engineStreamingGetModelLoadState, model)
    return ok and tostring(state) or "state-error"
end

local function requestModel(model)
    if type(engineStreamingRequestModel) ~= "function" then
        return "stream-unavailable"
    end
    local ok, result = pcall(engineStreamingRequestModel, model, true, false)
    if ok and result then
        requestedModels[model] = true
        return "requested"
    end
    return "request-failed:" .. tostring(result)
end

local function applyReplacement(entry)
    local state = loadState(entry.model)
    local requestResult = "not-needed"

    -- Weapon models which are not equipped can still be unloaded by the
    -- streamer. Ask for them without blocking the game, then wait a few ticks.
    if state ~= "loaded" and state ~= "unavailable" then
        if not requestedModels[entry.model] then
            requestResult = requestModel(entry.model)
        else
            requestResult = "already-requested"
        end
        waitAttempts[entry.model] = (waitAttempts[entry.model] or 0) + 1
        if waitAttempts[entry.model] <= 30 then
            return "wait", state .. "/" .. requestResult
        end
        return false, "model not loaded (" .. state .. "/" .. requestResult .. ")"
    end

    local diag = state .. "/" .. requestResult
    local txd = engineLoadTXD("textures/" .. entry.name .. ".txd")
    if not txd then
        return false, "TXD load failed (" .. diag .. ")"
    end

    local imported = engineImportTXD(txd, entry.model)
    if not imported then
        return false, "TXD import failed (" .. diag .. ")"
    end

    local dff = engineLoadDFF("models/" .. entry.name .. ".dff")
    if not dff then
        return false, "DFF load failed (" .. diag .. ")"
    end

    local replaced = engineReplaceModel(dff, entry.model)
    if not replaced then
        return false, "DFF replace failed (" .. diag .. ")"
    end

    return true
end

local function finishRun()
    running = false
    outputDebugString("[GTAVW] applied " .. appliedCount .. "/" .. #REPLACEMENTS .. " weapon models")
    triggerServerEvent("gtavw:report", resourceRoot, appliedCount, #REPLACEMENTS, failedList)
end

local function processNext()
    if not running then
        return
    end
    if index > #queue then
        finishRun()
        return
    end

    local entry = queue[index]
    local ok, result, reason = pcall(applyReplacement, entry)

    if ok and result == "wait" then
        setTimer(processNext, 100, 1)
        return
    end

    if ok and result == true then
        appliedCount = appliedCount + 1
    else
        if not ok then
            reason = result
        elseif reason == nil then
            reason = result
        end
        failedList[#failedList + 1] = entry.name .. "[" .. entry.model .. "]: " .. tostring(reason)
    end

    index = index + 1
    setTimer(processNext, 50, 1)
end

local function applyAll()
    if running then
        return
    end
    queue = {}
    for _, entry in ipairs(REPLACEMENTS) do
        queue[#queue + 1] = entry
    end
    index = 1
    appliedCount = 0
    failedList = {}
    waitAttempts = {}
    running = true
    setTimer(processNext, 50, 1)
end

addEventHandler("onClientResourceStart", resourceRoot, applyAll)
addEvent("gtavw:apply", true)
addEventHandler("gtavw:apply", resourceRoot, applyAll)

addEventHandler("onClientResourceStop", resourceRoot, function()
    running = false
    for _, entry in ipairs(REPLACEMENTS) do
        engineRestoreModel(entry.model)
    end
    if type(engineStreamingReleaseModel) == "function" then
        for model in pairs(requestedModels) do
            pcall(engineStreamingReleaseModel, model, true)
        end
    end
    requestedModels = {}
end)
