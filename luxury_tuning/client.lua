--[[
    [LuxuryCars] Tuning Garage - client side (DX menu)
    Open with /tune while sitting in a vehicle.
]]

local screenW, screenH = guiGetScreenSize()
local sx, sy = screenW / 1920, screenH / 1080

local menu = { open = false, vehicle = nil, page = "main", notify = nil, notifyTime = 0 }

local COLORS = {
    { "أسود لامع",   10, 10, 10 },  { "أبيض لؤلؤي", 235, 235, 235 },
    { "فضي معدني",  160, 165, 170 }, { "رمادي مطفي",  70, 72, 75 },
    { "أحمر فيراري", 200, 15, 20 }, { "أحمر داكن",   120, 10, 15 },
    { "أزرق مكلارين", 20, 60, 200 }, { "أزرق سماوي",  30, 120, 220 },
    { "أصفر لامبو", 235, 190, 20 }, { "برتقالي",     230, 110, 20 },
    { "أخضر زمردي",  15, 110, 60 }, { "بنفسجي",      90, 20, 140 },
    { "ذهبي فاخر",  190, 160, 70 }, { "بني جلدي",    95, 60, 35 },
}

local function px(v) return math.floor(v * sx) end
local function py(v) return math.floor(v * sy) end

-- MTA has no built-in mouse-rect hit test: provide one (cursor must be shown)
local function isMouseInPosition(x, y, w, h)
    if not isCursorShowing() then return false end
    local cx, cy = getCursorPosition()
    if not cx then return false end
    cx, cy = cx * screenW, cy * screenH
    return cx >= x and cx <= x + w and cy >= y and cy <= y + h
end

local function drawText(txt, x, y, w, h, color, scale, align)
    dxDrawText(txt, x, y, x + w, y + h, color or tocolor(255, 255, 255, 255),
        scale or 1, "default-bold", align or "center", "center", false, false, false, true)
end

local function button(x, y, w, h, label, action, active)
    local hovered = isMouseInPosition and isMouseInPosition(px(x), py(y), px(w), py(h)) or false
    local bg = active and tocolor(200, 160, 40, 220) or (hovered and tocolor(60, 60, 70, 240) or tocolor(25, 25, 32, 235))
    dxDrawRectangle(px(x), py(y), px(w), py(h), bg)
    dxDrawRectangle(px(x), py(y) + py(h) - 2, px(w), 2, tocolor(200, 160, 40, 200))
    drawText(label, px(x), py(y), px(w), py(h), tocolor(240, 240, 245, 255), 0.95)
    if hovered and getKeyState("mouse1") then
        action()
    end
end

local function closeMenu()
    menu.open = false
    menu.vehicle = nil
    showCursor(false)
end

local function notify(msg, kind)
    menu.notify = msg
    menu.notifyTime = getTickCount()
    menu.notifyKind = kind
end

