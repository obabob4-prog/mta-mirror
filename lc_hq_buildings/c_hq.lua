--[[
    lc_hq_buildings / client
    ------------------------
    1. Adds lost micro-detail to the original LC building textures without
       replacing their artwork (unsharp mask + subtle luminance grain).
    2. Keeps LOD distances inside the 325 m range where GTA still fades models
       instead of popping them, instead of pushing every model to 900 m and
       every plant to 2500 m (low LOD objects multiply that by 5). Categories
       are still classified by real bounding-box height/name:
          buildings 380 m, landmarks 850 m, roads 650 m, vegetation 1200-1400 m
       but the effective high-model switch is capped at 325 m; low LOD objects
       receive the matching fifth of that value, low LOD buildings 305-325 m.
       The original engine distance of every model is saved before the first
       change and restored when the resource stops.
    3. Breaks exact coplanarity of overlapping road tiles by 8 mm, and only
       when two thin road plates really overlap (bounding boxes + top height).
       The old build lifted every road tile within 24 m, which produced visible
       steps on junctions.

    Nothing here modifies IMG / TXD archives, terrain geometry or the map files
    at runtime.
]]

local created = {}
local SHARPEN = 0.22

-- Exact world-texture names captured from the live lab-area models by the
-- lc_audit texture probe. Excludes the main road/sidewalk names already
-- replaced outright by lc_hd_roads, so the two shaders never fight.
local BUILDING_TEXTURES = {
    "wood02", "cratetop128", "raffles_128", "striplights", "striplights2", "striplights02",
    "exitgreen", "bluemetal04", "warehouse1z", "newtenmt7", "newtenmt4",
    "srrplcf", "itengarage1b", "itengarage1a", "itenblock09b", "itenblock09a",
    "newchina01", "concrete02_64HV", "indmidbeigebrick64", "nightnewallkb1128",
    "newall_harling_sless128", "italyawalll64", "TENterr2_128", "ledge_uni_64H",
    "ind_italywinda128", "artgal_128", "dirtyblack_matte", "inddoor3",
    "tenabrick64", "ind_tentop128", "indtentop128", "tenreditaly128",
    "indredten128", "tenwhitebrick64", "tenwhite128", "flatslates_blue64hv",
    "support_water256", "subindwall2128", "step_64HV", "stepflat_64HV",
    "rustyboltpaneltns64", "alumox64e", "floodlight",
    "carshowwin2", "Xrail_64",
    "bluemetal", "bluemetal02", "gridnorm_64HV", "greyfence", "chromepipe3_64HV",
    "Miamibeige256", "SupaSave02_64", "SupaSave01_64", "Aascaff_64HV", "aascaff",
    "ClothesClub01_64", "ClothesClub02_64", "runwaylight_64", "darkgrey64",
    "pipe64v", "ladderbase4_64", "hangingwires1", "compcouwall1",
    "clukpost1_lae2", "cluckbell02_law", "stadium_ground2",
    "dt_yellow_kerby_shit", "dt_scyscrap5", "banding7_64hv", "gen_chrome",
    "generatorfront1_256", "wallwhitetinge256", "dt_bulkhead_light1",
    "vgnstripwall1_256", "shopwindowlow2_256", "247sign2", "247sign1",
    "poster3_64a", "poster2_64a", "poster1_64a", "gen_gym1_256",
    "cbchallenge_256", "black128", "concretenewb256128", "dustytar_64HV",
    "newallkb1128", "newall5-3_16c128", "taxi_256", "taxi_256128",
    "sandytar_64HV", "dogpillar_128", "PoliceParking_64", "Plaindoor_128",
    "Plaindoor_64V", "pol_build_128", "Alumox64", "Alumox64b",
    "newall1-1_16c", "newall6_16c", "newgrnd2_128", "newall1-1", "dirty_64",
    "Industdoor10", "newall9d_16c128", "tallbuild256", "redlitblankdark3_128hv",
    "tallbuildb256", "sffront23_256128", "sffront19a_256128",
    "gourmetdeli256hi128", "sffront20_256128", "sffront24_256128",
    "delilib256128", "sffront26_256128", "atpspage", "indten2btm128",
    "indtenbtm128", "rustyblocks_64HV", "indten2top128", "dragwin4_128hv",
    "dragwall4_128hv", "chipboardgrating64HV", "shopgrating128H",
    "vent_64", "Grass_128HV", "mottled_grey_64HV", "ledgetop_64HV",
    "walldirtynewa256hi128", "ind_hospital1_128", "ind_hospital2_128", "greyground256128",
    "cutscenebank128", "sky33_64hv", "airportdoor1", "newall15128",
    "AmbulanceParking_64", "hospitalboard_128a", "burnt_faggots64",
    "policewall128beige", "policedoor256hi_blank", "newall9b_16c",
    "policerepeat256beige", "policedoortop256hibeige", "policetop64", "policebottom256hi",
    "rubble128HV", "dirtywhite", "rustb128", "steel64", "USAflag",
    "Strip_weathered_64HV", "newall11-2", "corrugated2", "shutters",
    "black64", "darkdirt", "black64a", "black64c",
}

