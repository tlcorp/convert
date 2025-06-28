onPlayerSpawned = function(isFirstSpawn)
    if isFirstSpawn then
        -- exports['vms_guidebook']:openBook("default")
    else
        
    end
end

RegisterNetEvent("vms_spawnselector:WeatherSync")
AddEventHandler("vms_spawnselector:WeatherSync", function(boolean)
    if boolean then
        Wait(150)
        if Config.WeatherSync == 'cd_easytime' then
            TriggerEvent('cd_easytime:PauseSync', true)
        elseif Config.WeatherSync == 'qb-weathersync' then
            TriggerEvent('qb-weathersync:client:DisableSync')
        elseif Config.WeatherSync == 'vSync' then
            TriggerEvent('vSync:toggle', false)
            Wait(100)
            TriggerEvent('vSync:updateWeather', Config.Weather, false)
        end
        Wait(50)
        NetworkOverrideClockTime(Config.Time.hour, Config.Time.minutes, 0)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(Config.Weather)
        SetWeatherTypeNow(Config.Weather)
        SetWeatherTypeNowPersist(Config.Weather)
    else
        Wait(150)
        if Config.WeatherSync == 'cd_easytime' then
            TriggerEvent('cd_easytime:PauseSync', false)
        elseif Config.WeatherSync == 'qb-weathersync' then
            TriggerEvent('qb-weathersync:client:EnableSync')
        elseif Config.WeatherSync == 'vSync' then
            TriggerEvent('vSync:toggle', true)
            Wait(100)
            TriggerServerEvent('vSync:requestSync')
        end
    end
end)

RegisterNetEvent('vms_spawnselector:openLoaded')
AddEventHandler('vms_spawnselector:openLoaded', function(isFirstSpawn, allHouses, myHouses)
    spawnsList = {}
    local housesList = allHouses
    local myHousesList = myHouses
    if housesList and myHousesList then
        if GetResourceState('esx_property') == 'started' then
            if myHousesList[1] then
                for k, v in pairs(myHousesList) do
                    spawnsList[#spawnsList+1] = {
                        camCoords = vec(v.coords.x-20.0, v.coords.y+20.0, v.coords.z + 30.0),
                        spawnCoords = vec(v.coords.x, v.coords.y, v.coords.z),
                        label = Config.Translate['house_label'],
                        address = v.label
                    }
                end
            end
        elseif GetResourceState('qs-housing') == 'started' or GetResourceState('qb-houses') == 'started' then
            for k, v in pairs(myHousesList) do
                if housesList[v.house] then
                    spawnsList[#spawnsList+1] = {
                        camCoords = vec(housesList[v.house].coords.x-20.0, housesList[v.house].coords.y+20.0, housesList[v.house].coords.z + 30.0),
                        spawnCoords = housesList[v.house].coords,
                        label = Config.Translate['house_label'],
                        address = housesList[v.house].label
                    }
                end
            end
        elseif GetResourceState('ps-housing') == 'started' then
            for k, v in pairs(myHousesList) do
                local coords = json.decode(v.door_data)
                if coords and coords.x then
                    spawnsList[#spawnsList+1] = {
                        camCoords = vec(coords.x-20.0, coords.y+20.0, coords.z + 30.0),
                        spawnCoords = vec(coords.x, coords.y, coords.z),
                        label = Config.Translate['house_label'],
                        address = v.street
                    }
                end
            end
        elseif GetResourceState('bcs_housing') == 'started' then
            for k, v in pairs(myHousesList) do
                spawnsList[#spawnsList+1] = {
                    camCoords = vec(v.entry.x - 20.0, v.entry.y + 20.0, v.entry.z + 30.0),
                    spawnCoords = vec(v.entry.x, v.entry.y, v.entry.z),
                    label = Config.Translate['house_label'],
                    address = v.name
                }
            end
        end
    end

    local PlayerData = Config.Core == "ESX" and ESX.GetPlayerData() or Config.Core == "QB-Core" and QBCore.Functions.GetPlayerData()
    if PlayerData.job and PlayerData.job.name then
        if Config.OnlyJobsSpawns[PlayerData.job.name] then
            for k, v in pairs(Config.OnlyJobsSpawns[PlayerData.job.name]) do
                spawnsList[#spawnsList+1] = {
                    camCoords = v.camCoords,
                    spawnCoords = v.spawnCoords,
                    label = v.label,
                    address = v.address
                }
            end
        end
    end

    for k, v in pairs(Config.Spawns) do
        spawnsList[#spawnsList+1] = {
            camCoords = v.camCoords,
            spawnCoords = v.spawnCoords,
            label = v.label,
            address = v.address
        }
    end

    OpenSpawnSelector(isFirstSpawn)
end)