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

function module.behavior(_resource)
  local self = {}

  function self.get()
    return behaviors
  end

  function self.has(...)
    return hasBehaviors(...)
  end

  function self.on(behavior, cb, cb2)
    if (not utils.isType(cb, "table", "function")) then
      return error("[ERROR] [MODULE] [SERVER] : " .. ("not found callback function of %s!"):format(event))
    end

    event.new(("Index.modules.player:onBehavior[%s]"):format(behavior), cb, _resource)

    if (not utils.isType(cb2, "table", "function")) then
      return
    end

    event.new(("Index.modules.player:onBehavior[%s].end"):format(behavior), cb2, _resource)
  end

  function self:addTrack(trackName, default, ...)
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
      self.on(trackName, cb)
    end

    return track
  end

  function self:add(behavior, ...)
    if not self.has(behavior) then
      behaviors:push(behavior)

      local args = table.pack(...)
      local success, err = pcall(function()
        TriggerEvent(("Index.modules.player:onBehavior[%s]"):format(behavior), table.unpack(args))
      end)

      return {
        destroy = function(...)
          return self:remove(behavior, ...)
        end
      }
    end
  end

  function self:remove(behavior, ...)
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

  return self
end

function module.localPlayer(_resource)
  local self = {}

  --[[ COMMON ]]
  function self.ped()
    return PlayerPedId()
  end

  function self.coords()
    return vec(GetEntityCoords(self.ped()), GetEntityHeading(self.ped()))
  end

  function self.behavior()
    return module.behavior(_resource)
  end

  function self:teleport(coords, preparing)
    local preparing = preparing or true
    local vector = type(coords) == "vector4" and coords or type(coords) == "vector3" and vector4(coords, 0.0) or
        vec(coords.x, coords.y, coords.z, coords.heading or 0.0)
    local ped = self.ped()

    if DoesEntityExist(ped) then
      if preparing then
        RequestCollisionAtCoord(vector.xyz)
        while not HasCollisionLoadedAroundEntity(ped) do
          Wait(0)
        end
      end

      SetEntityCoords(ped, vector.xyz, false, false, false, false)
      SetEntityHeading(ped, vector.w)
    end

    if cb then
      cb()
    end
  end

  function self:set(type, ...)
    local ped = self.ped()

    if (type == "health") then
      SetEntityHealth(ped, ...)
    elseif (type == "coords") then
      SetEntityCoords(ped, ...)
    elseif (type == "heading") then
      SetEntityHeading(ped, ...)
    end
  end

  --[[ PLAYER DATA ]]
  function self.on(event, cb)
    if (not utils.isType(cb, "table", "function")) then
      return error("[ERROR] [MODULE] [SERVER] : " .. ("not found callback function of %s!"):format(event))
    end

    AddEventHandler(("Index.modules.player:on[%s]"):format(event), function(...)
      local state, err = pcall(cb, ...)
    end)
  end

  function self.onEvent(event, ...)
    return TriggerEvent(("Index.modules.player:on[%s]"):format(event), ...)
  end

  function self.data()
    local state = hook.getState("@player:data")

    return state.get(), state
  end

  function self.get(key)
    local data, state = self.data();

    return data.data[key], state
  end

  function self.useState(default, stateName)
    if not stateName then return error("pls enter the state name"); end
    return hook.useState(default, "@player:" .. stateName, _resource)
  end

  function self.getState(stateName)
    return hook.getState("@player:" .. stateName, 100, _resource)
  end

  return self
end

return module
