minetest.register_on_respawnplayer(function(player)
	nextbot.on_new_player(player)
	return true
end)