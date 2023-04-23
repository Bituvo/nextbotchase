local S = minetest.get_translator("status")

function minetest.get_server_status(name, joined)
	local message = minetest.colorize("yellow", S("Welcome to BACKROOMS CHASE, ")) .. name
	message = message .. " | " .. minetest.colorize("#afa", 'Type "/who" to see who is online')

	return message
end