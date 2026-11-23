--[[
    ng-phone c_phone.lua - modern phone UI (client)
    Home screen with apps: Contacts, Messages, Calls, Bank, Jobs, Ads.
    Open with P.
]]

local RP = exports["ng-rp"]

local phone = nil

-- when the premium CEF phone (luxury_phone) is running, this legacy DX UI
-- stays dormant; the server events (ngp:*) keep working for both
local function luxuryPhoneActive()
    local r = getResourceFromName("luxury_phone")
    return r and getResourceState(r) == "running"
end

bindKey("p", "down", function()
    if luxuryPhoneActive() then return end
    if getElementData(localPlayer, "char.spawned") then
        triggerServerEvent("ngp:open", localPlayer)
    end
end)

local function homeScreen()
    if not phone then return end
    local sw, sh = guiGetScreenSize()
    local pw, ph = 380, 520
    local px, py = math.floor((sw - pw) / 2), math.floor((sh - ph) / 2)
    RP:openWindow("phone", "PHONE  |  " .. tostring(phone.number), px, py, pw, ph)
    RP:windowClear("phone")
    RP:windowLabel("phone", "unread", phone.unread and phone.unread > 0 and (phone.unread .. " unread SMS") or "No unread messages", 0.06, 0.10, 0.88, 0.05, 0.8, tocolor(150, 160, 172, 255), "center", "center")
    local apps = {
        {"CONTACTS", "contacts"}, {"MESSAGES", "messages"},
        {"BANK", "bank"}, {"JOBS", "jobs"},
        {"ADS", "ads"}, {"CLOSE", "close"},
    }
    local pos = {
        {0.06, 0.18}, {0.54, 0.18},
        {0.06, 0.33}, {0.54, 0.33},
        {0.06, 0.48}, {0.54, 0.48},
    }
    for i, app in ipairs(apps) do
        RP:windowButton("phone", app[2], app[1], pos[i][1], pos[i][2], 0.40, 0.12, function()
            openApp(app[2])
        end, app[2] == "close" and tocolor(120, 30, 30, 200) or nil)
    end
    RP:windowLabel("phone", "battery", "Next Generation OS  -  " .. tostring(phone.job):upper(), 0.06, 0.90, 0.88, 0.05, 0.75, tocolor(150, 160, 172, 255), "center", "center")
end

