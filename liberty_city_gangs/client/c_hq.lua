--[[
    liberty_city_gangs / client/c_hq.lua
    HQ enter/exit prompt handling.
]]

LCG = LCG or {}

local prompt = nil -- {type, factionId}

addEvent("lcg:hqPrompt", true)
addEventHandler("lcg:hqPrompt", resourceRoot, function(data)
    prompt = data
    LCG.client.prompt = data
end)

addEventHandler("onClientRender", root, function()
    if not prompt then return end
    local sw, sh = guiGetScreenSize()
    local txt
    if prompt.type == "enter" then
        txt = LCG.t("اضغط E لدخول المقر", "Press E to enter HQ", "Pressione E para entrar na sede")
    else
        txt = LCG.t("اضغط E للخروج", "Press E to exit", "Pressione E para sair")
    end
    dxDrawText(txt, 0, sh - 140, sw, sh - 100, tocolor(212,175,90,230), 1.4, "default-bold", "center", "center", false, false, false, true)
end)

addEventHandler("onClientMarkerLeave", resourceRoot, function(hit, dimMatch)
    if hit ~= localPlayer then return end
    local enterId = getElementData(source, "lcg.hq.enter")
    local exitId = getElementData(source, "lcg.hq.exit")
    if (enterId and prompt and prompt.type == "enter" and tonumber(prompt.factionId) == tonumber(enterId))
    or (exitId and prompt and prompt.type == "exit" and tonumber(prompt.factionId) == tonumber(exitId)) then
        prompt = nil
        LCG.client.prompt = nil
    end
end)

bindKey("e", "down", function()
    if not prompt or isChatBoxInputActive() or isConsoleActive() then return end
    if prompt.type == "enter" then
        triggerServerEvent("lcg:hq:enter", resourceRoot, prompt.factionId)
    elseif prompt.type == "exit" then
        triggerServerEvent("lcg:hq:exit", resourceRoot, prompt.factionId)
    end
end)
