local array = import 'array'
local hook = import 'hook'
local module = {}
local entities = array.new {
  CPed = array.new({}),
  CObject = array.new({}),
  CVehicle = array.new({}),
  CPickup = array.new({})
}

function module.GetGamePool(...)
  local pools = array.pack(...)
  local results = array.new()
  local types = array.new { 'CPed', 'CObject', 'CVehicle', 'CPickup' }

  pools:map(function(poolName)
    if (types:find(poolName)) then
      local pool = GetGamePool(poolName)

      if (type(pool) == 'table' and #pool > 0) then
        results:join(pool)
      end
    end
  end)

  return results
end

CreateThread(function()
  while true do
    entities:map(function(entities_, type)
      local gamePool = array.new(module.GetGamePool(type))

      gamePool:map(function(entity)
        local index = entities_:find(entity)
        if (not index) then
          entities[type]:push(entity)
          hook.triggerEvent(('%s:onSpawn'):format(type), entity)
        end
      end)

      entities[type]:map(function(entity, key)
        if (not DoesEntityExist(entity)) then
          table.remove(entities[type], key)
          hook.triggerEvent(('%s:onDespawn'):format(type), entity)
        end
      end)

      Wait(1000)
    end)
    Wait(1500)
  end
end)

return module
