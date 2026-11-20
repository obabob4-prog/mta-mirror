--[[
    gta4inver client.lua - GTA V premium inventory UI (CEF browser)
    - 1280x720 CEF panel, full drag & drop grid
    - Use/Drop go straight to the ORIGINAL ng-inventory server events
      (ngi:use / ngi:drop / ngi:give) so effects, markers and gives
      behave exactly like before
    - quickslots on keys F2..F6 (F7/F9 are taken by the HUD, F8 is the console)
    - cross-link: phone can open/close this UI, we can open the phone
]]

local sw, sh = guiGetScreenSize()
-- responsive inventory size (preserve 16:9 layout, scale to fit screen)
local baseW, baseH = 1280, 720
local scale = math.min((sw * 0.92) / baseW, (sh * 0.90) / baseH, 1.0)
if scale < 0.5 then scale = 0.5 end
local W, H = math.floor(baseW * scale), math.floor(baseH * scale)
local bx, by = math.floor((sw - W) / 2), math.floor((sh - H) / 2)

local browserGui, browser
local isOpen = false
local currentPayload = nil

-- remember which action key to use after a UI action (use/drop/give)
local function emit(action, args)
    if not browser then return end
    local js = string.format("window.__luxAction('%s', %s)",
        tostring(action), toJSON(args or {}, true))
    executeBrowserJavascript(browser, js)
end

local function updateCursor()
    showCursor(isOpen)
end

-- ============================== lifecycle ==============================

local function createBrowser()
    -- CEF browsers created with isLocal=true can ONLY load resource files
    -- through http://mta/local/. The old url1 (http://mta/gta4inver/...) is
    -- the remote HTTP-server form and stalled; the old 4s retry then aborted
    -- that in-flight load, which is exactly the ERR_ABORTED error players saw.
    -- One correct URL, no retry, no abort.
    local url = "http://mta/local/ui2/index.html"
    local pageReady = false

    browserGui = guiCreateBrowser(bx, by, W, H, true, true, false)
    browser = browserGui and guiGetBrowser(browserGui) or nil
    if not browser then
        outputChatBox("[gta4inver] Could not create the CEF browser.", 214, 61, 61)
        return
    end
    guiSetVisible(browserGui, false)

    addEventHandler("onClientBrowserCreated", browser, function()
        local ok = loadBrowserURL(browser, url)
        triggerServerEvent("gta4i:diag", localPlayer,
            "browser created, load=" .. tostring(ok) .. " (" .. url .. ")")
    end)
    addEventHandler("onClientBrowserLoadingStart", browser, function(loadedUrl)
        triggerServerEvent("gta4i:diag", localPlayer, "loading: " .. tostring(loadedUrl))
    end)
    -- NB: this event only passes the loaded url
    addEventHandler("onClientBrowserDocumentReady", browser, function(loadedUrl)
        pageReady = true
        triggerServerEvent("gta4i:diag", localPlayer, "document ready: " .. tostring(loadedUrl))
        -- Match the DOM layout to the 1280x720 design inside the scaled
        -- browser: without this zoom the fixed-pixel CSS overflows and the
        -- whole F1 panel looks stretched/cropped on non-1080p screens.
        local z = string.format("%.4f", scale)
        executeBrowserJavascript(browser,
            "document.documentElement.style.zoom=" .. z ..
            ";document.body.style.zoom=" .. z .. ";")
        executeBrowserJavascript(browser,
            "document.body.classList.add('ready'); if(window.__luxReady) window.__luxReady();")
        -- re-inject the last payload so a hot restart keeps the view alive
        if currentPayload then emit("state", currentPayload) end
    end)
    addEventHandler("onClientBrowserLoadingFailed", browser, function(...)
        local failedUrl, code, desc = ...
        triggerServerEvent("gta4i:diag", localPlayer,
            "load failed: " .. tostring(failedUrl) .. " / " .. tostring(code) .. " / " .. tostring(desc))
        -- ERR_ABORTED (-3) means a load was cancelled/superseded. With the
        -- retry removed this should no longer happen; stay silent instead of
        -- showing a false error to the player.
        if tostring(code) == "-3" or tostring(desc) == "ERR_ABORTED" then return end
        outputChatBox("[gta4inver] UI failed to load (" .. tostring(desc or code) .. ").", 214, 61, 61)
    end)

    -- Last-resort feedback. A cold CEF start (first open after joining) can
    -- take tens of seconds to fetch the CSS/JS, so 9s was a false alarm.
    -- Stay quiet while the page is still downloading; only warn when the
    -- browser has stopped and never reached "ready".
    setTimer(function()
        if pageReady or not browser then return end
        if isBrowserLoading(browser) then
            triggerServerEvent("gta4i:diag", localPlayer, "slow load: still loading after 45s")
            return
        end
        outputChatBox("[gta4inver] UI failed to load - press F8 and report.", 214, 61, 61)
        triggerServerEvent("gta4i:diag", localPlayer, "timeout: page never became ready")
    end, 45000, 1)

    -- short-lived diagnostics: report the browser state to the server log
    local probes = 0
    local probeTimer
    probeTimer = setTimer(function()
        probes = probes + 1
        if not browser then return end
        triggerServerEvent("gta4i:diag", localPlayer,
            "state " .. probes .. ": url=" .. tostring(getBrowserURL(browser))
            .. " loading=" .. tostring(isBrowserLoading(browser)))
        if probes >= 5 then
            if isTimer(probeTimer) then killTimer(probeTimer) end
        end
    end, 3000, 0)
