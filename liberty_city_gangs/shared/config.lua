--[[
    liberty_city_gangs / shared/config.lua
    Foundation configuration for Liberty City mafia & gangs.
    NOTES:
      - Liberty City only. All coordinates must be verified in-game before production use.
      - HQ exterior anchors reference real LC map building objects where identified.
      - Interiors are private-dimension spaces (implementation/WIP); verify assets/coords.
      - Vehicle models must be valid/spawnable in this server build.
]]

LCG = LCG or {}

LCG.version = "0.1.0"
LCG.resourceName = "liberty_city_gangs"
LCG.dimBaseHQ = 30000      -- HQ interior base dimension: dimBaseHQ + factionId
LCG.dimBaseGarage = 30500  -- garage/interior helper if needed
LCG.interactRange = 2.5
LCG.markerAlpha = 140
LCG.saveIntervalMs = 5 * 60 * 1000

-- UI theme (Luxury GTA V RP: black & gold)
LCG.theme = {
    bg      = { 10, 10, 12, 235 },
    panel   = { 18, 18, 22, 245 },
    panel2  = { 26, 26, 32, 245 },
    line    = { 70, 58, 30, 255 },
    gold    = { 212, 175, 90, 255 },
    goldSoft= { 212, 175, 90, 70  },
    text    = { 236, 236, 236, 255 },
    dim     = { 160, 160, 170, 255 },
    good    = { 104, 196, 128, 255 },
    bad     = { 208, 82, 74, 255 },
    warn    = { 226, 176, 84, 255 },
}

-- Rank ladder (shared template; per-faction can be extended later)
LCG.ranks = {
    [1] = { key = "recruit",      label = { ar="مجند", en="Recruit", pt="Recruta" } },
    [2] = { key = "member",       label = { ar="عضو", en="Member", pt="Membro" } },
    [3] = { key = "senior",       label = { ar="عضو أول", en="Senior Member", pt="Membro Sênior" } },
    [4] = { key = "captain",      label = { ar="كابتن", en="Captain", pt="Capitão" } },
    [5] = { key = "underboss",    label = { ar="نائب الزعيم", en="Underboss", pt="Subchefe" } },
    [6] = { key = "co_leader",    label = { ar="نائب القائد", en="Co-Leader", pt="Colíder" } },
    [7] = { key = "leader",       label = { ar="القائد", en="Leader", pt="Líder" } },
}

-- Permission keys checked server-side
LCG.perms = {
    INVITE          = "invite",
    KICK            = "kick",
    PROMOTE         = "promote",
    DEMOTE          = "demote",
    TREASURY_VIEW   = "treasury_view",
    TREASURY_DEPOSIT= "treasury_deposit",
    TREASURY_WITHDRAW="treasury_withdraw",
    WAREHOUSE_VIEW  = "warehouse_view",
    WAREHOUSE_PUT   = "warehouse_put",
    WAREHOUSE_TAKE  = "warehouse_take",
    VEHICLE_USE     = "vehicle_use",
    VEHICLE_MANAGE  = "vehicle_manage",
    HQ_ACCESS       = "hq_access",
    HQ_MANAGE       = "hq_manage",
    LOGS_VIEW       = "logs_view",
    TERRITORY       = "territory",
}

-- Default permissions by minimum rank (>=)
LCG.rankPerms = {
    [LCG.perms.HQ_ACCESS]        = 1,
    [LCG.perms.VEHICLE_USE]      = 2,
    [LCG.perms.TREASURY_VIEW]    = 2,
    [LCG.perms.TREASURY_DEPOSIT] = 1,
    [LCG.perms.WAREHOUSE_VIEW]   = 2,
    [LCG.perms.WAREHOUSE_PUT]    = 2,
    [LCG.perms.WAREHOUSE_TAKE]   = 3,
    [LCG.perms.LOGS_VIEW]        = 4,
    [LCG.perms.INVITE]           = 5,
    [LCG.perms.PROMOTE]          = 6,
    [LCG.perms.DEMOTE]           = 6,
    [LCG.perms.KICK]             = 6,
    [LCG.perms.VEHICLE_MANAGE]   = 6,
    [LCG.perms.TREASURY_WITHDRAW]= 6,
    [LCG.perms.HQ_MANAGE]        = 7,
    [LCG.perms.TERRITORY]        = 5,
}

