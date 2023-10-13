local utils = import 'utils';
local event = import 'event';
local module = {}
local shared = {}
local ticks = {}

local function shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

local function getNestedKey(table, path)
    local keys = {}
    for key in path:gmatch("[^.]+") do
        table = table[key]
        if not table then
            return nil
        end
    end
    return table
end

local function unpackFallback(t, i, j)
    i = i or 1
    j = j or #t
    if type(t) == "table" then
        return table.unpack(t, i, j)
    else
        return unpack(t, i, j)
    end
end

local function setNestedKey(originalTable, path, newValue)
    local function recursiveSet(table, keys, value)
        local key = table[keys[1]]
        if #keys == 1 then
            table[keys[1]] = value
        elseif type(key) == "table" then
            recursiveSet(key, { unpackFallback(keys, 2) }, value)
        else
            return nil
        end
    end

    local newTable = {}
    for k, v in pairs(originalTable) do
        newTable[k] = v
    end

    local keys = {}
    for key in path:gmatch("[^.]+") do
        keys[#keys + 1] = key
    end

    recursiveSet(newTable, keys, newValue)

    return newTable
end
--[[ STATE ]]

function module.useState(default, stateName, _resource)
    local callbacks = {}
    local self = {}
    self.val = default
    self.updated = false;
    self.name = stateName;
    self.type = true;
    self.parent = _resource;
    self.callbackEvent = ("Index.module.hook:onChange(%s)"):format(stateName or utils.randChar(15));

    function self.get()
        return self.val
    end

    function self.wait(val, sec)
        while not self.val == val do
            Wait(sec or 0)
        end
    end

    function self.onChange(cb, resource)
        return event.new(self.callbackEvent, cb, resource or self.parent);
    end

    function self:link(key, stateName)
        if (type(self.val) ~= "table") then
            return error("THIS METHOD ONLY WORK ON TABLE!")
        end

        local data = getNestedKey(self.val, key);
        if (data) then
            CreateThread(function()
                local state = module.getState(stateName, 100)

                state.onChange(function(newVal)
                    local updated = setNestedKey(self.val, key, newVal);
                    self:set(updated)
                end)
            end)
        end
    end

    local function setValue(new, noTrigger)
        if self.type and (type(self.val) ~= type(new)) then
            return error(self.name or
                "unnamed state cannot set with type " .. (type(new) .. " you need to use " .. (type(self.val))))
        end

        if self.val ~= new then
            self.updated = true
        end

        local oldVal = self.val
        self.val = new

        if (not noTrigger and self.val ~= oldVal) then
            pcall(function()
                TriggerEvent(self.callbackEvent, self.val, oldVal)
            end)
        end
    end

    function self:set(new, noTrigger)
        return setValue(new, noTrigger)
    end

    local function setDefault(val)
        if not self.updated then
            self.val = val

            return true
        end
    end

    function self:setDefault(val)
        return setDefault(val)
    end

    if (stateName and type(stateName) == "string") then
        if (shared[stateName]) then
            warn(("OVERRIDE STATE %s"):format(stateName))
        end

        shared[stateName] = self;
    end

    return self
end

function module.getState(stateName, tick, _resource)
    local tick = tick or 100

    for i = 1, tick do
        if (shared[stateName]) then
            local state = shared[stateName];
            if (state.parent == _resource) then
                return state
            end
            --[[ OVERRIDE METHOD ]]
            local onChange = state.onChange;

            function state.onChange(cb)
                return onChange(cb, _resource)
            end

            return state
        end

        Wait(1)
    end


    return error("ERROR NO FOUND STATE " .. stateName)
end

function module.useTick(callback, interval, ...)
    interval = interval or 0

    if type(interval) ~= 'number' then
        return error(('Interval must be a number. Received %s'):format(json.encode(interval --[[@as unknown]])))
    end

    local cbType = type(callback)

    if cbType == 'number' and ticks[callback] then
        ticks[callback] = interval or 0
        return
    end

    local args, id = { ... }

    Citizen.CreateThreadNow(function(ref)
        id = ref
        ticks[id] = interval or 0
        repeat
            interval = ticks[id]
            Wait(interval)
            pcall(callback, table.unpack(args))
        until interval < 0
        ticks[id] = nil
    end)

    return {
        id = id,
        destroy = function()
            clearInterval(id)
        end
    }
end

function module.clearTick()
    if type(id) ~= 'number' then
        return error(('Interval id must be a number. Received %s'):format(json.encode(id --[[@as unknown]])))
    end

    if not intervals[id] then
        return error(('No interval exists with id %s'):format(id))
    end

    intervals[id] = -1
end

return module