local function render()
    if not menu.open then return end

    local W, H = 700, 520
    local X, Y = (screenW / sx - W) / 2, (screenH / sy - H) / 2

    dxDrawRectangle(px(X), py(Y), px(W), py(H), tocolor(12, 12, 16, 235))
    dxDrawRectangle(px(X), py(Y), px(W), py(54), tocolor(20, 20, 26, 255))
    drawText("LUXURY TUNING GARAGE", px(X), py(Y), px(W), py(54), tocolor(200, 160, 40, 255), 1.25)
    drawText("وظيفة الميكانيكي — تعديل السيارات الفاخرة", px(X), py(Y + 38), px(W), py(20), tocolor(160, 160, 170, 255), 0.8)

    -- close button
    button(X + W - 56, Y + 12, 40, 30, "X", closeMenu)

    local bx, by = X + 24, Y + 80
    local bw, bh, gap = (W - 48 - 24) / 3, 46, 12

    if menu.page == "main" then
        button(bx, by, bw, bh, "الطلاء", function() menu.page = "paint" end)
        button(bx + bw + gap, by, bw, bh, "الأداء", function() menu.page = "perf" end)
        button(bx + (bw + gap) * 2, by, bw, bh, "الإضافات", function() menu.page = "extras" end)
        button(bx, by + 120, bw * 2 + gap, bh, "إصلاح السيارة", function() triggerServerEvent("luxury:repair", localPlayer) end)
        button(bx + (bw + gap) * 2, by + 120, bw, bh, "إغلاق", closeMenu)

        drawText("اختر فئة التعديل من الأعلى", px(bx), py(by + 200), px(W - 48), py(40),
            tocolor(120, 120, 130, 255), 0.9)
    elseif menu.page == "paint" then
        for i, c in ipairs(COLORS) do
            local col = (i - 1) % 7
            local row = math.floor((i - 1) / 7)
            local cx = bx + col * ((W - 48) / 7)
            local cy = by + row * 90
            dxDrawRectangle(px(cx), py(cy), px((W - 48) / 7 - 8), py(60), tocolor(c[2], c[3], c[4], 255))
            if isMouseInPosition and isMouseInPosition(px(cx), py(cy), px((W - 48) / 7 - 8), py(60)) and getKeyState("mouse1") then
                triggerServerEvent("luxury:applyPaint", localPlayer, c[2], c[3], c[4])
            end
            drawText(c[1], px(cx), py(cy + 64), px((W - 48) / 7 - 8), py(20), tocolor(200, 200, 210, 255), 0.8)
        end
        button(bx, Y + H - 70, 120, 42, "رجوع", function() menu.page = "main" end)
    elseif menu.page == "perf" then
        button(bx, by, bw * 1.5, bh, "مرحلة 1 (+10%)", function() triggerServerEvent("luxury:applyHandling", localPlayer, 1) end)
        button(bx, by + 64, bw * 1.5, bh, "مرحلة 2 (+22%)", function() triggerServerEvent("luxury:applyHandling", localPlayer, 2) end)
        button(bx, by + 128, bw * 1.5, bh, "مرحلة 3 (+35%)", function() triggerServerEvent("luxury:applyHandling", localPlayer, 3) end)
        drawText("تُطبق المراحل على المحرك والفرامل والاحتكاك", px(bx + bw * 1.6), py(by + 20), px(W - 200), py(90),
            tocolor(150, 150, 160, 255), 0.85, "left")
        button(bx, Y + H - 70, 120, 42, "رجوع", function() menu.page = "main" end)
    else
        button(bx, by, bw, bh, "نيترو ×2", function() triggerServerEvent("luxury:addUpgrade", localPlayer, 1008) end)
        button(bx, by + 64, bw, bh, "نيترو ×5", function() triggerServerEvent("luxury:addUpgrade", localPlayer, 1009) end)
        button(bx, by + 128, bw, bh, "نيترو ×10", function() triggerServerEvent("luxury:addUpgrade", localPlayer, 1010) end)
        button(bx + bw + gap, by, bw, bh, "هايدروليك", function() triggerServerEvent("luxury:addUpgrade", localPlayer, 1087) end)

        drawText("ألوان الإضاءة الأمامية:", px(bx), py(by + 210), px(300), py(24), tocolor(200, 200, 210, 255), 0.9, "left")
        local lights = { { 255, 235, 200 }, { 200, 220, 255 }, { 255, 200, 120 }, { 150, 255, 180 }, { 255, 120, 120 } }
        for i, c in ipairs(lights) do
            local lx = bx + (i - 1) * 62
            dxDrawRectangle(px(lx), py(by + 245), px(52), py(38), tocolor(c[1], c[2], c[3], 255))
            if isMouseInPosition and isMouseInPosition(px(lx), py(by + 245), px(52), py(38)) and getKeyState("mouse1") then
                local veh = menu.vehicle
                if isElement(veh) then setVehicleHeadLightColor(veh, c[1], c[2], c[3]) end
            end
        end
        button(bx, Y + H - 70, 120, 42, "رجوع", function() menu.page = "main" end)
    end

    -- notification
    if menu.notify and getTickCount() - menu.notifyTime < 4000 then
        local col = menu.notifyKind == "error" and tocolor(220, 60, 60, 235) or tocolor(40, 160, 90, 235)
        dxDrawRectangle(px(X), py(Y + H - 130), px(W), py(40), col)
        drawText(menu.notify, px(X), py(Y + H - 130), px(W), py(40), tocolor(255, 255, 255, 255), 0.95)
    end
