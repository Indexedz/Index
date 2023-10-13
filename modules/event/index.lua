local module = {}
local events = array.new();

AddEventHandler('onResourceStop', function(resourceName)
  TriggerEvent("@Index.resource:stop", resourceName)

  events:map(function(event)
    if (event.resource == resourceName) then
      RemoveEventHandler(event.handler)
    end
  end)

  events = events:map(function(event)
    if (event.resource ~= resourceName) then
      return event
    end
  end)
end)

function module.new(eventName, eventCb, _resource)
  local event = AddEventHandler(eventName, eventCb)
  local payload = {
    name = eventName,
    handler = event,
    resource = _resource
  }

  return events:push(payload)
end

function module.onStart(cb, _resource)
  return module.new('onResourceStart', function (resourceName)
    if resourceName == _resource then
      return pcall(cb)
    end
  end, _resource)
end

function module.onStop(cb, _resource)
  return module.new('@Index.resource:stop', function (resourceName)
    if resourceName == _resource then
      return pcall(cb)
    end
  end, _resource)
end

return module
