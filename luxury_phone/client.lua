--[[
    luxury_phone client.lua - iFruit style phone UI (CEF browser)
    - opens with P (same key as the legacy phone; legacy UI is dormant
      while this resource runs)
    - 3D phone object in hand (server side, others can see it)
    - reuses ng-phone server events for contacts/SMS/calls/ads
]]

local sw, sh = guiGetScreenSize()
-- responsive phone size (scales with screen, keeps aspect ratio)
local H = math.floor(math.min(sh * 0.84, 760))
H = math.max(H, 480)
local W = math.floor(H * (400 / 720))
local margin = 20
if W > sw - margin * 2 then
    W = sw - margin * 2
    H = math.floor(W * (720 / 400))
end
local bx, by = sw - W - margin, math.floor((sh - H) / 2)

local browserGui, browser
local isOpen = false
local settingsReady = false
local myWaypoint
-- keep the last server payloads so a freshly loaded page can be re-synced
local lastPhoneData, lastSettingsData

local SOUNDS = { click = true, notify = true, call = true, unlock = true, shutter = true, message = true }
local sfxSettings = {}
local function playSfx(name)
    if not SOUNDS[name] then return end
    local vol = 0.5
    if sfxSettings and sfxSettings.volume then vol = (sfxSettings.volume / 100) end
    local snd = playSound("assets/" .. name .. ".wav")
    if snd then setSoundVolume(snd, vol) end
end

-- ============================== browser ==============================

local function emit(action, data)
    if not browser then return end
    local js = string.format("window.__luxAction('%s', %s)", tostring(action), toJSON(data or {}, true))
    executeBrowserJavascript(browser, js)
end

local function createBrowser()
    -- CEF browsers created with isLocal=true can ONLY load resource files
    -- through http://mta/local/. The old url1 (http://mta/luxury_phone/...)
    -- is the remote HTTP-server form and stalled; the old 4s retry then
    -- aborted it in flight, which is exactly the ERR_ABORTED error.
    -- One correct URL, no retry, no abort.
    local url = "http://mta/local/ui/index.html"
    local pageReady = false

    browserGui = guiCreateBrowser(bx, by, W, H, true, true, false)
    browser = browserGui and guiGetBrowser(browserGui) or nil
    if not browser then
        outputChatBox("[luxury_phone] Could not create the CEF browser.", 214, 61, 61)
        return
    end
    guiSetVisible(browserGui, false)

    addEventHandler("onClientBrowserCreated", browser, function()
        local ok = loadBrowserURL(browser, url)
        triggerServerEvent("lxp:diag", localPlayer,
            "browser created, load=" .. tostring(ok) .. " (" .. url .. ")")
    end)
    addEventHandler("onClientBrowserLoadingStart", browser, function(loadedUrl)
        triggerServerEvent("lxp:diag", localPlayer, "loading: " .. tostring(loadedUrl))
    end)
    -- NB: this event only passes the loaded url
    addEventHandler("onClientBrowserDocumentReady", browser, function(loadedUrl)
        pageReady = true
        triggerServerEvent("lxp:diag", localPlayer, "document ready: " .. tostring(loadedUrl))
        executeBrowserJavascript(browser, "document.body.classList.add('ready'); if(window.__luxReady) window.__luxReady();")
        if lastPhoneData then emit("phone", lastPhoneData) end
        if lastSettingsData then emit("settings", lastSettingsData) end
    end)
    addEventHandler("onClientBrowserLoadingFailed", browser, function(...)
        local failedUrl, code, desc = ...
        triggerServerEvent("lxp:diag", localPlayer,
            "load failed: " .. tostring(failedUrl) .. " / " .. tostring(code) .. " / " .. tostring(desc))
        -- ERR_ABORTED (-3) is caused by a cancelled/superseded load. With the
        -- retry removed it should not happen; do not show a false error.
        if tostring(code) == "-3" or tostring(desc) == "ERR_ABORTED" then return end
        outputChatBox("[luxury_phone] UI failed to load (" .. tostring(desc or code) .. ").", 214, 61, 61)
    end)
    -- A cold CEF start can take tens of seconds to fetch CSS/JS; 9s was a
    -- false alarm. Report only when loading has stopped without "ready".
    setTimer(function()
        if pageReady or not browser then return end
        if isBrowserLoading(browser) then
            triggerServerEvent("lxp:diag", localPlayer, "slow load: still loading after 45s")
            return
        end
        outputChatBox("[luxury_phone] UI failed to load - press F8 and report.", 214, 61, 61)
        triggerServerEvent("lxp:diag", localPlayer, "timeout: page never became ready")
    end, 45000, 1)
