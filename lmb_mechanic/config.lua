-- ============================================================
-- [LmB] Customs - shared configuration
-- NOTE: Prices here are used for DISPLAY. Every price is resolved
--       again on the server before any money moves.
-- ============================================================

LMB = LMB or {}

LMB.brand = "LmB Customs"
LMB.studio = "LmB Roleplay"
LMB.slogan = "FIX  •  UPGRADE  •  DRIVE"
LMB.job = "mechanic"

-- 2026-11-18: moved from the rejected old coordinates to the verified
-- Liberty City industrial site. The real building is now supplied by
-- luxury_mechanic_liberty; this resource keeps the mechanic logic/UI only.
LMB.workshop = {
    x = -35.0, y = 645.0, z = 10.40,
    radius = 13.0,       -- service zone
    radiusUI = 16.0,     -- hint / interaction radius
    interior = 0,
    dimension = 0,
    visual = false,      -- no duplicate garage props at this location
    -- Visual footprint used by the in-world garage and its gold outlines.
    footprint = {
        canopyFront = -11.0, canopyBack = 0.6,
        buildingFront = -3.1, buildingBack = 10.1,
        halfWidth = 8.2, buildingHalfWidth = 11.4,
        canopyHeight = 5.7, buildingHeight = 4.3,
        signHeight = 6.6,
    },
}

-- Luxury palette (primary / secondary). Values are GTA colour IDs where
-- possible plus RGB for the UI swatches.
LMB.palette = {
    { name = "Champagne Gold", ar = "ذهبي شامباني", rgb = { 212, 175,  90 } },
    { name = "Midnight Black", ar = "أسود ليلي",    rgb = {  18,  20,  26 } },
    { name = "Pearl White",    ar = "أبيض لؤلؤي",   rgb = { 238, 238, 232 } },
    { name = "Racing Red",     ar = "أحمر سباق",    rgb = { 186,  30,  38 } },
    { name = "Royal Blue",     ar = "أزرق ملكي",    rgb = {  30,  70, 160 } },
    { name = "Emerald",        ar = "زمردي",        rgb = {  24, 130,  86 } },
    { name = "Silver Frost",   ar = "فضي",          rgb = { 176, 182, 190 } },
    { name = "Desert Sand",    ar = "رملي",         rgb = { 205, 178, 132 } },
    { name = "Carbon Grey",    ar = "رمادي كربون",  rgb = {  58,  62,  70 } },
    { name = "Burgundy",       ar = "خمري",         rgb = { 112,  32,  52 } },
    { name = "Neon Cyan",      ar = "سيان نيون",    rgb = {  40, 200, 220 } },
    { name = "Sunset Orange",  ar = "برتقالي",      rgb = { 232, 120,  36 } },
    { name = "Deep Violet",    ar = "بنفسجي",       rgb = { 110,  62, 170 } },
    { name = "Army Olive",     ar = "زيتوني",       rgb = {  92, 104,  64 } },
    { name = "Rose Gold",      ar = "ذهبي وردي",    rgb = { 214, 160, 150 } },
    { name = "Ice Blue",       ar = "أزرق جليدي",   rgb = { 150, 205, 232 } },
}

-- Repair prices (server authoritative).
LMB.repair = {
    engine = { price = 450, ar = "إصلاح المحرك", en = "Repair Engine" },
    body   = { price = 350, ar = "إصلاح الهيكل", en = "Repair Body" },
    tires  = { price = 250, ar = "إصلاح الإطارات", en = "Repair Tires" },
    all    = { price = 950, ar = "إصلاح شامل", en = "Full Repair" },
}

