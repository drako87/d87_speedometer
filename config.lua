Config = {}

-- SELECCIÓN DE FRAMEWORK
Config.Framework = 'auto'  -- Opciones: 'auto' (detecta solo), 'qbox', 'qb-core', 'esx'
Config.GitHubRepo = 'https://github.com'

-- CONFIGURACIÓN DE POSICIÓN Y TAMAÑO VISUAL
Config.Size = 1.0          -- Escala general del HUD (1.0 = Original, 0.8 = Más pequeño, 1.2 = Más grande)
Config.BottomMargin = 40   -- Distancia desde el borde inferior de la pantalla (en píxeles)
Config.RightMargin = 40    -- Distancia desde el borde derecho de la pantalla (en píxeles)

-- CONFIGURACIÓN DE ELEMENTOS (True = Activado / False = Desactivado)
Config.ShowVehicleName = true -- Mostrar u ocultar el nombre del vehículo abajo
Config.ShowRpmBar = true      -- Mostrar u ocultar la barra de revoluciones (RPM)
Config.ShowFuelBar = true     -- Mostrar u ocultar la barra vertical de gasolina
Config.ShowEngineBar = true   -- Mostrar u ocultar la barra vertical de salud del motor
Config.ShowGearBox = true     -- Mostrar u ocultar el recuadro azul de las marchas

-- AJUSTES MECÁNICOS Y ALERTAS
Config.UseMPH = false             -- Cambiar a 'true' si prefieres Millas por Hora en lugar de KM/H
Config.SeatbeltKey = 'B'          -- Tecla para el cinturón
Config.CruiseKey = 'Y'            -- Tecla para activar/desactivar el Control de Crucero
Config.FuelAlertPercent = 20      -- Reserva de gasolina
Config.EngineAlertPercent = 30    -- Alerta de motor

-- CONFIGURACIÓN DE DURABILIDAD REAL DE VEHÍCULOS (NUEVO)
-- Regula el daño que recibe el motor al chocar de forma inmediata.
-- 1.0 = Daño normal | 0.5 = Aguantan el DOBLE | 0.3 = Aguantan el TRIPLE | 0.2 = Auténticos TANQUES (5 veces más duros)
Config.VehicleDamageMultiplier = 0.3 

-- CONFIGURACIÓN DE RADARES 
Config.EnableRadars = false        -- Cambiar a 'false' para desactivar por completo todos los radares del HUD
Config.RadarDistance = 80.0       -- Distancia en metros a la que el HUD empezará a avisar del radar
Config.Radars = {
    { coords = vec3(220.0, -815.0, 30.0), maxSpeed = 50 },  
    { coords = vec3(-250.0, -900.0, 30.0), maxSpeed = 80 }, 
    { coords = vec3(1000.0, 200.0, 50.0), maxSpeed = 120 }, 
}

-- COMPATIBILIDAD DE SCRIPTS EXTERNOS SEGÚN TU FRAMEWORK
Config.FuelSystem = 'auto'        -- Opciones: 'auto', 'bazufix-fuel', 'ox_fuel', 'legacyfuel', 'qb-fuel'