end

-- server -> client events must be registered on BOTH sides, otherwise MTA
-- silently drops them ("event is not added clientside") and the menu never opens
addEvent("luxury:openMenu", true)
addEvent("luxury:notify", true)

addEventHandler("luxury:openMenu", root, function(veh)
    menu.open = true
    menu.vehicle = veh
    menu.page = "main"
    showCursor(true)
end)

addEventHandler("luxury:notify", root, function(msg, kind)
    notify(msg, kind)
end)

addEventHandler("onClientRender", root, render)
addEventHandler("onClientResourceStop", resourceRoot, closeMenu)

-- ======================= WORKSHOP MAP MARKER =======================
-- Gold beacon + ground rings + 3D sign above the tuning workshop.
-- Everything here is distance limited and cached so it costs ~nothing.

local garage = { x = -1090.00, y = 1118.00, z = 25.20 }
local hintUntil = 0
local SIGN_HEIGHT = 6.0
local VIEW_DISTANCE = 45          -- beacon is only drawn inside this range
local losCache = { t = 0, ok = true }

-- real world-space billboard (visible from 160 m, always faces the camera)
local signTexture = nil
addEventHandler("onClientResourceStart", resourceRoot, function()
    signTexture = dxCreateTexture("sign.png", "argb", true, "clamp")
    if not signTexture then outputDebugString("[luxury_tuning] sign.png failed to load", 2) end
end)
addEventHandler("onClientResourceStop", resourceRoot, function()
    if isElement(signTexture) then destroyElement(signTexture) end
    signTexture = nil
end)

addEvent("luxury:setGaragePos", true)
addEvent("luxury:garageHint", true)

addEventHandler("luxury:setGaragePos", root, function(x, y, z)
    garage.x, garage.y, garage.z = x, y, z
    losCache.t = 0
end)

addEventHandler("luxury:garageHint", root, function()
    hintUntil = getTickCount() + 6000
end)

-- After a teleport MTA can leave the camera stuck above / inside the player.
-- Re-targeting on the client is the only reliable way to snap it back.
addEvent("luxury:cameraReset", true)
addEventHandler("luxury:cameraReset", root, function()
    if not isElement(localPlayer) then return end
    setCameraTarget(localPlayer)
    setTimer(function()
        if isElement(localPlayer) then setCameraTarget(localPlayer) end
    end, 300, 1)
end)

-- Project a world position to the screen. A tolerance of 0 means "do not draw
-- when the point is off screen / behind the camera", which is what caused the
-- sign to stick to a screen corner and overlap the chat box before.
local function project(wx, wy, wz)
    local cx, cy = getScreenFromWorldPosition(wx, wy, wz, 0, false)
    if not cx or not cy then return nil end
    if cx ~= cx or cy ~= cy then return nil end          -- NaN guard
    if cx < 0 or cy < 0 or cx > screenW or cy > screenH then return nil end
    return cx, cy
end

-- Cheap glowing ring on the ground (12 short 3D lines, no texture needed).
local RING_SEG = 24
local function drawGroundRing(gx, gy, gz, radius, r, g, b, a, width, dashed)
    local step = (math.pi * 2) / RING_SEG
    for i = 0, RING_SEG - 1 do
        if not dashed or (i % 2 == 0) then
            local a1 = i * step
            local a2 = a1 + step * 0.92
            dxDrawLine3D(
                gx + math.cos(a1) * radius, gy + math.sin(a1) * radius, gz + 0.06,
                gx + math.cos(a2) * radius, gy + math.sin(a2) * radius, gz + 0.06,
                tocolor(r, g, b, a), width)
        end
    end
