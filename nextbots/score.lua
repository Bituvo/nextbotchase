local S = minetest.get_translator("score")
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

local function get_player_score(player_name)
	local player_data = storage:get_string(player_name)
	local player_score = 0

	if player_data ~= "" then
		player_data = minetest.deserialize(player_data)
		player_score = player_data.score
	end

	return player_score
end


-- Coloring functions
local err = function(message) return minetest.colorize(server.error_color, message) end
local inf = function(message) return minetest.colorize(server.info_color, message) end

minetest.register_chatcommand("score", {
	description = S("See a player's score or your own"),
	params = "[" .. S("player") .. "]",

	func = function(invoker_name, player_name)
		local invoker = minetest.get_player_by_name(invoker_name)

		if player_name == "" then
			local player_score = get_player_score(invoker_name)

			minetest.log("action", invoker_name .. " viewed their score: " .. player_score)
			return true, inf(S("Your score: @1", player_score))
		else
			if minetest.player_exists(player_name) then
				local player_score = get_player_score(player_name)

				minetest.log("action", invoker_name .. " viewed " .. player_name .. "'s score: " .. player_score)
				return true, inf(S("@1's score: @2", player_name, player_score))
			else
				return false, err(S('The player "@1" either does not exist or is not logged in', player_name))
			end
		end
	end
})