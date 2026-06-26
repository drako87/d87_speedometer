fx_version 'cerulean'
game 'gta5'

author 'Drako87/Dracatt'
description 'D87 Speedometer - Velocímetro minimalista premium multiframework estilo ONX RP con Checker de versiones'
version '1.0.0'

-- Registramos los scripts compartidos, de cliente y el NUEVO de servidor
shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/ui.css',
    'html/ui.js'
}