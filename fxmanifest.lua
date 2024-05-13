fx_version 'cerulean'
game 'gta5'

name 'qbx_spawn'
description 'Spawn selection for Qbox'
repository 'https://github.com/Qbox-project/qbx_spawn'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
	'@ox_lib/init.lua',
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

files {
	'config/client.lua',
	'locales/*.json'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
