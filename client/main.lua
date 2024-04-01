local config = require 'config.client'
local previewCam
local scaleform
local currentButtonID =  1
local previousButtonID = 1
local arrowStart = {
    vec2(-3150.25, -1427.83),
    vec2(4173.08, 1338.72),
    vec2(-2390.23, 6262.24)
}

local function setupCamera()
    previewCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', -24.77, -590.35, 90.8, -2.0, 0.0, 160.0, 45.0, false, 2)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, false, 1, true, true)
end

local function stopCamera()
    SetCamActive(previewCam, false)
    DestroyCam(previewCam, true)
    RenderScriptCams(false, false, 1, true, true)
end

local function managePlayer()
    SetEntityCoords(cache.ped, -21.58, -583.76, 86.31, false, false, false, false)
    FreezeEntityPosition(cache.ped, true)

    SetTimeout(500, function()
        DoScreenFadeIn(5000)
    end)
end

local function setupMap()
    scaleform = lib.requestScaleformMovie('HEISTMAP_MP')

    CreateThread(function()
        while DoesCamExist(previewCam) do
            DrawScaleformMovie_3d(scaleform, -24.86, -593.38, 91.8, -180.0, -180.0, -20.0, 0.0, 2.0, 0.0, 3.815, 2.27, 1.0, 2)
            Wait(0)
        end
    end)
end

local function scaleformDetails(index)
    BeginScaleformMovieMethod(scaleform, 'ADD_HIGHLIGHT')
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamFloat(config.spawns[index].coords.x)
    ScaleformMovieMethodAddParamFloat(config.spawns[index].coords.y)
    ScaleformMovieMethodAddParamFloat(500.0)
    ScaleformMovieMethodAddParamInt(255)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(100)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'ADD_TEXT')
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamTextureNameString(config.spawns[index].label)
    ScaleformMovieMethodAddParamFloat(config.spawns[index].coords.x)
    ScaleformMovieMethodAddParamFloat(config.spawns[index].coords.y - 500)
    ScaleformMovieMethodAddParamFloat(25 - math.random(0, 50))
    ScaleformMovieMethodAddParamInt(26)
    EndScaleformMovieMethod()

    local randomCoords = arrowStart[math.random(1, #arrowStart)]

    BeginScaleformMovieMethod(scaleform, 'ADD_ARROW')
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamFloat(randomCoords.x)
    ScaleformMovieMethodAddParamFloat(randomCoords.y)
    ScaleformMovieMethodAddParamFloat(config.spawns[index].coords.x)
    ScaleformMovieMethodAddParamFloat(config.spawns[index].coords.y)
    ScaleformMovieMethodAddParamFloat(math.random(30, 80))
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'COLOUR_ARROW')
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamInt(255)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(100)
    EndScaleformMovieMethod()
end

local function updateScaleform()
    if previousButtonID == currentButtonID then return end

    BeginScaleformMovieMethod(scaleform, 'REMOVE_HIGHLIGHT')
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'REMOVE_TEXT')
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'REMOVE_ARROW')
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()

    scaleformDetails(currentButtonID)
end

local function inputHandler()
    while DoesCamExist(previewCam) do
        if IsControlJustReleased(0, 188) then
            previousButtonID = currentButtonID
            currentButtonID = currentButtonID - 1

            if currentButtonID < 1 then
                currentButtonID = 1
            end

            updateScaleform()
        elseif IsControlJustReleased(0, 187) then
            previousButtonID = currentButtonID
            currentButtonID = currentButtonID + 1

            if currentButtonID > #config.spawns then
                currentButtonID = #config.spawns
            end

            updateScaleform()
        elseif IsControlJustReleased(0, 191) then
            DoScreenFadeOut(1000)

            while not IsScreenFadedOut() do
                Wait(0)
            end

            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            TriggerEvent('QBCore:Client:OnPlayerLoaded')
            FreezeEntityPosition(cache.ped, false)

            local coords = config.spawns[currentButtonID].coords

            SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, false)
            SetEntityHeading(cache.ped, coords.w or 0.0)
            DoScreenFadeIn(1000)
            break
        end

        Wait(0)
    end
    stopCamera()
end

AddEventHandler('qb-spawn:client:setupSpawns', function()
    config.spawns[#config.spawns+1] = {
        label = 'Last Location',
        coords = lib.callback.await('qbx_spawn:server:getLastLocation')
    }

    Wait(400)

    managePlayer()
    setupCamera()
    setupMap()

    Wait(400)

    scaleformDetails(currentButtonID)
    inputHandler()
end)
