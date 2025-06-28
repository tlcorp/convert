spawnsList = {}
local currectSpawnPoint = nil
local lastSpawnPoint = nil
local cam, cameraOffset = nil, nil

local firstSpawn = false

if Config.Core == "ESX" then
    ESX = Config.CoreExport()
elseif Config.Core == "QB-Core" then
    QBCore = Config.CoreExport()
end

RegisterNUICallback("change", function(data)
    if cam and data.direction then
        lastSpawnPoint = currectSpawnPoint
        if data.direction == "left" then
            currectSpawnPoint = currectSpawnPoint - 1
            if not spawnsList[currectSpawnPoint] then
                currectSpawnPoint = #spawnsList
            end
        elseif data.direction == "right" then
            currectSpawnPoint = currectSpawnPoint + 1
            if not spawnsList[currectSpawnPoint] then
                currectSpawnPoint = 1
            end
        end
        DoScreenFadeOut(250)
        while not IsScreenFadedOut() do
            Citizen.Wait(5)
        end
        SetEntityCoords(PlayerPedId(), spawnsList[currectSpawnPoint].spawnCoords.x, spawnsList[currectSpawnPoint].spawnCoords.y, spawnsList[currectSpawnPoint].spawnCoords.z+5.0)
        SetCamCoord(cam, spawnsList[currectSpawnPoint].camCoords.x, spawnsList[currectSpawnPoint].camCoords.y, spawnsList[currectSpawnPoint].camCoords.z)
        PointCamAtCoord(cam, spawnsList[currectSpawnPoint].spawnCoords.x, spawnsList[currectSpawnPoint].spawnCoords.y, spawnsList[currectSpawnPoint].spawnCoords.z)
        Citizen.Wait(150)
        DoScreenFadeIn(250)
        SendNUIMessage({
            action = 'change',
            label = spawnsList[currectSpawnPoint].label,
            address = spawnsList[currectSpawnPoint].address
        })
    end
end)

RegisterNUICallback("select", function(data)
    SelectSpawn(data.isLastPosition)
end)

