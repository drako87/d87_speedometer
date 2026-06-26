-- Validamos que el recurso use ox_lib y que la URL esté configurada
CreateThread(function()
    Wait(1000) -- Pausa de cortesía para asegurar la carga completa de la consola
    
    if Config.GitHubRepo and Config.GitHubRepo ~= 'https://github.com' then
        -- Extraemos el usuario y el nombre del repositorio de la URL
        local user, repo = Config.GitHubRepo:match("github%.com/([^/]+)/([^/]+)")
        
        if user and repo then
            -- Usamos el comprobador de versiones nativo y optimizado de ox_lib
            lib.versionCheck({
                user = user,
                repo = repo,
                currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
            })
        else
            print('^1[d87-speedometer] ERROR: El formato de la URL de GitHub en el config.lua es incorrecto.^7')
        end
    else
        print('^3[d87-speedometer] Alerta: Config.GitHubRepo no configurado. Comprobación de versión omitida.^7')
    end
end)
