--[[
    lmb_police / config.lua  (shared: server + client)
    ------------------------------------------------------------------
    LmB ROLEPLAY  -  LIBERTY CITY POLICE DEPARTMENT  ("LCPD")
    Single source of truth for ranks, permissions, uniforms, fleet,
    armory, station geometry and the luxury UI palette.

    Nothing in here is trusted by the server: the server re-reads this
    table for every permission check. The client only uses the copy for
    labels/lock states (the server always validates again).
    ------------------------------------------------------------------
]]

PD = PD or {}

PD.name        = "LmB Police Department"
PD.short       = "LCPD"
PD.tag         = "LCPD"
PD.version     = "1.0.0"
PD.job         = "police"
-- 2026-11-22 OPEN-WORLD HQ:
-- The LCPD now uses a real walk-in annex attached to the south face of the
-- Liberty City "police_station_ind" building. No private dimension, no
-- teleport, no interior 6. Everything is dimension 0 / interior 0 so it is
-- part of the normal world and visible from the street.
PD.dim         = 0
PD.interior    = 0
PD.maxPerPlayer = 4               -- only 4 collision-stable bays exist on this map
PD.maxGlobalPerModel = 8          -- global cap per model; only LCPD-owned cars count
PD.vehicleLifetime = 45 * 60 * 1000 -- auto-return after 45 min
PD.jailDim     = 41000            -- same dimension ng-rp jail already uses

-- ============================================================
-- RANKS (9)  -  id = authority level (higher = more power)
-- ============================================================
PD.ranks = {
    { id = 1, key = "cadet",    name = "Cadet",          short = "CDT", pay = 900,  badge = "C",  color = {196, 168, 108} },
    { id = 2, key = "officer",  name = "Officer",        short = "OFC", pay = 1200, badge = "O",  color = {206, 180, 118} },
    { id = 3, key = "senior",   name = "Senior Officer", short = "SOF", pay = 1500, badge = "SO", color = {214, 188, 124} },
    { id = 4, key = "corporal", name = "Corporal",       short = "CPL", pay = 1800, badge = "CP", color = {222, 196, 132} },
    { id = 5, key = "sergeant", name = "Sergeant",       short = "SGT", pay = 2200, badge = "SG", color = {228, 202, 140} },
    { id = 6, key = "lieutenant", name = "Lieutenant",   short = "LT",  pay = 2700, badge = "LT", color = {234, 210, 152} },
    { id = 7, key = "captain",  name = "Captain",        short = "CPT", pay = 3300, badge = "CPT", color = {238, 216, 160} },
    { id = 8, key = "deputy",   name = "Deputy Chief",   short = "DC",  pay = 4000, badge = "DC", color = {242, 222, 172} },
    { id = 9, key = "chief",    name = "Chief of Police", short = "CHIEF", pay = 5000, badge = "CH", color = {248, 230, 190} },
}

PD.rankById = {}
PD.rankByKey = {}
for _, r in ipairs(PD.ranks) do
    PD.rankById[r.id] = r
    PD.rankByKey[r.key] = r
end

function PD.rankName(id)
    local r = PD.rankById[tonumber(id) or 0]
    return r and r.name or "Civilian"
end

-- ============================================================
-- PERMISSIONS  (minimum rank required)
-- The server is the only place these are enforced.
-- ============================================================
PD.minRank = {
    patrol        = 1,
    cuff          = 1,
    idcheck       = 1,
    vehcheck      = 1,
    radio         = 1,
    garage        = 1,
    armory        = 1,
    arrest        = 2,
    fine          = 2,
    wanted        = 2,
    search        = 2,
    mdt           = 2,
    taser         = 3,
    radioNet      = 3,   -- can create/close calls
    mdtFull       = 4,   -- full record history + notes
    dispatch      = 4,   -- dispatch board control
    impound       = 5,
    reviewApps    = 7,
    hire          = 7,
    promote       = 8,
    fire          = 8,
    setBadge      = 8,
    command       = 7,
}

