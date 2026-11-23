resourceLoaded = {}
lodIDsByResource = {}
crashZoneMarkers = {}
local sendLoadDiag -- forward-declared; defined near the bottom of this file
local defaultWorldRemovalApplied = false
local defaultWaterLevelApplied = false
local defaultWorldOcclusionsEnabled

-- Utility: Read all lines from a file handle, returns a table of lines
local function fileToLines(fh)
    if not fh then return {} end
    local size = fileGetSize(fh)
    if not size or size == 0 then fileClose(fh); return {} end
    local data = fileRead(fh, size)
    fileClose(fh)
    local result = {}
    for line in data:gmatch("[^\r\n]+") do
        table.insert(result, line)
    end
    return result
end

local function parseOffsetDirective(line, directive)
    local x, y, z = line:match("^" .. directive .. "%s+([^,]+),([^,]+),([^,]+)%s*$")
    if not (x and y and z) then
        return
    end

    return tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0
end

-- Load a zone .definition file (returns table of attribute tables)
function loadZone(resourceName, zone)
    zone = zone:gsub("%s+", "")
    local path = (":%s/zones/%s/%s.definition"):format(resourceName, zone, zone)
    if not fileExists(path) then
        print(string.format("Unable to find zone: %s", path))
        return
    end
    local xml = xmlLoadFile(path)
    if not xml then return end
    local defs = {}
    for _, node in ipairs(xmlNodeGetChildren(xml)) do
        local attributes = xmlNodeGetAttributes(node)
        -- The containing directory is the authoritative zone. Older generated
        -- definition files (including Nice_Optimized) omit the zone attribute.
        attributes.zone = attributes.zone or zone
        attributes.definitionType = xmlNodeGetName(node)
        getFlags(attributes)
        table.insert(defs, attributes)
    end
    xmlUnloadFile(xml)
    return defs
end

local function getMapInfoOffset(attributes)
    if not (attributes.offsetX or attributes.offsetY or attributes.offsetZ) then
        return
    end

    return {
        x = tonumber(attributes.offsetX) or 0,
        y = tonumber(attributes.offsetY) or 0,
        z = tonumber(attributes.offsetZ) or 0
    }
end

-- Load a zone .map file (returns table of attribute tables with .type field and optional map info offset)
function loadMap(resourceName, zone)
    zone = zone:gsub("%s+", "")
    local path = (":%s/zones/%s/%s.map"):format(resourceName, zone, zone)
    if not fileExists(path) then return end
    local xml = xmlLoadFile(path)
    if not xml then return end
    local entries = {}
    local mapOffset
    for _, node in ipairs(xmlNodeGetChildren(xml)) do
        local attributes = xmlNodeGetAttributes(node)
        local nodeType = xmlNodeGetName(node)
        if nodeType == "info" then
            mapOffset = getMapInfoOffset(attributes) or mapOffset
        else
            attributes.type = nodeType
            table.insert(entries, attributes)
        end
    end
    xmlUnloadFile(xml)
    return entries, mapOffset
end

-- 2026-11-17 gta4gg: these two were called by removeWorldMapConfirm()
-- but never defined anywhere in this resource, so every boot the client
-- threw "attempt to call a nil value" mid-load - an intermittent
-- interference with the LC map streaming.
--
-- 2026-11-22 ROLLBACK: the full native removeGameWorld() sweep broke LC map
-- streaming completely (no client ever fired onPlayerLoad afterwards, so
-- players fell through an empty sky). Restore the exact interior-0 wipe that
-- was live and verified working at 08:48. Interior 13 scenery is a cosmetic
-- issue only; a missing map is not.
function removeGameWorld()
    for i = 0, 50000 do
        removeWorldModel(i, 5000, 0, 0, 0, 0)
    end
end

function restoreGameWorld()
    if restoreAllWorldModels then
        restoreAllWorldModels()
    end
end

