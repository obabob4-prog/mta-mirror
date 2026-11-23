--[[
    gta4hud / config.lua
    Central layout + colour configuration. All sizes are design pixels for a
    1920x1080 screen; the client scales them with min(w/1920, h/1080).

    STYLE = "classic"  -> GTA IV look: circular radar with a thick black bezel,
                          segmented health/armour strip, plain big cash card.
    STYLE = "glass"    -> GTA V look: square rounded radar, glass vitals panel.

    Switch HUDCFG.style (and the matching minimap.shape / vitals.style) below.
]]

HUDCFG = {
    version       = "1.1.1",
    designWidth   = 1920,
    designHeight  = 1080,

    style         = "classic",

    -- global
    marginTop     = 26,
    marginRight   = 36,
    marginBottom  = 34,

    colors = {
        health      = { 224,  75,  63 },
        healthLow   = { 255,  86,  70 },
        armor       = { 143, 196, 240 },
        hunger      = { 226, 164,  58 },
        thirst      = {  62, 160, 220 },
        money       = { 139, 255, 180 },
        moneyGain   = { 139, 255, 180 },
        moneyLoss   = { 255, 120, 110 },
        text        = { 238, 242, 248 },
        textDim     = { 150, 160, 174 },
        panel       = {  10,  13,  16, 172 },
        panelSoft   = {  10,  13,  16, 120 },
        strip       = {   0,   0,   0, 214 },
        border      = { 255, 255, 255,  40 },
        star        = { 255, 208,  64 },
        radio       = { 226, 232, 240 },
        zone        = { 224, 230, 238 },
        speed       = { 238, 242, 248 },
        fuel        = { 226, 164,  58 },
        weapon      = { 238, 242, 248 },
        accent      = { 124, 255, 168 },
        accentGold  = { 227, 190, 114 },
    },

    minimap = {
        shape         = "circle", -- "circle" (GTA IV) | "square" (GTA V)
        size          = 216,      -- design px
        x             = 34,
        radius        = 22,       -- corner radius, square shape only
        bezel         = 8,        -- extra black ring around a circular radar
        bottomOffset  = 0,        -- extra lift from marginBottom
        rtSize        = 512,      -- render target resolution (square)
        -- The LC radar texture is 2048px for a 6000 unit world (~0.34 px per
        -- metre), so ~460m across is the sweet spot: readable streets without
        -- over-magnifying the source art.
        viewMeters    = 460,      -- world metres visible across the map
        minView       = 260,
        maxView       = 900,
        zoomStep      = 40,
        rotate        = true,
        showVehicles  = true,
        vehicleRange  = 180,
        showPlayers   = true,
        playerRange   = 400,
        blipSize      = 32,       -- render-target pixels
        arrowSize     = 40,
        borderWidth   = 1.6,
        gapBelow      = 12,       -- gap between minimap and the vitals strip
    },

    vitals = {
        style         = "segments", -- "segments" (GTA IV) | "glass" (GTA V)
        height        = 44,
        segments      = 10,
        segmentGap    = 2,
        padding       = 10,
        healthHeight  = 10,
        armorHeight   = 9,
        thinHeight    = 3,
    },

    radio = {
        style         = "classic",  -- "classic" | "glass"
        width         = 216,
        height        = 44,
        gapAbove      = 10,
        visibleTime   = 6500,       -- ms the widget stays after a change
    },

    money = {
        -- premium glass card, top-right
        -- 2026-11-19: one dial scales the whole card. 1.18 + larger cashSize
        -- gives the richer GTA V Online cash readout requested by the user.
        scale         = 1.18,
        cardWidth     = 344,
        cardHeight    = 124,
        cardRadius    = 18,
        cardY         = 24,
        cashSize      = 38,
        bankSize      = 18,
        labelSize     = 10,
        deltaSize     = 16,
        deltaLife     = 1600,
        fill          = { 9, 12, 16, 184 },
        border        = { 232, 197, 107, 62 },
        borderWidth   = 1.6,
    },

    weapon = {
        style         = "classic",  -- "classic" (big text) | "chip" (glass chip)
        chipWidth     = 168,
        chipHeight    = 30,
        nameSize      = 24,
        ammoSize      = 20,
        visibleTime   = 6000,
    },

    vehicle = {
        style         = "classic",  -- "classic" (black strip) | "glass"
        chipWidth     = 186,
        chipHeight    = 58,
        gapAbove      = 14,
    },
}

-- Radio station metadata (MTA only exposes channel id + name, no song info).
HUDCFG.radioGenres = {
    [1]  = "CLASSIC HIP HOP",
    [2]  = "COUNTRY",
    [3]  = "CLASSIC ROCK",
    [4]  = "FUNK / SOUL",
    [5]  = "HOUSE / TECHNO",
    [6]  = "WEST COAST RAP",
    [7]  = "ALTERNATIVE",
    [8]  = "MODERN ROCK",
    [9]  = "REGGAE / DUB",
    [10] = "RARE GROOVE",
    [11] = "TALK RADIO",
    [12] = "USER TRACKS",
}
