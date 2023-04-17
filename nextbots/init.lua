local modpath = minetest.get_modpath("nextbots")

nextbots = {
	player_spawn_offset = 20,
	
	registered_nextbots = {},
	spawned_nextbots = {}
}

dofile(modpath .. "/definitions.lua")
dofile(modpath .. "/logic.lua")
dofile(modpath .. "/playerhandler.lua")
dofile(modpath .. "/chatcommands.lua")