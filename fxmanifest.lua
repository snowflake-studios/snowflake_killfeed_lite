fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snowflake Studios'
description 'Snowflake Killfeed Lite - Free Edition'
version '1.0.3'

-- Dependencies
dependencies {
    'ox_lib',
    'baseevents'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
