global, Index      = global or {}, exports['Index'];
global.resource    = GetCurrentResourceName();
global.context     = IsDuplicityVersion() and "server" or "client";
local loadedModule = {}

local sub          = Index:sub(global.resource);

local _print       = print;
local _warn        = warn;
local _error       = error;

function print(...)
	local val = "";

	local mytables = table.pack(...)
	for i = 1, #mytables do
		local data = mytables[i];
		if (type(data) == "table") then
			val = val .. json.encode(data, { indent = true });
		elseif (type(data) == "boolean") then
			val = val .. (data and "true" or "false")
		else
			val = val .. data
		end

		if mytables[i + 1] then
			val = val .. ", "
		end
	end

	return _print(val)
end

function warn(...)
	local mytables = table.pack(...)
	local val = ""

	for i = 1, #mytables do
		val = val .. mytables[i] .. " "
	end

	return _warn(val);
end

function error(...)
	local mytables = table.pack(...)
	local val = ""

	for i = 1, #mytables do
		val = val .. mytables[i] .. " "
	end

	return _error(val);
end

local function prepare(name)
	local state, data = pcall(sub, name)

	if not state then
		return error("NOT FOUND : " .. data);
	end

	return data
end

local renderModule = function(...)
	return Index:renderModule(...)
end

function getPackage(packageName)
	local state, data = pcall(sub, packageName)

	return Index:package(data.name)
end

function data(dataName)
	local state, data = pcall(sub, dataName)

	return Index:data(data.name)
end

function _import(moduleName)
	local data    = prepare(moduleName)
	local package = getPackage(data.name);
	if package.type ~= "shared" then
		if package.type ~= global.context then
			return error("[ERROR] [MODULE] : " .. ("not support %sside!"):format(dataname));
		end;
	end;

	if (data.parent ~= global.resource and not package.classes) then
		local object = Index:CallModule(moduleName)
		return object()
	end

	if loadedModule[data.name] then
		return loadedModule[data.name]()
	end

	local path = ("modules/%s/%s"):format(data.target, package[global.context]);
	local chunk = LoadResourceFile(data.parent, path);

	if not chunk then
		return error("[ERROR] [MODULE] : " .. ("not found module %s!"):format(data.name));
	end;

	if (not package.classes) then
		local main, child   = renderModule(chunk, data);

		local mainFn, err   = load(main, path)
		local childFn, err2 = load(child, path)

		if (not mainFn or err) or (not childFn or err2) then
			return error("[ERROR] [MODULE] : " .. (err or err2));
		end;

		if (data.parent == global.resource) then
			mainFn()
		end

		loadedModule[data.name] = childFn;
		Index:ShareModule(data.name, childFn);

		return childFn()
	else
		local fn, err = load(chunk, data.target)

		if (not fn or err) then
			return error("[ERROR] [MODULE] : " .. (err));
		end


		loadedModule[data.name] = fn
		return fn()
	end
end

function import(moduleName)
	local module = _import(moduleName)
	if (module?.setPath) then
		module.setPath(global.resource)
	end
	return module;
end

exports("import", import)

--[[ AUTO IMPORT ARRAY ]]
array = import '@Index/array';
