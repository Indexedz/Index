local hook         = import 'hook';
local callback     = import 'callback';
local array        = import 'array';
local player       = import 'player';
local behavior     = import 'behavior';
local spawn        = data 'spawn';
local cam, cam2, lastcamindex, camloading

local prepare      = hook.useState(true);
local loaded       = player.useState(false, "loaded")
local PlayerData   = player.useState({}, "data");
local PlayerHealth = player.useState(200, "health");

NetworkStartSoloTutorialSession()
CreateThread(function()
    exports.spawnmanager:setAutoSpawn(false)

    if GetIsLoadingScreenActive() then
        SendLoadingScreenMessage(json.decode({
            fullyLoaded = true
        }))
        ShutdownLoadingScreenNui()
    end

    while not IsScreenFadedOut() do
        DoScreenFadeOut(0)
        Wait(0)
    end

    ShutdownLoadingScreen()
    Wait(500)
    TriggerServerEvent('Index.server:onPlayerJoined')

    while not prepare.get() do
        DisableAllControlActions(0)
        ThefeedHideThisFrame()
        HideHudAndRadarThisFrame()
        SetLocalPlayerInvisibleLocally(true)
        SetPedAoBlobRendering(PlayerPedId(), false)
        Wait(0)
    end

    SetLocalPlayerInvisibleLocally(false)
    SetPedAoBlobRendering(PlayerPedId(), true)
end)

local function skyCam(bool)
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(PlayerPedId(), false)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 0, 0, 1500, 0.0, 0.0, 0, 60.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

local function SetCam(campos)
    local camZPlus2 = 50
    local pointCamCoords2 = 0
    local cam2Time = 1000

    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", campos.x, campos.y, campos.z + camZPlus2, 300.00, 0.00, 0.00,
        110.00, false, 0)
    PointCamAtCoord(cam, campos.x, campos.y, campos.z + pointCamCoords2)
    SetCamActiveWithInterp(cam, cam2, cam2Time, true, true)
    SetEntityCoords(PlayerPedId(), campos.x, campos.y, campos.z)
end

local function SpawnPlayer()
    prepare:set(false);
    loaded:set(true)
    SetNuiFocus(false, false)
    TriggerServerEvent("Index.server:onPlayerReady")
end

local function initAppearance(appearance, cb)
    if not appearance or appearance == "" then
        return exports['fivem-appearance']:startPlayerCustomization(cb, {
            ped = true,
            headBlend = true,
            faceFeatures = true,
            headOverlays = true,
            components = true,
            props = true,
            tattoos = true,
            allowExit = false,
            automaticFade = false
        })
    end

    exports['fivem-appearance']:setPlayerAppearance(appearance)
    return cb()
end

local FadeOut = function(timer)
    DoScreenFadeOut(timer)
    Wait(timer)
end

local FadeIn = function(timer)
    DoScreenFadeIn(timer)
    Wait(timer)
end

RegisterNUICallback("HoverLocation", function(index, cb)
    FreezeEntityPosition(PlayerPedId(), true)
    local location = spawn.spawnPoints[index] or spawn.spawnPoints[1];
    SetCam(location)
    cb(true)
end)

RegisterNUICallback("SelectedLocation", function(index, cb)
    local location = spawn.spawnPoints[index] or spawn.spawnPoints[1];
    local data = PlayerData.get();

    data.coords = location
    PlayerData:setDefault(data);

    local onAppearance = function(response)
        if not response then
            return initAppearance(nil, onAppearance)
        end

        TriggerServerEvent("Index.player:SaveAppearance", response)
        SpawnPlayer()
    end

    FadeOut(1000)
    cb(true)
    skyCam(false)
    SetEntityCoords(PlayerPedId(), location.x, location.y, location.z)
    SetEntityHeading(PlayerPedId(), location.w)
    initAppearance(nil, onAppearance)
    FadeIn(1000)
end)

RegisterNUICallback('CreateCharacter', function(data, cb)
    local data = callback.use("Index.player:createCharacter", data)
    PlayerData:setDefault(data);

    cb(true)

    CreateThread(function()
        Wait(1000)
        local locations = spawn.spawnPoints;
        local spawnLabels = {}
        for i = 1, #locations do
            local coords = locations[i]
            table.insert(spawnLabels, {
                id = i,
                label = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
            })
        end

        SendNUIMessage({
            header = 'SetupLocations',
            props = spawnLabels
        })
    end)
end)

RegisterNUICallback('SelectCharacter', function(data, cb)
    FadeOut(300)
    local xPlayer = callback.use("Index.player:loadCharacter", data.id)
    local location = xPlayer.coords;
    PlayerData:setDefault(xPlayer);
    local appearance = not xPlayer.data.appearance.model and "" or xPlayer.data.appearance

    local onAppearance = function(response)
        if response then
            TriggerServerEvent("Index.player:SaveAppearance", response)
        end

        SpawnPlayer()
    end

    cb(true)
    skyCam(false)
    SetEntityCoords(PlayerPedId(), location.x, location.y, location.z)
    SetEntityHeading(PlayerPedId(), location.w)
    initAppearance(appearance, onAppearance)
    FadeIn(1000)
end)

RegisterNetEvent("Index.modules.player:loaded", function(characters)
    characters = array.new(characters)
    local chars = characters:map(function(character)
        local info = json.decode(character.info)

        return {
            id   = character.charId,
            name = (info.firstName or "unknow") .. " " .. (info.lastName or "unknow")
        }
    end)

    Wait(500)
    skyCam(true)
    DoScreenFadeIn(300)
    SetNuiFocus(true, true)

    SendNUIMessage({
        header = 'SetupCharacter',
        props = chars
    })
end)

--[[ EVENTS ]]
loaded.onChange(function(val)
    if (not val) then
        return
    end

    player.onEvent("loaded", PlayerData.get())
end)

player.on("logout", function()
    if not loaded.get() then
        return
    end

    loaded:set(false)
end)

--[[ BEHAVIOR ]]

local AutoBehavior, AutoTracker = array.new {
    { IsPedSwimming,           "Swimming" },
    { IsPedSwimmingUnderWater, "UnderWater" },
    { IsPedJumping,            "Jumping" },
    { IsPedReloading,          "Reloading" },
    { IsEntityInWater,         "InWater" }
}, array.new {
    {
        name = "Movement",
        behaviors = {
            { IsPedStill,     "idle" },
            { IsPedClimbing,  "climbing" },
            { IsPedWalking,   "walking" },
            { IsPedRunning,   "running" },
            { IsPedSprinting, "sprinting" },
        }
    }
}

local caches, tracks = {}, {}

hook.useTick(function()
    local ped = player.ped();

    AutoBehavior:map(function(behavior_)
        local func, behavior_ = table.unpack(behavior_);
        local state = func(ped);

        if (state and not caches[behavior_]) then
            caches[behavior_] = behavior:add(behavior_)
        elseif (not state and caches[behavior_]) then
            caches[behavior_].destroy()
            caches[behavior_] = nil
        end
    end)

    AutoTracker:map(function(track)
        if not tracks[track.name] then
            tracks[track.name] = behavior:addTrack(track.name, track.behaviors[2])
        end

        local tracker = tracks[track.name];
        local behaviors = array.new(track.behaviors);

        behaviors:map(function(behavior)
            local func, behavior = table.unpack(behavior);

            if (func(ped)) then
                tracker:set(behavior)
            end
        end)
    end)
end, 0)
