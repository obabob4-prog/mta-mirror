--[[
    ng-admin c_admin.lua - admin panel (client)
    Open with /admin (level 1+). Tabs: Players | Resources | Server | Logs
]]

local RP = exports["ng-rp"]

local myLevel = 0

local function buildPlayersTab(list)
    RP:windowClear("ap")
    RP:windowLabel("ap", "tab", "PLAYERS (" .. #list .. ")", 0.04, 0.10, 0.6, 0.04, 0.95, tocolor(74, 163, 255, 255), "left", "center")
    local y = 0.15
    for i, pl in ipairs(list) do
        if i > 12 then break end
        RP:windowLabel("ap", "n" .. i,
            pl.name .. "  [" .. pl.ip .. "  " .. pl.ping .. "ms]  job: " .. pl.job .. (pl.spawned and "" or " (lobby)") .. (pl.level > 0 and ("  LVL" .. pl.level) or ""),
            0.04, y, 0.55, 0.05, 0.75, nil, "left", "center")
        RP:windowEdit("ap", "amt" .. i, "", 0.60, y, 0.09, 0.05)
        RP:windowButton("ap", "kick" .. i, "KICK", 0.70, y, 0.07, 0.05, function()
            triggerServerEvent("nga:kick", localPlayer, pl.name, RP:windowGetEdit("ap", "amt" .. i) ~= "" and RP:windowGetEdit("ap", "amt" .. i) or "Kicked by staff")
        end, tocolor(120, 30, 30, 200))
        RP:windowButton("ap", "ban" .. i, "BAN", 0.78, y, 0.07, 0.05, function()
            if myLevel >= 2 then
                triggerServerEvent("nga:ban", localPlayer, pl.name, "Banned by " .. getPlayerName(localPlayer))
            end
        end, tocolor(120, 30, 30, 200))
        RP:windowButton("ap", "go" .. i, "GO", 0.86, y, 0.06, 0.05, function()
            triggerServerEvent("nga:goto", localPlayer, pl.name)
        end)
        RP:windowButton("ap", "br" .. i, "BR", 0.925, y, 0.055, 0.05, function()
            triggerServerEvent("nga:bring", localPlayer, pl.name)
        end)
        y = y + 0.062
    end
    RP:windowLabel("ap", "moneyNote", "Give money: write amount in the box next to a player then click GIVE.", 0.04, 0.90, 0.7, 0.03, 0.75, tocolor(150, 160, 172, 255), "left", "center")
    RP:windowButton("ap", "give", "GIVE", 0.70, 0.89, 0.10, 0.05, function()
        local idx = tonumber(RP:windowGetEdit("ap", "selIdx") or "") or 0
        local pl = list[idx]
        if pl and myLevel >= 2 then
            triggerServerEvent("nga:givemoney", localPlayer, pl.name, tonumber(RP:windowGetEdit("ap", "amt" .. idx)))
        end
    end, tocolor(40, 96, 160, 200))
    RP:windowEdit("ap", "selIdx", "", 0.81, 0.89, 0.07, 0.05)
    RP:windowLabel("ap", "selNote", "row#", 0.89, 0.89, 0.08, 0.05, 0.75, tocolor(150, 160, 172, 255), "left", "center")
end

local function buildResourcesTab(list)
    RP:windowClear("ap")
    RP:windowLabel("ap", "tab", "RESOURCES (" .. #list .. ")", 0.04, 0.10, 0.6, 0.04, 0.95, tocolor(74, 163, 255, 255), "left", "center")
    local y = 0.15
    for i, r in ipairs(list) do
        if i > 22 then break end
        local stateCol = r.state == "running" and tocolor(64, 178, 96, 255) or tocolor(214, 150, 40, 255)
        RP:windowLabel("ap", "rn" .. i, r.name, 0.04, y, 0.55, 0.045, 0.8, nil, "left", "center")
        RP:windowLabel("ap", "rs" .. i, r.state, 0.50, y, 0.12, 0.045, 0.8, stateCol, "left", "center")
        RP:windowButton("ap", "start" .. i, "S", 0.63, y, 0.045, 0.045, function()
            triggerServerEvent("nga:resourceAction", localPlayer, r.name, "start")
        end)
        RP:windowButton("ap", "stop" .. i, "X", 0.68, y, 0.045, 0.045, function()
            triggerServerEvent("nga:resourceAction", localPlayer, r.name, "stop")
        end, tocolor(120, 30, 30, 200))
        RP:windowButton("ap", "restart" .. i, "R", 0.73, y, 0.045, 0.045, function()
            triggerServerEvent("nga:resourceAction", localPlayer, r.name, "restart")
        end)
        y = y + 0.048
    end
end

local function buildServerTab()
    triggerServerEvent("nga:serverInfo", localPlayer)
end

local function buildLogsTab()
    triggerServerEvent("nga:logs", localPlayer)
end

addEvent("nga:info", true)
addEventHandler("nga:info", root, function(info)
    if not RP:isWindowOpen("ap") then return end
    RP:windowClear("ap")
    RP:windowLabel("ap", "tab", "SERVER STATUS", 0.04, 0.10, 0.6, 0.04, 0.95, tocolor(74, 163, 255, 255), "left", "center")
    local lines = {
        "Players online: " .. info.players,
        "Accounts: " .. info.accounts,
        "Characters: " .. info.characters,
        "Vehicles owned: " .. info.vehicles,
        "Server uptime: " .. info.uptime,
        "MTA version: " .. tostring(info.version),
    }
    local y = 0.18
    for _, l in ipairs(lines) do
        RP:windowLabel("ap", "i" .. y, l, 0.06, y, 0.88, 0.05, 0.9, nil, "left", "center")
        y = y + 0.06
    end
    RP:windowLabel("ap", "note", "Restart the server with scripts\\restart-server.bat", 0.06, y + 0.02, 0.88, 0.05, 0.8, tocolor(150, 160, 172, 255), "left", "center")
end)

addEvent("nga:logs", true)
addEventHandler("nga:logs", root, function(admin, srv)
    if not RP:isWindowOpen("ap") then return end
    RP:windowClear("ap")
    RP:windowLabel("ap", "tab", "LOGS (latest 30)", 0.04, 0.10, 0.6, 0.04, 0.95, tocolor(74, 163, 255, 255), "left", "center")
    local y = 0.16
    RP:windowLabel("ap", "lt1", "-- ADMIN ACTIONS --", 0.04, y, 0.9, 0.03, 0.85, tocolor(74, 163, 255, 255), "left", "center")
    y = y + 0.04
    for i, l in ipairs(admin) do
        if i > 12 then break end
        RP:windowLabel("ap", "al" .. i, tostring(l.time) .. "  " .. tostring(l.action) .. " -> " .. tostring(l.target) .. " " .. tostring(l.details),
            0.04, y, 0.92, 0.03, 0.65, nil, "left", "top")
        y = y + 0.033
    end
    RP:windowLabel("ap", "lt2", "-- SERVER LOG --", 0.04, y + 0.01, 0.9, 0.03, 0.85, tocolor(214, 150, 40, 255), "left", "center")
    y = y + 0.05
    for i, l in ipairs(srv) do
        if i > 10 then break end
        RP:windowLabel("ap", "sl" .. i, tostring(l.time) .. "  [" .. tostring(l.ltype) .. "] " .. tostring(l.message),
            0.04, y, 0.92, 0.03, 0.65, tocolor(150, 160, 172, 255), "left", "top")
        y = y + 0.033
    end
end)

local function openPanel()
    if myLevel < 1 then
        RP:notify("You are not a staff member.", 214, 61, 61)
        return
    end
    RP:openWindow("ap", "NGRP ADMIN PANEL - level " .. myLevel, 300, 120, 900, 640)
    triggerServerEvent("nga:requestPlayers", localPlayer)
end

local function buildTabsRow()
    RP:windowButton("ap", "tPlayers", "PLAYERS", 0.03, 0.04, 0.12, 0.05, function()
        triggerServerEvent("nga:requestPlayers", localPlayer)
    end, tocolor(40, 96, 160, 220))
    RP:windowButton("ap", "tRes", "RES", 0.16, 0.04, 0.10, 0.05, function()
        if myLevel >= 2 then triggerServerEvent("nga:resources", localPlayer) end
    end)
    RP:windowButton("ap", "tSrv", "SERVER", 0.27, 0.04, 0.10, 0.05, buildServerTab)
    RP:windowButton("ap", "tLog", "LOGS", 0.38, 0.04, 0.10, 0.05, function()
        if myLevel >= 2 then buildLogsTab() end
    end)
    RP:windowButton("ap", "spawnVeh", "SPAWN VEH", 0.49, 0.04, 0.12, 0.05, function()
        buildVehMenu()
    end)
    RP:windowButton("ap", "close", "CLOSE", 0.86, 0.04, 0.11, 0.05, function()
        RP:closeWindow("ap")
    end, tocolor(120, 30, 30, 200))
end

addEvent("nga:players", true)
addEventHandler("nga:players", root, function(list)
    if not RP:isWindowOpen("ap") then return end
    buildPlayersTab(list)
end)

addEvent("nga:resources", true)
addEventHandler("nga:resources", root, function(list)
    if not RP:isWindowOpen("ap") then return end
    buildResourcesTab(list)
end)

addEvent("nga:status", true)
addEventHandler("nga:status", root, function(text, ok)
    RP:notify(text, ok and 64 or 214, ok and 178 or 61, ok and 96 or 61)
end)

addCommandHandler("admin", openPanel)

-- refresh level when account data changes
addEventHandler("onClientElementDataChange", root, function(key)
    if source == localPlayer and key == "account.level" then
        myLevel = tonumber(getElementData(localPlayer, "account.level")) or 0
        if RP:isWindowOpen("ap") then
            RP:closeWindow("ap")
            openPanel()
        end
    end
end)

-- restore level on resource restart
addEventHandler("onClientResourceStart", resourceRoot, function()
    myLevel = tonumber(getElementData(localPlayer, "account.level")) or 0
end)

-- ============================== admin vehicle menu ==============================
-- full catalog with real names, paginated; SPAWN summons the car next to
-- the admin and warps him in (server: nga:spawnveh, level 1+)
local VEH_NAMES = {
    [400] = "Landstalker", [401] = "Bravura", [402] = "Buffalo", [403] = "Linerunner",
    [404] = "Perennial", [405] = "Sentinel", [406] = "Dumper", [407] = "Firetruck",
    [408] = "Trashmaster", [409] = "Stretch", [410] = "Manana", [411] = "Infernus",
    [412] = "Voodoo", [413] = "Pony", [414] = "Mule", [415] = "Cheetah",
    [416] = "Ambulance", [417] = "Leviathan", [418] = "Moonbeam", [419] = "Esperanto",
    [420] = "Taxi", [421] = "Washington", [422] = "Bobcat", [423] = "Mr Whoopee",
    [424] = "BF Injection", [425] = "Hunter", [426] = "Premier", [427] = "Enforcer",
    [428] = "Securicar", [429] = "Banshee", [430] = "Predator", [431] = "Coach",
    [432] = "Rhino", [433] = "Barracks", [434] = "Hotknife", [435] = "Article Trailer",
    [436] = "Previon", [437] = "Coach", [438] = "Cabbie", [439] = "Stallion",
    [440] = "Rumpo", [441] = "RC Bandit", [442] = "Romero", [443] = "Packer",
    [444] = "Monster", [445] = "Admiral", [446] = "Squalo", [447] = "Seasparrow",
    [448] = "Pizzaboy", [449] = "Tram", [450] = "Article Trailer 2", [451] = "Turismo",
    [452] = "Speeder", [453] = "Reefer", [454] = "Tropic", [455] = "Flatbed",
    [456] = "Yankee", [457] = "Caddy", [458] = "Solair", [459] = "RC Van",
    [460] = "Skimmer", [461] = "PCJ-600", [462] = "Faggio", [463] = "Freeway",
    [464] = "RC Baron", [465] = "RC Raider", [466] = "Glendale", [467] = "Oceanic",
    [468] = "Sanchez", [469] = "Sparrow", [470] = "Patriot", [471] = "Quad",
    [472] = "Coastguard", [473] = "Dinghy", [474] = "Hermes", [475] = "Sabre",
    [476] = "Rustler", [477] = "ZR-350", [478] = "Walton", [479] = "Regina",
    [480] = "Comet", [481] = "BMX", [482] = "Burrito", [483] = "Camper",
    [484] = "Marquis", [485] = "Baggage", [486] = "Dozer", [487] = "Maverick",
    [488] = "News Chopper", [489] = "Rancher", [490] = "FBI Rancher", [491] = "Virgo",
    [492] = "Greenwood", [493] = "Jetmax", [494] = "Hotring Racer", [495] = "Sandking",
    [496] = "Blista Compact", [497] = "Police Maverick", [498] = "Boxville", [499] = "Benson",
    [500] = "Mesa", [501] = "RC Goblin", [502] = "Hotring Racer A", [503] = "Hotring Racer B",
    [504] = "Bloodring Banger", [505] = "Rancher Lure", [506] = "Super GT", [507] = "Elegant",
    [508] = "Journey", [509] = "Bike", [510] = "Mountain Bike", [511] = "Beagle",
    [512] = "Cropduster", [513] = "Stuntplane", [514] = "Tanker", [515] = "Roadtrain",
    [516] = "Nebula", [517] = "Majestic", [518] = "Buccaneer", [519] = "Shamal",
    [520] = "Hydra", [521] = "FCR-900", [522] = "NRG-500", [523] = "HPV-1000",
    [524] = "Cement Truck", [525] = "Towtruck", [526] = "Fortune", [527] = "Cadrona",
    [528] = "FBI Truck", [529] = "Willard", [530] = "Forklift", [531] = "Tractor",
    [532] = "Combine", [533] = "Feltzer", [534] = "Remington", [535] = "Slamvan",
    [536] = "Blade", [537] = "Freight Train", [538] = "Streak Train", [539] = "Vortex",
    [540] = "Vinewood", [541] = "Bullet", [542] = "Clover", [543] = "Sadler",
    [544] = "Firetruck LA", [545] = "Hustler", [546] = "Intruder", [547] = "Primo",
    [548] = "Cargobob", [549] = "Tampa", [550] = "Sunrise", [551] = "Merit",
    [552] = "Utility Van", [553] = "Nevada", [554] = "Yosemite", [555] = "Windsor",
    [556] = "Monster A", [557] = "Monster B", [558] = "Uranus", [559] = "Jester",
    [560] = "Sultan", [561] = "Stratum", [562] = "Elegy", [563] = "Raindance",
    [564] = "RC Tiger", [565] = "Flash", [566] = "Tahoma", [567] = "Savanna",
    [568] = "Bandito", [569] = "Freight Flat", [570] = "Streak Trailer", [571] = "Kart",
    [572] = "Mower", [573] = "Dune", [574] = "Sweeper", [575] = "Broadway",
    [576] = "Tornado", [577] = "AT-400", [578] = "DFT-30", [579] = "Huntley",
    [580] = "Stafford", [581] = "BF-400", [582] = "News Van", [583] = "Tug",
    [584] = "Petrol Trailer", [585] = "Emperor", [586] = "Wayfarer", [587] = "Euros",
    [588] = "Hotdog", [589] = "Club", [590] = "Freight Box", [591] = "Article Trailer 3",
    [592] = "Andromada", [593] = "Dodo", [594] = "RC Cam", [595] = "Launch",
    [596] = "Police LS", [597] = "Police SF", [598] = "Police LV", [599] = "Police Ranger",
    [600] = "Picador", [601] = "SWAT Van", [602] = "Alpha", [603] = "Phoenix",
    [604] = "Glendale Worn", [605] = "Sadler Worn", [606] = "Baggage Trailer A",
    [607] = "Baggage Trailer B", [608] = "Tug Stairs", [609] = "Boxville",
    [610] = "Farm Trailer", [611] = "Utility Trailer",
}
-- trains need tracks; spawning them just wedges them into the ground
local VEH_SKIP = { [449] = true, [537] = true, [538] = true, [569] = true, [570] = true, [590] = true }

local vehPage = 1
local VEH_PER_PAGE = 9
local VEH_FIRST, VEH_LAST = 400, 611
local vehPages = math.ceil((VEH_LAST - VEH_FIRST + 1) / VEH_PER_PAGE)

function buildVehMenu()
    RP:openWindow("vehmenu", "ADMIN VEHICLE MENU - SPAWN = summon next to you", 250, 70, 540, 730)
    local function buildPage()
        RP:windowClear("vehmenu")
        local first = VEH_FIRST + (vehPage - 1) * VEH_PER_PAGE
        local last = math.min(first + VEH_PER_PAGE - 1, VEH_LAST)
        local y = 0.055
        for id = first, last do
            if not VEH_SKIP[id] then
                RP:windowLabel("vehmenu", "n" .. id, id .. "  " .. (VEH_NAMES[id] or "?"), 0.05, y, 0.60, 0.05, 0.9, nil, "left", "center")
                RP:windowButton("vehmenu", "s" .. id, "SPAWN", 0.72, y, 0.22, 0.045, function()
                    triggerServerEvent("nga:spawnveh", localPlayer, id)
                end, tocolor(40, 96, 160, 220))
                y = y + 0.066
            end
        end
        RP:windowLabel("vehmenu", "pg", "PAGE " .. vehPage .. " / " .. vehPages, 0.34, 0.895, 0.32, 0.05, 0.9, tocolor(150, 160, 172, 255), "center", "center")
        RP:windowButton("vehmenu", "prev", "PREV", 0.08, 0.89, 0.13, 0.05, function()
            if vehPage > 1 then vehPage = vehPage - 1 buildPage() end
        end)
        RP:windowButton("vehmenu", "next", "NEXT", 0.79, 0.89, 0.13, 0.05, function()
            if vehPage < vehPages then vehPage = vehPage + 1 buildPage() end
        end)
        RP:windowButton("vehmenu", "close", "CLOSE", 0.36, 0.955, 0.28, 0.038, function()
            RP:closeWindow("vehmenu")
        end, tocolor(120, 30, 30, 200))
    end
    buildPage()
end
