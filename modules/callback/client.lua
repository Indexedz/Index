local randChar = import 'utils'.randChar

local module = {};
local callbacks = {};
local caches = {};

RegisterNetEvent("Index.callback:Return", function(key, data)
    local respIndex = nil
    for i, resp in ipairs(caches) do
        if resp.key == key then
            respIndex = i
            break
        end
    end

    if not respIndex then
        print('No matching response found')
        return
    end

    local resp = table.remove(caches, respIndex)
    resp.cb(data)
end)

RegisterNetEvent("Index.callback:Trigger", function(name, key, ...)
    local cb = nil
    for _, existingCB in ipairs(callbacks) do
        if existingCB.name == name then
            cb = existingCB
            break
        end
    end

    if cb then
        local result = table.pack(cb.cb(id, ...))

        TriggerServerEvent("Index.callback:Return", key, result)
    else
        print('Not found callback:', name)
    end
end)

function module.new(callbackName, cb) 
    for _, existingCB in ipairs(callbacks) do
        if existingCB.name == callbackName then
            callbacks[_].cb = cb;
            return warn(("OVERRIDE CALLBACK %s"):format(callbackName))
        end
    end

    table.insert(callbacks, { name = callbackName, cb = cb })
end

function module.use(name, ...)
    local data = table.pack(...)
    local key = randChar(20)
    while caches[key] do
        key = randChar(20)
        Wait(0)
    end

    TriggerServerEvent("Index.callback:Trigger", name, key, table.unpack(data))
    local promise = promise.new()

    table.insert(caches, {
        key = key,
        cb = function(response)
            if promise then
                return promise:resolve(response)
            end
        end
    })

    if promise then
        return table.unpack(Citizen.Await(promise))
    end
end

return module