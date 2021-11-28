local QBCore = exports['qb-core']:GetCoreObject()

local chicken = vehicleBaseRepairCost

RegisterNetEvent('qb-customs:attemptPurchase', function(type, upgradeLevel, model)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local balance = nil
    if Player.PlayerData.job.name == "mechanic" then
        balance = exports['qb-bossmenu']:GetAccount(Player.PlayerData.job.name)
    else
        balance = Player.Functions.GetMoney(moneyType)
    end

    for k,v in pairs(QBCore.Shared.Vehicles) do
        if model == v.hash then
            carPrice = v.price
        end
    end

    if type == "repair" then
        if balance >= chicken then
            if Player.PlayerData.job.name == "mechanic" then
                TriggerEvent('qb-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name, chicken)
            else
                Player.Functions.RemoveMoney(moneyType, chicken, "bennys")
            end
            TriggerClientEvent('qb-customs:purchaseSuccessful', source)
        else
            TriggerClientEvent('qb-customs:purchaseFailed', source)
        end
    elseif type == "performance" then
        if balance >= QBCore.Shared.Round((vehicleCustomisationPrices[type].prices[upgradeLevel] * carPrice) / 100, 0) then
            TriggerClientEvent('qb-customs:purchaseSuccessful', source)
            if Player.PlayerData.job.name == "mechanic" then
                TriggerEvent('qb-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name,
                    vehicleCustomisationPrices[type].prices[upgradeLevel])
            else
                Player.Functions.RemoveMoney(moneyType, QBCore.Shared.Round((vehicleCustomisationPrices[type].prices[upgradeLevel] * carPrice) / 100), "bennys")
            end
        else
            TriggerClientEvent('qb-customs:purchaseFailed', source)
        end
    else
        if balance >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('qb-customs:purchaseSuccessful', source)
            if Player.PlayerData.job.name == "mechanic" then
                TriggerEvent('qb-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name,
                    vehicleCustomisationPrices[type].price)
            else
                Player.Functions.RemoveMoney(moneyType, vehicleCustomisationPrices[type].price, "bennys")
            end
        else
            TriggerClientEvent('qb-customs:purchaseFailed', source)
        end
    end
end)

RegisterNetEvent('qb-customs:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterNetEvent("updateVehicle", function(myCar)
    local src = source
    if IsVehicleOwned(myCar.plate) then
        exports.oxmysql:execute('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(myCar), myCar.plate})
    end
end)

function IsVehicleOwned(plate)
    local retval = false
    local result = exports.oxmysql:scalarSync('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        retval = true
    end
    return retval
end
