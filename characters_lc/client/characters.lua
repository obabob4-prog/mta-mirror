-- ============================================================================
--  characters_lc - Liberty City character select / create / change UI
--  Adapted from CharacterSelect_Export for the gta4gg LC build.
--  RULES ENFORCED HERE:
--    * DX only (no guiCreate* elements)
--    * Liberty City coordinates only (no San Andreas camera / spawn)
--    * uses the EXISTING ng-characters events, so the database, login,
--      inventory, phone, HUD, police and property systems stay untouched.
-- ============================================================================

local SW, SH = guiGetScreenSize()
local S  = math.max(0.80, math.min(SW / 1366, SH / 768))
-- Snap every DX coordinate to whole pixels: fractional scaling is what makes
-- thin gold bars look dashed and leaves hairline gaps between adjacent boxes.
local function px(v) return math.floor((tonumber(v) or 0) + 0.5) end
local W, H = px(640 * S), px(500 * S)
-- 2026-11-19: list panel sits on the LEFT so the 3D saved-character studio
-- occupies the right side of the screen without any overlap.
local X, Y = px(30 * S), px(SH / 2 - H / 2)

-- 2026-11-19: aligned with the unified Luxury GTA V palette used by ng-rp,
-- gta4hud, ng-shops, the phone and the inventory (charcoal + gold).
local GOLD    = tocolor(232, 197, 107, 255)
local GOLD_D  = tocolor(120, 92, 36, 255)
local PANEL   = tocolor(10, 14, 21, 248)
local ROW     = tocolor(27, 36, 49, 255)
local ROWSEL  = tocolor(92, 70, 28, 255)
local WHITE   = tocolor(242, 242, 244, 255)
local MUTED   = tocolor(158, 158, 166, 255)
local GREEN   = tocolor(62, 140, 82, 255)
local RED     = tocolor(158, 64, 64, 255)
local FIELD   = tocolor(26, 26, 32, 255)

-- MUST match ng-characters/s_chars.lua and sCharacterCreator/config.lua
local MALE_SKINS   = { 37, 22, 43, 46, 30, 274 }
local FEMALE_SKINS = { 9, 12, 13, 40, 56, 88, 93, 141, 190, 195 }
local SKIN_NAMES = {
    [37] = "Handsome Male HD", [22] = "Business Male HD", [43] = "Mafia Male HD",
    [46] = "Mafia Random HD", [30] = "Bloods HD", [274] = "Doctor HD",
    [9] = "Executive Black", [12] = "Downtown Casual", [13] = "Modern Street",
    [40] = "Latina Socialite", [56] = "Asian Socialite", [88] = "Executive White",
    [93] = "Asian Business", [141] = "Nightlife Chic", [190] = "LCPD Officer",
    [195] = "Street Fashion",
}

local st = {
    open = false, screen = "list", chars = {}, selected = nil,
    status = "", statusOK = true, loading = 0, manual = false,
    first = "", last = "", ageText = "25", gender = 0, skinIndex = 1,
    focus = nil, delArm = nil, dimSwitched = false, level = 0,
}

-- 2026-11-19 saved-character studio (LC only). Small live ped previews of every
-- saved character, lined up with spacing and different idle poses so they never
-- overlap. Only peds created by THIS resource are stored here.
local STUDIO = { x = -980, y = 1095, z = 20.8 }
local STUDIO_POSES = { "shift", "stretch", "time" }
local studioPeds = {}

local function log(msg)
    triggerServerEvent("ngc:clientLog", localPlayer, msg)
end

