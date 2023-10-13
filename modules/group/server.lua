local module      = {}
local groups      = array.data('groups');
local permissions = array.new();
local player      = import 'player';
local server      = import 'server';

groups:map(function(group)
  array.new(group.permissions):map(function(permission)
    ExecuteCommand(('add_ace group.%s %s'):format(group.name, permission))
  end)
end)

local function addPrincipal(src, name)
  ExecuteCommand(('add_principal player.%s group.%s'):format(src, name))
end

local function rmPrincipal(src, name)
  ExecuteCommand(('remove_principal player.%s group.%s'):format(src, name))
end

local function rmGroup(target, name)
  local group = module.get(name);

  if not group then
    return 
  end

  if (group.include) then
    if (type(group.include) == "table") then
      array.new(group.include):map(function(includeName)
        if (includeName ~= name) then
          return rmGroup(target, includeName)
        end
      end)
    elseif (type(group.include) == "number") then
      groups:map(function(group)
        if (group.name ~= name) then
          return rmGroup(target, group.name)
        end
      end)
    elseif (type(group.include) == "string") then
      rmGroup(target, group.include)
    end
  end

  rmPrincipal(target, group.name)
end

local function addGroup(target, name)
  local group = module.get(name);

  if not group then
    return 
  end

  if (group.include) then
    if (type(group.include) == "table") then
      array.new(group.include):map(function(includeName)
        if (includeName ~= name) then
          return addGroup(target, includeName)
        end
      end)
    elseif (type(group.include) == "number") then
      groups:map(function(group)
        if (group.name ~= name) then
          return addGroup(target, group.name)
        end
      end)
    elseif (type(group.include) == "string") then
      addGroup(target, group.include)
    end
  end

  addPrincipal(target, group.name)
end

local function getChilds(name, childs)
  local group = module.get(name)
  local childs = array.new(childs or {})

  if not group then
    return childs
  end

  if (group.include) then
    if (type(group.include) == "table") then
      array.new(group.include):map(function(includeName)
        if (includeName ~= name) then
          return childs:join(getChilds(includeName, { includeName }))
        end
      end)
    elseif (type(group.include) == "number") then
      groups:map(function(group)
        if (group.name ~= name) then
          return childs:push(group.name)
        end
      end)
    elseif (type(group.include) == "string") then
      childs:join(getChilds(group.include, { group.include }))
    end
  end

  return childs:unDuplicates();
end

server.on("@player:job", function(event, src, job, oldJob)
  if not event == "changed" then
    return
  end

  module.load()
end)

function module.get(name)
  return groups:find(function(group)
    return group.name == name;
  end)
end

function module.childs(name, includeSelf)
  return getChilds(name, includeSelf and { name } or {})
end

function module.allowed(src, permissions)
  if type(permissions) == 'string' then
    return IsPlayerAceAllowed(src, permissions)
  elseif type(permissions) == "table" then
    local state = false;
    for i = 1, #permissions do
      if not IsPlayerAceAllowed(src, permissions) then
        state = true;
        break;
      end
    end
    return state;
  end
end

function module.setGroup(target, group)
  local group = module.get(group);
  local xPlayer, xCharacter = player.find(target);

  if not group then
    return warn("not found group");
  end

  if not xCharacter then
    return warn("not found character");
  end

  xCharacter:set("group", group.name);
  xPlayerTrigger("Index.player.group:changed", group)
  return addGroup(target, group.name);
end

function module.load(src)
  groups:map(function(group)
    rmPrincipal(src, group.name)
  end)

  local _, xCharacter = player.find(src);
  local group = xCharacter.get("group");
  local job = xCharacter.get("job");
  addGroup(src, group.name)
  addGroup(src, ("JOB:%s[%s]"):format(job.job, job.grade))
end

return module;