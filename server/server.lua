local alreadySelectedSpawn = {}

if Config.Core == "ESX" then
    ESX = Config.CoreExport()

    ESX.RegisterServerCallback('vms_spawnselector:getLastPosition', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        local result = MySQL.query.await('SELECT position FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier})
        if result[1] then
            cb(json.decode(result[1].position))
        else
            cb(nil)
        end
    end)

    ESX.RegisterServerCallback('vms_spawnselector:getDeadStatus', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        local result = MySQL.query.await('SELECT is_dead FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier})
        if result[1] then
            cb(result[1].is_dead)
        else
            cb(nil)
        end
    end)
elseif Config.Core == "QB-Core" then
    QBCore = Config.CoreExport()

end

RegisterNetEvent("vms_spawnselector:loadSpawnPoints")
AddEventHandler("vms_spawnselector:loadSpawnPoints", function(isFirstSpawn)
    local src = source
    local xPlayer = SV.getPlayer(src)
    local myIdentifier = SV.getIdentifier(xPlayer)
    local isInPrison = false
    if Config.UseOnlyFirstJoinSelect and alreadySelectedSpawn[myIdentifier] then
        TriggerClientEvent('vms_spawnselector:loadLastPosition', src)
        return
    end
    if Config.CheckJail and not isFirstSpawn then
        SV.getJailStatus(src, function(inPrison)
            if inPrison then
                isInPrison = true
                if Config.IsJailedTeleportOnCoords then
                    TriggerClientEvent('vms_spawnselector:loadJailPosition', src)
                else
                    TriggerClientEvent('vms_spawnselector:loadLastPosition', src)
                end
            end
        end)
    end
    if not isInPrison then
        if Config.UseHousingSpawns then
            SV.getHousings(src, function(allHouses, myHouses)
                if allHouses and myHouses then
                    TriggerClientEvent('vms_spawnselector:openLoaded', src, isFirstSpawn, allHouses, myHouses)
                else
                    TriggerClientEvent('vms_spawnselector:openLoaded', src, isFirstSpawn)
                end
            end)
        else
            TriggerClientEvent('vms_spawnselector:openLoaded', src, isFirstSpawn)
        end
    end
    alreadySelectedSpawn[myIdentifier] = true
end)