fx_version 'cerulean'
game 'gta5'

author 'Drako87/Dracatt'
description 'D87 Speedometer - Velocímetro minimalista premium multiframework con Checker de versiones'
version '1.0.0'

shared_script '@ox_lib/init.lua'

shared_script 'config.lua'

-- Orden de carga importante:
-- 1. state.lua      -> declara TODAS las variables globales compartidas antes de que nada las use
-- 2. frameworks.lua  -> detección de framework y combustible
-- 3. main.lua        -> bucle principal de telemetría/daño/eyección
-- 4. features.lua    -> radar, atajos de teclado, integración ox_target
client_scripts {
    'client/state.lua',
    'client/frameworks.lua',
    'client/main.lua',
    'client/features.lua'
}

server_script 'server/server.lua'
ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/ui.css',
    'html/ui.js'
}