function OpenSpawnSelector(isFirstSpawn)
    firstSpawn = isFirstSpawn
    if not DoesCamExist(cam) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end
    TriggerEvent('vms_spawnselector:WeatherSync', true)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), false)
    currectSpawnPoint = 1
    lastSpawnPoint = currectSpawnPoint
    DoScreenFadeIn(250)
    SetEntityCoords(PlayerPedId(), spawnsList[1].spawnCoords.x, spawnsList[1].spawnCoords.y, spawnsList[1].spawnCoords.z)
    SetCamCoord(cam, spawnsList[1].camCoords.x, spawnsList[1].camCoords.y, spawnsList[1].camCoords.z)
    PointCamAtCoord(cam, spawnsList[1].spawnCoords.x, spawnsList[1].spawnCoords.y, spawnsList[1].spawnCoords.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    Config.Hud:Disable()
    SendNUIMessage({action = 'open', isFirstSpawn = isFirstSpawn})
    SendNUIMessage({
        action = 'change',
        label = spawnsList[currectSpawnPoint].label,
        address = spawnsList[currectSpawnPoint].address
    })
    SetNuiFocus(true, true)
end

function SelectSpawn(isLastPosition, isJailPosition)
    if isLastPosition then
        if Config.Core == "ESX" then
            ESX.TriggerServerCallback('vms_spawnselector:getLastPosition', function(spawnCoords)
                if spawnCoords then
                    SetCamCoord(cam, spawnCoords.x, spawnCoords.y, spawnCoords.z + 75.0)
                    PointCamAtCoord(cam, spawnCoords.x, spawnCoords.y, spawnCoords.z)
                    SetEntityCoords(PlayerPedId(), spawnCoords.x, spawnCoords.y, spawnCoords.z)
                    SetEntityHeading(PlayerPedId(), spawnCoords.w)
                    Citizen.Wait(150)
                    DestoryCams()
                    DoScreenFadeIn(250)
                end
            end)
        elseif Config.Core == "QB-Core" then
            QBCore.Functions.GetPlayerData(function(PlayerData)
                if PlayerData.position then
                    SetCamCoord(cam, PlayerData.position.x, PlayerData.position.y, PlayerData.position.z + 75.0)
                    PointCamAtCoord(cam, PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
                    SetEntityCoords(PlayerPedId(), PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
                    SetEntityHeading(PlayerPedId(), PlayerData.position.a)
                    Citizen.Wait(150)
                    DestoryCams()
                    DoScreenFadeIn(250)
                end
            end)
        end
    elseif isJailPosition and Config.IsJailedTeleportOnCoords.xyz then
        SetEntityCoords(PlayerPedId(), Config.IsJailedTeleportOnCoords.xyz)
        SetEntityHeading(PlayerPedId(), Config.IsJailedTeleportOnCoords.w)
        DestoryCams()
    else
        if Config.OnDeadOnlyLastPosition then
            if Config.Core == "ESX" then
                ESX.TriggerServerCallback('vms_spawnselector:getDeadStatus', function(isDead)
                    if isDead then
                        return Config.Notification(Config.Translate['cannot_spawn_on_dead'], 5000, 'error')
                    end
                    SetEntityCoords(PlayerPedId(), spawnsList[currectSpawnPoint].spawnCoords.x, spawnsList[currectSpawnPoint].spawnCoords.y, spawnsList[currectSpawnPoint].spawnCoords.z)
                    SetEntityHeading(PlayerPedId(), spawnsList[currectSpawnPoint].spawnCoords.w)
                    DestoryCams()
                end)
            elseif Config.Core == "QB-Core" then
                QBCore.Functions.GetPlayerData(function(PlayerData)
                    if PlayerData.metadata['isdead'] then
                        return Config.Notification(Config.Translate['cannot_spawn_on_dead'], 5000, 'error')
                    end
                    SetEntityCoords(PlayerPedId(), spawnsList[currectSpawnPoint].spawnCoords.x, spawnsList[currectSpawnPoint].spawnCoords.y, spawnsList[currectSpawnPoint].spawnCoords.z)
                    SetEntityHeading(PlayerPedId(), spawnsList[currectSpawnPoint].spawnCoords.w)
                    DestoryCams()
                end)
            end
        else
            SetEntityCoords(PlayerPedId(), spawnsList[currectSpawnPoint].spawnCoords.x, spawnsList[currectSpawnPoint].spawnCoords.y, spawnsList[currectSpawnPoint].spawnCoords.z)
            SetEntityHeading(PlayerPedId(), spawnsList[currectSpawnPoint].spawnCoords.w)
            DestoryCams()
        end
    end
end

function DestoryCams()
    SendNUIMessage({action = 'close'})
    Config.Hud:Enable()
    SetCamActive(cam, false)
    cam = nil
    RenderScriptCams(false, true, 2500, true, true)
    SetNuiFocus(false, false)
    SetEntityVisible(PlayerPedId(), true)
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerEvent('vms_spawnselector:WeatherSync', false)
    if Config.Core == "QB-Core" then
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    end
    onPlayerSpawned(firstSpawn)
    firstSpawn = false
end

RegisterNetEvent('vms_spawnselector:loadLastPosition')
AddEventHandler('vms_spawnselector:loadLastPosition', function()
    SelectSpawn(true)
end)

RegisterNetEvent('vms_spawnselector:loadJailPosition')
AddEventHandler('vms_spawnselector:loadJailPosition', function()
    SelectSpawn(false, true)
end)

RegisterNetEvent('vms_spawnselector:open')
AddEventHandler('vms_spawnselector:open', function(isFirstSpawn)
    TriggerServerEvent("vms_spawnselector:loadSpawnPoints", isFirstSpawn)
end)

RegisterNetEvent('vms_spawnselector:openSelector')
AddEventHandler('vms_spawnselector:openSelector', function(isFirstSpawn)
    TriggerServerEvent("vms_spawnselector:loadSpawnPoints", isFirstSpawn)
end)

exports('OpenSpawnSelector', function(isFirstSpawn)
    TriggerEvent('vms_spawnselector:open', isFirstSpawn)
end)