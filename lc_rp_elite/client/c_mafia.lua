--[[
    lc_rp_elite / client/c_mafia.lua
    Bilingual Mafia management panel. Every button sends a server-authoritative
    action; the client never changes money, rank, stock or permissions itself.
]]
local C = LCRE.client
local sw, sh = C.sw, C.sh

local TABS = {
    { id = "overview",  ar = "نظرة عامة", en = "Overview" },
    { id = "members",   ar = "الأعضاء",   en = "Members" },
    { id = "treasury",  ar = "الخزنة",    en = "Treasury" },
    { id = "warehouse", ar = "المستودع",  en = "Warehouse / Trade" },
    { id = "diplomacy", ar = "الدبلوماسية", en = "Diplomacy" },
    { id = "logs",      ar = "السجلات",   en = "Logs" },
    { id = "identity",  ar = "الهوية",    en = "Identity" },
}
C.tab.mafia = C.tab.mafia or "overview"
local selected = nil

addEvent("lcre:mafiaData", true)
addEventHandler("lcre:mafiaData", root, function(data)
    C.data.mafia = data
    if data then
        C.inputs["maf_name_ar"] = C.inputs["maf_name_ar"] or data.name.ar
        C.inputs["maf_name_en"] = C.inputs["maf_name_en"] or data.name.en
        C.inputs["maf_tag"]     = C.inputs["maf_tag"] or data.tag
        C.inputs["maf_color"]   = C.inputs["maf_color"] or
            table.concat(data.color or { 212, 175, 90 }, ",")
    end
end)

local function v(id) return C.inputs[id] or "" end
local function num(id) return tonumber(v(id)) or 0 end
local function refresh() C.send("mafiaInfo", {}) end
local function act(name, data)
    C.send(name, data or {})
    setTimer(refresh, 260, 1)
end

