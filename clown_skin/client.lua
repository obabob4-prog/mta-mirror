-- Art the Clown - client-side model loader
-- Uses a dynamically allocated ped model ID so vanilla skins stay untouched.

local clownModel = nil
local loading = false

local function loadClownModel()
    if clownModel then
        return true
    end
    if loading then
        return false
    end
    loading = true

    -- "7" = standard civilian ped parent used by engineRequestModel for skins.
    clownModel = engineRequestModel("ped", 7)
    if not clownModel then
        outputChatBox("[Clown] Could not allocate a ped model ID.", 255, 80, 80)
        loading = false
        return false
    end

    -- Load order required by MTA: TXD first, then DFF.
    local txd = engineLoadTXD("artclown.txd", true)
    if not txd then
        outputChatBox("[Clown] Failed to load artclown.txd", 255, 80, 80)
        loading = false
        return false
    end
    engineImportTXD(txd, clownModel)

    local dff = engineLoadDFF("artclown.dff", clownModel)
    if not dff then
        outputChatBox("[Clown] Failed to load artclown.dff", 255, 80, 80)
        loading = false
        return false
    end
    engineReplaceModel(dff, clownModel)

    loading = false
    return true
end

local function applyClown()
    if loadClownModel() then
        setElementModel(localPlayer, clownModel)
        outputChatBox("[Clown] Skin applied.", 120, 255, 120)
    end
end

addEventHandler("onClientResourceStart", resourceRoot, loadClownModel)
addEvent("clown:apply", true)
addEventHandler("clown:apply", resourceRoot, applyClown)

-- Client-side fallback command (works even without server script).
addCommandHandler("clownme", applyClown)
