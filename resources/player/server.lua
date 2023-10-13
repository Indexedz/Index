local server    = import 'server';
local player    = import 'player';
local array     = import 'array';
local utils     = import 'utils';
local character = import 'character';
local callback  = import 'callback';
local data      = {
    spawn = data 'spawn',
    player = data 'player',
}
local players   = array.new();

server.on("PlayerDisconnect", function(source)
    local xPlayer = player.find(source);

    if (xPlayer) then
        local success = xPlayer:save()
        print("SAVE", xPlayer.identifier)
    else
        print("NOT FOUND PLAYER")
    end
end)

server.on("PlayerConnecting", function(source, name, setKickReason, def)
    def.defer()
    local license = server.getIdentifier(source, "license")

    if (not license) then
        return def.done("No found license!");
    end

    Wait(100)
    def.done();
end)

server.on("PlayerJoined", function(source)
    local license = server.getIdentifier(source, 'license');
    local xPlayer = players:find(function(xPlayer)
        if (xPlayer.license == license) then
            return true
        end
    end)

    if (not xPlayer) then
        xPlayer = player.new(source)
    else
        server.kick("already_have_player")
    end
end)

callback.new("Index.player:loadCharacter", function(source, charId)
    local xPlayer = player.find(source)

    local ignores = array.new({
        "player", "charId", "info", "coords"
    })

    local decodeData = function(xCharacter)
        local result = {}

        for key, val in pairs(xCharacter) do
            if (not ignores:find(key)) then
                if (utils.isJson(val)) then
                    val = json.decode(val)
                end

                result[key] = val
            end
        end

        for key, val in pairs(data.player.default) do
            if (not result[key]) then
                result[key] = val
            end
        end

        return result
    end

    local db = array.new(xPlayer.characters):find(function(character)
        if (character.charId == charId) then
            return true
        end
    end);

    if (not db) then
        return xPlayer.kick("NOT FOUND CHARACTER");
    end

    xCharacter = {};
    xCharacter.player = db.player;
    xCharacter.charId = db.charId;
    xCharacter.info = json.decode(db.info)
    xCharacter.coords = utils.setObjectToVector(json.decode(db.coords))
    xCharacter.data = decodeData(db)

    xPlayer:setCharacter(xCharacter);

    return xCharacter;
end)

callback.new("Index.player:createCharacter", function(source, payload)
    local xPlayer = player.find(source)

    local character, err = character.new({
        player = xPlayer.identifier,
        charId = utils.randChar(15),
        info = payload,
        coords = utils.setVectorToObject(data.spawn.spawnPoints[1]),
        data = data.player.default
    })

    if not character then
        return warn("CREATE CHARACTER ERROR : "..err)
    end

    debug("CREATED")
    xPlayer:setCharacter(character);
    debug("RETURNED")

    return character;
end)

RegisterNetEvent("Index.player:SaveAppearance", function(appearance)
    local xPlayer, xCharacter = player.find(source);
    if not xCharacter then
        print("NOT FOUND")
        return xPlayer.kick("NOT FOUND CHARACTER")
    end

    debug("SAVE PLAYER", appearance)
    xCharacter:set("appearance", appearance)
end)

lib.addCommand('save', {
    help = 'save player',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local xPlayer, xCharacter = player.find(args.target)
    if xPlayer and xCharacter then
        xPlayer:save()
    end
end)
