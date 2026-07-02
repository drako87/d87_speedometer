--[[
    main.lua
    Bucle principal: telemetría, control de crucero, adaptación de tipo,
    odómetro, salud del motor con multiplicador de daño y eyección por
    choque sin cinturón.

    NOTA DE OPTIMIZACIÓN: este hilo fusiona lo que antes eran DOS hilos
    separados (uno en client.lua y otro en features.lua) que consultaban
    el mismo vehículo cada 100ms de forma independiente (IsPedInAnyVehicle,
    GetVehiclePedIsIn, GetPedInVehicleSeat, GetVehicleEngineHealth
    duplicados). Fusionarlos reduce las llamadas nativas a la mitad y
    elimina una condición de carrera: antes el hilo de daño podía ajustar
    la salud del motor un frame después de que el HUD ya la hubiera
    pintado, provocando parpadeos en la barra de motor.
]]

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) and not IsPauseMenuActive() then
            sleep = 100
            local veh = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(veh, -1) == ped then

                -- 🔧 SALUD DEL MOTOR + MULTIPLICADOR DE DAÑO (leída una sola vez por frame)
                local rawEngineHealth = GetVehicleEngineHealth(veh)
                if lastEngineHealth and rawEngineHealth < 1000.0 then
                    local damageDone = lastEngineHealth - rawEngineHealth
                    if damageDone > 0 then
                        local adjustedHealth = lastEngineHealth - (damageDone * (Config.VehicleDamageMultiplier or 1.0))
                        SetVehicleEngineHealth(veh, adjustedHealth)
                        rawEngineHealth = adjustedHealth
                    end
                end
                lastEngineHealth = rawEngineHealth

                local enginePct = math.floor((rawEngineHealth / 1000) * 100)
                if enginePct < 0 then enginePct = 0 elseif enginePct > 100 then enginePct = 100 end

                -- 🛠️ SOLUCIÓN AL BUCLE DE ENCENDIDO/PARPADEO: Sincronización estricta de estados
                if enginePct > 15 then
                    if lastEngineState ~= engineStatus then
                        SetVehicleEngineOn(veh, engineStatus, true, true)
                        SetVehicleUndriveable(veh, not engineStatus)
                        lastEngineState = engineStatus
                    end
                else
                    if lastEngineState ~= false then
                        SetVehicleUndriveable(veh, true)
                        lastEngineState = false
                    end
                end

                -- ADAPTACIÓN DEL TIPO DE VEHÍCULO
                local class = GetVehicleClass(veh)
                local vehType = "car"
                if class == 8 then vehType = "bike"
                elseif class == 14 then vehType = "boat"
                elseif class == 15 then vehType = "heli"
                elseif class == 16 then vehType = "plane" end

                -- CÁLCULO DEL CUENTAKILÓMETROS (ODÓMETRO)
                local currentCoords = GetEntityCoords(veh)
                if lastVehicleCoords then
                    local dist = #(currentCoords - lastVehicleCoords)
                    if dist > 0.0 and dist < 100.0 then
                        local conversion = Config.UseMPH and 0.000621371 or 0.001
                        local currentOdo = Entity(veh).state.odometer or 0.0
                        Entity(veh).state:set('odometer', currentOdo + (dist * conversion), true)
                    end
                end
                lastVehicleCoords = currentCoords

                local totalOdometer = math.floor(Entity(veh).state.odometer or 0.0)

                -- Conversión de velocidades dinámicas
                local speedMultiplier = Config.UseMPH and 2.236936 or 3.6
                local speedUnit = Config.UseMPH and "MPH" or "KM/H"
                local speedHUD = math.floor(GetEntitySpeed(veh) * speedMultiplier)

                -- Control de Crucero Activo
                if cruiseStatus and vehType ~= "plane" and vehType ~= "heli" and vehType ~= "boat" then
                    local currentSpeed = GetEntitySpeed(veh)
                    if IsControlPressed(0, 72) or (currentSpeed < (cruiseSpeed - 3.0)) then
                        cruiseStatus = false
                        SendNUIMessage({ action = "cruise", status = false })
                        lib.notify({title = 'Crucero', description = 'Control de crucero desactivado.', type = 'error'})
                    else
                        SetVehicleForwardSpeed(veh, cruiseSpeed)
                    end
                end

                -- 💥 EYECCIÓN POR CHOQUE SIN CINTURÓN (antes vivía en un hilo aparte de features.lua)
                currentVelocity = GetEntityVelocity(veh)
                if speedHUD >= (Config.MinSpeedEject or 60.0) then
                    local lastSpeed = #lastVelocity
                    local curSpeed = #currentVelocity
                    local diff = lastSpeed - curSpeed

                    if not seatbeltStatus and diff > (lastSpeed * 0.3) then
                        local coords = GetEntityCoords(ped)
                        local fwVector = GetEntityForwardVector(veh)

                        SetEntityCoords(ped, coords.x + fwVector.x * 1.5, coords.y + fwVector.y * 1.5, coords.z + 0.5, true, true, true, false)
                        SetEntityVelocity(ped, lastVelocity.x * 1.2, lastVelocity.y * 1.2, lastVelocity.z * 1.2)

                        Wait(100)
                        SetPedToRagdoll(ped, 5000, 5000, 0, true, true, false)
                        ApplyDamageToPed(ped, math.random(30, 65), false)

                        seatbeltStatus = false
                        SendNUIMessage({ action = "seatbelt", status = false })
                    end
                end
                lastVelocity = currentVelocity

                local rpm = 0
                -- Si el juego reporta que el motor está realmente apagado (por un script de llaves), forzamos rpm a 0
                if GetIsVehicleEngineRunning(veh) and engineStatus and enginePct > 15 then
                    rpm = math.floor(GetVehicleCurrentRpm(veh) * 100)
                else
                    rpm = 0
                end

                local gear = GetVehicleCurrentGear(veh)
                local gearStr = tostring(gear)
                if gear == 0 then gearStr = "R" end

                local fuel = GetVehicleFuel(veh)

                local _, lightsOn, highBeamsOn = GetVehicleLightsState(veh)
                local lightStatus = "off"
                if highBeamsOn == 1 then lightStatus = "high" elseif lightsOn == 1 then lightStatus = "normal" end

                -- Definición nativa del nombre del modelo para evitar caídas de HUD
                local modelName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
                if modelName == "NULL" then modelName = GetDisplayNameFromVehicleModel(GetEntityModel(veh)) end

                -- Ajuste nativo para que el estado de cierre sea estable en motos
                local isLocked = GetVehicleDoorLockStatus(veh) == 2 or GetVehicleDoorsLockedForPlayer(veh, ped)

                if not isHudVisible then
                    isHudVisible = true
                    SendNUIMessage({
                        action = "show",
                        size = Config.Size or 1.0,
                        bottom = Config.BottomMargin or 40,
                        right = Config.RightMargin or 40,
                        showName = Config.ShowVehicleName,
                        showRpm = Config.ShowRpmBar,
                        showFuel = Config.ShowFuelBar,
                        showEngine = Config.ShowEngineBar,
                        showGear = Config.ShowGearBox,
                        vehicleName = modelName,
                        hideSeatbelt = false, -- Control reactivo en el ui.js
                        fuelLimit = Config.FuelAlertPercent,
                        engineLimit = Config.EngineAlertPercent
                    })
                    SendNUIMessage({ action = "seatbelt", status = seatbeltStatus })
                    SendNUIMessage({ action = "cruise", status = cruiseStatus })
                end

                SendNUIMessage({
                    action = "update",
                    speed = speedHUD,
                    gear = gearStr,
                    unit = speedUnit,
                    rpm = rpm,
                    fuel = fuel,
                    engine = enginePct,
                    locked = isLocked,
                    lights = lightStatus,
                    radar = activeRadar,
                    radarSpeed = activeRadarSpeed,
                    vehType = vehType,
                    odo = totalOdometer
                })
            else
                if isHudVisible then ResetHudStates() end
            end
        else
            if isHudVisible then ResetHudStates() end
            engineStatus = true
            lastVehicleCoords = nil
            lastEngineState = nil
            lastEngineHealth = nil
            sleep = 1000
        end
        Wait(sleep)
    end
end)

function ResetHudStates()
    isHudVisible = false
    seatbeltStatus = false
    cruiseStatus = false
    lastEngineState = nil
    SendNUIMessage({ action = "hide" })
end
