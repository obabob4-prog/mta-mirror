--[[
    gta4hud / client.lua
    GTA IV / GTA V inspired HUD for gta4gg (Liberty City).

    class   layout (HUDCFG.style = "classic")
        bottom-left   circular radar + black bezel + segmented vitals strip
        bottom-right  weapon + speed/fuel strip
        top-right     premium cash card + wanted stars
        above radar   radio badge (auto-hides)

    Keys: F7 toggle HUD, F8 cycle radar size, mouse wheel zoom radar.
]]

local hudVisible     = true
local hudAlpha       = 0
local lastFrame      = 0
local bigmapOpen     = false
local mapSizeIndex   = 1

local weaponCacheId  = -1
local weaponCacheName = ""

local nativeComponents = {
    "health", "armour", "money", "weapon", "ammo", "clock",
    "area_name", "vehicle_name", "breath", "wanted", "radio", "radar",
}

-- ------------------------------------------------------------- native HUD

local function hideNativeHud()
    for i = 1, #nativeComponents do
        setPlayerHudComponentVisible(nativeComponents[i], false)
    end
end

-- ----------------------------------------------------------- radar bridge

local function hideRadarCoreMinimap()
    local res = getResourceFromName("Radar_Core")
    if res and getResourceState(res) == "running" then
        call(res, "setMinimapVisible", false)
    end
end

local function pollBigmap()
    bigmapOpen = HUD.isBigmapOpen()
end

-- ------------------------------------------------------------- layout box

local function mapSizes()
    local base = HUDCFG.minimap.size
    return { base, math.floor(base * 1.22) }
end

local function layout()
    local S = HUD.s
    local cfg = HUDCFG
    local size = S(mapSizes()[mapSizeIndex])
    local mapX = S(cfg.minimap.x)
    local stripH = S(cfg.vitals.height)
    local gap = S(cfg.minimap.gapBelow)
    local mapY = HUD.sh - S(cfg.marginBottom) - stripH - gap - size - S(cfg.minimap.bottomOffset)
    return mapX, mapY, size, mapY + size + gap
end

-- --------------------------------------------------------------- weapon

local function weaponName(id)
    if id ~= weaponCacheId then
        weaponCacheId = id
        weaponCacheName = (getWeaponNameFromID(id) or ""):upper()
    end
    return weaponCacheName
end

local function drawWeapon(bottomY)
    local cfg = HUDCFG
    local S = HUD.s
    local wp = getPedWeapon(localPlayer) or 0
    if wp <= 0 then return end

    local name = weaponName(wp)
    if name == "" then return end
    local ammo = getPedTotalAmmo(localPlayer) or 0
    local right = HUD.sw - S(cfg.marginRight)

    if cfg.weapon.style == "classic" then
        HUD.text(name, right - S(320), bottomY - S(54), right, bottomY - S(26),
            HUD.color(cfg.colors.weapon, 0.96), cfg.weapon.nameSize, "default-bold", "right", "bottom")
        HUD.text(tostring(ammo), right - S(320), bottomY - S(22), right, bottomY,
            HUD.color(cfg.colors.text, 0.88), cfg.weapon.ammoSize, "default-bold", "right", "bottom")
    else
        local chipW = S(cfg.weapon.chipWidth)
        local chipH = S(cfg.weapon.chipHeight)
        local chipY = bottomY - chipH
        HUD.panel(right - chipW, chipY, chipW, chipH, S(8), cfg.colors.panelSoft, cfg.colors.border, 1)
        HUD.text(name, right - chipW + S(10), chipY, right - S(48), chipY + chipH,
            HUD.color(cfg.colors.weapon), 15, "default-bold", "left", "center")
        HUD.text(tostring(ammo), right - S(10) - S(38), chipY, right - S(10), chipY + chipH,
            HUD.color(cfg.colors.textDim), 15, "default-bold", "right", "center")
    end
end

-- -------------------------------------------------------------- vehicle

