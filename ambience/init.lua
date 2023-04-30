local function play_ambient_noise(player)
	local sound_pos = vector.add(player:get_pos(),
		vector.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	)

	minetest.sound_play("ambient", {
		to_player = player:get_player_name(),
		pos = sound_pos,
		gain = 10 / vector.distance(player:get_pos(), sound_pos)
	})

	minetest.after(math.random(30, 60), function()
		play_ambient_noise(player)
	end)
end

minetest.register_on_joinplayer(function(player)
	if not minetest.check_player_privs(player, {server = true}) then
		minetest.sound_play("hum", {
			to_player = player:get_player_name(),
			loop = true
		})

		minetest.after(math.random(30, 60), function()
			play_ambient_noise(player)
		end)
	end
end)