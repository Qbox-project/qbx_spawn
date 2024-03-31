fx_version 'cerulean'
game 'gta5'

version '1.0.0'
repository 'https://github.com/Qbox-project/qbx_spawn'

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

client_scripts {
	'client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