-- Remove world map and/or interiors as needed
function removeWorldMapConfirm(water)
    if not removeDefaultMap then
        return
    end

    if water and not defaultWaterLevelApplied then
        setWaterLevel(-10000000)
        defaultWaterLevelApplied = true
    end

    if defaultWorldRemovalApplied then
        -- Keep SA hidden even if something toggles occlusions/water later.
        setOcclusionsEnabled(false)
        if water and defaultWaterLevelApplied then
            setWaterLevel(-10000000)
        end
        return
    end

    if removeDefaultInteriors then
        removeGameWorld()
    else
        for i = 0, 50000 do
            removeWorldModel(i, 5000, 0, 0, 0, 0)
            removeWorldModel(i, 5000, 0, 0, 0, 13)
        end
    end
    if defaultWorldOcclusionsEnabled == nil and getOcclusionsEnabled then
        defaultWorldOcclusionsEnabled = getOcclusionsEnabled()
    end
    setOcclusionsEnabled(false)
    defaultWorldRemovalApplied = true
end

-- Restore the stock GTA:SA world after Eagle has removed it.  This must only
-- run when no Eagle map is loaded (or still unloading), otherwise restored
-- stock geometry can overlap the map that is about to be streamed.
function restoreSAWorld()
    -- This Liberty City server must never show the default San Andreas world.
    -- If removeDefaultMap is enabled, keep SA removed permanently.
    if removeDefaultMap then
        removeWorldMapConfirm(true)
        outputDebugString2("SA world restoration blocked: removeDefaultMap is enabled.")
        return false
    end

    if (resourceElements and next(resourceElements))
        or (unloadingResources and next(unloadingResources))
    then
        outputDebugString2("Cannot restore the GTA:SA world while an Eagle map is still active.", 2)
        return false
    end

    if defaultWorldRemovalApplied then
        restoreGameWorld()
        setOcclusionsEnabled(true)
        defaultWorldOcclusionsEnabled = nil
        defaultWorldRemovalApplied = false
    end

    if defaultWaterLevelApplied then
        if resetWaterLevel then
            resetWaterLevel()
        else
            setWaterLevel(0)
        end
        defaultWaterLevelApplied = false
    end

    engineRestreamWorld(true)
    outputDebugString2("Restored the stock GTA:SA world.")
    return true
end

local function crashZoneAppliesToResource(zone, resourceName)
    return not zone.resource or zone.resource == "" or zone.resource == resourceName
end

local function getCrashZoneForPosition(resourceName, x, y, z, skipOnly)
    for _, zone in ipairs(crashZones or {}) do
        if crashZoneAppliesToResource(zone, resourceName) and (not skipOnly or zone.skip) then
            local dx, dy, dz = x - zone.x, y - zone.y, z - zone.z
            if (dx * dx + dy * dy + dz * dz) <= (zone.radius * zone.radius) then
                return zone
            end
        end
    end
end

local function createCrashZoneMarkers(resourceName)
    if crashZoneMarkers[resourceName] then
        return
    end

    crashZoneMarkers[resourceName] = {}

    for _, zone in ipairs(crashZones or {}) do
        if zone.blip and crashZoneAppliesToResource(zone, resourceName) then
            local blip = createBlip(zone.x, zone.y, zone.z, 0, 3, 255, 0, 0, 255, 0, 99999)
            local area = createRadarArea(
                zone.x - zone.radius,
                zone.y - zone.radius,
                zone.radius * 2,
                zone.radius * 2,
                255,
                0,
                0,
                80
            )

            if isElement(blip) then
                table.insert(crashZoneMarkers[resourceName], blip)
            end
            if isElement(area) then
                table.insert(crashZoneMarkers[resourceName], area)
            end
        end
    end
end

local function destroyCrashZoneMarkers(resourceName)
    for _, element in ipairs(crashZoneMarkers[resourceName] or {}) do
        if isElement(element) then
            destroyElement(element)
        end
    end

    crashZoneMarkers[resourceName] = nil
end

local function isTrueAttribute(value)
    if type(value) == "boolean" then return value end
    if type(value) == "number" then return value ~= 0 end
    if type(value) ~= "string" then return false end
    value = value:lower()
    return value == "true" or value == "1" or value == "yes" or value == "on"