end

local function drawWorkshopSign()
    if not isElement(localPlayer) then return end

    local gx, gy, gz = garage.x, garage.y, garage.z
    local lx, ly, lz = getElementPosition(localPlayer)
    local dist = getDistanceBetweenPoints3D(gx, gy, gz, lx, ly, lz)
    if dist > VIEW_DISTANCE then return end

    local tick = getTickCount()
    local pulse = 0.6 + 0.4 * math.sin(tick / 450)

    -- luxury gold floor rings
    drawGroundRing(gx, gy, gz, 4.3, 255, 200, 60, math.floor(40 + 55 * pulse), 2.0, false)
    drawGroundRing(gx, gy, gz, 3.1, 255, 228, 130, math.floor(30 + 40 * pulse), 1.5, true)

    local alphaMul = 1
    if dist > 32 then alphaMul = math.max(0, (VIEW_DISTANCE - dist) / 13) end
    local fade = math.floor(255 * alphaMul)

    -- hide the beacon when a building is between camera and workshop
    -- (cached: one ray cast every 250 ms instead of every frame)
    if dist > 20 then
        if tick - losCache.t > 250 then
            local ccx, ccy, ccz = getCameraMatrix()
            if ccx then
                losCache.ok = isLineOfSightClear(ccx, ccy, ccz, gx, gy, gz + SIGN_HEIGHT,
                    true, false, false, true, false, false, false, false) and true or false
            else
                losCache.ok = true
            end
            losCache.t = tick
        end
        if not losCache.ok then return end
    end

    -- vertical light beam
    for i = 0, 5 do
        local bx, by = project(gx, gy, gz + 0.8 + i * (SIGN_HEIGHT / 6))
        if bx then
            local a = math.max(0, math.floor((130 - i * 20) * alphaMul * pulse))
            dxDrawRectangle(bx - 3, by - 5, 6, 10, tocolor(255, 200, 60, a))
        end
    end

    -- the panel: only from 8 m away so it never covers the player or the HUD
    if dist >= 8 and not menu.open then
        local px1, py1 = project(gx, gy, gz + SIGN_HEIGHT)
        if px1 then
            local signScale = math.max(0.4, math.min(1.0, 18 / dist))
            local w, h = 330 * sx * signScale, 54 * sy * signScale
            local x1, y1 = px1 - w / 2, py1 - h

            x1 = math.max(8, math.min(x1, screenW - w - 8))
            y1 = math.max(8, math.min(y1, screenH - h - 8))

            -- never draw on top of the chat box (top-left corner)
            if not (x1 < screenW * 0.45 and y1 < screenH * 0.28) then
                dxDrawRectangle(x1, y1, w, h, tocolor(10, 10, 14, math.floor(200 * alphaMul)))
                dxDrawRectangle(x1, y1, w, math.max(2, 3 * sy), tocolor(255, 200, 60, fade))
                dxDrawRectangle(x1, y1 + h - math.max(1, sy), w, math.max(1, sy),
                    tocolor(255, 200, 60, math.floor(fade * 0.45)))
                dxDrawText("LUXURY TUNING GARAGE", x1, y1 + h * 0.06, x1 + w, y1 + h * 0.58,
                    tocolor(255, 208, 55, fade), 1.0 * signScale, "default-bold", "center", "center",
                    false, false, false, false)
                dxDrawText("ورشة الميكانيكي - " .. math.floor(dist) .. "m", x1, y1 + h * 0.55, x1 + w, y1 + h * 0.95,
                    tocolor(228, 228, 238, fade), 0.78 * signScale, "default-bold", "center", "center",
                    false, false, false, false)
            end
        end
    end

    -- in-vehicle prompt inside the workshop zone
    if dist < 14 and getPedOccupiedVehicle(localPlayer) then
        local sw, sh = 520 * sx, 38 * sy
        dxDrawRectangle(screenW / 2 - sw / 2, screenH * 0.82, sw, sh, tocolor(12, 12, 16, 215))
        dxDrawRectangle(screenW / 2 - sw / 2, screenH * 0.82 + sh - 2, sw, 2, tocolor(255, 200, 60, 255))
        dxDrawText("اضغط [E] لفتح قائمة تعديل السيارة", screenW / 2 - sw / 2, screenH * 0.82,
            screenW / 2 + sw / 2, screenH * 0.82 + sh,
            tocolor(255, 255, 255, 255), 0.9, "default-bold", "center", "center")
    end
