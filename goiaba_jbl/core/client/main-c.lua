--| Replace texture

addEventHandler("onClientResourceStart", resourceRoot, function()
    engineImportTXD (engineLoadTXD("core/assets/texture/jbl.txd"), 2231)
    engineReplaceModel(engineLoadDFF("core/assets/texture/jbl.dff"), 2231)
end)