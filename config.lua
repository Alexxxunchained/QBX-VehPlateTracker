Config = {}

-- 追踪器物品设置
-- Item for tracking
Config.TrackerItem = 'cryptostick'               -- Normal Tracker Item 普通追踪器物品
Config.PoliceTrackerItem = 'police_tracker'      -- Police Tracker Item 警察追踪器物品

-- 追踪设置
-- Tracking config
Config.MaxTrackingTime = 5 * 60 * 1000 -- 5 minutes in milliseconds    5分钟
Config.MaxTrackedVehicles = 1           -- Limit of tracked vehicles 最大追踪车辆数
Config.MaxPoliceTrackedVehicles = 3      -- Limit of police tracked vehicles 最大警察追踪车辆数

-- 追踪器图标设置
-- Tracker blip
Config.PoliceBlipColor = 3 -- 警用追踪器的图标颜色 当前为蓝色 Blue color for police trackers
Config.NormalBlipColor = 1 -- 普通追踪器的图标颜色 当前为红色 Red color for normal trackers

-- 追踪器头标设置
-- Marker
Config.MarkerType = 0 -- 当前为一个向下的箭头 Arrow pointing downward, if u want to change this marker check out this: https://docs.fivem.net/docs/game-references/markers/
Config.MarkerSize = vector3(1.0, 1.0, 1.0)
Config.MarkerHeight = 4.0 -- 标记高度 Height above vehicle
Config.NormalMarkerColor = vector3(255, 0, 0) -- 普通追踪器标记颜色 Red for normal tracker
Config.PoliceMarkerColor = vector3(0, 0, 255) -- 警用追踪器标记颜色 Blue for police tracker