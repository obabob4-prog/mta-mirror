-- Imports Globais

system, _interface = returnSystem (), returnInterface ();
colors = _interface['Colors'];
texts = _interface['Texts'][_interface['Language']];

means = import 'Means';
colorAnimation = import 'colorAnimation';

-- Assets Globais

textures = means:getAllTextures ();
fonts = means:getAllFonts ();
svg = means:getAllSVGS ();

class 'Display'
{
    constructor = function (self)
        self.alpha = 0;
        self.fullopacity = 0;
        self.displayColor = colors['BackgroundColor'];
    end,

    render = function (self)
        dxDrawImage (parent.x, parent.y, parentWidth, parentHeight, textures['Display'], 0, 0, 0, tocolor (self.displayColor[1], self.displayColor[2], self.displayColor[3], self.alpha * self.displayColor[4]));

        if (_interface['BlurActive']) then
            dxDrawImage (parent.x, parent.y, parentWidth, parentHeight, textures['Blur'], 0, 0, 0, tocolor (255, 255, 255, self.fullopacity));
        end
    end,

    setAlpha = function (self, value)
       self.alpha, self.fullopacity = value, value * 255; 
    end,
};