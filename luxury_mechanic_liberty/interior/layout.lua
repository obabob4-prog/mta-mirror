-- ============================================================
-- 3D interior layout. Coordinates are relative to LML.interior.
-- Every entry is a real MTA object with collision unless marked.
-- ============================================================

LML.INTERIOR_LAYOUT = LML.INTERIOR_LAYOUT or {}

-- Floor, ceiling supports and partitions. Front (+Y) stays open for cars.
LML.INTERIOR_LAYOUT.shell = {
    { model = 13646, dx = 0,   dy = 0,   dz = -0.2, sx = 13.0, sy = 10.0, sz = 0.4, rz = 0,  label = "showroom_floor" },
    { model = 17064, dx = 0,   dy = 13,  dz = 4.0,  sx = 2.6,  sy = 0.2,  sz = 1.3, rz = 0,  label = "back_wall", solid = true },
    { model = 17064, dx = -19, dy = 0,   dz = 4.0,  sx = 0.2,  sy = 2.6,  sz = 1.3, rz = 0,  label = "left_wall", solid = true },
    { model = 17064, dx = 19,  dy = 0,   dz = 4.0,  sx = 0.2,  sy = 2.6,  sz = 1.3, rz = 0,  label = "right_wall", solid = true },
    { model = 17065, dx = 0,   dy = 0,   dz = 7.4,  sx = 2.6,  sy = 2.6,  sz = 1.0, rz = 0,  label = "roof", noCollision = true },
}

-- Three working hydraulic lift bays.
LML.INTERIOR_LAYOUT.lifts = {
    { model = 13646, dx = -8, dy = 2, dz = 0.15, sx = 1.8, sy = 1.5, sz = 0.5, rz = 0, label = "hydraulic_lift_1" },
    { model = 13646, dx =  0, dy = 2, dz = 0.15, sx = 1.8, sy = 1.5, sz = 0.5, rz = 0, label = "hydraulic_lift_2" },
    { model = 13646, dx =  8, dy = 2, dz = 0.15, sx = 1.8, sy = 1.5, sz = 0.5, rz = 0, label = "hydraulic_lift_3" },
}

-- Reception, management office, tuning benches and paint bay.
LML.INTERIOR_LAYOUT.props = {
    { model = 2008, dx = -13, dy = -7, dz = 0.1, rz = 0,   label = "reception_desk" },
    { model = 2165, dx = -13, dy = -9, dz = 0.1, rz = 180, label = "reception_chair" },
    { model = 2606, dx = -13, dy = -7, dz = 1.1, rz = 0,   label = "reception_monitor", noCollision = true },
    { model = 2008, dx =  13, dy =  8, dz = 0.1, rz = 0,   label = "office_desk" },
    { model = 2165, dx =  13, dy =  6, dz = 0.1, rz = 180, label = "office_chair" },
    { model = 2606, dx =  13, dy =  8, dz = 1.1, rz = 0,   label = "office_monitor", noCollision = true },
    { model = 1932, dx = -15, dy =  7, dz = 0.1, rz = 90,  label = "tuning_workbench" },
    { model = 1999, dx = -12, dy =  8, dz = 0.1, rz = 0,   label = "tool_cabinet_a" },
    { model = 1999, dx = -12, dy = 10, dz = 0.1, rz = 0,   label = "tool_cabinet_b" },
    { model = 11393,dx =  16, dy =  3, dz = 0.1, rz = 270, label = "tool_wall", noCollision = true },
    { model = 925,  dx =  16, dy = -3, dz = 0.1, rz = 270, label = "parts_rack" },
    { model = 925,  dx =  16, dy =  0, dz = 0.1, rz = 270, label = "engine_rack" },
    { model = 1932, dx =  13, dy = -9, dz = 0.1, rz = 0,   label = "paint_bench" },
    { model = 2701, dx =  13, dy = -5, dz = 5.2, rz = 0,   label = "paint_light", noCollision = true },
}

-- Tyre and rim stacks beside the lifts.
LML.INTERIOR_LAYOUT.tyres = {}
for _, x in ipairs({ -14, 14 }) do
    for _, z in ipairs({ 0.25, 0.9, 1.55 }) do
        LML.INTERIOR_LAYOUT.tyres[#LML.INTERIOR_LAYOUT.tyres + 1] = {
            model = 1327, dx = x, dy = -2, dz = z, rz = 0, label = "tyre_stack",
        }
    end
end

-- LED strip anchors used by client.lua (relative to the interior origin).
LML.INTERIOR_LAYOUT.leds = {
    { -15, -9, 6.8 }, { 15, -9, 6.8 },
    { -15,  9, 6.8 }, { 15,  9, 6.8 },
    { -8,   2, 5.4 }, { 0,   2, 5.4 }, { 8,   2, 5.4 },
}