end

local function resolvesToSAPhysicsModel(element, resourceName)
    if not (element and element.id) then
        return false
    end

    local requestedModel = getResourceModelID(resourceName, element.id)
    if requestedModel then
        -- Ordinary custom allocations stay eligible for promotion even when
        -- their logical name matches a stock model. An explicit nativeModel is
        -- different: it deliberately opts into that stock model's behavior.
        local definition = resourceDefinitions[resourceName]
            and resourceDefinitions[resourceName][element.id]
        local nativeValue = definition and (
            definition.nativeModel
            or definition.nativeModelID
            or definition.native_model
            or definition.native_model_id
        )
        local nativeModel = nativeValue
            and (defaultIDs[tostring(nativeValue):gsub("^%s*(.-)%s*$", "%1")]
                or tonumber(nativeValue))
        return nativeModel and isSAPhysicsObjectID(nativeModel) or false
    end

    local model = defaultIDs[element.id] or tonumber(element.id)
    return model and isSAPhysicsObjectID(model) or false
end

local function canPromoteStaticObject(element, overrides, resourceName)
    if not preferStaticBuildings or element.type ~= "object" then
        return false
    end
    if (tonumber(element.dimension) or 0) ~= 0 then
        return false
    end
    if isTrueAttribute(element.dynamic)
        or isTrueAttribute(element.forceObject)
        or isTrueAttribute(element.force_object)
    then
        return false
    end
    if lodAttach and (lodAttach[element.id] or lodAttach[element.lodParent]) then
        return false
    end

    -- Keep physics-tagged stock GTA:SA models on the native object path. Their
    -- object.dat behavior is lost if the static-building optimization recreates
    -- them as buildings. Untagged stock scenery and custom definitions remain
    -- eligible; custom definitions have an idCache entry even when they reuse
    -- a stock logical name.
    if resolvesToSAPhysicsModel(element, resourceName) then
        return false
    end

    -- Preserve object-only behavior when a placement explicitly asks for it
    -- or uses per-instance physics (buildings do not support object physics).
    return not overrides or (
        overrides.breakable == nil
        and overrides.frozen == nil
        and overrides.streamable == nil
        and overrides.scale == nil
        and overrides.simulated ~= true
        and overrides.objectProperties == nil
    )
end

local function ensureBuildingPoolCapacity(elementList, resourceName)
    if not (engineGetPoolCapacity and engineSetPoolCapacity) then
        return
    end

    local requested = 0
    for _, element in ipairs(elementList or {}) do
        if (tonumber(element.dimension) or 0) == 0
            and (element.type == "building"
            or (preferStaticBuildings
                and element.type == "object"
                and not isTrueAttribute(element.dynamic)
                and not isTrueAttribute(element.forceObject)
                and not isTrueAttribute(element.force_object)
                and not resolvesToSAPhysicsModel(element, resourceName)))
        then
            requested = requested + 1
        end
    end

    local okCapacity, currentCapacity = pcall(engineGetPoolCapacity, "building")
    if not okCapacity or not tonumber(currentCapacity) then
        return
    end

    local used = 0
    if engineGetPoolUsedCapacity then
        local okUsed, currentUsed = pcall(engineGetPoolUsedCapacity, "building")
        if okUsed then used = tonumber(currentUsed) or 0 end
    end

    local target = used + requested + math.max(0, tonumber(buildingPoolHeadroom) or 0)
    if target > currentCapacity then
        local ok, result = pcall(engineSetPoolCapacity, "building", target)
        if not ok or result == false then
            outputDebugString2(string.format(
                "Could not grow the building pool from %d to %d; static placements will fall back to objects.",
                currentCapacity, target
            ), 2)
        else
            outputDebugString2(string.format(
                "Expanded the building pool from %d to %d for %d candidate placements.",
                currentCapacity, target, requested
            ))
        end
    end
end

