--[[
    ng-hud c_hud.lua - in-game HUD (client)
    GTA-V inspired: bottom-left vitals, bottom-right money, speedometer in vehicles.
    Toggle with F7.
]]

local RP = exports["ng-rp"]
local sw, sh = guiGetScreenSize()
local DSX, DSY = 1920, 1080
local function sx(v) return math.floor(v * (sw / DSX)) end
local function sy(v) return math.floor(v * (sh / DSY)) end
local function sxy(v) return v * math.min(sw / DSX, sh / DSY) * 1.15 end

local hudVisible = true
local lowHpFlash = 0

-- gta4hud owns the HUD when it is running; keep this legacy layer dormant.
local function gta4HudRunning()
    local res = getResourceFromName("gta4hud")
    return res and getResourceState(res) == "running"
end

bindKey("f7", "down", function() if gta4HudRunning() then return end hudVisible = not hudVisible end)

local function bar(x, y, w, h, frac, fg, bg)
    dxDrawRectangle(x, y, w, h, bg or tocolor(0, 0, 0, 160))
    frac = math.max(0, math.min(1, frac or 0))
    dxDrawRectangle(x, y, w * frac, h, fg)
    dxDrawLine(x, y, x, y + h, tocolor(255, 255, 255, 40))
end

local function fmtMoney(n)
    local s = tostring(math.floor(n or 0))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (out:gsub("^,", ""))
end

addEventHandler("onClientRender", root, function()
    if gta4HudRunning() then return end
    if not getElementData(localPlayer, "char.spawned") then return end
    if not hudVisible then return end

    local hp = getElementHealth(localPlayer) / 100
    local armor = getPedArmor(localPlayer) / 100
    local hunger = (tonumber(getElementData(localPlayer, "char.hunger")) or 100) / 100
    local thirst = (tonumber(getElementData(localPlayer, "char.thirst")) or 100) / 100
    local cash = tonumber(getElementData(localPlayer, "char.cash")) or 0
    local bank = tonumber(getElementData(localPlayer, "char.bank")) or 0
    local job = tostring(getElementData(localPlayer, "char.job") or "unemployed")
    local wanted = tonumber(getElementData(localPlayer, "char.wanted")) or 0

    -- ===== bottom-left vitals =====
    local bx, by = sx(24), sh - sy(150)
    local bw, bh = sx(230), sy(13)

    -- low HP flash
    local flash = hp < 0.25 and (math.sin(getTickCount() / 180) * 0.5 + 0.5) or 0
    bar(bx, by, bw, bh, hp, tocolor(flash > 0.5 and 255 or 214, flash > 0.5 and 60 or 48, 56, 230))
    bar(bx, by + sy(19), bw, bh, armor, tocolor(120, 170, 230, 230))
    bar(bx, by + sy(38), bw, bh, hunger, tocolor(214, 150, 40, 230))
    bar(bx, by + sy(57), bw, bh, thirst, tocolor(60, 140, 210, 230))

    -- ===== bottom-right money =====
    local mx = sw - sx(340)
    dxDrawRectangle(mx, sh - sy(96), sx(316), sy(74), tocolor(14, 17, 21, 200))
    dxDrawRectangle(mx, sh - sy(96), 4, sy(74), tocolor(64, 178, 96, 255))
    dxDrawText("$" .. fmtMoney(cash), mx + sx(16), sh - sy(92), mx + sx(300), sh - sy(60),
        tocolor(120, 230, 140, 255), sxy(1.15), "default-bold", "left", "center")
    dxDrawText("BANK  $" .. fmtMoney(bank), mx + sx(16), sh - sy(58), mx + sx(300), sh - sy(26),
        tocolor(235, 240, 245, 235), sxy(0.85), "default-bold", "left", "center")

    -- ===== top-right: job + wanted =====
    dxDrawRectangle(sw - sx(200), sy(50), sx(180), sy(30), tocolor(14, 17, 21, 170))
    dxDrawText(job:upper(), sw - sx(190), sy(50), sw - sx(20), sy(80), tocolor(74, 163, 255, 255), sxy(0.85), "default-bold", "center", "center")
    for i = 1, 6 do
        local filled = wanted >= i
        dxDrawText("*", sw - sx(150) + (i - 1) * sx(26), sy(84), 0, 0,
            filled and tocolor(255, 210, 40, 255) or tocolor(255, 255, 255, 60), sxy(1.1), "default-bold", "left", "top")
    end

    -- ===== speedometer =====
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh and getVehicleController(veh) == localPlayer then
        local vx, vy, vz = getElementVelocity(veh)
        local kmh = math.floor(math.sqrt(vx * vx + vy * vy + vz * vz) * 181.5)
        local fuel = tonumber(getElementData(veh, "veh.fuel")) or 100
        local engine = getElementData(veh, "veh.engine") == true
        local sxp, syp = sw - sx(260), sh - sy(200)
        dxDrawRectangle(sxp, syp, sx(230), sy(90), tocolor(14, 17, 21, 210))
        dxDrawRectangle(sxp, syp, 4, sy(90), engine and tocolor(64, 178, 96, 255) or tocolor(214, 61, 61, 255))
        dxDrawText(tostring(kmh), sxp + sx(14), syp + sy(6), sxp + sx(120), syp + sy(60),
            tocolor(235, 240, 245, 255), sxy(1.6), "default-bold", "left", "center")
        dxDrawText("KM/H", sxp + sx(14), syp + sy(52), sxp + sx(120), syp + sy(84),
            tocolor(150, 160, 172, 255), sxy(0.8), "default-bold", "left", "center")
        -- fuel bar
        bar(sxp + sx(130), syp + sy(24), sx(84), sy(14), fuel / 100, tocolor(214, 150, 40, 230))
        dxDrawText("FUEL", sxp + sx(130), syp + sy(44), sxp + sx(214), syp + sy(66),
            tocolor(150, 160, 172, 255), sxy(0.8), "default-bold", "center", "center")
    end
end)

-- weapon display (top-left, small)
addEventHandler("onClientRender", root, function()
    if gta4HudRunning() then return end
    if not getElementData(localPlayer, "char.spawned") or not hudVisible then return end
    local wp = getPedWeapon(localPlayer)
    if wp and wp > 0 then
        dxDrawText(getWeaponNameFromID(wp), sx(24), sy(40), sx(24) + sx(300), sy(40) + sy(30),
            tocolor(235, 240, 245, 200), sxy(0.85), "default-bold", "left", "center")
    end
end)
