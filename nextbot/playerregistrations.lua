minetest.register_on_newplayer(nextbot.on_new_player)

minetest.register_on_joinplayer(nextbot.on_new_player)

minetest.register_on_respawnplayer(function(player)
	nextbot.on_new_player(player)
	return true
end)