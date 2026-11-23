--[[ ============================================================
     lc_premium_interiors / config.lua
     Luxury GTA V-style shops, precinct, workshop and public gym
     for Liberty City Roleplay.

     All geometry is loaded into custom object model IDs and created
     ONLY inside private dimensions with interior 0. The exterior
     Liberty City world and all existing systems are never modified.
     No CEF. No stock model replacement. No eagleZones.txt.
     ============================================================ ]]

LPI = {
    version    = "1.0.0",
    fade       = 350,
    doorRange  = 4.5,
    exitRange  = 3.2,

    -- Private dimensions. None of these are used by other resources.
    dims = {
        shop     = 22000,   -- venue 1 -> 22001
        police   = 23000,   -- venue 2 -> 23001
        mechanic = 24000,   -- venue 3 -> 24001
        gym      = 25000,   -- venue 4 -> 25001
        measure  = 31991,   -- temporary invisible-floor measurement only
    },

    -- Real converted DFF/TXD/COL assets. Several DFF files share one TXD.
    -- Source and author credits are in README.md.
    assets = {
        otakushop = { dff = "models/Otakushop.dff", txd = "models/Otakushop.txd", col = "models/Otakushop.col" },
        otaku1    = { dff = "models/Otaku1.dff",    txd = "models/Otakushop.txd" },
        otaku2    = { dff = "models/Otaku2.dff",    txd = "models/Otakushop.txd" },
        otaku3    = { dff = "models/Otaku3.dff",    txd = "models/Otakushop.txd" },
        otaku4    = { dff = "models/Otaku4.dff",    txd = "models/Otakushop.txd" },

        apt_shell = { dff = "models/apt_mp_shell.dff", txd = "models/apt_mp_mod.txd", col = "models/apt_mp_shell.col" },
        apt_int   = { dff = "models/apt_mp_int.dff",   txd = "models/apt_mp_int.txd",   col = "models/apt_mp_int.col" },
        apt_props = { dff = "models/apt_mp_props.dff", txd = "models/apt_mp_props.txd", col = "models/apt_mp_props.col" },

        mech_outer = { dff = "models/mech_outer.dff", txd = "models/mech.txd", col = "models/mech.col" },
        mech_door  = { dff = "models/mech_door.dff",  txd = "models/mech.txd" },

        gym_hall  = { dff = "models/gym_hall.dff", txd = "models/gym_hall.txd", col = "models/gym_hall.col" },
    },

    -- Every room lives on a remote stage in its own private dimension.
    -- spawn/exit/floor coordinates are LOCAL to that stage and are rotated
    -- by rotZ with the same transform used for the DFF objects.
    venues = {
        [1] = {
            key = "boutique", type = "shop", name = "GTA V Boutique 24/7",
            door = { x = -1181.79, y = 540.60, z = 30.75, rot = 180 },
            dim = 22001, interior = 0, rotZ = 0,
            stage = { x = 4000, y = 4000, z = 500 },
            spawn = { x = -10.2, y = 9.0,  z = -0.9 },
            exit  = { x = -10.2, y = 5.6,  z = -0.9 },
            floor = { centerX = -10.2, centerY = 10.7, topZ = -1.9, sizeX = 20, sizeY = 15, thickness = 0.4 },
            assets = { "otakushop", "otaku1", "otaku2", "otaku3", "otaku4" },
        },
        [2] = {
            key = "precinct", type = "police", name = "LCPD Premier Precinct",
            door = { x = -2623.62, y = 1765.98, z = 57.95, rot = 90 },
            dim = 23001, interior = 0, rotZ = 87.00007855374548,
            stage = { x = 4100, y = 4100, z = 500 },
            -- Inverse of the verified luxury_houses teleport
            -- (2997.58,3005.75,499.5) relative to origin 3000,3000,500.
            spawn = { x = 5.62, y = 2.72, z = -0.5 },
            exit  = { x = 5.62, y = 2.72, z = -0.5 },
            floor = { centerX = 0, centerY = 2.4, topZ = -1.8, sizeX = 28, sizeY = 46, thickness = 0.45 },
            assets = { "apt_shell", "apt_int", "apt_props" },
        },
        [3] = {
            key = "workshop", type = "mechanic", name = "Premium Motorsport Workshop",
            door = { x = -158.46, y = 933.95, z = 13.82, rot = 270 },
            dim = 24001, interior = 0, rotZ = 0,
            stage = { x = 4200, y = 4200, z = 500 },
            spawn = { x = 0, y = -10.0, z = -3.5 },
            exit  = { x = 0, y = -14.0, z = -3.5 },
            floor = { centerX = 0, centerY = 0, topZ = -4.85, sizeX = 70, sizeY = 32, thickness = 0.5 },
            assets = { "mech_outer", "mech_door" },
        },
        [4] = {
            key = "sports", type = "gym", name = "Liberty Sports Hall",
            -- comsw.map places gym_treadmill at -1260.449,224.423;
            -- this door is on the same LC gym block at verified street z.
            door = { x = -1245.00, y = 200.00, z = 30.16, rot = 90 },
            dim = 25001, interior = 0, rotZ = 0,
            stage = { x = 4300, y = 4300, z = 500 },
            spawn = { x = 0, y = -16.0, z = -1.3 },
            exit  = { x = 0, y = -18.5, z = -1.3 },
            floor = { centerX = 0, centerY = 0, topZ = -2.3, sizeX = 32, sizeY = 42, thickness = 0.4 },
            assets = { "gym_hall" },
        },

        -- =====================================================================
        -- SHOP EXPANSION (2026-11-20)
        -- Every door below is an EXACT <building> position taken from the
        -- installed LC .map files, cross-checked against same-level ground
        -- objects in the same file. Interior geometry lives ONLY in the
        -- private dimension/stage listed here - NOTHING is created in the
        -- exterior world (dimension 0), so Liberty City is never altered.
        -- All six reuse the verified boutique assets/spawn/floor layout.
        -- =====================================================================
        [5] = {
            key = "shops2", type = "shop", name = "West Commerce Boutique",
            -- comsw.map <building id="block3_shops2"> x=-1508.13 y=345.1 z=29.0372
            door = { x = -1508.13, y = 345.10, z = 29.04, rot = 0 },
            dim = 26001, interior = 0, rotZ = 0,
            stage = { x = 4400, y = 4400, z = 500 },
            spawn = { x = -10.2, y = 9.0,  z = -0.9 },
            exit  = { x = -10.2, y = 5.6,  z = -0.9 },
            floor = { centerX = -10.2, centerY = 10.7, topZ = -1.9, sizeX = 20, sizeY = 15, thickness = 0.4 },
            assets = { "otakushop", "otaku1", "otaku2", "otaku3", "otaku4" },
        },
        [6] = {
            key = "shops5", type = "shop", name = "Commerce South Boutique",
            -- comsw.map <building id="block3_shops5"> x=-1328.25 y=260.5 z=28.9039
            door = { x = -1328.25, y = 260.50, z = 28.90, rot = 0 },
            dim = 27001, interior = 0, rotZ = 0,
            stage = { x = 4500, y = 4500, z = 500 },
            spawn = { x = -10.2, y = 9.0,  z = -0.9 },
            exit  = { x = -10.2, y = 5.6,  z = -0.9 },
            floor = { centerX = -10.2, centerY = 10.7, topZ = -1.9, sizeX = 20, sizeY = 15, thickness = 0.4 },
            assets = { "otakushop", "otaku1", "otaku2", "otaku3", "otaku4" },
        },
        [7] = {
            key = "cafe", type = "shop", name = "Downtown Cafe & Store",
            -- comsw.map <building id="tw@t_cafe"> x=-1182 y=798.85 z=26.0059 rotZ=-90
            door = { x = -1182.00, y = 798.85, z = 26.01, rot = -90 },
            dim = 28001, interior = 0, rotZ = 0,
            stage = { x = 4600, y = 4600, z = 500 },
            spawn = { x = -10.2, y = 9.0,  z = -0.9 },
            exit  = { x = -10.2, y = 5.6,  z = -0.9 },
            floor = { centerX = -10.2, centerY = 10.7, topZ = -1.9, sizeX = 20, sizeY = 15, thickness = 0.4 },
            assets = { "otakushop", "otaku1", "otaku2", "otaku3", "otaku4" },
        },
        [8] = {
            key = "mall", type = "shop", name = "Central Mall Store",
            -- comnbtm.map <building id="mallground02"> x=-1163.18 y=1143.57 z=25.1266
            door = { x = -1163.18, y = 1143.57, z = 25.13, rot = 0 },
            dim = 29001, interior = 0, rotZ = 0,
            stage = { x = 4700, y = 4700, z = 500 },
            spawn = { x = -10.2, y = 9.0,  z = -0.9 },
            exit  = { x = -10.2, y = 5.6,  z = -0.9 },
            floor = { centerX = -10.2, centerY = 10.7, topZ = -1.9, sizeX = 20, sizeY = 15, thickness = 0.4 },
            assets = { "otakushop", "otaku1", "otaku2", "otaku3", "otaku4" },
        },
        [9] = {
            key = "shopbit", type = "shop", name = "Commerce Corner Store",
            -- comsw.map <building id="shop_bit"> x=-1436.55 y=296.64 z=25.0993
            door = { x = -1436.55, y = 296.64, z = 25.10, rot = 0 },
            dim = 30001, interior = 0, rotZ = 0,
            stage = { x = 4800, y = 4800, z = 500 },
            spawn = { x = -10.2, y = 9.0,  z = -0.9 },
            exit  = { x = -10.2, y = 5.6,  z = -0.9 },
            floor = { centerX = -10.2, centerY = 10.7, topZ = -1.9, sizeX = 20, sizeY = 15, thickness = 0.4 },
            assets = { "otakushop", "otaku1", "otaku2", "otaku3", "otaku4" },
        },
        [10] = {
            key = "news", type = "shop", name = "South Market News",
            -- comsw.map <building id="newsstand1"> x=-1296.86 y=232.24 z=25.9099
            door = { x = -1296.86, y = 232.24, z = 25.91, rot = 0 },
            dim = 31001, interior = 0, rotZ = 0,
            stage = { x = 4900, y = 4900, z = 500 },
            spawn = { x = -10.2, y = 9.0,  z = -0.9 },
            exit  = { x = -10.2, y = 5.6,  z = -0.9 },
            floor = { centerX = -10.2, centerY = 10.7, topZ = -1.9, sizeX = 20, sizeY = 15, thickness = 0.4 },
            assets = { "otakushop", "otaku1", "otaku2", "otaku3", "otaku4" },
        },
    },

    -- Server-authoritative shop catalogue (mirrors ng-shops prices/items).
    shopItems = {
        { key = "burger",   name = "Burger",   price = 12 },
        { key = "water",    name = "Water",    price = 5 },
        { key = "phone",    name = "Phone",    price = 350 },
        { key = "backpack", name = "Backpack", price = 250 },
    },

    -- Real HD outfit model IDs from ng-characters / ng-shops.
    outfitPrice = 500,
    skins = {
        male = {
            [14] = "BOPE HD", [15] = "SAMU ByOutfit HD", [18] = "ByRupra HD",
            [19] = "Transito HD", [20] = "Mechanic HD", [21] = "SAMU By7capa HD",
            [22] = "Business Male HD", [23] = "Pulaski HD", [24] = "RED HD",
            [25] = "GHOST DZ Blue HD", [26] = "ByKAZIDE HD", [27] = "ByBeyBy HD",
            [30] = "Bloods HD", [32] = "PMES HD", [33] = "Mafia ByCostela HD",
            [37] = "Handsome Male HD", [43] = "Mafia Male HD", [44] = "Crips HD",
            [45] = "Business Male v2 HD", [46] = "Mafia Random HD", [51] = "LCPD Cadet HD",
            [52] = "LCPD Patrol HD", [60] = "Skin 60 HD",
            [252] = "Karakter 252 HD", [274] = "Male Surgeon HD",
        },
        female = {
            [9] = "Female Surgeon HD", [10] = "COT PF HD", [11] = "K-Camuflada HD",
            [12] = "Random Girl v2 HD", [13] = "Roleplay Girl HD", [31] = "TDT HD",
            [38] = "La Casa de Papel HD", [39] = "LCPD Officer F2 HD", [40] = "Roleplay Girl v2 HD",
            [41] = "Brasil HD", [53] = "Pijama HD", [54] = "BySampaio HD",
            [55] = "LCPD Officer F1 HD", [56] = "Tattooed Girl HD", [88] = "Tourist Girl HD",
            [93] = "Kaine Goth HD",
        },
    },

    gym = {
        heal = 100,
        armor = 60,
        cooldown = 15000,
    },
}

-- Convert a stage-local point into world coordinates.
function LPI.stagePoint(v, lx, ly, lz)
    local st = v and v.stage or {}
    local rot = math.rad(tonumber(v and v.rotZ) or 0)
    local c, s = math.cos(rot), math.sin(rot)
    return (tonumber(st.x) or 0) + lx * c - ly * s,
           (tonumber(st.y) or 0) + lx * s + ly * c,
           (tonumber(st.z) or 0) + (tonumber(lz) or 0)
end
