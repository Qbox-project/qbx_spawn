fx_version 'cerulean'
game 'gta5'

description 'qbx_Spawn'
repository 'https://github.com/Qbox-project/qbx_spawn'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua',
	'@qbx_core/import.lua',
	'@qbx_apartments/config.lua'
}

client_script 'client.lua'
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

ui_page 'html/index.html'

modules {
    'qbx_core:playerdata'
}

files {
	'html/index.html',
	'html/style.css',
	'html/vue.js',
	'html/reset.css'
}

lua54 'yes'

use_experimental_fxv2_oal 'yes'