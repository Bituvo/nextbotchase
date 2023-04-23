-- HUD stuff
local function set_hud(player)
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

-- Show a player the rules if they have not agreed to them yet
minetest.register_on_newplayer(function(player)
	player:set_physics_override({speed = nextbots.player_speed})
	
	if not minetest.check_player_privs(player, {server = true}) then
		set_hud(player)
		
		player:get_meta():set_int("rules_agreed", 0)
		player:set_pos(server.static_spawn)

		server.show_new_player_rules(player)
	end
end)

-- Ditto, but also spawn a nextbot
minetest.register_on_joinplayer(function(player)
	player:set_physics_override({speed = nextbots.player_speed})

	if not minetest.check_player_privs(player, {server = true}) then
		set_hud(player)
		
		if player:get_hp() > 0 then
			if player:get_meta():get_int("rules_agreed") == 0 then
				server.show_new_player_rules(player)
				return
			else
				nextbots.handle_new_player(player)
			end
		end
	end
end)

minetest.register_on_respawnplayer(function(player)
	nextbots.handle_new_player(player)
	return true
end)