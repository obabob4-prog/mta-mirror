cache = {
    functions = { };
    fonts = { };
    text = dxDrawText;
    image = dxDrawImage;
    data = getElementData;
}


local vectors = {}
function createVector(width, height, rawData)
    local svgElm = svgCreate(width, height, rawData)
    local svgXML = svgGetDocumentXML(svgElm)
    local rect = xmlFindChild(svgXML, 'rect', 0)

    return { 
        svg = svgElm,
        xml = svgXML,
        rect = rect
    }
end

function createCircleStroke(id, width, height, sizeStroke)
    if (not id) then return end
    if (not (width or height)) then return end
    
    if (not vectors[id]) then
        sizeStroke = sizeStroke or 2
        
        local radius = math.min(width, height) / 2
        local radiusLenght = (2 * math.pi) * radius
        local newWidth, newHeight = width + (sizeStroke * 2), height + (sizeStroke * 2)
        
        local raw = string.format([[
        <svg width='%s' height='%s'>
        <rect x='%s' y='%s' rx='%s' width='%s' height='%s' fill='#FFFFFF' fill-opacity='0' stroke='#FFFFFF'
        stroke-width='%s' stroke-dasharray='%s' stroke-dashoffset='%s' stroke-linecap='round' stroke-linejoin='round' />
        </svg>
        ]], newWidth, newHeight, sizeStroke, sizeStroke, radius, width, height, sizeStroke, radiusLenght, 0)
        local svg = createVector(width, height, raw)
        
        local attributes = {
            type = 'circle-stroke',
            svgDetails = svg,
            width = width,
            height = height,
            radiusLenght = radiusLenght
            
        }
        vectors[id] = attributes
    end
    return vectors[id]
end

function createCircle(id, width, height)
    if (not id) then return end
    if (not (width or height)) then return end

    if (not vectors[id]) then
        width = width or 1
        height = height or 1

        local radius = math.min(width, height) / 2
        local raw = string.format([[
            <svg width='%s' height='%s'>
            <rect rx='%s' width='%s' height='%s' fill='#FFFFFF' />
            </svg>
            ]], width, height, radius, width, height)
            local svg = createVector(width, height, raw)

            local attributes = {
                type = 'circle',
                svgDetails = svg,
                width = width,
                height = height
            }
            vectors[id] = attributes
    end
    return vectors[id]
end

function setSVGOffset (id, value, type_value)
    if (not vectors[id]) then return end

    local svg = vectors[id]
    if (cache2[id][2] ~= value) then
        if (not cache2[id][1]) then
            cache2[id][3] = getTickCount()
            cache2[id][1] = true
        end
        
        local progress = (getTickCount() - cache2[id][3]) / 2500
        cache2[id][2] = interpolateBetween(cache2[id][2], 0, 0, value, 0, 0, progress, 'OutQuad')
        
        if (progress > 1) then
            cache2[id][3] = nil
            cache2[id][1] = false
        end 
        
        local rect = svg.svgDetails.rect
        local newValue = svg.radiusLenght - (svg.radiusLenght / type_value) * cache2[id][2]

        xmlNodeSetAttribute(rect, 'stroke-dashoffset', newValue)
        svgSetDocumentXML(svg.svgDetails.svg, svg.svgDetails.xml)
    elseif (cache2[id][1]) then
        cache2[id][1] = false
    end
end

function drawItem(id, x, y, color, rotX, rotY, rotZ, postGUI)
    
    if (not vectors[id]) then return end
    if (not (x or y)) then return end
    local svg = vectors[id]
    
    postGUI = postGUI or false 
    color = color or 0xFFFFFFFF
    
    local width, height = svg.width, svg.height

    --dxSetBlendMode('add')
        dxDrawImage(x, y, width, height, svg.svgDetails.svg, rotX, rotY, rotZ, color, postGUI)
    --dxSetBlendMode('modulate_add')


end

cache2 = {

    weight_bg = {false, 0, getTickCount()},
    weight = {false, 0, getTickCount()},
    weight_bg2 = {false, 0, getTickCount()},
    weight2 = {false, 0, getTickCount()},

}