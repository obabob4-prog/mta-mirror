addEventHandler('onClientResourceStart',resourceRoot,function () 
    txd = engineLoadTXD( '355.txd' ) 
    engineImportTXD( txd, 355 ) 
    dff = engineLoadDFF('355.dff', 355) 
    engineReplaceModel( dff, 355 )

    txd2 = engineLoadTXD( '356.txd' ) 
    engineImportTXD( txd2, 356 ) 
    dff2 = engineLoadDFF('356.dff', 356) 
    engineReplaceModel( dff2, 356 )

    txd3 = engineLoadTXD( '335.txd' ) 
    engineImportTXD( txd3, 335 ) 
    dff3 = engineLoadDFF('335.dff', 335) 
    engineReplaceModel( dff3, 335 )

    txd4 = engineLoadTXD( '346.txd' ) 
    engineImportTXD( txd4, 346 ) 
    dff4 = engineLoadDFF('346.dff', 346) 
    engineReplaceModel( dff4, 346 )

    txd5 = engineLoadTXD( '358.txd' ) 
    engineImportTXD( txd5, 358 ) 
    dff5 = engineLoadDFF('358.dff', 358) 
    engineReplaceModel( dff5, 358 )

    txd6 = engineLoadTXD( '353.txd' ) 
    engineImportTXD( txd6, 353 ) 
    dff6 = engineLoadDFF('353.dff', 353) 
    engineReplaceModel( dff6, 353 )

    txd7 = engineLoadTXD( '347.txd' ) 
    engineImportTXD( txd7, 347 ) 
    dff7 = engineLoadDFF('347.dff', 347) 
    engineReplaceModel( dff7, 347 )

    txd8 = engineLoadTXD( '366.txd' ) 
    engineImportTXD( txd8, 366 ) 
    dff8 = engineLoadDFF('366.dff', 366) 
    engineReplaceModel( dff8, 366 )

end)