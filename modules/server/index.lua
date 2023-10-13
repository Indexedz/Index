local array = import 'array';
local object = import 'object';
local isType  = import 'utils'.isType;
local module = {}
local caches = array.new()
local events = array.new({
    "PlayerDisconnect",
    "PlayerConnecting",
    "PlayerJoined",
    "@player:ready",
    "@player:login",
    "@player:logout",
    "@player:job",
    "@player:account"
})

AddEventHandler('playerDropped', function(reason)
    local src = source

    module.trigger("@player:logout", src)
    module.trigger("PlayerDisconnect", src, reason)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source 

    module.trigger("PlayerConnecting", src, name, setKickReason, deferrals)
end)

RegisterNetEvent("Index.server:onPlayerJoined", function()
    local src = source 

    module.trigger("PlayerJoined", src)
end)

RegisterNetEvent("Index.server:onPlayerReady", function()
    local src = source 

    module.trigger("@player:ready", src)
end)    

function module.on(event, cb)
    if (not events:find(event)) then
        return error("[ERROR] [MODULE] [SERVER] : "..("not found event %s!"):format(event))
    end

    if (not isType(cb, "table", "function")) then
        return error("[ERROR] [MODULE] [SERVER] : "..("not found callback function of %s!"):format(event))
    end

    AddEventHandler(("Index.modules.server:on[%s]"):format(event), function(...)
        local state, err = pcall(cb, ...)
    end)
end

function module.getIdentifier(source, ...)
    local types = ... and array.pack(...) or nil
    local identifiers = array.new(GetPlayerIdentifiers(source))

    if (not types) then 
        return identifiers
    end

    local data = array.new();

    types:map(function (type)
        local value = identifiers:find(function(identifier)
            if(string.find(identifier, type..":")) then
                return true
            end
        end)
        
        data:push(value)
    end)

    return table.unpack(data)
end

function module.isBanned(source)
    local isBanned, Reason = false, ""
    local license = module.getIdentifier(source, "license");

    local result = MySQL.single.await("SELECT * FROM bans WHERE license = ?", {license})
    if (result) then
        if os.time() < result.expire then
            retval = true
            local timeTable = os.date('*t', tonumber(result.expire))
        else
            MySQL.query('DELETE FROM bans WHERE id = ?', { result[1].id })
        end
    end
end

function module.trigger(event, ...)
    if (not events:find(event)) then
        return error("[ERROR] [MODULE] [SERVER] : "..("not found event %s!"):format(event))
    end

    return TriggerEvent(('Index.modules.server:on[%s]'):format(event), ...)
end

function module.kick(source, reason)
    return DropPlayer(source, reason or "Kicked!")
end

return module;