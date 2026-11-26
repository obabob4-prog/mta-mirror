----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: settings: shared.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Shared Settings ]]--
----------------------------------------------------------------


------------------
--[[ Settings ]]--
------------------

settings = {
    GTA = {
        restoreWorld = false,
        clearWorld = false,
        -- LC: eagleLoader owns water. Assetify must never reset global water
        -- back to the GTA:SA level after the LC map loader removed it.
        waterLevel = false
    },

    library = {
        autoUpdate = false,
        -- 2026-11-22: public Cloudflare tunnel to the local Assetify webserver (port 33022).
        -- Without this the remote client fetches http://localhost:33022 = its OWN PC,
        -- so scene packs (LPW_Bolge_1/2) fail and half the city is missing.
        webserverURL = "https://extraction-affect-jan-turbo.trycloudflare.com"
    },

    discord = {
        appID = "1311797731932766248",
        logo = {asset = "logo", tooltip = "ᴏᴠ ━ ꜱᴛᴜᴅɪᴏ"},
        minAge = 3,
        details = "ovstudio",
        trackRate = 30*1000,
        buttons = {
            {name = "Download", url = "https://github.com/ov-sa/Assetify.library/releases/latest"},
            {name = "Donate", url = "https://ko-fi.com/ovstudio"}
        }
    },

    downloader = {
        isAccessSafe = true,
        syncRate = 100,
        buildRate = 1000,
        trackRate = 300
    },

    streamer = {
        syncRate = 250,
        streamRate = 75,
        cameraRate = 75,
        syncCoolDownRate = false,
        streamDelimiter = {8, 30, 5},
        unsyncDimension = 65535 
    },

    syncer = {
        persistence = 30*1000
    },

    renderer = {
        state = false,

        -- LC: luxury_weather owns time/sky. Assetify's GTA:SA timecycle and
        -- dynamic sky override setSkyGradient every frame and visually warp
        -- the Liberty City scene, so both stay off.
        timecycle = {
            state = false,
            source = ":assetify_library/utilities/rw/timecycle.vcl"
        },

        sky = {
            state = false,
            cloud = {
                speed = 1,
                scale = 1,
                direction = {1, -1},
                color = {255, 255, 255, 255}
            },
            star = {
                speed = 5,
                scale = 0.085,
                intensity = 1,
            },
            moon = {
                scale = 0.5,
                brightness = 1,
                emissive = {
                    scale = 1,
                    intensity = 1
                }
            }
        }
    }
}