end

local function showBrowser()
    if not browser or not browserGui then createBrowser() end
    if not browser or not browserGui then
        outputChatBox("[luxury_phone] UI unavailable - reconnect and try again.", 214, 61, 61)
        return
    end
    isOpen = true
    guiSetVisible(browserGui, true)
    setBrowserRenderingPaused(browser, false)
    focusBrowser(browser, true)
    showCursor(true)
    triggerServerEvent("ngp:hand", localPlayer, true)
    playSfx("unlock")
end

function closeUI()
    if not isOpen then return end
    isOpen = false
    guiSetVisible(browserGui, false)
    setBrowserRenderingPaused(browser, true)
    focusBrowser(browser, false)
    showCursor(false)
    triggerServerEvent("ngp:hand", localPlayer, false)
end

-- ============================== open flow ==============================

local function requestOpen()
    if not getElementData(localPlayer, "char.spawned") then
        outputChatBox("[PHONE] spawn your character first.", 212, 175, 55)
        return
    end
    if isOpen then
        closeUI()
        return
    end
    -- make sure no other luxury UI is in front
    local invRes = getResourceFromName("gta4inver")
    if invRes and getResourceState(invRes) == "running" then
        pcall(function() exports.gta4inver:closeInventorySilent() end)
    end
    outputChatBox("[PHONE] opening...", 212, 175, 55)
    triggerServerEvent("ngp:open", localPlayer)
end

bindKey("p", "down", requestOpen)
addCommandHandler("phone", requestOpen)

-- pages report their own JS errors back to the server log
addEvent("lxp:bridge", true)
addEventHandler("lxp:bridge", root, function(msg)
    triggerServerEvent("lxp:diag", localPlayer, "page: " .. tostring(msg))
end)

-- server-driven open (remote testing / admin tools)
addEvent("lxp:openReq", true)
addEventHandler("lxp:openReq", root, requestOpen)

addEvent("ngp:showPhone", true)
addEventHandler("ngp:showPhone", root, function(data)
    lastPhoneData = data
    if not isOpen then showBrowser() end
    emit("phone", data)
    if not settingsReady then
        triggerServerEvent("lxp:getSettings", localPlayer)
    else
        emit("settings", sfxSettings)
    end
end)

addEvent("lxp:settings", true)
addEventHandler("lxp:settings", root, function(data)
    settingsReady = true
    sfxSettings = data or {}
    lastSettingsData = sfxSettings
    emit("settings", sfxSettings)
end)

-- ============================== incoming / sms ==============================

addEvent("ngp:incoming", true)
addEventHandler("ngp:incoming", root, function(number)
    if not isOpen then showBrowser() end
    emit("incoming", { number = tostring(number) })
    playSfx(sfxSettings.ringtone == "message" and "message" or "call")
end)

addEvent("ngp:callEnded", true)
addEventHandler("ngp:callEnded", root, function()
    emit("callEnded", {})
end)

addEvent("ngp:smsReceived", true)
addEventHandler("ngp:smsReceived", root, function(from, text)
    playSfx("message")
    if isOpen then
        emit("sms", { from = tostring(from), text = tostring(text) })
    end
end)

addEvent("lxp:status", true)
addEventHandler("lxp:status", root, function(text, ok)
    if isOpen then
        emit("toast", { text = tostring(text), ok = ok ~= false })
    else
        outputChatBox("[PHONE] " .. tostring(text), 74, 163, 255)
    end
    playSfx("notify")
end)

-- ============================== app data ==============================

addEvent("lxp:bankData", true)
addEventHandler("lxp:bankData", root, function(cash, bank, transactions)
    emit("bank", { cash = cash, bank = bank, transactions = transactions or {} })
end)

