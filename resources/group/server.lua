local player  = import 'player';
local command = import 'command';
local group   = import 'group';
local server  = import 'server';
local methods = {};

function methods.getGroup(playerId)
  local _, xCharacter = player.find(playerId);
  local PlayerGroup = xCharacter.get('group');

  return group.get(PlayerGroup)
end

function methods.setGroup(playerId, groupName)
  return group.setGroup(playerId, groupName)
end

function methods.hasPermissions(playerId, perms)
  return group.allowed(playerId, perms)
end

function methods.hasGroup(playerId, group)
  local _, xCharacter = player.find(playerId);
  local plyGroup = xCharacter.get("group");
  local childs = group.childs(plyGroup, true);

  return array.new(childs):find(function(child)
    return group == child
  end)
end

player.export({
  { methods.getGroup,       "getGroup" },
  { methods.setGroup,       "setGroup" },
  { methods.hasPermissions, "hasPermission" },
  { methods.hasGroup,       "hasGroup" }
})

command.new("setGroup", {
  { name = "target", type = "player", help = "Player ID" },
  { name = "group",  type = "string", help = "Group ID" }
}, function(src, args)
  if not args.target.xCharacter then
    return
  end

  group.setGroup(args.target.xPlayer.source, args.group);
end, true)

server.on("@player:ready", group.load)