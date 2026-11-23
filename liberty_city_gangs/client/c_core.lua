--[[
    liberty_city_gangs / client/c_core.lua
]]

LCG = LCG or {}
LCG.client = LCG.client or {
    state = nil,
    prompt = nil,
    uiOpen = false,
    lang = "ar", -- ar/en/pt (basic)
}

function LCG.t(ar, en, pt)
    local l = LCG.client.lang or "ar"
    if l == "en" then return en or ar end
    if l == "pt" then return pt or en or ar end
    return ar or en or pt
end

function LCG.notify(msg, kind)
    local r,g,b = 212,175,90
    if kind == "error" then r,g,b = 208,82,74
    elseif kind == "success" then r,g,b = 104,196,128
    elseif kind == "warn" then r,g,b = 226,176,84 end
    outputChatBox("[GANG] " .. tostring(msg), r, g, b, true)
end

addEvent("lcg:state", true)
addEventHandler("lcg:state", resourceRoot, function(payload)
    LCG.client.state = payload
    if LCG.UI and LCG.UI.onState then LCG.UI.onState(payload) end
end)

addEvent("lcg:treasuryLogs", true)
addEventHandler("lcg:treasuryLogs", resourceRoot, function(rows)
    LCG.client.treasuryLogs = rows or {}
    if LCG.UI and LCG.UI.onTreasuryLogs then LCG.UI.onTreasuryLogs(rows) end
end)

addEvent("lcg:warehouse:list", true)
addEventHandler("lcg:warehouse:list", resourceRoot, function(rows)
    LCG.client.warehouse = rows or {}
    if LCG.UI and LCG.UI.onWarehouse then LCG.UI.onWarehouse(rows) end
end)

addEvent("lcg:territory:update", true)
addEventHandler("lcg:territory:update", resourceRoot, function(id, owner)
    -- lightweight client cache update if needed
end)

addEvent("lcg:activity:info", true)
addEventHandler("lcg:activity:info", resourceRoot, function(info)
    LCG.client.activity = info
    LCG.notify((info and info.label or "Activity") .. ": " .. (info and info.desc or ""), "info")
end)

function LCG.requestState()
    triggerServerEvent("lcg:requestState", resourceRoot)
end

addCommandHandler("gang", function()
    if LCG.UI then LCG.UI.toggle() end
end)

addCommandHandler("ganglang", function(cmd, lang)
    if lang == "ar" or lang == "en" or lang == "pt" then
        LCG.client.lang = lang
        LCG.notify("Language: " .. lang, "success")
    else
        LCG.notify("Usage: /ganglang ar|en|pt", "warn")
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(LCG.requestState, 1500, 1)
end)
