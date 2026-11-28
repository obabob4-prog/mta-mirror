--[[
    lc_rp_elite / shared/config.lua
    GTA V style Roleplay layer for the unmodified Liberty City map.

    HARD RULES IMPLEMENTED HERE
    - No dimension 0 object, marker, collision, building or road is created.
    - Every entrance is a real existing Liberty City door from liberty_world/LC/zones/*.map.
    - Entry is walking through that door: no E key, no command, no teleport marker.
    - The ONLY change on crossing is the dimension; position/rotation/velocity stay untouched.
    - Each private room is staged so its own GTA V doorway sits on the exterior door.
    - The room shell is the proven converted GTA V apartment shell from luxury_houses.
    - Stock GTA:SA interiors are NOT used: this LC build neutralized them.
]]

LCRE = LCRE or {}

LCRE.version = "1.0.0"
LCRE.resource = "lc_rp_elite"

LCRE.world = {
    exteriorInterior = 0,
    exteriorDimension = 0,
    interior = 0,
    dimBase = 50000,
    hintRange = 4.0,
}

-- Proven private room stage (the same geometry used by luxury_houses).
LCRE.room = {
    originX = 3000.0, originY = 3000.0, originZ = 500.0, rotZ = 87.00007855374548,
    spawnX = 2997.58, spawnY = 3005.75, spawnZ = 499.5, spawnRot = 90,
    exitX = 2997.58, exitY = 3002.20, exitZ = 499.5,
    floorTopZ = -1.80, floorCenterY = 2.40,
    floorSizeX = 28.0, floorSizeY = 46.0, floorThickness = 0.45,
    safetyRadius = 45.0,
    -- The shell's real doorway, decoded from luxury_houses spawn/exit offsets.
    -- (doorLocal -> insideLocal is the direction of travel into the room.)
    doorLocalX = 2.07, doorLocalY = 2.53, doorLocalZ = -0.50,
    insideLocalX = 5.62, insideLocalY = 2.72, insideLocalZ = -0.50,
}

-- Seamless walk-through: no E key, no marker, no position change.
LCRE.walk = { radius = 1.35, clearRadius = 2.8, cooldown = 1100, tick = 200 }

local function normAngle(a)
    a = tonumber(a) or 0
    a = a % 360
    if a < 0 then a = a + 360 end
    return a
end

-- The shell's inward direction is its local +X. luxury_houses used rotZ~87 for
-- an exterior door rotZ~90, so the exterior map door rotation is the room's
-- facing direction. Matching it keeps the doorway plane on the real door.
function LCRE.roomRotation(hq)
    if hq and hq.door and hq.door.rz ~= nil then return normAngle(hq.door.rz) end
    return normAngle(LCRE.room.rotZ)
end

-- Origin of a private room whose doorway sits exactly on the exterior door.
function LCRE.roomOrigin(hq)
    local rot = math.rad(LCRE.roomRotation(hq))
    local c, s = math.cos(rot), math.sin(rot)
    local lx = tonumber(LCRE.room.doorLocalX) or 2.07
    local ly = tonumber(LCRE.room.doorLocalY) or 2.53
    local lz = tonumber(LCRE.room.doorLocalZ) or -0.50
    local baseX = hq and hq.door and tonumber(hq.door.x) or (tonumber(LCRE.room.originX) or 3000)
    local baseY = hq and hq.door and tonumber(hq.door.y) or (tonumber(LCRE.room.originY) or 3000)
    local baseZ = hq and hq.door and tonumber(hq.door.z) or (tonumber(LCRE.room.originZ) or 500)
    return baseX - (lx * c - ly * s),
           baseY - (lx * s + ly * c),
           baseZ - lz
end

-- Shared transform used by both server staging and client room rendering.
function LCRE.roomPoint(lx, ly, lz, hq)
    local rot = math.rad(LCRE.roomRotation(hq))
    local c, s = math.cos(rot), math.sin(rot)
    local ox, oy, oz
    if hq then ox, oy, oz = LCRE.roomOrigin(hq)
    else ox, oy, oz = tonumber(LCRE.room.originX) or 3000,
                      tonumber(LCRE.room.originY) or 3000,
                      tonumber(LCRE.room.originZ) or 500 end
    return ox + (tonumber(lx) or 0) * c - (tonumber(ly) or 0) * s,
           oy + (tonumber(lx) or 0) * s + (tonumber(ly) or 0) * c,
           oz + (tonumber(lz) or 0)
end

LCRE.theme = {
    bg      = { 8, 8, 11, 238 },
    panel   = { 16, 16, 21, 246 },
    panel2  = { 24, 24, 31, 246 },
    line    = { 72, 62, 42, 255 },
    gold    = { 212, 175, 90, 255 },
    goldDim = { 212, 175, 90, 60 },
    blue    = { 64, 132, 210, 255 },
    blueDim = { 64, 132, 210, 60 },
    text    = { 238, 238, 242, 255 },
    dim     = { 158, 158, 170, 255 },
    good    = { 104, 196, 128, 255 },
    bad     = { 208, 82, 74, 255 },
    warn    = { 226, 176, 84, 255 },
}

LCRE.locale = {
    ar = {
        mafia = "مافيا", police = "شرطة", enter = "امشِ عبر الباب للدخول",
        exit = "امشِ عبر الباب للخروج", treasury = "الخزنة", armory = "مستودع الأسلحة",
        members = "الأعضاء", mdt = "نظام MDT", duty = "الخدمة", garage = "المرآب",
        logs = "السجلات", territories = "المناطق", orders = "الأوامر",
        none = "لا شيء", close = "إغلاق", confirm = "تأكيد", cancel = "إلغاء",
        denied = "تم الرفض", saved = "تم الحفظ",
    },
    en = {
        mafia = "Mafia", police = "Police", enter = "Walk through the door to enter",
        exit = "Walk through the door to leave", treasury = "Treasury", armory = "Armory",
        members = "Members", mdt = "MDT", duty = "Duty", garage = "Garage",
        logs = "Logs", territories = "Territories", orders = "Orders",
        none = "None", close = "Close", confirm = "Confirm", cancel = "Cancel",
        denied = "Denied", saved = "Saved",
    },
}

LCRE.mafiaRanks = {
    [1] = { key = "recruit",   ar = "مجند",        en = "Recruit",    pay = 500  },
    [2] = { key = "soldier",   ar = "جندي",        en = "Soldier",    pay = 900  },
    [3] = { key = "capo",      ar = "كابو",        en = "Capo",       pay = 1400 },
    [4] = { key = "underboss", ar = "أندربوس",     en = "Underboss",  pay = 2200 },
    [5] = { key = "leader",    ar = "قائد",        en = "Leader",     pay = 2800 },
    [6] = { key = "boss",      ar = "الزعيم",      en = "Boss",       pay = 3400 },
}

LCRE.mafiaPerms = {
    hq          = 1,
    treasury    = 2,
    warehouse   = 2,
    vehicle     = 2,
    territory   = 3,
    invite      = 4,
    promote     = 4,
    demote      = 4,
    kick        = 4,
    withdraw    = 4,
    manage      = 6,
    alliance    = 6,
    logs        = 4,
}

LCRE.policeRanks = {
    [1] = { key = "cadet",    ar = "كاديت",        en = "Cadet",          pay = 900  },
    [2] = { key = "officer",  ar = "ضابط",         en = "Officer",        pay = 1200 },
    [3] = { key = "senior",   ar = "ضابط أول",     en = "Senior Officer", pay = 1500 },
    [4] = { key = "sergeant", ar = "رقيب",         en = "Sergeant",       pay = 2200 },
    [5] = { key = "lieutenant", ar = "ملازم",      en = "Lieutenant",     pay = 2700 },
    [6] = { key = "captain",  ar = "نقيب",         en = "Captain",        pay = 3300 },
    [7] = { key = "deputy",   ar = "نائب الرئيس",  en = "Deputy Chief",   pay = 4000 },
    [8] = { key = "chief",    ar = "رئيس الشرطة",  en = "Chief",          pay = 5000 },
}

LCRE.policePerms = {
    patrol      = 1,
    cuff        = 1,
    search      = 2,
    fine        = 2,
    arrest      = 2,
    wanted      = 2,
    mdt         = 2,
    impound     = 3,
    dispatch    = 4,
    evidence    = 4,
    swat        = 5,
    recruit     = 6,
    fire        = 7,
    chief       = 8,
}

-- Four mafia identities. Faction 1 is compatible with liberty_city_gangs.
LCRE.factions = {
    [1] = {
        key = "famiglia", name = { ar = "عائلة بيرلينو", en = "Berlino Family" },
        tag = "BL", color = { 212, 175, 90 }, hq = 1,
    },
    [2] = {
        key = "docks", name = { ar = "عصابة الميناء", en = "Docks Crew" },
        tag = "DC", color = { 176, 142, 78 }, hq = 3,
    },
    [3] = {
        key = "north", name = { ar = "تحالف الشمال", en = "North Side Alliance" },
        tag = "NS", color = { 148, 156, 172 }, hq = 7,
    },
    [4] = {
        key = "club", name = { ar = "نادي الثلاثة عشر", en = "Thirteen Club" },
        tag = "13", color = { 186, 118, 74 }, hq = 8,
    },
}

--[[
    HQ entrances. Every coordinate/rotation below is copied verbatim from the
    installed Liberty City map door records in liberty_world/LC/zones/*.map.
    NO marker and NO new door object is created outside. The private room is
    staged so its own doorway sits on this exact coordinate; walking through
    it changes ONLY the dimension. No coordinate is shared with
    luxury_houses, lc_premium_interiors, lmb_police or liberty_city_gangs.
]]
LCRE.hqs = {
    [1] = {
        key = "boss_palace", type = "mafia", faction = 1, minRank = 1,
        name = { ar = "قصر عائلة بيرلينو", en = "Berlino Boss Palace" },
        door = { x = -973.865, y = 1223.350, z = 26.9235, rz = 0, elementType = "building" },
        source = "comnbtm.map / door_bombshop",
        color = { 212, 175, 90 },
        services = { "treasury", "armory", "members", "meeting", "garage", "logs" },
        layout = "boss",
    },
    [2] = {
        key = "mafia_office", type = "mafia", faction = 1, minRank = 2,
        name = { ar = "مكتب إدارة العائلة", en = "Family Management Office" },
        door = { x = -1051.010, y = 1369.280, z = 26.774, rz = 90.000035460221, elementType = "building" },
        source = "comnbtm.map / door_jmsgrage",
        color = { 212, 175, 90 },
        services = { "members", "meeting", "logs", "territories" },
        layout = "office",
    },
    [3] = {
        key = "docks_vault", type = "mafia", faction = 2, minRank = 1,
        name = { ar = "خزنة عصابة الميناء", en = "Docks Crew Vault" },
        door = { x = -1089.446, y = 1005.979, z = 28.2174, rz = 0, elementType = "building" },
        source = "comnbtm.map / door3_garage",
        color = { 176, 142, 78 },
        services = { "treasury", "warehouse", "garage", "logs" },
        layout = "vault",
    },
    [4] = {
        key = "lcpd_central", type = "police", minRank = 1,
        name = { ar = "مقر شرطة Algonquin", en = "Algonquin Central Precinct" },
        door = { x = -998.511, y = 1089.220, z = 25.242, rz = -179.99984796107, elementType = "object" },
        source = "comnbtm.map / Gen_doorEXT11",
        color = { 64, 132, 210 },
        services = { "duty", "mdt", "armory", "cells", "garage", "logs" },
        layout = "police",
    },
    [5] = {
        key = "lcpd_detective", type = "police", minRank = 3,
        name = { ar = "مكتب التحقيقات", en = "Detective Bureau" },
        door = { x = -1318.940, y = 1448.950, z = 17.0564, rz = 90.000035460221, elementType = "building" },
        source = "comntop.map / door_col_compnd_03",
        color = { 64, 132, 210 },
        services = { "mdt", "evidence", "interrogation", "logs" },
        layout = "detective",
    },
    [6] = {
        key = "lcpd_evidence", type = "police", minRank = 4,
        name = { ar = "مستودع الأدلة", en = "Evidence Lockup" },
        door = { x = -1124.980, y = 1466.930, z = 30.686, rz = -89.999923980241, elementType = "object" },
        source = "comntop.map / Gen_doorEXT07",
        color = { 64, 132, 210 },
        services = { "evidence", "logs" },
        layout = "evidence",
    },
    [7] = {
        key = "north_ops", type = "mafia", faction = 3, minRank = 2,
        name = { ar = "غرفة عمليات الشمال", en = "North Side Operations" },
        door = { x = -1351.800, y = 1275.200, z = 18.670, rz = 83.000177853103, elementType = "object" },
        source = "comnbtm.map / Gen_doorEXT05",
        color = { 148, 156, 172 },
        services = { "meeting", "territories", "warehouse", "logs" },
        layout = "planning",
    },
    [8] = {
        key = "thirteen_club", type = "club", faction = 4, minRank = 1,
        name = { ar = "نادي الثلاثة عشر الخاص", en = "Thirteen Private Club" },
        door = { x = -136.230, y = 1556.650, z = 23.9363, rz = 180, elementType = "building" },
        source = "industne.map / oddjgaragdoor",
        color = { 186, 118, 74 },
        services = { "vip", "meeting", "garage", "logs" },
        layout = "club",
    },
    [9] = {
        key = "secret_garage", type = "garage", faction = 2, minRank = 2,
        name = { ar = "مرآب سري", en = "Secure Private Garage" },
        door = { x = -973.965, y = 1362.330, z = 21.866, rz = 0, elementType = "building" },
        source = "comnbtm.map / door_sfehousegrge",
        color = { 176, 142, 78 },
        services = { "garage", "warehouse", "logs" },
        layout = "garage",
    },
    [10] = {
        key = "port_depot", type = "warehouse", faction = 2, minRank = 1,
        name = { ar = "مستودع الميناء السري", en = "Port Secret Depot" },
        door = { x = -451.112, y = 1458.749, z = 9.338, rz = 90.0002280593, elementType = "object" },
        source = "industnw.map / Gen_doorEXT19",
        color = { 176, 142, 78 },
        services = { "warehouse", "treasury", "garage", "logs" },
        layout = "warehouse",
    },
    [11] = {
        key = "swat_armory", type = "police", minRank = 5,
        name = { ar = "مستودع SWAT", en = "SWAT Armory" },
        door = { x = -68.230, y = 1700.360, z = 15.370, rz = -89.999923980324, elementType = "building" },
        source = "industne.map / bombdoor",
        color = { 64, 132, 210 },
        services = { "armory", "swat", "duty", "logs" },
        layout = "swat",
    },
    [12] = {
        key = "executive_suite", type = "executive", minRank = 0,
        name = { ar = "الجناح التنفيذي", en = "Executive Suite" },
        door = { x = -2012.650, y = 1761.350, z = 19.5549, rz = 0, elementType = "building" },
        source = "landne.map / towergaragedoor1",
        color = { 212, 175, 90 },
        services = { "vip", "meeting", "logs" },
        layout = "executive",
    },
}

for id, hq in ipairs(LCRE.hqs) do
    hq.id = id
    hq.dimension = LCRE.world.dimBase + id
    hq.interior = LCRE.world.interior
    hq.roomRot = LCRE.roomRotation(hq)
    local ix, iy, iz = LCRE.roomPoint(LCRE.room.insideLocalX, LCRE.room.insideLocalY,
        LCRE.room.insideLocalZ, hq)
    local ex, ey, ez = LCRE.roomPoint(LCRE.room.doorLocalX, LCRE.room.doorLocalY,
        LCRE.room.doorLocalZ, hq)
    hq.spawn = { x = ix, y = iy, z = iz, rz = hq.roomRot }
    -- This is the doorway: on both sides of the crossing it is the same world
    -- point as the exterior map door. No jump is ever performed here.
    hq.exit = { x = ex, y = ey, z = ez }
end

LCRE.hqById = {}
for _, hq in ipairs(LCRE.hqs) do LCRE.hqById[hq.id] = hq end

LCRE.territories = {
    { id = 1, name = { ar = "Chinatown", en = "Chinatown" }, x = -310, y = 1145, r = 180 },
    { id = 2, name = { ar = "Downtown", en = "Downtown" }, x = -1120, y = 1060, r = 220 },
    { id = 3, name = { ar = "Star Junction", en = "Star Junction" }, x = -1320, y = 730, r = 200 },
    { id = 4, name = { ar = "Docks", en = "Docks" }, x = -890, y = 390, r = 230 },
    { id = 5, name = { ar = "Bohan industrial", en = "Bohan Industrial" }, x = -1430, y = 1310, r = 210 },
    { id = 6, name = { ar = "Shoreside Vale", en = "Shoreside Vale" }, x = -2020, y = 1760, r = 300 },
}

-- Stock models only. No stock model is replaced by this resource.
LCRE.mafiaVehicles = {
    { model = 409, name = "Executive Limousine", rank = 3 },
    { model = 445, name = "Black Sedan", rank = 1 },
    { model = 507, name = "Elegant", rank = 2 },
    { model = 585, name = "Emperor", rank = 1 },
    { model = 579, name = "Huntley SUV", rank = 2 },
    { model = 402, name = "Sports Coupe", rank = 4 },
    { model = 503, name = "Supercar", rank = 5 },
}

LCRE.policeVehicles = {
    { model = 596, name = "Police Cruiser", rank = 1 },
    { model = 523, name = "Police Cruiser II", rank = 1 },
    { model = 599, name = "Police SUV", rank = 2 },
    { model = 490, name = "FBI Interceptor", rank = 3 },
    { model = 427, name = "Enforcer", rank = 4 },
    { model = 528, name = "SWAT Van", rank = 5 },
    { model = 497, name = "Police Helicopter", rank = 5 },
}

LCRE.salaryInterval = 180000 -- 3 minutes

-- Weapon/contraband catalogues. Every item here is server-whitelisted.
LCRE.weaponItems = {
    weapon_pistol  = { weapon = 22, ammo = 90,  rank = 1, price = 900  },
    weapon_deagle  = { weapon = 24, ammo = 45,  rank = 2, price = 2400 },
    weapon_shotgun = { weapon = 25, ammo = 50,  rank = 2, price = 1800 },
    weapon_ak      = { weapon = 30, ammo = 90,  rank = 3, price = 5500 },
    medkit         = { weapon = 0,  ammo = 0,   rank = 1, price = 90   },
    repairkit      = { weapon = 0,  ammo = 0,   rank = 2, price = 220  },
}

LCRE.policeIssue = {
    [1] = { "weapon_pistol", "medkit" },
    [2] = { "weapon_pistol", "weapon_shotgun", "medkit" },
    [3] = { "weapon_deagle", "weapon_shotgun", "medkit" },
    [4] = { "weapon_deagle", "weapon_shotgun", "weapon_ak", "medkit" },
    [5] = { "weapon_deagle", "weapon_ak", "medkit", "repairkit" },
    [6] = { "weapon_deagle", "weapon_ak", "medkit", "repairkit" },
    [7] = { "weapon_deagle", "weapon_ak", "medkit", "repairkit" },
    [8] = { "weapon_deagle", "weapon_ak", "medkit", "repairkit" },
}

LCRE.contraband = {
    { item = "weapon_pistol",  price = 1200, stock = 1 },
    { item = "weapon_deagle",  price = 2600, stock = 1 },
    { item = "weapon_shotgun", price = 2100, stock = 1 },
    { item = "weapon_ak",      price = 6200, stock = 1 },
    { item = "medkit",         price = 110,  stock = 5 },
}

LCRE.rules = {
    inviteRange = 6.0,
    actionRange = 6.0,
    searchRange = 5.0,
    jailMinutes = 10,
    jailMaxMinutes = 60,
    fineMin = 100,
    fineMax = 15000,
    wantedMax = 5,
    maxFactionVehicles = 12,
    robberyCooldown = 300000,
    robberyMax = 5000,
    territoryInterval = 15000,
    territoryMinControl = 3,
    territoryRadiusBonus = 0,
}
