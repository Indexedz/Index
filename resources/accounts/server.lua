local player        = import 'player';
local array         = import 'array';
local server        = import 'server';
local data, methods = {
    server = data 'server'
}, {}

local function setMoney(playerId, type, val)
    local xPlayer, xCharacter = player.find(playerId);

    if xCharacter then
        local accounts = xCharacter.get("accounts");
        local setType  = "set";
        if (accounts[type] > val) then
            setType = "add";
        elseif (accounts[type] < val) then
            setType = "remove"
        end

        if accounts[type] then
            accounts[type] = val
            xCharacter:set("accounts", accounts)
            xPlayer:trigger("Index.player.account:changed", type, val)
            server.trigger("@player:account", "changed", playerId, type, val, setType)
        end
    end
end

local function validate(target, type, cb)
    local type = type or "cash";
    local xPlayer, xCharacter = player.find(target);

    if xCharacter then
        local Accounts = xCharacter.get("accounts");
        local Account  = Accounts[type];

        if Account then
            cb(Account)
        end
    end
end

function methods:add(playerId, type, val)
    validate(playerId, type, function(account)
        setMoney(playerId, type or "cash", account + val)
    end)
end

function methods:remove(playerId, type, val)
    validate(playerId, type, function(account)
        setMoney(playerId, type or "cash", account - val)
    end)
end

function methods:set(playerId, type, val)
    validate(playerId, type, function(account)
        setMoney(playerId, type or "cash", val)
    end)
end

player.export(function(playerId, accountName)
    local accounts = array.new(data.server.accounts)
    local account = {}
    account.get = function()
        local xPlayer, xCharacter = player.find(playerId)

        if not xCharacter then
            return 0
        end

        return xCharacter.get("accounts")[accountName]
    end

    if (not accounts:find(accountName)) then
        return error("DONT HAVE ACCOUNT, " .. accountName)
    end

    function account:add(val, reason)
        return methods:add(playerId, accountName, val)
    end

    function account:remove(val, reason)
        return methods:remove(playerId, accountName, val)
    end

    function account:set(val, reason)
        return methods:set(playerId, accountName, val)
    end

    return account
end, "Account")

lib.addCommand('GiveMoney', {
    help = 'give player money',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'value',
            type = 'number',
            help = 'Number',
        },
        {
            name = 'type',
            type = 'string',
            help = 'Money Type',
            optional = true,
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    methods:add(args.target, args.type, args.value)
end)

lib.addCommand('RemoveMoney', {
    help = 'remove player money',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'value',
            type = 'number',
            help = 'Number',
        },
        {
            name = 'type',
            type = 'string',
            help = 'Money Type',
            optional = true,
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    methods:remove(args.target, args.type, args.value)
end)

lib.addCommand('SetMoney', {
    help = 'set player money',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'value',
            type = 'number',
            help = 'Number',
        },
        {
            name = 'type',
            type = 'string',
            help = 'Money Type',
            optional = true,
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    methods:set(args.target, args.type, args.value)
end)