function openApp(app)
    if not phone then return end
    if app == "close" then RP:closeWindow("phone") return end
    RP:openWindow("phoneapp", "PHONE - " .. app:upper(), 780, 250, 380, 520)
    RP:windowClear("phoneapp")

    if app == "contacts" then
        local y = 0.10
        RP:windowEdit("phoneapp", "cname", "", 0.07, 0.78, 0.40, 0.07)
        RP:windowEdit("phoneapp", "cnumber", "", 0.52, 0.78, 0.40, 0.07)
        RP:windowButton("phoneapp", "addc", "+", 0.86, 0.78, 0.07, 0.07, function()
            triggerServerEvent("ngp:addContact", localPlayer, RP:windowGetEdit("phoneapp", "cname"), RP:windowGetEdit("phoneapp", "cnumber"))
        end, tocolor(40, 96, 160, 220))
        if #phone.contacts == 0 then
            RP:windowLabel("phoneapp", "nocon", "No contacts saved.", 0.06, y, 0.88, 0.05, 0.85, tocolor(150, 160, 172, 255), "center", "center")
        end
        for i, c in ipairs(phone.contacts) do
            if i > 8 then break end
            RP:windowLabel("phoneapp", "cn" .. i, c.name .. "  " .. c.number, 0.07, y, 0.60, 0.055, 0.8, nil, "left", "center")
            RP:windowButton("phoneapp", "call" .. i, "CALL", 0.70, y, 0.13, 0.055, function()
                triggerServerEvent("ngp:call", localPlayer, c.number)
            end)
            RP:windowButton("phoneapp", "sms" .. i, "SMS", 0.85, y, 0.08, 0.055, function()
                RP:openWindow("sms", "SMS TO " .. c.name, 800, 350, 340, 220)
                RP:windowClear("sms")
                RP:windowEdit("sms", "text", "", 0.08, 0.16, 0.84, 0.22)
                RP:windowButton("sms", "send", "SEND", 0.08, 0.44, 0.84, 0.14, function()
                    triggerServerEvent("ngp:sendSms", localPlayer, c.number, RP:windowGetEdit("sms", "text"))
                    RP:closeWindow("sms")
                end, tocolor(40, 96, 160, 220))
                RP:windowButton("sms", "cancel", "CANCEL", 0.08, 0.62, 0.84, 0.14, function() RP:closeWindow("sms") end)
            end)
            y = y + 0.062
        end
        RP:windowButton("phoneapp", "back", "BACK", 0.07, 0.88, 0.86, 0.07, homeScreen, tocolor(120, 30, 30, 200))

    elseif app == "messages" then
        triggerServerEvent("ngp:markRead", localPlayer)
        local y = 0.10
        for i, m in ipairs(phone.messages) do
            if i > 9 then break end
            local isIn = m.receiver == tostring(phone.number)
            RP:windowLabel("phoneapp", "m" .. i,
                (isIn and "FROM " or "TO ") .. (isIn and m.sender or m.receiver) .. ": " .. tostring(m.text),
                0.06, y, 0.88, 0.075, 0.75, isIn and tocolor(74, 163, 255, 255) or tocolor(150, 160, 172, 255), "left", "top")
            y = y + 0.082
        end
        RP:windowEdit("phoneapp", "sendTo", "", 0.07, 0.84, 0.30, 0.07)
        RP:windowEdit("phoneapp", "sendTxt", "", 0.39, 0.84, 0.45, 0.07)
        RP:windowButton("phoneapp", "sendsms", "SMS", 0.86, 0.84, 0.07, 0.07, function()
            triggerServerEvent("ngp:sendSms", localPlayer, RP:windowGetEdit("phoneapp", "sendTo"), RP:windowGetEdit("phoneapp", "sendTxt"))
        end, tocolor(40, 96, 160, 220))
        RP:windowButton("phoneapp", "back", "BACK", 0.07, 0.92, 0.86, 0.07, homeScreen, tocolor(120, 30, 30, 200))

    elseif app == "bank" then
        RP:windowLabel("phoneapp", "b1", "Bank balance: $" .. tostring(phone.balance), 0.06, 0.16, 0.88, 0.07, 1.0, tocolor(64, 178, 96, 255), "center", "center")
        RP:windowLabel("phoneapp", "b2", "Cash on hand: $" .. tostring(phone.cash), 0.06, 0.24, 0.88, 0.07, 0.95, nil, "center", "center")
        RP:windowLabel("phoneapp", "b3", "Use any ATM in the city for deposits and withdrawals.", 0.06, 0.34, 0.88, 0.06, 0.8, tocolor(150, 160, 172, 255), "center", "center")
        RP:windowButton("phoneapp", "back", "BACK", 0.07, 0.88, 0.86, 0.07, homeScreen, tocolor(120, 30, 30, 200))

    elseif app == "jobs" then
        RP:windowLabel("phoneapp", "j0", "Your job: " .. tostring(phone.job), 0.06, 0.12, 0.88, 0.06, 0.95, tocolor(74, 163, 255, 255), "center", "center")
        local lines = {
            "Taxi driver   - Unity Station  (1799.2, -1929.6)",
            "Truck driver  - El Corona depot (2494.6, -1970.8)",
            "Courier       - Unity Station courier office",
            "Mechanic      - LS garage (1033.3, -1317.0)",
            "Fisher        - Ocean Docks (2340.0, -1800.0)",
            "Trader        - Idlewood market (1352.0, -1757.0)",
        }
        local y = 0.22
        for _, l in ipairs(lines) do
            RP:windowLabel("phoneapp", "jl" .. y, l, 0.06, y, 0.88, 0.05, 0.8, nil, "left", "center")
            y = y + 0.055
        end
        RP:windowLabel("phoneapp", "jnote", "Visit the Job Center at Unity Station to switch jobs.", 0.06, y + 0.02, 0.88, 0.05, 0.8, tocolor(150, 160, 172, 255), "center", "center")
        RP:windowButton("phoneapp", "back", "BACK", 0.07, 0.88, 0.86, 0.07, homeScreen, tocolor(120, 30, 30, 200))

    elseif app == "ads" then
        RP:windowLabel("phoneapp", "a1", "Server-wide ad - $200", 0.06, 0.14, 0.88, 0.06, 0.95, nil, "center", "center")
        RP:windowEdit("phoneapp", "adtext", "", 0.08, 0.22, 0.84, 0.18)
        RP:windowButton("phoneapp", "adgo", "PUBLISH", 0.08, 0.44, 0.84, 0.12, function()
            triggerServerEvent("ngp:sendAd", localPlayer, RP:windowGetEdit("phoneapp", "adtext"))
            RP:closeWindow("phoneapp")
        end, tocolor(40, 96, 160, 220))
        RP:windowButton("phoneapp", "back", "BACK", 0.08, 0.60, 0.84, 0.12, homeScreen, tocolor(120, 30, 30, 200))
    end
end

addEvent("ngp:showPhone", true)
addEventHandler("ngp:showPhone", root, function(data)
    if luxuryPhoneActive() then return end
    phone = data
    RP:closeWindow("phoneapp")
    homeScreen()
end)

addEvent("ngp:status", true)
addEventHandler("ngp:status", root, function(text, ok)
    if luxuryPhoneActive() then return end
    RP:notify(text, ok and 64 or 214, ok and 178 or 61, ok and 96 or 61)
end)

addEvent("ngp:incoming", true)
addEventHandler("ngp:incoming", root, function(number)
    if luxuryPhoneActive() then return end
    RP:notify("Incoming call from " .. tostring(number), 74, 163, 255)
end)

addEvent("ngp:callEnded", true)
addEventHandler("ngp:callEnded", root, function()
    if luxuryPhoneActive() then return end
    RP:notify("Call ended.", 200, 200, 200)
end)
