class 'TopContent'
{
    constructor = function (self)
        self.alpha = 0;
        self.fullopacity = 0;
        self.topContentColor = colors['TopContentColor'];
        self.middleContentColor = {colors['MiddleContentColor'].tittle, colors['MiddleContentColor'].subtittle};
    end,

    render = function (self)
        dxDrawImage (parent.x + 42 * scale, parent.y + 35 * scale, 40 * scale, 40 * scale, svg['Ellipse'], 0, 0, 0, tocolor (colors['MainColor'][1], colors['MainColor'][2], colors['MainColor'][3], self.alpha * 40));
        dxDrawImage (parent.x + 47 * scale, parent.y + 40 * scale, 30 * scale, 30 * scale, svg['Bike'], 0, 0, 0, tocolor (colors['MainColor'][1], colors['MainColor'][2], colors['MainColor'][3], self.fullopacity));

        dxDrawText (texts['TopContent'].Tittle, parent.x + 96 * scale, parent.y + 34 * scale, 40 * scale, 40 * scale,
        tocolor (colors['MainColor'][1], colors['MainColor'][2], colors['MainColor'][3], self.fullopacity), 1, fonts['roboto-18']);
        dxDrawText (texts['TopContent'].SubTittle, parent.x + 95 * scale, parent.y + 55 * scale, 40 * scale, 40 * scale,
        tocolor (self.topContentColor[1], self.topContentColor[2], self.topContentColor[3], self.alpha * self.topContentColor[4]), 1, fonts['roboto-18']);

        dxDrawImage (parent.x + 42 * scale, parent.y + 107 * scale, 40 * scale, 40 * scale, svg['Icon'], 0, 0, 0, tocolor (255, 255, 255, self.fullopacity));
        dxDrawRectangle (parent.x + 186 * scale, parent.y + 116 * scale, 295 * scale, 1 * scale, tocolor (255, 255, 255, self.alpha * 15))
        dxDrawText (texts['MiddleContent'].Tittle, parent.x + 95 * scale, parent.y + 106 * scale, 40 * scale, 40 * scale,
        tocolor (self.middleContentColor[1][1], self.middleContentColor[1][2], self.middleContentColor[1][3], self.alpha * self.middleContentColor[1][4]), 1, fonts['roboto-18']);
        dxDrawText (texts['MiddleContent'].SubTittle, parent.x + 95 * scale, parent.y + 127 * scale, 373 * scale, 42 * scale,
        tocolor (self.middleContentColor[2][1], self.middleContentColor[2][2], self.middleContentColor[2][3], self.alpha * self.middleContentColor[2][4]), 1, fonts['roboto-18']);
    end,

    setAlpha = function (self, value)
        self.alpha, self.fullopacity = value, value * 255;
    end,
}