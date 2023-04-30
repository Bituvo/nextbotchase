local modpath = minetest.get_modpath("nextbots")

nextbots = {
	player_spawn_offset = 20,
	player_speed = 4,
	
	registered_nextbots = {},
	spawned_nextbots = {}
}

dofile(modpath .. "/definitions.lua")
dofile(modpath .. "/functions.lua")
dofile(modpath .. "/logic.lua")
dofile(modpath .. "/spawning.lua")
dofile(modpath .. "/chatcommands.lua")
dofile(modpath .. "/score.lua")
dofile(modpath .. "/roles.lua")