local function applyDetailShader()
    -- "world" keeps this off peds and vehicles even if a texture name matches.
    local shader, tech = dxCreateShader("hq_detail.fx", 0, 0, false, "world")
    if not shader then
        outputDebugString("[lc_hq_buildings] shader compile failed - original textures kept", 1)
        triggerServerEvent("lc_hq:diag", localPlayer, "FAILED", 0, #BUILDING_TEXTURES)
        return
    end
    dxSetShaderValue(shader, "texel", { 1 / 512, 1 / 512 })
    dxSetShaderValue(shader, "sharpen", SHARPEN)

    local applied = 0
    for _, name in ipairs(BUILDING_TEXTURES) do
        if engineApplyShaderToWorldTexture(shader, name) then
            applied = applied + 1
        end
    end
    created[#created + 1] = shader
    outputDebugString("[lc_hq_buildings] detail shader applied to " .. applied .. " textures", 0)
    triggerServerEvent("lc_hq:diag", localPlayer, tostring(tech or "?"), applied, #BUILDING_TEXTURES)
end

-- ---------------------------------------------------------------------------
-- LOD policy
-- ---------------------------------------------------------------------------
-- engineSetModelLODDistance is applied to BOTH sides of a linked pair. The
-- low LOD must never be closer than the high model or MTA keeps drawing the
-- coarse twin on top of the detailed one.
--
-- Distances are deliberately conservative: a 900 m blanket kept full-detail
-- buildings (and 2500 m kept flat plant impostors) alive far beyond the point
-- where they are readable. That wasted geometry/draw calls and exposed
-- low-detail district shells at close range.

local originalLOD = {}
local appliedLOD = {}
local stats = { building = 0, landmark = 0, veg = 0, road = 0 }

local VEG_PATTERNS = {
    "veg", "grass", "bush", "tree", "foliage", "plant", "palm",
    "fern", "indtreepatch", "firegrass",
}
local LANDMARK_PATTERNS = {
    "skyscrap", "scrapenew", "tower", "stadium", "bridge", "bridg",
    "cathedral", "hospital", "police", "airport", "mansion", "colum",
    "station", "dam", "lift",
}
local ROAD_PATTERN = "^rd_"

local function matchesAny(id, patterns)
    id = tostring(id or ""):lower()
    for _, pattern in ipairs(patterns) do
        if id:find(pattern, 1, true) then return true end
    end
    return false
end

local function getModelDistance(model)
    if type(engineGetModelLODDistance) ~= "function" then return nil end
    local ok, dist = pcall(engineGetModelLODDistance, model)
    if ok and tonumber(dist) then return tonumber(dist) end
    return nil
end

local function saveOriginalDistance(model)
    if originalLOD[model] == nil then
        local dist = getModelDistance(model)
        if dist then originalLOD[model] = dist end
    end
end

-- MTA specifics (wiki, engineSetModelLODDistance):
--   * high models above 325 lose their fade and pop in/out
--   * low LOD *objects* use 5x the supplied value as actual draw distance
--   * low LOD *buildings* need a value above 300 to work at all
-- Therefore we cap the real switch distance at 325 (the last value with a
-- smooth fade) and derive the raw argument from the element type.
local MAX_FADE_DISTANCE = 325

local function setModelDistance(model, target, isLow, elementType)
    if type(engineSetModelLODDistance) ~= "function" then return false end
    if not model or model <= 0 then return false end
    target = math.min(math.floor(target + 0.5), MAX_FADE_DISTANCE)
    if isLow then
        if elementType == "object" then
            target = math.max(1, math.floor(target / 5 + 0.5)) -- 5x multiplier
        else
            target = math.max(305, target)                     -- low buildings
        end
    end
    saveOriginalDistance(model)
    -- Never fight a model the map already keeps beyond 1200 m (distant land,
    -- seabed, airport shells). Reducing those creates holes in the horizon.
    local original = originalLOD[model]
    if original and original > 1200 and target < original then
        target = original
    end
    if appliedLOD[model] == target then return false end
    -- extendedLod is only needed when an untouched map value is above 325.
    local ok = pcall(engineSetModelLODDistance, model, target, target > MAX_FADE_DISTANCE)
    if ok then
        appliedLOD[model] = target
        return true
    end
    return false
end

-- getElementBoundingBox returns local min/max and needs a streamed element.
local function localHeight(element)
    if type(getElementBoundingBox) ~= "function" then return nil end
    local x1, y1, z1, x2, y2, z2 = getElementBoundingBox(element)
    if not x1 then return nil end
    return math.abs(z2 - z1)
end

local function targetFor(element)
    local id = tostring(getElementID(element) or "")
    local lower = id:lower()
    local low = getLowLODElement(element)
    local lowId = isElement(low) and tostring(getElementID(low) or "") or ""

    if matchesAny(id, VEG_PATTERNS) or matchesAny(lowId, VEG_PATTERNS) then
        -- 1200-1400 m: enough to hide the cut-off, far less than 2500 m.
        return (lower:find("treepatch", 1, true) and 1200 or 1400), "veg"
    end

    if matchesAny(id, LANDMARK_PATTERNS) then
        return 850, "landmark"
    end
    if lower:find(ROAD_PATTERN) or lower:find("road", 1, true) then
        return 650, "road"
    end

    local height = localHeight(element) or 0
    if height >= 70 then return 900, "landmark" end
    if height >= 35 then return 650, "building" end
    if height >= 12 then return 500, "building" end
    return 380, "building"
end

local function enforceLODDistance()
    stats.building, stats.landmark, stats.veg, stats.road = 0, 0, 0, 0
    local changed = 0

    for _, elementType in ipairs({ "building", "object" }) do
        for _, element in ipairs(getElementsByType(elementType)) do
            local low = getLowLODElement(element)
            if isElement(low) then
                local target, kind = targetFor(element)
                if setModelDistance(getElementModel(element), target, false, elementType) then
                    stats[kind] = stats[kind] + 1
                    changed = changed + 1
                end
                if setModelDistance(getElementModel(low), target, true, getElementType(low)) then
                    changed = changed + 1
                end
            else
                local id = tostring(getElementID(element) or ""):lower()
                if id:find("^lod") then
                    -- Orphan LOD elements are invisible to the pair walk; keep
                    -- them at a readable distance instead of far away.
                    if setModelDistance(getElementModel(element), 500, true, elementType) then
                        changed = changed + 1
                    end
                end
            end
        end
    end

    if changed > 0 then
        outputDebugString(string.format(
            "[lc_hq_buildings] LOD policy: %d models adjusted (buildings %d, landmarks %d, roads %d, vegetation %d)",
            changed, stats.building, stats.landmark, stats.road, stats.veg), 0)
        triggerServerEvent("lc_hq:diag", localPlayer, "LOD", changed, stats.veg)
    end
end

-- ---------------------------------------------------------------------------
-- Road coplanarity guard (max 1 cm, overlap-verified)
-- ---------------------------------------------------------------------------

local ROAD_LIFT = 0.008
local ROAD_LIFT_LIMIT = 0.01

local function undoRoadLift()
    local undone = 0
    for _, elementType in ipairs({ "building", "object" }) do
        for _, element in ipairs(getElementsByType(elementType)) do
            local lift = tonumber(getElementData(element, "lc_hq:roadLift"))
            if lift and lift > 0 then
                local x, y, z = getElementPosition(element)
                setElementPosition(element, x, y, z - lift)
                setElementData(element, "lc_hq:roadLift", nil)
                undone = undone + 1
            end
        end
    end
    if undone > 0 then
        outputDebugString("[lc_hq_buildings] restored " .. undone .. " lifted road tiles", 0)
    end
end

-- World-space XY box + top height for a thin road plate. Only Z rotation is
-- used: every LC road tile is a flat plate and rx/ry are zero or negligible.
local function roadBox(element)
    local x, y, z = getElementPosition(element)
    local x1, y1, z1, x2, y2, z2 = getElementBoundingBox(element)
    if not x1 then return nil end
    local height = math.abs(z2 - z1)
    if height > 2.5 then return nil end

    local halfW, halfD = math.abs(x2 - x1) / 2, math.abs(y2 - y1) / 2
    if halfW < 2 or halfD < 2 then return nil end
    local cx, cy = (x1 + x2) / 2, (y1 + y2) / 2
    local _, _, rz = getElementRotation(element)
    rz = math.rad(rz or 0)
    local c, s = math.cos(rz), math.sin(rz)
    local ex = math.abs(c) * halfW + math.abs(s) * halfD
    local ey = math.abs(s) * halfW + math.abs(c) * halfD
    return {
        element = element,
        id = tostring(getElementID(element) or ""),
        x0 = x + cx - ex, x1 = x + cx + ex,
        y0 = y + cy - ey, y1 = y + cy + ey,
        top = z + math.max(z1, z2),
        bottom = z + math.min(z1, z2),
    }
end

local function overlaps(a, b)
    local dx = math.min(a.x1, b.x1) - math.max(a.x0, b.x0)
    local dy = math.min(a.y1, b.y1) - math.max(a.y0, b.y0)
    return dx > 0.5 and dy > 0.5
end

local function fixRoadCoplanarity()
    undoRoadLift()

    local CELL = 16
    local cells, entries = {}, {}
    for _, elementType in ipairs({ "building", "object" }) do
        for _, element in ipairs(getElementsByType(elementType)) do
            local box = roadBox(element)
            if box then
                local id = box.id:lower()
                if id:find("^rd_") or id:find("road", 1, true) or id:find("street", 1, true) then
                    local x, y = getElementPosition(element)
                    if math.abs(x) < 3000 and math.abs(y) < 3000 then
                        entries[#entries + 1] = box
                        for ix = math.floor(box.x0 / CELL), math.floor(box.x1 / CELL) do
                            for iy = math.floor(box.y0 / CELL), math.floor(box.y1 / CELL) do
                                local key = ix .. "," .. iy
                                cells[key] = cells[key] or {}
                                cells[key][#cells[key] + 1] = box
                            end
                        end
                    end
                end
            end
        end
    end

    local lifted = 0
    for _, list in pairs(cells) do
        for i = 1, #list do
            for j = i + 1, #list do
                local a, b = list[i], list[j]
                if a.element ~= b.element
                    and math.abs(a.top - b.top) < 0.012
                    and overlaps(a, b) then
                    -- Lift only the lexicographically later plate of the pair.
                    local target = nil
                    if a.id > b.id or (a.id == b.id and tostring(a.element) > tostring(b.element)) then
                        target = a
                    else
                        target = b
                    end
                    if target and not getElementData(target.element, "lc_hq:roadLift") then
                        local x, y, z = getElementPosition(target.element)
                        local amount = math.min(ROAD_LIFT, ROAD_LIFT_LIMIT)
                        setElementData(target.element, "lc_hq:roadLift", amount)
                        setElementPosition(target.element, x, y, z + amount)
                        lifted = lifted + 1
                    end
                end
            end
        end
    end

    if lifted > 0 then
        outputDebugString("[lc_hq_buildings] road z-fight guard lifted " .. lifted .. " of " .. #entries .. " road plates by 8 mm", 0)
        triggerServerEvent("lc_hq:diag", localPlayer, "ROADLIFT", lifted, #entries)
    end
end

-- ---------------------------------------------------------------------------
-- World readiness
-- ---------------------------------------------------------------------------
-- LC streams asynchronously and can take 90+ s on a cold client. Run the
-- fixes once the building count is stable, then re-check slowly for elements
-- that streamed in later. Both routines are idempotent.
local worldFixDone = false
local lastCount, stablePolls = 0, 0

local function runWorldFixes()
    -- LOD override disabled: forcing full and low-LOD buildings to the same
    -- short fade distance made both draw at once, producing foggy, non-solid
    -- ghost buildings stacked on the real ones. Original map LOD is restored
    -- on resource stop and is now left untouched.
    -- enforceLODDistance()
    fixRoadCoplanarity()
end

local function waitForWorld(attempt)
    if worldFixDone then return end
    local count = #getElementsByType("building")
    if count >= 1500 then
        if count == lastCount then
            stablePolls = stablePolls + 1
        else
            stablePolls = 0
        end
        lastCount = count
        if stablePolls >= 2 then
            worldFixDone = true
            runWorldFixes()
            triggerServerEvent("lc_hq:diag", localPlayer, "WORLDREADY", count, attempt)
            setTimer(runWorldFixes, 60000, 0)
            return
        end
    end
    if attempt >= 200 then
        runWorldFixes()
        triggerServerEvent("lc_hq:diag", localPlayer, "WORLDTIMEOUT", count, attempt)
        return
    end
    setTimer(waitForWorld, 1500, 1, attempt + 1)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Remove any lift applied by an older build immediately.
    undoRoadLift()
    setTimer(applyDetailShader, 1500, 1)
    setTimer(waitForWorld, 1500, 1, 1)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, shader in ipairs(created) do
        if isElement(shader) then destroyElement(shader) end
    end
    created = {}

    -- Restore every model distance that was changed, then drop all state.
    if type(engineSetModelLODDistance) == "function" then
        for model, dist in pairs(originalLOD) do
            pcall(engineSetModelLODDistance, model, dist, true)
        end
    end
    originalLOD = {}
    appliedLOD = {}

    undoRoadLift()
end)
