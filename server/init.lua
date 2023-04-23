local modpath = minetest.get_modpath("server")

server = {
	static_spawn = {x = 8, y = -4.5, z = 8}
}

dofile(modpath .. "/chatcommands.lua")
dofile(modpath .. "/rules.lua")
dofile(modpath .. "/playerregistrations.lua")
dofile(modpath .. "/death.lua")
dofile(modpath .. "/staffstuff.lua")
dofile(modpath .. "/status.lua")