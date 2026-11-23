--[[
    lmb_police / client/c_world.lua
    World interactions: station/interior markers, 3D prompts, E-key interact,
    waypoint/blip, stun feedback, radio/duty client events.
]]

local sw, sh = guiGetScreenSize()

local W = {
    points = nil,
    station = nil,
    isPolice = false,
    blip = nil,
    wpBlip = nil,
    wpMarker = nil,
    stunnedUntil = 0,
}

local GOLD = tocolor(226, 190, 116, 235)
local GOLD_DIM = tocolor(226, 190, 116, 140)
local WHITE = tocolor(240, 242, 246, 235)
local BG = tocolor(10, 11, 14, 180)
local BLUE = tocolor(92, 150, 214, 230)
local RED = tocolor(208, 82, 74, 235)

local function dist3(a, b, c, x, y, z)
    local dx, dy, dz = a - x, b - y, c - z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function ensureBlip()
    if W.blip and isElement(W.blip) then destroyElement(W.blip) end
    W.blip = nil
    if not W.station then return end
    local b = W.station.blip or {}
    W.blip = createBlip(W.station.x, W.station.y, W.station.z, b.sprite or 30, 2,
        b.color == 2 and 0 or 255, b.color == 2 and 120 or 255, b.color == 2 and 255 or 255, 255, 0, 800)
    if W.blip then
        setBlipVisibleDistance(W.blip, 800)
    end
end

local function setWaypoint(x, y, label)
    if W.wpBlip and isElement(W.wpBlip) then destroyElement(W.wpBlip) end
    if W.wpMarker and isElement(W.wpMarker) then destroyElement(W.wpMarker) end
    W.wpBlip = createBlip(x, y, 20, 41, 2, 226, 190, 116, 255, 0, 1200)
    W.wpMarker = createMarker(x, y, 0, "checkpoint", 2.2, 226, 190, 116, 160)
    if W.wpBlip then setBlipVisibleDistance(W.wpBlip, 1200) end
    if label then
        outputChatBox("[LCPD] Waypoint set: " .. tostring(label), 226, 190, 116)
    end
end

addEvent("pd:points", true)
addEventHandler("pd:points", root, function(points, station)
    W.points = points or W.points
    W.station = station or W.station
    ensureBlip()
end)

addEvent("pd:role", true)
addEventHandler("pd:role", root, function(isPolice)
    W.isPolice = isPolice == true
end)

addEvent("pd:duty", true)
addEventHandler("pd:duty", root, function(state)
    -- client UI already tracks via element data; this is a hook for feedback
    if state then
        playSoundFrontEnd(43)
    else
        playSoundFrontEnd(42)
    end
end)

addEvent("pd:waypoint", true)
addEventHandler("pd:waypoint", root, function(x, y, label)
    x, y = tonumber(x), tonumber(y)
    if not x or not y then return end
    setWaypoint(x, y, label)
end)

addEvent("pd:stunned", true)
addEventHandler("pd:stunned", root, function(officer)
    W.stunnedUntil = getTickCount() + 2200
    setPedAnimation(localPlayer, "ped", "KO_skid_back", 1200, false, false, false)
end)

addEvent("pd:radioFx", true)
addEventHandler("pd:radioFx", root, function()
    playSoundFrontEnd(11)
end)

-- Determine nearest interactable point for current player state
local function nearestInteract()
    local px, py, pz = getElementPosition(localPlayer)
    local pint, pdim = getElementInterior(localPlayer), getElementDimension(localPlayer)
    local best, bestKey, bestD = nil, nil, 3.2

    -- exterior station entrance (world) - only for closed/teleport stations
    if W.station and not W.station.open and pdim == 0 and pint == 0 then
        local d = dist3(px, py, pz, W.station.x, W.station.y, W.station.z)
        if d < bestD then
            best = { x = W.station.x, y = W.station.y, z = W.station.z, label = W.station.label or "LmB POLICE DEPARTMENT", hint = "E - ENTER" }
            bestKey = "station"
            bestD = d
        end
    end

    if not W.points then return best, bestKey, bestD end

    -- interior points
    for name, pt in pairs(W.points) do
        if pt and getElementDimension(localPlayer) == (pt.dimension or 0)
            and getElementInterior(localPlayer) == (pt.interior or 0) then
            local d = dist3(px, py, pz, pt.x, pt.y, pt.z)
            local limit = 3.5
            if d < limit and d < bestD then
                local hint = "E - INTERACT"
                local action = name
                if name == "entrance" then hint = "E - EXIT"; action = "exit" end
                if name == "duty" then hint = "E - DUTY / TERMINAL" end
                if name == "armory" then hint = "E - ARMOURY" end
                if name == "garage" then hint = "E - GARAGE" end
                if name == "chief" then hint = "E - COMMAND" end
                if name == "cells" then hint = "E - HOLDING" end
                best = { x = pt.x, y = pt.y, z = pt.z, label = pt.label or name, hint = hint }
                bestKey = action
                bestD = d
            end
        end
    end
    return best, bestKey, bestD
end

