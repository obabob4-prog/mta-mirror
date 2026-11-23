--[[
    gta4hud / minimap.lua
    Real, rotating Liberty City minimap rendered from the project's radar
    texture. Drawn into a square render target (so it can be rotated), then
    composited on screen with a GTA V style rounded frame.

    World -> texture mapping matches Liberty_City_Radar:
        mapX = (worldSize/2 + x) / worldSize * textureSize
        mapY = (worldSize/2 - y) / worldSize * textureSize
]]

MINIMAP = {}

local tex, rt
local rtSize        = 512
local worldSize     = 6000
local textureSize   = 2048
local headingDeg    = 0
local zoom          = 220
local inInterior    = false
local lastSync      = 0
local blipPaths     = {}

for i = 0, 63 do
    blipPaths[i] = string.format("images/blips/%d.png", i)
end

-- Radar rotation helpers (same convention as Radar_Core, but local so this
-- resource does not depend on that resource's globals).
local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end

local function vectorRotation(x, y, x2, y2)
    local twoPi = 6.2831853071796
    local rotation = twoPi - (atan2(x2 - x, y2 - y) % twoPi)
    return -rotation
end

local function cameraRotation()
    local cameraX, cameraY, _, lookX, lookY = getCameraMatrix()
    if not cameraX or not lookX then return 0 end
    return vectorRotation(cameraX, cameraY, lookX, lookY)
end

local function syncSettings()
    local res = getResourceFromName("Liberty_City_Radar")
    if not res or getResourceState(res) ~= "running" then return end
    local s = call(res, "getRadarSettings")
    if type(s) ~= "table" then return end
    local ws, ts = tonumber(s.worldSize), tonumber(s.mapTextureSize)
    if ws and ws > 0 then worldSize = ws end
    if ts and ts > 0 then textureSize = ts end
end

function MINIMAP.init()
    syncSettings()
    zoom = HUDCFG.minimap.viewMeters

    if not tex or not isElement(tex) then
        tex = dxCreateTexture("images/radar.png", "dxt5", true, "clamp")
        if tex and isElement(tex) then
            dxSetTextureEdge(tex, "border", tocolor(15, 18, 22, 255))
        end
    end

    if not rt or not isElement(rt) then
        rt = dxCreateRenderTarget(rtSize, rtSize, true)
    end

    if not tex or not isElement(tex) then
        outputDebugString("[gta4hud] minimap texture could not be created", 2)
    end
end

function MINIMAP.destroy()
    if tex and isElement(tex) then destroyElement(tex) end
    if rt and isElement(rt) then destroyElement(rt) end
    tex, rt = nil, nil
end

function MINIMAP.zoom(delta)
    local cfg = HUDCFG.minimap
    zoom = HUD.clamp(zoom + delta * cfg.zoomStep, cfg.minView, cfg.maxView)
end

function MINIMAP.getZoom()
    return zoom
end

-- draw the rotating map + markers into the render target
local function drawMapSurface(px, py)
    local mapPX = (worldSize * 0.5 + px) / worldSize * textureSize
    local mapPY = (worldSize * 0.5 - py) / worldSize * textureSize

    local pxPerMeterTex = textureSize / worldSize
    local pad = 1.45
    local srcSize = zoom * pxPerMeterTex * pad
    local destSize = rtSize * pad
    local destOff = (rtSize - destSize) * 0.5

    dxSetRenderTarget(rt, true)
    dxDrawRectangle(0, 0, rtSize, rtSize, tocolor(15, 18, 22, 255))
    dxDrawImageSection(destOff, destOff, destSize, destSize,
        mapPX - srcSize * 0.5, mapPY - srcSize * 0.5, srcSize, srcSize,
        tex, -headingDeg, 0, 0, tocolor(255, 255, 255, 255), false)

    local half = rtSize * 0.5
    local k = rtSize / zoom
    local theta = math.rad(headingDeg)
    local cosT, sinT = math.cos(theta), math.sin(theta)

    local function project(wx, wy)
        local rx, ry = wx - px, wy - py
        local sx = rx * cosT - ry * sinT
        local sy = -(ry * cosT + rx * sinT)
        return half + sx * k, half + sy * k
    end

    local cfg = HUDCFG.minimap
    local myDim = getElementDimension(localPlayer)
    local myInt = getElementInterior(localPlayer)
    local limit = half - rtSize * 0.045

    -- ------------------------------------------------------------ blips
    local drawn = 0
    for _, blip in ipairs(getElementsByType("blip")) do
        if drawn < 140 then
            local attached = getElementAttachedTo(blip)
            if attached ~= localPlayer
                and getElementDimension(blip) == myDim
                and getElementInterior(blip) == myInt then
                local bx, by = getElementPosition(blip)
                if bx and by then
                    local sx, sy = project(bx, by)
                    local dx, dy = sx - half, sy - half
                    dx = HUD.clamp(dx, -limit, limit)
                    dy = HUD.clamp(dy, -limit, limit)

                    local icon = getBlipIcon(blip) or 0
                    local size = cfg.blipSize
                    local custom = tonumber(getElementData(blip, "blipSize"))
                    if custom then size = size * HUD.clamp(custom / 20, 0.65, 1.9) end

                    local r, g, b, a = 255, 255, 255, 255
                    if icon == 0 or icon == 1 then
                        r, g, b, a = getBlipColor(blip)
                        a = a or 255
                    end

                    dxDrawImage(half + dx - size * 0.5, half + dy - size * 0.5, size, size,
                        blipPaths[icon] or blipPaths[0], 0, 0, 0,
                        tocolor(r, g, b, a), false)
                    drawn = drawn + 1
                end
            end
        end
    end

    -- ---------------------------------------------------------- players
    if cfg.showPlayers then
        local range = cfg.playerRange
        local rangeSq = range * range
        for _, player in ipairs(getElementsByType("player")) do
            if player ~= localPlayer
                and not getElementData(player, "dontshow")
                and getElementDimension(player) == myDim
                and getElementInterior(player) == myInt then
                local ox, oy = getElementPosition(player)
                if ox and getDistanceBetweenPoints2D(ox, oy, px, py) <= range then
                    local sx, sy = project(ox, oy)
                    local dx, dy = sx - half, sy - half
                    if dx * dx + dy * dy <= rangeSq then
                        local r, g, b = getPlayerNametagColor(player)
                        local rot = (360 - (getPedRotation(player) or 0) - headingDeg) % 360
                        local size = 17
                        dxDrawImage(sx - size * 0.5, sy - size * 0.5, size, size,
                            "icons/arrow.png", rot, 0, 0, tocolor(r or 255, g or 255, b or 255, 235), false)
                    end
                end
            end
        end
    end

    -- --------------------------------------------------------- vehicles
    if cfg.showVehicles then
        local vRange = cfg.vehicleRange
        local count = 0
        for _, veh in ipairs(getElementsByType("vehicle")) do
            if count < 28
                and getElementDimension(veh) == myDim
                and getVehicleOccupant(veh) then
                local vx, vy = getElementPosition(veh)
                if vx and getDistanceBetweenPoints2D(vx, vy, px, py) <= vRange then
                    local sx, sy = project(vx, vy)
                    local dx, dy = sx - half, sy - half
                    if dx * dx + dy * dy < (half - 6) * (half - 6) then
                        dxDrawRectangle(sx - 2, sy - 2, 4, 4, tocolor(235, 240, 246, 120), false)
                        count = count + 1
                    end
                end
            end
        end
    end

    -- ------------------------------------------------------ local player
    local pedRot = getPedRotation(localPlayer) or 0
    local arrowRot = (360 - pedRot - headingDeg) % 360
    local arrow = cfg.arrowSize
    local ax, ay = half - arrow * 0.5, half - arrow * 0.5

    -- dark outline so the arrow stays readable on light streets
    dxDrawImage(ax - 1, ay - 1, arrow + 2, arrow + 2, "icons/arrow.png", arrowRot, 0, 0, tocolor(0, 0, 0, 135), false)
    dxDrawImage(ax, ay, arrow, arrow, "icons/arrow.png", arrowRot, 0, 0, tocolor(255, 255, 255, 255), false)

    dxSetRenderTarget()
end

--- Draw the minimap on screen. Returns the screen rectangle used.
function MINIMAP.render(mapX, mapY, mapSize)
    if not tex or not isElement(tex) or not rt or not isElement(rt) then
        return
    end

    local now = getTickCount()
    if now - lastSync > 15000 then
        lastSync = now
        syncSettings()
    end

    local px, py = getElementPosition(localPlayer)

    local rot = cameraRotation()
    local targetDeg = HUDCFG.minimap.rotate and math.deg(rot) or 0
    local diff = ((targetDeg - headingDeg + 540) % 360) - 180
    headingDeg = (headingDeg + diff * 0.22 + 360) % 360

    inInterior = getElementInterior(localPlayer) ~= 0

    drawMapSurface(px, py)

    local cfg = HUDCFG.minimap
    local circle = cfg.shape == "circle"
    local radius = circle and (mapSize * 0.5) or HUD.s(cfg.radius)
    local cx, cy = mapX + mapSize * 0.5, mapY + mapSize * 0.5
    local r = mapSize * 0.5

    if circle then
        -- drop shadow
        dxDrawCircle(cx, cy, r + HUD.s(cfg.bezel) + HUD.s(3), 0, 360,
            HUD.tocol(HUD.rgba(0, 0, 0, 70)), HUD.tocol(HUD.rgba(0, 0, 0, 70)), 56)
        -- thick black bezel
        dxDrawCircle(cx, cy, r + HUD.s(cfg.bezel), 0, 360,
            HUD.tocol(HUD.rgba(0, 0, 0, 225)), HUD.tocol(HUD.rgba(0, 0, 0, 225)), 56)
        -- subtle inner highlight ring (map is drawn on top of it)
        dxDrawCircle(cx, cy, r + HUD.s(2), 0, 360,
            HUD.tocol(HUD.rgba(255, 255, 255, 30)), HUD.tocol(HUD.rgba(255, 255, 255, 30)), 56)
    else
        HUD.panel(mapX - HUD.s(3), mapY - HUD.s(3), mapSize + HUD.s(6), mapSize + HUD.s(6),
            radius + HUD.s(3), { 0, 0, 0, 95 })
    end

    HUD.roundedTexture(mapX, mapY, mapSize, mapSize, rt, radius, 1.2)

    if inInterior then
        if circle then
            dxDrawCircle(cx, cy, r, 0, 360,
                HUD.tocol(HUD.rgba(6, 8, 10, 120)), HUD.tocol(HUD.rgba(6, 8, 10, 120)), 48)
        else
            HUD.panel(mapX, mapY, mapSize, mapSize, radius, { 6, 8, 10, 120 })
        end
    end

    if not circle then
        -- soft vignette + clean 1px frame
        HUD.panel(mapX, mapY, mapSize, mapSize, radius, nil, { 0, 0, 0, 70 }, HUD.s(7))
        HUD.panel(mapX, mapY, mapSize, mapSize, radius, nil, HUDCFG.colors.border, HUD.s(cfg.borderWidth))
    end

    -- north indicator
    local nr = r - HUD.s(18)
    local theta = math.rad(headingDeg)
    local nx = cx - math.sin(theta) * nr
    local ny = cy - math.cos(theta) * nr
    local ns = HUD.s(12)
    if circle then
        dxDrawCircle(nx, ny, HUD.s(11), 0, 360,
            HUD.tocol(HUD.rgba(0, 0, 0, 140)), HUD.tocol(HUD.rgba(0, 0, 0, 140)), 24)
    end
    HUD.text("N", nx - ns, ny - ns * 0.75, nx + ns, ny + ns * 0.75,
        HUD.rgba(255, 255, 255, 200), 11, "default-bold", "center", "center")
end
