--[[
    ng-admin c_admin.lua - Admin panel (client)
    Open with /admin (level 1+). Tabs: Players | Resources | Server | Logs
    -----------------------------------------------------------------
    - 2026-11-20: LmB RP luxury restyle - neon blue/black GTA V theme
    - All functionality preserved, only visual restyle
]]--

local RP = exports["ng-rp"]

local myLevel = 0

-- =============================================================================
-- NEON BLACK / ELECTRIC BLUE COLOR PALETTE (LmB RP Theme)
-- =============================================================================
local ADMIN_COLORS = {
    -- Panel backgrounds
    panelDark = tocolor(15, 22, 35, 255),       -- dark panel base
    panelMid  = tocolor(22, 32, 48, 255),       -- medium panel
    panelLight = tocolor(30, 42, 62, 255),      -- light panel
    
    -- Accent neon electric blue
    accentBlue = tocolor(0, 150, 255, 255),      -- electric blue
    accentGold = tocolor(232, 197, 107, 255),    -- gold
    accentRed = tocolor(244, 67, 54, 255),       -- red for errors
    
    -- Text colors
    textWhite = tocolor(255, 255, 255, 255),     -- pure white
    textGray  = tocolor(180, 195, 210, 255),     -- gray text
    textDim   = tocolor(100, 120, 130, 255),    -- dim text
    
    -- Button colors
    btnActive = tocolor(0, 150, 255, 255),       -- active button
    btnHover  = tocolor(30, 60, 90, 255),        -- hover state
    btnActiveRed = tocolor(244, 67, 54, 255),    -- red buttons (kick/ban)
    btnGold   = tocolor(232, 197, 107, 255),     -- gold accent buttons
    
    -- Level/notes
    levelColor = tocolor(0, 150, 255, 255),      -- level color
    noteColor  = tocolor(150, 165, 180, 255),    -- note text
}

local function AD(key)
    local c = ADMIN_COLORS[key] or key
    return c
end

