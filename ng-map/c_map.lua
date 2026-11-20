--[[
    ng-map c_map.lua - 3D floating location labels (client)
]]

local LABELS = {
    -- 2026-11-18: the old list used Los Santos/GTA V coordinates
    -- (x positive, y negative, z ~730) and was invisible in Liberty City.
    -- These are the SAME verified LC positions used by the radar blips in
    -- s_map.lua, so labels and radar now agree.
    {text = "LIBERTY CITY POLICE DEPT", x = -998.80,  y = 1081.90, z = 25.20},
    {text = "LIBERTY HOSPITAL",         x = -1264.52, y = 251.19,  z = 27.80},
    {text = "JOB CENTER",               x = -1135.52, y = 302.318, z = 26.275},
    {text = "CAR DEALER",               x = -1898.40, y = 1780.00, z = 2.86},
    {text = "24/7 SUPERMARKET",         x = -1246.46, y = 343.29,  z = 27.00},
    {text = "GAS STATION",              x = -1354.80, y = 1275.95, z = 18.70},
    {text = "GAS STATION 2",            x = -1228.39, y = 435.38,  z = 26.90},
}

local sw, sh = guiGetScreenSize()

addEventHandler("onClientRender", root, function()
    if not getElementData(localPlayer, "char.spawned") then return end
    local px, py, pz = getElementPosition(localPlayer)
    for _, l in ipairs(LABELS) do
        local dist = getDistanceBetweenPoints3D(px, py, pz, l.x, l.y, l.z)
        if dist < 120 then
            local sxp, syp = getScreenFromWorldPosition(l.x, l.y, l.z)
            if sxp then
                local alpha = math.max(0, math.min(255, 255 - (dist / 120) * 180))
                local size = math.max(0.7, 1.5 - dist / 150)
                dxDrawText(l.text, sxp, syp, sxp, syp, tocolor(255, 255, 255, alpha), size, "default-bold", "center", "center", false, false, false, true)
            end
        end
    end
end)
