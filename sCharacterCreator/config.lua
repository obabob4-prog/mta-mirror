--[[
    sCharacterCreator - configuration
    ------------------------------------------------------------------
    Everything you normally need to change lives in this file.
    This resource is standalone: no sGui / sBinco / sAccounts needed.
    ------------------------------------------------------------------
    Skin IDs are San Andreas ped model IDs. The defaults below are the
    male/female lists used by the original VeltrixScript server (sBinco).
]]

CC = {
    -- How many characters one account may own.
    maxCharacters = 3,

    -- false: characters are scoped to the player's serial (no login needed).
    -- true : characters are scoped to the player's MTA account name.
    useAccounts = false,

    -- Optional: read the account key from player element data instead.
    -- Example: "char.accID" (the field used by the original sAccounts).
    -- Leave false to use the serial / MTA account name from useAccounts.
    -- 2026-11-16 NGRP integration: scope characters to the ng-login account id
    accountDataKey = "account.id",

    -- Allow the player to press ESC and leave the creator without saving.
    allowCancel = false,

    -- Hide the HUD (radar, money, weapon icons, ...) while the creator is open.
    hideHud = true,

    -- Database. SQLite works out of the box (file is created inside this resource).
    -- Set type = "mysql" and fill the mysql table if you want MySQL instead.
    database = {
        type = "sqlite",
        -- 2026-11-16 NGRP: ":/" anchors the file inside this resource's
        -- folder (same pattern ng-database uses) instead of a server-CWD
        -- relative path that could land anywhere.
        file = ":/characters.db",
        mysql = {
            host = "127.0.0.1",
            port = 3306,
            dbname = "mta",
            user = "root",
            password = "",
        },
    },

    -- Move the player to the spawn point after the creator finishes.
    -- Set to false if your gamemode handles spawning in onCharacterCreated.
    -- 2026-11-16 NGRP integration: ng-characters handles the gated spawn
    spawnAfterCreation = false,

    -- Where the player is put after the creator finishes.
    -- The event onCharacterCreated is fired so your gamemode can take over.
    spawn = {
        x = 1682.7392578125,
        y = -2328.7177734375,
        z = 13.546875,
        rotation = 0,
        interior = 0,
        dimension = 0,
    },

    -- The 3D preview. Original indoor scene: the Dieder Sachs clothes-shop
    -- studio room (SA interior 14). Restored 2026-11-17 per user request -
    -- the room still exists because the stock world is not removed
    -- (eagleLoader's removeGameWorld branch is a no-op here).
    scene = {
        interior = 14,
        ped = {
            x = 256.8984375,
            y = -42.7890625,
            z = 1002.0234375,
            rotation = -20,
        },
        camera = {
            x = 258.25390625,
            y = -39.514453125,
            z = 1002.85,
            lookX = 256.8984375,
            lookY = -42.7890625,
            lookZ = 1002.0234375,
        },
        time = { hour = 12, minute = 0 },
        idles = { "shift", "stretch", "strleg", "time" },
    },

    -- Name rules. Characters are stored as Firstname_Lastname.
    name = {
        minLength = 6,
        maxLength = 24,
        minParts = 2,
        maxParts = 2,
    },

    -- All user-facing text. Translate freely.
    ui = {
        title = "CHARACTER CREATION",
        subtitle = "CREATE YOUR IDENTITY BEFORE YOU ENTER THE CITY",
        passenger = "PASSENGER",
        namePlaceholder = "FIRSTNAME LASTNAME",
        nameHint = "2-4 words, English letters only, 6-24 characters",
        from = "LIBERTY CITY",
        to = "DOWNTOWN LC",
        flight = "SA111",
        gate = "A7",
        boardingPass = "BOARDING PASS",
        male = "MALE",
        female = "FEMALE",
        skin = "SKIN",
        next = "CONTINUE",
        nextDesc = "CREATE CHARACTER",
        back = "BACK TO SELECTION",
        backDesc = "RETURN TO CHARACTER LIST",
        checking = "CHECKING...",
        saving = "CREATING...",
        approved = "APPROVED",
        ready = "Welcome to the city",
        errors = {
            tooShort = "The name must be at least 6 characters long.",
            tooLong = "The name can be at most 24 characters long.",
            parts = "The name must contain 2 to 4 words.",
            characters = "Only English letters and spaces are allowed.",
            taken = "This name is already taken.",
            limit = "You have reached the character limit.",
            account = "You must be logged in to create a character.",
            database = "Database error. Please try again.",
            generic = "Something went wrong. Please try again.",
        },
    },

    -- Male / female skin model IDs.
    skins = {
        -- 2026-11-20 fix: removed female model IDs (37=sweety, 22=wfybu)
        -- that were incorrectly listed as male. Male list now contains
        -- only actual male ped model IDs.
        male = {
        1, 7, 14, 17, 23, 30, 42, 43, 44, 45, 46, 47, 48, 49, 50, 274,
        },
        female = {
        9, 12, 13, 40, 56, 88, 93, 141, 190, 195,
        },
    },
}
