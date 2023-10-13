local db = import 'db';
local utils = import 'utils';
local array = import 'array';
local module = {}
local unSaved = array.new();

function module.new(character)
    local saved = {
        player     = character.player,
        charId     = character.charId,
        info       = character.info,
        coords     = utils.setVectorToObject(character.coords)
    }

    for key, val in pairs(character.data) do
        if not saved[key] and not unSaved:find(key) then
            saved[key] = val
        end
    end

    local success, err = db.insert("characters", saved)

    if (not success) then
        return success, err
    end

    return character
end

function module.load(identifier)
    local success, result = db.select("characters", {
        player = identifier
    })

    return success == true and result or false, result
end

function module.save(character) 
    local saved = {
        info       = character.info,
        coords     = utils.setVectorToObject(character.coords)
    }

    for key, val in pairs(character.data) do
        if not saved[key] and not unSaved:find(key) then
            saved[key] = val
        end
    end

    local success, err = db.update("characters", {
        charId = character.charId
    }, saved)

    if (success) then
        print(("[SAVED] %s"):format(character.charId))
    else
        print(("[ERROR] [SAVED] %s : %s"):format(character.charId, err))
    end

    return success, err
end

function module.disableSave(...)
    local data = array.pack(...);

    data:map(function(data)
        if not unSaved:find(data) then
            unSaved:push(data)
        end
    end)
end

return module;