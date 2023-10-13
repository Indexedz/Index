local module = {};
local objectPrototype = {
	hasKey = function(self, key)
		return self[key] ~= nil;
	end,
	getWithStringPath = function(table, path)
		local keys = {}
		for key in path:gmatch("[^.]+") do
			table = table[key]
			if not table then
				return nil
			end
		end
		return table
	end
};
local objectMetatable = {
	__index = objectPrototype
};

function module.new(obj)
    local obj = obj or {}
	setmetatable(obj, objectMetatable);
	return obj;
end;

function module.matches(t1, t2)
	local type1, type2 = type(t1), type(t2)
	
	if type1 ~= type2 then return false end
	if type1 ~= 'table' and type2 ~= 'table' then return t1 == t2 end

	for k1,v1 in pairs(t1) do
	   local v2 = t2[k1]
	   if v2 == nil or not module.matches(v1,v2) then return false end
	end

	for k2,v2 in pairs(t2) do
	   local v1 = t1[k2]
	   if v1 == nil or not module.matches(v1,v2) then return false end
	end

	return true
end

return module;