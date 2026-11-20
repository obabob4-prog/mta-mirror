-- Cinematic helper camera + character-select driver.
-- Lets the server park a fixed camera on the workshop, take a clean capture,
-- and spawn a real character through the game's own login UI events instead of
-- teleport hackery (which left the client stuck in the 3D creator).

local charList = nil

addEvent("lux_shot:cam", true)
addEventHandler("lux_shot:cam", root, function(x, y, z, tx, ty, tz)
    if not isElement(localPlayer) then return end
    setCameraMatrix(x, y, z, tx, ty, tz)
    outputDebugString("[lux_shot] camera set")
end)

addEvent("lux_shot:reset", true)
addEventHandler("lux_shot:reset", root, function()
    if not isElement(localPlayer) then return end
    setCameraTarget(localPlayer)
end)

-- ng-characters broadcasts the character list to the client
addEventHandler("ngc:showCharList", root, function(list)
    charList = list
    outputDebugString("[lux_shot] char list received: " .. tostring(list and #list or 0))
end)

local function pick(index, tries)
    tries = tries or 0
    if charList and charList[index or 1] then
        local id = charList[index or 1].id
        outputDebugString("[lux_shot] selecting character " .. tostring(id))
        triggerServerEvent("ngc:selectChar", localPlayer, tonumber(id))
        return
    end
    if tries > 10 then
        outputDebugString("[lux_shot] no character list available", 3)
        return
    end
    -- ask ng-characters to resend the list, then retry
    triggerServerEvent("ngc:uiRequest", localPlayer)
    setTimer(function()
        if isElement(localPlayer) then pick(index, tries + 1) end
    end, 1000, 1)
end

addEvent("lux_shot:pick", true)
addEventHandler("lux_shot:pick", root, function(index)
    pick(index)
end)

-- ------------------------------------------------------------------
-- Open ground scanner: finds flat, unobstructed spots near a centre.
-- Used once to pick a workshop location; not part of normal gameplay.
-- ------------------------------------------------------------------
local DIRS = {
    {1, 0}, {0.7071, 0.7071}, {0, 1}, {-0.7071, 0.7071},
    {-1, 0}, {-0.7071, -0.7071}, {0, -1}, {0.7071, -0.7071},
}

local scan = nil

local function finishScan()
    local cells = scan.cells
    table.sort(cells, function(a, b) return a.score > b.score end)
    local out = {}
    for i = 1, math.min(#cells, 40) do
        local c = cells[i]
        out[#out + 1] = string.format("%.1f,%.1f,%.1f,%d", c.x, c.y, c.z, c.score)
    end
    triggerServerEvent("lux_shot:scanData", localPlayer, scan.tag, table.concat(out, ";"))
    outputDebugString("[lux_shot] scan done: " .. #cells .. " open cells")
    scan = nil
end

local function scanTick()
    if not scan then return end
    local budget = 45
    while budget > 0 and scan.i <= #scan.pts do
        local p = scan.pts[scan.i]
        scan.i = scan.i + 1
        budget = budget - 1

        local gz = getGroundPosition(p.x, p.y, 150)
        if gz and gz > 1 then
            local open = 0
            for k = 1, 8 do
                local clearDist = 0
                for dd = 4, 16, 4 do
                    local ok = isLineOfSightClear(p.x, p.y, gz + 1.2,
                        p.x + DIRS[k][1] * dd, p.y + DIRS[k][2] * dd, gz + 1.2,
                        true, false, false, true, false, false, false, false)
                    if ok then clearDist = dd else break end
                end
                open = open + clearDist
            end
            if open >= 88 then          -- average 11 m clear in all directions
                scan.cells[#scan.cells + 1] = { x = p.x, y = p.y, z = gz, score = open }
            end
        end
    end
    if scan.i > #scan.pts then
        finishScan()
        return
    end
    setTimer(scanTick, 25, 1)
end

addEvent("lux_shot:scan", true)
addEventHandler("lux_shot:scan", root, function(cx, cy, half, step)
    if not isElement(localPlayer) then return end
    if scan then outputDebugString("[lux_shot] scan already running", 2) return end
    step = step or 5
    local pts = {}
    for x = cx - half, cx + half, step do
        for y = cy - half, cy + half, step do
            pts[#pts + 1] = { x = x, y = y }
        end
    end
    scan = { pts = pts, i = 1, cells = {}, tag = string.format("%.0f_%.0f", cx, cy) }
    outputDebugString("[lux_shot] scanning " .. #pts .. " points")
    scanTick()
end)
