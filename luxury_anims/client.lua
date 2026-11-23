--[[
    [LuxuryCars] Realistic Movement Animations (GTA V style)
    ---------------------------------------------------------
    Loads a custom ped.ifp (ANP3, block "ped") and swaps the walking /
    running / sprinting / idle / jump / turn animations of nearby players
    with the new ones, using MTA's engineLoadIFP + engineReplaceAnimation.

    Commands:
        /anims        -> toggle the custom animations on/off for yourself
        /anims on|off -> explicit

    Notes:
      * Client-side only, nothing is streamed to other players' scripts.
      * Animations that do not exist in the IFP are skipped silently.
      * If the IFP fails to load, the resource reports it in the debug log.
]]

local IFP_FILE = "anim/ped.ifp"
local BLOCK = "lv_ped"          -- custom block name for the loaded IFP
local BASE_BLOCK = "ped"        -- block name inside ped.ifp
local MAX_DISTANCE = 120        -- metres: only peds near the player are patched

-- Animation names used by the pack (both cases are tried; missing ones are ignored)
local ANIMS = {
    -- idle
    "Idle_stance", "idle_stance", "IDLE_taxi", "Idlestance_fat", "Idlestance_old",
    "sexywomanfat_idlestance", "Gun_2_IDLE",
    -- walk
    "WALK_civi", "WALK_civi2", "WALK_civi3", "WALK_civi4", "WALK_civi5",
    "WALK_fat", "WALK_old", "WALK_gang1", "WALK_gang2", "WALK_player", "WALK_armed",
    "WALK_ballas1", "WALK_fam1", "WALK_fam2", "WALK_homeless", "WALK_latino1",
    "WALK_start", "WALK_start_armed", "WALK_rocket", "WALK_start_rocket",
    "Walk_DoorPartial", "walk_csaw_right", "walk_civi", "walk_fat", "walk_old",
    -- run
    "run_player", "run_old", "run_armed", "run_left", "run_homeless", "Run_Wuzi",
    "Run_stop", "Run_stopR", "run_civi", "run_fat", "run_gang1", "run_gang2",
    "run_csaw", "run_panic",
    -- sprint
    "sprint_civi", "sprint_panic", "sprint_panic2", "oldsprint_panic",
    "playersprint_armed", "sprint_armed",
    -- jump / fall
    "JUMP_launch", "JUMP_glide", "JUMP_land", "JUMP_launch_R",
    "jump_launch", "jump_glide", "jump_land", "FALL_land", "fall_land", "CLIMB_jump",
    -- turning
    "turn_180", "Turn_L", "Turn_R", "Turn_180", "turn_left", "turn_right",
    -- road crossing
    "roadcross", "roadcross_gang", "roadcross_old",
}

local loaded = false
local enabled = true
local patched = {}

local function isTargetElement(el)
    if not isElement(el) then return false end
    local t = getElementType(el)
    return t == "player" or t == "ped"
end

local function nearLocalPlayer(el)
    if el == localPlayer then return true end
    local x, y, z = getElementPosition(el)
    local px, py, pz = getElementPosition(localPlayer)
    return getDistanceBetweenPoints3D(x, y, z, px, py, pz) <= MAX_DISTANCE
end

local function patchPed(ped)
    if not loaded or not enabled then return end
    if not isTargetElement(ped) then return end
    if patched[ped] then return end
    if not nearLocalPlayer(ped) then return end

    patched[ped] = {}
    local ok = 0
    for _, name in ipairs(ANIMS) do
        if engineReplaceAnimation(ped, BASE_BLOCK, name, BLOCK, name) then
            patched[ped][name] = true
            ok = ok + 1
        end
    end
    if ped == localPlayer then
        outputDebugString("[luxury_anims] patched local player with " .. ok .. " animations")
    end
end

local function restorePed(ped)
    if not patched[ped] then return end
    for name in pairs(patched[ped]) do
        engineRestoreAnimation(ped, BASE_BLOCK, name, BLOCK, name)
    end
    patched[ped] = nil
end

local function patchAll()
    patchPed(localPlayer)
    for _, el in ipairs(getElementsByType("player")) do patchPed(el) end
    for _, el in ipairs(getElementsByType("ped")) do patchPed(el) end
end

local function restoreAll()
    for ped in pairs(patched) do restorePed(ped) end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    loaded = engineLoadIFP(IFP_FILE, BLOCK) and true or false
    if not loaded then
        outputDebugString("[luxury_anims] FAILED to load " .. IFP_FILE, 1)
        return
    end
    outputDebugString("[luxury_anims] IFP loaded, patching peds")
    patchAll()
    setTimer(patchAll, 5000, 0)   -- catches peds that spawned out of range earlier
end)

addEventHandler("onClientElementStreamIn", root, function()
    if isTargetElement(source) then patchPed(source) end
end)

addEventHandler("onClientElementDestroy", root, function()
    patched[source] = nil
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    restoreAll()
    loaded = false
end)

-- ===================== toggle =====================
local function toggle(state)
    if state == true or state == "on" then enabled = true
    elseif state == false or state == "off" then enabled = false
    else enabled = not enabled end

    if enabled then
        patchAll()
        outputDebugString("[luxury_anims] enabled")
    else
        restoreAll()
        outputDebugString("[luxury_anims] disabled")
    end
    return enabled
end

addCommandHandler("anims", function(_, arg)
    local on = toggle(arg and string.lower(arg) or nil)
    outputChatBox("[الحركات] " .. (on and "مفعّلة" or "معطّلة"), 255, 200, 45)
end)
