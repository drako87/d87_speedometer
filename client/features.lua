--[[
    features.lua
    Radar fijo, atajos de teclado (motor/cinturón/crucero) e integración
    con ox_target para desvolcar vehículos.

    NOTA: el antiguo "detector de impactos y durabilidad del motor" que
    vivía aquí se fusionó dentro de client/main.lua para no duplicar,
    en un segundo hilo separado, las mismas consultas nativas del
    vehículo (ver comentario en main.lua).
]]

-- 📡 ESCÁNER ASÍNCRONO DE RADARES FIJOS
CreateThread(function()
    while true do
        local sleep = 1500
        local ped = PlayerPedId()

        if Config.EnableRadars and IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(veh, -1) == ped then
                sleep = 400
                local coords = GetEntityCoords(veh)
                local closeToRadar = false

                for _, radar in ipairs(Config.Radars) do
                    local dist = #(coords - radar.coords)
                    if dist <= (Config.RadarDistance or 80.0) then
                        closeToRadar = true
                        activeRadarSpeed = radar.maxSpeed
                        sleep = 150
                        break
                    end
                end

                if closeToRadar then
                    if not activeRadar then
                        activeRadar = true
                        PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
                    end
                else
                    activeRadar = false
                end
            else
                activeRadar = false
            end
        else
            activeRadar = false
            sleep = 2000
        end
        Wait(sleep)
    end
end)

-- MAPEO DE TECLAS (Motor, Cinturón y Crucero)
RegisterKeyMapping('toggleengine', 'Alternar Motor del Vehículo', 'KEYBOARD', Config.EngineKey or 'M')
RegisterCommand('toggleengine', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(veh, -1) == ped then
            if GetVehicleEngineHealth(veh) > 150 then
                engineStatus = not engineStatus
                if engineStatus then
                    SetVehicleEngineOn(veh, true, false, true)
                    SetVehicleUndriveable(veh, false)
                    lastEngineState = true -- EVITA EL BUCLE: Avisamos a main.lua que lo encendiste a propósito
                    lib.notify({title = 'Vehículo', description = 'Motor encendido.', type = 'success'})
                else
                    SetVehicleEngineOn(veh, false, false, true)
                    SetVehicleUndriveable(veh, true)
                    cruiseStatus = false
                    lastEngineState = false -- EVITA EL BUCLE: Avisamos a main.lua que lo apagaste a propósito
                    SendNUIMessage({ action = "cruise", status = false })
                    lib.notify({title = 'Vehículo', description = 'Motor apagado.', type = 'error'})
                end
            else
                lib.notify({title = 'Vehículo', description = 'El motor está dañado.', type = 'error'})
            end
        end
    end
end, false)

RegisterKeyMapping('toggleseatbelt', 'Poner/Quitar Cinturón de Seguridad', 'KEYBOARD', Config.SeatbeltKey or 'B')
RegisterCommand('toggleseatbelt', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(veh, -1) == ped then
            seatbeltStatus = not seatbeltStatus
            SendNUIMessage({ action = "seatbelt", status = seatbeltStatus })
            PlaySoundFrontend(-1, "BUTTON_AND_CLICK", "HUD_AWARDS", true)
            lib.notify({
                title = 'Cinturón',
                description = seatbeltStatus and 'Cinturón abrochado.' or 'Cinturón desabrochado.',
                type = seatbeltStatus and 'success' or 'error'
            })
        end
    end
end, false)

RegisterKeyMapping('togglecruise', 'Alternar Control de Crucero', 'KEYBOARD', Config.CruiseKey or 'Y')
RegisterCommand('togglecruise', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(veh, -1) == ped then
            local speed = GetEntitySpeed(veh)
            if speed * 3.6 >= 20.0 then
                cruiseStatus = not cruiseStatus
                if cruiseStatus then
                    cruiseSpeed = speed
                    SendNUIMessage({ action = "cruise", status = true })
                    lib.notify({title = 'Crucero', description = 'Control de crucero establecido.', type = 'success'})
                else
                    SendNUIMessage({ action = "cruise", status = false })
                    lib.notify({title = 'Crucero', description = 'Control de crucero quitado.', type = 'error'})
                end
            else
                lib.notify({title = 'Crucero', description = 'Vas demasiado lento.', type = 'error'})
            end
        end
    end
end, false)

-- INTEGRACIÓN CON OX_TARGET (DESVOLCAR)
CreateThread(function()
    Wait(1000)
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:addGlobalVehicle({
            {
                name = 'd87_speedometer:flip_vehicle',
                icon = 'fa-solid fa-car-burst',
                label = 'Desvolcar Vehículo',
                distance = Config.FlipDistance or 3.0,
                canInteract = function(entity, distance, coords, name, bone)
                    return not IsPedInAnyVehicle(PlayerPedId(), false) and IsEntityUpsidedown(entity)
                end,
                onSelect = function(data)
                    local veh = data.entity
                    if DoesEntityExist(veh) then
                        local ped = PlayerPedId()
                        TaskTurnPedToFaceEntity(ped, veh, 1000)
                        Wait(500)
                        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true)

                        if lib.progressBar({
                            duration = Config.FlipDuration or 4000,
                            label = 'Desvolcando...',
                            useVacuum = false,
                            disable = { move = true, car = true, combat = true }
                        }) then
                            ClearPedTasksImmediately(ped)
                            NetworkRequestControlOfEntity(veh)
                            local timeout = 0
                            while not NetworkHasControlOfEntity(veh) and timeout < 30 do Wait(10) timeout = timeout + 1 end
                            local pos = GetEntityCoords(veh)
                            SetEntityCoords(veh, pos.x, pos.y, pos.z + 0.5, true, false, false, true)
                            SetVehicleOnGroundProperly(veh)
                            lib.notify({title = 'Asistencia', description = 'Vehículo desvolcado con éxito.', type = 'success'})
                        else
                            ClearPedTasksImmediately(ped)
                            lib.notify({title = 'Asistencia', description = 'Acción cancelada.', type = 'error'})
                        end
                    end
                end
            }
        })
    end
end)
