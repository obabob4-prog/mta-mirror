--[[ ============================================================
     lc_hd_roads / client  -  TRUE texture replacement (2K / 1K / 512)
     ------------------------------------------------------------
     Every LC road / sidewalk texture is replaced outright by a
     clean tileable surface. 2048px is tried first, then 1024px,
     then the original 512px. All variants are declared in meta.xml
     so the client actually downloads them. Nothing is layered.

     Markings are baked into the PNG that matches each original
     texture name, so lane lines stay exactly where they belong.
     No IMG / TXD archives are touched. Stop = full restore.
     ============================================================ ]]

local created = {}

-- One shader per look, applied to EXACT original texture names (no wildcards
-- that could catch walls or unrelated world textures).
local GROUPS = {
    {
        label = "blank",
        marks = true,
        png   = "road_blank_2k.png",
        names = { "Road_blank256HV", "Road_pavetrans", "raiseroad_section", "raiseroad_section_mid" },
    },
    {
        label = "line1",
        marks = true,
        png   = "road_line1_2k.png",
        names = { "Road_1line256HV", "Road_1line256HV128", "Tar_1line256HV" },
    },
    {
        label = "line2",
        marks = true,
        png   = "road_line2_2k.png",
        names = { "Road_2line256HV" },
    },
    {
        label = "yellow",
        marks = true,
        png   = "road_yellow_2k.png",
        names = { "Road_yellowline256HV" },
    },
    {
        label = "tar",
        marks = true,
        png   = "road_tar_2k.png",
        names = { "Tar_mix256HV", "tarmac_64HV" },
    },
    {
        label = "pave",
        marks = false,
        png   = "pave_slabs_2k.png",
        names = {
            "Pave01_128", "Pave02_128", "Pave03_128", "Pave04_128",
            "Paveroad2_lbrown64V", "Paveroad2_lbrownd64V", "Paveroad_lbrown128V",
            "pave_dirty", "tunnelsidewalk",
        },
    },
    {
        label = "curb",
        marks = false,
        png   = "curb_stone_2k.png",
        names = { "curb_64H" },
    },
}

local function tryTexture(path)
    local tex = dxCreateTexture(path, "argb", true, "wrap")
    if tex then return tex, path end

    local oneK = path:gsub("_2k%.png$", "_1k.png")
    if oneK ~= path then
        tex = dxCreateTexture(oneK, "argb", true, "wrap")
        if tex then return tex, oneK end
    end

    local five12 = path:gsub("_[12]k%.png$", ".png")
    if five12 ~= path then
        tex = dxCreateTexture(five12, "argb", true, "wrap")
        if tex then return tex, five12 end
    end
    return nil, path
end

local function applyGroup(group)
    local tex, used = tryTexture(group.png)
    if not tex then
        outputDebugString("[lc_hd_roads] FAILED texture " .. group.label .. " (" .. tostring(group.png) .. ")", 1)
        return group.label .. "=FAIL"
    end
    if used ~= group.png then
        outputDebugString("[lc_hd_roads] " .. group.label .. ": " .. group.png .. " failed, using " .. used, 2)
    end
    -- Restrict to world textures so a same-named vehicle/ped skin is never hit.
    local shader, tech = dxCreateShader("hd_roads.fx", 0, 0, false, "world")
    if not tex or not shader then
        outputDebugString("[lc_hd_roads] FAILED create " .. group.label, 1)
        if isElement(tex) then destroyElement(tex) end
        if isElement(shader) then destroyElement(shader) end
        return group.label .. "=FAIL"
    end

    dxSetShaderValue(shader, "hdTexture", tex)
    -- Keep the original paint geometry for roads; ignore bright sidewalk art.
    dxSetShaderValue(shader, "preserveMarkings", group.marks and 1 or 0)

    local applied = 0
    for _, name in ipairs(group.names) do
        if engineApplyShaderToWorldTexture(shader, name) then
            applied = applied + 1
        end
    end

    created[#created + 1] = { shader = shader, texture = tex }
    local w, h = 0, 0
    if dxGetMaterialSize then
        local okSize, sw, sh = pcall(dxGetMaterialSize, tex)
        if okSize and sw then w, h = sw, sh or 0 end
    end
    outputDebugString("[lc_hd_roads] " .. group.label .. ": " .. applied .. "/" .. #group.names
        .. " " .. tostring(w) .. "x" .. tostring(h) .. " tech=" .. tostring(tech or "?"), 0)
    return group.label .. "=" .. (applied > 0 and (tostring(w) .. "x" .. tostring(h)) or "FAIL")
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    local ok = {}
    for _, group in ipairs(GROUPS) do
        ok[#ok + 1] = applyGroup(group)
    end
    triggerServerEvent("lc_hd_roads:ready", localPlayer, table.concat(ok, " "))
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, e in ipairs(created) do
        if isElement(e.shader) then destroyElement(e.shader) end
        if isElement(e.texture) then destroyElement(e.texture) end
    end
    created = {}
end)