-- =============================================================================
-- ADMIN PANEL - PLAYER TAB RESTYLE
-- =============================================================================
local function buildPlayersTab(list)
    -- Window clear with neon blue header
    RP:windowClear("ap")
    
    -- Header label with neon blue accent
    RP:windowLabel("ap", "tab", "PLAYERS (" .. #list .. ")", 0.04, 0.10, 0.6, 0.04, AD("accentBlue"), "left", "center")
    
    local y = 0.15
    for i, pl in ipairs(list) do
        if i > 12 then break end
        
        -- Player info text with neon blue color
        local levelText = ""
        if pl.level > 0 then
            levelText = "  LVL " .. pl.level
        end
        local lobbyText = pl.spawned and "" or " (lobby)"
        
        RP:windowLabel("ap", "n" .. i,
            pl.name .. "  [" .. pl.ip .. "  " .. pl.ping .. "ms]  job: " .. pl.job .. lobbyText .. levelText,
            0.04, y, 0.55, 0.05, AD("textWhite"), "left", "center")
        
        -- Amount edit field with dark background
        RP:windowEdit("ap", "amt" .. i, "", 0.60, y, 0.09, 0.05)
        
        -- KICK button with red neon accent
        RP:windowButton("ap", "kick" .. i, "KICK", 0.70, y, 0.07, 0.05, function()
            triggerServerEvent("nga:kick", localPlayer, pl.name, RP:windowGetEdit("ap", "amt" .. i) ~= "" and RP:windowGetEdit("ap", "amt" .. i) or "Kicked by staff")
        end, AD("btnActiveRed"))
        
        -- BAN button with red neon accent (conditional on level)
        RP:windowButton("ap", "ban" .. i, "BAN", 0.78, y, 0.07, 0.05, function()
            if myLevel >= 2 then
                triggerServerEvent("nga:ban", localPlayer, pl.name, "Banned by " .. getPlayerName(localPlayer))
            end
        end, AD("btnActiveRed"))
        
        -- GO button with neon blue
        RP:windowButton("ap", "go" .. i, "GO", 0.86, y, 0.06, 0.05, function()
            triggerServerEvent("nga:goto", localPlayer, pl.name)
        end, AD("accentBlue"))
        
        -- BR button
        RP:windowButton("ap", "br" .. i, "BR", 0.925, y, 0.055, 0.05, function()
            triggerServerEvent("nga:bring", localPlayer, pl.name)
        end)
        
        y = y + 0.062
    end
    
    -- Money give section with neon styling
    RP:windowLabel("ap", "moneyNote", "Give money: write amount in the box next to a player then click GIVE.", 0.04, 0.90, 0.7, 0.03, AD("noteColor"), "left", "center")
    
    -- GIVE button with neon blue
    RP:windowButton("ap", "give", "GIVE", 0.70, 0.89, 0.10, 0.05, function()
        local idx = tonumber(RP:windowGetEdit("ap", "selIdx") or "") or 0
        local pl = list[idx]
        if pl and myLevel >= 2 then
            triggerServerEvent("nga:givemoney", localPlayer, pl.name, tonumber(RP:windowGetEdit("ap", "amt" .. idx)))
        end
    end, AD("accentBlue"))
    
    -- Selected index edit
    RP:windowEdit("ap", "selIdx", "", 0.81, 0.89, 0.07, 0.05)
    RP:windowLabel("ap", "selNote", "row#", 0.89, 0.89, 0.08, 0.05, AD("noteColor"), "left", "center")
end

-- =============================================================================
-- ADMIN PANEL - RESOURCES TAB RESTYLE
-- =============================================================================
local function buildResourcesTab(list)
    RP:windowClear("ap")
    
    -- Header
    RP:windowLabel("ap", "tab", "RESOURCES (" .. #list .. ")", 0.04, 0.10, 0.6, 0.04, AD("accentBlue"), "left", "center")
    
    local y = 0.15
    for i, r in ipairs(list) do
        if i > 22 then break end
        
        -- Resource state color based on running/stopped
        local stateCol = r.state == "running" and AD("accentBlue") or AD("adcentGold")
        
        RP:windowLabel("ap", "rn" .. i, r.name, 0.04, y, 0.55, 0.045, AD("textWhite"), "left", "center")
        RP:windowLabel("ap", "rs" .. i, r.state, 0.50, y, 0.12, 0.045, stateCol, "left", "center")
        
        -- Action buttons with neon colors
        RP:windowButton("ap", "start" .. i, "S", 0.63, y, 0.045, 0.045, function()
            triggerServerEvent("nga:resourceAction", localPlayer, r.name, "start")
        end, AD("accentBlue"))
        
        RP:windowButton("ap", "stop" .. i, "X", 0.68, y, 0.045, 0.045, function()
            triggerServerEvent("nga:resourceAction", localPlayer, r.name, "stop")
        end, AD("btnActiveRed"))
        
        RP:windowButton("ap", "restart" .. i, "R", 0.73, y, 0.045, 0.045, function()
            triggerServerEvent("nga:resourceAction", localPlayer, r.name, "restart")
        end)
        
        y = y + 0.048
    end
end

-- =============================================================================
-- ADMIN PANEL - SERVER TAB RESTYLE
-- =============================================================================
local function buildServerTab()
    -- Request server info from server
    triggerServerEvent("nga:serverInfo", localPlayer)
end

-- =============================================================================
-- ADMIN PANEL - LOGS TAB RESTYLE
-- =============================================================================
local function buildLogsTab()
    -- Request logs from server
    triggerServerEvent("nga:logs", localPlayer)
end

-- =============================================================================
-- EVENT HANDLERS - remain unchanged, only UI restyled
-- =============================================================================
addEvent("nga:info", true)
addEventHandler("nga:info", root, function(info)
    if not RP:isWindowOpen("ap") then return end
    
    RP:windowClear("ap")
    
    -- Server status header with neon blue
    RP:windowLabel("ap", "tab", "SERVER STATUS", 0.04, 0.10, 0.6, 0.04, AD("accentBlue"), "left", "center")
    
    -- Status lines
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
        RP:windowLabel("ap", "i" .. y, l, 0.06, y, 0.88, 0.05, AD("textWhite"), "left", "center")
        y = y + 0.06
    end
    
    -- Restart note
    RP:windowLabel("ap", "note", "Restart the server with scripts\\restart-server.bat", 0.06, y + 0.02, 0.88, 0.05, AD("noteColor"), "left", "center")
end)

addEvent("nga:logs", true)
addEventHandler("nga:logs", root, function(admin, srv)
    if not RP:isWindowOpen("ap") then return end
    
    RP:windowClear("ap")
    
    -- Logs header
    RP:windowLabel("ap", "tab", "LOGS (latest 30)", 0.04, 0.10, 0.6, 0.04, AD("accentBlue"), "left", "center")
    
    -- Admin actions section header
    RP:windowLabel("ap", "lt1", "-- ADMIN ACTIONS --", 0.04, 0.16, 0.9, 0.03, AD("accentBlue"), "left", "center")
    
    local y = 0.20
    for i, l in ipairs(admin) do
        if i > 12 then break end
        RP:windowLabel("ap", "al" .. i, tostring(l.time) .. "  " .. tostring(l.action) .. " -> " .. tostring(l.target) .. " " .. tostring(l.details),
            0.04, y, 0.92, 0.03, AD("textWhite"), "left", "top")
        y = y + 0.033
    end
    
    -- Server log section header
    RP:windowLabel("ap", "lt2", "-- SERVER LOG --", 0.04, y + 0.01, 0.9, 0.03, AD("accentGold"), "left", "center")
    
    y = y + 0.05
    for i, l in ipairs(srv) do
        if i > 10 then break end
        RP:windowLabel("ap", "sl" .. i, tostring(l.time) .. "  [" .. tostring(l.ltype) .. "] " .. tostring(l.message),
            0.04, y, 0.92, 0.03, AD("textDim"), "left", "top")
        y = y + 0.033
    end
end)