function streamMapElements(resourceName, elementList,offX,offY,offZ, initializeImmediately)
    local objects = {}
    local skippedByCrashZone = {}
    local resourceLODIDs = lodIDsByResource[resourceName] or {}

    for _, element in ipairs(elementList or {}) do
        if not (resourceLODIDs[element.id] and highDefLODs) then
            local elementOffsetX = element.eagleOffsetX or offX
            local elementOffsetY = element.eagleOffsetY or offY
            local elementOffsetZ = element.eagleOffsetZ or offZ
            local x = (tonumber(element.posX) or 0) + elementOffsetX
            local y = (tonumber(element.posY) or 0) + elementOffsetY
            local z = (tonumber(element.posZ) or 0) + elementOffsetZ
            local crashZone = getCrashZoneForPosition(resourceName, x, y, z, true)

            if crashZone then
                skippedByCrashZone[crashZone.name] = (skippedByCrashZone[crashZone.name] or 0) + 1
            else
                local resourcePhysics = resourceDefinitionPhysicsOverrides[resourceName]
                local overrides = mergePlacementOverrides(
                    resourcePhysics and resourcePhysics[element.id],
                    getPlacementOverrides(element)
                )
                local isLowLODElement = (element.type ~= "building") and resourceLODIDs[element.id] and not highDefLODs
                local newElement = streamElement(
                    element.id,
                    element.type,
                    {x, y, z},
                    {tonumber(element.rotX) or 0, tonumber(element.rotY) or 0, tonumber(element.rotZ) or 0},
                    element.interior,
                    element.dimension,
                    element.lodParent,
                    element.uniqueID,
                    not initializeImmediately,
                    isLowLODElement,
                    canPromoteStaticObject(element, overrides, resourceName),
                    resourceName,
                    element.type,
                    overrides
                )
                if newElement then
                    table.insert(objects, newElement)
                end
            end
        end
    end

    for zoneName, count in pairs(skippedByCrashZone) do
        outputDebugString2(string.format("Skipped %d elements in crash zone: %s", count, zoneName))
    end

    return objects
end

