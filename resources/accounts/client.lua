local player = import 'player';
local data   = {
    player = data 'player'
}

local Accounts = player.useState(data.player.default.accounts, "accounts")

player.on("loaded", function()
    local accounts, state = player.get("accounts");
    
    Accounts:setDefault(accounts)
    state:link('data.accounts', "@player:accounts")
end)

RegisterNetEvent("Index.player.account:changed", function(accountType, accountValue) 
    local accounts = Accounts.get();
    accounts[accountType] = accountValue

    Accounts:set(accounts);
end)