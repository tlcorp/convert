Config = {}

--[[
    In case of any problems, refer to the documentation:
    https://docs.vames-store.com/assets/vms_spawnselector

    Client Trigger: "vms_spawnselector:open"
    Client Export: exports['vms_spawnselector']:OpenSpawnSelector
]]

------------------------------ █▀ █▀▄ ▄▀▄ █▄ ▄█ ██▀ █   █ ▄▀▄ █▀▄ █▄▀ ------------------------------
------------------------------ █▀ █▀▄ █▀█ █ ▀ █ █▄▄ ▀▄▀▄▀ ▀▄▀ █▀▄ █ █ ------------------------------
local frameworkAutoFind = function()
    if GetResourceState('es_extended') ~= 'missing' then
        return "ESX"
    elseif GetResourceState('qb-core') ~= 'missing' then
        return "QB-Core"
    end
end

Config.Core = frameworkAutoFind()
Config.CoreExport = function()
    if Config.Core == "ESX" then
        return exports['es_extended']:getSharedObject() -- ESX
    else
        return exports['qb-core']:GetCoreObject() -- QB-CORE
    end
end

------------------------ █▄ ▄█ ▄▀▄ █ █▄ █   ▄▀▀ ██▀ ▀█▀ ▀█▀ █ █▄ █ ▄▀  ▄▀▀ ------------------------
------------------------ █ ▀ █ █▀█ █ █ ▀█   ▄██ █▄▄  █   █  █ █ ▀█ ▀▄█ ▄██ ------------------------
Config.Notification = function(message, time, type)
    if type == "error" then
        if GetResourceState("vms_notify") == 'started' then
            exports['vms_notify']:Notification('SPAWN SELECTOR', message, time, '#f52a2a', 'fa-solid fa-map-pin')
        else
            TriggerEvent('esx:showNotification', message)
            TriggerEvent('QBCore:Notify', message, 'error', time)
        end
    end
end

Config.Translate = {
    ['cannot_spawn_on_dead'] = "Your previous game ended in death, you must be reborn in the last location.",
    ['house_label'] = 'House',
}

Config.Hud = {
    Enable = function()
        if GetResourceState('vms_hud') ~= 'missing' then
            exports['vms_hud']:Display(true)
        end
        
    end,
    Disable = function()
        if GetResourceState('vms_hud') ~= 'missing' then
            exports['vms_hud']:Display(false)
        end

    end
}

Config.WeatherSync = "vSync" -- "cd_easytime", "qb-weathersync", "vSync"
Config.Weather = 'CLEAR' -- weather type
Config.Time = {hour = 20, minutes = 0}

-- @OnDeadOnlyLastPosition: When the player is dead, should he be able to be reborn only in the previous location or can he be reborn in any location
Config.OnDeadOnlyLastPosition = true

-- @UseHousingSpawns: In config.client.lua & config.server.lua you can adjust to your housing system if you are using other than: esx_property / qs-housing / qb-houses / ps-housing / bcs_housing 
Config.UseHousingSpawns = true

-- @CheckJail: In config.server.lua you can adjust to your jail system if you are using other than: esx_jail / esx-qalle-jail / mx_jail / qb-prison / pickle_prisons / rcore_prison
Config.CheckJail = true
Config.IsJailedTeleportOnCoords = vector4(1724.01, 2535.58, 44.56, 110.56) -- vector4 or nil (nil = last position)

-- @UseOnlyFirstJoinSelect: Using this option, the player will be able to choose the spawn location only once, until the server restarts
Config.UseOnlyFirstJoinSelect = false

Config.Spawns = {
    [1] = {
        camCoords = vector3(1151.57, -627.64, 65.27),
        spawnCoords = vector4(1127.14, -645.29, 55.79, 281.89),
        label = "Mirror Park",
        address = "Mirror Park Blvd",
    },
    [2] = {
        camCoords = vector3(-1011.8, -2714.38, 23.61),
        spawnCoords = vector4(-1037.8, -2737.82, 19.17, 325.98),
        label = "Airport",
        address = "New Empire Way",
    },
    [3] = {
        camCoords = vector3(-1249.22, -1469.2, 10.6),
        spawnCoords = vector4(-1265.34, -1481.28, 3.33, 286.73),
        label = "Beach",
        address = "Aguja St.",
    },
    [4] = {
        camCoords = vector3(1113.8, 2680.31, 46.42),
        spawnCoords = vector4(1138.84, 2672.44, 37.13, 89.32),
        label = "Sandy Shores",
        address = "Route 68",
    },
    [5] = {
        camCoords = vector3(176.68, 6555.92, 43.24),
        spawnCoords = vector4(159.59, 6587.62, 31.12, 187.2),
        label = "Paleto Bay",
        address = "Great Ocean Hwy",
    },
}

Config.OnlyJobsSpawns = {
    ['police'] = {
        {
            camCoords = vector3(400.97, -953.46, 42.28),
            spawnCoords = vector4(427.18, -974.64, 30.71, 93.26),
            label = "Police Department",
            address = "Mission Row",
        },
        {
            camCoords = vector3(1873.35, 3667.73, 38.64),
            spawnCoords = vector4(1854.2, 3681.26, 33.27, 214.38),
            label = "Police Department",
            address = "Sandy Shores",
        },
    },
    ['ambulance'] = {
        {
            camCoords = vector3(252.44, -595.97, 54.05),
            spawnCoords = vector4(282.22, -587.52, 42.28, 69.9),
            label = "Hospital",
            address = "Pillbox Hill",
        },
    },
    ['mechanic'] = {
        {
            camCoords = vector3(-220.52, -1296.49, 38.08),
            spawnCoords = vector4(-202.93, -1307.75, 30.28, 5.08),
            label = "Benny'S",
            address = "Alta St.",
        },
    },
}