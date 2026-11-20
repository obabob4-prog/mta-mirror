-- ============================================================
-- LmB Customs - world interaction layer
-- The physical building / sign / LED trim is drawn by the
-- luxury_mechanic_liberty resource. This file adds the work
-- lights, the interaction prompt and the mechanic animation.
-- ============================================================

local DEFAULT_W = { x = -35.0, y = 645.0, z = 10.40, radiusUI = 16.0, interior = 0, dimension = 0 }

local function getW()
    if type(LMB) == "table" and type(LMB.workshop) == "table" then
        return LMB.workshop
    end
    return DEFAULT_W
end

local sw, sh = guiGetScreenSize()
local sx, sy = sw / 1920, sh / 1080
local lights = {}
local near = false
local nearZone = nil

local GOLD  = tocolor(212, 175, 90)
local WHITE = tocolor(245, 240, 228)
local DARK  = tocolor(10, 11, 15, 230)
local arFont = dxCreateFont(":lmb_mechanic/fonts/Cairo.ttf", 20, true) or "default-bold"

local function dist2(ax, ay, bx, by)
    return (ax - bx) ^ 2 + (ay - by) ^ 2
end

local function createWorkLights()
    local W = getW()
    for _, p in ipairs({
        { -11, 13, 4.8 }, { 11, 13, 4.8 },
        { -11,  2, 4.8 }, { 11,  2, 4.8 },
    }) do
        local l = createLight(0, W.x + p[1], W.y + p[2], W.z + p[3], 9, 212, 175, 90)
        if isElement(l) then
            setElementInterior(l, W.interior or 0)
            setElementDimension(l, W.dimension or 0)
            lights[#lights + 1] = l
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(createWorkLights, 600, 1)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, l in ipairs(lights) do
        if isElement(l) then destroyElement(l) end
    end
    lights = {}
end)

addEventHandler("onClientRender", root, function()
    local W = getW()
    local px, py = getElementPosition(localPlayer)
    local d2 = dist2(px, py, W.x, W.y)
    if d2 > 130 ^ 2 then return end

    local radius = tonumber(W.radiusUI) or 16
    if d2 <= radius ^ 2 then
        local txt = "LmB Customs  |  ورشة الميكانيك  |  /lmb"
        local w, h = 580 * sx, 46 * sy
        local x, y = sw / 2 - w / 2, sh * 0.80
        dxDrawRectangle(x, y, w, h, DARK)
        dxDrawRectangle(x, y, w, 2 * sy, GOLD)
        dxDrawText(txt, x, y, x + w, y + h, WHITE, 0.95 * sx, 0.95 * sy,
            arFont, "center", "center", false, true, false, false, false, 0, 0, 0)
    end
end)

addEvent("lmb:nearWorkshop", true)
addEventHandler("lmb:nearWorkshop", root, function(state, zoneName)
    near = state == true
    nearZone = zoneName
end)

addEvent("lmb:workAnim", true)
addEventHandler("lmb:workAnim", root, function(kind)
    local p = localPlayer
    if not isElement(p) then return end
    local x, y, z = getElementPosition(p)
    if getPedOccupiedVehicle(p) then
        clearPedTasks(p)
    else
        setPedAnimation(p, "WELDING", "welding", 2200, true, false, false)
        setTimer(function() if isElement(p) then setPedAnimation(p) end end, 2300, 1)
    end
    playSound3D(":lmb_mechanic/sounds/tool.wav", x, y, z + 0.8, false)
    if kind == "paint" then
        setTimer(function() playSound3D(":lmb_mechanic/sounds/tool.wav", x, y + 1, z + 0.8, false) end, 280, 1)
    end
end)
