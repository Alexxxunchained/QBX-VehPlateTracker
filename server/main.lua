local QBCore = exports['qb-core']:GetCoreObject()
local policeTrackedVehicles = {}

QBCore.Functions.CreateUseableItem(Config.TrackerItem, function(source)
    TriggerClientEvent('vehicle_tracker:use', source)
end)

-- PD tracker is only used by PD
QBCore.Functions.CreateUseableItem(Config.PoliceTrackerItem, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent('vehicle_tracker:usePolice', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = '车辆追踪器', -- 'Vehicle Tracker'
            description = '警用雷达卫星拒绝你的访问', -- 'Police radar satellite denied your access'
            type = 'error'
        })
    end
end)

RegisterNetEvent('vehicle_tracker:addPoliceTracker', function(plate)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        policeTrackedVehicles[plate] = true
        -- Sync to all police
        local Players = QBCore.Functions.GetQBPlayers()
        for _, v in pairs(Players) do
            if v.PlayerData.job.name == "police" then
                TriggerClientEvent('vehicle_tracker:syncPoliceTrackers', v.PlayerData.source, plate)
            end
        end
    end
end)

RegisterNetEvent('vehicle_tracker:removePoliceTracker', function(plate)
    policeTrackedVehicles[plate] = nil
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        for plate, _ in pairs(policeTrackedVehicles) do
            TriggerClientEvent('vehicle_tracker:syncPoliceTrackers', source, plate)
        end
    end
end)