print("[LOADER] STRING LOADED")

setmetatable(string, {
	__index = {
		trim = function(self)
			return self:gsub("%s", "");
		end
	},
});
