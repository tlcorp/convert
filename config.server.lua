SV = {}

SV.getPlayer = function(src)
    if Config.Core == "ESX" then
        return ESX.GetPlayerFromId(src)
    elseif Config.Core == "QB-Core" then
        return QBCore.Functions.GetPlayer(src)
    end
end

SV.getIdentifier = function(xPlayer)
    if Config.Core == "ESX" then
        return xPlayer.identifier
    elseif Config.Core == "QB-Core" then
        return xPlayer.PlayerData.citizenid
    end
    return nil
end


SV.getJailStatus = function(source, cb)
    local source = source
    local xPlayer = SV.getPlayer(source)
    local myIdentifier = SV.getIdentifier(xPlayer)
    
    if GetResourceState('esx_jail') == 'started' then
        local myJail = MySQL.query.await('SELECT jail_time FROM users WHERE identifier = ?', {myIdentifier})
        if myJail[1] and myJail[1].jail_time >= 1 then
            TriggerEvent('esx_jail:sendToJail', xPlayer.source, myJail[1].jail_time, true)
            cb(true)
        else
            cb(false)
        end
        
    elseif GetResourceState('esx-qalle-jail') == 'started' then
        local myJail = MySQL.query.await('SELECT jail FROM users WHERE identifier = ?', {myIdentifier})
        if myJail[1] and myJail[1].jail >= 1 then
            cb(true)
        else
            cb(false)
        end
        
    elseif GetResourceState('mx_jail') == 'started' then
        local myJail = MySQL.query.await('SELECT jail_time FROM users WHERE identifier = ?', {myIdentifier})
        if myJail[1] and myJail[1].jail_time ~= 0 then
            cb(true)
        else
            cb(false)
        end
        
    elseif GetResourceState('qb-prison') == 'started' then
        if xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.metadata.injail and xPlayer.PlayerData.metadata.injail >= 1 then
            cb(true)
        else
            cb(false)
        end

    elseif GetResourceState('pickle_prisons') == 'started' then
        local myJail = MySQL.query.await('SELECT * FROM pickle_prisons WHERE identifier = ?', {myIdentifier})
        if myJail then
            cb(true)
        else
            cb(false)
        end

    elseif GetResourceState('rcore_prison') == 'started' then
        local state, statusCode = exports.rcore_prison:IsPrisoner(source)
        if state then
            cb(true)
        else
            cb(false)
        end
        
    else
        cb(false)

    end
end

SV.getHousings = function(source, cb)
    local xPlayer = SV.getPlayer(source)
    local myIdentifier = SV.getIdentifier(xPlayer)

    if GetResourceState('esx_property') == 'started' then
        local propertiesList = LoadResourceFile('esx_property', 'properties.json')
        if propertiesList then
            local allHouses = json.decode(propertiesList)
            local myHouses = {}
            for k, v in pairs(allHouses) do
                if v.Owner == myIdentifier then
                    myHouses[#myHouses + 1] = {
                        label = v.Name,
                        coords = v.Entrance
                    }
                end
            end
            if myHouses[1] then
                cb(true, myHouses)
            else
                cb(nil)
            end
        end
    elseif GetResourceState('qs-housing') == 'started' then
        local allHouses = MySQL.query.await('SELECT * FROM houselocations')
        if allHouses[1] then
            local listedHouses = {}
            for k, v in pairs(allHouses) do
                listedHouses[v.name] = {
                    label = v.label,
                    coords = json.decode(v.coords).enter
                }
            end
            local myHouses = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?', {myIdentifier})
            if myHouses and myHouses[1] ~= nil then
                cb(listedHouses, myHouses)
            else
                cb(nil)
            end
        else
            cb(nil)
        end
    elseif GetResourceState('qb-houses') == 'started' then
        local allHouses = MySQL.query.await('SELECT * FROM houselocations')
        if allHouses[1] then
            local listedHouses = {}
            for k, v in pairs(allHouses) do
                listedHouses[v.name] = {
                    label = v.label,
                    coords = json.decode(v.coords).enter
                }
            end
            local myHouses = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?', {myIdentifier})
            if myHouses and myHouses[1] ~= nil then
                cb(listedHouses, myHouses)
            else
                cb(nil)
            end
        else
            cb(nil)
        end
    elseif GetResourceState('ps-housing') == 'started' then
        local myHouses = MySQL.query.await('SELECT * FROM properties WHERE owner_citizenid = ?', {myIdentifier})
        if myHouses and myHouses[1] ~= nil then
            cb(true, myHouses)
        else
            cb(nil)
        end
    elseif GetResourceState('bcs_housing') == 'started' then
        local myHouses = exports['bcs_housing']:GetOwnedHomes(myIdentifier)
        if myHouses and myHouses[1] ~= nil then
            cb(true, myHouses)
        else
            cb(nil)
        end
    else
        cb(false, false)
    end
end