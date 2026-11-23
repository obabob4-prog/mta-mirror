local visible;
local isClosing;

local middleHover = (screen.y - parentHeight) / 2;
local bottomHover = ((screen.y - parentHeight) / 2) - 40;

local alpha = {0, 0, 0};
local hover = {bottomHover, 0, 0};

local Display, TopContent, Market;

local createEventHandler = import 'ceh';
local delCA = import 'deleteColorAnimations';

local function render ()
    cursorUpdate ();

    if (alpha[3]) then
        local progress_alpha = interpolateBetween (alpha[1], 0, 0, alpha[2], 0, 0, (getTickCount () - alpha[3]) / 3000, 'Linear');
        alpha[1] = progress_alpha;

        if ((alpha[2] == 1 and progress_alpha == alpha[2]) or (alpha[2] == 0 and progress_alpha == alpha[2])) then
            alpha[3] = nil;
        end

        Display:setAlpha (progress_alpha);
        TopContent:setAlpha (progress_alpha);
        Market:setAlpha (progress_alpha);
    end

    if (hover[3]) then
        local position_hover = interpolateBetween (hover[1], 0, 0, hover[2], 0, 0, (getTickCount () - hover[3]) / 12000, 'OutQuad');
        hover[1] = position_hover;
        parent.y = hover[1];

        if ((floor(position_hover) == floor(middleHover) and floor(hover[2]) == floor(middleHover)) or (floor(position_hover) == floor(bottomHover) and floor(hover[2]) == floor(bottomHover))) then
            hover[3] = nil;
        end
    end

    Display:render ();
    TopContent:render ();
    Market:render ();
end

local function click (...)
    Market:click (arg);
end

manager = {
    toggle = function ()
        if not (visible) and not (isClosing) then
            visible = true;
            alpha[2], alpha[3] = 1, getTickCount ();
            hover[2], hover[3] = middleHover, getTickCount ();
            Display, TopContent, Market = new 'Display' (), new 'TopContent' (), new 'Market' ();
            showCursor (true);
            showChat (false);
            means:renewTextures ();
            means:renewSvg ();
            addEventHandler ('onClientRender', root, render);
            addEventHandler ('onClientClick', root, click);
        end
    end,

    hide = function ()
        if (visible and not isClosing) then
            alpha[2], alpha[3] = 0, getTickCount ();
            hover[2], hover[3] = bottomHover, getTickCount ();
            showCursor (false);
            showChat (true);
            isClosing = Timer (function ()
                if (isClosing and isTimer (isClosing)) then
                    isClosing:destroy ();
                    isClosing = nil;
                end
                visible = nil;
                Display, TopContent, Market = nil, nil, nil;
                removeEventHandler ('onClientRender', root, render);
                removeEventHandler ('onClientClick', root, click);
                means:destroySVGS ();
                means:destroyTextures ();
                delCA ();
            end, 600, 1)
        end
    end,
};

createEventHandler ('BikeSystem >> ClosePanel >> Client', resourceRoot, manager.hide);
createEventHandler ('BikeSystem >> ShowPanel >> Client', resourceRoot, manager.toggle);