end

local function hideBrowser()
    if not browserGui then return end
    isOpen = false
    guiSetVisible(browserGui, false)
    setBrowserRenderingPaused(browser, true)
    focusBrowser(browser, false)
    updateCursor()
    setElementData(localPlayer, "gta4i.open", false)
end

-- browsers load reliably while they are visible, so create it on first open
local function ensureBrowser()
    if browser and browserGui then return true end
    createBrowser()
    return browser ~= nil
end

function openInventory()
    if isOpen then return end
    if not getElementData(localPlayer, "char.spawned") then return end
    if not ensureBrowser() then return end
    -- never two luxury UIs at once
    local phoneRes = getResourceFromName("luxury_phone")
    if phoneRes and getResourceState(phoneRes) == "running" then
        pcall(function() exports.luxury_phone:closeUI() end)
    end
    triggerServerEvent("ngp:hand", localPlayer, false)
    isOpen = true
    setElementData(localPlayer, "gta4i.open", true)
    triggerServerEvent("gta4i:open", localPlayer)
    guiSetVisible(browserGui, true)
    setBrowserRenderingPaused(browser, false)
    focusBrowser(browser, true)
    updateCursor()
    outputChatBox("[INVENTORY] opening...", 212, 175, 55)
    playSound("ui/click.wav")
end

function closeInventory()
    if not isOpen then return end
    hideBrowser()
    playSound("ui/close.wav")
end

function closeInventorySilent()
    if isOpen then hideBrowser() end
end

-- ============================== server -> UI ==============================

addEvent("gta4i:show", true)
addEventHandler("gta4i:show", root, function(payload)
    currentPayload = payload
    emit("state", payload)
end)

-- ============================== UI -> server ==============================

