--[[ ============================================================
     luxury_houses / config.lua  ("PREMIUM REAL ESTATE & INTERIOR SYSTEM")
     gta4gg - Liberty City Roleplay

     Adding a new house = append one table to LH.properties.
     Nothing else needs to be touched: markers, dimension, interior
     shell, exit point, ownership, keys, storage, garage and the
     premium UI are all generated from this file.

     2026-11-19 FIX (final): the old object shells (sweetsmain, BDups
     furniture, exterior warehouses...) were partial/open meshes and
     produced the holes/gaps players reported. Every property now uses a
     REAL GTA V Online "Eclipse Tower" apartment: original converted
     DFF/TXD/COL assets loaded by the client and instantiated ONLY in
     that property's private dimension (21000 + id), interior 0.
     The exterior Liberty City map/world is never touched. The old
     "shell" ids are kept only for historical DB rows.
     x/y/z   : the exterior door position in Liberty City (verified
               ground coordinates - all taken from live walkable spots
               or the original LC interior street doors).
     interior: index into LH.interiors below (the real enterable room).
     rot     : facing of the player when leaving the house.
     price   : bank price.  rent : optional 24h rent price (0 = no rent)
     capacity: storage slots (warehouses) / garage slots (garages).
   ============================================================ ]]

LH = {
    version   = "2.0.0",
    dimBase   = 21000,     -- property dimensions 21000 + id
    maxOwned  = 3,         -- max properties per character
    sellRatio = 0.70,      -- sell back to bank = 70% of price
    keyLimit  = 8,         -- max keys per property

    -- legacy anchor, kept only so old furniture rows can be re-based once
    shellX = 3000.0,
    shellY = 3000.0,
    shellZ = 500.0,

    -- ================ GTA V ECLIPSE TOWER APARTMENT ================
    -- Original converted GTA V Online assets (DFF/TXD/COL) are loaded by
    -- client.lua and instantiated ONLY inside the private property dimension.
    -- Interior 0 is used: no stock SA interior world is touched.
    gtav = {
        originX = 3000.0,
        originY = 3000.0,
        originZ = 500.0,
        rotZ    = 87.00007855374548,

        -- decoded from the original CLEO teleport, relative to the object origin
        spawnX  = 2997.58,
        spawnY  = 3005.75,
        spawnZ  = 499.5,

        -- invisible safety floor (top surface) below the modelled floor
        floorTopZ      = -1.80,
        floorCenterY   =  2.40,
        floorSizeX     = 28.0,
        floorSizeY     = 46.0,
        floorThickness =  0.45,
        safetyRadius   = 45.0,
    },

    -- Every property uses this one sealed GTA V apartment interior.
    -- Interior 0 + dimension 21000 + id isolates it from the LC exterior.
    interiors = {
        [1] = {
            interior = 0,
            x = 2997.58, y = 3005.75, z = 499.5, rot = 90,
            name = "Eclipse Tower Luxury Interior",
        },
    },

    -- admin-created doors also use the same verified room
    interiorByType = {
        house     = { 1 },
        villa     = { 1 },
        mansion   = { 1 },
        penthouse = { 1 },
        warehouse = { 1 },
        garage    = { 1 },
        depot     = { 1 },
    },

    doorRange = 3.2,       -- metres to see PRESS E at a door
    exitRange = 2.8,
    fadeTime  = 350,

    -- =====================================================================
    -- ONE-HOUSE ANIMATED DOOR DEMO (2026-11-20)
    -- The exterior LC map ALREADY contains the real door object at the
    -- Chinatown property entrance:
    --   LC/zones/industsw/industsw.map:865
    --   <object id="Gen_doorSHOP3" posX="-313.879" posY="1146.152"
    --           posZ="14.007" rotZ="89.999771940814">
    -- Its model is 1522 (SHOP_doors2, physics-tagged), so eagleLoader keeps
    -- it as a real client-side object element. We animate THAT existing
    -- element with moveObject. Nothing is added to dimension 0, no .map file
    -- is edited, and no other property is affected by this demo.
    -- =====================================================================
    demoDoor = {
        propKey   = "chinatown_res",
        model     = 1522,
        x = -313.879, y = 1146.152, z = 14.007,
        rotZ      = 89.999771940814,
        openAngle = -85,     -- degrees added to rotZ when the door swings open
        animTime  = 800,     -- ms for the swing
        holdTime  = 2200,    -- ms before the door swings closed again
    },

    properties = {
        { key = "chinatown_res",  name = "Chinatown Luxury Residence",
          ptype = "house",     district = "Chinatown",
          x = -313.88, y = 1146.15, z = 14.01, rot = 90,
          interior = 1, shell = 14526, price = 85000,  rent = 2500, capacity = 0,
          desc = "Private townhouse in the heart of Chinatown. Complete solid interior with marble halls, warm lighting, full living room and bedroom." },

        { key = "downtown_pent",  name = "Downtown Glass Penthouse",
          ptype = "penthouse", district = "Algonquin",
          x = -1110.24, y = 1035.08, z = 25.03, rot = -116,
          interior = 1, shell = 14506, price = 250000, rent = 0, capacity = 0,
          desc = "Top-floor penthouse above the downtown strip. Sealed luxury interior with panoramic windows, lounge, wet bar and king bedroom." },

        { key = "vinewood_villa", name = "Vinewood Hills Glass Villa",
          ptype = "villa",     district = "Algonquin Hills",
          x = -1232.27, y = 685.54, z = 25.14, rot = -26,
          interior = 1, shell = 14758, price = 400000, rent = 0, capacity = 0,
          desc = "Modern glass villa with a complete open-plan interior, designer furniture and a private garden view." },

        { key = "starjunction_mansion", name = "Star Junction VIP Mansion",
          ptype = "mansion",   district = "Star Junction",
          x = -1326.25, y = 726.50, z = 25.15, rot = -90,
          interior = 1, shell = 11085, price = 750000, rent = 0, capacity = 0,
          desc = "The crown of Liberty City: a fully enclosed gold-and-marble VIP palace with multiple halls and a private bar." },

        { key = "bohan_beach",    name = "Bohan Beachfront Villa",
          ptype = "villa",     district = "Bohan",
          x = -438.04, y = 993.90, z = 14.04, rot = -45,
          interior = 1, shell = 14735, price = 320000, rent = 0, capacity = 0,
          desc = "Beachfront villa steps from the water. Solid sun-lit rooms, open kitchen and a relaxing lounge." },

        { key = "shoreside_estate", name = "Shoreside Coastal Estate",
          ptype = "mansion",   district = "Shoreside Vale",
          x = -2432.32, y = 1858.68, z = 59.57, rot = -90,
          interior = 1, shell = 14802, price = 600000, rent = 0, capacity = 0,
          desc = "Gated coastal estate with a complete executive interior, private driveway, huge living room, office and guest wing." },

        { key = "docks_warehouse", name = "Docks Storage Warehouse",
          ptype = "warehouse", district = "Dukes Docks",
          x = -886.33, y = 385.84, z = 25.10, rot = 135,
          interior = 1, shell = 14784, price = 150000, rent = 6000, capacity = 120,
          desc = "Enclosed industrial warehouse at the docks. 120 storage slots for goods, weapons crates and vehicles parts." },

        { key = "bohan_warehouse", name = "Bohan Industrial Warehouse",
          ptype = "warehouse", district = "Bohan Industrial",
          x = -1436.05, y = 1314.85, z = 15.15, rot = 90,
          interior = 1, shell = 10844, price = 220000, rent = 8000, capacity = 80,
          desc = "Medium enclosed industrial unit with loading bay. 80 storage slots, ideal for a growing business." },

        { key = "broker_depot",   name = "Broker Storage Depot",
          ptype = "warehouse", district = "Broker",
          x = -1246.20, y = 1317.25, z = 14.86, rot = 180,
          interior = 1, shell = 10845, price = 95000,  rent = 4500, capacity = 40,
          desc = "Small secure enclosed depot in Broker. 40 storage slots, low upkeep - perfect first business." },

        { key = "chinatown_garage", name = "Chinatown Private Garage",
          ptype = "garage",    district = "Chinatown",
          x = -1293.15, y = 1423.04, z = 17.20, rot = 0,
          interior = 1, shell = 14798, price = 60000,  rent = 2000, capacity = 2,
          desc = "Two-car private garage inside a sealed secure depot. Park owned vehicles and retrieve them any time." },

        -- NOTE 2026-11-18: "Algonquin Garage Loft" was removed. Its coordinates
        -- (-975.60, 1104.90) were the LUXURY TUNING workshop spot, so the gold
        -- property marker sat exactly on top of the tuning garage marker/blip.
        -- A property must never share a door with another system.
        -- It will come back through /lhaddprop on a real garage door.

        { key = "dukes_family",   name = "Dukes Modern Family House",
          ptype = "house",     district = "Dukes",
          x = -1092.83, y = 1066.82, z = 25.11, rot = -116,
          interior = 1, shell = 14805, price = 120000, rent = 3500, capacity = 0,
          desc = "Modern family home with a complete living room, kitchen, kids room and a cosy sitting area." },
    },

    -- ================= FURNITURE CATALOG =================
    -- owner buys furniture from the bank and places it inside his
    -- property.  Prices are bank prices (GTA V style economy).
    furniture = {
        { model = 1753, name = "Swank Couch",        price = 2400  },
        { model = 1761, name = "Swank Couch 2",      price = 2600  },
        { model = 1763, name = "Low Couch",          price = 1500  },
        { model = 1766, name = "Medium Couch",       price = 1900  },
        { model = 2290, name = "Designer Sofa",      price = 3200  },
        { model = 1798, name = "Swank Bed",          price = 4200  },
        { model = 1795, name = "Swank Bed 2",        price = 4400  },
        { model = 1745, name = "Medium Bed",         price = 2600  },
        { model = 1752, name = "Swank TV",           price = 3800  },
        { model = 1786, name = "Swank TV 2",         price = 4200  },
        { model = 1781, name = "Medium TV",          price = 2000  },
        { model = 14629, name = "Chandelier",        price = 6000  },
        { model = 14413, name = "Marble Column",     price = 5200  },
        { model = 14445, name = "Marble Column 2",   price = 5200  },
        { model = 8397,  name = "Luxor Pillar",      price = 4800  },
        { model = 2815,  name = "Living Room Rug",   price = 1400  },
        { model = 2817,  name = "Bedroom Rug",       price = 1200  },
        { model = 2726,  name = "Strip Lamp",        price = 900   },
        { model = 2964,  name = "Pool Table",        price = 7500  },
        { model = 18090, name = "Bar Counter",       price = 8800  },
        { model = 2516,  name = "Bath",              price = 2200  },
        { model = 10619, name = "Office Mirror",     price = 1600  },
        { model = 14580, name = "Gold Ornament",     price = 12500 },
        { model = 14621, name = "Casino Glass Wall", price = 7200  },
        { model = 1369,  name = "Potted Plant",      price = 700   },
        { model = 14415, name = "Marble Floor Slab", price = 3000  },
    },

    -- warehouse stock items that can always be withdrawn even if the
    -- player inventory has no such item (pure warehouse goods)
    storageGoods = {
        "burger", "water", "soda", "pizza", "medkit", "repairkit",
        "fuelcan", "phone", "radio", "weapon_pistol",
    },
}