local function skins() return st.gender == 1 and FEMALE_SKINS or MALE_SKINS end
local function currentSkin()
    local s = skins()
    return s[math.max(1, math.min(#s, st.skinIndex))]
end

-- ---------------------------------------------------------------------------
-- LC-only world view. The server keeps the player frozen in dimension 9999;
-- locally we render dimension 0 / interior 0 so the Liberty City map (and NOT
-- the default San Andreas world) is visible behind the picker.
-- ---------------------------------------------------------------------------
local LC_VIEW = { x = -980, y = 1095, z = 20.8 }

local function enterWorldView()
    if not st.dimSwitched then
        setElementDimension(localPlayer, 0)
        setElementInterior(localPlayer, 0)
        st.dimSwitched = true
    end
    setCameraMatrix(LC_VIEW.x + 34, LC_VIEW.y - 58, LC_VIEW.z + 62,
                    LC_VIEW.x, LC_VIEW.y, LC_VIEW.z + 4)
end

local function leaveWorldView()
    if st.dimSwitched then
        setElementDimension(localPlayer, 9999)
        setElementInterior(localPlayer, 0)
        st.dimSwitched = false
    end
    setCameraTarget(localPlayer, localPlayer)
end

-- Build the saved-character studio: one live ped per saved character, spaced
-- apart and posed differently. Camera is offset so the studio sits on the RIGHT
-- half of the screen while the panel stays on the LEFT (no overlap).
local function clearStudio()
    for _, ped in ipairs(studioPeds) do
        if isElement(ped) then destroyElement(ped) end
    end
    studioPeds = {}
end

local function layoutStudio()
    clearStudio()
    local list = st.chars or {}
    local n = math.min(#list, 5)
    if n == 0 then return end

    local spacing = 1.9
    local startX = STUDIO.x - (n - 1) * spacing / 2
    for i = 1, n do
        local c = list[i]
        local x = startX + (i - 1) * spacing
        local z = STUDIO.z
        if getGroundPosition then
            local gz = getGroundPosition(x, STUDIO.y, z + 50)
            if gz then z = gz + 1.0 end
        end
        local ped = createPed(tonumber(c.skin) or 1, x, STUDIO.y, z, 180 + (i - (n + 1) / 2) * 6)
        if ped then
            setElementDimension(ped, 0)
            setElementInterior(ped, 0)
            setElementFrozen(ped, true)
            setElementCollisionsEnabled(ped, false)
            setElementPosition(ped, x, STUDIO.y, z)
            setPedAnimation(ped, "playidles", STUDIO_POSES[((i - 1) % #STUDIO_POSES) + 1], -1, false, false)
            table.insert(studioPeds, ped)
        end
    end

    -- camera shifted left of the row so all peds sit to the RIGHT of the panel
    local camOffset = 4.6
    local dist = 9.5 + n * 0.4
    setCameraMatrix(STUDIO.x - camOffset, STUDIO.y - dist, STUDIO.z + 2.6,
                    STUDIO.x - camOffset, STUDIO.y, STUDIO.z + 0.95)
end

local function setStatus(text, ok)
    st.status = tostring(text or "")
    st.statusOK = ok ~= false
end

local function closeAll()
    st.open = false
    st.focus = nil
    st.delArm = nil
    clearStudio()
    if isElement(localPlayer) then setElementData(localPlayer, "ngc.uiOpen", false) end
    leaveWorldView()
    showCursor(false)
    showChat(true)
end

-- ---------------------------------------------------------------------------
-- layout
-- ---------------------------------------------------------------------------
-- Rows: 78-136, 142-200, 206-264, 270-328, 334-392.
-- New button: 398-442. Bottom bar: 450-492 (no overlap with "new").
local function rowRect(i)
    local rh = px(58 * S)
    return px(X + 24 * S), px(Y + 78 * S + (i - 1) * (rh + px(6 * S))), px(W - 48 * S), rh
end
local function newRect()
    local rh = px(58 * S)
    return px(X + 24 * S), px(Y + 78 * S + 5 * (rh + px(6 * S))), px(W - 48 * S), px(44 * S)
end
local function botRect(id)
    local by = px(Y + 450 * S)
    if id == "spawn" then return px(X + 24 * S), by, px(250 * S), px(42 * S) end
    if id == "studio" then return px(X + 286 * S), by, px(190 * S), px(42 * S) end
    return px(X + 488 * S), by, px(W - 512 * S), px(42 * S)
end
local function delRect(i)
    local rx, ry, rw, rh = rowRect(i)
    return px(rx + rw - 42 * S), px(ry + 8 * S), px(32 * S), px(32 * S)
end
local function fieldRect(id)
    local fx, fw = px(X + 210 * S), px(W - 250 * S)
    if id == "first" then return fx, px(Y + 118 * S), fw, px(36 * S) end
    if id == "last"  then return fx, px(Y + 176 * S), fw, px(36 * S) end
    return fx, px(Y + 234 * S), fw, px(36 * S)
end
local function genderRect() return px(X + 210 * S), px(Y + 292 * S), px(W - 250 * S), px(36 * S) end
local function skinPrevRect() return px(X + 210 * S), px(Y + 340 * S), px(40 * S), px(36 * S) end
local function skinNextRect() return px(X + W - 250 * S), px(Y + 340 * S), px(40 * S), px(36 * S) end
local function formBtn(id)
    local by = px(Y + 450 * S)
    if id == "back" then return px(X + 24 * S), by, px(170 * S), px(42 * S) end
    return px(X + W - 304 * S), by, px(280 * S), px(42 * S)
end

local function inBox(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function txt(s, x, y, w, h, color, scale, font, align, vert)
    local sc = (scale or 1.0) * S
    x, y, w, h = px(x), px(y), px(w), px(h)
    -- dxDrawText: text,l,t,r,b,color,scaleX,scaleY,font,alignX,alignY,...
    dxDrawText(tostring(s), x, y, x + w, y + h, color, sc, sc,
               font or "default", align or "left", vert or "center",
               false, false, false, false)
end

local function cursorXY()
    local cx, cy = getCursorPosition()
    if not cx then return -1, -1 end
    return cx * SW, cy * SH
end

-- Luxury game-style button: drop shadow, gold frame, top gloss, hover glow and
-- pressed state. Layout rectangles never change, only the drawing does.
local function fancyBtn(x, y, w, h, label, base, selected, scale, font)
    x, y, w, h = px(x), px(y), px(w), px(h)
    local mx, my = cursorXY()
    local hover = st.open and inBox(mx, my, x, y, w, h)
    local down = hover and getKeyState("mouse1")
    local b = math.max(1, px(S))
    local g = math.max(1, px(2 * S))
    dxDrawRectangle(px(x + 3 * S), px(y + 4 * S), w, h, tocolor(0, 0, 0, 170))
    dxDrawRectangle(x - b, y - b, w + 2 * b, h + 2 * b,
        hover and tocolor(255, 220, 150, 255) or GOLD)
    dxDrawRectangle(x, y, w, h, down and tocolor(120, 92, 36, 255) or
        (selected and (base or tocolor(46, 42, 28, 255)) or base or tocolor(34, 36, 43, 255)))
    -- Whole-pixel bars: solid lines, no dashed seams.
    dxDrawRectangle(px(x + 2 * S), px(y + 2 * S), px(w - 4 * S), g,
        tocolor(255, 235, 185, hover and 190 or 95))
    dxDrawRectangle(px(x + 2 * S), px(y + h - 4 * S), px(w - 4 * S), g, tocolor(0, 0, 0, 130))
    dxDrawText(tostring(label), x, y, x + w, y + h,
        hover and tocolor(255, 245, 220, 255) or WHITE,
        (scale or 1.0) * S, (scale or 1.0) * S,
        font or "default-bold", "center", "center", false, false, false, false)
end

-- ---------------------------------------------------------------------------
-- draw
-- ---------------------------------------------------------------------------
addEventHandler("onClientRender", root, function()
    if not st.open then return end

    -- 2026-11-19: studio-first list — keep panel subtle so saved peds on the
    -- right remain visible; selection works by list rows or by clicking peds.
    local panelA = (st.screen == "list" and #st.chars > 0) and 170 or 248
    dxDrawRectangle(px(X - 5 * S), px(Y - 5 * S), px(W + 10 * S), px(H + 10 * S), tocolor(0, 0, 0, 120))
    dxDrawRectangle(px(X), px(Y), px(W), px(H), tocolor(10, 14, 21, panelA))
    dxDrawRectangle(px(X), px(Y), px(W), math.max(1, px(3 * S)), GOLD)
    dxDrawRectangle(px(X), px(Y + H - 3 * S), px(W), math.max(1, px(3 * S)), GOLD_D)

    txt("LIBERTY CITY  |  الشخصيات", X, Y + 10 * S, W, 44 * S, GOLD, 1.35, "default-bold", "center")
    if st.screen == "list" and #st.chars > 0 then
        txt("اضغط على الشخصية في الاستوديو أو من القائمة للاختيار",
            X + 24 * S, Y + 50 * S, W - 48 * S, 22 * S, MUTED, 0.88, "default", "center")
    end

    if st.screen == "list" then
        if #st.chars == 0 then
            txt("لا توجد شخصيات. سيتم فتح شاشة التخصيص الموحّدة لإنشاء شخصيتك.",
                X + 30 * S, Y + 130 * S, W - 60 * S, 60 * S, MUTED, 1.05, "default", "center")
        end
        for i, c in ipairs(st.chars) do
            if i <= 5 then
                local rx, ry, rw, rh = rowRect(i)
                local sel = (st.selected == c.id)
                dxDrawRectangle(rx, ry, rw, rh, sel and ROWSEL or ROW)
                dxDrawRectangle(rx, ry, math.max(1, px(4 * S)), rh, sel and GOLD or GOLD_D)
                txt(c.name or "?", rx + 16 * S, ry + 6 * S, rw - 70 * S, 28 * S,
                    WHITE, 1.12, "default-bold", "right")
                txt(c.info or "", rx + 16 * S, ry + 30 * S, rw - 70 * S, 24 * S,
                    MUTED, 0.92, "default", "right")
                local dx, dy, dw, dh = delRect(i)
                local armed = (st.delArm == c.id)
                fancyBtn(dx, dy, dw, dh, "x", armed and RED or tocolor(60, 60, 68, 255), false, 1.0)
            end
        end
        local nx, ny, nw, nh = newRect()
        local more = #st.chars >= 5 and "  (الحد الأقصى 5)" or ""
        fancyBtn(nx, ny, nw, nh, "+ إنشاء شخصية جديدة" .. more,
            tocolor(46, 42, 28, 255), false, 1.02)

        local sx, sy, sw, sh = botRect("spawn")
        fancyBtn(sx, sy, sw, sh, "الدخول بالشخصية المحددة",
            st.selected and GREEN or tocolor(50, 50, 58, 255), not st.selected and true or false, 0.98)

        local ux, uy, uw, uh = botRect("studio")
        fancyBtn(ux, uy, uw, uh, "تخصيص الشخصية", tocolor(46, 42, 28, 255), false, 0.92)

        local lx, ly, lw, lh = botRect("logout")
        fancyBtn(lx, ly, lw, lh, "خروج", tocolor(60, 44, 44, 255), false, 0.95)

        -- floating name plates above the live studio previews (right side)
        for i, ped in ipairs(studioPeds) do
            if isElement(ped) and st.chars[i] then
                local wx, wy, wz = getElementPosition(ped)
                local sx2, sy2 = getScreenFromWorldPosition(wx, wy, wz + 2.15)
                if sx2 then
                    local selected = (st.selected == st.chars[i].id)
                    local label = st.chars[i].name or "?"
                    local lw2, lh2 = px(150 * S), px(30 * S)
                    local lx2, ly2 = px(sx2 - lw2 / 2), px(sy2 - lh2 / 2)
                    dxDrawRectangle(lx2, ly2, lw2, lh2,
                        selected and tocolor(92, 70, 28, 230) or tocolor(12, 12, 16, 205))
                    dxDrawText(label, lx2, ly2, lx2 + lw2, ly2 + lh2,
                        selected and GOLD or WHITE, 0.95 * S, 0.95 * S,
                        "default-bold", "center", "center", false, false, false, false)
                    if selected then
                        dxDrawRectangle(px(sx2 - 3 * S), px(ly2 + lh2 + 3 * S), px(6 * S), px(6 * S), GOLD)
                    end
                end
            end
        end
    else
        local function field(id, label, value, placeholder)
            local fx, fy, fw, fh = fieldRect(id)
            txt(label, X + 24 * S, fy, 180 * S, fh, MUTED, 1.0, "default-bold", "right")
            dxDrawRectangle(fx, fy, fw, fh, FIELD)
            dxDrawRectangle(fx, px(fy + fh - 2 * S), fw, math.max(1, px(2 * S)), st.focus == id and GOLD or GOLD_D)
            txt(value ~= "" and value or placeholder, fx + 10 * S, fy, fw - 20 * S, fh,
                value ~= "" and WHITE or tocolor(110, 110, 118, 255), 1.0, "default", "right")
        end
        field("first", "الاسم الأول:", st.first, "Ahmed")
        field("last", "اسم العائلة:", st.last, "Saleh")
        field("age", "العمر (18-80):", st.ageText, "25")

        local gx, gy, gw, gh = genderRect()
        txt("الجنس:", X + 24 * S, gy, 180 * S, gh, MUTED, 1.0, "default-bold", "right")
        dxDrawRectangle(gx, gy, gw, gh, FIELD)
        txt(st.gender == 1 and "أنثى  (اضغط للتبديل)" or "ذكر  (اضغط للتبديل)",
            gx, gy, gw, gh, WHITE, 1.0, "default-bold", "center")

        local px, py, pw, ph = skinPrevRect()
        local nx2, ny2, nw2, nh2 = skinNextRect()
        txt("الشكل:", X + 24 * S, py, 180 * S, ph, MUTED, 1.0, "default-bold", "right")
        fancyBtn(px, py, pw, ph, "<", FIELD, false, 1.1)
        txt((SKIN_NAMES[currentSkin()] or ("Skin " .. currentSkin())) .. "  [" .. currentSkin() .. "]",
            px + pw + 6 * S, py, nx2 - px - pw - 12 * S, ph, WHITE, 0.95, "default-bold", "center")
        fancyBtn(nx2, ny2, nw2, nh2, ">", FIELD, false, 1.1)

        local bx, by, bw, bh = formBtn("back")
        fancyBtn(bx, by, bw, bh, "رجوع", tocolor(60, 60, 68, 255), false, 1.0)
        local cx, cy, cw, ch = formBtn("create")
        fancyBtn(cx, cy, cw, ch, "إنشاء الشخصية", GREEN, false, 1.02)
    end

    -- Loading + status live BELOW the panel: they used to sit on top of the
    -- "new character" button and its label (real overlap).
    if st.loading > 0 then
        local bw = px(W - 48 * S)
        local by = px(Y + H + 8 * S)
        local bh = math.max(1, px(10 * S))
        dxDrawRectangle(px(X + 24 * S), by, bw, bh, tocolor(40, 40, 46, 255))
        dxDrawRectangle(px(X + 24 * S), by, px(bw * math.max(0, math.min(1, st.loading))), bh, GOLD)
        txt("جارٍ تجهيز مدينة Liberty City...", X + 24 * S, Y + H + 22 * S, bw, 22 * S,
            GOLD, 0.95, "default", "center")
    end

    if st.status ~= "" then
        txt(st.status, X + 24 * S, Y + H + 50 * S, W - 48 * S, 26 * S,
            st.statusOK and tocolor(120, 220, 140, 255) or tocolor(240, 110, 110, 255),
            1.0, "default-bold", "center")
    end
end)

-- ---------------------------------------------------------------------------
-- input
-- ---------------------------------------------------------------------------
addEventHandler("onClientClick", root, function(button, state, mx, my, wx, wy, wz, clickedElement)
    if not st.open or button ~= "left" or state ~= "down" then return end

    if st.screen == "list" then
        -- 2026-11-19: studio-first selection — click a saved character ped directly.
        if isElement(clickedElement) and getElementType(clickedElement) == "ped" then
            for i, ped in ipairs(studioPeds) do
                if ped == clickedElement and st.chars[i] then
                    st.selected = st.chars[i].id
                    st.delArm = nil
                    setStatus("تم اختيار: " .. tostring(st.chars[i].name or "?"), true)
                    return
                end
            end
        end

        for i, c in ipairs(st.chars) do
            if i <= 5 and inBox(mx, my, delRect(i)) then
                if st.delArm == c.id then
                    st.delArm = nil
                    triggerServerEvent("ngc:deleteChar", localPlayer, c.id)
                    setStatus("تم حذف الشخصية.", true)
                else
                    st.delArm = c.id
                    setStatus("اضغط x مرة أخرى لتأكيد الحذف.", false)
                end
                return
            end
            if i <= 5 and inBox(mx, my, rowRect(i)) then
                st.selected = c.id
                st.delArm = nil
                return
            end
        end
        if inBox(mx, my, newRect()) then
            st.screen = "create"
            st.first, st.last, st.ageText = "", "", "25"
            st.gender, st.skinIndex = 0, 1
            st.focus = nil
            setStatus("", true)
            return
        end
        if st.selected and inBox(mx, my, botRect("spawn")) then
            st.loading = 0.05
            setStatus("جارٍ الدخول إلى المدينة...", true)
            triggerServerEvent("ngc:selectChar", localPlayer, st.selected)
            return
        end
        if inBox(mx, my, botRect("studio")) then
            st.screen = "create"
            st.first, st.last, st.ageText = "", "", "25"
            st.gender, st.skinIndex = 0, 1
            st.focus = nil
            setStatus("", true)
            return
        end
        if inBox(mx, my, botRect("logout")) then
            closeAll()
            triggerServerEvent("ngc:logout", localPlayer)
            return
        end
    else
        for _, id in ipairs({ "first", "last", "age" }) do
            if inBox(mx, my, fieldRect(id)) then st.focus = id; return end
        end
        if inBox(mx, my, genderRect()) then
            st.gender = st.gender == 1 and 0 or 1
            st.skinIndex = 1
            return
        end
        if inBox(mx, my, skinPrevRect()) then
            local s = skins()
            st.skinIndex = ((st.skinIndex - 2) % #s) + 1
            return
        end
        if inBox(mx, my, skinNextRect()) then
            local s = skins()
            st.skinIndex = (st.skinIndex % #s) + 1
            return
        end
        if inBox(mx, my, formBtn("back")) then
            st.screen, st.focus = "list", nil
            return
        end
        if inBox(mx, my, formBtn("create")) then
            local first = st.first:sub(1, 1):upper() .. st.first:sub(2):lower()
            local last  = st.last:sub(1, 1):upper() .. st.last:sub(2):lower()
            local age = tonumber(st.ageText) or 25
            if #first < 2 or #last < 2 then
                setStatus("أدخل الاسم الأول واسم العائلة (حرفان إنجليزيان على الأقل).", false)
                return
            end
            if age < 18 or age > 80 then
                setStatus("العمر يجب أن يكون بين 18 و 80.", false)
                return
            end
            st.loading = 0.05
            setStatus("جارٍ إنشاء الشخصية...", true)
            triggerServerEvent("ngc:createChar", localPlayer, first, last,
                               st.gender, currentSkin(), age, 25, 25)
            return
        end
        st.focus = nil
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if not st.open or not st.focus or not press then return end
    if key == "backspace" then
        if st.focus == "first" then st.first = st.first:sub(1, -2)
        elseif st.focus == "last" then st.last = st.last:sub(1, -2)
        else st.ageText = st.ageText:sub(1, -2) end
        cancelEvent()
        return
    elseif key == "enter" or key == "num_enter" then
        st.focus = nil
        cancelEvent()
        return
    elseif key == "tab" then
        st.focus = st.focus == "first" and "last" or (st.focus == "last" and "age" or "first")
        cancelEvent()
        return
    end
    if type(key) == "string" and #key == 1 and key:match("[%a%d%s%-_]") then
        if st.focus == "age" then
            if key:match("%d") then st.ageText = st.ageText .. key end
        else
            local cur = st.focus == "first" and st.first or st.last
            if #cur < 16 then
                if st.focus == "first" then st.first = cur .. key else st.last = cur .. key end
            end
        end
        cancelEvent()
    end
end)

addEventHandler("onClientRender", root, function()
    if st.open and st.loading > 0 and st.loading < 1 then
        st.loading = math.min(1, st.loading + 0.008)
    end
end)

-- ---------------------------------------------------------------------------
-- server -> client events (the SAME events ng-characters already fires)
-- ---------------------------------------------------------------------------
addEvent("ngc:showCharList", true)
addEventHandler("ngc:showCharList", root, function(list, level, manual)
    st.chars = list or {}
    st.level = level or 0
    st.manual = manual == true
    st.selected = nil
    st.delArm = nil
    st.loading = 0
    setStatus("", true)
    st.open = true
    if isElement(localPlayer) then setElementData(localPlayer, "ngc.uiOpen", true) end
    showCursor(true)
    showChat(false)
    fadeCamera(true, 1.0)
    enterWorldView()
    layoutStudio()

    if #st.chars == 0 and not st.manual then
        st.screen = "create"
        st.first, st.last, st.ageText = "", "", "25"
        st.gender, st.skinIndex = 0, 1
        st.focus = nil
        setStatus("", true)
        log("charList: 0 chars - CREATE screen opened")
    else
        st.screen = "list"
        log("charList: " .. #st.chars .. " chars - LIST screen opened")
    end
end)


addEvent("ngc:cityPreparing", true)
addEventHandler("ngc:cityPreparing", root, function()
    st.open = true
    st.loading = 0.05
    log("cityPreparing: waiting for the city sync")
end)

addEvent("ngc:charSpawned", true)
addEventHandler("ngc:charSpawned", root, function()
    closeAll()
    st.loading = 0
    -- CRITICAL LC FIX: leaveWorldView() sets dimension 9999 again; the server
    -- already spawned the character in dimension 0. Without this correction
    -- the default San Andreas world renders through the Liberty City map.
    if isElement(localPlayer) then
        setElementDimension(localPlayer, 0)
        setElementInterior(localPlayer, 0)
        setElementAlpha(localPlayer, 255)
    end
    setCameraTarget(localPlayer, localPlayer)
    fadeCamera(true, 1.0)
end)

addEvent("ngc:status", true)
addEventHandler("ngc:status", root, function(text, ok)
    setStatus(text, ok)
    if not ok then st.loading = 0 end
end)

addEvent("ngl:reopen", true)
addEventHandler("ngl:reopen", root, function()
    closeAll()
    st.loading = 0
end)

addEventHandler("onClientResourceStart", root, function(res)
    if res ~= getThisResource() then return end
    setTimer(function()
        if getElementData(localPlayer, "account.id")
           and not getElementData(localPlayer, "char.spawned") then
            triggerServerEvent("ngc:uiRequest", localPlayer)
        end
    end, 1500, 1)
end)

-- ---------------------------------------------------------------------------
-- F10: in-game character switch (save current character and reopen picker)
-- ---------------------------------------------------------------------------
local function canSwitchCharacter()
    if not isElement(localPlayer) then return false end
    if st.open then return false end
    if getElementData(localPlayer, "lcapp.uiOpen") then return false end
    if not getElementData(localPlayer, "account.id") then return false end
    if not getElementData(localPlayer, "char.id") then return false end
    if not getElementData(localPlayer, "char.spawned") then return false end
    if isChatBoxInputActive() or isConsoleActive() or guiGetInputEnabled() then return false end
    return true
end

bindKey("F10", "down", function()
    if not canSwitchCharacter() then return end
    triggerServerEvent("ngc:changeChar", localPlayer)
end)

-- 2026-11-19: make sure studio preview peds never leak on /restart or stop.
addEventHandler("onClientResourceStop", root, function(res)
    if res == getThisResource() then clearStudio() end
end)