-- Performance stages. GTA has no engine-upgrade model: engine/brakes/
-- suspension/handling are applied through setVehicleHandling from the
-- original factory handling, so they can never stack incorrectly.
LMB.upgrades = {
    { id = "engine1", ar = "محرك - المرحلة 1", en = "Engine Stage 1", price = 1200, effect = "+8% acceleration", icon = "ic_engine", stage = "engine", mult = { engineAcceleration = 1.08, maxVelocity = 1.05 } },
    { id = "engine2", ar = "محرك - المرحلة 2", en = "Engine Stage 2", price = 2600, effect = "+16% acceleration", icon = "ic_engine", stage = "engine", mult = { engineAcceleration = 1.16, maxVelocity = 1.10 } },
    { id = "engine3", ar = "محرك - المرحلة 3", en = "Engine Stage 3", price = 5000, effect = "+26% acceleration", icon = "ic_engine", stage = "engine", mult = { engineAcceleration = 1.26, maxVelocity = 1.16 } },
    { id = "turbo",   ar = "تيربو",            en = "Turbo",            price = 3500, effect = "+10% top speed",  icon = "ic_turbo",  stage = "turbo",   mult = { maxVelocity = 1.10, engineAcceleration = 1.10 } },
    { id = "brakes",  ar = "فرامل رياضية",      en = "Sport Brakes",     price = 900,  effect = "+18% braking",    icon = "ic_brake",  stage = "brakes",  mult = { brakeDeceleration = 1.18 } },
    { id = "susp",    ar = "تعليق رياضي",       en = "Sport Suspension", price = 700,  effect = " tighter ride",   icon = "ic_susp",   stage = "susp",    mult = { suspensionForceLevel = 1.20, suspensionDamping = 1.15 } },
    { id = "handling",ar = "تحسين التوجيه",     en = "Handling Package", price = 1500, effect = "+14% traction",   icon = "ic_dash",  stage = "handling",mult = { tractionMultiplier = 1.14, steeringLock = 1.08 } },
    { id = "nitro",   ar = "نيترو (5x)",        en = "Nitro (5x)",       price = 2200, effect = "NOS upgrade 1008",icon = "ic_nitro",  upgrade = 1008 },
}

-- Body parts: the server builds the actual list from
-- getVehicleCompatibleUpgrades(), grouped by getVehicleUpgradeSlotName().
LMB.partCategories = {
    { key = "spoiler",  ar = "سبويلر",        en = "Spoilers",   icon = "ic_spoiler", slots = { "Spoiler" }, price = 600 },
    { key = "wheels",   ar = "جنوط",          en = "Wheels",     icon = "ic_wheel",   slots = { "Wheels" },  price = 1100 },
    { key = "exhaust",  ar = "عادم",          en = "Exhaust",    icon = "ic_exhaust", slots = { "Exhaust" },  price = 750 },
    { key = "bumper",   ar = "صدامات",        en = "Bumpers",    icon = "ic_bumper",  slots = { "Front Bumper", "Rear Bumper", "Bullbar", "Front Bullbars", "Rear Bullbars" }, price = 650 },
    { key = "skirt",    ar = "ناطحات جانبية", en = "Side Skirts",icon = "ic_skirt",   slots = { "Sideskirt" }, price = 550 },
    { key = "bodykit",  ar = "كيت هيكل",      en = "Body Kits",  icon = "ic_bodykit", slots = { "Roof", "Hood", "Vents", "Vent" }, price = 1400 },
    { key = "lights",   ar = "إضاءة",         en = "Lights",     icon = "ic_lights",  slots = { "Lamps" }, price = 500 },
}

-- Ranks 1..6 (kept inside ng-jobs' 0..6 range).
LMB.ranks = {
    [1] = { ar = "متدرب",      en = "Trainee",    pay = 0 },
    [2] = { ar = "فني",        en = "Technician", pay = 50 },
    [3] = { ar = "أخصائي",     en = "Specialist", pay = 90 },
    [4] = { ar = "فني أول",    en = "Senior Tech",pay = 140 },
    [5] = { ar = "مشرف ورشة",  en = "Foreman",    pay = 200 },
    [6] = { ar = "مدير المركز", en = "Chief",      pay = 280 },
}

LMB.perm = {
    repair = 1, upgrade = 2, paint = 2, parts = 2, tow = 3,
    invoice = 3, reviewApps = 5, hire = 5, rank = 6, logs = 5,
}

LMB.towFee = 350
LMB.towModel = 525
LMB.commission = 0.20   -- mechanic commission from each paid job
LMB.quoteLifetime = 45000
LMB.actionLimit = 12    -- actions per second per player

-- Colour helpers used by both sides.
function LMB.hex(rgb)
    return string.format("#%02X%02X%02X", rgb[1], rgb[2], rgb[3])
end

function LMB.money(n)
    n = math.floor(tonumber(n) or 0)
    local s = tostring(math.abs(n))
    local out = ""
    while #s > 3 do
        out = "," .. s:sub(-3) .. out
        s = s:sub(1, #s - 3)
    end
    return (n < 0 and "-$" or "$") .. s .. out
end
