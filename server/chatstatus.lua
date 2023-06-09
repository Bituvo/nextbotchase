local S = minetest.get_translator("server")

function minetest.get_server_status(name)
	local message = minetest.colorize("#ff0", S("Welcome to BACKROOMS CHASE, ")) .. name
	message = message .. " | " .. minetest.colorize("#9ef", S('Type "/who" to see who is online, "/skin" to change your skin'))

	return message
end

local join_messages = {
	"@1 has joined the chase",
	"@1 has joined the game",
	"Say hello to @1",
	"@1 has arrived"
}

local leave_messages = {
	"@1 couldn't handle the hunt",
	"@1 has left the game",
	"Say goodbye to @1",
	"@1 has left"
}

function minetest.send_join_message(player_name)
	local player_rank = server.get_player_rank(player_name)

	minetest.chat_send_all(minetest.get_color_escape_sequence(server.join_color) .. " =>" ..
		minetest.get_color_escape_sequence(player_rank.color) .. " [" .. player_rank.rank .. "] " ..
		minetest.get_color_escape_sequence(server.join_color) .. S(join_messages[math.random(1, 4)], player_name)
	)
end

function minetest.send_leave_message(player_name, timed_out)
	local message = " <= " .. S(leave_messages[math.random(1, 4)], player_name)

	if timed_out then
		message = message .. S(" (timed out)")
	end

	minetest.chat_send_all(minetest.colorize(server.leave_color, message))
end