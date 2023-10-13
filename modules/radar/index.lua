local hook    = import 'hook';
local radar   = hook.useState(false, "@game/radar");
local minimap = RequestScaleformMovie("minimap")
local module  = {}

local function ToggleRadar(state)
    DisplayRadar(state)
    BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
    ScaleformMovieMethodAddParamInt(3)
    EndScaleformMovieMethod()
end

radar.onChange(ToggleRadar)
CreateThread(function()
    local defaultAspectRatio = 1920 / 1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end

    ToggleRadar(false)
    RequestStreamedTextureDict("circlemap", false)
    while not HasStreamedTextureDictLoaded("circlemap") do
        Wait(100)
    end

    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
    SetMinimapClipType(1)
    SetMinimapComponentPosition('minimap', 'L', 'B', -0.0100 + minimapOffset, -0.029, 0.16, 0.245)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.200 + minimapOffset, 0.08, 0.071, 0.164)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, -0.06, 0.18, 0.22)
    ThefeedSpsExtendWidescreenOn()
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetRadarBigmapEnabled(true, false)
    Wait(150)
    SetRadarBigmapEnabled(false, false)
end)

function module.set(state)
    return radar:set(state)
end

function module.state()
    return radar.get()
end

return module
