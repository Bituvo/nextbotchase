local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

nextbot = {}

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/nextbot.lua")
dofile(modpath .. "/registernextbots.lua")
dofile(modpath .. "/chatcommands.lua")
dofile(modpath .. "/playerregistrations.lua")