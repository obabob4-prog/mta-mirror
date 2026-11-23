means = {

    fonts = {

        ['montserrat13'] = exports['goiaba_fonts']:useFont('sf:regular', 13),

        ['epilogue_semiBold14'] = exports['goiaba_fonts']:useFont('sf:semibold', 14),

    },

    textures = {

        bar = dxCreateTexture('public/images/bar.png'),

        pin = dxCreateTexture('public/images/pin.png'),

    }

}

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "goiaba_fonts" then
        means.fonts = {
            ['montserrat13'] = exports['goiaba_fonts']:useFont('sf:regular', 13),
            ['epilogue_semiBold14'] = exports['goiaba_fonts']:useFont('sf:semibold', 14),
        }
    end
end)