-- Draw 3D markers/prompts
addEventHandler("onClientRender", root, function()
    -- stun overlay
    if W.stunnedUntil > getTickCount() then
        dxDrawRectangle(0, 0, sw, sh, tocolor(255, 255, 255, 30))
        dxDrawText("STUNNED", 0, sh * 0.45, sw, sh * 0.55, RED, 2.2, "default-bold", "center", "center")
    end

    -- armory flashlight: lightweight 3D beam (server still owns the flag)
    if getElementData(localPlayer, "pol.flashlight") == true and
       getElementData(localPlayer, "pol.duty") == true then
        local px, py, pz = getElementPosition(localPlayer)
        local _, _, rz = getElementRotation(localPlayer)
        local base = math.rad(rz or 0)
        for i = -3, 3 do
            local a = base + i * 0.09
            local ex = px + math.sin(a) * 14
            local ey = py - math.cos(a) * 14
            local ez = pz + 0.35 + math.abs(i) * 0.04
            local alpha = math.max(20, 95 - math.abs(i) * 11)
            dxDrawLine3D(px, py, pz + 1.15, ex, ey, ez,
                tocolor(246, 222, 174, alpha), 2)
        end
    end

    if not W.points and not W.station then return end

    local px, py, pz = getElementPosition(localPlayer)
    local pint, pdim = getElementInterior(localPlayer), getElementDimension(localPlayer)

    local function drawPoint(pt, label, hint, keyName)
        if not pt then return end
        if getElementDimension(localPlayer) ~= (pt.dimension or 0) then return end
        if getElementInterior(localPlayer) ~= (pt.interior or 0) then return end
        local x, y, z = pt.x, pt.y, pt.z
        local d = dist3(px, py, pz, x, y, z)
        if d > 40 then return end
        -- ground marker (simple square outline)
        local pulse = 0.55 + math.sin(getTickCount() / 400) * 0.08
        dxDrawLine3D(x - pulse, y - pulse, z + 0.05, x + pulse, y - pulse, z + 0.05, GOLD_DIM, 2)
        dxDrawLine3D(x + pulse, y - pulse, z + 0.05, x + pulse, y + pulse, z + 0.05, GOLD_DIM, 2)
        dxDrawLine3D(x + pulse, y + pulse, z + 0.05, x - pulse, y + pulse, z + 0.05, GOLD_DIM, 2)
        dxDrawLine3D(x - pulse, y + pulse, z + 0.05, x - pulse, y - pulse, z + 0.05, GOLD_DIM, 2)
        local sx, sy = getScreenFromWorldPosition(x, y, z + 1.05)
        if sx and sy and d < 25 then
            local alpha = math.max(80, 255 - d * 7)
            local txt = label or (pt.label or keyName or "")
            local w = dxGetTextWidth(txt, 1, "default-bold") + 18
            dxDrawRectangle(sx - w/2, sy - 12, w, 22, tocolor(10, 11, 14, math.min(180, alpha)))
            dxDrawText(txt, sx - w/2, sy - 12, sx + w/2, sy + 10, tocolor(246, 222, 174, alpha), 1, "default-bold", "center", "center")
            if d < 3.5 and hint then
                local hw = dxGetTextWidth(hint, 1, "default-bold") + 16
                dxDrawRectangle(sx - hw/2, sy + 12, hw, 20, tocolor(226, 190, 116, math.min(220, alpha)))
                dxDrawText(hint, sx - hw/2, sy + 12, sx + hw/2, sy + 32, tocolor(20, 18, 14, 255), 1, "default-bold", "center", "center")
            end
        end
    end

    -- exterior
    if W.station and not W.station.open and pdim == 0 and pint == 0 then
        local ex = { x = W.station.x, y = W.station.y, z = W.station.z, dimension = 0, interior = 0 }
        drawPoint(ex, W.station.label or "LmB POLICE DEPARTMENT", "E - ENTER", "station")
    end

    -- interior
    if W.points then
        for name, pt in pairs(W.points) do
            local hint = "E - INTERACT"
            if name == "entrance" then hint = "E - EXIT" end
            if name == "duty" then hint = "E - DUTY / TERMINAL" end
            if name == "armory" then hint = "E - ARMOURY" end
            if name == "garage" then hint = "E - GARAGE" end
            if name == "chief" then hint = "E - COMMAND" end
            if name == "cells" then hint = "E - HOLDING" end
            drawPoint(pt, pt.label or name, hint, name)
        end
    end
end)

-- E key interaction
local lastInteract = 0
bindKey("e", "down", function()
    if isChatBoxInputActive() or isConsoleActive() or guiGetInputEnabled() then return end
    if isCursorShowing() then return end
    local now = getTickCount()
    if now - lastInteract < 500 then return end
    local best, key = nearestInteract()
    if not key then return end
    lastInteract = now
    triggerServerEvent("pd:action", localPlayer, "interact", key)
end)

-- F3 toggles the issued flashlight (server validates duty + equipment)
bindKey("F3", "down", function()
    if getElementData(localPlayer, "pol.duty") ~= true then return end
    triggerServerEvent("pd:action", localPlayer, "flashlight")
end)

-- Request points/state sync on start (hot-restart safe, no forced UI open)
addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(function()
        if getElementData(localPlayer, "char.id") then
            triggerServerEvent("pd:action", localPlayer, "sync")
        end
    end, 1500, 1)
end)
