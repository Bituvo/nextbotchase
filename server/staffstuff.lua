-- Send message that only staff can see
function server.admin_chat_send(message)
	for _, player in ipairs(minetest.get_connected_players()) do
		if minetest.check_player_privs(player, {server = true}) then
			minetest.chat_send_player(player, minetest.colorize(server.staff_color))
		end
	end
end