local isJson = import 'utils'.isJson
local module = {}

local function load()
	local localeName = global.config.LOCALE;
	local data = LoadResourceFile(global.resource, ("locales/%s.json"):format(localeName));
	if not data then
		return error("[ERROR] [LOCALE] : " .. ("not found locale %s!"):format(localeName));
	end;

    local locales = json.decode(data)
    declareLocale = function(table, key)
        if (isJson(table)) then
            table = json.decode(table)
        end

        for name, text in pairs(table) do
            if type(text) == "table" or isJson(text) then
                local newKey = key and (key .. "_" .. name) or name
                declareLocale(text, newKey)
            else
                local finalKey = key and (key .. "_" .. name) or name
                local trimmedKey = finalKey:clearSpaces()
                local globalVarName = "lang_" .. trimmedKey
                _G[globalVarName] = text
            end
        end
    end

    declareLocale(locales);
end;

module.locales = load();

return module;