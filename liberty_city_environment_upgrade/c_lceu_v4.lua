--[[
    liberty_city_environment_upgrade / client
    ------------------------------------------
    Independent, reversible sidewalk + building material upgrade.

    * Full 4K replacement ONLY for paving/concrete names that are not
      owned by the accepted lc_hd_roads resource.
    * Material-preserving detail enhancement for real building facades,
      brick/stone/concrete/metal/roof and a restrained glass pass.
    * World-space decorrelated UVs -> no stretching, no obvious tiling.
    * "world" shaders only: peds, vehicles and other maps are untouched.
    * /lceu off  or  stop resource  => original textures return instantly.
]]

local created = {}
local texCache = {}
local enabled = true
local lastReport = "not applied"

-- These names are driven by lc_hd_roads (the accepted road upgrade).
-- Hard block: this resource must never fight with them.
local ROAD_NAMES = {
    "road_blank256hv", "road_pavetrans", "road_1line256hv", "road_1line256hv128",
    "tar_1line256hv", "road_2line256hv", "road_yellowline256hv",
    "raiseroad_section", "raiseroad_section_mid", "tarmac_64hv", "tar_mix256hv",
    "pave01_128", "pave02_128", "pave03_128", "pave04_128",
    "paveroad2_lbrown64v", "paveroad2_lbrownd64v", "paveroad_lbrown128v",
    "pave_dirty", "tunnelsidewalk", "curb_64h",
    "zebracrossing_64", "whiteline_64h", "dt_yellow_kerby_shit",
}
local ROAD_BLOCK = {}
for _, n in ipairs(ROAD_NAMES) do ROAD_BLOCK[n] = true end

-- Full replacement: 4K weathered concrete for the large flat sidewalk /
-- step surfaces that are currently low resolution or smeared.
local GROUPS = {
    {
        label = "concrete", file = "textures/lc_concrete_4k_v3.jpg",
        fx = "shaders/lceu_replace_v4.fx", worldScale = 0.20, colorLock = 1.0,
        names = {
            "dustyconcrete128", "concrete_64HV", "concretenewb256128",
            "mottled_grey_64HV", "greyground256128", "tar_conc_64H",
            "dirtywhite", "stadium_ground2", "newgrnd2_128",
        },
    },
    {
        label = "stone", file = "textures/lc_stone_4k_v3.jpg",
        fx = "shaders/lceu_replace_v4.fx", worldScale = 0.26, colorLock = 1.0,
        names = {
            "step_64HV", "stepflat_64HV", "ledgetop_64HV",
            "flatslates_blue64hv", "rubble128HV",
        },
    },
    {
        label = "facade", file = "textures/facade_detail_4k.png",
        fx = "shaders/lceu_detail.fx", worldScale = 0.30,
        sharpen = 0.45, detailStrength = 0.17,
        names = {
            -- industrial / warehouse blocks
            "indnewbuilds01a", "indnewbuilds01d", "indnewbuilds01e", "indnewbuilds01f",
            "singbuild02_back", "singbuild02_front", "warehouse1z", "subindwall2128",
            -- brick and stone facades (identity kept: original colour is the base)
            "indmidbeigebrick64", "tenabrick64", "tenwhitebrick64", "tenreditaly128",
            "indredten128", "italyawalll64", "wallbrown64HV", "wallwhitetinge256",
            "walldirtynewa256hi128", "newall_harling_sless128", "concrete02_64HV",
            -- low / mid rental blocks
            "newall1-1", "newall1-1_16c", "newall11-2", "newall15128",
            "newall5-3_16c128", "newall6_16c", "newall9b_16c", "newall9d_16c128",
            "newallkb1128", "nightnewallkb1128", "newtenmt4", "newtenmt7",
            "indtenbtm128", "indten2btm128", "indten2top128", "tallbuild",
            "tallbuild256", "tallbuildb256", "sffront19a_256128", "sffront20_256128",
            "sffront23_256128", "sffront24_256128", "sffront26_256128",
            -- concrete / tar / roof
            "dustytar_64HV", "sandytar_64HV", "ind_tentop128", "indtentop128",
            "TENterr2_128", "rustyblocks_64HV", "rustyboltpaneltns64",
            -- metal, shutters, doors, frames
            "bluemetal", "bluemetal02", "steel64", "corrugated2", "shutters",
            "Alumox64", "Alumox64b", "alumox64e", "gen_chrome", "chromepipe3_64HV",
            "Plaindoor_128", "Plaindoor_64V", "Industdoor10", "inddoor3",
            "airportdoor1", "pol_build_128", "policewall128beige",
            "policedoor256hi_blank", "policedoortop256hibeige",
            "srrplcf", "itengarage1a", "itengarage1b", "itenblock09a", "itenblock09b",
        },
    },
    {
        label = "glass", file = "textures/facade_detail_4k.png",
        fx = "shaders/lceu_glass.fx", worldScale = 0.34,
        names = {
            "shopwindowlow2_256", "carshowwin2", "dragwin4_128hv",
            "ind_italywinda128", "newchina01",
        },
    },
}