local function drawVehicle(bottomY)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh or getVehicleController(veh) ~= localPlayer then return 0 end

    local cfg = HUDCFG
    local S = HUD.s
    local w = S(cfg.vehicle.chipWidth)
    local h = S(cfg.vehicle.chipHeight)
    local right = HUD.sw - S(cfg.marginRight)
    local x = right - w
    local y = bottomY - h

    local vx, vy, vz = getElementVelocity(veh)
    local speed = math.floor(math.sqrt(vx * vx + vy * vy + vz * vz) * 181.5)

    if cfg.vehicle.style == "classic" then
        dxDrawRectangle(x, y, w, h, HUD.tocol(HUD.color(cfg.colors.strip)))
        dxDrawRectangle(x, y, w, 1, HUD.tocol(HUD.rgba(255, 255, 255, 22)))
        HUD.text(tostring(speed), x + S(12), y + S(4), x + S(96), y + h - S(12),
            HUD.color(cfg.colors.speed), 26, "default-bold", "left", "center")
        HUD.text("KM/H", x + S(12), y + h - S(22), x + S(96), y + h - S(4),
            HUD.color(cfg.colors.textDim), 11, "default-bold", "left", "center")
    else
        HUD.panel(x, y, w, h, S(10), cfg.colors.panel, cfg.colors.border, 1)
        HUD.text(tostring(speed), x + S(12), y, x + S(90), y + h - S(10),
            HUD.color(cfg.colors.speed), 26, "default-bold", "left", "center")
        HUD.text("KM/H", x + S(12), y + h - S(24), x + S(90), y + h - S(4),
            HUD.color(cfg.colors.textDim), 11, "default-bold", "left", "center")
    end

    HUD.icon("icons/fuel.png", x + w - S(30), y + S(12), S(15), HUD.color(cfg.colors.fuel, 0.82))
    local fuel = HUD.clamp((tonumber(getElementData(veh, "veh.fuel")) or 100) / 100, 0, 1)
    local barX, barW = x + w - S(96), S(66)
    if cfg.vehicle.style == "classic" then
        dxDrawRectangle(barX, y + S(40), barW, S(6), HUD.tocol(HUD.rgba(255, 255, 255, 26)))
        dxDrawRectangle(barX, y + S(40), barW * fuel, S(6), HUD.tocol(HUD.color(cfg.colors.fuel, 0.92)))
    else
        HUD.bar(barX, y + S(40), barW, S(6), fuel,
            HUD.color(cfg.colors.fuel, 0.9), HUD.color({ 0, 0, 0, 150 }))
    end

    return h
end

-- ----------------------------------------------------------------- zone

local zoneName = ""
local zoneAt = 0

local function updateZone()
    local now = getTickCount()
    if now - zoneAt < 1000 then return end
    zoneAt = now
    local px, py, pz = getElementPosition(localPlayer)
    zoneName = getZoneName(px, py, pz, true) or ""
end

local function drawZone(mapX, mapY, mapSize, vitalsY)
    if zoneName == "" then return end
    local cfg = HUDCFG
    local S = HUD.s

    if cfg.style == "classic" then
        local x = mapX + mapSize + S(18)
        HUD.text(zoneName:upper(), x, vitalsY + S(4), x + S(420), vitalsY + S(28),
            HUD.color(cfg.colors.zone, 0.92), 16, "default-bold", "left", "center")
    else
        local right = HUD.sw - S(cfg.marginRight)
        local y = HUD.sh - S(cfg.marginBottom) - S(24)
        HUD.text(zoneName:upper(), right - S(460), y, right, y + S(24),
            HUD.color(cfg.colors.zone, 0.92), 17, "default-bold", "right", "center")
    end
end

-- ------------------------------------------------------------- info strip
-- 2026-11-19: compact top-left identity strip.  Clock/date, character number
-- and microphone state were requested for every in-game session; it stays
-- small and never overlaps the cash card (top-right) or the radar (bottom-left).
local function drawInfoStrip()
    local cfg = HUDCFG
    local S = HUD.s
    local x = S(cfg.marginTop + 6)
    local y = S(cfg.marginTop + 2)
    local w, h = S(300), S(30)
    local pname = tostring(getElementData(localPlayer, "char.name") or getPlayerName(localPlayer) or "LC")
    local pid = tostring(getElementData(localPlayer, "char.id") or getElementData(localPlayer, "ngc.charid") or "-")
    local hh, mm = getTime()
    local day, month, year = getRealDateTime and getRealDateTime() or nil
    local date = ""
    if day then
        date = string.format("%02d/%02d/%04d  ", day, month, year)
    else
        local t = getTickCount()
        date = os and os.date and os.date("%d/%m/%Y  ") or ""
    end
    local mic = "MIC OFF"
    if type(isVoiceInputEnabled) == "function" and isVoiceInputEnabled() then mic = "MIC ON" end

    HUD.panel(x, y, w, h, S(7), cfg.colors.panel, cfg.colors.border, 1)
    dxDrawRectangle(x, y, S(3), h, HUD.tocol(HUD.rgba(232, 197, 107, 220)))
    HUD.text(string.format("%s%02d:%02d", date, hh, mm), x + S(10), y, x + S(120), y + h,
        HUD.color(cfg.colors.text, 0.92), 12, "default-bold", "left", "center")
    HUD.text("ID:" .. pid, x + S(124), y, x + S(190), y + h,
        HUD.color(cfg.colors.textDim, 0.9), 11, "default-bold", "left", "center")
    HUD.text(mic, x + S(196), y, x + w - S(8), y + h,
        HUD.color({ 232, 197, 107, 255 }, 0.95), 11, "default-bold", "right", "center")