-- Handles loading zones, maps, and water on resource start
function onResourceStartTimer(resourceThatStarted)
    -- Some clients cannot resolve other running resources with
    -- getResourceFromName(), so accept either a resource element or a plain
    -- resource name. All loader logic below only needs the name.
    local resourceName = type(resourceThatStarted) == "string"
        and resourceThatStarted
        or (isElement(resourceThatStarted) and getResourceName(resourceThatStarted))
    if not resourceName then
        if sendLoadDiag then sendLoadDiag("load:no-name") end
        return
    end
    local zoneFilePath = (":%s/eagleZones.txt"):format(resourceName)
    local waterFilePath = (":%s/water.dat"):format(resourceName)

    -- A fast map restart can arrive while the previous instance is waiting for
    -- its delayed native cleanup. Retry after that cleanup instead of mixing
    -- the old model/IMG state with the new map load.
    if unloadingResources and unloadingResources[resourceName] then
        setTimer(onResourceStartTimer, (EAGLE_UNLOAD_DELAY_MS or 100) + 25, 1, resourceThatStarted)
        return
    end

    if not fileExists(zoneFilePath) or resourceLoaded[resourceName] then return end

    mapLoadStartTicks[resourceName] = getTickCount()
    local elementList, definitionList = {}, {}
    lodIDsByResource[resourceName] = {}
    local resourceLODIDs = lodIDsByResource[resourceName]
    createCrashZoneMarkers(resourceName)

    -- Load maps first
    local fh = fileOpen(zoneFilePath)
    local maps = fileToLines(fh)

    -- Read optional map/water offsets before the zone names. Water has its own
    -- directive because some converted maps need the geometry and exported
    -- water adjusted independently.
    local offsetX, offsetY, offsetZ = 0, 0, 0
    local waterOffsetX, waterOffsetY, waterOffsetZ = 0, 0, 0
    while maps[1] do
        local directive = maps[1]
        if directive:match("^#offset%s+") then
            local x, y, z = parseOffsetDirective(directive, "#offset")
            if x then
                offsetX, offsetY, offsetZ = x, y, z
            else
                outputDebugString("Invalid eagleZones offset directive: " .. directive, 2)
            end
            table.remove(maps, 1)
        elseif directive:match("^#waterOffset%s+") then
            local x, y, z = parseOffsetDirective(directive, "#waterOffset")
            if x then
                waterOffsetX, waterOffsetY, waterOffsetZ = x, y, z
            else
                outputDebugString("Invalid eagleZones water offset directive: " .. directive, 2)
            end
            table.remove(maps, 1)
        else
            break
        end
    end

    for _, map in ipairs(maps) do
        local mapEntries, mapOffset = loadMap(resourceName, map)
        for _, v in ipairs(mapEntries or {}) do
            if mapOffset then
                v.eagleOffsetX = mapOffset.x
                v.eagleOffsetY = mapOffset.y
                v.eagleOffsetZ = mapOffset.z
            end
            table.insert(elementList, v)
            if v.lodParent then
                resourceLODIDs[v.lodParent] = true
            end
        end
    end


    -- Then definitions. Reuse the already-parsed `maps` list (the zone names are
    -- the same lines) so the stripped #offset header isn't reintroduced by a
    -- second read of the file.
    for _, zone in ipairs(maps) do
        for _, v in ipairs(loadZone(resourceName, zone) or {}) do
            if not (resourceLODIDs[v.id] and highDefLODs) then
                table.insert(definitionList, v)
            end
        end
    end

    removeWorldMapConfirm(true)
    engineRestreamWorld()

    resourceLoaded[resourceName] = true

    local lastDef = definitionList[#definitionList]
    loadMapDefinitions(resourceName, definitionList, lastDef and lastDef.id or true, function()
        -- Definitions now exist, so create each placement directly with its
        -- final model and initialize it in the same pass.
        ensureBuildingPoolCapacity(elementList, resourceName)
        mapElements[resourceName] = streamMapElements(
            resourceName,
            elementList,
            offsetX,
            offsetY,
            offsetZ,
            true
        )
        return true
    end)

    parseWaterDat(
        waterFilePath,
        resourceName,
        waterOffsetX,
        waterOffsetY,
        waterOffsetZ
    )
end

-- A client-side resource load can fail silently (e.g. getResources() is server-only).
-- Run every entry point through one guarded wrapper so the failure reaches the
-- server log as [EAGLE-DIAG] instead of leaving the player in an empty sky.
local mapLoadInProgress = {}
local function startMapSafely(res, phase)
    local name
    if type(res) == "string" then
        name = res
    elseif isElement(res) then
        name = getResourceName(res) or "?"
    else
        if sendLoadDiag then sendLoadDiag(phase .. ":no-resource") end
        return false
    end

    if mapLoadInProgress[name] then return true end
    mapLoadInProgress[name] = true

    local ok, err = pcall(onResourceStartTimer, res)
    if not ok then
        mapLoadInProgress[name] = nil
        if sendLoadDiag then
            sendLoadDiag(phase .. ":err=" .. tostring(err):gsub("[\r\n]", " "):sub(1, 120))
        end
        return false
    end
    return true
end

addEventHandler("onClientResourceStart", root, function(startedResource)
    -- onClientResourceStart passes the started resource via `source`, not as an
    -- argument. Accept both so LC is loaded no matter which form MTA provides.
    local res = startedResource or source
    if not isElement(res) then return end
    local name = getResourceName(res) or "?"
    if not fileExists((":%s/eagleZones.txt"):format(name)) then return end
    startMapSafely(res, "start")
end)

-- 2026-11-19 gta4gg: when eagleLoader (re)starts client-side, map resources such as
-- LC may already be running so no onClientResourceStart event will fire for them.
-- Scan running resources and load any that expose eagleZones.txt, otherwise the
-- client can stay on the removed/default SA world with no LC map streamed.
addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Remove the default SA world/water immediately so no SA geometry is ever visible.
    if removeDefaultMap then
        removeWorldMapConfirm(true)
    end

    -- getResources() is SERVER-ONLY and made this handler error on every client
    -- before LC could load. The map resource name is fixed; fileExists() is the
    -- reliable client-side signal that its files are present and downloaded.
    if not fileExists(":LC/eagleZones.txt") then
        if sendLoadDiag then sendLoadDiag("scan:no-files") end
        return
    end
    startMapSafely("LC", "scan")
end)

