local utils     = import 'utils';
local hook      = import 'hook';
local event     = import 'event';
local behaviors = array.new();
local module    = {}

local function hasBehaviors(...)
  local hasBehaviors = array.pack(...)
  local founds       = {}

  founds             = hasBehaviors:map(function(behavior)
    if (behaviors:find(behavior)) then
      return behavior
    end

    return nil
  end)

  return #founds >= 1, founds
end

function module.get()
  return behaviors
end

function module.has(...)
  return hasBehaviors(...)
end

function module.on(behavior, cb, cb2)
  if (not utils.isType(cb, "table", "function")) then
    return error("[ERROR] [MODULE] [SERVER] : " .. ("not found callback function of %s!"):format(event))
  end

  event.new(("Index.modules.player:onBehavior[%s]"):format(behavior), cb, _resource)

  if (not utils.isType(cb2, "table", "function")) then
    return
  end

  event.new(("Index.modules.player:onBehavior[%s].end"):format(behavior), cb2, _resource)
end

function module:addTrack(trackName, default, ...)
  local lastTracked;

  local function getName(behavior)
    return ("%s:%s"):format(trackName, behavior);
  end

  local function trigger(on, ...)
    local args = table.pack(...)
    local success, err = pcall(function()
      TriggerEvent(("Index.modules.player:onBehavior[%s]"):format(trackName), on, table.unpack(args))
    end)
  end

  local defaultName = getName(default);
  lastTracked = defaultName

  behaviors:push(defaultName)
  trigger(default)

  local track = {}

  function track:set(val, ...)
    local setBehavior     = getName(val)
    local behavior, index = behaviors:find(lastTracked)

    if (setBehavior == lastTracked) then
      return
    end

    if (behavior and index) then
      lastTracked      = setBehavior
      behaviors[index] = setBehavior
      trigger(val, ...)
    else
      error("NOT FOUND TRACK " .. trackName)
    end
  end

  function track.on(cb)
    module.on(trackName, cb)
  end

  return track
end

function module:add(behavior, ...)
  if not module.has(behavior) then
    behaviors:push(behavior)

    local args = table.pack(...)
    local success, err = pcall(function()
      TriggerEvent(("Index.modules.player:onBehavior[%s]"):format(behavior), table.unpack(args))
    end)

    return {
      destroy = function(...)
        return module.remove(behavior, ...)
      end
    }
  end
end

function module:remove(behavior, ...)
  local behavior, index = behaviors:find(behavior)

  if not behavior then
    return
  end

  local args = table.pack(...)
  local success, err = pcall(function()
    TriggerEvent(("Index.modules.player:onBehavior[%s].end"):format(behavior), table.unpack(args))
  end)

  behaviors:cut(index)
end

return module
