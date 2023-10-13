local hook     = import 'hook'
local object   = import 'object'
local player   = import 'player'
local behavior = import 'behavior'
local radar    = import 'radar'

local states   = {
    isIn    = player.useState(false, "@vehicle:isIn"),
    isEnter = player.useState(false, "@vehicle:isEnter"),
    seat    = player.useState(0, "@vehicle:seat"),
    vehicle = player.useState(0, "@vehicle:entity"),
    dead    = player.getState("isDead"),
    loaded  = player.getState("loaded"),
}

local function getStates()
    local results = {}

    for key, state in pairs(states) do
        results[key] = state.get()
    end

    return results
end

local function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

hook.useTick(function()
    local ped = player.ped();
    local data = getStates();

    if (not data['isIn'] and not data['dead']) then
        if (DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not data['isEnter']) then
            local vehicle   = GetVehiclePedIsTryingToEnter(ped)
            local seat      = GetSeatPedIsTryingToEnter(ped)
            data['isEnter'] = true

            behavior:add("EnteringVehicle");
        elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and data['isEnter'] then
            data['isEnter'] = false
            behavior:remove("EnteringVehicle");
        elseif IsPedInAnyVehicle(ped, false) then
            data['isEnter'] = false
            data['isIn']    = true
            data['seat']    = GetPedVehicleSeat(ped)
            data['vehicle'] = GetVehiclePedIsUsing(ped)

            behavior:remove("EnteringVehicle");
            behavior:add("InVehicle");
        end
    elseif (data['isIn']) then
        if (not IsPedInAnyVehicle(ped, false) or data['dead']) then
            data['isIn']    = false
            data['seat']    = 0
            data['vehicle'] = 0

            behavior:remove("InVehicle")
        end
    end

    if (not object.matches(data, getStates())) then
        for key, state in pairs(states) do
            if (data[key] ~= state.get()) then
                state:set(data[key])
            end
        end
    end
end, 0)

behavior.on("InVehicle", function()
    radar.set(true)
end, function()
    radar.set(false)
end)
