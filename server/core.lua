QBCore = nil

CreateThread(function()
    while (QBCore == nil) do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Wait(100)
    end
end)

RegisterServerEvent('qb-customs:removeCash')
AddEventHandler('qb-customs:removeCash', function(amount)
    local src = source
    removePlayerCashMoney(src, amount)
end)

function IsVehicleOwned(plate)
    local retval = false
    QBCore.Functions.ExecuteSql(true, {['a']=plate}, "SELECT * FROM `player_vehicles` WHERE `plate` = @a", function(result)
        if result[1] ~= nil then
            retval = true
        end
    end)
    return retval
end

RegisterServerEvent('qb-customs:server:SaveVehicleProps')
AddEventHandler('qb-customs:server:SaveVehicleProps', function(vehicleProps)
    local src = source
    if IsVehicleOwned(vehicleProps.plate) then
        QBCore.Functions.ExecuteSql(false, {['a']=json.encode(vehicleProps),['b']=vehicleProps.plate}, "UPDATE `player_vehicles` SET `mods` = @a WHERE `plate` = @b")
    else
        TriggerClientEvent('QBCore:Notify', src, 'No Owner - Mods Not Saved', 'error')
    end
end)
