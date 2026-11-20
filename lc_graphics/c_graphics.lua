-- ============================================================
--  lc_graphics / client
--  Subtle screen-space unsharp mask for Liberty City.
--
--  Why it exists: the LC conversion ships 6,516 textures, 90% of
--  them 64x64 / 128x128, and 97% with a single mip level, so the
--  mapping filter has nothing to blend and facades read as soft.
--  This pass restores local contrast at render time; it never
--  touches the source art and can be switched off at any moment.
--
--  Commands:
--    /lchq            state + help
--    /lchq on|off     enable / disable for this client
--    /lchq 0.1..0.6   sharpen strength (default 0.28)
--
--  Safety:
--    * shader compile failure  -> effect disables itself
--    * self benchmark          -> compares FPS with / without the
--                                 effect and switches itself off if
--                                 the cost is noticeable
--    * login park              -> no pass while the player sits at
--                                 0,0,0 behind the login screen
-- ============================================================

local DEFAULT_STRENGTH = 0.28
-- 2026-11-18: the fullscreen unsharp pass was the SOURCE of the reported
-- building blur (feedback capture + repeated fullscreen resampling), not the
-- LC TXDs (txd.img is byte-identical to the upstream original). Keep the
-- effect available, but start in the known-good vanilla state. /lchq on
-- still enables the CORRECTED pass for clients who want to try it.
local DEFAULT_ENABLED = false

local screenW, screenH = guiGetScreenSize()
local shader, screenSource
local enabled = DEFAULT_ENABLED
local strength = DEFAULT_STRENGTH
local ready = false
local failed = false
local lastW, lastH
local autoDisabled = false

-- frame accounting for the benchmark / live guard
local frames = 0
local framesAtWindowStart = 0
local windowStart = getTickCount()

-- login park gate
local gated = false

local function sendLog(text)
    if triggerServerEvent then
        triggerServerEvent("lcGraphics:log", localPlayer, text)
    end
end

local function setShaderSize(w, h)
    if not shader then return end
    lastW, lastH = w, h
    dxSetShaderValue(shader, "texelSize", 1.0 / w, 1.0 / h)
end

local function makeScreenSource(w, h)
    if isElement(screenSource) then
        destroyElement(screenSource)
    end
    screenSource = dxCreateScreenSource(w, h)
    if not isElement(screenSource) then
        failed = true
        outputDebugString("[lc_graphics] could not create screenSource; effect disabled", 2)
        sendLog("screenSource create failed")
        return false
    end
    if isElement(shader) then
        dxSetShaderValue(shader, "ScreenTexture", screenSource)
    end
    return true
end

local function createResources()
    if failed then return end
    if not screenW or not screenH or screenW <= 0 or screenH <= 0 then
        screenW, screenH = guiGetScreenSize()
    end
    local w, h = screenW, screenH
    if not isElement(screenSource) then
        if not makeScreenSource(w, h) then return end
    end
    if not isElement(shader) then
        shader = dxCreateShader("sharpen.fx")
        if not isElement(shader) then
            failed = true
            outputDebugString("[lc_graphics] could not create sharpen.fx; effect disabled", 2)
            sendLog("shader create failed")
            return
        end
        dxSetShaderValue(shader, "ScreenTexture", screenSource)
        dxSetShaderValue(shader, "strength", strength)
        setShaderSize(w, h)
    end
    ready = isElement(shader) and isElement(screenSource)
end

-- A resolution change used to leave a stale-sized screenSource bound to the
-- shader. Rebuild it instead of only changing texelSize.
local function syncResolution()
    if not screenW or not screenH then return end
    local w, h = guiGetScreenSize()
    if w == screenW and h == screenH then return end
    screenW, screenH = w, h
    if isElement(screenSource) then
        makeScreenSource(w, h)
        ready = isElement(shader) and isElement(screenSource)
    end
    setShaderSize(w, h)
end

local function updateGate()
    if not isElement(localPlayer) then
        gated = true
        return
    end
    local x, y, z = getElementPosition(localPlayer)
    -- the login scene parks the player at the origin; nothing to sharpen there
    gated = (math.abs(x) < 30) and (math.abs(y) < 30) and (z < 10)
end

