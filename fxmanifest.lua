fx_version 'cerulean'
game 'gta5'

name 'MySword_VehPlateTracker'
author 'MySword傅剑寒'
description 'Vehicle Tracker 车辆追踪系统'
version '1.0.2'

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