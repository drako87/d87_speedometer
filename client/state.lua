--[[
    state.lua
    Variables de estado compartidas entre todos los scripts cliente.
    Se centralizan aquí (y se cargan primero en fxmanifest.lua) para no
    depender del orden de carga de client.lua/features.lua para que
    existan antes de su primer uso.
]]

isHudVisible   = false
engineStatus   = true
cruiseStatus   = false
cruiseSpeed    = 0.0
seatbeltStatus = false
activeRadar    = false
activeRadarSpeed = 0

lastVehicleCoords = nil
lastEngineState   = nil
lastEngineHealth  = nil
lastVelocity    = vec3(0, 0, 0)
currentVelocity = vec3(0, 0, 0)
