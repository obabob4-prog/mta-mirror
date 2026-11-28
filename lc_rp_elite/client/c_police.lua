--[[
    lc_rp_elite / client/c_police.lua
    LSPD MDT / command panel. All enforcement, HR and dispatch operations are
    sent to the server and validated there (rank, duty, range, rate limits).
]]
local C = LCRE.client
local sw, sh = C.sw, C.sh

local TABS = {
    { id = "mdt",     ar = "الخدمة و MDT", en = "Duty / MDT" },
    { id = "records", ar = "السجلات",       en = "Records" },
    { id = "enforce", ar = "تنفيذ القانون", en = "Enforcement" },
    { id = "evidence",ar = "الأدلة",        en = "Evidence" },
    { id = "hr",      ar = "الإدارة",       en = "HR" },
    { id = "tools",   ar = "الأوامر",       en = "Tools" },
}
C.tab.police = C.tab.police or "mdt"
local selectedCall = 0

addEvent("lcre:mdtData", true)
addEventHandler("lcre:mdtData", root, function(d)
    C.data.mdt = d
    if d and d.rank then
        C.tab.police = C.tab.police or "mdt"
    end
end)

addEvent("lcre:mdtRecord", true)
addEventHandler("lcre:mdtRecord", root, function(d)
    C.data.record = d
    C.tab.police = "records"
end)

addEvent("lcre:searchResult", true)
addEventHandler("lcre:searchResult", root, function(name, items, weapons)
    C.data.search = { name = name, items = items or {}, weapons = weapons or {} }
end)

addEvent("lcre:evidenceData", true)
addEventHandler("lcre:evidenceData", root, function(list)
    C.data.evidence = list or {}
    C.tab.police = "evidence"
end)

addEvent("lcre:policePanel", true)
addEventHandler("lcre:policePanel", root, function()
    C.open("police")
    C.send("policeMDT", {})
end)

local function v(id) return C.inputs[id] or "" end
local function num(id) return tonumber(v(id)) or 0 end
local function act(name, data)
    C.send(name, data or {})
    setTimer(function() C.send("policeMDT", {}) end, 280, 1)
end

