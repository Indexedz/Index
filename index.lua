global              = {};
global.resource     = GetCurrentResourceName();
global.context      = IsDuplicityVersion() and "server" or "client";
global.config       = json.decode(LoadResourceFile(global.resource, "config.json"));

local loadedPackage = {}
local loadedData    = {}
local shared        = {
	modules = {}
}

local sub           = exports['Index']:sub(global.resource);
local function prepare(name)
	local state, data = pcall(sub, name)

	if not state then
		return error("NOT FOUND : " .. data);
	end

	return data
end

function package(moduleName)
	local data = prepare(moduleName)

	if (loadedPackage[data.name]) then
		return json.decode(loadedPackage[data.name])
	end

	local dir = ("modules/%s"):format(data.target);
	local package = LoadResourceFile(data.parent, dir .. "/_package.json");

	if not package then
		return error("[ERROR] [PACKAGE] : " .. data.name);
	end

	loadedPackage[data.name] = package
	return json.decode(package)
end;

function data(dataName)
	local data = prepare(dataName)

	if loadedData[data.name] then
		return loadedData[data.name]()
	end

	local dir = ("data/%s.lua"):format(data.target);
	local result = LoadResourceFile(data.parent, dir);
	if not result then
		return error("[ERROR] [DATA] : " .. data.name);
	end;

	local func, err = load(result, dir);
	if not func or err then
		return error("[ERROR] [DATA] : " .. err);
	end;

	loadedData[data.name] = func
	return func();
end;

function debug(...)
	local pack = table.pack(...)

	for i = 1, #pack do
		print(json.encode(pack[i], { indent = true }))
	end
end

exports("PrepareModule", prepare)
exports("ShareModule", function(moduleName, fn)
	if shared['modules'][moduleName] then
		return warn("OVERRIDE MODULE : " .. moduleName)
	end

	shared['modules'][moduleName] = function(...)
		local state, result = pcall(fn, ...)

		if not state and result then
			return error("CANNOT CALL MODULE : " .. result);
		end

		return result
	end
end)

exports("CallModule", function(moduleName)
	local data = prepare(moduleName)

	if (shared.modules[data.name]) then
		return shared.modules[data.name]
	end

	local loadModule = exports[data.parent]:import(moduleName);

	if loadModule then
		loadModule()
	else
		error("NOT FOUND MODULE : " .. moduleName)
	end
end)

exports("package", package)
exports("data", data)
exports("config", data)
exports("debug", debug)