addEvent("lxp:vehicles", true)
addEventHandler("lxp:vehicles", root, function(vehicles)
    emit("vehicles", { vehicles = vehicles or {} })
end)

-- ============================== UI -> Lua ==============================

addEvent("lxp:ui", true)
addEventHandler("lxp:ui", root, function(action, argsJson)
    if not isOpen then return end
    local ok, args = pcall(fromJSON, tostring(argsJson or "{}"))
    if not ok or type(args) ~= "table" then args = {} end

    if action == "click" then
        playSfx("click")

    elseif action == "close" then
        closeUI()

    elseif action == "markRead" then
        triggerServerEvent("ngp:markRead", localPlayer)

    elseif action == "addContact" then
        triggerServerEvent("ngp:addContact", localPlayer, args.name, args.number)

    elseif action == "deleteContact" then
        triggerServerEvent("ngp:deleteContact", localPlayer, args.number)

    elseif action == "sendSms" then
        triggerServerEvent("ngp:sendSms", localPlayer, args.number, args.text)
        playSfx("message")

    elseif action == "call" then
        triggerServerEvent("ngp:call", localPlayer, args.number)
        playSfx("call")

    elseif action == "hangup" then
        triggerServerEvent("ngp:hangup", localPlayer)

    elseif action == "sendAd" then
        triggerServerEvent("ngp:sendAd", localPlayer, args.text)

    elseif action == "bankData" then
        triggerServerEvent("lxp:bank", localPlayer)

    elseif action == "transfer" then
        triggerServerEvent("lxp:transfer", localPlayer, args.name, args.amount)

    elseif action == "vehicles" then
        triggerServerEvent("lxp:vehicles", localPlayer)

    elseif action == "vehAction" then
        triggerServerEvent("lxp:vehAction", localPlayer, args.id, args.do_action)

    elseif action == "service" then
        triggerServerEvent("lxp:service", localPlayer, args.service)

    elseif action == "waypoint" then
        setWaypointLocal(tonumber(args.x), tonumber(args.y), tonumber(args.z), tostring(args.name or "Waypoint"))
        playSfx("notify")

    elseif action == "photo" then
        playSfx("shutter")
        triggerServerEvent("lxp:photo", localPlayer)

    elseif action == "saveSettings" then
        triggerServerEvent("lxp:setSettings", localPlayer, toJSON(args, true))

    elseif action == "openInventory" then
        closeUI()
        local invRes = getResourceFromName("gta4inver")
        if invRes and getResourceState(invRes) == "running" then
            pcall(function() exports.gta4inver:openInventory() end)
        end

    elseif action == "close" then
        closeUI()
    end
end)

-- ============================== GPS waypoints ==============================

function setWaypointLocal(x, y, z, name)
    if not x or not y then return end
    if myWaypoint and isElement(myWaypoint) then destroyElement(myWaypoint) end
    myWaypoint = createBlip(x, y, z, 0, 3, 212, 175, 55, 255)
    outputChatBox("[GPS] Route set: " .. name .. " (" .. string.format("%.0f, %.0f", x, y) .. ").", 212, 175, 55)
end

-- ============================== camera photo ==============================

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function toBase64(data)
    return ((data:gsub(".", function(x)
        local r, b = "", x:byte()
        for i = 8, 1, -1 do
            r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
        end
        return r
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if #x < 6 then return "" end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0) end
        return b64chars:sub(c + 1, c + 1)
    end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

addEvent("lxp:photoData", true)
addEventHandler("lxp:photoData", root, function(pixels)
    if not pixels then return end
    local ok, b64 = pcall(toBase64, pixels)
    if ok and isOpen then
        emit("photo", { data = "data:image/jpeg;base64," .. b64 })
    end
end)

-- ============================== misc ==============================

addEventHandler("onClientPlayerWasted", localPlayer, function()
    closeUI()
end)
addEventHandler("onClientElementDataChange", localPlayer, function(key)
    if key == "char.spawned" and not getElementData(localPlayer, "char.spawned") then
        closeUI()
    end
end)

outputDebugString("[luxury_phone] client UI armed (P)")
