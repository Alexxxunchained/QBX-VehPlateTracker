local QBCore = exports['qb-core']:GetCoreObject()
local trackedVehicles = {}
local policeTrackedVehicles = {}

-- 按照车牌号获取车辆信息并且记录
-- Function to get vehicle by plate
local function GetVehicleByPlate(plate)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            if vehiclePlate:upper():gsub("%s+", "") == plate:upper():gsub("%s+", "") then
                return vehicle
            end
        end
    end
    return nil
end

-- 创建blip
-- Helper function to create vehicle blip
local function CreateVehicleBlip(vehicle, plate, isPoliceTracker)
    local blip = AddBlipForEntity(vehicle)
    SetBlipSprite(blip, 326) -- Car blip sprite
    SetBlipColour(blip, isPoliceTracker and Config.PoliceBlipColor or Config.NormalBlipColor)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("追踪车辆: " .. plate)
    EndTextCommandSetBlipName(blip)
    return blip
end

-- 绘制标记
-- Draw marker above vehicle
local function DrawTrackerMarker(coords, isPoliceTracker)
    local markerColor = isPoliceTracker and Config.PoliceMarkerColor or Config.NormalMarkerColor
    DrawMarker(
        Config.MarkerType,
        coords.x,
        coords.y,
        coords.z + Config.MarkerHeight,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        Config.MarkerSize.x,
        Config.MarkerSize.y,
        Config.MarkerSize.z,
        markerColor.x,
        markerColor.y,
        markerColor.z,
        100,
        false,
        true,
        2,
        false,
        nil,
        nil,
        false
    )
end

-- 取消追踪
-- Remove tracking after timeout
local function RemoveTracking(plate, isPoliceTracker)
    local vehicleList = isPoliceTracker and policeTrackedVehicles or trackedVehicles
    if vehicleList[plate] then
        RemoveBlip(vehicleList[plate].blip)
        vehicleList[plate] = nil
        if isPoliceTracker then
            TriggerServerEvent('vehicle_tracker:removePoliceTracker', plate)
        end
        lib.notify({
            title = '车辆追踪器',
            description = '对该车辆:' .. plate .. '的追踪已失灵',
            type = 'inform'
        })
    end
end

-- 追踪车辆
-- Track vehicle function
local function TrackVehicle(plate, isPoliceTracker)
    local vehicleList = isPoliceTracker and policeTrackedVehicles or trackedVehicles
    local maxVehicles = isPoliceTracker and Config.MaxPoliceTrackedVehicles or Config.MaxTrackedVehicles

    -- 检查是否达到追踪上限
    -- Check if maximum tracked vehicles reached
    if #vehicleList >= maxVehicles then
        lib.notify({
            title = '车辆追踪器', -- 'Vehicle Tracker'
            description = '已达最大追踪车辆上限',  -- 'Maximum tracked vehicles reached'
            type = 'error'
        })
        return false
    end

    local vehicle = GetVehicleByPlate(plate)
    if not vehicle then
        lib.notify({
            title = '车辆追踪器',  -- 'Vehicle Tracker'
            description = '雷达卫星未检测到该车辆',  -- 'Radar satellite did not detect the vehicle'
            type = 'error'
        })
        return false
    end

    -- 创建blip并存储信息
    -- Create blip and store tracking info
    local blip = CreateVehicleBlip(vehicle, plate, isPoliceTracker)
    vehicleList[plate] = {
        blip = blip,
        vehicle = vehicle,
        expiresAt = GetGameTimer() + Config.MaxTrackingTime
    }

    if isPoliceTracker then
        TriggerServerEvent('vehicle_tracker:addPoliceTracker', plate)
    end

    lib.notify({
        title = '车辆追踪器',  -- 'Vehicle Tracker'
        description = '已开始对该车辆:' .. plate .. '的追踪',  -- 'Tracking started for vehicle:' .. plate
        type = 'success'
    })
    return true
end

-- oxlib part
-- Show input dialog
local function ShowTrackingUI(isPoliceTracker)
    local input = lib.inputDialog('车辆追踪器', { -- 'Vehicle Tracker'
        {type = 'input', label = '车牌号', description = '输入要追踪的车辆车牌号(不分大小写)'}, -- label = 'Veh Plate', description = 'Enter the plate number of the vehicle to track (case insensitive)'
    })

    if not input then return end
    local plate = input[1]
    if plate then
        TrackVehicle(plate:upper(), isPoliceTracker)
    end
end

-- 追踪车辆列表
-- Show tracked vehicles list
local function ShowTrackedVehicles(isPoliceTracker)
    local vehicleList = isPoliceTracker and policeTrackedVehicles or trackedVehicles
    local options = {}
    
    for plate, _ in pairs(vehicleList) do
        table.insert(options, {
            title = plate,
            description = '点击以停止追踪', -- 'Click to stop tracking'
            onSelect = function()
                RemoveTracking(plate, isPoliceTracker)
            end
        })
    end

    if #options == 0 then
        table.insert(options, {
            title = '当前无追踪车辆', -- 'No tracked vehicles'
            description = '请使用车辆追踪器进行追踪', -- 'Use vehicle tracker to track'
        })
    end

    lib.registerContext({
        id = 'tracked_vehicles',
        title = '车辆追踪器', -- 'Vehicle Tracker'
        options = options
    })

    lib.showContext('tracked_vehicles')
