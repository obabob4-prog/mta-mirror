class 'Means'

{

    constructor = function (self, fonts, texture, svg)

        self.fonts, self.fontsCache = fonts, {};

        self.textures, self.texturesCache = texture, {};

        self.svg, self.svgsCache = svg, {};

        

        for name, pathTbl in pairs (self.textures) do

            self:createTexture (name, pathTbl.path, pathTbl.format, pathTbl.mipmaps, pathTbl.textureEdge);

        end

        for name, pathTbl in pairs (self.fonts) do

            self:createFont (name, pathTbl.path, pathTbl.size);

        end

        addEventHandler("onClientResourceStart", root, function(res)
            if getResourceName(res) == "goiaba_fonts" then
                self:reloadFonts();
            end
        end)

    end,



    createTexture = function (self, name, path, format, mipmaps, textureEdge)

        if not (self.texturesCache[name] and isElement (self.texturesCache[name])) then

            local _path = 'public/images/' .. path;

            self.texturesCache[name] = dxCreateTexture (_path, format or 'argb', mipmaps or true, textureEdge or 'wrap'); 

        end

    end,



    destroyTextures = function (self)

        for texture in pairs (self.texturesCache) do

            destroyElement (self.texturesCache[texture]);

            self.texturesCache[texture] = nil;

        end

    end,



    createFont = function (self, name, path, size)

        if not (self.fontsCache[name] and isElement (self.fontsCache[name])) then

            self.fontsCache[name] = createFont (path, size);

        end

    end,

    reloadFonts = function (self)
        for name, pathTbl in pairs(self.fonts) do
            self:createFont(name, pathTbl.path, pathTbl.size);
        end
    end,



    createSVG = function (self, name, width, height, string_supper)

        if not (self.svgsCache[name] and isElement (self.svgsCache[name])) then

            self.svgsCache[name] = svgCreate (width, height, string_supper);

        end

    end,



    renewSvg = function (self)

        if (self.svg) then

            for name, pathTbl in pairs (self.svg) do

                self:createSVG (name, pathTbl.width, pathTbl.height, pathTbl.string)

            end

        end

    end,



    renewTextures = function (self)

        if (self.textures) then

            for name, pathTbl in pairs (self.textures) do

                self:createTexture (name, pathTbl.path, pathTbl.format, pathTbl.mipmaps, pathTbl.textureEdge);

            end

        end

    end,



    destroySVGS = function (self)

        for name in pairs (self.svgsCache) do

            destroyElement (self.svgsCache[name]);

            self.svgsCache[name] = nil;

        end

    end,



    getTexture = function (self, name)

        return self.texturesCache[name];

    end,



    getFont = function (self, name)

        return self.fontsCache[name];

    end,



    getAllTextures = function (self)

        return self.texturesCache;

    end,



    getAllFonts = function (self)

        return self.fontsCache;

    end,



    getAllSVGS = function (self)

        return self.svgsCache;

    end,

};



