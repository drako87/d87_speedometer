fx_version 'cerulean'
game 'gta5'

author 'Drako87/Dracatt'
description 'D87 Speedometer - Velocímetro minimalista premium multiframework con Checker de versiones'
version '1.0.0'

-- IMPORTANTE: Cargamos los scripts de inicialización de ox_lib para Cliente y Servidor
shared_script '@ox_lib/init.lua'

-- Registramos la estructura de scripts del recurso
shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/ui.css',
    'html/ui.js'
}
