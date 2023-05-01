local modpath = minetest.get_modpath("server")

server = {
	static_spawn = {x = -32, y = -4.5, z = -32},
	player_speed = 4,

	join_color = "#af6",
	leave_color = "#f99",
	death_color = "#f33",

	error_color = "#f88",
	success_color = "#cfc",
	info_color = "#9ef",
	staff_color = "#c8e"
}

dofile(modpath .. "/chatcommands.lua")
dofile(modpath .. "/rules.lua")
dofile(modpath .. "/functions.lua")
dofile(modpath .. "/playerregistrations.lua")
dofile(modpath .. "/death.lua")
dofile(modpath .. "/chatstatus.lua")
dofile(modpath .. "/tipoftheday.lua")