local function render()
    if not enabled or failed or autoDisabled then return end
    frames = frames + 1
    if gated then return end
    syncResolution()
    if not ready then createResources() end
    if not ready then return end
    -- true = capture the CURRENT frame before drawing the fullscreen quad.
    -- The old default captured the PREVIOUS (already post-processed) frame,
    -- so the unsharp mask fed back into itself every frame and softened the
    -- whole picture instead of sharpening it.
    dxUpdateScreenSource(screenSource, true)
    dxDrawImage(0, 0, screenW, screenH, shader)
end

local function windowFps()
    local now = getTickCount()
    local elapsed = (now - windowStart) / 1000
    if elapsed < 0.5 then return nil end
    local fps = (frames - framesAtWindowStart) / elapsed
    windowStart = now
    framesAtWindowStart = frames
    return fps
end

local function setEnabled(state)
    enabled = state
end

-- Benchmark: 4 s with the pass, 4 s without, then keep whichever choice
-- the numbers support. Runs once, a few seconds after the resource starts.
local function benchmark()
    local fpsOn = windowFps()
    setEnabled(false)
    setTimer(function()
        local fpsOff = windowFps()
        setEnabled(true)
        if not fpsOn or not fpsOff or fpsOff <= 0 then
            sendLog(string.format("benchmark skipped (fpsOn=%s fpsOff=%s)",
                tostring(fpsOn), tostring(fpsOff)))
            return
        end
        local ratio = fpsOn / fpsOff
        if ratio < 0.85 then
            autoDisabled = true
            outputChatBox(string.format(
                "#d4af37[LC Graphics] #ffffffSharpen switched off automatically (%.0f -> %.0f fps). Use /lchq on to force it.",
                fpsOff, fpsOn), 255, 255, 255, true)
            sendLog(string.format("benchmark: fpsOn=%.1f fpsOff=%.1f ratio=%.2f -> auto-disabled", fpsOn, fpsOff, ratio))
        else
            sendLog(string.format("benchmark: fpsOn=%.1f fpsOff=%.1f ratio=%.2f -> kept on", fpsOn, fpsOff, ratio))
        end
    end, 4000, 1)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    screenW, screenH = guiGetScreenSize()
    if enabled then createResources() end
    if isElement(shader) then
        dxSetShaderValue(shader, "strength", strength)
    end
    addEventHandler("onClientRender", root, render, true, "low-5")
    updateGate()
    setTimer(updateGate, 1000, 0)
    if enabled then
        setTimer(function()
            if failed or not isElement(shader) then return end
            windowFps()          -- reset the window before measuring
            benchmark()
        end, 6000, 1)
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    removeEventHandler("onClientRender", root, render)
    if isElement(shader) then destroyElement(shader) end
    if isElement(screenSource) then destroyElement(screenSource) end
    shader, screenSource, ready = nil, nil, false
end)

local function printState()
    outputChatBox(string.format(
        "#d4af37[LC Graphics] #ffffffState: %s%s   Strength: %.2f   (usage: /lchq on | off | 0.1-0.6)",
        enabled and "ON" or "OFF",
        autoDisabled and " (auto-disabled for performance)" or "",
        strength
    ), 255, 255, 255, true)
end

addCommandHandler("lchq", function(_, _, arg)
    if not arg or arg == "" then
        printState()
        return
    end
    arg = tostring(arg):lower()
    if arg == "on" then
        autoDisabled = false
        failed = false
        enabled = true
        createResources()
        if isElement(shader) then dxSetShaderValue(shader, "strength", strength) end
        outputChatBox("#d4af37[LC Graphics] #ffffffSharpen enabled.", 255, 255, 255, true)
    elseif arg == "off" then
        enabled = false
        outputChatBox("#d4af37[LC Graphics] #ffffffSharpen disabled (vanilla look).", 255, 255, 255, true)
    else
        local v = tonumber(arg)
        if v then
            v = math.max(0.0, math.min(0.6, v))
            strength = v
            enabled = v > 0
            autoDisabled = false
            if isElement(shader) then dxSetShaderValue(shader, "strength", strength) end
            outputChatBox(string.format("#d4af37[LC Graphics] #ffffffStrength set to %.2f.", strength), 255, 255, 255, true)
        else
            printState()
        end
    end
end)
