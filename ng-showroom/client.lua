-- ng-showroom / client
-- The map is a custom world, so server-side ground queries are impossible
-- (getGroundPosition is client-only in MTA). When a player stands near the
-- showroom (world collision streamed), this script probes the real ground
-- z under every placement once and reports it back for exact snapping.

addEvent("ngs:probeGround", true)
addEventHandler("ngs:probeGround", localPlayer, function(placements, anchor)
    if type(placements) ~= "table" or type(anchor) ~= "table" then return end
    local probing = false
    local function tryProbe()
        if probing then return end
        local px, py = getElementPosition(localPlayer)
        local d = (px - anchor.x)^2 + (py - anchor.y)^2
        if d > 150 * 150 then return end -- arrive at the showroom first
        probing = true
        local results = {}
        for i, p in ipairs(placements) do
            local gz = getGroundPosition(p.x, p.y)
            if gz and gz > 1 then
                results[#results + 1] = { i = i, z = gz }
            end
        end
        if #results > 0 then
            triggerServerEvent("ngs:groundFix", localPlayer, results)
        else
            probing = false -- world not streamed yet, keep trying
        end
    end
    setTimer(tryProbe, 2000, 0)
end)