-- permission label used by the "Ranks" page
PD.permLabels = {
    { key = "patrol",     label = "Patrol & traffic stops" },
    { key = "cuff",       label = "Handcuffs" },
    { key = "arrest",     label = "Arrest & process" },
    { key = "fine",       label = "Issue fines" },
    { key = "wanted",     label = "Wanted level control" },
    { key = "search",     label = "Search citizens / vehicles" },
    { key = "mdt",        label = "MDT access" },
    { key = "taser",      label = "Taser X26" },
    { key = "dispatch",   label = "Dispatch board" },
    { key = "reviewApps", label = "Review applications" },
    { key = "hire",       label = "Hire officers" },
    { key = "promote",    label = "Promote / demote" },
    { key = "fire",       label = "Terminate officers" },
    { key = "command",    label = "Command authority" },
}

-- ============================================================
-- UNIFORMS  (stock SA ped skins: 280-311 are the police models)
-- ============================================================
PD.uniforms = {
    { key = "cadet",     name = "Cadet Uniform",        minRank = 1, male = 300, female = 306,
      desc = "Academy issue. No holster, no badge." },
    { key = "patrol",    name = "Patrol Uniform",       minRank = 1, male = 280, female = 306,
      desc = "Standard LCPD street uniform." },
    { key = "senior",    name = "Senior Patrol",        minRank = 3, male = 281, female = 307,
      desc = "Deep-blue senior patrol kit." },
    { key = "corporal",  name = "Corporal / Traffic",   minRank = 4, male = 283, female = 310,
      desc = "High-visibility traffic detail." },
    { key = "undercover", name = "Undercover",          minRank = 4, male = 303, female = 306,
      desc = "Plain clothes. Badge stays in the pocket." },
    { key = "detective", name = "Detective",            minRank = 4, male = 286, female = 306,
      desc = "Dark suit, gold shield." },
    { key = "sergeant",  name = "Sergeant / Motors",    minRank = 5, male = 284, female = 306,
      desc = "Motor unit leathers and helmet." },
    { key = "tactical",  name = "Tactical Response",    minRank = 6, male = 285, female = 306,
      desc = "Black tactical rig, no heavy plate." },
    { key = "swat",      name = "SWAT Operator",        minRank = 6, male = 285, female = 306,
      desc = "Full SWAT loadout. Command authorisation." },
    { key = "lieutenant", name = "Lieutenant",          minRank = 6, male = 266, female = 306,
      desc = "Command uniform with gold trim." },
    { key = "captain",   name = "Captain",              minRank = 7, male = 267, female = 306,
      desc = "Precinct command uniform." },
    { key = "deputy",    name = "Deputy Chief",         minRank = 8, male = 265, female = 306,
      desc = "Deputy Chief dress uniform." },
    { key = "chief",     name = "Chief of Police",      minRank = 9, male = 166, female = 306,
      desc = "Black suit. Gold shield. The office." },
}

-- ============================================================
-- FLEET
-- model IDs are stock GTA:SA police vehicles (no custom DFF needed
-- to be functional); when the LCPD DFF/TXD pack is installed these
-- same IDs are re-skinned by the vehicle loader, so nothing here
-- changes.
-- ============================================================
PD.vehicles = {
    { key = "cruiser",   name = "Patrol Cruiser",     model = 596, minRank = 1, slots = 3,
      color1 = 0, color2 = 1, plate = "LMB", class = "patrol",
      desc = "Black & white LCPD cruiser. Unit 1xx." },
    { key = "bike",      name = "Traffic HPV-1000",   model = 523, minRank = 2, slots = 2,
      color1 = 0, color2 = 1, plate = "LMB", class = "traffic",
      desc = "Police motorcycle for traffic detail." },
    { key = "suv",       name = "Patrol SUV",         model = 599, minRank = 2, slots = 2,
      color1 = 0, color2 = 1, plate = "LMB", class = "patrol",
      desc = "Ranger-pattern SUV for rough streets." },
    { key = "unmarked",  name = "Unmarked Unit",      model = 490, minRank = 3, slots = 2,
      color1 = 0, color2 = 0, plate = "LMB", class = "unmarked",
      desc = "Blacked-out unmarked unit. Detectives." },
    { key = "interceptor", name = "Interceptor",      model = 597, minRank = 4, slots = 2,
      color1 = 0, color2 = 1, plate = "LMB", class = "patrol",
      desc = "High-speed interceptor for the highway." },
    { key = "enforcer",  name = "Enforcer",           model = 427, minRank = 5, slots = 1,
      color1 = 0, color2 = 0, plate = "LMB", class = "support",
      desc = "Armoured transport / roadblock unit." },
    { key = "command",   name = "Command Vehicle",    model = 598, minRank = 6, slots = 1,
      color1 = 0, color2 = 0, plate = "LMB", class = "command",
      desc = "Mobile command post for on-scene command." },
    { key = "tactical",  name = "SWAT Van",           model = 601, minRank = 6, slots = 1,
      color1 = 0, color2 = 0, plate = "LMB", class = "tactical",
      desc = "SWAT deployment van. Tactical call-out only." },
    { key = "fbi",       name = "Federal Truck",      model = 528, minRank = 8, slots = 1,
      color1 = 0, color2 = 0, plate = "LMB", class = "federal",
      desc = "Federal liaison unit. Command staff." },
    { key = "air",       name = "Police Maverick",    model = 497, minRank = 7, slots = 1,
      color1 = 0, color2 = 1, plate = "LMB", class = "air",
      desc = "Air support. Requires a pilot on duty." },
}

