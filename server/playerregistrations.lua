-- Show a player the rules if they have not agreed to them yet
minetest.register_on_newplayer(function(player)
	if not minetest.check_player_privs(player, {server = true}) then
		player:get_meta():set_int("rules_agreed", 0)
		player:set_pos(server.static_spawn)

		server.show_new_player_rules(player)
	end
end)

-- Ditto, but also spawn a nextbot
minetest.register_on_joinplayer(function(player)
	if not minetest.check_player_privs(player, {server = true}) then
		if player:get_meta():get_int("rules_agreed") == 0 then
			server.show_new_player_rules(player)
			return
		else
			nextbots.handle_new_player(player)
		end
	end
end)

minetest.register_on_respawnplayer(function(player)
	nextbots.handle_new_player(player)
	return true
end)