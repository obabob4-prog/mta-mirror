--[[
    liberty_city_npc_population / config.lua
    ------------------------------------------------------------------
    Shared configuration (loaded on BOTH server and client).
    All NPC decisions are made server-side; the client part only loads
    the supplied custom ped models and applies them to synced peds.

    The seven model packs are the ONLY skins used.  They were supplied by
    the server owner in C:\Users\Admin\Downloads\SEL3A and copied here with
    their original DFF/TXD bytes (no re-modelling, no extra downloads).
]]

LCNPC = {
    version = "1.0.0",

    -- ------------------------------------------------------------------
    -- Population / performance
    -- ------------------------------------------------------------------
    maxNPCs          = 90,     -- hard cap, adjustable here only
    spawnBatch       = 6,      -- created per timer tick (gradual warm-up)
    spawnTick        = 900,    -- ms between spawn batches
    thinkTick        = 100,    -- ms between server movement decisions (balanced for smooth sync)
    minSpawnGap      = 3.2,    -- metres between two spawn points
    minSeparation    = 1.35,   -- metres between two walking NPCs
    streamRadius     = 120,    -- only NPCs near a player are stepped every tick (kept for compatibility)
    farStepEvery     = 1,      -- all NPCs are stepped every tick for consistent movement

    -- ------------------------------------------------------------------
    -- Behaviour timing (milliseconds, with per-NPC randomisation)
    -- ------------------------------------------------------------------
    walkMin          = 3200,
    walkMax          = 11000,
    idleMin          = 900,
    idleMax          = 4200,
    lookMin          = 600,
    lookMax          = 2200,
    sitChance        = 0.10,
    groupChance      = 0.18,
    groupMax         = 3,
    speedMin         = 0.10,
    speedMax         = 0.19,   -- metres per thinkTick (~1-1.9 m/s walking at thinkTick 100ms)

    -- ------------------------------------------------------------------
    -- Debug (server.log only - never chat, markers, blips or GUI)
    -- ------------------------------------------------------------------
    debug            = false,
    debugSpawn       = false,

    -- ------------------------------------------------------------------
    -- Supplied skins.  `base` is only a stock model used as a sync anchor
    -- when the ped is created; every client replaces it with the matching
    -- custom model ID from c_models.lua.  No stock model is replaced here.
    -- ------------------------------------------------------------------
    skins = {
        { name = "hospital_doctor",  dff = "skins/hospital_doctor.dff",  txd = "skins/hospital_doctor.txd",  base = 7,  label = "Hospital Doctor" },
        { name = "random_girl_v2",   dff = "skins/random_girl_v2.dff",   txd = "skins/random_girl_v2.txd",   base = 7,  label = "Random Girl" },
        { name = "roleplay_girl",    dff = "skins/roleplay_girl.dff",    txd = "skins/roleplay_girl.txd",    base = 7,  label = "Roleplay Girl" },
        { name = "roleplay_girl_v2", dff = "skins/roleplay_girl_v2.dff", txd = "skins/roleplay_girl_v2.txd", base = 7,  label = "Roleplay Girl V2" },
        { name = "tattooed_girl",    dff = "skins/tattooed_girl.dff",    txd = "skins/tattooed_girl.txd",    base = 7,  label = "Tattooed Girl" },
        { name = "tourist_girl",     dff = "skins/tourist_girl.dff",     txd = "skins/tourist_girl.txd",     base = 7,  label = "Tourist Girl" },
        { name = "kaine_goth",       dff = "skins/kaine_goth.dff",       txd = "skins/kaine_goth.txd",       base = 7,  label = "Kaine Goth" },
    },

    -- District density weights.  Populated from the ACTUAL installed LC map
    -- by build_spawn_graph.ps1 (auto-extracted, never entered by hand).
    districts = {},
}