local function field(labelAr, labelEn, x, y, w, id)
    C.text(C.t(labelAr, labelEn), x, y - C.px(2), w, C.px(22),
        C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
    C.input(id, labelAr, labelEn, x, y + C.px(22), w, C.px(34))
end

local function overview(d, x, y, w, h)
    C.rect(x, y, w, C.px(96), C.color(LCRE.theme.panel, 255))
    C.rect(x, y, C.px(4), C.px(96), C.color(d.color or LCRE.theme.gold, 255))
    C.text(d.name.ar or "", x + C.px(20), y + C.px(10), w * 0.55, C.px(30),
        C.color(d.color or LCRE.theme.gold), C.fontTitle, "left", "center")
    C.text(d.name.en or "", x + w * 0.52, y + C.px(12), w * 0.44, C.px(26),
        C.color(LCRE.theme.dim), C.fontSmall, "right", "center")
    C.text(C.t("الرتبة", "Rank") .. ": " .. tostring(d.rankName),
        x + C.px(20), y + C.px(48), w * 0.48, C.px(28), C.color(LCRE.theme.text), C.fontSmall, "left", "center")
    C.text(C.t("الوسم", "Tag") .. ": " .. tostring(d.tag) .. "    " ..
        C.t("الرصيد", "Balance") .. ": $" .. tostring(d.balance or 0),
        x + w * 0.46, y + C.px(48), w * 0.50, C.px(28), C.color(LCRE.theme.text), C.fontSmall, "right", "center")

    local by = y + C.px(116)
    local bw = (w - C.px(18)) / 2
    C.button("mm_accept", "قبول الدعوة", "Accept invitation", x, by, bw, C.px(48),
        function() act("mafiaAccept", {}) end, false, LCRE.theme.good)
    C.button("mm_decline", "رفض الدعوة", "Decline invitation", x + bw + C.px(18), by, bw, C.px(48),
        function() act("mafiaDecline", {}) end, false, LCRE.theme.bad)
    C.button("mm_treasury_tab", "فتح الخزنة", "Open treasury", x, by + C.px(60), bw, C.px(48),
        function() C.tab.mafia = "treasury" end, false, LCRE.theme.gold)
    C.button("mm_warehouse_tab", "فتح المستودع", "Open warehouse", x + bw + C.px(18), by + C.px(60), bw, C.px(48),
        function() C.tab.mafia = "warehouse" end, false, LCRE.theme.gold)

    local lines = {
        C.t("صلاحياتك", "Your permissions") .. ":",
        C.t("إدارة", "Manage") .. " (" .. C.t("تغيير الهوية", "Identity") .. "): " .. (d.canManage and C.t("نعم", "YES") or C.t("لا", "NO")),
        C.t("دعوة / ترقية / طرد", "Invite / promote / kick") .. ": " .. (d.canInvite and C.t("نعم", "YES") or C.t("لا", "NO")),
        C.t("سحب الأموال", "Withdraw funds") .. ": " .. (d.canWithdraw and C.t("نعم", "YES") or C.t("لا", "NO")),
        C.t("جميع الإجراءات تُسجّل في قاعدة البيانات.", "All actions are recorded in the database."),
    }
    for i, line in ipairs(lines) do
        C.text(line, x + C.px(4), by + C.px(126) + (i - 1) * C.px(30), w - C.px(8), C.px(26),
            C.color(i == 1 and LCRE.theme.gold or LCRE.theme.dim), C.fontSmall, "left", "center")
    end
end

local function members(d, x, y, w, h)
    local listW = w * 0.58
    local rows = {}
    for _, m in ipairs(d.members or {}) do
        table.insert(rows, (m.name or "?") .. "   |   " .. (m.rankName or "?") .. "   |   " .. (m.badge or ""))
    end
    C.list(rows, x, y, listW, h - C.px(54), C.px(32), function(row) return row end,
        function(row, i)
            local m = d.members[i]
            selected = m and m.name or nil
            C.inputs["mm_target"] = selected or ""
        end, d.color or LCRE.theme.gold)

    local ax = x + listW + C.px(14)
    local aw = w - listW - C.px(14)
    field("اسم اللاعب", "Player name", ax, y, aw, "mm_target")
    C.text(C.t("المحدد", "Selected") .. ": " .. (selected or C.t("لا شيء", "None")),
        ax, y + C.px(68), aw, C.px(26), C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
    local by = y + C.px(102)
    C.button("mm_invite", "دعوة", "Invite", ax, by, aw, C.px(44),
        function() act("mafiaInvite", { name = v("mm_target") }) end, false, LCRE.theme.good)
    C.button("mm_promote", "ترقية", "Promote", ax, by + C.px(50), aw / 2 - C.px(4), C.px(44),
        function() act("mafiaRank", { name = v("mm_target"), delta = 1 }) end, false, LCRE.theme.gold)
    C.button("mm_demote", "تخفيض", "Demote", ax + aw / 2 + C.px(4), by + C.px(50), aw / 2 - C.px(4), C.px(44),
        function() act("mafiaRank", { name = v("mm_target"), delta = -1 }) end, false, LCRE.theme.warn)
    C.button("mm_kick", "طرد", "Kick", ax, by + C.px(100), aw, C.px(44),
        function() act("mafiaKick", { name = v("mm_target") }) end, false, LCRE.theme.bad)
end

local function treasury(d, x, y, w, h)
    C.rect(x, y, w, C.px(86), C.color(LCRE.theme.panel, 255))
    C.text(C.t("رصيد الخزنة", "Treasury balance"), x + C.px(18), y + C.px(12), w * 0.5, C.px(26),
        C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
    C.text("$" .. tostring(d.balance or 0), x + C.px(18), y + C.px(36), w * 0.6, C.px(40),
        C.color(LCRE.theme.gold), C.fontTitle, "left", "center")
    field("المبلغ", "Amount", x, y + C.px(104), w * 0.55, "maf_amount")
    local bx = x + w * 0.60
    C.button("maf_deposit", "إيداع", "Deposit", bx, y + C.px(126), w * 0.38, C.px(46),
        function() act("mafiaTreasury", { mode = "deposit", amount = num("maf_amount") }) end, false, LCRE.theme.good)
    C.button("maf_withdraw", "سحب", "Withdraw", bx, y + C.px(180), w * 0.38, C.px(46),
        function() act("mafiaTreasury", { mode = "withdraw", amount = num("maf_amount") }) end, false, LCRE.theme.gold)
    C.text(C.t("الحد: 100 - 100,000 دولار. الخزنة متاحة داخل مقر العائلة فقط.",
               "Limit: $100 - $100,000. Treasury service is available inside the faction HQ only."),
        x, y + C.px(246), w, C.px(28), C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
end

local function catalogRows()
    local rows = {}
    for item, def in pairs(LCRE.weaponItems) do
        table.insert(rows, { item = item, label = item .. "  |  R" .. (def.rank or 1) .. "  |  $" .. (def.price or 0) })
    end
    table.sort(rows, function(a, b) return a.item < b.item end)
    return rows
end

local function warehouse(d, x, y, w, h)
    local cat = catalogRows()
    C.list(cat, x, y, w * 0.48, h - C.px(48), C.px(30), function(row) return row.label end,
        function(row) C.inputs["maf_item"] = row.item end, LCRE.theme.gold)
    local stock = {}
    for _, s in ipairs(d.warehouse or {}) do
        table.insert(stock, s.item .. "  x" .. tostring(s.amount))
    end
    C.list(stock, x + w * 0.51, y, w * 0.49, C.px(130), C.px(30), function(row) return row end,
        nil, LCRE.theme.blue)

    local ax = x + w * 0.51
    local ay = y + C.px(146)
    field("الصنف", "Item", ax, ay, w * 0.49, "maf_item")
    field("الكمية", "Amount", ax, ay + C.px(70), w * 0.49, "maf_amount2")
    local by = ay + C.px(140)
    C.button("maf_store", "إيداع في المستودع", "Store in warehouse", ax, by, w * 0.49, C.px(42),
        function() act("mafiaWarehouse", { mode = "deposit", item = v("maf_item"), amount = num("maf_amount2") }) end, false, LCRE.theme.good)
    C.button("maf_take", "سحب من المستودع", "Take from warehouse", ax, by + C.px(48), w * 0.49, C.px(42),
        function() act("mafiaWarehouse", { mode = "withdraw", item = v("maf_item"), amount = num("maf_amount2") }) end, false, LCRE.theme.gold)
    C.button("maf_trade", "بيع للخزنة", "Sell to treasury", ax, by + C.px(96), w * 0.49, C.px(42),
        function() act("mafiaTrade", { item = v("maf_item"), amount = num("maf_amount2") }) end, false, LCRE.theme.blue)
end

local function diplomacy(d, x, y, w, h)
    local rows = {}
    for _, a in ipairs(d.alliances or {}) do
        rows[#rows + 1] = "#" .. tostring(a.faction) .. "  " .. tostring(a.name) .. "  ->  " .. tostring(a.state)
    end
    C.list(rows, x, y, w, C.px(150), C.px(32), function(row) return row end, nil, LCRE.theme.gold)
    field("رقم الفصيل", "Faction ID", x, y + C.px(170), w * 0.45, "maf_faction")
    local bx = x + w * 0.50
    C.button("maf_ally", "حليف", "Ally", bx, y + C.px(192), w * 0.22, C.px(44),
        function() act("mafiaAlliance", { faction = num("maf_faction"), state = "ally" }) end, false, LCRE.theme.good)
    C.button("maf_enemy", "عدو", "Enemy", bx + w * 0.24, y + C.px(192), w * 0.22, C.px(44),
        function() act("mafiaAlliance", { faction = num("maf_faction"), state = "enemy" }) end, false, LCRE.theme.bad)
    C.button("maf_neutral", "محايد", "Neutral", bx, y + C.px(244), w * 0.46, C.px(44),
        function() act("mafiaAlliance", { faction = num("maf_faction"), state = "neutral" }) end, false, LCRE.theme.dim)
    C.text(C.t("فقط الزعيم يستطيع تغيير التحالفات.", "Only a Boss can change diplomacy."),
        x, y + C.px(310), w, C.px(28), C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
end

local function logs(d, x, y, w, h)
    local rows = {}
    for _, l in ipairs(d.logs or {}) do
        rows[#rows + 1] = tostring(l.time) .. "  |  " .. tostring(l.action) .. "  |  " .. tostring(l.details)
    end
    C.list(rows, x, y, w, h, C.px(32), function(row) return row end, nil, LCRE.theme.gold)
end

local function identity(d, x, y, w, h)
    if not d.canManage then
        C.text(C.t("الزعيم فقط يمكنه تعديل هوية العائلة.", "Only the Boss can edit faction identity."),
            x, y, w, h, C.color(LCRE.theme.bad), C.font, "center", "center")
        return
    end
    local half = (w - C.px(18)) / 2
    field("الاسم بالعربية", "Arabic name", x, y, half, "maf_name_ar")
    field("الاسم بالإنجليزية", "English name", x + half + C.px(18), y, half, "maf_name_en")
    field("الوسم", "Tag", x, y + C.px(78), half, "maf_tag")
    field("اللون R,G,B", "Color R,G,B", x + half + C.px(18), y + C.px(78), half, "maf_color")
    C.button("maf_save_identity", "حفظ الهوية", "Save identity", x, y + C.px(176), w, C.px(48),
        function()
            act("mafiaSettings", {
                name_ar = v("maf_name_ar"), name_en = v("maf_name_en"),
                tag = v("maf_tag"), color = v("maf_color"),
            })
        end, false, LCRE.theme.gold)
end

addEventHandler("onClientRender", root, function()
    if C.panel ~= "mafia" then return end
    local w, h = C.px(960), C.px(640)
    local x, y = (sw - w) / 2, (sh - h) / 2
    local d = C.data.mafia
    C.window(x, y, w, h, d and d.color or LCRE.theme.gold,
        "إدارة العائلة", "MAFIA MANAGEMENT",
        "/elitemafia  |  /eliteaccept  |  server-authoritative")
    C.tabs(TABS, x + C.px(14), y + C.px(68), w - C.px(28), C.tab.mafia,
        function(id) C.tab.mafia = id end, d and d.color or LCRE.theme.gold)
    local cx, cy = x + C.px(18), y + C.px(114)
    local cw, ch = w - C.px(36), h - C.px(136)
    if not d then
        C.text(C.t("جارٍ تحميل بيانات العائلة...", "Loading faction data..."),
            cx, cy, cw, ch, C.color(LCRE.theme.dim), C.font, "center", "center")
        return
    end
    if C.tab.mafia == "overview" then overview(d, cx, cy, cw, ch)
    elseif C.tab.mafia == "members" then members(d, cx, cy, cw, ch)
    elseif C.tab.mafia == "treasury" then treasury(d, cx, cy, cw, ch)
    elseif C.tab.mafia == "warehouse" then warehouse(d, cx, cy, cw, ch)
    elseif C.tab.mafia == "diplomacy" then diplomacy(d, cx, cy, cw, ch)
    elseif C.tab.mafia == "logs" then logs(d, cx, cy, cw, ch)
    elseif C.tab.mafia == "identity" then identity(d, cx, cy, cw, ch)
    end
end)
