-- =================================================================
-- D3XL FiveM Standalone Progress Bar System Manifest
-- Resource Name: d3xl-progressbar
-- Author: d3xl
-- =================================================================

fx_version 'cerulean'
game 'gta5'

author 'd3xl'
description 'Progress Bar System V1'
version '1.0.0'

ui_page 'index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}

files {
    'index.html',
    'style.css',
    'config.js',
    'app.js'
}

export 'Progress'
export 'Progressbar'
export 'isDoingAction'