PD.vehicleByKey = {}
for _, v in ipairs(PD.vehicles) do PD.vehicleByKey[v.key] = v end

-- ============================================================
-- ARMORY
-- ============================================================
PD.armory = {
    { key = "baton",   name = "Nightstick",        kind = "weapon", weapon = 3,  ammo = 1,   minRank = 1 },
    { key = "flash",   name = "Flashlight",        kind = "tool",   tool = "flashlight",    minRank = 1 },
    { key = "cuffs",   name = "Handcuffs",         kind = "tool",   tool = "cuffs",         minRank = 1 },
    { key = "radio",   name = "Police Radio",      kind = "tool",   tool = "radio",         minRank = 1 },
    { key = "armor",   name = "Body Armour",       kind = "armor",  amount = 100,           minRank = 2 },
    { key = "pistol",  name = "9mm Pistol",        kind = "weapon", weapon = 22, ammo = 34,  minRank = 2 },
    { key = "taser",   name = "Taser X26",         kind = "weapon", weapon = 23, ammo = 12,  minRank = 3, taser = true },
    { key = "shotgun", name = "Remington 870",     kind = "weapon", weapon = 25, ammo = 20,  minRank = 3 },
    { key = "mp5",     name = "MP5 Submachine Gun", kind = "weapon", weapon = 29, ammo = 90, minRank = 4 },
    { key = "rifle",   name = "M4 Carbine",        kind = "weapon", weapon = 31, ammo = 120, minRank = 5 },
    { key = "sniper",  name = "Sniper Rifle",      kind = "weapon", weapon = 34, ammo = 20,  minRank = 6 },
    { key = "swatkit", name = "SWAT Loadout",      kind = "loadout", loadout = {29, 25, 23, 3}, armor = 100, minRank = 6 },
}

PD.armoryByKey = {}
for _, a in ipairs(PD.armory) do PD.armoryByKey[a.key] = a end

-- ============================================================
-- STATION
-- entrance/garage/blip: Liberty City PD landmark already verified
-- as solid ground by ng-map (2026-11-17). Interior points are stock
-- interior 6 (the same shell the jail has always used). Every point
-- can be re-calibrated in game with /pdcal (admin) and is then saved
-- to the database, so no code edit is needed.
-- ============================================================
PD.station = {
    -- REAL Liberty City 3D police station from LC/zones/industse/industse.map:
    -- <building id="police_station_ind" posX="-192.41" posY="1136.08"
    --  posZ="13.9107" .../>  (not a marker and not a blip-only fake building).
    -- The old interaction point was the building origin, which sits INSIDE the
    -- model's solid collision box. The entrance is now the open doorway of the
    -- walk-in annex on the south forecourt (see PD.annex below).
    x = -193.5, y = 1110.4, z = 13.90,
    rot = 0,
    interior = 0, dimension = 0,
    blip = { sprite = 30, color = 2, scale = 1.1, name = "LCPD - Liberty City Police Department" },
    label = "LIBERTY CITY POLICE DEPARTMENT",
    -- open-world flag: the client must NOT offer an "E - ENTER" teleport.
    -- Players walk in through the real south doorway of PD.annex.
    open = true,
}

