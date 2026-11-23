--[[
    car_radio / client.lua
    URL-based in-car radio. DX-only LmB style player, no GUI elements.
    Keys: K play/stop, L next, J prev. Commands: /radio, /radiovol.
]]

local sw, sh = guiGetScreenSize()
local SCALE = math.min(sw / 1366, sh / 768)
if SCALE < 0.85 then SCALE = 0.85 end

local GOLD     = tocolor(226, 190, 116, 235)
local GOLD_DIM = tocolor(226, 190, 116, 120)
local WHITE    = tocolor(240, 242, 246, 235)
local DIM      = tocolor(210, 216, 226, 165)
local BG       = tocolor(8, 10, 13, 210)
local RED      = tocolor(214, 78, 70, 240)
local BAR_BG   = tocolor(255, 255, 255, 38)

local R = {
    tracks = {},
    index = 0,
    sound = nil,
    playing = false,
    visible = true,
    volume = 0.80,
    startedAt = 0,
    notice = "",
    noticeUntil = 0,
    noticeErr = false,
}

local function currentTrack()
    if R.index >= 1 and R.index <= #R.tracks then
        return R.tracks[R.index]
    end
    return nil
end

local function notify(text, isErr)
    R.notice = tostring(text or "")
    R.noticeErr = isErr == true
    R.noticeUntil = getTickCount() + 3200
end

local function stopSound(silent)
    local s = R.sound
    R.sound = nil
    R.playing = false
    if s and isElement(s) then destroyElement(s) end
    if not silent then notify("Playback stopped") end
end

local function playIndex(i)
    if #R.tracks == 0 then
        stopSound(true)
        notify("No tracks - add URLs to songs.txt", true)
        return
    end

    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh or not isElement(veh) then
        stopSound(true)
        notify("You must be inside a vehicle", true)
        return
    end

    if i < 1 then i = #R.tracks end
    if i > #R.tracks then i = 1 end

    stopSound(true)
    local t = R.tracks[i]
    local x, y, z = getElementPosition(veh)
    local s = playSound3D(t.url, x, y, z, false)
    if not s then
        notify("Could not open audio stream", true)
        return
    end

    R.index = i
    R.sound = s
    R.playing = true
    R.startedAt = getTickCount()
    setSoundVolume(s, R.volume)
    setSoundMaxDistance(s, 85)
    setRadioChannel(0) -- mute the stock GTA radio while streaming
    notify("Now playing: " .. tostring(t.title))
end

local function nextTrack() playIndex(R.index + 1) end
local function prevTrack() playIndex(R.index - 1) end

local function characterUiActive()
    -- ng-characters marks its picker state; sCharacterCreator exposes its own
    -- state for the 3D creator. Never draw the radio over the character UI.
    if getElementData(localPlayer, "ngc.uiOpen") == true then return true end
    local res = getResourceFromName("sCharacterCreator")
    if res and getResourceState(res) == "running" then
        local ok, active = pcall(function()
            return exports.sCharacterCreator:isCreationActive()
        end)
        if ok and active then return true end
    end
    return false
end