-- Faction definitions
-- HQ exterior anchors are based on real LC map building objects (see docs/notes).
-- Entrance coords are near-anchor ground positions and MUST be probe-verified in-game.
LCG.factions = {
    [1] = {
        id = 1,
        key = "mafia",
        name = { ar="عائلة المافيا", en="The Mafia Family", pt="Família da Máfia" },
        identity = { ar="مافيا منظمة", en="Organized Mafia", pt="Máfia Organizada" },
        color = { 212, 175, 90 }, -- gold
        blip = 45,
        -- Anchor: hotel5 building (comnbtm.map) -1407.52,979.961,44.4315 / base map pos -1386.4,1120.13,65.7874 (large luxury building)
        -- 2026-11-22 OPEN-WORLD HQ:
        -- The old setup teleported players to an unverified "Eclipse-style"
        -- room at dimension 30001. That is now removed. The mafia uses a real
        -- walk-in club annex on the south forecourt of hotel5: stock SA wall
        -- sections (model 14843, with collision) at dimension 0 / interior 0.
        -- Its whole south face is open, so players enter from the street.
        hq = {
            label = { ar="قصر المافيا", en="Mafia Palace", pt="Palácio da Máfia" },
            openWorld = true,
            exterior = { x = -1386.4, y = 1149.0, z = 25.83, rot = 180, int = 0, dim = 0 },
            annex = {
                centerX = -1386.4,
                backY   = 1141.00,  -- just south of hotel5's south face (1140.15)
                frontY  = 1152.20,  -- completely open street-facing side
                halfW   = 5.60,
                floorZ  = 25.83,    -- verified by nearby hydrants at z=25.83
                roofZ   = 28.33,
                wallModel = 14843,
            },
            rooms = { "entrance","meeting","office","vault","warehouse","garage_access" },
            anchorBuilding = "hotel5 (comnbtm)",
        },
        garage = {
            spawn = { x = -1398.0, y = 1158.0, z = 25.83, rz = 0 },
            park  = { x = -1398.0, y = 1158.0, z = 25.33, r = 4.5 },
            capacity = 12,
        },
        vehicles = {
            { model = 409, name = "Stretch",   color = {20,20,20} },   -- luxury limo
            { model = 445, name = "Admiral",   color = {25,25,28} },
            { model = 507, name = "Elegant",   color = {30,28,24} },
            { model = 585, name = "Emperor",   color = {18,18,18} },
            { model = 561, name = "Stratum",   color = {22,22,22} },
            { model = 560, name = "Sultan",    color = {15,15,15} },
        },
        skins = { 46, 147, 57, 186 }, -- VERIFY availability in this server
        activity = "mafia",
    },

    [2] = {
        id = 2,
        key = "cartel",
        name = { ar="الكارتل", en="The Cartel", pt="O Cartel" },
        identity = { ar="كارتل إجرامي", en="Criminal Cartel", pt="Cartel Criminoso" },
        color = { 180, 140, 60 },
        blip = 51,
        -- Anchor: newdockbuilding (comnbtm.map) -930.821,1087.84,20.2382 (dock/industrial building)
        hq = {
            label = { ar="مستودع الكارتل", en="Cartel Warehouse", pt="Armazém do Cartel" },
            exterior = { x = -930.8, y = 1078.0, z = 13.9, rot = 0, int = 0, dim = 0 }, -- VERIFY IN-GAME
            interior = { x = 2997.58, y = 3005.75, z = 499.5, rot = 90, int = 0, dim = 30002 }, -- VERIFY
            rooms = { "entrance","meeting","office","vault","warehouse","garage_access" },
            anchorBuilding = "newdockbuilding (comnbtm)",
        },
        garage = {
            spawn = { x = -922.0, y = 1078.0, z = 13.9, rz = 90 }, -- VERIFY IN-GAME
            park  = { x = -922.0, y = 1078.0, z = 13.5, r = 4.5 },
            capacity = 12,
        },
        vehicles = {
            { model = 579, name = "Huntley",    color = {35,30,20} }, -- SUV
            { model = 400, name = "Landstalker",color = {40,35,25} },
            { model = 489, name = "Rancher",    color = {45,38,28} },
            { model = 500, name = "Mesa",       color = {30,28,20} },
            { model = 482, name = "Burrito",    color = {38,34,24} }, -- van
            { model = 413, name = "Pony",       color = {36,32,22} },
        },
        skins = { 28, 29, 30, 264 },
        activity = "cartel",
    },

    [3] = {
        id = 3,
        key = "yakuza",
        name = { ar="الياكوزا", en="Yakuza", pt="Yakuza" },
        identity = { ar="عصابة منظمة", en="Organized Syndicate", pt="Sindicato Organizado" },
        color = { 180, 40, 60 },
        blip = 52,
        -- Anchor: hotel_tenemant1 (comnbtm.map) -1286.62,1299.61,37.207 (discreet/urban building)
        hq = {
            label = { ar="مقر الياكوزا", en="Yakuza Hideout", pt="Refúgio Yakuza" },
            exterior = { x = -1286.6, y = 1294.0, z = 17.2, rot = 0, int = 0, dim = 0 }, -- VERIFY IN-GAME
            interior = { x = 2997.58, y = 3005.75, z = 499.5, rot = 90, int = 0, dim = 30003 }, -- VERIFY
            rooms = { "entrance","meeting","office","vault","warehouse","garage_access" },
            anchorBuilding = "hotel_tenemant1 (comnbtm)",
        },
        garage = {
            spawn = { x = -1294.0, y = 1294.0, z = 17.2, rz = 180 }, -- VERIFY IN-GAME
            park  = { x = -1294.0, y = 1294.0, z = 16.8, r = 4.0 },
            capacity = 10,
        },
        vehicles = {
            { model = 560, name = "Sultan",     color = {18,18,22} },
            { model = 562, name = "Elegy",      color = {20,20,24} },
            { model = 451, name = "Turismo",    color = {30,20,20} },
            { model = 561, name = "Stratum",    color = {15,15,18} },
            { model = 558, name = "Uranus",     color = {25,20,28} },
            { model = 409, name = "Stretch",    color = {10,10,12} },
        },
        skins = { 120, 122, 117, 118 },
        activity = "yakuza",
    },

    [4] = {
        id = 4,
        key = "bikers",
        name = { ar="عصابة الدراجات", en="Bikers MC", pt="Motoqueiros MC" },
        identity = { ar="نادي دراجات", en="Biker Club", pt="Clube de Motoqueiros" },
        color = { 120, 120, 130 },
        blip = 55,
        -- Anchor: garage_kb (comnbtm.map) -1089.446,1001.853,28.5916 (garage building)
        hq = {
            label = { ar="مرآب الدراجات", en="Bikers Garage", pt="Garagem dos Motoqueiros" },
            exterior = { x = -1089.4, y = 1008.0, z = 25.1, rot = 0, int = 0, dim = 0 }, -- VERIFY IN-GAME
            interior = { x = 2997.58, y = 3005.75, z = 499.5, rot = 90, int = 0, dim = 30004 }, -- VERIFY
            rooms = { "entrance","meeting","office","vault","warehouse","garage_access" },
            anchorBuilding = "garage_kb (comnbtm)",
        },
        garage = {
            spawn = { x = -1096.0, y = 1008.0, z = 25.1, rz = 270 }, -- VERIFY IN-GAME
            park  = { x = -1096.0, y = 1008.0, z = 24.7, r = 4.5 },
            capacity = 14,
        },
        vehicles = {
            { model = 463, name = "Freeway",    color = {30,30,30} }, -- bikes
            { model = 468, name = "Sanchez",    color = {40,35,30} },
            { model = 471, name = "Quad",       color = {35,35,35} },
            { model = 521, name = "FCR-900",    color = {20,20,20} },
            { model = 522, name = "NRG-500",    color = {15,15,15} },
            { model = 461, name = "PCJ-600",    color = {25,25,25} },
            { model = 536, name = "Blade",      color = {28,28,28} }, -- muscle
            { model = 534, name = "Remington",  color = {32,28,24} },
        },
        skins = { 100, 247, 248, 254 },
        activity = "bikers",
    },

    [5] = {
        id = 5,
        key = "street",
        name = { ar="عصابة الشوارع", en="Street Gang", pt="Gangue de Rua" },
        identity = { ar="عصابة شوارع", en="Street Gang", pt="Gangue de Rua" },
        color = { 60, 170, 90 },
        blip = 56,
        -- Anchor: warehouse1z4 (comntop.map) -1216.63,2028.77,13.9773 (warehouse/hideout)
        hq = {
            label = { ar="مخبأ العصابة", en="Street Hideout", pt="Esconderijo da Gangue" },
            exterior = { x = -1216.6, y = 2022.0, z = 14.0, rot = 180, int = 0, dim = 0 }, -- VERIFY IN-GAME
            interior = { x = 2997.58, y = 3005.75, z = 499.5, rot = 90, int = 0, dim = 30005 }, -- VERIFY
            rooms = { "entrance","meeting","office","vault","warehouse","garage_access" },
            anchorBuilding = "warehouse1z4 (comntop)",
        },
        garage = {
            spawn = { x = -1208.0, y = 2022.0, z = 14.0, rz = 90 }, -- VERIFY IN-GAME
            park  = { x = -1208.0, y = 2022.0, z = 13.6, r = 4.5 },
            capacity = 12,
        },
        vehicles = {
            { model = 536, name = "Blade",      color = {20,60,30} }, -- modded/street feel
            { model = 562, name = "Elegy",      color = {25,70,35} },
            { model = 558, name = "Uranus",     color = {30,80,40} },
            { model = 567, name = "Savanna",    color = {30,90,45} },
            { model = 575, name = "Broadway",   color = {25,75,35} },
            { model = 565, name = "Flash",      color = {20,65,30} },
        },
        skins = { 105, 106, 107, 102 },
        activity = "street",
    },

    [6] = {
        id = 6,
        key = "russian",
        name = { ar="المافيا الروسية", en="Russian Mafia", pt="Máfia Russa" },
        identity = { ar="مافيا روسية", en="Russian Mafia", pt="Máfia Russa" },
        color = { 160, 60, 60 },
        blip = 57,
        -- Anchor: warehouse1z2 (comntop.map) -1177.48,2034.35,13.977 (industrial building)
        hq = {
            label = { ar="مقر المافيا الروسية", en="Russian HQ", pt="QG Russo" },
            exterior = { x = -1177.5, y = 2027.0, z = 14.0, rot = 0, int = 0, dim = 0 }, -- VERIFY IN-GAME
            interior = { x = 2997.58, y = 3005.75, z = 499.5, rot = 90, int = 0, dim = 30006 }, -- VERIFY
            rooms = { "entrance","meeting","office","vault","warehouse","garage_access" },
            anchorBuilding = "warehouse1z2 (comntop)",
        },
        garage = {
            spawn = { x = -1168.0, y = 2027.0, z = 14.0, rz = 270 }, -- VERIFY IN-GAME
            park  = { x = -1168.0, y = 2027.0, z = 13.6, r = 4.5 },
            capacity = 12,
        },
        vehicles = {
            { model = 579, name = "Huntley",    color = {40,20,20} }, -- SUV
            { model = 490, name = "FBI Rancher",color = {30,18,18} },
            { model = 426, name = "Premier",    color = {35,20,20} },
            { model = 466, name = "Glendale",   color = {45,22,22} },
            { model = 507, name = "Elegant",    color = {38,20,20} },
            { model = 525, name = "Towtruck",   color = {50,30,30} },
        },
        skins = { 111, 112, 113, 272 },
        activity = "russian",
    },
}

