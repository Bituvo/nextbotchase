-- Send message that only staff can see
function server.admin_chat_send(message)
	minetest.log("action", "Sending admin chat message: " .. minetest.strip_colors(message))
	
	for _, player in ipairs(minetest.get_connected_players()) do
		if minetest.check_player_privs(player, {server = true}) then
			minetest.chat_send_player(player:get_player_name(), minetest.colorize(server.staff_color, message))
		end
	end
end