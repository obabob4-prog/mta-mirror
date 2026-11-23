class 'Market'
{
    constructor = function (self)
        self.alpha = 0;
        self.fullopacity = 0;
        self.selected = 0;
        self.pos = {192 * scale, 280 * scale, 368 * scale};
        self.marketColor = {colors['GridColor'].inHover, colors['GridColor'].notHover};
        self.gridTexts = {colors['GridTexts'].tittles, colors['GridTexts'].subtittles};
        self.buttonsColor = colors['ButtonsColor'].notHover;
        self.buttonsTextColor = {colors['ButtonsTextColor'].inHover, colors['ButtonsTextColor'].notHover};
    end,

    render = function (self)
        local isInside_Buy, isInside_Close = self.alpha == 1 and isCursorInPosition (parent.x + 42 * scale, parent.y + 464 * scale, 439 * scale, 70 * scale), self.alpha == 1 and isCursorInPosition (parent.x + 42 * scale, parent.y + 544 * scale, 439 * scale, 70 * scale);

        for i = 1, 3 do
            dxDrawImage (parent.x + 42 * scale, parent.y + self.pos[i], 439 * scale, 78 * scale, svg['Buttons'], 0, 0, 0, 
            (self.selected == i and colorAnimation ('Market' .. i, 2000, self.marketColor[1][1], self.marketColor[1][2], self.marketColor[1][3], self.fullopacity, self.alpha)) or
            (self.alpha == 1 and isCursorInPosition (parent.x + 42 * scale, parent.y + self.pos[i], 439 * scale, 78 * scale)) and 
            colorAnimation ('Market' .. i, 2000, self.marketColor[1][1], self.marketColor[1][2], self.marketColor[1][3], self.fullopacity, self.alpha) or 
            colorAnimation ('Market' .. i, 2000, self.marketColor[2][1], self.marketColor[2][2], self.marketColor[2][3], self.alpha * self.marketColor[2][4], self.alpha));
            dxDrawImage (parent.x + 64 * scale, parent.y + self.pos[i] + 21 * scale, 35 * scale, 35 * scale, svg['Rec'], 0, 0, 0,
            tocolor (colors['MainColor'][1], colors['MainColor'][2], colors['MainColor'][3], self.alpha * 40));
            dxDrawImage (parent.x + 70 * scale, parent.y + self.pos[i] + 27 * scale, 24 * scale, 24 * scale, svg['List'], 0, 0, 0,
            tocolor (colors['MainColor'][1], colors['MainColor'][2], colors['MainColor'][3], self.fullopacity));

            dxDrawText (texts['Market'].Tittle .. ' ' .. i .. 'º', parent.x + 114 * scale, parent.y + self.pos[i] + 18 * scale, 40 * scale, 40 * scale,
            tocolor (self.gridTexts[1][1], self.gridTexts[1][2], self.gridTexts[1][3], self.alpha * self.gridTexts[1][4]), 1, fonts['roboto-18']);
            dxDrawText (texts['Market'].Price, parent.x + 399 * scale, parent.y + self.pos[i] + 18 * scale, 40 * scale, 40 * scale,
            tocolor (self.gridTexts[1][1], self.gridTexts[1][2], self.gridTexts[1][3], self.alpha * self.gridTexts[1][4]), 1, fonts['roboto-18']);
            dxDrawText (system['Bikes'][i].name, parent.x + 114 * scale, parent.y + self.pos[i] + 39 * scale, 40 * scale, 40 * scale,
            tocolor (self.gridTexts[2][1], self.gridTexts[2][2], self.gridTexts[2][3], self.alpha * self.gridTexts[2][4]), 1, fonts['roboto-18']);
            dxDrawText (system['Bikes'][i].price .. ' ' .. _interface['MoneyText'], parent.x + 399 * scale, parent.y + self.pos[i] + 39 * scale, 40 * scale, 40 * scale,
            tocolor (self.gridTexts[2][1], self.gridTexts[2][2], self.gridTexts[2][3], self.alpha * self.gridTexts[2][4]), 1, fonts['roboto-18']);
        end

        dxDrawImage (parent.x + 42 * scale, parent.y + 464 * scale, 439 * scale, 70 * scale, svg['Buttons'], 0, 0, 0, 
        isInside_Buy and 
        colorAnimation ('Buy', 2000, colors['MainColor'][1], colors['MainColor'][2], colors['MainColor'][3], self.fullopacity, self.alpha) or 
        colorAnimation ('Buy', 2000, self.buttonsColor[1], self.buttonsColor[2], self.buttonsColor[3], self.alpha * self.buttonsColor[4], self.alpha));
        dxDrawImage (parent.x + 42 * scale, parent.y + 544 * scale, 439 * scale, 70 * scale, svg['Buttons'], 0, 0, 0, 
        isInside_Close and 
        colorAnimation ('Quit', 2000, colors['MainColor'][1], colors['MainColor'][2], colors['MainColor'][3], self.fullopacity, self.alpha) or 
        colorAnimation ('Quit', 2000, self.buttonsColor[1], self.buttonsColor[2], self.buttonsColor[3], self.alpha * self.buttonsColor[4], self.alpha));

        dxDrawText (texts['BottomContent'].Buy, parent.x + 42 * scale, parent.y + 464 * scale, 439 * scale, 70 * scale,
        isInside_Buy and colorAnimation ('_Buy', 2000, self.buttonsTextColor[1][1], self.buttonsTextColor[1][2], self.buttonsTextColor[1][3], self.fullopacity, self.alpha) or
        colorAnimation ('_Buy', 2000, self.buttonsTextColor[2][1], self.buttonsTextColor[2][2], self.buttonsTextColor[2][3], self.fullopacity, self.alpha), 1, fonts['roboto-18b'], 'center', 'center');
        dxDrawText (texts['BottomContent'].Quit, parent.x + 42 * scale, parent.y + 544 * scale, 439 * scale, 70 * scale,
        isInside_Close and colorAnimation ('_Quit', 2000, self.buttonsTextColor[1][1], self.buttonsTextColor[1][2], self.buttonsTextColor[1][3], self.fullopacity, self.alpha) or
        colorAnimation ('_Quit', 2000, self.buttonsTextColor[2][1], self.buttonsTextColor[2][2], self.buttonsTextColor[2][3], self.fullopacity, self.alpha), 1, fonts['roboto-18b'], 'center', 'center');
    end,

    setAlpha = function (self, value)
        self.alpha, self.fullopacity = value, value * 255;
    end,

    click = function (self, arg)
        local button, state = arg[1], arg[2];
        if (button == 'left' and state == 'down') then
            if not (self.alpha == 1) then
                return false;
            end
            if (not isCursorInPosition (parent.x, parent.y, parentWidth, parentHeight)) then
                self.selected = 0;
                return false;
            end
            for i = 1, 3 do
                if (isCursorInPosition (parent.x + 42 * scale, parent.y + self.pos[i], 439 * scale, 78 * scale)) then
                    self.selected = i;
                    break;
                end
            end
            if (isCursorInPosition (parent.x + 42 * scale, parent.y + 464 * scale, 439 * scale, 70 * scale)) then
                if (self.selected == 0) then
                    return false;
                end
                triggerServerEvent ('BikeSystem >> RentBike >> Server', resourceRoot, localPlayer, system['Bikes'][self.selected].price, self.selected);
                return true;
            elseif (isCursorInPosition (parent.x + 42 * scale, parent.y + 544 * scale, 439 * scale, 70 * scale)) then
                triggerEvent ('BikeSystem >> ClosePanel >> Client', resourceRoot);
                return true;
            end
        end
    end,
}