-- Initial territory seeds (Liberty City districts/areas). Real capture logic is server-validated.
LCG.territories = {
    { id = 1, key="chinatown",      name={ar="تشايناتاون",en="Chinatown",pt="Chinatown"},         x=-330.0,  y=1145.0, z=14.0,  radius=120.0, owner=nil },
    { id = 2, key="dukes_docks",    name={ar="أرصفة دوكس",en="Dukes Docks",pt="Docas de Dukes"},   x=-900.0,  y=500.0,  z=14.0,  radius=180.0, owner=nil },
    { id = 3, key="broker_market",  name={ar="سوق بروكر",en="Broker Market",pt="Mercado de Broker"}, x=-1355.0, y=1280.0, z=18.7,  radius=140.0, owner=nil },
    { id = 4, key="bohan_ind",      name={ar="صناعية بوهان",en="Bohan Industrial",pt="Industrial de Bohan"}, x=-1220.0, y=440.0,  z=26.9,  radius=160.0, owner=nil },
    { id = 5, key="algonquin_n",    name={ar="شمال ألغونكوين",en="North Algonquin",pt="Norte de Algonquin"}, x=-1100.0, y=1600.0, z=20.0,  radius=180.0, owner=nil },
    { id = 6, key="comntop_yards",  name={ar="ساحات كومنتوب",en="Comntop Yards",pt="Pátios Comntop"}, x=-1185.0, y=2010.0, z=14.0,  radius=150.0, owner=nil },
}

-- Warehouse: allowed item keys (must exist in ng-inventory / server logic)
LCG.warehouseAllowed = {
    "burger","pizza","water","soda","medkit","repairkit","phone","radio","fuelcan",
    "weapon_pistol","weapon_deagle","weapon_shotgun","weapon_ak",
}

-- Helper
function LCG.getFaction(id)
    id = tonumber(id)
    return id and LCG.factions[id] or nil
end

function LCG.getFactionByKey(key)
    for _, f in pairs(LCG.factions) do
        if f.key == key then return f end
    end
    return nil
end

function LCG.hasPerm(rank, perm)
    local need = LCG.rankPerms[perm]
    if not need then return false end
    return (tonumber(rank) or 0) >= need
end
