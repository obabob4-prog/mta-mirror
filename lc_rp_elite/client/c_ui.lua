--[[
    lc_rp_elite / client/c_ui.lua
    Main GTA V style launcher. Separate Mafia, LSPD and Garage panels are
    implemented in their own client files and opened from here.
]]
local C = LCRE.client
local sw, sh = C.sw, C.sh

local function drawMenu()
    local w, h = C.px(760), C.px(520)
    local x, y = (sw - w) / 2, (sh - h) / 2
    C.window(x, y, w, h, LCRE.theme.gold,
        "نظام الرولبلاي النخبة", "LC ELITE ROLEPLAY", "Liberty City - original exterior map / عالم ليبرتي سيتي الأصلي")

    local headerAr = " MAFIA & LSPD "
    local headerEn = "GTA V STYLE SYSTEM SUITE"
    C.rect(x + C.px(26), y + C.px(78), w - C.px(52), C.px(74), C.color(LCRE.theme.panel, 255))
    C.rect(x + C.px(26), y + C.px(78), C.px(4), C.px(74), C.color(LCRE.theme.gold, 255))
    C.text(headerAr, x + C.px(44), y + C.px(88), w * 0.52, C.px(28),
        C.color(LCRE.theme.gold), C.fontTitle, "left", "center")
    C.text(headerEn, x + C.px(44), y + C.px(120), w - C.px(90), C.px(22),
        C.color(LCRE.theme.dim), C.fontSmall, "left", "center")

    local bx = x + C.px(28)
    local by = y + C.px(176)
    local bw = (w - C.px(80)) / 2
    local bh = C.px(78)
    local gapX, gapY = C.px(24), C.px(18)

    C.button("open_mafia", "إدارة المافيا", "MAFIA MANAGEMENT", bx, by, bw, bh, function()
        C.open("mafia")
        C.send("mafiaInfo", {})
    end, false, LCRE.theme.gold)

    C.button("open_police", "مركز الشرطة", "LSPD COMMAND", bx + bw + gapX, by, bw, bh, function()
        C.open("police")
        C.send("policeMDT", {})
    end, false, LCRE.theme.blue)

    C.button("open_garage", "المرآب والأسطول", "GARAGE / FLEET", bx, by + bh + gapY, bw, bh, function()
        C.open("vehicles")
        C.send("vehicleList", { kind = "faction", faction = 0 })
    end, false, LCRE.theme.gold)

    C.button("lang", C.t("الإنجليزية", "العربية"), C.t("Switch to English", "التبديل إلى العربية"),
        bx + bw + gapX, by + bh + gapY, bw, bh, function()
            C.lang = C.lang == "ar" and "en" or "ar"
        end, false, LCRE.theme.gold)

    C.rect(x + C.px(28), y + C.px(386), w - C.px(56), C.px(88), C.color({ 10, 10, 14 }, 230))
    C.text("E", x + C.px(42), y + C.px(398), C.px(36), C.px(34), C.color(LCRE.theme.gold), C.fontTitle, "center", "center")
    C.text(C.t("ادخل المقر من الباب الحقيقي، وعد إلى نفس المدخل عند الخروج.",
               "Enter HQ at the real map door; return to the same entrance when leaving."),
        x + C.px(88), y + C.px(398), w - C.px(130), C.px(28), C.color(LCRE.theme.text), C.fontSmall, "left", "center")
    C.text(C.t("كل شيء محمي server-side - لا توجد كائنات خارجية أو تعديل للخريطة.",
               "Everything is server-authoritative - no exterior objects or map edits."),
        x + C.px(88), y + C.px(432), w - C.px(130), C.px(26), C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
end

addEventHandler("onClientRender", root, function()
    if C.panel == "menu" then drawMenu() end
end)
