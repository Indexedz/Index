local pattern = "@([^/]+)/(.*)" -- This pattern captures everything after "/" excluding the "@"

local function getLastLine(str)
  return str:reverse():find(("return module"):reverse())
end

local function removeLastLine(chunk)
  -- Split the chunk into lines
  local lines = {}
  for line in chunk:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  -- Check if the last line contains "return module" and remove it
  if #lines > 0 then
    local lastLine = lines[#lines]
    local modifiedLastLine = lastLine:gsub("return module", "")
    lines[#lines] = modifiedLastLine
  end

  -- Join the lines back into a single string
  local _chunk = table.concat(lines, "\n")

  return _chunk
end

function renderModule(chunk, data, package)
  if (not getLastLine(chunk) or not data or not chunk) then
    return error(("[ERROR] [MODULE] : cannot render module %s!"):format(data.name))
  end

  local function_names = {}
  local pattern_dot = 'function%s+module%.(%w+)%((.-)%)'
  local pattern_colon = 'function%s+module%:(%w+)%((.-)%)'

  local format = (package.format or {})[global.context] or nil

  for name, parameters in chunk:gmatch(pattern_dot) do
    local param_list = {}
    for param in parameters:gmatch("[^,%s]+") do
      table.insert(param_list, param)
    end

    table.insert(function_names, { name = name, parameters = param_list, pattern = "dot" })
  end

  for name, parameters in chunk:gmatch(pattern_colon) do
    local param_list = {}
    for param in parameters:gmatch("[^,%s]+") do
      table.insert(param_list, param)
    end

    table.insert(function_names, { name = name, parameters = param_list, pattern = "dot" })
  end

  if format then
    for i = 1, #function_names do
      for x = 1, #format do
        if function_names[i].name ~= format[x] then
          function_names[i] = nil
        end
      end
    end
  end

  local exportscripts = "";
  local _import = [[
    local module = {};
    local path = global.resource;

    function module.setPath(setPath)
      path = setPath
    end

    local insertAt = function(table, index, value)
      -- Calculate the current length of the table
      local length = #table

      -- If the index is beyond the current length, extend the table with nil values
      for i = length + 1, index - 1 do
          table[i] = nil
      end

      -- Insert the value at the specified index
      table[index] = value
    end

    local parseArgs = function(parameters, args)
      for i=1, #parameters do
        local name = parameters[i]
        if (name == "_resource") then
          insertAt(args, i, args[i] or path)
        end
      end

      return args
    end
  ]];

  for _, func in ipairs(function_names) do
    local methodName = ("modules.%s.%s"):format(data.parent .. "." .. data.target, func.name)
    local methodCode = ([[
            AddEventHandler(('__cfx_export_%s_%s'), function(setCB, ...)
                setCB(module.%s)
            end)
    ]]):format(data.parent, methodName, func.name)

    exportscripts = exportscripts .. methodCode;

    if func.pattern == "colon" then
      _import = _import .. ([[
        function module:%s(...)
            local parameters = json.decode('%s')
            local args = table.pack(...)

            return exports['%s']['%s'](self, table.unpack(parseArgs(parameters, args)))
        end
      ]]):format(func.name, json.encode(func.parameters), data.parent, methodName);
    else
      _import = _import .. ([[
        function module.%s(...)
            local parameters = json.decode('%s')
            local args = table.pack(...)

            return exports['%s']['%s'](self, table.unpack(parseArgs(parameters, args)))
        end
      ]]):format(func.name, json.encode(func.parameters), data.parent, methodName);
    end
  end

  _chunk = removeLastLine(chunk);
  _chunk = _chunk .. exportscripts;
  _chunk = _chunk .. "\n" .. "return module";
  _import = _import .. "return module";

  return _chunk, _import
end

exports("sub", function(resource)
  resource = resource or GetCurrentResourceName();

  return function(name)
    local function sub(name, tick)
      local tick = tick or 0
      local parent, target = name:match(pattern);

      if (tick >= 1 and (not parent or not target)) then
        return error("ERROR PATH : " .. name)
      end

      if (not parent) then
        name = ("@%s/%s"):format(resource, name)
        return sub(name, tick + 1)
      end

      return {
        parent = parent,
        target = target,
        name = name
      }
    end

    return sub(name, 0)
  end
end)

exports("renderModule", function(...)
  return renderModule(...)
end)

print("MODULE RENDER: RUNNING")
