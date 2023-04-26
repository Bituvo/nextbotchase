local storage = minetest.get_mod_storage()

function nextbots.calculate_score(player, player_chased_time, nextbot_speed)
	local player_meta = player:get_meta()

	local current_player_data = storage:get_string(player:get_player_name())
	if current_player_data == "" then
		current_player_data = {
			chased_time = 0,
			deaths = 0,
			score = 0
		}
	else
		current_player_data = minetest.deserialize(current_player_data)
	end

	current_player_data.chased_time = current_player_data.chased_time + player_chased_time
	current_player_data.deaths = current_player_data.deaths + 1

	local player_score = current_player_data.score
	local player_chased_time = current_player_data.chased_time
	local player_deaths = current_player_data.deaths
	if current_player_data.deaths < 5 then
		player_score = player_chased_time / (player_deaths * 3)
	else
		player_score = player_chased_time / (player_deaths + 3)
	end
	player_score = player_score + nextbot_speed / 10

	current_player_data.score = player_score

	storage:set_string(player:get_player_name(), minetest.serialize(current_player_data))
	minetest.log("action", "Recalculated score for " .. player:get_player_name())
end