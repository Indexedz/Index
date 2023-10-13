local array = import 'array'
local module = {}

function module.randChar(length, seed)
    local length = length or 10

    local charset = {}
    for i = 48, 57 do    -- ASCII codes for numbers 0-9
        table.insert(charset, string.char(i))
    end
    for i = 65, 90 do    -- ASCII codes for uppercase letters A-Z
        table.insert(charset, string.char(i))
    end
    for i = 97, 122 do   -- ASCII codes for lowercase letters a-z
        table.insert(charset, string.char(i))
    end

    if (not seed) then
        seed = math.random(1, 9999999)
    end

    math.randomseed(seed)

    local result = ""
    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        result = result .. charset[randomIndex]
    end

    return result
end

function module.isJson(data)
    local success, result = pcall(json.decode, data)
    return success and result ~= nil
end

function module.isEmpty(value)
    if value == nil then
        return true
    elseif type(value) == "string" then
        return value == ""
    elseif type(value) == "table" then
        return next(value) == nil
    elseif type(value) == "number" then
        return false -- Numbers are never considered empty
    elseif type(value) == "boolean" then
        return false -- Booleans are never considered empty
    elseif type(value) == "function" then
        return false -- Functions are never considered empty
    elseif type(value) == "userdata" then
        return false -- Userdata is never considered empty
    elseif type(value) == "thread" then
        return false -- Threads are never considered empty
    elseif type(value) == "cdata" then
        return false -- Cdata is never considered empty
    else
        return true -- Unknown types are considered empty
    end
end

function module.isType(data, ...)
    local types = array.pack(...)

    return not module.isEmpty(types:find(type(data))) 
end

function module.setVectorToObject(vec)
    return {
        x = vec.x or 0,
        y = vec.y or 0,
        z = vec.z or 0,
        w = vec.w or 0
    }
end

function module.setObjectToVector(obj)
    return vec(obj.x, obj.y, obj.z or nil, obj.w or nil)
end

return module