local function getTexture(path)
    local t = texCache[path]
    if not isElement(t) then
        t = dxCreateTexture(path, "argb", true, "wrap")
        texCache[path] = t or false
    end
    return isElement(t) and t or nil
end

local function destroyAll()
    for _, item in ipairs(created) do
        if isElement(item.shader) then destroyElement(item.shader) end
    end
    created = {}
end

local function textureSize(tex)
    if not dxGetMaterialSize then return "?" end
    local ok, w, h = pcall(dxGetMaterialSize, tex)
    if ok and w then return w .. "x" .. h end
    return "?"
end

local function applyGroup(group)
    local tex = getTexture(group.file)
    if not tex then
        local fe = fileExists(group.file) and "yes" or "no"
        local fs = fileExists(group.file) and tostring(fileGetSize(group.file)) or "0"
        outputDebugString("[LCEU] FAILED texture " .. group.label .. " " .. group.file .. " clientFile=" .. fe, 1)
        return group.label .. "=FAIL(file=" .. fe .. ",bytes=" .. fs .. ")"
    end

    local shader, tech = dxCreateShader(group.fx, 0, 0, false, "world")
    if not shader then
        outputDebugString("[LCEU] FAILED shader " .. group.label .. " " .. group.fx, 1)
        return group.label .. "=FAIL"
    end

    if group.fx:find("replace", 1, true) then
        dxSetShaderValue(shader, "hdTexture", tex)
        dxSetShaderValue(shader, "worldScale", group.worldScale)
        dxSetShaderValue(shader, "colorLock", group.colorLock)
    elseif group.fx:find("detail", 1, true) then
        dxSetShaderValue(shader, "detailTexture", tex)
        dxSetShaderValue(shader, "texel", { 1 / 512, 1 / 512 })
        dxSetShaderValue(shader, "sharpen", group.sharpen)
        dxSetShaderValue(shader, "detailStrength", group.detailStrength)
        dxSetShaderValue(shader, "worldScale", group.worldScale)
    else
        dxSetShaderValue(shader, "detailTexture", tex)
        dxSetShaderValue(shader, "worldScale", group.worldScale)
    end

    local applied, skipped = 0, 0
    for _, name in ipairs(group.names) do
        if ROAD_BLOCK[name:lower()] then
            skipped = skipped + 1
        elseif engineApplyShaderToWorldTexture(shader, name) then
            applied = applied + 1
        end
    end

    created[#created + 1] = { shader = shader, texture = tex }
    outputDebugString(string.format("[LCEU] %s %s applied=%d/%d tech=%s",
        group.label, textureSize(tex), applied, #group.names, tostring(tech or "?")), 0)
    return group.label .. "=" .. textureSize(tex) .. "(" .. applied .. "/" .. #group.names .. ")"
end

local function applyAll()
    destroyAll()
    local out = {}
    for _, group in ipairs(GROUPS) do
        out[#out + 1] = applyGroup(group)
    end
    lastReport = "V4 " .. table.concat(out, " ")
    triggerServerEvent("lceu:ready", localPlayer, lastReport)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(function()
        if enabled then applyAll() end
    end, 400, 1)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    destroyAll()
    for _, tex in pairs(texCache) do
        if isElement(tex) then destroyElement(tex) end
    end
    texCache = {}
end)

addEvent("lceu:setState", true)
addEventHandler("lceu:setState", root, function(on)
    if type(on) ~= "boolean" then return end
    enabled = on
    if enabled then
        applyAll()
    else
        destroyAll()
        lastReport = "OFF - original textures restored"
    end
    outputDebugString("[LCEU] toggle -> " .. tostring(enabled), 0)
    triggerServerEvent("lceu:ready", localPlayer, lastReport)
end)

addEvent("lceu:status", true)
addEventHandler("lceu:status", root, function()
    triggerServerEvent("lceu:ready", localPlayer, lastReport)
end)

-- Read-only performance diagnostic (no visual change).
addEvent("lceu:diag", true)
addEventHandler("lceu:diag", root, function()
    local d = dxGetStatus() or {}
    local keys = { "VideoMemoryUsedByTextures", "VideoMemoryUsedByRenderTargets",
                   "VideoMemoryUsedByFonts", "VideoMemoryUsedByMeshes",
                   "VideoMemoryUsedByShaders", "TextureCount", "RenderTargetCount",
                   "ShaderCount", "FontCount", "MeshCount", "DisplayMode",
                   "VideoCardName", "DriverVersion", "VideoCardRAM" }
    local out = {}
    for _, k in ipairs(keys) do
        local v = d[k]
        if type(v) == "number" then v = math.floor(v) end
        out[#out + 1] = k .. "=" .. tostring(v)
    end
    local ok, ps = pcall(function() return getPerformanceStats() end)
    if ok and type(ps) == "table" then
        for k, v in pairs(ps) do
            if type(v) ~= "table" then out[#out + 1] = "PS_" .. tostring(k) .. "=" .. tostring(v) end
        end
    else
        out[#out + 1] = "PS=unavailable"
    end
    triggerServerEvent("lceu:diagReport", localPlayer, table.concat(out, " "))
end)


