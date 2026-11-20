--[[
    lc_tp client diagnostics - reports map-load state to the server
    so the admin can read exactly why the screen is black.
]]

local function sendDiag(msg)
    triggerServerEvent("lctp:clientDiag", localPlayer, msg)
end

local function collectState()
    local parts = {}
    local el = getResourceFromName("eagleLoader")
    parts[#parts + 1] = "eagleLoader=" .. (el and getResourceState(el) or "MISSING")
    local lc = getResourceFromName("LC")
    parts[#parts + 1] = "LC=" .. (lc and getResourceState(lc) or "MISSING")
    parts[#parts + 1] = "zonesFile=" .. tostring(fileExists(":LC/eagleZones.txt"))
    local x, y, z = getElementPosition(localPlayer)
    parts[#parts + 1] = string.format("me=%.1f,%.1f,%.1f int=%d dim=%d", x, y, z, getElementInterior(localPlayer), getElementDimension(localPlayer))
    -- world sanity: how many streamed-in world objects around us
    local objs = getElementsWithinRange(x, y, z, 150, "object")
    parts[#parts + 1] = "objectsNear=" .. tostring(#objs)
    parts[#parts + 1] = "buildingsNear=" .. tostring(#getElementsWithinRange(x, y, z, 150, "building"))
    -- creator diagnostics: which client.lua version is actually running here?
    local cr = getResourceFromName("sCharacterCreator")
    parts[#parts + 1] = "creator=" .. (cr and getResourceState(cr) or "MISSING")
    local okv, ver = pcall(function()
        if not fileExists(":sCharacterCreator/client.lua") then return "NOFILE" end
        local fh = fileOpen(":sCharacterCreator/client.lua", true)
        if not fh then return "NOOPEN" end
        local content = fileRead(fh, fileGetSize(fh))
        fileClose(fh)
        if content:find("gta4gg fix: isMouseInPosition", 1, true) then
            return content:find("buildUiAssets", 1, true) and "V3-buttons" or "V2-mouse"
        end
        return "V1-old"
    end)
    parts[#parts + 1] = "creatorFile=" .. tostring(okv and ver or "ERR")
    local oka, act = pcall(function() return exports["sCharacterCreator"]:isCreationActive() end)
    parts[#parts + 1] = "creatorActive=" .. tostring(oka and act or "ERR")
    table.insert(parts, "mtaBuild=" .. tostring(getVersion().sortable))
    return table.concat(parts, " | ")
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(function()
        sendDiag("BOOT " .. collectState())
        setTimer(function() sendDiag("TICK " .. collectState()) end, 12000, 0)
        -- start the world-void scanner
        setTimer(scanVoids, 6000, 0)
    end, 8000, 1)
end)

-- ============================== void scanner (gta4gg) ==============================
-- Walks a grid of points around the player and shoots a vertical ray from
-- high above down to deep below. A point with NO ground hit inside the
-- streamed radius = a hole/void in the map (missing LC geometry). Results
-- are reported to the server diag file with exact coordinates, so every
-- reported gap can be patched precisely.

local GRID = 7          -- 7x7 sample points
local SPACING = 22      -- covers +-66 units around the player
local scanT0 = 0
local scanCount = 0

-- compact automatic spot dump: everything streamed within 55 units of the
-- player with its REAL element type + model + position (gta4gg). No type
-- filter - LC structures may not be plain "object"/"building" types.
local function miniSpotDump(px, py, pz)
    local list = getElementsWithinRange(px, py, pz, 55)
    table.sort(list, function(a, b)
        local ax, ay, az = getElementPosition(a)
        local bx, by, bz = getElementPosition(b)
        return getDistanceBetweenPoints3D(px, py, pz, ax, ay, az)
            < getDistanceBetweenPoints3D(px, py, pz, bx, by, bz)
    end)
    -- summarize element types first (what does LC geometry stream as?)
    local types = {}
    for _, o in ipairs(list) do
        local ty = getElementType(o)
        types[ty] = (types[ty] or 0) + 1
    end
    local tparts = {}
    for ty, c in pairs(types) do
        table.insert(tparts, ty .. "=" .. c)
    end
    table.sort(tparts)
    sendDiag(string.format("MINIDUMP TYPES near %.1f,%.1f,%.1f : %s",
        px, py, pz, table.concat(tparts, " ")))
    for i = 1, math.min(28, #list) do
        local o = list[i]
        local ox, oy, oz = getElementPosition(o)
        local _, _, rz = getElementRotation(o)
        local mdl = tostring(getElementModel(o) or "nil")
        if mdl ~= "nil" then
            sendDiag(string.format("MINIDUMP model=%s %s pos=%.2f,%.2f,%.2f rotZ=%.1f dist=%.1f",
                mdl, getElementType(o), ox, oy, oz, rz,
                getDistanceBetweenPoints3D(px, py, pz, ox, oy, oz)))
        end
    end
    sendDiag(string.format("MINIDUMP MARKER at %.1f,%.1f,%.1f count=%d", px, py, pz, #list))
end

local function rayHitsGround(x, y, fromZ, toZ)
    local hit = processLineOfSight(x, y, fromZ, x, y, toZ, true, false, false, true, false, false, false, false, nil, false)
    return hit
end

function scanVoids()
    -- 2026-11-17 gta4gg FIX: the selection flow keeps the player in a private
    -- dimension while LC streams everywhere, so do NOT gate on dimension 0 -
    -- gate on interior/visibility only, or the scanner never runs at all.
    if getElementInterior(localPlayer) ~= 0 then return end
    if getElementAlpha(localPlayer) == 0 then return end
    local px, py, pz = getElementPosition(localPlayer)
    if pz < 1 then return end

    scanCount = scanCount + 1
    -- automatic compact object dump every ~30s: exact model ids + positions
    -- around the player reach the diag file with no user action needed
    if scanCount % 5 == 0 then
        miniSpotDump(px, py, pz)
    end

    -- safety: is the ground under MY feet solid?
    if not rayHitsGround(px, py, pz + 1.0, pz - 150) then
        sendDiag(string.format("VOIDSCAN SELF-HOLE at %.1f,%.1f,%.1f (no ground under player!)", px, py, pz))
    end

    local holes = {}
    local half = (GRID - 1) / 2
    for ix = 0, GRID - 1 do
        for iy = 0, GRID - 1 do
            local sx = px + (ix - half) * SPACING
            local sy = py + (iy - half) * SPACING
            -- skip points too close to previously found holes (dedupe)
            local dup = false
            for _, h in ipairs(holes) do
                if math.abs(h.x - sx) < SPACING and math.abs(h.y - sy) < SPACING then dup = true break end
            end
            if not dup and not rayHitsGround(sx, sy, pz + 180, pz - 250) then
                table.insert(holes, { x = sx, y = sy })
            end
        end
    end

    if #holes > 0 then
        local list = {}
        for _, h in ipairs(holes) do
            table.insert(list, string.format("%.0f,%.0f", h.x, h.y))
        end
        sendDiag(string.format("VOIDSCAN holes=%d near %.1f,%.1f : %s",
            #holes, px, py, table.concat(list, " | ")))
    end
end

-- ============================== ground probe (gta4gg) ==============================
-- Verifies candidate spawn/rescue points with the client's real collision data.
-- Triggered by the server as: triggerClientEvent(p, "lctp:probeCoords", p, {{x,y},...})
addEvent("lctp:probeCoords", true)
addEventHandler("lctp:probeCoords", localPlayer, function(points)
    if type(points) ~= "table" then return end
    local out = {}
    for _, p in ipairs(points) do
        local x, y = tonumber(p[1]), tonumber(p[2])
        if x and y then
            local gz = getGroundPosition(x, y, 500)
            out[#out + 1] = string.format("%.1f,%.1f=>%s", x, y, gz and string.format("%.2f", gz) or "NOGROUND")
        end
    end
    sendDiag("GROUNDPROBE " .. table.concat(out, " | "))
end)

-- ============================== /spotdump (gta4gg) ==============================
-- Dumps every streamed world object around the player (model, position,
-- rotation, distance) to the diag file. Standing at a broken spot and
-- running /spotdump gives the EXACT model ids to patch or hide.
-- Works in any interior/dimension (also identifies furniture inside rooms).

-- server-triggerable variant (used by ng-hotreload eval)
addEvent("lctp:dumpSpot", true)
addEventHandler("lctp:dumpSpot", localPlayer, function()
    local px, py, pz = getElementPosition(localPlayer)
    local objs = getElementsWithinRange(px, py, pz, 80, "building")
    for _, o in ipairs(getElementsWithinRange(px, py, pz, 80, "object")) do
        table.insert(objs, o)
    end
    local lines = {}
    local n = 0
    for _, o in ipairs(objs) do
        if getElementModel(o) then
            local ox, oy, oz = getElementPosition(o)
            local d = getDistanceBetweenPoints3D(px, py, pz, ox, oy, oz)
            local _, _, rz = getElementRotation(o)
            n = n + 1
            if n <= 120 then
                table.insert(lines, string.format("model=%d type=%s pos=%.2f,%.2f,%.2f rotZ=%.1f dist=%.1f",
                    getElementModel(o), getElementType(o), ox, oy, oz, rz, d))
            end
        end
    end
    sendDiag(string.format("SPOTDUMP-SRV at %.1f,%.1f,%.1f int=%d dim=%d objects=%d",
        px, py, pz, getElementInterior(localPlayer), getElementDimension(localPlayer), #objs))
    for _, l in ipairs(lines) do sendDiag("SPOTDUMP-SRV " .. l) end
end)

addCommandHandler("spotdump", function()
    local px, py, pz = getElementPosition(localPlayer)
    -- gta4gg 2026-11-17: LC zone geometry is created as the NEW "building"
    -- element type (eagleLoader element_stream), NOT "object" - scan both.
    local objs = getElementsWithinRange(px, py, pz, 60, "building")
    for _, o in ipairs(getElementsWithinRange(px, py, pz, 60, "object")) do
        table.insert(objs, o)
    end
    local lines = {}
    local n = 0
    for _, o in ipairs(objs) do
        if getElementModel(o) then
            local ox, oy, oz = getElementPosition(o)
            local d = getDistanceBetweenPoints3D(px, py, pz, ox, oy, oz)
            local _, _, rz = getElementRotation(o)
            n = n + 1
            if n <= 80 then
                table.insert(lines, string.format("model=%d type=%s pos=%.2f,%.2f,%.2f rotZ=%.1f dist=%.1f",
                    getElementModel(o), getElementType(o), ox, oy, oz, rz, d))
            end
        end
    end
    sendDiag(string.format("SPOTDUMP at %.1f,%.1f,%.1f int=%d dim=%d objects=%d",
        px, py, pz, getElementInterior(localPlayer), getElementDimension(localPlayer), #objs))
    for _, l in ipairs(lines) do
        sendDiag("SPOTDUMP " .. l)
    end
    outputChatBox("* SPOTDUMP: " .. n .. " objects reported (" .. #lines .. " lines)", 120, 200, 255)
end)
