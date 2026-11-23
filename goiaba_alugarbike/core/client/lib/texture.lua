-- /// Text Relacioned \\\ --



local createdFonts = {};
local cachedFonts = {}


createFont = function(fontName, size, bold, quality)
    if fontName == "RobotoCondensed-Regular.ttf" then
        createdFonts[fontName..":"..size] = exports.goiaba_fonts:useFont("rc:regular", (size * scale))

        if not cachedFonts[fontName..":"..size] then 
            cachedFonts[fontName..":"..size] = {fontName, size}
        end

        return createdFonts[fontName..":"..size]
    end
end