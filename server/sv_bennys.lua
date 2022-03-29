-----------------------
----   Variables   ----
-----------------------
local QBCore = exports['qb-core']:GetCoreObject()
local RepairCosts = {}

-----------------------
----   Functions   ----
-----------------------

local function IsVehicleOwned(plate)
    local retval = false
    local result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then retval = true end
    return retval
end

-----------------------
----   Threads     ----
-----------------------

-----------------------
---- Server Events ----
-----------------------

AddEventHandler("playerDropped", function()
	local source = source
    RepairCosts[source] = nil
end)

RegisterNetEvent('qb-customs:server:attemptPurchase', function(type, upgradeLevel, vehiclePrice)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local moneyType = Config.MoneyType
    local balance = Player.Functions.GetMoney(moneyType)

    if type == "repair" then
        local repairCost = RepairCosts[source] or 600
        moneyType = Config.RepairMoneyType
        balance = Player.Functions.GetMoney(moneyType)
        if balance >= repairCost then
            Player.Functions.RemoveMoney(moneyType, repairCost, "bennys")
            TriggerClientEvent('qb-customs:client:purchaseSuccessful', source)
        else
            TriggerClientEvent('qb-customs:client:purchaseFailed', source)
        end
    elseif type == "performance" or type == "turbo" then
        if Config.UsePercentage then
            if balance >= math.floor((vehiclePrice / 100) * vehicleCustomisationPricesPercentage[type][upgradeLevel]) then
                TriggerClientEvent('qb-customs:client:purchaseSuccessful', source)
                Player.Functions.RemoveMoney(moneyType, math.floor((vehiclePrice / 100) * vehicleCustomisationPricesPercentage[type][upgradeLevel]), "bennys")
            else
                TriggerClientEvent('qb-customs:client:purchaseFailed', source)
            end
        else
            if balance >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
                TriggerClientEvent('qb-customs:client:purchaseSuccessful', source)
                Player.Functions.RemoveMoney(moneyType, vehicleCustomisationPrices[type].prices[upgradeLevel], "bennys")
            else
                TriggerClientEvent('qb-customs:client:purchaseFailed', source)
            end
        end
    else
        if Config.UsePercentage then
            if balance >= math.floor((vehiclePrice / 100) * vehicleCustomisationPricesPercentage[type]) then
                TriggerClientEvent('qb-customs:client:purchaseSuccessful', source)
                Player.Functions.RemoveMoney(moneyType, math.floor((vehiclePrice / 100) * vehicleCustomisationPricesPercentage[type]), "bennys")
            else
                TriggerClientEvent('qb-customs:client:purchaseFailed', source)
            end
        else
            if balance >= vehicleCustomisationPrices[type].price then
                TriggerClientEvent('qb-customs:client:purchaseSuccessful', source)
                Player.Functions.RemoveMoney(moneyType, vehicleCustomisationPrices[type].price, "bennys")
            else
                TriggerClientEvent('qb-customs:client:purchaseFailed', source)
            end
        end
    end
end)

RegisterNetEvent('qb-customs:server:updateRepairCost', function(cost)
    local source = source
    RepairCosts[source] = cost
end)

RegisterNetEvent("qb-customs:server:updateVehicle", function(myCar)
    if IsVehicleOwned(myCar.plate) then
        MySQL.Async.execute('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(myCar), myCar.plate})
    end
end)

-- Use somthing like this to dynamically enable/disable a location. Can be used to change anything at a location.
-- TriggerEvent('qb-customs:server:UpdateLocation', 'Hayes', 'settings', 'enabled', test)

RegisterNetEvent('qb-customs:server:UpdateLocation', function(location, type, key, value)
    Config.Locations[location][type][key] = value
    TriggerClientEvent('qb-customs:client:UpdateLocation', -1, location, type, key, value)
end)

QBCore.Functions.CreateCallback('qb-customs:server:GetLocations', function(source, cb)
	cb(Config.Locations)
end)