local function field(labelAr, labelEn, x, y, w, id)
    C.text(C.t(labelAr, labelEn), x, y - C.px(2), w, C.px(22),
        C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
    C.input(id, labelAr, labelEn, x, y + C.px(22), w, C.px(34))
end

local function smallButton(id, ar, en, x, y, w, fn, accent)
    C.button(id, ar, en, x, y, w, C.px(40), fn, false, accent or LCRE.theme.blue)
end

local function mdt(d, x, y, w, h)
    local on = C.duty
    C.rect(x, y, w, C.px(72), C.color(LCRE.theme.panel, 255))
    C.rect(x, y, C.px(4), C.px(72), C.color(on and LCRE.theme.good or LCRE.theme.bad, 255))
    C.text(C.t("الرتبة", "Rank") .. ": " .. tostring(d and d.rankName or "?"),
        x + C.px(18), y + C.px(8), w * 0.5, C.px(28), C.color(LCRE.theme.text), C.font, "left", "center")
    C.text(C.t("الشارة", "Badge") .. ": " .. tostring(d and d.badge or "?"),
        x + C.px(18), y + C.px(38), w * 0.5, C.px(24), C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
    C.button("pol_duty", on and "إيقاف الخدمة" or "بدء الخدمة", on and "Go OFF duty" or "Go ON duty",
        x + w * 0.62, y + C.px(16), w * 0.36, C.px(42),
        function() act("policeDuty", { on = not on }) end, on, on and LCRE.theme.good or LCRE.theme.blue)

    local rows = {}
    for _, call in ipairs(d and d.calls or {}) do
        rows[#rows + 1] = { id = call.id, label = "#" .. tostring(call.id) .. " [" ..
            tostring(call.kind) .. "] " .. tostring(call.title) .. " - " .. tostring(call.details) ..
            "  @" .. math.floor(call.x) .. "," .. math.floor(call.y) }
    end
    C.text(C.t("البلاغات النشطة", "Active dispatch calls"), x, y + C.px(84), w, C.px(26),
        C.color(LCRE.theme.gold), C.font, "left", "center")
    C.list(rows, x, y + C.px(114), w, h - C.px(214), C.px(32), function(row) return row.label end,
        function(row) selectedCall = row.id end, LCRE.theme.blue)
    smallButton("pol_accept", "استلام بلاغ", "Accept call", x, y + h - C.px(92), w * 0.46,
        function() if selectedCall > 0 then act("policeCallAction", { id = selectedCall, mode = "accept" }) end end, LCRE.theme.good)
    smallButton("pol_close", "إغلاق بلاغ", "Close call", x + w * 0.50, y + h - C.px(92), w * 0.46,
        function() if selectedCall > 0 then act("policeCallAction", { id = selectedCall, mode = "close" }) end end, LCRE.theme.dim)
    smallButton("pol_refresh", "تحديث", "Refresh", x, y + h - C.px(44), w,
        function() C.send("policeMDT", {}) end, LCRE.theme.gold)
end

local function drawRecord(r, x, y, w, h)
    if not r then
        C.text(C.t("ابحث عن اسم أو رقم شخصية لعرض السجل.",
                   "Enter a name or character ID to look up a record."),
            x, y, w, h, C.color(LCRE.theme.dim), C.font, "center", "center")
        return
    end
    C.text(tostring(r.name) .. "   #" .. tostring(r.id), x, y, w * 0.55, C.px(30),
        C.color(LCRE.theme.gold), C.fontTitle, "left", "center")
    C.text(C.t("مطلوب", "Wanted") .. ": " .. tostring(r.wanted) .. " " .. C.t("نجوم", "stars"),
        x + w * 0.55, y, w * 0.45, C.px(30), C.color(r.wanted > 0 and LCRE.theme.bad or LCRE.theme.good),
        C.fontSmall, "right", "center")
    local lic = r.licenses or {}
    local line2 = C.t("الرخص", "Licenses") .. ": weapon=" .. tostring(lic.weapon or 0) ..
        " vehicle=" .. tostring(lic.vehicle or 0) .. " business=" .. tostring(lic.business or 0)
    if r.jail then
        line2 = line2 .. "   |   " .. C.t("مسجون حتى", "Jailed until") .. " " .. os.date("%H:%M", tonumber(r.jail["until"]) or 0)
    end
    C.text(line2, x, y + C.px(32), w, C.px(26), C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
    local colW = (w - C.px(20)) / 3
    local sy = y + C.px(68)
    local wh = h - C.px(74)
    local warrants, fines, viol = {}, {}, {}
    for _, a in ipairs(r.warrants or {}) do warrants[#warrants + 1] = tostring(a.reason) .. " (" .. tostring(a.time) .. ")" end
    for _, a in ipairs(r.fines or {}) do fines[#fines + 1] = "$" .. tostring(a.amount) .. " " .. tostring(a.reason) .. " [" .. tostring(a.status) .. "]" end
    for _, a in ipairs(r.violations or {}) do viol[#viol + 1] = tostring(a.reason) .. " $" .. tostring(a.fine) .. " " .. tostring(a.time) end
    C.list(warrants, x, sy, colW, wh, C.px(30), function(row) return row end, nil, LCRE.theme.bad)
    C.list(fines, x + colW + C.px(10), sy, colW, wh, C.px(30), function(row) return row end, nil, LCRE.theme.gold)
    C.list(viol, x + (colW + C.px(10)) * 2, sy, colW, wh, C.px(30), function(row) return row end, nil, LCRE.theme.blue)
end

local function records(x, y, w, h)
    field("اسم الشخصية أو الرقم", "Character name or ID", x, y, w * 0.72, "pol_lookup")
    smallButton("pol_lookup_btn", "بحث", "Lookup", x + w * 0.74, y + C.px(22), w * 0.26,
        function()
            local q = v("pol_lookup")
            if tonumber(q) then C.send("policeLookup", { charId = num("pol_lookup") })
            else C.send("policeLookup", { name = q }) end
        end, LCRE.theme.gold)
    drawRecord(C.data.record, x, y + C.px(78), w, h - C.px(78))
end

local function enforcement(x, y, w, h)
    local left = w * 0.48
    field("اسم المطلوب", "Target name", x, y, left, "pol_name")
    field("السبب", "Reason", x, y + C.px(68), left, "pol_reason")
    field("المبلغ", "Amount", x, y + C.px(136), left * 0.48, "pol_amount")
    field("الدقائق", "Minutes", x + left * 0.52, y + C.px(136), left * 0.48, "pol_minutes")
    field("النجوم", "Stars", x, y + C.px(204), left * 0.48, "pol_stars")
    field("سلاح #", "Weapon ID", x + left * 0.52, y + C.px(204), left * 0.48, "pol_weapon")
    local by = y + C.px(270)
    local bw = (left - C.px(10)) / 2
    smallButton("pol_fine", "غرامة", "Fine", x, by, bw,
        function() act("policeFine", { name = v("pol_name"), reason = v("pol_reason"), amount = num("pol_amount") }) end, LCRE.theme.gold)
    smallButton("pol_arrest", "اعتقال", "Arrest", x + bw + C.px(10), by, bw,
        function() act("policeArrest", { name = v("pol_name"), reason = v("pol_reason"), minutes = num("pol_minutes") }) end, LCRE.theme.bad)
    smallButton("pol_warrant", "إصدار مذكرة", "Issue warrant", x, by + C.px(46), bw,
        function() act("policeWarrant", { name = v("pol_name"), reason = v("pol_reason") }) end, LCRE.theme.warn)
    smallButton("pol_wanted", "تعيين مطلوب", "Set wanted", x + bw + C.px(10), by + C.px(46), bw,
        function() act("policeWanted", { name = v("pol_name"), stars = num("pol_stars") }) end, LCRE.theme.warn)
    smallButton("pol_search", "تفتيش", "Search", x, by + C.px(92), bw,
        function() C.send("policeSearch", { name = v("pol_name") }) end, LCRE.theme.blue)
    smallButton("pol_confiscate", "مصادرة سلاح", "Confiscate", x + bw + C.px(10), by + C.px(92), bw,
        function() act("policeConfiscate", { name = v("pol_name"), weapon = num("pol_weapon"), case = v("pol_case") }) end, LCRE.theme.blue)
    smallButton("pol_impound", "حجز مركبة", "Impound", x, by + C.px(138), bw,
        function() act("policeImpound", {}) end, LCRE.theme.dim)
    smallButton("pol_hostage", "احتجاز رهينة", "Take hostage", x + bw + C.px(10), by + C.px(138), bw,
        function() act("policeHostage", { name = v("pol_name") }) end, LCRE.theme.bad)
    smallButton("pol_negotiate", "تفاوض", "Negotiate", x, by + C.px(184), bw,
        function() act("policeNegotiate", { name = v("pol_name") }) end, LCRE.theme.good)
    smallButton("pol_robbery", "سطو (محاكاة)", "Robbery", x + bw + C.px(10), by + C.px(184), bw,
        function() act("policeRobbery", { name = v("pol_name") }) end, LCRE.theme.bad)

    local sx = x + left + C.px(20)
    local sw2 = w - left - C.px(20)
    C.text(C.t("نتائج التفتيش", "Search results"), sx, y, sw2, C.px(26), C.color(LCRE.theme.gold), C.font, "left", "center")
    local s = C.data.search
    local rows = {}
    if s then
        C.text(C.t("المشتبه", "Suspect") .. ": " .. tostring(s.name), sx, y + C.px(28), sw2, C.px(24),
            C.color(LCRE.theme.text), C.fontSmall, "left", "center")
        for _, it in ipairs(s.items) do rows[#rows + 1] = "item: " .. tostring(it.item) .. " x" .. tostring(it.amount) end
        for _, wp in ipairs(s.weapons) do rows[#rows + 1] = "weapon: #" .. tostring(wp.weapon) .. " ammo " .. tostring(wp.ammo) end
    end
    C.list(rows, sx, y + C.px(60), sw2, h - C.px(66), C.px(30), function(row) return row end, nil, LCRE.theme.blue)
end

local function evidence(x, y, w, h)
    field("رقم القضية", "Case ID", x, y, w * 0.30, "pol_case")
    field("الصنف", "Item", x + w * 0.32, y, w * 0.34, "pol_item")
    field("الكمية", "Amount", x + w * 0.68, y, w * 0.14, "pol_evidence_amount")
    field("رقم الشخصية", "Character ID", x + w * 0.84, y, w * 0.16, "pol_charid")
    smallButton("pol_evidence_add", "تسجيل دليل", "Log evidence", x, y + C.px(70), w * 0.48,
        function()
            act("policeEvidence", {
                case = v("pol_case"), item = v("pol_item"),
                amount = num("pol_evidence_amount"), charId = num("pol_charid"),
            })
        end, LCRE.theme.good)
    smallButton("pol_evidence_view", "عرض الأدلة", "View evidence", x + w * 0.52, y + C.px(70), w * 0.48,
        function() C.send("policeEvidenceView", {}) end, LCRE.theme.blue)
    local rows = {}
    for _, e in ipairs(C.data.evidence or {}) do
        rows[#rows + 1] = "#" .. tostring(e.id) .. " [" .. tostring(e.case) .. "] " ..
            tostring(e.item) .. " x" .. tostring(e.amount) .. "  char#" .. tostring(e.char) ..
            "  " .. tostring(e.time)
    end
    C.list(rows, x, y + C.px(124), w, h - C.px(130), C.px(32), function(row) return row end, nil, LCRE.theme.gold)
end

local function hr(x, y, w, h)
    field("اسم اللاعب", "Player name", x, y, w * 0.60, "pol_hr_name")
    field("الرتبة", "Rank 1-8", x + w * 0.62, y, w * 0.38, "pol_rank")
    local bw = (w - C.px(12)) / 4
    smallButton("pol_hire", "تعيين", "Hire", x, y + C.px(70), bw,
        function() act("policeHire", { name = v("pol_hr_name"), rank = num("pol_rank") }) end, LCRE.theme.good)
    smallButton("pol_fire", "فصل", "Fire", x + bw + C.px(4), y + C.px(70), bw,
        function() act("policeFire", { name = v("pol_hr_name") }) end, LCRE.theme.bad)
    smallButton("pol_promote", "ترقية", "Promote", x + (bw + C.px(4)) * 2, y + C.px(70), bw,
        function() act("policeRank", { name = v("pol_hr_name"), delta = 1 }) end, LCRE.theme.gold)
    smallButton("pol_demote", "تخفيض", "Demote", x + (bw + C.px(4)) * 3, y + C.px(70), bw,
        function() act("policeRank", { name = v("pol_hr_name"), delta = -1 }) end, LCRE.theme.warn)
    field("رقم الشخصية للرخصة", "Character ID for license", x, y + C.px(140), w * 0.60, "pol_hr_charid")
    smallButton("pol_lic_weapon", "رخصة سلاح", "Weapon license", x + w * 0.62, y + C.px(162), w * 0.38,
        function() act("policeLicense", { charId = num("pol_hr_charid"), name = v("pol_hr_name"), kind = "weapon" }) end, LCRE.theme.blue)
    smallButton("pol_lic_vehicle", "رخصة قيادة", "Vehicle license", x, y + C.px(216), w * 0.48,
        function() act("policeLicense", { charId = num("pol_hr_charid"), name = v("pol_hr_name"), kind = "vehicle" }) end, LCRE.theme.blue)
    smallButton("pol_lic_business", "رخصة تجارية", "Business license", x + w * 0.52, y + C.px(216), w * 0.48,
        function() act("policeLicense", { charId = num("pol_hr_charid"), name = v("pol_hr_name"), kind = "business" }) end, LCRE.theme.blue)
    C.text(C.t("التعيين والفصل يتطلبان رتبة نقيب أو أعلى (أو أدمن).",
               "Hiring and firing require Captain+ (or admin)."),
        x, y + C.px(286), w, C.px(28), C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
end

local function tools(x, y, w, h)
    field("نص البلاغ", "Dispatch text", x, y, w, "pol_dispatch")
    local bw = (w - C.px(12)) / 2
    smallButton("pol_911", "بلاغ 911", "Send 911 report", x, y + C.px(74), bw,
        function() act("policeDispatch", { kind = "911", text = v("pol_dispatch") }) end, LCRE.theme.bad)
    smallButton("pol_backup", "طلب دعم", "Request backup", x + bw + C.px(12), y + C.px(74), bw,
        function() act("policeDispatch", { kind = "backup", text = v("pol_dispatch") }) end, LCRE.theme.blue)
    smallButton("pol_swat", "طلب SWAT", "Request SWAT", x, y + C.px(124), bw,
        function() act("policeDispatch", { kind = "swat", text = v("pol_dispatch") }) end, LCRE.theme.warn)
    smallButton("pol_roadblock", "نقطة تفتيش (إعلان)", "Checkpoint advisory", x + bw + C.px(12), y + C.px(124), bw,
        function() act("policeDispatch", { kind = "roadblock", text = v("pol_dispatch") }) end, LCRE.theme.gold)
    local lines = {
        C.t("أوامر سريعة", "Quick commands"),
        "/eliteduty   /elitemdt   /elite911",
        "/elitebackup   /eliteswat   /eliteroadblock",
        "/elitehostage <name>   /elitenegotiate <name>   /eliterob <name>",
        C.t("نقطة التفتيش إعلان فقط - لا توجد كائنات أو حواجز مادية في الطريق.",
            "Checkpoints are advisory only - no objects or physical road blockers are created."),
    }
    for i, line in ipairs(lines) do
        C.text(line, x, y + C.px(190) + (i - 1) * C.px(32), w, C.px(28),
            C.color(i == 1 and LCRE.theme.gold or LCRE.theme.dim), C.fontSmall, "left", "center")
    end
end

addEventHandler("onClientRender", root, function()
    if C.panel ~= "police" then return end
    local w, h = C.px(1000), C.px(660)
    local x, y = (sw - w) / 2, (sh - h) / 2
    C.window(x, y, w, h, LCRE.theme.blue,
        "مركز قيادة الشرطة", "LSPD COMMAND / MDT",
        "Rank-gated and server-authoritative / صلاحيات مشددة")
    C.tabs(TABS, x + C.px(14), y + C.px(68), w - C.px(28), C.tab.police,
        function(id) C.tab.police = id end, LCRE.theme.blue)
    local cx, cy = x + C.px(18), y + C.px(114)
    local cw, ch = w - C.px(36), h - C.px(136)
    local d = C.data.mdt
    if C.tab.police == "mdt" then mdt(d, cx, cy, cw, ch)
    elseif C.tab.police == "records" then records(cx, cy, cw, ch)
    elseif C.tab.police == "enforce" then enforcement(cx, cy, cw, ch)
    elseif C.tab.police == "evidence" then evidence(cx, cy, cw, ch)
    elseif C.tab.police == "hr" then hr(cx, cy, cw, ch)
    elseif C.tab.police == "tools" then tools(cx, cy, cw, ch)
    end
end)

-- Compact on-duty status. It does not replace any existing server HUD.
addEventHandler("onClientRender", root, function()
    if not C.duty or C.panel or not getElementData(localPlayer, "char.spawned") then return end
    local w, h = C.px(210), C.px(42)
    local x, y = sw - w - C.px(16), C.px(16)
    C.rect(x, y, w, h, C.color({ 8, 8, 11 }, 220))
    C.rect(x, y, C.px(3), h, C.color(LCRE.theme.blue, 255))
    local d = C.data.mdt
    C.text("LSPD  |  " .. C.t("في الخدمة", "ON DUTY"), x + C.px(12), y + C.px(4), w - C.px(20), C.px(20),
        C.color(LCRE.theme.blue), C.fontSmall, "left", "center")
    C.text(tostring(d and d.rankName or ""), x + C.px(12), y + C.px(22), w - C.px(20), C.px(18),
        C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
end)
