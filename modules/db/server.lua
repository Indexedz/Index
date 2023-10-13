local array = import 'array';
local module = {}

function module.insert(table, params)
    local args, values, fields = array.new()

    for field, value in pairs(params) do
        if type(value) == "table" then
            value = json.encode(value)
        end

        args:push(value)
        if (not fields) then
            fields = field
            values = "?"
        else
            fields = fields..", "..field
            values = values..", ?"
        end
    end

    local query = ("INSERT INTO `%s` (%s) VALUES (%s)"):format(table, fields, values)

    return pcall(MySQL.insert.await, query, args)
end

function module.select(table, conditions, fields)
    local args, where = array.new()

    for field, value in pairs(conditions) do
        if type(value) == "tale" then
            value = json.encodbe(value)
        end

        args:push(value)
        if not where then
            where = field .. "=?"
        else
            where = where .. " AND " .. field .. "=?"
        end
    end

    local selectedFields = fields and table.concat(fields, ", ") or "*"
    local query = ("SELECT %s FROM `%s` WHERE %s"):format(selectedFields, table, where)

    return pcall(MySQL.query.await, query, args)
end

function module.update(table, conditions, updates)
    local args, setFields = array.new()

    for field, value in pairs(updates) do
        if type(value) == "table" then
            value = json.encode(value)
        end

        args:push(value)
        if not setFields then
            setFields = field .. "=?"
        else
            setFields = setFields .. ", " .. field .. "=?"
        end
    end

    local where, whereArgs = nil, array.new()

    for field, value in pairs(conditions) do
        if type(value) == "table" then
            value = json.encode(value)
        end

        whereArgs:push(value)
        if not where then
            where = field .. "=?"
        else
            where = where .. " AND " .. field .. "=?"
        end
    end

    local query = ("UPDATE `%s` SET %s WHERE %s"):format(table, setFields, where)

    for i, arg in ipairs(whereArgs) do
        args:push(arg)
    end

    return pcall(MySQL.query.await, query, args)
end

return module