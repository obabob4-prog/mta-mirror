-- ============================================================
-- LUXURY MECHANIC CENTER / LIBERTY CITY - client
-- World sign, LED architecture and interaction prompt only.
-- All mechanic gameplay (UI, services, invoices, job) lives in
-- lmb_mechanic; this resource only presents the building.
-- ============================================================

LML = LML or {}
LML.site = LML.site or {
    x = -35.0, y = 645.0, baseZ = 8.0, floorZ = 10.4, rotZ = 0,
    interior = 0, dimension = 0,
    road = { x = -90.57, y = 720.37, z = 12.22 },
    entrance = { x = -35.0, y = 657.0, z = 10.4, radius = 4.0 },
    footprint = { halfWidth = 15.0, frontY = 12.0, height = 6.2,
                  signHeight = 8.4, rampFrom = 12.0, rampTo = 62.0 },
}
LML.interior = LML.interior or {
    x = 0, y = 0, z = 10, interior = 0, dimension = 21050, floorZ = 10,
    lifts = { { x = -8, y = 2 }, { x = 0, y = 2 }, { x = 8, y = 2 } },
}
LML.INTERIOR_LAYOUT = LML.INTERIOR_LAYOUT or { leds = {} }

local S = LML.site
local I = LML.interior
local L = LML.INTERIOR_LAYOUT

local sign = dxCreateTexture(":luxury_mechanic_liberty/textures/luxury_sign.png")
local uiFont = dxCreateFont(":lmb_mechanic/fonts/Cairo.ttf", 19, true) or "default-bold"
local sw, sh = guiGetScreenSize()
local sx, sy = sw / 1920, sh / 1080

local GOLD  = tocolor(212, 175,  90)
local RED   = tocolor(186,  30,  38)
local WHITE = tocolor(245, 240, 228)
local DARK  = tocolor(10, 11,  15, 225)

local function line3(x1, y1, z1, x2, y2, z2, col, w)
    dxDrawLine3D(x1, y1, z1, x2, y2, z2, col, w or 2)
end

local function drawSign3D(cx, cy, cz, width, height)
    if not isElement(sign) then return end
    local camX, camY = getCameraMatrix()
    local dxv, dyv = camX - cx, camY - cy
    local len = math.max(0.001, math.sqrt(dxv * dxv + dyv * dyv))
    local nx, ny = -dyv / len, dxv / len
    local hw, hh = width / 2, height / 2

    local a = { cx + nx * hw, cy + ny * hw, cz + hh }
    local b = { cx - nx * hw, cy - ny * hw, cz + hh }
    local c = { cx - nx * hw, cy - ny * hw, cz - hh }
    local d = { cx + nx * hw, cy + ny * hw, cz - hh }

    line3(a[1], a[2], a[3], b[1], b[2], b[3], GOLD, 3)
    line3(b[1], b[2], b[3], c[1], c[2], c[3], GOLD, 3)
    line3(c[1], c[2], c[3], d[1], d[2], d[3], GOLD, 3)
    line3(d[1], d[2], d[3], a[1], a[2], a[3], GOLD, 3)

    dxDrawMaterialLine3D(a[1], a[2], a[3], b[1], b[2], b[3],
        sign, hh * 2, tocolor(255, 255, 255, 245), c[1], c[2], c[3])
end

local function drawExterior()
    local px, py, pz = getElementPosition(localPlayer)
    if getElementDimension(localPlayer) ~= S.dimension then return end
    local d2 = (px - S.x) ^ 2 + (py - S.y) ^ 2
    if d2 > 170 ^ 2 then return end

    local pulse = 0.78 + 0.22 * math.sin(getTickCount() / 650)
    local f = S.footprint
    local z0, z1 = S.floorZ + 0.15, S.floorZ + f.height

    local x0, x1 = S.x - f.halfWidth, S.x + f.halfWidth
    local y0, y1 = S.y - 10, S.y + f.frontY
    line3(x0, y0, z0, x1, y0, z0, GOLD, 2)
    line3(x1, y0, z0, x1, y1, z0, GOLD, 2)
    line3(x1, y1, z0, x0, y1, z0, GOLD, 2)
    line3(x0, y1, z0, x0, y0, z0, GOLD, 2)
    line3(x0, y0, z1, x1, y0, z1, GOLD, 2)
    line3(x1, y1, z1, x0, y1, z1, GOLD, 2)
    line3(x0, y0, z0, x0, y0, z1, GOLD, 2)
    line3(x1, y1, z0, x1, y1, z1, GOLD, 2)

    for _, bx in ipairs({ -7.5, 7.5 }) do
        line3(S.x + bx - 4, S.y + 12.1, S.floorZ + 4.5,
              S.x + bx + 4, S.y + 12.1, S.floorZ + 4.5, RED, 3)
        line3(S.x + bx - 4, S.y + 12.2, S.floorZ + 0.2,
              S.x + bx + 4, S.y + 12.2, S.floorZ + 0.2, tocolor(212, 175, 90, 190 * pulse), 2)
    end

    line3(S.x, S.y + f.rampFrom, S.floorZ + 0.2,
          S.road.x, S.road.y, S.road.z + 0.2, tocolor(212, 175, 90, 120 * pulse), 2)

    if d2 < 150 ^ 2 then
        drawSign3D(S.x, S.y + 15.5, S.floorZ + f.signHeight, 15.0, 2.6)
    end
end

local function drawInterior()
    if getElementDimension(localPlayer) ~= I.dimension then return end
    local pulse = 0.75 + 0.25 * math.sin(getTickCount() / 700)
    for _, p in ipairs(L.leds or {}) do
        line3(I.x + p[1], I.y + p[2], I.floorZ + p[3],
              I.x + p[1] + 3, I.y + p[2], I.floorZ + p[3],
              tocolor(212, 175, 90, 200 * pulse), 3)
    end
    for _, lift in ipairs(I.lifts or {}) do
        line3(I.x + lift.x - 2.6, I.y + lift.y, I.floorZ + 0.5,
              I.x + lift.x + 2.6, I.y + lift.y, I.floorZ + 0.5, RED, 2)
    end
    drawSign3D(I.x, I.y + 9, I.floorZ + 6.4, 11.0, 2.0)
end

addEventHandler("onClientRender", root, function()
    drawExterior()
    drawInterior()
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isElement(sign) then destroyElement(sign) end
end)
