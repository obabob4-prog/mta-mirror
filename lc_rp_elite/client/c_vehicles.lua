--[[
    lc_rp_elite / client/c_vehicles.lua
    Fleet / garage panel. Only approved stock model IDs can be spawned, and
    every spawn, retrieve, lock, store and release is validated server-side.
]]
local C = LCRE.client
local sw, sh = C.sw, C.sh

local TABS = {
    { id = "faction", ar = "أسطول العائلة", en = "Faction fleet" },
    { id = "police",  ar = "أسطول الشرطة",  en = "LSPD fleet" },
    { id = "impound", ar = "المصادرة",      en = "Impound" },
}
C.tab.vehicles = C.tab.vehicles or "faction"
local selectedVehicle = 0

addEvent("lcre:vehicleData", true)
addEventHandler("lcre:vehicleData", root, function(list, kind, faction)
    C.data.vehicles = { list = list or {}, kind = kind or "faction", faction = faction or 0 }
    selectedVehicle = 0
end)

local function v(id) return C.inputs[id] or "" end
local function num(id) return tonumber(v(id)) or 0 end
local function refresh(kind)
    C.send("vehicleList", { kind = kind, faction = 0 })
end
local function act(name, data, kind)
    C.send(name, data or {})
    setTimer(function() refresh(kind) end, 300, 1)
end

local function field(labelAr, labelEn, x, y, w, id)
    C.text(C.t(labelAr, labelEn), x, y - C.px(2), w, C.px(22),
        C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
    C.input(id, labelAr, labelEn, x, y + C.px(22), w, C.px(34))
end

local function drawFleet(kind, x, y, w, h)
    local d = C.data.vehicles
    local catalog = kind == "police" and LCRE.policeVehicles or LCRE.mafiaVehicles
    local accent = kind == "police" and LCRE.theme.blue or LCRE.theme.gold

    local rows = {}
    if d and d.kind == kind then
        for _, veh in ipairs(d.list) do
            rows[#rows + 1] = { id = veh.id, label = "#" .. tostring(veh.id) .. "  model " ..
                tostring(veh.model) .. "  " .. tostring(veh.plate) .. "  " ..
                (tonumber(veh.stored) == 1 and C.t("مخزنة", "Stored") or C.t("خارج", "Deployed")) }
        end
    end
    C.list(rows, x, y, w * 0.52, h - C.px(48), C.px(32), function(row) return row.label end,
        function(row)
            selectedVehicle = row.id
            C.inputs["veh_id"] = tostring(row.id)
        end, accent)

    local sx = x + w * 0.55
    local sw2 = w * 0.45
    C.text(C.t("المركبات المتاحة", "Approved models"), sx, y, sw2, C.px(26),
        C.color(accent), C.font, "left", "center")
    local catRows = {}
    for _, def in ipairs(catalog) do
        catRows[#catRows + 1] = { model = def.model, label = def.name .. "  [model " ..
            tostring(def.model) .. "]  R" .. tostring(def.rank or 1) }
    end
    local maxVisible = math.max(1, math.floor((h * 0.48) / C.px(30)))
    C.list(catRows, sx, y + C.px(30), sw2, C.px(30) * maxVisible, C.px(30),
        function(row) return row.label end, function(row) C.inputs["veh_model"] = tostring(row.model) end, accent)

    field("رقم المركبة", "Vehicle ID", sx, y + h * 0.52, sw2, "veh_id")
    field("الموديل", "Model ID", sx, y + h * 0.52 + C.px(64), sw2, "veh_model")
    local by = y + h * 0.52 + C.px(128)
    local bw = (sw2 - C.px(8)) / 2
    C.button("veh_spawn", "إنشاء", "Spawn", sx, by, bw, C.px(42),
        function() act("vehicleSpawn", { kind = kind, model = num("veh_model") }, kind) end, false, accent)
    C.button("veh_retrieve", "إحضار", "Retrieve", sx + bw + C.px(8), by, bw, C.px(42),
        function() act("vehicleRetrieve", { id = num("veh_id") }, kind) end, false, LCRE.theme.good)
    C.button("veh_lock", "قفل / فتح", "Lock / unlock", sx, by + C.px(48), bw, C.px(42),
        function() act("vehicleLock", { id = num("veh_id") }, kind) end, false, LCRE.theme.blue)
    C.button("veh_store", "تخزين", "Store", sx + bw + C.px(8), by + C.px(48), bw, C.px(42),
        function() act("vehicleStore", { id = num("veh_id") }, kind) end, false, LCRE.theme.dim)
    C.text(C.t("الإنشاء داخل مرآب خاص فقط. الإحضار إلى نقطة الدخول التي سُجّلت من الباب الحقيقي.",
               "Spawn works inside a private garage only. Retrieval uses the saved real-door entry point."),
        sx, by + C.px(104), sw2, C.px(48), C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
end

local function impound(x, y, w, h)
    C.rect(x, y, w, C.px(76), C.color(LCRE.theme.panel, 255))
    C.text(C.t("مركبات محجوزة من قبل LSPD", "Vehicles impounded by LSPD"),
        x + C.px(16), y + C.px(12), w - C.px(32), C.px(28), C.color(LCRE.theme.blue), C.font, "left", "center")
    C.text(C.t("الإفراج يعيد المركبة إلى موقع الحجز الأصلي. يتطلب صلاحية ضابط رقيب أو أعلى.",
               "Release returns the vehicle to its original impound location. Sergeant+ is required."),
        x + C.px(16), y + C.px(42), w - C.px(32), C.px(24), C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
    field("رقم سجل الحجز", "Impound record ID", x, y + C.px(96), w * 0.58, "veh_impound_id")
    C.button("veh_release", "إفراج", "Release", x + w * 0.62, y + C.px(118), w * 0.38, C.px(46),
        function()
            C.send("policeImpoundRelease", { id = num("veh_impound_id") })
            setTimer(function() C.send("vehicleList", { kind = "impound", faction = 0 }) end, 300, 1)
        end, false, LCRE.theme.good)
    C.text("/elitegarage   |   /elitemdt", x, y + C.px(190), w, C.px(28),
        C.color(LCRE.theme.dim), C.fontSmall, "left", "center")
end

addEventHandler("onClientRender", root, function()
    if C.panel ~= "vehicles" then return end
    local w, h = C.px(920), C.px(620)
    local x, y = (sw - w) / 2, (sh - h) / 2
    C.window(x, y, w, h, LCRE.theme.gold,
        "المرآب والأسطول", "GARAGE / FLEET",
        "Approved stock models only - exterior map untouched")
    C.tabs(TABS, x + C.px(14), y + C.px(68), w - C.px(28), C.tab.vehicles,
        function(id)
            C.tab.vehicles = id
            if id == "police" then C.send("vehicleList", { kind = "police", faction = 0 })
            elseif id == "faction" then C.send("vehicleList", { kind = "faction", faction = 0 }) end
        end, LCRE.theme.gold)
    local cx, cy = x + C.px(18), y + C.px(114)
    local cw, ch = w - C.px(36), h - C.px(136)
    if C.tab.vehicles == "faction" then drawFleet("faction", cx, cy, cw, ch)
    elseif C.tab.vehicles == "police" then drawFleet("police", cx, cy, cw, ch)
    elseif C.tab.vehicles == "impound" then impound(cx, cy, cw, ch)
    end
end)
