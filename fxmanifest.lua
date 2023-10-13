fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game        'gta5'

shared_scripts{
    '@ox_lib/init.lua',
    'loaders/*.lua',
    'module.render.lua',
    'index.lua',
    'imports/main.lua'
}

client_scripts{
    'resources/**/client/*.lua',
    'resources/**/client.lua'
}

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'resources/**/server/*.lua',
    'resources/**/server.lua'
}

ui_page 'web/dist/index.html'

files{
    'data/*.lua',
    
    'web/dist/index.html',
    'web/dist/**/*',

    'config.json',
    'locales/*.json',
    
    'modules/**/*.lua',
    'modules/**/*.json',
    'imports/*.lua',
    'loaders/*.lua'
}

