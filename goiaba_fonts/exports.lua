Fonts = {

    -- SF Display
    ['sf:regular'] = 'sf/regular.ttf',
    ['sf:bold'] = 'sf/bold.ttf',
    ['sf:sbold'] = 'sf/sbold.ttf',
    ['sf:medium'] = 'sf/medium.ttf',

    -- Roboto Condensed
    ['rc:regular'] = 'roboto/regular.ttf',
    ['rc:bold'] = 'roboto/bold.ttf',
    ['rc:medium'] = 'roboto/medium.ttf',

    -- Inter
    ['int:bold'] = 'inter/bold.ttf',
    ['int:extrabold'] = 'inter/extrabold.ttf',
    ['int:medium'] = 'inter/medium.ttf',
    ['int:regular'] = 'inter/regular.ttf',
    ['int:semibold'] = 'inter/semibold.ttf',


    -- Generics
    ['gn:heavy'] = 'generic/heavy.ttf',
    ['gn:digital'] = 'generic/digital.ttf',
    ['gn:integral'] = 'generic/integral.ttf',
    ['gn:black'] = 'generic/black.ttf',
    ['gn:wind'] = 'generic/wind.ttf',
}


cacheFont = {}
function useFont (name, size, ...)
	if not Fonts[name] then return 'default' end
    if not cacheFont[name..':'..size] then
        cacheFont[name..':'..size] = dxCreateFont('assets/fonts/'..Fonts[name], size, ...)
    end
    return cacheFont[name..':'..size] or 'default'
end

setTimer( function()
    collectgarbage ("collect")
end, 10000, 0)