-- Walk-in annex built at runtime by server/s_station.lua from SA police
-- interior wall sections (model 14843). South face is completely open: it is
-- the doorway, so players simply walk in from the forecourt at ground level.
PD.annex = {
    centerX = -193.5,
    backY   = 1122.30,   -- flush with the LC station's south collision face
    frontY  = 1111.20,   -- open side (street side)
    halfW   = 5.60,      -- 11.2 m wall sections
    floorZ  = 13.90,
    roofZ   = 16.40,
    wallModel = 14843,   -- int_policeA01, 11.22 x 0.14 x 2.5 m, has collision
}

-- vehicle spawn slots: the verified station forecourt / adjacent LC road
-- (industse.map roads at x=-224.23, z=13.78 and station ground at z~13.9).
-- Probe-verified road ground: x=-204..-212 => z 13.83..13.94;
-- x=-200/-196 hits the station building collision (z 32.8/35.8).
PD.vehicleSlots = {
    { x = -212.0, y = 1130.0, z = 13.90, rot = 90 },
    { x = -212.0, y = 1142.0, z = 13.90, rot = 90 },
    { x = -216.0, y = 1130.0, z = 13.83, rot = 270 },
    { x = -216.0, y = 1142.0, z = 13.86, rot = 270 },
}

-- interaction points: all inside the walk-in annex, dimension 0 / interior 0.
-- There is deliberately NO "entrance"/"exit" point: the doorway is a real open
-- gap in the south wall, so there is nothing to teleport through.
PD.points = {
    duty      = { x = -196.4, y = 1119.0, z = 13.90, rot = 180, interior = 0, dimension = 0, label = "DUTY DESK & WARDROBE", icon = "duty" },
    armory    = { x = -190.6, y = 1119.0, z = 13.90, rot = 180, interior = 0, dimension = 0, label = "ARMOURY",              icon = "armory" },
    -- garage terminal is outside in the vehicle lot so released units are visible immediately
    garage    = { x = -224.23, y = 1146.18, z = 14.05, rot = 90, interior = 0, dimension = 0, label = "POLICE GARAGE", icon = "garage" },
    chief     = { x = -189.4, y = 1114.4, z = 13.90, rot = 180, interior = 0, dimension = 0, label = "CHIEF OF POLICE",      icon = "chief" },
    cells     = { x = -197.6, y = 1114.4, z = 13.90, rot = 0,   interior = 0, dimension = 0, label = "HOLDING CELLS",        icon = "cells" },
}

-- exterior interaction (entrance marker in the world)
PD.exteriorPoint = { label = "LmB POLICE DEPARTMENT - ENTRANCE", icon = "enter" }

-- ============================================================
-- GAMEPLAY TUNING
-- ============================================================
PD.tuning = {
    cuffRange      = 3.2,
    searchRange    = 3.2,
    fineRange      = 5.0,
    arrestRange    = 4.0,
    vehicleCheckRange = 6.0,
    jailDefault    = 180,        -- seconds
    jailMax        = 900,
    fineMax        = 25000,
    wantedMax      = 6,
    radioRange     = 99999,      -- radio is not distance limited
    localRadioRange = 40,
    speeds = { 0.5, 1.0, 1.5, 2.0 },
}

-- strictServices: when true, garage/armoury/duty only work at the
-- station or inside the PD interior. Left false for the first rollout
-- so the systems stay usable even before the interior points are
-- calibrated on a live client.
PD.strictServices = false
PD.strictDutyLocation = false

-- ============================================================
-- LUXURY UI PALETTE (identical family to ng-characters)
-- ============================================================
PD.ui = {
    gold       = { 226, 190, 116 },
    goldSoft   = { 246, 222, 174 },
    goldDeep   = { 154, 120, 58 },
    text       = { 240, 242, 246 },
    mute       = { 150, 155, 166 },
    dim        = { 96, 101, 112 },
    charcoal   = { 14, 15, 18 },
    panel      = { 18, 19, 23 },
    panel2     = { 24, 26, 31 },
    line       = { 226, 190, 116 },
    good       = { 104, 196, 128 },
    bad        = { 208, 82, 74 },
    warn       = { 226, 176, 84 },
    blue       = { 92, 150, 214 },
}
