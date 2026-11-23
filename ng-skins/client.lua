--[[
    ng-skins - the ONLY character models available on this server.
    ------------------------------------------------------------
    Every DFF/TXD below comes directly from D:\022\SKINS\skn\0.
    25 male packs and 16 female packs are remapped onto fixed ped
    model IDs so they can all coexist (the original packs targeted
    many different, conflicting stock IDs).

    The model IDs are shared with ng-characters (MALE_SKINS / FEMALE_SKINS)
    and the outfit lists in ng-shops / lc_premium_interiors.
    lc_peds must stay stopped - it replaces some female IDs with models
    from outside this folder.
]]

local PACKS = {
    -- males
    { id = 14,  dff = "m14_bope.dff",       txd = "m14_bope.txd",       name = "BOPE HD" },
    { id = 15,  dff = "m15_samu.dff",       txd = "m15_samu.txd",       name = "SAMU ByOutfit HD" },
    { id = 18,  dff = "m18_rupra.dff",      txd = "m18_rupra.txd",      name = "ByRupra HD" },
    { id = 19,  dff = "m19_transito.dff",   txd = "m19_transito.txd",   name = "Transito HD" },
    { id = 20,  dff = "m20_mechanic.dff",   txd = "m20_mechanic.txd",   name = "Mechanic HD" },
    { id = 21,  dff = "m21_samu7capa.dff",  txd = "m21_samu7capa.txd",  name = "SAMU By7capa HD" },
    { id = 22,  dff = "business.dff",       txd = "business.txd",       name = "Business Male HD" },
    { id = 23,  dff = "m23_pulaski.dff",    txd = "m23_pulaski.txd",    name = "Pulaski HD" },
    { id = 24,  dff = "m24_red.dff",        txd = "m24_red.txd",        name = "RED HD" },
    { id = 25,  dff = "m25_ghost.dff",      txd = "m25_ghost.txd",      name = "GHOST DZ Blue HD" },
    { id = 26,  dff = "m26_kazide.dff",     txd = "m26_kazide.txd",     name = "ByKAZIDE HD" },
    { id = 27,  dff = "m27_beyby.dff",      txd = "m27_beyby.txd",      name = "ByBeyBy HD" },
    { id = 30,  dff = "bloods.dff",         txd = "bloods.txd",         name = "Bloods HD" },
    { id = 32,  dff = "m32_pmes.dff",       txd = "m32_pmes.txd",       name = "PMES HD" },
    { id = 33,  dff = "m33_mafia2.dff",     txd = "m33_mafia2.txd",     name = "Mafia ByCostela HD" },
    { id = 37,  dff = "handsome.dff",       txd = "handsome.txd",       name = "Handsome Male HD" },
    { id = 43,  dff = "mafia.dff",          txd = "mafia.txd",          name = "Mafia Male HD" },
    { id = 44,  dff = "m44_crips.dff",      txd = "m44_crips.txd",      name = "Crips HD" },
    { id = 45,  dff = "m45_business2.dff",  txd = "m45_business2.txd",  name = "Business Male v2 HD" },
    { id = 46,  dff = "mafiarandom.dff",    txd = "mafiarandom.txd",    name = "Mafia Random HD" },
    { id = 51,  dff = "m51_lcpd1.dff",      txd = "m51_lcpd1.txd",      name = "LCPD Cadet HD" },
    { id = 52,  dff = "m52_lcpd2.dff",      txd = "m52_lcpd2.txd",      name = "LCPD Patrol HD" },
    { id = 60,  dff = "m60_cat.dff",        txd = "m60_cat.txd",        name = "Skin 60 HD" },
    -- Ballas HD (210) removed 2026-11-22: DFF rejected by engineReplaceModel on every client.
    { id = 252, dff = "m252_karakter.dff",  txd = "m252_karakter.txd",  name = "Karakter 252 HD" },
    { id = 274, dff = "doctor.dff",         txd = "doctor.txd",         name = "Male Surgeon HD" },
    -- females
    { id = 9,   dff = "f_doctor.dff",       txd = "f_doctor.txd",       name = "Female Surgeon HD" },
    { id = 10,  dff = "f10_cotpf.dff",      txd = "f10_cotpf.txd",      name = "COT PF HD" },
    { id = 11,  dff = "f11_kcamuflada.dff", txd = "f11_kcamuflada.txd", name = "K-Camuflada HD" },
    { id = 12,  dff = "f_random.dff",       txd = "f_random.txd",       name = "Random Girl v2 HD" },
    { id = 13,  dff = "f_roleplay.dff",     txd = "f_roleplay.txd",     name = "Roleplay Girl HD" },
    { id = 31,  dff = "f31_tdt.dff",        txd = "f31_tdt.txd",        name = "TDT HD" },
    { id = 38,  dff = "f38_lacasa.dff",     txd = "f38_lacasa.txd",     name = "La Casa de Papel HD" },
    { id = 39,  dff = "f39_lcpdf2.dff",     txd = "f39_lcpdf2.txd",     name = "LCPD Officer F2 HD" },
    { id = 40,  dff = "f_roleplay2.dff",    txd = "f_roleplay2.txd",    name = "Roleplay Girl v2 HD" },
    { id = 41,  dff = "f41_brasil.dff",     txd = "f41_brasil.txd",     name = "Brasil HD" },
    { id = 53,  dff = "f53_pijama.dff",     txd = "f53_pijama.txd",     name = "Pijama HD" },
    { id = 54,  dff = "f54_id11.dff",       txd = "f54_id11.txd",       name = "BySampaio HD" },
    { id = 55,  dff = "f55_lcpdf1.dff",     txd = "f55_lcpdf1.txd",     name = "LCPD Officer F1 HD" },
    { id = 56,  dff = "f_tattooed.dff",     txd = "f_tattooed.txd",     name = "Tattooed Girl HD" },
    { id = 88,  dff = "f_tourist.dff",      txd = "f_tourist.txd",      name = "Tourist Girl HD" },
    { id = 93,  dff = "f_kaine.dff",        txd = "f_kaine.txd",        name = "Kaine Goth HD" },
}

