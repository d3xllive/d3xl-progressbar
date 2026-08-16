-- =================================================================
-- D3XL FiveM Standalone Progress Bar Client Script
-- Full ox_lib & QBCore Feature Matrix Implementation:
-- - Movement, Car, Combat, Mouse, Sprint Disable Toggles
-- - Animation Dict/Clip & Scenario Support
-- - Prop Attachment & Cleanup
-- - Synchronous & Asynchronous Returns
-- Author: d3xl
-- =================================================================

Config = Config or {}
local isBusy = false
local currentFinishCb = nil
local currentCancelCb = nil
local attachedPropObj = nil
local attachedPropObj2 = nil

-- Helper to Load Model
local function loadModel(model)
    if type(model) == 'string' then model = GetHashKey(model) end
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end
    end
    return model
end

-- Helper to Attach Prop
local function attachProp(ped, propData)
    if not propData or not propData.model then return nil end
    local model = loadModel(propData.model)
    local coords = GetEntityCoords(ped)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    
    local bone = propData.bone or 60309
    local p = propData.pos or propData.coords or vector3(0.0, 0.0, 0.0)
    local r = propData.rot or vector3(0.0, 0.0, 0.0)
    
    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, bone), p.x, p.y, p.z, r.x, r.y, r.z, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)
    return obj
end

-- Helper to Remove Props
local function removeProps()
    if attachedPropObj and DoesEntityExist(attachedPropObj) then
        DeleteEntity(attachedPropObj)
        attachedPropObj = nil
    end
    if attachedPropObj2 and DoesEntityExist(attachedPropObj2) then
        DeleteEntity(attachedPropObj2)
        attachedPropObj2 = nil
    end
end

-- Core Progress Function (Supports ox_lib table OR QBCore params)
function Progress(name, label, duration, useWhileDead, canCancel, disableControls, anim, prop, propTwo, onFinish, onCancel)
    if isBusy then return false end
    isBusy = true

    -- Handle ox_lib single table parameter syntax
    local data = {}
    if type(name) == 'table' then
        data = name
        label = data.label or data.text or 'LOADING'
        duration = data.duration or 5000
        useWhileDead = data.useWhileDead or false
        canCancel = data.canCancel or true
        disableControls = data.disable or data.controlDisables or {}
        anim = data.anim or data.animation
        prop = data.prop
        propTwo = data.propTwo
    else
        data = {
            name = name,
            label = label,
            duration = duration,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            disable = disableControls,
            anim = anim,
            prop = prop,
            propTwo = propTwo
        }
    end

    currentFinishCb = onFinish
    currentCancelCb = onCancel

    local ped = PlayerPedId()

    -- 1. Animation & Scenario Handler
    if anim then
        if anim.scenario then
            TaskStartScenarioInPlace(ped, anim.scenario, 0, true)
        elseif (anim.dict or anim.anim) and (anim.clip or anim.anim) then
            local dict = anim.dict or anim.anim
            local clip = anim.clip or anim.anim
            Citizen.CreateThread(function()
                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do
                    Citizen.Wait(10)
                end
                TaskPlayAnim(ped, dict, clip, 8.0, -8.0, duration or 5000, anim.flag or 49, 0, false, false, false)
            end)
        end
    end

    -- 2. Prop Attachment Handler
    if prop then
        attachedPropObj = attachProp(ped, prop)
    end
    if propTwo then
        attachedPropObj2 = attachProp(ped, propTwo)
    end

    -- 3. Precise Control Locking Loop (ox_lib style)
    Citizen.CreateThread(function()
        local dis = disableControls or {}
        while isBusy do
            Citizen.Wait(0)
            
            -- Disable Player Movement (Walking/Running)
            if dis.move or dis.disableMovement then
                DisableControlAction(0, 30, true) -- MoveLeftRight
                DisableControlAction(0, 31, true) -- MoveUpDown
            end

            -- Disable Sprinting
            if dis.sprint then
                DisableControlAction(0, 21, true) -- Sprint
            end

            -- Disable Vehicle Driving
            if dis.car or dis.disableCarMovement then
                DisableControlAction(0, 63, true) -- VehicleMoveLeftRight
                DisableControlAction(0, 71, true) -- VehicleAccelerate
                DisableControlAction(0, 72, true) -- VehicleBrake
                DisableControlAction(0, 75, true) -- Exit Vehicle
            end

            -- Disable Combat & Shooting
            if dis.combat or dis.disableCombat then
                DisableControlAction(0, 24, true)  -- Attack
                DisableControlAction(0, 25, true)  -- Aim
                DisableControlAction(0, 37, true)  -- Select Weapon
                DisableControlAction(0, 140, true) -- Melee
            end

            -- Disable Mouse Camera Look
            if dis.mouse then
                DisableControlAction(0, 1, true) -- LookLeftRight
                DisableControlAction(0, 2, true) -- LookUpDown
            end

            -- Cancel Key Check (Default: X / Key 73)
            if canCancel and IsControlJustPressed(0, Config.CancelKey or 73) then
                CancelProgress('İPTAL')
            end
        end
    end)

    SendNUIMessage({
        action = 'progress',
        label = label or 'LOADING',
        duration = duration or 5000,
        canCancel = canCancel or false,
        position = Config.Position or 'center-bottom'
    })

    return true
