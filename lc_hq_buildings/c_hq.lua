--[[
    lc_hq_buildings / client
    ------------------------
    1. Adds lost micro-detail to the original LC building textures without
       replacing their artwork (unsharp mask + subtle luminance grain).
    2. Pushes explicit low-LOD buildings far away so the high-detail model is
       the one seen near the player. This removes the duplicate-building
       overlap reported at the "lab" area.
    3. Breaks exact coplanarity of overlapping road tiles by a few centimetres
       (reversible: stop the resource and restore the map by restarting LC).

    Nothing here modifies IMG / TXD archives.
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

-- engineSetModelLODDistance must be applied to BOTH sides of an LOD pair:
--   * high model -> stops the low-detail twin switching in at 100-300m
--     (that early switch is the city-wide "doubled building" overlap)
--   * low model  -> MTA requires >300 for a low-detail building to behave
--     correctly; otherwise it is drawn permanently on top of the high model.
-- Vegetation/grass LODs are impostor planes, so they are pushed much farther;
-- otherwise they appear as green patches floating in the sky.
local lodApplied = {}
local lodNewPushes = 0
local vegPushes = 0
local VEG_PATTERNS = {
    "veg", "grass", "bush", "tree", "foliage", "plant", "palm",
    "fern", "indtreepatch", "firegrass",
}

local function isVegetation(id)
    id = tostring(id or ""):lower()
    for _, pattern in ipairs(VEG_PATTERNS) do
        if id:find(pattern, 1, true) then return true end
    end
    return false
end

local function pushLODFar(model, target)
    model = tonumber(model)
    target = tonumber(target) or 900
    if not model or model <= 0 then return end
    -- lodApplied is never cleared while the resource runs, so a model first
    -- seen as ordinary (900m) can still be raised later if it is vegetation.
    if (lodApplied[model] or 0) >= target then return end

    if type(engineGetModelLODDistance) ~= "function"
        or type(engineSetModelLODDistance) ~= "function" then
        return
    end
    local okGet, dist = pcall(engineGetModelLODDistance, model)
    dist = okGet and tonumber(dist) or 0
    -- Never reduce a model the map already configured farther away
    -- (e.g. 1800/2000/3000m distant land and seabed LODs).
    if dist > target then
        lodApplied[model] = dist
        return
    end
    local okSet = pcall(engineSetModelLODDistance, model, target, true)
    if okSet then
        lodApplied[model] = target
        lodNewPushes = lodNewPushes + 1
        if target >= 2500 then vegPushes = vegPushes + 1 end
        outputDebugString("[lc_hq_buildings] LOD model " .. model .. " pushed to " .. target .. "m", 0)
    end
end

local function enforceLODDistance()
    for _, elementType in ipairs({ "building", "object" }) do
        for _, e in ipairs(getElementsByType(elementType)) do
            local id = tostring(getElementID(e) or "")
            local low = getLowLODElement(e)
            local veg = isVegetation(id) or (isElement(low) and isVegetation(getElementID(low))) or false
            local lowerId = id:lower()

            -- Push vegetation regardless of whether MTA has an explicit low-LOD
            -- twin linked. Many LC trees/grass patches are standalone billboard
            -- models (e.g. indtreepatch5, veg_tree3): their 100-300m LOD limit
            -- is exactly what makes the flat green plane appear in the sky.
            if veg then
                pushLODFar(getElementModel(e), 2500)
            end

            if isElement(low) then
                pushLODFar(getElementModel(low), veg and 2500 or 900)
                pushLODFar(getElementModel(e), veg and 2500 or 900)
            elseif lowerId:find("^lod") then
                pushLODFar(getElementModel(e), veg and 2500 or 900)
            end
        end
    end
    if vegPushes > 0 then
        triggerServerEvent("lc_hq:diag", localPlayer, "VEG", vegPushes, 2500)
        vegPushes = 0
    end
    if lodNewPushes > 0 then
        triggerServerEvent("lc_hq:diag", localPlayer, "LOD", lodNewPushes, 900)
        lodNewPushes = 0
    end
end

-- Runs IMMEDIATELY on resource start: an older build of this resource raised
-- road tiles by 0.06-0.12 m and flagged them with "lc_hq:roadLift". If we wait
-- for the slow world-stability poll, those visible overlaps stay on screen for
-- a long time after a hot reload. Undo is safe to call repeatedly.
local function undoOldRoadLift()
    local undone = 0
    for _, e in ipairs(getElementsByType("building")) do
        local lift = getElementData(e, "lc_hq:roadLift")
        if tonumber(lift) then
            local x, y, z = getElementPosition(e)
            setElementPosition(e, x, y, z - tonumber(lift))
            setElementData(e, "lc_hq:roadLift", nil)
            undone = undone + 1
        end
    end
    if undone > 0 then
        outputDebugString("[lc_hq_buildings] undid " .. undone .. " old road lifts", 0)
        triggerServerEvent("lc_hq:diag", localPlayer, "UNDO", undone, 0)
    end
end

local function fixRoadCoplanarity()
    -- Idempotent: undo any earlier (larger) lift first, then re-apply the
    -- smallest nudge that still breaks exact coplanarity. The old 0.06-0.12 m
    -- lift made road tiles visibly overlap kerbs/city geometry; 0.01-0.02 m
    -- is enough to kill z-fighting without a visible step.
    undoOldRoadLift()
    local cells, entries = {}, {}
    local CELL = 32
    for _, e in ipairs(getElementsByType("building")) do
        local id = tostring(getElementID(e) or ""):lower()
        if id:find("^rd_") or id:find("road") then
            local x, y, z = getElementPosition(e)
            if math.abs(x) < 3000 and math.abs(y) < 3000 and z < 45 then
                local entry = { e = e, id = id, x = x, y = y, z = z, lift = 0 }
                local key = math.floor(x / CELL) .. "," .. math.floor(y / CELL)
                cells[key] = cells[key] or {}
                cells[key][#cells[key] + 1] = entry
                entries[#entries + 1] = entry
            end
        end
    end

    for _, entry in ipairs(entries) do
        local cx, cy = math.floor(entry.x / CELL), math.floor(entry.y / CELL)
        for ox = -1, 1 do
            for oy = -1, 1 do
                for _, other in ipairs(cells[(cx + ox) .. "," .. (cy + oy)] or {}) do
                    if other ~= entry and other.id > entry.id
                        and math.abs(other.z - entry.z) < 0.05 then
                        local dx, dy = other.x - entry.x, other.y - entry.y
                        if dx * dx + dy * dy < 24 * 24 then
                            entry.lift = math.min(entry.lift + 0.01, 0.02)
                        end
                    end
                end
            end
        end
    end

    local lifted = 0
    for _, entry in ipairs(entries) do
        if entry.lift > 0 and not getElementData(entry.e, "lc_hq:roadLift") then
            setElementData(entry.e, "lc_hq:roadLift", entry.lift)
            setElementPosition(entry.e, entry.x, entry.y, entry.z + entry.lift)
            lifted = lifted + 1
        end
    end
    if lifted > 0 then
        outputDebugString("[lc_hq_buildings] road z-fight guard lifted " .. lifted .. " tiles", 0)
        triggerServerEvent("lc_hq:diag", localPlayer, "ROADLIFT", lifted, #entries)
    end
end

-- LC is streamed in asynchronously and can take 90+ seconds on a cold client.
-- Running the LOD / road-lift fixes on a fixed timer saw zero buildings, so
-- they silently did nothing. Poll until the map is actually present, then run
-- both fixes exactly once.
local worldFixDone = false
local lastCount, stablePolls = 0, 0

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
        -- Wait for two identical consecutive polls so the map has finished
        -- creating elements before we scan them.
        if stablePolls >= 2 then
            worldFixDone = true
            enforceLODDistance()
            fixRoadCoplanarity()
            triggerServerEvent("lc_hq:diag", localPlayer, "WORLDREADY", count, attempt)
            -- Re-apply every 30s in case LC is reloaded or more elements stream in.
            -- lodApplied is intentionally kept so higher vegetation targets are
            -- not lost on a later pass.
            setTimer(function()
                enforceLODDistance()
                fixRoadCoplanarity()
            end, 30000, 0)
            return
        end
    end
    if attempt >= 200 then
        -- Last resort: never leave the map in the overlapping state just
        -- because the element count never stabilised exactly.
        enforceLODDistance()
        fixRoadCoplanarity()
        triggerServerEvent("lc_hq:diag", localPlayer, "WORLDTIMEOUT", count, attempt)
        return
    end
    setTimer(waitForWorld, 1500, 1, attempt + 1)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    undoOldRoadLift() -- clear the old visible city/road overlap right away
    setTimer(applyDetailShader, 1500, 1)
    setTimer(waitForWorld, 1500, 1, 1)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, shader in ipairs(created) do
        if isElement(shader) then destroyElement(shader) end
    end
    created = {}
    lodApplied = {}
end)
