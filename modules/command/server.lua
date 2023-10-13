local module = {}
local player = import 'player';

local parseToArray = function(val)
  if (type(val) ~= "table") then
    return array.new({ val })
  end

  return array.new(val);
end

local parseArgs = function(params, args)
  if not params then
    return args
  end

  local data = {};
  local err = false;

  params:map(function(param, index)
    local arg, val = args[index]

    if (param.type == "player") then
      local xPlayer, xCharacter = player.find(tonumber(arg))

      if (xPlayer) then
        val = {
          xPlayer = xPlayer,
          xCharacter = xCharacter
        }
      end
    elseif (param.type == "number") then
      val = tonumber(arg)
    elseif (param.type == "string") then
      val = not tonumber(arg) and arg
    else
      val = arg
    end

    if val == nil and not param.optional then
      err = true;
    end

    data[param.name] = val;
  end)

  if err then
    return
  end

  return data;
end

function module.new(commands, params, cb, restricted)
  local self = {}
  commands   = parseToArray(commands)
  params     = parseToArray(params)

  function handler(source, args, raws)
    local args = parseArgs(params, args)

    if not args then
      return
    end

    cb(source, args, raws)
  end

  commands:map(function(promt)
    return RegisterCommand(promt, handler, restricted)
  end)

  return setmetatable(module, self)
end

return module;
