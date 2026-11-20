--[[
    lc_peds - HD GTA V female player models for Lmbaw9in RP
    -------------------------------------------------------
    Independent resource. Owns the 10 female stock IDs only;
    ng-skins owns the male IDs and lmb_police_skins owns police IDs.

    Source: "Womens Mega Pack by 7 Pack" (gtaall.com), GTA V / GTA Online
    female pedestrian conversions. All models are static merged meshes,
    the same structure as the already-working ng-skins / lmb_police_skins.

    9   = Executive Black    (bfori)
    12  = Downtown Casual    (wfybu)
    13  = Modern Street      (dnfolc2)
    40  = Latina Socialite   (hfyri)
    56  = Asian Socialite    (ofyri)
    88  = Executive White    (wfori)
    93  = Asian Business     (ofori)
    141 = Nightlife Chic     (sofybu)
    190 = LCPD Officer       (copgrl3)
    195 = Street Fashion     (gangrl3)

    The selection lists live in sCharacterCreator/config.lua,
    ng-characters, and ng-shops. Keep those lists identical.
]]

local PACKS = {
    { id = 9,   dff = "models/9_bfori.dff",     txd = "models/9_bfori.txd",     name = "Executive Black" },
    { id = 12,  dff = "models/12_wfybu.dff",    txd = "models/12_wfybu.txd",    name = "Downtown Casual" },
    { id = 13,  dff = "models/13_dnfolc2.dff",  txd = "models/13_dnfolc2.txd",  name = "Modern Street" },
    { id = 40,  dff = "models/40_hfyri.dff",    txd = "models/40_hfyri.txd",    name = "Latina Socialite" },
    { id = 56,  dff = "models/56_ofyri.dff",    txd = "models/56_ofyri.txd",    name = "Asian Socialite" },
    { id = 88,  dff = "models/88_wfori.dff",    txd = "models/88_wfori.txd",    name = "Executive White" },
    { id = 93,  dff = "models/93_ofori.dff",    txd = "models/93_ofori.txd",    name = "Asian Business" },
    { id = 141, dff = "models/141_sofybu.dff",  txd = "models/141_sofybu.txd",  name = "Nightlife Chic" },
    { id = 190, dff = "models/190_copgrl3.dff", txd = "models/190_copgrl3.txd", name = "LCPD Officer" },
    { id = 195, dff = "models/195_gangrl3.dff", txd = "models/195_gangrl3.txd", name = "Street Fashion" },
}

local loaded = {}

local function loadPack()
    for _, p in ipairs(PACKS) do
        local txd = engineLoadTXD(p.txd)
        local txdOk = txd and engineImportTXD(txd, p.id)
        local dff = engineLoadDFF(p.dff, p.id)
        local dffOk = dff and engineReplaceModel(dff, p.id)
        if txdOk and dffOk then
            loaded[p.id] = true
            outputDebugString("[lc_peds] loaded: " .. p.name .. " (skin " .. p.id .. ")")
        else
            outputDebugString("[lc_peds] FAILED: " .. p.name .. " (skin " .. p.id .. ")", 2)
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, loadPack)

-- Re-apply after server resource restarts that drop client replacements.
addEventHandler("onClientResourceStop", resourceRoot, function()
    for id, ok in pairs(loaded) do
        if ok then
            engineRestoreModel(id)
        end
    end
    loaded = {}
end)
