--[[
    ng-skins - HD FiveM-style ped skins for Lmbaw9in RP
    ----------------------------------------------------
    Remapped from the original bluenode packs into one resource:
      22  = Business Male HD
      30  = Bloods HD
      37  = Handsome Male HD
      43  = Mafia Male HD
      46  = Mafia Random HD   (remapped from 37 to avoid conflict,
                               46 is already a selectable male skin)
      274 = Hospital Doctor HD
    Selection list lives in ng-characters (MALE_SKINS).
]]

local PACKS = {
    { id = 22,  dff = "business.dff", txd = "business.txd", name = "Business Male" },
    { id = 30,  dff = "bloods.dff",   txd = "bloods.txd",   name = "Bloods" },
    { id = 37,  dff = "handsome.dff", txd = "handsome.txd", name = "Handsome Male" },
    { id = 43,  dff = "mafia.dff",    txd = "mafia.txd",    name = "Mafia Male" },
    { id = 46,  dff = "mafia2.dff",   txd = "mafia2.txd",   name = "Mafia Random" },
    { id = 274, dff = "doctor.dff",   txd = "doctor.txd",   name = "Doctor" },
}

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, p in ipairs(PACKS) do
        local txd = engineLoadTXD(p.txd)
        local txdOk = txd and engineImportTXD(txd, p.id)
        local dff = engineLoadDFF(p.dff, p.id)
        local dffOk = dff and engineReplaceModel(dff, p.id)
        if txdOk and dffOk then
            outputDebugString("[ng-skins] loaded: " .. p.name .. " (skin " .. p.id .. ")")
        else
            outputDebugString("[ng-skins] FAILED: " .. p.name .. " (skin " .. p.id .. ")", 2)
        end
    end
end)
