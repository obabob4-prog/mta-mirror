floor, cos, sin, abs, acos, asin, pi, random, min, max = math.floor, math.cos, math.sin, math.abs, math.acos, math.asin, math.pi, math.random, math.min, math.max;
sub, gsub, format, len, find = string.sub, string.gsub, string.format, string.len, string.find;
tbl_remove, tbl_insert = table.remove, table.insert;
crt_yield, crt_create, crt_resume, crt_status = coroutine.yield, coroutine.create, coroutine.resume, coroutine.status;

local module = {};

modules = {
    exports = function (attrName, attrValue)
        if (module[attrName]) then
            error('Module ' .. attrName .. ' already exists')
        end
    
        module[attrName] = attrValue;
    end
};

function import(attrName)
    if (not module[attrName]) then
        error('Module ' .. attrName .. ' does not exist')
    end

    return module[attrName]
end