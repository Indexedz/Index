local player        = import 'player'
local behavior      = import 'behavior';
local hook          = import 'hook';
local callback      = import 'callback';
local death         = data 'death';

local isDead        = player.useState(false, "isDead");
local preparing = false;

local function onDeath(skipPreparing)
    isDead:set(true)
    behavior:add("death");
    preparing = true
    TriggerServerEvent("Index.death:isDead", true)
    local anims = death.anims;

    for i=1, #anims do
        lib.requestAnimDict(anims[i][1])
    end 

    CreateThread(function()
        while isDead.get() do
            DisableFirstPersonCamThisFrame()
            Wait(0)
        end
    end)

    if not skipPreparing then
        Wait(4000)
    end
    local coords = player.coords() --[[@as vector]]
    local ped    = player.ped()

    if (IsPedDeadOrDying(ped)) then
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.w, false, false)
    end
    SetEntityInvincible(ped, true)
    SetEntityHealth(ped, 200)
    SetEveryoneIgnorePlayer(player.id, true)

    local timeout = 50

    while isDead.get() do
  --[[       local inVehicle = player.hasBehaviors("inVehicle"); ]]
        local anim = anims[1] --[[ inVehicle and anims[2] or  anims[1]  ]]

        if not IsEntityPlayingAnim(ped, anim[1], anim[2], 3) then
            TaskPlayAnim(ped, anim[1], anim[2], 50.0, 8.0, -1, 1, 1.0, false, false, false)
        end

        Wait(200)
    end

    preparing = false
    local coords = player.coords() --[[@as vector]]
    local hospitals = death.hospitals

    DoScreenFadeOut(200)
    while not IsScreenFadedOut() do
        Wait(50)
    end

    if (IsPedDeadOrDying(ped)) then
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.w, false, false)
    end
    local ped = player.ped();

    ClearPedBloodDamage(ped)
    SetEntityInvincible(ped, false)
    SetEveryoneIgnorePlayer(player.id, false)

    Wait(200)
    DoScreenFadeIn(200)
    ClearPedTasks(ped)
    TriggerServerEvent("Index.death:isDead", false)
    behavior:remove("death");
    isDead:set(false)
end

player.on("loaded", function(PlayerData)
    local isDead, state = player.get("isDead");

    state:link('data.isDead', "@player:isDead")

    if isDead == true or tostring(isDead) == "1" then 
        onDeath(true) 
    end
end)

callback.new("Index.player:revive", function()
    if not isDead.get() then
        return false
    end

    if preparing then
        while not preparing  do
            Wait(1000)
        end
    end

    local ped = player.ped()
    SetEntityHealth(ped, 130)

    isDead:set(false)
    return true
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if event == "CEventNetworkEntityDamage" then
        local victim, victimDied, weapon = data[1], data[4], data[7]
        
        if not IsEntityAPed(victim) then 
            return 
        end

        if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() then
            if IsEntityDead(PlayerPedId()) then
                local isDead = isDead.get()
                if not isDead then
                    onDeath()
                end
            end
        end
    end
end)

RegisterCommand('die', function()
    player:set("health", 0)
end, false)