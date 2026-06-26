local CurrentFramework = nil
local inVehicle = false
local seatbeltOn = false
local isBike = false
local cruiseOn = false
local cruiseSpeed = 0.0

-- Variables internas para la mitigación del daño del motor
local lastVehicle = 0
local lastEngineHealth = 1000.0

-- Función interna para detectar de forma automática el Framework activo
local function DetectFramework()
    if Config.Framework ~= 'auto' then
        CurrentFramework = Config.Framework
        return
    end

    if GetResourceState('qbx_core') == 'started' then
        CurrentFramework = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        CurrentFramework = 'qb-core'
    elseif GetResourceState('es_extended') == 'started' then
        CurrentFramework = 'esx'
    else
        CurrentFramework = 'standalone'
    end
end

-- Inicialización al cargar el recurso
CreateThread(function()
    DetectFramework()
    print('^2[d87-speedometer]^7 Inicializado con éxito.')
    print(('^2[d87-speedometer]^7 Framework activo detectado: ^5%s^7'):format(CurrentFramework))
end)

-- Teclado para el cinturón
RegisterCommand('toggle_seatbelt', function()
    if inVehicle and not isBike then
        seatbeltOn = not seatbeltOn
        SendNUIMessage({ action = "seatbelt", status = seatbeltOn })
    end
end, false)
RegisterKeyMapping('toggle_seatbelt', 'Poner/Quitar Cinturón', 'keyboard', Config.SeatbeltKey)

-- Teclado para el Control de Crucero
RegisterCommand('toggle_cruise', function()
    if inVehicle and not isBike then
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            local currentSpeed = GetEntitySpeed(vehicle)
            if currentSpeed * 3.6 > 20 then
                cruiseOn = not cruiseOn
                if cruiseOn then
                    cruiseSpeed = currentSpeed
                    SetVehicleMaxSpeed(vehicle, cruiseSpeed)
                else
                    SetVehicleMaxSpeed(vehicle, 0.0)
                end
                SendNUIMessage({ action = "cruise", status = cruiseOn })
            end
        end
    end
end, false)
RegisterKeyMapping('toggle_cruise', 'Alternar Control de Crucero', 'keyboard', Config.CruiseKey)