addEvent("gta4i:ui", true)
addEventHandler("gta4i:ui", root, function(action, argsJson)
    if not isOpen then return end
    local ok, args = pcall(fromJSON, tostring(argsJson or "{}"))
    if not ok or type(args) ~= "table" then args = {} end

    local function payloadItem(id)
        for _, it in ipairs(currentPayload and currentPayload.items or {}) do
            if it.id == tonumber(id) then return it end
        end
        return nil
    end

    if action == "use" then
        local it = payloadItem(args.id)
        if it then
            triggerServerEvent("ngi:use", localPlayer, it.item)
            setTimer(function() triggerServerEvent("gta4i:open", localPlayer) end, 250, 1)
        end

    elseif action == "drop" then
        local it = payloadItem(args.id)
        if it then
            triggerServerEvent("ngi:drop", localPlayer, it.item)
            setTimer(function() triggerServerEvent("gta4i:open", localPlayer) end, 250, 1)
        end

    elseif action == "give" then
        local it = payloadItem(args.id)
        if it then
            -- nearest player within 3.5m (server re-validates the distance)
            local px, py, pz = getElementPosition(localPlayer)
            local best, bd
            for _, p in ipairs(getElementsByType("player")) do
                if p ~= localPlayer and getElementData(p, "char.spawned") then
                    local x2, y2, z2 = getElementPosition(p)
                    local d = getDistanceBetweenPoints3D(px, py, pz, x2, y2, z2)
                    if d < 3.5 and (not bd or d < bd) then best, bd = p, d end
                end
            end
            if not best then
                emit("toast", { text = "No player nearby.", ok = false })
                return
            end
            triggerServerEvent("ngi:give", localPlayer, it.item, getPlayerName(best))
            setTimer(function() triggerServerEvent("gta4i:open", localPlayer) end, 250, 1)
        end

    elseif action == "split" then
        triggerServerEvent("gta4i:split", localPlayer, args.id, args.amount)

    elseif action == "merge" then
        triggerServerEvent("gta4i:merge", localPlayer, args.srcId, args.dstId)

    elseif action == "move" then
        triggerServerEvent("gta4i:move", localPlayer, args.id, args.slot)

    elseif action == "setQuick" then
        triggerServerEvent("gta4i:setQuick", localPlayer, args.index, args.item)

    elseif action == "clearQuick" then
        triggerServerEvent("gta4i:setQuick", localPlayer, args.index, nil)

    elseif action == "storageDeposit" then
        triggerServerEvent("gta4i:storageMove", localPlayer, "deposit", args.ctx, args.item, args.amount)

    elseif action == "storageWithdraw" then
        triggerServerEvent("gta4i:storageMove", localPlayer, "withdraw", args.ctx, args.item, args.amount)

    elseif action == "openPhone" then
        closeInventorySilent()
        triggerServerEvent("ngp:open", localPlayer)
        playSound("ui/click.wav")

    elseif action == "close" then
        closeInventory()
    end
end)

-- ============================== quickslot keys ==============================

local QUICK_KEYS = { "F2", "F3", "F4", "F5", "F6" }
for i, key in ipairs(QUICK_KEYS) do
    bindKey(key, "down", function()
        if not getElementData(localPlayer, "char.spawned") then return end
        local qs = currentPayload and currentPayload.quickslots or {}
        local item = qs[i]
        if item then
            triggerServerEvent("ngi:use", localPlayer, tostring(item))
            setTimer(function() triggerServerEvent("gta4i:open", localPlayer) end, 250, 1)
        else
            emit("toast", { text = "Quickslot " .. i .. " is empty (assign it in the inventory).", ok = false })
        end
    end)
end

-- ============================== keys / lifecycle ==============================

bindKey("F1", "down", function()
    if isOpen then closeInventory() else openInventory() end
end)
bindKey("i", "down", function()
    if isOpen then closeInventory() else openInventory() end
end)

-- chat fallback: some clients block the "i" bind while the chatbox is focused
addCommandHandler("inv", function()
    if isOpen then closeInventory() else openInventory() end
end)
addCommandHandler("inventory", function()
    if isOpen then closeInventory() else openInventory() end
end)

-- pages report their own JS errors back to the server log
addEvent("gta4i:bridge", true)
addEventHandler("gta4i:bridge", root, function(msg)
    triggerServerEvent("gta4i:diag", localPlayer, "page: " .. tostring(msg))
end)

-- server-driven open (used for remote testing / admin tools)
addEvent("gta4i:openReq", true)
addEventHandler("gta4i:openReq", root, function()
    outputChatBox("[INVENTORY] opening...", 212, 175, 55)
    openInventory()
end)

addEventHandler("onClientPlayerWasted", localPlayer, function()
    closeInventorySilent()
end)
addEventHandler("onClientElementDataChange", localPlayer, function(key)
    if key == "char.spawned" and not getElementData(localPlayer, "char.spawned") then
        closeInventorySilent()
    end
end)

outputDebugString("[gta4inver] client UI armed (F1 / I)")