end

-- 普通追踪器part
-- normal tracker
RegisterNetEvent('vehicle_tracker:use', function()
    local options = {
        {
            title = '追踪车辆', -- 'Track Vehicle'
            description = '输入要追踪的车辆车牌号(不分大小写)', -- 'Enter the plate number of the vehicle to track (case insensitive)'
            onSelect = function()
                ShowTrackingUI(false)
            end
        },
        {
            title = '查看追踪车辆', -- 'View Tracked Vehicles'
            description = '查看并管理当前追踪的车辆', -- 'View and manage currently tracked vehicles'
            onSelect = function()
                ShowTrackedVehicles(false)
            end
        }
    }

    lib.registerContext({
        id = 'vehicle_tracker_menu',
        title = '车辆追踪器', -- 'Vehicle Tracker'
        options = options
    })

    lib.showContext('vehicle_tracker_menu')
end)

-- 警用追踪器part
-- police tracker
RegisterNetEvent('vehicle_tracker:usePolice', function()
    local options = {
        {
            title = '追踪车辆(警用)',  -- 'Track Vehicle (Police)'
            description = '输入要追踪的车辆车牌号(不分大小写)', -- 'Enter the plate number of the vehicle to track (case insensitive)'
            onSelect = function()
                ShowTrackingUI(true)
            end
        },
        {
            title = '查看追踪车辆', -- 'View Tracked Vehicles'
            description = '查看并管理当前追踪的车辆', -- 'View and manage currently tracked vehicles'
            onSelect = function()
                ShowTrackedVehicles(true)
            end
        }
    }

    lib.registerContext({
        id = 'police_tracker_menu',
        title = '警用车辆追踪器', -- 'Police Vehicle Tracker'
        options = options
    })

    lib.showContext('police_tracker_menu')
end)

-- 同步blip给所有pd
-- Sync police tracked vehicles
RegisterNetEvent('vehicle_tracker:syncPoliceTrackers', function(plate, vehicle)
    if not policeTrackedVehicles[plate] and vehicle then
        local blip = CreateVehicleBlip(vehicle, plate, true)
        policeTrackedVehicles[plate] = {
            blip = blip,
            vehicle = vehicle,
            expiresAt = GetGameTimer() + Config.MaxTrackingTime
        }
    end
end)

-- 用线程检测blip坐标和检查到期时间
-- Update blips position and check expiration
CreateThread(function()
    while true do
        local currentGameTime = GetGameTimer()
        
        -- Update normal trackers
        for plate, data in pairs(trackedVehicles) do
            if currentGameTime >= data.expiresAt then
                RemoveTracking(plate, false)
            elseif DoesEntityExist(data.vehicle) then
                SetBlipCoords(data.blip, GetEntityCoords(data.vehicle))
            else
                RemoveTracking(plate, false)
            end
        end
        
        -- 警用追踪part
        -- Update police trackers
        for plate, data in pairs(policeTrackedVehicles) do
            if currentGameTime >= data.expiresAt then
                RemoveTracking(plate, true)
            elseif DoesEntityExist(data.vehicle) then
                SetBlipCoords(data.blip, GetEntityCoords(data.vehicle))
            else
                RemoveTracking(plate, true)
            end
        end
        
        Wait(200)
    end
end)

-- 绘制标记
-- Update blips position and check expiration
CreateThread(function()
    while true do
        local currentGameTime = GetGameTimer()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000
        
        for plate, data in pairs(trackedVehicles) do
            if currentGameTime >= data.expiresAt then
                RemoveTracking(plate, false)
            elseif DoesEntityExist(data.vehicle) then
                local coords = GetEntityCoords(data.vehicle)
                SetBlipCoords(data.blip, coords)
                
                -- 我测试了resmon占用表现，在100米左右绘制标记的表现最好，不会造成太大的负担的同时功能表现也很不错，但存在一种理论上的情况就是说如果PD在线人数多，而你们又在追踪可能同时好几台车辆的话，也许会出现性能问题，这个需要你们测试观察，因为我是在本地服一个人和原住民测试的，所以很难定义绘制marker这部分是否必要，但大多数服务器搞的场景文字和头标显示都会占用巨量的资源倒也没出现过很严重的问题，所以我在想应该没事
                -- Draw marker if player is close enough, for some reason of performance, its could be a problem if PD are tracking multiple vehicles at once, not sure will it be a resmon consuming monster, but I think its fine
                if #(playerCoords - coords) < 100.0 then
                    DrawTrackerMarker(coords, false)
                    sleep = 0
                end
            else
                RemoveTracking(plate, false)
            end
        end
        
        for plate, data in pairs(policeTrackedVehicles) do
            if currentGameTime >= data.expiresAt then
                RemoveTracking(plate, true)
            elseif DoesEntityExist(data.vehicle) then
                local coords = GetEntityCoords(data.vehicle)
                SetBlipCoords(data.blip, coords)
                
                if #(playerCoords - coords) < 100.0 then
                    DrawTrackerMarker(coords, true)
                    sleep = 0
                end
            else
                RemoveTracking(plate, true)
            end
        end
        
        Wait(sleep)
    end
end)