-- Hilo de telemetría e interacciones cruzadas
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and IsPedInAnyVehicle(ped, false) then
            local isDriver = (GetPedInVehicleSeat(vehicle, -1) == ped)

            if not inVehicle then
                inVehicle = true
                local vehClass = GetVehicleClass(vehicle)
                isBike = (vehClass == 8 or vehClass == 13 or vehClass == 3 or vehClass == 11)
                
                local hash = GetEntityModel(vehicle)
                local modelName = GetDisplayNameFromVehicleModel(hash)
                local vehicleLabel = GetLabelText(modelName)
                if vehicleLabel == "NULL" then vehicleLabel = modelName end

                SendNUIMessage({ 
                    action = "show",
                    hideSeatbelt = isBike,
                    vehicleName = vehicleLabel,
                    size = Config.Size,
                    bottom = Config.BottomMargin,
                    right = Config.RightMargin,
                    showName = Config.ShowVehicleName,
                    showRpm = Config.ShowRpmBar,
                    showFuel = Config.ShowFuelBar,
                    showEngine = Config.ShowEngineBar,
                    showGear = Config.ShowGearBox,
                    fuelLimit = Config.FuelAlertPercent,
                    engineLimit = Config.EngineAlertPercent
                })

                -- Capturar salud inicial al entrar al coche
                lastVehicle = vehicle
                lastEngineHealth = GetVehicleEngineHealth(vehicle)
            end
            
            sleep = 100 

            -- 🛡️ MITIGADOR DE COLISIONES BASADO EN EL CONFIG.LUA
            local currentEngineHealth = GetVehicleEngineHealth(vehicle)
            if isDriver and currentEngineHealth < lastEngineHealth then
                local damageTaken = lastEngineHealth - currentEngineHealth
                if damageTaken > 1.0 and currentEngineHealth > 0.0 then
                    -- Multiplicamos el daño por el valor configurado por el usuario
                    local mitigatedHealth = lastEngineHealth - (damageTaken * Config.VehicleDamageMultiplier)
                    SetVehicleEngineHealth(vehicle, mitigatedHealth)
                    currentEngineHealth = mitigatedHealth
                end
            end
            lastEngineHealth = currentEngineHealth

            -- 1. Velocidad y Marchas Universales
            local speedMultiplier = Config.UseMPH and 2.236936 or 3.6
            local speedUnit = Config.UseMPH and "MPH" or "KM/H"
            local speed = math.floor(GetEntitySpeed(vehicle) * speedMultiplier)
            
            local gear = GetVehicleCurrentGear(vehicle)
            if gear == 0 and speed > 0 then gear = "R" end
            if gear == 0 and speed == 0 then gear = "N" end
            local rpmPct = math.floor((GetVehicleCurrentRpm(vehicle) or 0.0) * 100)

            if cruiseOn and IsControlPressed(0, 72) then
                cruiseOn = false
                SetVehicleMaxSpeed(vehicle, 0.0)
                SendNUIMessage({ action = "cruise", status = false })
            end

            -- 2. Luces
            local _, lightsOn, highBeamsOn = GetVehicleLightsState(vehicle)
            local lightState = "off"
            if highBeamsOn == 1 then lightState = "high" elseif lightsOn == 1 then lightState = "normal" end

            -- 3. Radares Fijos
            local nearRadar = false
            local radarMaxSpeed = 0
            
            if Config.EnableRadars then
                local coords = GetEntityCoords(ped)
                for _, radar in ipairs(Config.Radars) do
                    if #(coords - radar.coords) <= Config.RadarDistance then
                        nearRadar = true
                        radarMaxSpeed = radar.maxSpeed
                        break
                    end
                end
            end

            -- 4. Sistema Multicapa de Gasolina (Línea 164 CORREGIDA sin 'blanks')
            local fuel = 0
            if Config.FuelSystem == 'bazufix-fuel' or (Config.FuelSystem == 'auto' and GetResourceState('bazufix-fuel') == 'started') then
                fuel = exports['bazufix-fuel']:GetFuel(vehicle) or 0
            elseif Config.FuelSystem == 'ox_fuel' or (Config.FuelSystem == 'auto' and GetResourceState('ox_fuel') == 'started') then
                fuel = exports['ox_fuel']:GetFuel(vehicle) or 0
            elseif Config.FuelSystem == 'legacyfuel' or (Config.FuelSystem == 'auto' and GetResourceState('LegacyFuel') == 'started') then
                fuel = exports['LegacyFuel']:GetFuel(vehicle) or 0
            elseif Config.FuelSystem == 'qb-fuel' or (Config.FuelSystem == 'auto' and GetResourceState('qb-fuel') == 'started') then
                fuel = exports['qb-fuel']:GetFuel(vehicle) or 0
            else
                fuel = GetVehicleFuelLevel(vehicle) or 100
            end
            fuel = math.floor(fuel)

            -- 5. Daño de Motor en Porcentaje
            local enginePct = math.floor((currentEngineHealth / 1000) * 100)

            -- 6. Cierre Centralizado
            local isLocked = false
            if CurrentFramework == 'qbox' or CurrentFramework == 'qb-core' then
                local lockStatus = GetVehicleDoorLockStatus(vehicle)
                isLocked = (lockStatus == 2 or lockStatus == 4 or lockStatus == 10)
            elseif CurrentFramework == 'esx' then
                local lockStatus = GetVehicleDoorLockStatus(vehicle)
                isLocked = (lockStatus == 2)
            else
                local lockStatus = GetVehicleDoorLockStatus(vehicle)
                isLocked = (lockStatus == 2 or lockStatus == 4)
            end

            SendNUIMessage({
                action = "update",
                speed = speed,
                gear = gear,
                fuel = fuel,
                engine = enginePct,
                locked = isLocked,
                rpm = rpmPct,
                unit = speedUnit,
                lights = lightState,
                radar = nearRadar,
                radarSpeed = radarMaxSpeed
            })
        else
            if inVehicle then
                inVehicle = false
                seatbeltOn = false
                isBike = false
                cruiseOn = false
                lastVehicle = 0
                lastEngineHealth = 1000.0
                SendNUIMessage({ action = "hide" })
                SendNUIMessage({ action = "seatbelt", status = false })
                SendNUIMessage({ action = "cruise", status = false })
            end
        end
        Wait(sleep)
    end
end)
