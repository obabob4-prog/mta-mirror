--[[
    ng-jobs c_jobs.lua - Job Center UI (client)
]]

local RP = exports["ng-rp"]

local JOBS_INFO = {
    { job = "taxi",     title = "TAXI DRIVER",   desc = "Drive fares around Liberty City. $90 per stop." },
    { job = "trucker",  title = "TRUCK DRIVER",  desc = "Haul cargo across the city. $170 per stop." },
    { job = "delivery", title = "COURIER",       desc = "Fast deliveries by bike. $60 per stop." },
    { job = "mechanic", title = "MECHANIC",      desc = "Roadside repairs and tow duty. $120 per stop." },
    { job = "fisher",   title = "FISHER",        desc = "Work the Liberty Docks. $45 per catch." },
    { job = "trader",   title = "TRADER",        desc = "Move goods between markets. $130 per stop." },
    { job = "unemployed", title = "UNEMPLOYED",  desc = "Collect basic unemployment pay ($250)." },
}

addEvent("ngj:showJobCenter", true)
addEventHandler("ngj:showJobCenter", root, function(currentJob)
    RP:openWindow("jobs", "LIBERTY CITY JOB CENTER", 700, 200, 540, 620)
    RP:windowClear("jobs")
    RP:windowLabel("jobs", "cur", "Current job: " .. tostring(currentJob), 0.06, 0.09, 0.88, 0.05, 0.9, tocolor(74, 163, 255, 255), "center", "center")
    local y = 0.16
    for _, j in ipairs(JOBS_INFO) do
        RP:windowButton("jobs", "j_" .. j.job, j.title, 0.06, y, 0.30, 0.075, function()
            triggerServerEvent("ngj:pickJob", localPlayer, j.job)
        end, j.job == currentJob and tocolor(40, 96, 160, 200) or nil)
        RP:windowLabel("jobs", "d_" .. j.job, j.desc, 0.38, y, 0.58, 0.075, 0.8, tocolor(150, 160, 172, 255), "left", "center")
        y = y + 0.09
    end
    RP:windowLabel("jobs", "note", "Police & medic roles are assigned by server administration.", 0.06, y + 0.01, 0.88, 0.05, 0.8, tocolor(150, 160, 172, 255), "center", "center")
    RP:windowButton("jobs", "work", "START /work ROUTE NOW", 0.06, 0.90, 0.88, 0.07, function()
        RP:closeWindow("jobs")
        triggerServerEvent("ngj:work", localPlayer)
    end, tocolor(40, 96, 160, 220))
end)
