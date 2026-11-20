--[[
    ng-characters c_chars.lua - DISABLED 2026-11-19 (gta4gg)

    The character picker UI is now provided by the [systems]/characters_lc
    resource. This file is intentionally inert so only ONE client script
    answers ngc:showCharList / ngc:charSpawned (two UIs used to overlap).

    All SERVER logic in s_chars.lua is untouched and still owns:
      * SQLite characters table, create/select/delete, saving
      * map-ready gated spawn + LC position clamping
      * ngc:* events consumed by login, HUD, inventory, phone, police...
      * the critical dimension-0 fix that stops the default SA world
        rendering through the Liberty City map.

    Original cinematic UI backup:
      D:\MTA-LC-Server\backups\lc_pro_20261119_133708_charselect_lc_integration\ng-characters_FULL\c_chars.lua
]]