local applied = false
local function applySkins()
    if applied then return end
    applied = true
    local loaded, failed = 0, 0
    local failedNames = {}
    for _, p in ipairs(PACKS) do
        local txd = engineLoadTXD(p.txd)
        local dff = engineLoadDFF(p.dff)
        -- Split the two MTA steps so the server report says exactly WHICH
        -- step rejected a pack (download/decode vs TXD import vs DFF replace).
        local okT = txd and engineImportTXD(txd, p.id) or false
        local okD = dff and engineReplaceModel(dff, p.id) or false
        if okT and okD then
            loaded = loaded + 1
            outputDebugString("[ng-skins] " .. p.name .. " -> " .. tostring(p.id))
        else
            failed = failed + 1
            local why = "txd=" .. tostring(txd ~= nil) .. " dff=" .. tostring(dff ~= nil)
                .. " import=" .. tostring(okT) .. " replace=" .. tostring(okD)
            failedNames[#failedNames + 1] = p.name .. "(" .. tostring(p.id) .. ")[" .. why .. "]"
            outputDebugString("[ng-skins] FAILED " .. p.name .. " -> " .. tostring(p.id) .. " " .. why, 2)
        end
    end
    outputDebugString("[ng-skins] loaded " .. loaded .. "/" .. #PACKS .. " folder skins (failed " .. failed .. ")")
    -- Report once per client join so the server log proves whether every
    -- DFF/TXD actually loaded on a real client (debug output stays client-side).
    triggerServerEvent("ngSkins:report", localPlayer, loaded, failed, table.concat(failedNames, ", "))
end

addEventHandler("onClientResourceStart", resourceRoot, applySkins)
-- Late joiners / other resources that restore a model can be corrected again.
addEventHandler("onClientPlayerSpawn", root, function()
    if source == localPlayer then applySkins() end
end)
