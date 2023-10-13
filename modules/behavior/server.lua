local array = import 'array';
local object = import 'object';
local server = import 'server';
local character = import 'character';
local package = package 'player';
local accounts = array.new(package.accounts)

local module = {}
local methods = array.new();
local players = array.new();

local LoadData = function(identifier)
    return MySQL.single.await("SELECT * FROM users WHERE identifier = ?", { identifier })
end

function module.new(source)
    local identifier = server.getIdentifier(source, "license");
    players:map(function(player)
        if (player.license == license) then
            server.kick(player.source, "error")
        end
    end)

    local self      = {};
    self.identifier = identifier
    self.source     = source
    self.name       = GetPlayerName(source)
    self.character  = false
    self.characters = character.load(identifier)

    self.ped        = function()
        return GetPlayerPed(self.source)
    end

    self.coords     = function()
        return vec(GetEntityCoords(self.ped()), GetEntityHeading(self.ped()))
    end

    function self.kick(reason)
        return server.kick(self.source, reason or "kick")
    end

    function self:save()
        if not self.character then
            return 
        end

        self.character.coords = self.coords()
        local success, err = character.save(self.character)
        if (not success) then
            return error(err)
        end

        return true
    end

    local function setCharacter(character)
        local character  = character;
        character.data   = character.data or {}
        character.caches = character.caches or {}

        local function set(key, value, isCache, cb)
            if not isCache then
                self.character.data[key] = value
            else
                self.character.caches[key] = value
            end

            if cb then
                pcall(cb, value, key, isCache)
            end
        end

        function character:set(...)
            return set(...)
        end

        function character.get(key)
            return self.character.data[key]
        end

        function character.cache(key)
            return self.character.caches[key]
        end

        methods:map(function(method)
            character[method.name] = function(...)
                local success, err = pcall(method.method, self.source, ...)
                if not success then
                    return error("ERROR CALL METHOD : " .. err)
                end

                return err
            end
        end)

        character.coords = self.coords;
        character.ped    = self.ped;
        self.character   = character;
        self.characters  = nil;

        return true
    end

    function self:setCharacter(character)
        return setCharacter(character)
    end

    function self:trigger(trigger, ...)
        return TriggerClientEvent(trigger, self.source, ...)
    end

    self:trigger("Index.modules.player:loaded", self.characters);
    return players:push(self)
end

function module.all(cb, onlyReady)
    local onlyReady = onlyReady or true
    players:map(function(xPlayer)
        local xPlayer, xCharacter = module.find(xPlayer.source)

        if onlyReady and xCharacter then
            pcall(cb, xPlayer, xCharacter)
        end
    end)
end

function module.find(source)
    local xPlayer = players:find(function(player)
        if (player.source == source) then
            return true
        end
    end)

    return xPlayer, xPlayer?.character or nil
end

function module.export(...)
    local addMethod = function(method, name)
        local isOverride, index = methods:find(function(method)
            return method.name == name
        end)

        if (isOverride and index) then
            methods:cut(index)
            print("OVERRIDE METHOD : " .. name)
        end

        methods:push({
            name = name,
            method = method
        })

        for index, xPlayer in pairs(players) do
            local xCharacter = xPlayer.character
            if xCharacter then
                players[index].character[name] = nil
                players[index].character[name] = function(...)
                    local success, err = pcall(method, xPlayer.source, ...)
                    if not success then
                        return error("ERROR CALL METHOD : " .. err)
                    end

                    return err
                end
            end
        end
    end

    local args = table.pack(...)
    local _ = next(args[1])
    if (string.find(_, "__cfx_functionReference")) then
        addMethod(args[1], args[2])
    else
        for name, func in pairs(args[1]) do
            addMethod(func, name)
        end
    end
end

function module.save(playerId)
    local xPlayer = module.find(playerId)
    if xPlayer then
        return xPlayer:save()
    end
end

return module;
