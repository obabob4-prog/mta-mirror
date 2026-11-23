--[[ ============================================================
     lc_voice / client.lua
     HOLD X    -> microphone opens (push-to-talk)
     RELEASE X -> microphone closes immediately
     V / F12 are NOT bound (V keeps its original GTA camera switch)

     NO ON/OFF HUD, NO BOX: the only visual is the professional microphone
     ICON floating above the head of a speaking player, with a soft pulsing
     glow. It shows while X is held (transmitting) or on real voice activity.
     ============================================================ ]]

local sw, sh = guiGetScreenSize()
local sc = math.max(0.75, math.min(sw / 1920, sh / 1080))

local micTex = nil
local holdSafetyTimer = nil
local badgeReported = false

local function isTyping()
    return (isChatBoxInputActive and isChatBoxInputActive())
        or (isConsoleActive and isConsoleActive())
end

-- PUSH-TO-TALK: explicit down/up state, never a toggle.
local function pushToTalk(on)
    if isTyping() then return end
    if isTimer(holdSafetyTimer) then killTimer(holdSafetyTimer) end
    holdSafetyTimer = nil
    if on then
        -- Safety: if the player alt-tabs while holding X, never leave the
        -- microphone stuck open (other servers use the same guard).
        holdSafetyTimer = setTimer(function()
            holdSafetyTimer = nil
            triggerServerEvent("lc:setMic", localPlayer, false)
        end, 45000, 1)
    end
    triggerServerEvent("lc:setMic", localPlayer, on)
end

-- ONLY X is bound now. V is untouched so GTA's camera switch works again.
bindKey("x", "down", function() pushToTalk(true) end)
bindKey("x", "up", function() pushToTalk(false) end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    micTex = dxCreateTexture("mic.png", "argb")
    if not micTex then
        outputDebugString("[lc_voice] WARNING: could not load mic.png", 1)
    end
    triggerServerEvent("lc:clientReady", localPlayer, micTex ~= nil)
    triggerServerEvent("lc:requestMicState", localPlayer)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isTimer(holdSafetyTimer) then killTimer(holdSafetyTimer) end
    holdSafetyTimer = nil
    if micTex and isElement(micTex) then destroyElement(micTex) end
    micTex = nil
end)

-- ============================================================
-- PREMIUM SPEAKING ICON  (the ONLY voice indicator)
--   the professional microphone mark alone - NO box / frame / bars,
--   just a soft cyan + gold light pulsing behind it.
-- ============================================================

local function drawSpeakingMarkers()
    local now = getTickCount()
    local pulse = 0.5 + 0.5 * math.sin(now / 150)

    for _, p in ipairs(getElementsByType("player")) do
        -- Show the icon while the player is TRANSMITTING (X held) OR when
        -- MTA reports real voice activity. Relying on voice events alone made
        -- it unreliable on devices where onPlayerVoiceStart is not reported.
        local transmitting = getElementData(p, "lc.micOn") == true
        local speaking = getElementData(p, "isTalking") == true
        if transmitting or speaking then
            local px, py, pz = getElementPosition(p)
            local cx, cy = getScreenFromWorldPosition(px, py, pz + 1.35, 0.08)
            if cx and cy then
                -- one-time proof that the draw path really executed
                if p == localPlayer and not badgeReported then
                    badgeReported = true
                    triggerServerEvent("lc:badgeShown", localPlayer)
                end

                -- ICON ONLY: no plaque, no frame, no wave bars, no pointer.
                local icon = 58 * sc
                local ix = cx - icon / 2
                local iy = cy - icon - 10 * sc
                if micTex then
                    -- wide soft cyan glow
                    local glow = icon * (1.65 + 0.25 * pulse)
                    dxDrawImage(ix + icon / 2 - glow / 2, iy + icon / 2 - glow / 2,
                        glow, glow, micTex, 0, 0, 0,
                        tocolor(0, 185, 255, math.floor(24 + 42 * pulse)))
                    -- warm gold inner glow for a premium look
                    local glow2 = icon * (1.28 + 0.16 * pulse)
                    dxDrawImage(ix + icon / 2 - glow2 / 2, iy + icon / 2 - glow2 / 2,
                        glow2, glow2, micTex, 0, 0, 0,
                        tocolor(226, 190, 116, math.floor(22 + 38 * pulse)))
                    -- the downloaded professional microphone icon
                    dxDrawImage(ix, iy, icon, icon, micTex, 0, 0, 0,
                        tocolor(255, 255, 255, 255))
                else
                    -- fallback glyph if the texture did not download
                    dxDrawRectangle(ix + icon * 0.42, iy + icon * 0.22,
                        icon * 0.16, icon * 0.34, tocolor(255, 255, 255, 255))
                    dxDrawLine(ix + icon * 0.30, iy + icon * 0.48,
                        ix + icon * 0.70, iy + icon * 0.48,
                        tocolor(255, 255, 255, 255), 2 * sc)
                end

                -- Explicit MIC label above the head (English, neon cyan).
                dxDrawText("MIC", ix, iy + icon + 2 * sc, ix + icon,
                    iy + icon + 18 * sc, tocolor(230, 245, 255, 255), 1 * sc,
                    "default-bold", "center", "center")
            end
        end
    end
end

addEventHandler("onClientRender", root, drawSpeakingMarkers)
