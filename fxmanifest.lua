---@diagnostic disable: undefined-global
fx_version 'cerulean'
game 'gta5'
version '0.0.1'

dependencies {
	'rp_utils'
}

client_scripts {
	'@rp_utils/i18n.lua',
	'@rp_utils/logging.lua',
	'@rp_utils/utils.lua',

	'client/*.lua',
	'shared/*.lua'
}

server_scripts {
	'@rp_utils/i18n.lua',
	'@rp_utils/logging.lua',
	'@rp_utils/utils.lua',

	'server/*.lua',
	'shared/*.lua'
}

files {
	'locales/*.lua'
}