end

-- ---------------------------------------------------------------- render

addEventHandler("onClientRender", root,
    function()
        local now = getTickCount()
        local dt = (now - lastFrame) / 1000
        if dt <= 0 or dt > 0.5 then dt = 0.016 end
        lastFrame = now

        local wantHud = hudVisible
            and getElementData(localPlayer, "char.spawned")
            and not isCursorShowing()
            and not bigmapOpen

        local target = wantHud and 1 or 0
        if HUD.alpha ~= target then
            hudAlpha = hudAlpha + (target - hudAlpha) * (target > hudAlpha and 0.16 or 0.28)
            if math.abs(target - hudAlpha) < 0.01 then hudAlpha = target end
        end
        if hudAlpha <= 0 then return end

        HUD.alpha = hudAlpha

        local S = HUD.s
        local mapX, mapY, size, vitalsY = layout()
        local bottom = HUD.sh - S(HUDCFG.marginBottom)

        MONEY.update()
        updateZone()
        drawInfoStrip()

        MINIMAP.render(mapX, mapY, size)
        VITALS.render(mapX, mapY, size)
        RADIO.render(mapX, mapY, size)

        local starsBottom = MONEY.render()

        local vehH = drawVehicle(bottom)
        if vehH > 0 then
            drawWeapon(bottom - vehH - S(HUDCFG.vehicle.gapAbove))
        else
            drawWeapon(bottom)
        end

        drawZone(mapX, mapY, size, vitalsY)

        HUD.alpha = 0
    end
)

-- ----------------------------------------------------------- key handling

bindKey("f7", "down",
    function()
        hudVisible = not hudVisible
        playSoundFrontEnd(hudVisible and 1 or 2)
    end)

bindKey("f8", "down",
    function()
        mapSizeIndex = mapSizeIndex + 1
        if mapSizeIndex > #mapSizes() then mapSizeIndex = 1 end
        playSoundFrontEnd(mapSizeIndex == 1 and 2 or 1)
    end)

addEventHandler("onClientKey", root,
    function(key, state)
        if not state or isCursorShowing() then return end
        if key == "mouse_wheel_up" then
            MINIMAP.zoom(-1)
        elseif key == "mouse_wheel_down" then
            MINIMAP.zoom(1)
        end
    end)

-- ------------------------------------------------------------- lifecycle

local function startHud()
    if HUD.started then return end
    HUD.started = true

    HUD.createShaders()
    MINIMAP.init()
    hideNativeHud()

    setTimer(hideNativeHud, 1200, 0)
    setTimer(hideRadarCoreMinimap, 2500, 0)
    setTimer(pollBigmap, 250, 0)
    setTimer(HUD.refresh, 1000, 0)

    -- a few quick retries: Radar_Core / Liberty_City_Radar may still be starting
    for i = 1, 12 do
        setTimer(hideRadarCoreMinimap, 400 + i * 700, 1)
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        startHud()
    end)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        MINIMAP.destroy()
        HUD.destroyShaders()
    end)

-- in case the script is (re)started after the client is already in-game
if getElementData(localPlayer, "char.spawned") then
    setTimer(startHud, 600, 1)
end

-- --------------------------------------------------------------- exports

function setHudVisible(visible)
    hudVisible = visible and true or false
    return true
end

function isHudVisible()
    return hudVisible
end

function getHudVersion()
    return HUDCFG.version
end
