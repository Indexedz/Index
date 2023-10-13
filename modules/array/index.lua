local module = {};
local tablePrototype = {
    find = function(self, callback)
        if type(callback) == "function" then
            for key, val in pairs(self) do
                if callback(val, key, self) then return val, key; end
            end
        else
            for key, val in pairs(self) do
                if val == callback then return val, key; end
            end
        end
        return nil;
    end,
    filter = function(self, callback)
        local filteredTable = module.new()
        for key, val in pairs(self) do
            if callback(val, key, self) then
                table.insert(filteredTable, val)
            end
        end
        return filteredTable
    end,
    push = function(self, value) 
        table.insert(self, value); 

        return self[1]
    end,
    cut = function(self, index)
        if type(index) == "number" and index >= 1 and index <= #self then
            table.remove(self, index)
        end
    end,
    map = function(self, callback)
        local mappedTable = module.new()
        for key, val in pairs(self) do
            local mappedValue = callback(val, key, self)
            table.insert(mappedTable, mappedValue)
        end
        return mappedTable
    end,
    join = function(self, joinWith)
        for key, val in pairs(joinWith) do
            table.insert(self, val)
        end
    
        return self
    end,
    clear = function(self)
        for key in pairs(self) do
            self[key] = nil
        end
    end
};

function module.new(table)
    local table = table or {};
    setmetatable(table, {__index = tablePrototype});

    return table;
end

function module.pack(...)
    local table = table.pack(...) or {};
    
    return module.new(table)
end

function module.data(path)
    
    return module.new(data(path));
end

return module;