end

addEventHandler("onClientRender", root, drawWorkshopSign)

-- ===================== WORLD-SPACE BILLBOARD =====================
-- The screen-space panel above is a HUD element: it disappears when the
-- workshop is far or the camera turns away, so players could not actually
-- "see" a workshop standing in the street. This draws a real sign in the
-- world (textured quad + support posts + 4 corner light posts), visible up
-- to 160 m and always facing the camera.
local BILLBOARD_DIST = 160
local SIGN_WIDTH = 7.0
local SIGN_BOARD_H = 1.75
local signLos = { t = 0, ok = true }

local function drawWorldBillboard()
    if not signTexture or not isElement(localPlayer) then return end

    local gx, gy, gz = garage.x, garage.y, garage.z
    local lx, ly, lz = getElementPosition(localPlayer)
    local dist = getDistanceBetweenPoints3D(gx, gy, gz, lx, ly, lz)
    if dist > BILLBOARD_DIST then return end

    local tick = getTickCount()
    local ccx, ccy, ccz = getCameraMatrix()
    if not ccx then return end

    if dist > 25 then
        if tick - signLos.t > 400 then
            signLos.ok = isLineOfSightClear(ccx, ccy, ccz, gx, gy, gz + 6.0,
                true, false, false, true, false, false, false, false) and true or false
            signLos.t = tick
        end
        if not signLos.ok then return end
    end

    local fadeA = 255
    if dist > 120 then fadeA = math.floor(255 * math.max(0, (BILLBOARD_DIST - dist) / 40)) end

    local topZ = gz + 6.4
    local half = SIGN_WIDTH / 2

    -- support posts
    dxDrawLine3D(gx - half * 0.8, gy, gz, gx - half * 0.8, gy, topZ, tocolor(190, 195, 205, fadeA), 3)
    dxDrawLine3D(gx + half * 0.8, gy, gz, gx + half * 0.8, gy, topZ, tocolor(190, 195, 205, fadeA), 3)

    -- the billboard itself (billboarded toward the camera)
    dxDrawMaterialLine3D(gx - half, gy, topZ + SIGN_BOARD_H / 2,
        gx + half, gy, topZ + SIGN_BOARD_H / 2,
        signTexture, SIGN_BOARD_H, tocolor(255, 255, 255, fadeA), ccx, ccy, ccz)

    -- four golden corner posts so the spot reads as a built workshop, not a paint blob
    local padR = 4.3
    for i = 0, 3 do
        local a = math.pi / 4 + i * (math.pi / 2)
        local pxp, pyp = gx + math.cos(a) * padR, gy + math.sin(a) * padR
        dxDrawLine3D(pxp, pyp, gz, pxp, pyp, gz + 3.0, tocolor(255, 200, 60, math.floor(fadeA * 0.75)), 3)
    end
end

addEventHandler("onClientRender", root, drawWorldBillboard)

bindKey("e", "down", function()
    if menu.open then return end
    if not getPedOccupiedVehicle(localPlayer) then return end
    local dist = getDistanceBetweenPoints3D(garage.x, garage.y, garage.z, getElementPosition(localPlayer))
    if dist < 12 then
        triggerServerEvent("luxury:requestMenu", localPlayer)
    end
end)
