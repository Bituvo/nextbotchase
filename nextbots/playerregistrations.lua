minetest.register_on_respawnplayer(function(player)
	nextbots.handle_new_player(player)
	return true
end)

minetest.register_on_leaveplayer(function(player)
	nextbots.remove_nextbot(player:get_player_name())
end)

-- Pause nextbots when player opens formspec, resume when formspec closes
minetest.register_on_player_receive_fields(function(player, _, fields)
	local player_nextbot = nextbots.find_nextbot(player:get_player_name())
	if not player_nextbot then return end
	local nextbot_luaentity = player_nextbot:get_luaentity()
	if not nextbot_luaentity then return end

	if fields.quit == "true" then
		nextbot_luaentity._chasing = true
	else
		nextbot_luaentity._chasing = false
	end
end)