local means = new 'Means' (

    {

        ['roboto-18'] = {path = 'RobotoCondensed-Regular.ttf', size = 14};

        ['roboto-18b'] = {path = 'RobotoCondensed-Regular.ttf', size = 15};

    },

    {

        ['Display'] = {path = 'Display.png'};

        ['Blur'] = {path = 'Blur.png'};

    },

    {

        ['Ellipse'] = {width = 40, height = 40, string = [[

            <svg width="40" height="40">

                <rect width="40" height="40" rx="20" fill="white"/>

            </svg>

        ]]};

        ['Bike'] = {width = 30, height = 30, string = [[

            <svg width="30" height="30" viewBox="0 0 30 30" fill="none" xmlns="http://www.w3.org/2000/svg">

                <path d="M22.5 13.125C21.7711 13.125 21.083 13.29 20.4578 13.5717L19.0469 11.8081L20.6689 9.375H22.5C23.1903 9.375 23.75 8.81531 23.75 8.125C23.75 7.43469 23.1903 6.875 22.5 6.875H18.75C18.0597 6.875 17.5 7.43469 17.5 8.125C17.5 8.48282 17.6543 8.80074 17.8954 9.02855L16.8311 10.625H11.25C10.8112 10.625 10.4041 10.8551 10.1782 11.2317L8.90633 13.3511C8.45726 13.2183 7.99156 13.125 7.5 13.125C4.74304 13.125 2.5 15.368 2.5 18.125C2.5 20.882 4.74304 23.125 7.5 23.125C9.82285 23.125 11.7634 21.5253 12.3225 19.375H15C15.5109 19.375 15.9705 19.0637 16.1609 18.5895L17.8641 14.3307L18.5123 15.141C17.8853 15.9764 17.5 17.0025 17.5 18.125C17.5 20.882 19.743 23.125 22.5 23.125C25.257 23.125 27.5 20.882 27.5 18.125C27.5 15.368 25.257 13.125 22.5 13.125ZM7.5 20.625C6.12122 20.625 5 19.5038 5 18.125C5 16.7462 6.12122 15.625 7.5 15.625C8.87878 15.625 10 16.7462 10 18.125C10 19.5038 8.87878 20.625 7.5 20.625ZM14.1534 16.875H12.3225C12.0986 16.0141 11.6653 15.2376 11.0593 14.622L11.9574 13.125H15.6534L14.1534 16.875ZM22.5 20.625C21.1212 20.625 20 19.5038 20 18.125C20 16.7462 21.1212 15.625 22.5 15.625C23.8788 15.625 25 16.7462 25 18.125C25 19.5038 23.8788 20.625 22.5 20.625Z" fill="white"/>

                <path d="M10.0002 9.3754H12.5006C13.191 9.3754 13.7508 8.81562 13.7508 8.1252C13.7508 7.43478 13.191 6.875 12.5006 6.875H10.0002C9.30978 6.875 8.75 7.43478 8.75 8.1252C8.75 8.81562 9.30978 9.3754 10.0002 9.3754Z" fill="white"/>

            </svg>

        ]]};

        ['Icon'] = {width = 40, height = 40, string = [[

            <svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">

            <circle cx="20" cy="20" r="20" fill="white" fill-opacity="0.3"/>

            <path d="M22.6667 18.7084C23.9809 18.7084 25.0338 17.6475 25.0338 16.3334C25.0338 15.0192 23.9809 13.9584 22.6667 13.9584C21.3526 13.9584 20.2917 15.0192 20.2917 16.3334C20.2917 17.6475 21.3526 18.7084 22.6667 18.7084ZM16.3334 18.7084C17.6476 18.7084 18.7005 17.6475 18.7005 16.3334C18.7005 15.0192 17.6476 13.9584 16.3334 13.9584C15.0192 13.9584 13.9584 15.0192 13.9584 16.3334C13.9584 17.6475 15.0192 18.7084 16.3334 18.7084ZM16.3334 20.2917C14.4888 20.2917 10.7917 21.218 10.7917 23.0625V25.0417H21.8751V23.0625C21.8751 21.218 18.178 20.2917 16.3334 20.2917ZM22.6667 20.2917C22.4372 20.2917 22.1759 20.3075 21.8988 20.3313C22.8172 20.9963 23.4584 21.8909 23.4584 23.0625V25.0417H28.2084V23.0625C28.2084 21.218 24.5113 20.2917 22.6667 20.2917Z" fill="white" fill-opacity="0.3"/>

            </svg>

        ]]};

        ['Buttons'] = {width = 439, height = 70, string = [[

            <svg width="439" height="70">

                <rect width="439" height="70" rx="11" fill="white"/>

            </svg>

        ]]};

        ['Rec'] = {width = 35, height = 35, string = [[

            <svg width="35" height="35" viewBox="0 0 35 35" fill="none" xmlns="http://www.w3.org/2000/svg">

                <rect width="35" height="35" rx="5" fill="white"/>

            </svg>

        ]]};

        ['List'] = {width = 24, height = 24, string = [[

            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">

                <path d="M20 7H4M15 12H4M9 17H4" stroke="white" stroke-width="1.5" stroke-linecap="round"/>

            </svg>

        ]]};

    }

)



modules.exports ('Means', means);