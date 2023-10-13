local player = import 'player'
local callback = import 'callback'

RegisterNetEvent("Index.death:isDead", function(state)
    local xPlayer, xCharacter = player.find(source);

    if xPlayer then
        xCharacter:set("isDead", state and 1 or 0)
    end
end)

lib.addCommand('revive', {
    help = 'revive player',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
            optional = true
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    if not args.target and source == 0 then
        return false
    end

    local status = callback.use("Index.player:revive", args.target or source)
end)