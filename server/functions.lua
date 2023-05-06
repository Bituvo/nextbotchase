function server.prepare_player(player)
	player:hud_set_flags({hotbar = false, healthbar = false, wielditem = false, crosshair = false, basic_debug = false})
	player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.5, y = 0.5},
		text = "vignette.png",
		direction = 0,
		scale = {x = -100, y = -100},
		offset = {x = 0, y = 0}
	})
end

-- Send message that only staff can see
function server.admin_chat_send(message)
	minetest.log("action", "Sending admin chat message: " .. minetest.strip_colors(message))

	for _, player in ipairs(minetest.get_connected_players()) do
		if minetest.check_player_privs(player, {server = true}) then
			minetest.chat_send_player(player:get_player_name(), minetest.colorize(server.staff_color, message))
		end
	end
end