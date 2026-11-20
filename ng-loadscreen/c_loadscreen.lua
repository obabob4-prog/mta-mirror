--[[
    ng-loadscreen - lightweight DX loading overlay (zero CEF)
    Two phases:
      1. "city preparing"  - shown while the GTA V map syncs and the spawn
                             area is pre-loaded (triggered by the server)
      2. "area streaming"  - shown right after the character spawns, with
                             a REAL progress bar (stream-in counter), until
                             the surroundings are built (or a hard cap)
    Never sticks: both phases have hard time caps.
]]

local overlayActive = false
local overlayEnd = 0
local streamedCount = 0
local TARGET = 100            -- stream-ins counted as "area ready" (LC)
local MAX_MS = 12000          -- hard cap, spawn phase (LC)
local PREPARE_MS = 15000      -- hard cap, city-preparing phase (LC)
                              -- was 95s for the old GTA V map sync; LC is a
                              -- fraction of that and the long cap made every
                              -- spawn LOOK frozen behind a black overlay)

local sw, sh = guiGetScreenSize()

-- 2026-11-17 gta4gg: horror artwork background (GGGGGG.png by the player),
-- drawn aspect-cover behind the title / progress bar
local bgTex = nil
-- cached background geometry (recomputed only on texture/size change) to avoid
-- per-frame dxGetMaterialSize + math work (lag source during spawn overlay)
local bgCache = nil
addEventHandler("onClientResourceStart", resourceRoot, function()
	bgTex = dxCreateTexture("bg_dark.png", "argb", false, "clamp")
	if not bgTex then bgTex = nil; bgCache = nil; return end
	local tw, th = dxGetMaterialSize(bgTex)
	local scale = math.max(sw / tw, sh / th)
	local dw, dh = tw * scale, th * scale
	local dy = 0
	if dh < sh then dy = (sh - dh) / 2 end
	bgCache = { dx = (sw - dw) / 2, dy = dy, dw = dw, dh = dh }
end)

local function drawBackground()
	if not bgTex then
		dxDrawRectangle(0, 0, sw, sh, tocolor(6, 6, 10, 255))
		return
	end
	if not bgCache then
		local tw, th = dxGetMaterialSize(bgTex)
		local scale = math.max(sw / tw, sh / th)
		local dw, dh = tw * scale, th * scale
		local dy = 0
		if dh < sh then dy = (sh - dh) / 2 end
		bgCache = { dx = (sw - dw) / 2, dy = dy, dw = dw, dh = dh }
	end
	dxDrawImage(bgCache.dx, bgCache.dy, bgCache.dw, bgCache.dh, bgTex)
end

local function endOverlay()
	overlayActive = false
end

addEventHandler("onClientElementStreamIn", root, function()
	if overlayActive then
		streamedCount = streamedCount + 1
		if streamedCount >= TARGET then endOverlay() end
	end
end)

addEventHandler("onClientRender", root, function()
	if not overlayActive then return end
	if getTickCount() >= overlayEnd then
		endOverlay()
		return
	end
	-- dark backdrop
	drawBackground()
	local progress = math.min(1, streamedCount / TARGET)
	dxDrawText("LIBERTY CITY", 0, sh * 0.40, sw, sh * 0.47,
		tocolor(235, 235, 240, 255), 2.4, "default-bold", "center", "top")
	if streamedCount > 0 then
		dxDrawText("جارٍ بناء محيطك... / Building your surroundings...",
			0, sh * 0.475, sw, sh * 0.51,
			tocolor(180, 185, 195, 255), 1.2, "default", "center", "top")
	else
		dxDrawText("جارٍ تجهيز مدينة ليبرتي... / Preparing Liberty City...",
			0, sh * 0.475, sw, sh * 0.51,
			tocolor(180, 185, 195, 255), 1.2, "default", "center", "top")
	end
	local bw = sw * 0.4
	local bx = (sw - bw) / 2
	dxDrawRectangle(bx, sh * 0.56, bw, 22, tocolor(40, 44, 52, 255))
	dxDrawRectangle(bx, sh * 0.56, bw * progress, 22, tocolor(74, 163, 255, 255))
end)

-- phase 1: the city is syncing / the spawn area is being pre-loaded
addEvent("ngc:cityPreparing", true)
addEventHandler("ngc:cityPreparing", root, function()
	streamedCount = 0
	overlayEnd = getTickCount() + PREPARE_MS
	overlayActive = true
end)

-- phase 2: the character spawned - switch to the streaming progress bar
addEventHandler("ngc:charSpawned", root, function()
	if overlayActive then
		-- keep the preparing overlay but refresh its window for streaming
		streamedCount = 0
		overlayEnd = math.max(overlayEnd, getTickCount() + MAX_MS)
	else
		streamedCount = 0
		overlayEnd = getTickCount() + MAX_MS
		overlayActive = true
	end
end, false)

-- Hide the loading overlay while the character selection screen is open so
-- it can never paint over the character list / empty-state message.
addEvent("ngc:showCharList", true)
addEventHandler("ngc:showCharList", root, function()
	overlayActive = false
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	overlayActive = false
end)
