minetest.register_on_respawnplayer(function(player)
	nextbots.handle_new_player(player)
	return true
end)

minetest.register_on_leaveplayer(function(player)
	local nextbot_id = player:get_meta():get_int("nextbot_id")
	nextbots.remove_nextbot(nextbot_id)
end)