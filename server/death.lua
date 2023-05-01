-- minetest.register_on_player_hpchange(function(player, hp_change)
-- 	local current_hp = player:get_hp()
-- 	if current_hp + hp_change <= 0 then
		-- Show formspec

-- 		return player:get_properties().hp_max - current_hp
-- 	end
-- end, true)

-- register_on_player_receive_fields with player:respawn()

-- Prevent staff from taking damage
minetest.register_on_player_hpchange(function(player, hp_change)
	if minetest.check_player_privs(player, {server = true}) then
		return 0
	end

	return hp_change
end, true)