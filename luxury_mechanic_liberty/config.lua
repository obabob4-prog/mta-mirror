-- ============================================================
-- LUXURY MECHANIC CENTER / LIBERTY CITY
-- Shared configuration. Every coordinate is editable here.
--
-- Site provenance:
--   LC/zones/industse + industsw map/definition files, water.dat and
--   lc_audit in-game probes. Verified 2026-11-18:
--   -35,645 half=40: ground=289/289, water=0, void=0, overlap=0
--   -35,645 half=6 : ground=49/49,  water=0, void=0, z=7.98..10.16
--   nearest road: ind_customroad109 @ -90.57,720.37 z=12.22 (94 m)
--   nearest solid map building: doc_rave2 @ -65.74,701.31 (64 m)
-- This is Liberty City native coordinates, NOT San Andreas.
-- ============================================================

LML = LML or {}

LML.brand  = "LUXURY AUTO CUSTOMS"
LML.short  = "LUXURY MECHANIC CENTER"
LML.job    = "mechanic"

-- Exterior, verified solid ground in the industrial district of LC.
LML.site = {
    x = -35.0, y = 645.0,
    baseZ = 8.0,        -- underside of the concrete pad
    floorZ = 10.4,      -- garage floor / pad top
    rotZ = 0,           -- entrance faces +Y, toward the street approach
    interior = 0,
    dimension = 0,
    -- Driveway target taken from the actual LC road entry in water/map data.
    road = { x = -90.57, y = 720.37, z = 12.22 },
    entrance = { x = -35.0, y = 657.0, z = 10.4, radius = 4.0 },
    customerParking = {
        { x = -48.0, y = 650.0, rz = 0 },
        { x = -22.0, y = 650.0, rz = 0 },
        { x = -48.0, y = 636.0, rz = 0 },
        { x = -22.0, y = 636.0, rz = 0 },
    },
    -- Visual footprint used by client LEDs and server collision pads.
    footprint = {
        halfWidth = 15.0,
        frontY = 12.0,
        backY = -12.0,
        height = 6.2,
        signHeight = 8.4,
        rampFrom = 12.0,
        rampTo = 62.0,
    },
}

-- Separate 3D interior. Own dimension keeps it away from the LC street grid.
LML.interior = {
    x = 0.0, y = 0.0, z = 10.0,
    interior = 0,
    dimension = 21050,
    floorZ = 10.0,
    exit = { x = 0.0, y = -12.0, z = 10.0, radius = 3.6 },
    lifts = {
        { x = -8.0, y = 2.0 },
        { x =  0.0, y = 2.0 },
        { x =  8.0, y = 2.0 },
    },
    reception = { x = -13.0, y = -7.0, z = 10.0 },
    office    = { x =  13.0, y =  8.0, z = 10.0 },
    paint     = { x =  13.0, y = -7.0, z = 10.0 },
    parking   = { x =   0.0, y = -7.0, z = 10.0 },
}

-- Server-authoritative prices. Display uses the same table.
LML.prices = {
    repairAll = 950,
    repairEngine = 450,
    repairBody = 350,
    repairTires = 250,
    engine1 = 1200,
    engine2 = 2600,
    engine3 = 5000,
    turbo = 3500,
    brakes = 900,
    suspension = 700,
    handling = 1500,
    nitro = 2200,
    wheels = 1100,
    color = 400,
    bodykit = 1400,
    partEngine = 650,
    partBrakes = 380,
    partTires = 420,
    partGlass = 260,
}

-- Engine stages use the original factory handling as the base, so stages
-- never stack on top of each other incorrectly.
LML.engineStages = {
    engine1 = { mult = { engineAcceleration = 1.08, maxVelocity = 1.05 }, label = "Stage 1" },
    engine2 = { mult = { engineAcceleration = 1.16, maxVelocity = 1.10 }, label = "Stage 2" },
    engine3 = { mult = { engineAcceleration = 1.26, maxVelocity = 1.16 }, label = "Stage 3" },
}

LML.colors = {
    { name = "Champagne Gold", ar = "ذهبي شامباني", rgb = { 212, 175,  90 } },
    { name = "Midnight Black", ar = "أسود ليلي",    rgb = {  18,  20,  26 } },
    { name = "Pearl White",    ar = "أبيض لؤلؤي",   rgb = { 238, 238, 232 } },
    { name = "Racing Red",     ar = "أحمر سباق",    rgb = { 186,  30,  38 } },
    { name = "Royal Blue",     ar = "أزرق ملكي",    rgb = {  30,  70, 160 } },
    { name = "Emerald",        ar = "زمردي",        rgb = {  24, 130,  86 } },
    { name = "Silver Frost",   ar = "فضي",          rgb = { 176, 182, 190 } },
    { name = "Carbon Grey",    ar = "رمادي كربون",  rgb = {  58,  62,  70 } },
}

LML.parts = {
    partEngine = { item = "engine_part",  label = "محرك قطعة غيار" },
    partBrakes = { item = "brake_part",   label = "فرامل قطعة غيار" },
    partTires  = { item = "tire_part",    label = "إطار قطعة غيار" },
    partGlass  = { item = "glass_part",   label = "زجاج قطعة غيار" },
}

-- Palace palette kept consistent with the rest of the server's luxury UI.
LML.palette = {
    gold  = { 212, 175,  90 },
    red   = { 186,  30,  38 },
    dark  = {  10,  11,  15 },
    grey  = {  42,  45,  52 },
    white = { 245, 240, 228 },
}

function LML.money(n)
    n = math.floor(tonumber(n) or 0)
    local s = tostring(math.abs(n))
    local out = ""
    while #s > 3 do
        out = "," .. s:sub(-3) .. out
        s = s:sub(1, #s - 3)
    end
    return (n < 0 and "-$" or "$") .. s .. out
end
