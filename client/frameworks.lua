CurrentFramework = nil

-- Detección automática de Frameworks principales
CreateThread(function()
    if Config.Framework == 'auto' then
        if GetResourceState('qbox') == 'started' then
            CurrentFramework = 'qbox'
        elseif GetResourceState('qb-core') == 'started' then
            CurrentFramework = 'qb-core'
        elseif GetResourceState('es_extended') == 'started' then
            CurrentFramework = 'esx'
        end
    else
        CurrentFramework = Config.Framework
    end
end)

-- Función global y unificada para obtener la gasolina del coche
function GetVehicleFuel(vehicle)
    if not DoesEntityExist(vehicle) then return 100 end

    local system = Config.FuelSystem
    if system == 'auto' then
        if GetResourceState('ox_fuel') == 'started' then system = 'ox_fuel'
        elseif GetResourceState('bazufix-fuel') == 'started' then system = 'bazufix-fuel'
        elseif GetResourceState('legacyfuel') == 'started' then system = 'legacyfuel'
        elseif GetResourceState('qb-fuel') == 'started' then system = 'qb-fuel'
        else system = 'native' end
    end

    if system == 'ox_fuel' then
        return math.floor(Entity(vehicle).state.fuel or 100)
    elseif system == 'bazufix-fuel' then
        -- Lectura directa de bazufix-fuel v2
        local success, result = pcall(function() return exports['bazufix-fuel']:GetFuel(vehicle) end)
        return (success and result) and math.floor(result) or math.floor(GetVehicleFuelLevel(vehicle))
    elseif system == 'legacyfuel' then
        local success, result = pcall(function() return exports['LegacyFuel']:GetFuel(vehicle) end)
        return (success and result) and math.floor(result) or math.floor(GetVehicleFuelLevel(vehicle))
    elseif system == 'qb-fuel' then
        local success, result = pcall(function() return exports['qb-fuel']:GetFuel(vehicle) end)
        return (success and result) and math.floor(result) or math.floor(GetVehicleFuelLevel(vehicle))
    else
        return math.floor(GetVehicleFuelLevel(vehicle) or 100)
    end
end

-- 🛡️ SOLUCIÓN EXCLUSIVA PARA QBOX + QBX_GARAGES + BAZUFIX-FUEL
-- Escuchamos el evento exacto en el que qbx_garages solicita las propiedades para meter el coche al garaje
RegisterNetEvent('qbx_garages:client:storeVehicle', function(vehNetId)
    if not CurrentFramework or CurrentFramework ~= 'qbox' then return end

    -- Esperamos un mini-frame para asegurar estabilidad en la red
    Wait(0)

    if NetworkDoesNetworkIdExist(vehNetId) then
        local vehicle = NetToVeh(vehNetId)
        if DoesEntityExist(vehicle) then
            -- Obtenemos los litros exactos que reporta bazufix en este instante
            local currentFuel = GetVehicleFuel(vehicle)

            -- Sincronizamos de forma forzada el tanque físico de GTA V milisegundos antes
            -- de que qbx_garages ejecute su guardado SQL
            SetVehicleFuelLevel(vehicle, currentFuel + 0.0)
        end
    end
end)
