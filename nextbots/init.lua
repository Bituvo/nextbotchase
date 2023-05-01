local modpath = minetest.get_modpath("nextbots")

nextbots = {
	player_spawn_offset = 20,
	
	registered_nextbots = {},
	spawned_nextbots = {}
}

dofile(modpath .. "/definitions.lua")
dofile(modpath .. "/functions.lua")
dofile(modpath .. "/playerregistrations.lua")
dofile(modpath .. "/logic.lua")
dofile(modpath .. "/spawning.lua")
dofile(modpath .. "/chatcommands.lua")
dofile(modpath .. "/score.lua")
dofile(modpath .. "/ranks.lua")