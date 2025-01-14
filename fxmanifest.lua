fx_version 'cerulean'
game 'gta5'

author 'MySword傅剑寒'
description 'Vehicle Plate Tracking System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

lua54 'yes'
use_fxv2_oal 'yes'