end

function CancelProgress(reason)
    if not isBusy then return end
    isBusy = false
    SendNUIMessage({ action = 'fail', reason = reason or 'İPTAL' })

    local ped = PlayerPedId()
    ClearPedTasks(ped)
    removeProps()

    if currentCancelCb then
        currentCancelCb()
        currentCancelCb = nil
    end
    currentFinishCb = nil
end

function FailProgress(reason)
    CancelProgress(reason or 'BAŞARISIZ')
end

-- =================================================================
-- Exports & Framework Compatibility Layer
-- =================================================================

-- 1. Standalone & Qbox Exports
exports('Progress', Progress)
exports('Progressbar', function(name, label, duration, useWhileDead, canCancel, disableControls, anim, prop, propTwo, onFinish, onCancel)
    return Progress(name, label, duration, useWhileDead, canCancel, disableControls, anim, prop, propTwo, onFinish, onCancel)
end)
exports('Cancel', CancelProgress)
exports('Fail', FailProgress)
exports('isDoingAction', function() return isBusy end)

-- 2. ox_lib progressBar Export (Synchronous Promise Return)
exports('progressBar', function(data)
    if not data then return false end
    local p = promise.new()
    
    local success = Progress(data, nil, nil, nil, nil, nil, nil, nil, nil, 
        function() p:resolve(true) end,
        function() p:resolve(false) end
    )
    
    if not success then return false end
    return Citizen.Await(p)
end)

-- 3. QBCore Net Event & Function Override
RegisterNetEvent('progressbar:client:progress', function(action, finish, cancel)
    if Config.EnableQBCoreProgress ~= false and action then
        Progress(
            action.name,
            action.label,
            action.duration,
            action.useWhileDead,
            action.canCancel,
            action.controlDisables,
            action.animation,
            action.prop,
            action.propTwo,
            finish,
            cancel
        )
    end
end)

RegisterNetEvent('progressbar:client:cancel', function(reason)
    FailProgress(reason)
end)

-- 4. ESX Progressbar Compatibility
RegisterNetEvent('esx_progressbar:start', function(duration, label, cb)
    Progress('esx_pb', label, duration, false, true, {}, nil, nil, nil, cb, cb)
end)

-- NUI Callbacks
RegisterNUICallback('finishProgress', function(data, cb)
    cb('ok')
    if isBusy then
        isBusy = false
        ClearPedTasks(PlayerPedId())
        removeProps()
        if currentFinishCb then
            currentFinishCb()
            currentFinishCb = nil
        end
        currentCancelCb = nil
    end
end)

RegisterNUICallback('cancelProgress', function(data, cb)
    cb('ok')
    if isBusy then
        isBusy = false
        ClearPedTasks(PlayerPedId())
        removeProps()
        if currentCancelCb then
            currentCancelCb()
            currentCancelCb = nil
        end
        currentFinishCb = nil
    end
end)

-- =================================================================
-- In-Game Test Commands
-- =================================================================
if Config.EnableTestCommand ~= false then

    -- Command 1: Test with Movement ALLOWED (Oyuncu Yürüyebilir)
    RegisterCommand('testmove', function()
        Progress({
            name = 'test_move',
            label = 'YÜRÜMEK SERBEST PROGRESS',
            duration = 6000,
            canCancel = true,
            disable = {
                move = false,    -- Oyuncu serbestçe yürüyebilir!
                car = true,
                combat = true
            }
        }, nil, nil, nil, nil, nil, nil, nil, nil,
        function()
            TriggerEvent('chat:addMessage', { color = { 54, 255, 159 }, args = { "D3XL PROGRESS", "Yürüme serbest işlemi bitti!" } })
        end)
    end, false)

    -- Command 2: Test with Movement DISABLED (Oyuncu Yürüyemez)
    RegisterCommand('testnomove', function()
        Progress({
            name = 'test_nomove',
            label = 'YÜRÜMEK YASAK PROGRESS',
            duration = 6000,
            canCancel = true,
            disable = {
                move = true,     -- Oyuncu yürüyemez!
                car = true,
                combat = true
            }
        }, nil, nil, nil, nil, nil, nil, nil, nil,
        function()
            TriggerEvent('chat:addMessage', { color = { 54, 255, 159 }, args = { "D3XL PROGRESS", "Yürüme kilitli işlem bitti!" } })
        end)
    end, false)

end
