local config = require 'config.client'
local spawns
local previewCam
local scaleform
local buttonsScaleform
local currentButtonId = 1
local previousButtonId = 1

local function setupCamera()
    previewCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', -24.77, -590.35, 90.8, -2.0, 0.0, 160.0, 45.0, false, 2)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, false, 1, true, true)
end

local function stopCamera()
    if not previewCam then
        return
    end
    SetCamActive(previewCam, false)
    DestroyCam(previewCam, true)
    RenderScriptCams(false, false, 1, true, true)

    mapScaleform:Method('CLEANUP')
    previewCam = nil
end

local function managePlayer()
    SetEntityCoords(cache.ped, -21.58, -583.76, 86.31, false, false, false, false)
    FreezeEntityPosition(cache.ped, true)
    DisplayRadar(false)

    SetTimeout(500, function()
        DoScreenFadeIn(5000)
    end)
end

local function createSpawnArea()
    for i = 1, #spawns, 1 do    -- Loop through the spawns
        local spawn = spawns[i] -- Get the spawn

        -- Add the area to the map scaleform
        mapScaleform:MethodArgs('ADD_AREA', { i, spawn.coords.x, spawn.coords.y, 500.0, 255, 0, 0, 100 })
    end
end

local function setupInstructionalScaleform()
    -- Clear Current Buttons
    buttonScaleform:Method('CLEAR_ALL')
    buttonScaleform:MethodArgs("SET_CLEAR_SPACE", { 200 })

    -- Define Buttons
    local sumbit = GetControlInstructionalButton(2, 191, true)
    local up = GetControlInstructionalButton(2, 188, true)
    local down = GetControlInstructionalButton(2, 187, true)

    -- Add Buttons
    buttonScaleform:MethodArgs('SET_DATA_SLOT', { 0, sumbit, 'Submit' })
    buttonScaleform:MethodArgs('SET_DATA_SLOT', { 1, up, 'Down' })
    buttonScaleform:MethodArgs('SET_DATA_SLOT', { 2, down, 'Up' })

    -- Draw Buttons
    buttonScaleform:Method('DRAW_INSTRUCTIONAL_BUTTONS')
end

local function setupMap()
    mapScaleform = qbx.newScaleform('HEISTMAP_MP')              -- Create a new scaleform
    buttonScaleform = qbx.newScaleform('INSTRUCTIONAL_BUTTONS') -- Create a new scaleform

    CreateThread(function()
        setupInstructionalScaleform() -- Setup the instructional scaleform
        createSpawnArea()             -- Add the spawn areas to the map

        if not previewCam then        -- check the camera is created
            return
        end

        mapScaleform:Draw(true)           -- Draw the map scaleform
        buttonScaleform:Draw(true)        -- Draw the button scaleform

        while DoesCamExist(previewCam) do -- while the camera exists
            HideHudComponentThisFrame(6)  -- Vehicle Name
            HideHudComponentThisFrame(7)  -- Area Name
            HideHudComponentThisFrame(9)  -- Street Name

            Wait(0)                       -- Wait a tick
        end

        -- Clean up the scaleforms
        mapScaleform:Dispose()
        buttonScaleform:Dispose()

        -- Set the scaleform references to nil
        mapScaleform = nil
        buttonScaleform = nil
    end)
end

local function scaleformDetails(index)
    local spawn = spawns[index]
    local arrowStart = {
        vec2(-3150.25, -1427.83),
        vec2(4173.08, 1338.72),
        vec2(-2390.23, 6262.24)
    }

    -- Add the highlight to the map 
    mapScaleform:MethodArgs("ADD_HIGHLIGHT", { index, spawn.coords.x, spawn.coords.y, 500.0, 0, 255, 0, 100 })

    -- Add the area to the map 
    mapScaleform:MethodArgs("COLOUR_AREA", { index, 0, 255, 0, 100 })

    -- Add the text to the map
    mapScaleform:MethodArgs("ADD_TEXT", { index, spawn.label, spawn.coords.x,
        spawn.coords.y - 500, 25 - math.random(0, 50), 24, 100, 255, true })

    -- Get a random arrow start
    local randomCoords = arrowStart[math.random(#arrowStart)]

    -- Add the arrow to the map
    mapScaleform:MethodArgs("ADD_ARROW", { index, randomCoords.x, randomCoords.y,
        spawn.coords.x, spawn.coords.y, math.random(30, 80) })

    -- Colour the arrow
    mapScaleform:MethodArgs("COLOUR_ARROW", { index, 255, 0, 0, 100 })

end

local function updateScaleform()
    if previousButtonId == currentButtonId then return end

    for i = 1, #spawns, 1 do                                          -- Loop through the spawns
        mapScaleform:MethodArgs('REMOVE_HIGHLIGHT', { i })            -- Remove the highlight
        mapScaleform:MethodArgs('REMOVE_TEXT', { i })                 -- Remove the text
        mapScaleform:MethodArgs('REMOVE_ARROW', { i })                -- Remove the arrow
        mapScaleform:MethodArgs('COLOUR_AREA', { i, 255, 0, 0, 100 }) -- Reset the colour
    end

    scaleformDetails(currentButtonId)
end

local function inputHandler()
    if not previewCam then
        return
    end

    while DoesCamExist(previewCam) do
        if IsControlJustReleased(0, 188) then
            previousButtonId = currentButtonId
            currentButtonId -= 1

            if currentButtonId < 1 then
                currentButtonId = #spawns
            end

            updateScaleform()
        elseif IsControlJustReleased(0, 187) then
            previousButtonId = currentButtonId
            currentButtonId += 1

            if currentButtonId > #spawns then
                currentButtonId = 1
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
            DisplayRadar(true)

            local spawnData = spawns[currentButtonId]

            if spawnData.propertyId then
                TriggerServerEvent('qbx_properties:server:enterProperty', { id = spawnData.propertyId, isSpawn = true })
            else
                SetEntityCoords(cache.ped, spawnData.coords.x, spawnData.coords.y, spawnData.coords.z, false, false,
                    false, false)
                SetEntityHeading(cache.ped, spawnData.coords.w or 0.0)
            end

            DoScreenFadeIn(1000)

            break
        end

        Wait(0)
    end

    stopCamera()
end

RegisterNetEvent('qb-spawn:client:setupSpawns', function()
    spawns = {}

    local lastCoords, lastPropertyId = lib.callback.await('qbx_spawn:server:getLastLocation')
    spawns[#spawns + 1] = {
        label = locale('last_location'),
        coords = lastCoords,
        propertyId = lastPropertyId
    }

    for i = 1, #config.spawns do
        spawns[#spawns + 1] = config.spawns[i]
    end

    local properties = lib.callback.await('qbx_spawn:server:getProperties')
    for i = 1, #properties do
        spawns[#spawns + 1] = properties[i]
    end

    Wait(400)

    managePlayer()
    setupCamera()
    setupMap()

    Wait(400)

    scaleformDetails(currentButtonId)
    inputHandler()
end)