local function drawPanel()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if characterUiActive() then return end

    local w, h = 420 * SCALE, 96 * SCALE
    -- right-aligned so it never covers the top-left server-message feed
    local x = sw - w - 26 * SCALE
    local y = 22 * SCALE

    dxDrawRectangle(x, y, w, h, BG)
    dxDrawRectangle(x, y, 4 * SCALE, h, GOLD)
    dxDrawRectangle(x, y, w, 1.5 * SCALE, GOLD_DIM)
    dxDrawRectangle(x, y + h - 1.5 * SCALE, w, 1.5 * SCALE, GOLD_DIM)

    dxDrawText("LmB RADIO", x + 16 * SCALE, y + 7 * SCALE, x + w - 60 * SCALE, y + 27 * SCALE,
        GOLD, 1.05 * SCALE, "default-bold", "left", "center")
    local num = (#R.tracks > 0) and (R.index .. " / " .. #R.tracks) or "0 / 0"
    dxDrawText(num, x + w - 14 * SCALE, y + 7 * SCALE, x + w - 14 * SCALE, y + 27 * SCALE,
        GOLD, 1.0 * SCALE, "default-bold", "right", "center")

    local t = currentTrack()
    dxDrawText(t and t.title or "PLAYLIST EMPTY", x + 16 * SCALE, y + 27 * SCALE,
        x + w - 16 * SCALE, y + 49 * SCALE, WHITE, 1.25 * SCALE, "default-bold", "left", "center")

    local barX = x + 16 * SCALE
    local barY = y + 55 * SCALE
    local barW = w - 32 * SCALE
    local barH = 5 * SCALE
    dxDrawRectangle(barX, barY, barW, barH, BAR_BG)

    -- getSoundPlayPosition does not exist on this server build, so estimate
    -- progress from playback start time and getSoundLength (which does exist).
    local ratio = 0
    if R.sound and isElement(R.sound) then
        local len = getSoundLength(R.sound) or 0
        if len and len > 0 then
            ratio = ((getTickCount() - R.startedAt) / 1000) / len
        end
    end
    if ratio < 0 then ratio = 0 elseif ratio > 1 then ratio = 1 end
    if ratio > 0 then dxDrawRectangle(barX, barY, barW * ratio, barH, GOLD) end

    local state = R.playing and "PLAYING" or "STOPPED"
    local vol = math.floor(R.volume * 100)
    dxDrawText(state .. "   VOL " .. vol .. "%    K play/stop  L next  J prev",
        x + 16 * SCALE, y + 66 * SCALE, x + w - 16 * SCALE, y + 86 * SCALE,
        DIM, 0.9 * SCALE, "default", "left", "center")

    if getTickCount() < R.noticeUntil and R.notice ~= "" then
        local col = R.noticeErr and RED or GOLD
        local tw = dxGetTextWidth(R.notice, 1.0 * SCALE, "default-bold") + 20 * SCALE
        local nx, ny = (sw - tw) / 2, y + h + 6 * SCALE
        dxDrawRectangle(nx, ny, tw, 22 * SCALE, BG)
        dxDrawText(R.notice, nx, ny, nx + tw, ny + 22 * SCALE,
            col, 1.0 * SCALE, "default-bold", "center", "center")
    end
end

addEventHandler("onClientRender", root, function()
    if R.sound and isElement(R.sound) then
        local veh = getPedOccupiedVehicle(localPlayer)
        if veh and isElement(veh) then
            local x, y, z = getElementPosition(veh)
            setElementPosition(R.sound, x, y, z)
        end
    end
    if R.visible then drawPanel() end
end)

-- advance to the next track when the current stream finishes
addEventHandler("onClientSoundStopped", root, function()
    if source ~= R.sound or not R.playing then return end
    local nextIndex = R.index + 1
    R.sound = nil
    R.playing = false
    setTimer(function() playIndex(nextIndex) end, 350, 1)
end)

addEventHandler("onClientPlayerVehicleEnter", localPlayer, function(veh, seat)
    if seat ~= 0 then return end
    setTimer(function()
        if getPedOccupiedVehicle(localPlayer) then playIndex(R.index > 0 and R.index or 1) end
    end, 350, 1)
end)

addEventHandler("onClientPlayerVehicleExit", localPlayer, function()
    stopSound(true)
    -- 2026-11-20: safety net - ensure player is not frozen after exiting
    -- a vehicle (some scripts leave the player frozen on exit).
    setElementFrozen(localPlayer, false)
    showCursor(false)
end)

addEvent("carRadio:playlist", true)
addEventHandler("carRadio:playlist", root, function(tracks)
    R.tracks = type(tracks) == "table" and tracks or {}
    if R.index > #R.tracks then R.index = #R.tracks end
    if #R.tracks == 0 then stopSound(true) end
end)

addCommandHandler("radio", function(_, arg)
    local a = tostring(arg or ""):lower()
    if a == "" or a == "ui" then
        R.visible = not R.visible
        outputChatBox("[LmB Radio] Player " .. (R.visible and "shown" or "hidden"), 226, 190, 116)
    elseif a == "next" then
        nextTrack()
    elseif a == "prev" then
        prevTrack()
    elseif a == "play" then
        playIndex(R.index > 0 and R.index or 1)
    elseif a == "stop" then
        stopSound()
    elseif a == "list" then
        if #R.tracks == 0 then
            outputChatBox("[LmB Radio] Playlist empty. Add URLs to songs.txt then /radioreload", 226, 190, 116)
        else
            outputChatBox("[LmB Radio] Tracks (" .. #R.tracks .. "):", 226, 190, 116)
            for i, t in ipairs(R.tracks) do
                outputChatBox("  " .. i .. ". " .. tostring(t.title), 240, 242, 246)
            end
        end
    else
        outputChatBox("[LmB Radio] /radio [next|prev|play|stop|list|ui]  |  /radiovol <0-100>", 226, 190, 116)
    end
end)

addCommandHandler("radiovol", function(_, v)
    local n = tonumber(v)
    if not n or n < 0 or n > 100 then
        outputChatBox("[LmB Radio] Usage: /radiovol <0-100>", 226, 190, 116)
        return
    end
    R.volume = n / 100
    if R.sound and isElement(R.sound) then setSoundVolume(R.sound, R.volume) end
    outputChatBox("[LmB Radio] Volume: " .. math.floor(n) .. "%", 226, 190, 116)
end)

local function inChat()
    return isChatBoxInputActive() or isConsoleActive() or guiGetInputEnabled() or isCursorShowing()
end

bindKey("k", "down", function()
    if inChat() then return end
    if R.playing then stopSound() else playIndex(R.index > 0 and R.index or 1) end
end)
bindKey("l", "down", function()
    if inChat() then return end
    nextTrack()
end)
bindKey("j", "down", function()
    if inChat() then return end
    prevTrack()
end)

-- server-side/admin remote control (also used for live diagnostics)
addEvent("carRadio:control", true)
addEventHandler("carRadio:control", root, function(action, value)
    if action == "play" then
        playIndex(tonumber(value) or (R.index > 0 and R.index or 1))
    elseif action == "stop" then
        stopSound()
    elseif action == "next" then
        nextTrack()
    elseif action == "prev" then
        prevTrack()
    elseif action == "vol" then
        local n = tonumber(value)
        if n then
            R.volume = math.max(0, math.min(1, n))
            if R.sound and isElement(R.sound) then setSoundVolume(R.sound, R.volume) end
        end
    end
    setElementData(localPlayer, "carRadio.debug",
        "tracks=" .. #R.tracks .. " index=" .. R.index ..
        " playing=" .. tostring(R.playing) ..
        " sound=" .. tostring(R.sound and isElement(R.sound) or false) ..
        " note=" .. R.notice)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    stopSound(true)
end)
