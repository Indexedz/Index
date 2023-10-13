local player = import 'player';
local data   = data 'player'
local groups = array.data('groups')
local state  = player.useState(data.default.group, "group")

player.on("loaded", function()
  local _, dataState = player.get("group");

  state:setDefault(_)
  dataState:link('data.group', "@player:group")
end)

RegisterNetEvent("Index.player.group:changed", function(group)
  return state:set(group)
end)
