local utils     = import 'utils';
local hook      = import 'hook';
local event     = import 'event';
local module    = {}

function module.ped()
  return PlayerPedId()
end

function module.coords()
  local ped = module.ped()

  return vec(GetEntityCoords(ped), GetEntityHeading(ped))
end

function module:teleport(coords, preparing)
  local preparing = preparing or true
  local vector = type(coords) == "vector4" and coords or type(coords) == "vector3" and vector4(coords, 0.0) or
      vec(coords.x, coords.y, coords.z, coords.heading or 0.0)
  local ped = module.ped()

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
end

function module.on(eventName, cb, _resource)
  if (not utils.isType(cb, "table", "function")) then
    return error("[ERROR] [MODULE] [SERVER] : " .. ("not found callback function of %s!"):format(event))
  end

  local eventName = ("Index.modules.player:on[%s]"):format(eventName)
  event.new(eventName, cb, _resource)
end

function module.onEvent(event, ...)
  return TriggerEvent(("Index.modules.player:on[%s]"):format(event), ...)
end

function module.data()
  local state = hook.getState("@player:data")

  return state.get(), state
end

function module.get(key)
  local data, state = module.data();

  return data.data[key], state
end

function module.useState(default, stateName, _resource)
  if not stateName then return error("pls enter the state name"); end
  return hook.useState(default, "@player:" .. stateName, _resource)
end

function module.getState(stateName, _resource)
  return hook.getState("@player:" .. stateName, 100, _resource)
end

return module
