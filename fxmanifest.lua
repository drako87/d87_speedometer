fx_version 'cerulean'
game 'gta5'

author 'Drako87/Dracatt'
description 'D87 Speedometer - Velocímetro minimalista premium multiframework con Checker de versiones'
version '1.0.0'

shared_script '@ox_lib/init.lua'

shared_script 'config.lua'

-- Cargamos primero la detección de frameworks y luego el resto de módulos
client_scripts {
    'frameworks.lua',
    'client.lua',
    'features.lua'
}

server_script 'server.lua'
ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/ui.css',
    'html/ui.js'
}
