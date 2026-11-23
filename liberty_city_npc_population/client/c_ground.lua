--[[
    liberty_city_npc_population / client/c_ground.lua
    ------------------------------------------------------------------
    SENSOR ONLY - no movement decisions are made here.

    The LC map collision is client-side, so MTA's ground/water raycasts do
    not exist on the server.  Each client samples the ground under nearby
    streamed-in NPCs and reports anomalies to the server.  The server alone
    validates the report and decides what to do (correction, turn-around,
    or blacklisting a bad spawn node).

    Reports are throttled per citizen and only concern server-owned peds
    tagged with lcnpc.id.
]]

local lastCheck = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(function()
        for _, ped in ipairs(getElementsByType("ped", root, true)) do
            if isElement(ped) and getElementDimension(ped) == 0
               and getElementInterior(ped) == 0 then
                local id = tonumber(getElementData(ped, "lcnpc.id") or 0)
                if id > 0 and getTickCount() - (lastCheck[id] or 0) > 600 then
                    lastCheck[id] = getTickCount()
                    local x, y, z = getElementPosition(ped)
                    local gz = getGroundPosition(x, y, z + 3)
                    local wet = false
                    if type(testLineAgainstWater) == "function" then
                        wet = testLineAgainstWater(x, y, z + 0.5, x, y, z - 1.5) and true or false
                    end
                    if gz then
                        -- report both floating above and sinking below ground quickly
                        if wet or math.abs(z - gz) > 0.18 then
                            triggerServerEvent("lcnpc:groundIssue", resourceRoot, ped, gz, wet)
                        end
                    elseif wet then
                        triggerServerEvent("lcnpc:groundIssue", resourceRoot, ped, z, wet)
                    end
                end
            end
        end
    end, 600, 0)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    lastCheck = {}
end)
