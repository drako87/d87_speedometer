-- Bucle de seguridad extendido para esperar a que ox_lib cargue por completo en la red del servidor
CreateThread(function()
    -- Ampliamos el tiempo de espera controlado a 15 segundos (150 intentos de 100ms)
    local retries = 0
    while not lib and retries < 150 do
        Wait(100)
        retries = retries + 1
    end

    -- Si transcurrido el tiempo la librería ya está disponible en la memoria global
    if lib and lib.versionCheck then
        if Config.GitHubRepo and Config.GitHubRepo ~= 'https://github.com' then
            -- CORREGIDO: Expresión regular mejorada para admitir guiones, mayúsculas y barras finales en GitHub
            local user, repo = Config.GitHubRepo:match("github%.com/([%w%-]+)/([%w%-]+)")
            
            if user and repo then
                -- Ejecutamos el comprobador oficial de versiones en la nube
                lib.versionCheck({
                    user = user,
                    repo = repo,
                    currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
                })
            else
                print('^1[D87 Speedometer] ERROR: El formato de la URL de GitHub en el config.lua es incorrecto u omitido.^7')
            end
        end
    else
        -- Alerta informativa secundaria sin impacto negativo en el rendimiento
        print('^3[D87 Speedometer] Alerta de inicio: ox_lib no se detectó a tiempo tras 15s. Comprobación de versión en GitHub omitida para asegurar estabilidad.^7')
    end
end)