addEventHandler("onClientResourceStop", root, function(stoppedResource)
    local resourceName = getResourceName(stoppedResource)
    destroyCrashZoneMarkers(resourceName)
    lodIDsByResource[resourceName] = nil
end)

addEventHandler("eagleLoader:mapSync", resourceRoot, function(mapNames)
    if type(mapNames) ~= "table" then return end
    for _, name in ipairs(mapNames) do
        if type(name) == "string" and fileExists((":%s/eagleZones.txt"):format(name)) then
            startMapSafely(name, "sync")
        end
    end
end)


-- ============================================================
-- Read-only load diagnostics (server logs [EAGLE-DIAG]). Kept in this
-- existing client file because the HTTP mirror only publishes files that
-- already exist there; a brand-new file would 404 for clients.
-- ============================================================
local DIAG_RES = "LC"
local function diagPath(rel) return (":%s/%s"):format(DIAG_RES, rel) end

function sendLoadDiag(phase)
    local zones = {}
    local zp = diagPath("eagleZones.txt")
    if fileExists(zp) then
        local fh = fileOpen(zp)
        local data = ""
        if fh then
            local size = fileGetSize(fh) or 0
            data = size > 0 and fileRead(fh, size) or ""
            fileClose(fh)
        end
        for line in tostring(data):gmatch("[^\r\n]+") do
            local z = line:gsub("%s+", "")
            if z ~= "" and not z:match("^#") then
                local hasMap = fileExists(diagPath("zones/" .. z .. "/" .. z .. ".map"))
                local hasDef = fileExists(diagPath("zones/" .. z .. "/" .. z .. ".definition"))
                zones[#zones + 1] = z .. ":" .. (hasMap and "M" or "-") .. (hasDef and "D" or "-")
            end
        end
    else
        zones[1] = "NO_ZONE_FILE"
    end

    local imgs = {}
    for _, name in ipairs({ "dff", "col", "txd" }) do
        imgs[#imgs + 1] = name .. "=" .. tostring(fileExists(diagPath("imgs/" .. name .. ".img")))
    end

    local defs, elements = 0, 0
    for _ in pairs((type(resourceDefinitions) == "table" and resourceDefinitions[DIAG_RES]) or {}) do
        defs = defs + 1
    end
    for _ in pairs((type(mapElements) == "table" and mapElements[DIAG_RES]) or {}) do
        elements = elements + 1
    end

    triggerServerEvent("eagleLoader:loadDiag", resourceRoot, DIAG_RES, tostring(phase),
        table.concat(zones, ","), table.concat(imgs, ","),
        tostring(type(resourceLoaded) == "table" and resourceLoaded[DIAG_RES]),
        tostring(defs), tostring(elements))
end

-- Fire directly when this script loads; do not depend on event parameters.
setTimer(function() sendLoadDiag("t5") end, 5000, 1)
setTimer(function() sendLoadDiag("t20") end, 20000, 1)

-- Final safety net: some clients receive no useful resource-start event when
-- eagleLoader itself is restarted after LC is already running. Force one
-- guarded load attempt after startup files have had time to arrive.
setTimer(function()
    if resourceLoaded["LC"] then return end
    if not fileExists(":LC/eagleZones.txt") then
        sendLoadDiag("force:no-files")
        return
    end
    startMapSafely("LC", "force")
end, 1500, 1)

addEvent("eagleLoader:requestDiag", true)
addEventHandler("eagleLoader:requestDiag", resourceRoot, function()
    sendLoadDiag("request")
end)
