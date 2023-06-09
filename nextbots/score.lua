local S = minetest.get_translator("nextbots")
local storage = minetest.get_mod_storage()

function nextbots.calculate_score(player, player_chased_time, nextbot_speed)
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
	player_chased_time = current_player_data.chased_time
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

local function get_player_data(player_name)
	local player_data = storage:get_string(player_name)

	if player_data ~= "" then
		return minetest.deserialize(player_data)
	end
end

function nextbots.get_player_score(player_name)
	local player_data = get_player_data(player_name)

	if player_data then
		return player_data.score
	end

	return 0
end

-- Coloring functions
local err = function(message) return minetest.colorize(server.error_color, message) end
local inf = function(message) return minetest.colorize(server.info_color, message) end

minetest.register_chatcommand("score", {
	description = S("See a player's score or your own"),
	params = "[" .. S("player") .. "]",

	func = function(invoker_name, player_name)
		if player_name == "" then
			local player_score = nextbots.get_player_score(invoker_name)

			minetest.log("action", invoker_name .. " viewed their score: " .. player_score)
			return true, inf(S("Your score: @1", player_score))
		else
			if minetest.player_exists(player_name) then
				local player_score = nextbots.get_player_score(player_name)

				minetest.log("action", invoker_name .. " viewed " .. player_name .. "'s score: " .. player_score)
				return true, inf(S("@1's score: @2", player_name, player_score))
			else
				return false, err(S('The player "@1" does not exist', player_name))
			end
		end
	end
})

local function compare_scores(a, b)
	return a.score > b.score
end

minetest.register_chatcommand("highscores", {
	description = S("See the leaderboard"),

	func = function(invoker_name)
		minetest.log(invoker_name .. " viewed highscores")

		local scores = {}

		for player_name, player_data in pairs(storage:to_table()["fields"]) do
			player_data = minetest.deserialize(player_data)
			player_data.name = player_name
			table.insert(scores, player_data)
		end

		table.sort(scores, compare_scores)

		local formspec = "formspec_version[5]" ..
			"size[17, 10]" ..
			"bgcolor[#111a]" ..
			"label[1.15, 1;" .. S("Player name") .. "]" ..
			"label[7.2, 1;" .. S("Score") .. "]" ..
			"label[10.25, 1;" .. S("Death count") .. "]" ..
			"label[13.4, 1;" .. S("Seconds chased") .. "]" ..
			"button_exit[12, 8;4, 1;exit_highscores;" .. S("Close") .. "]" ..
			"tablecolumns[text,width=18;text,width=9;text,width=9;text]" ..
			"table[1, 1.5;15, 6;highscores;"

		local formspec_table_data = {}
		for _, player_data in ipairs(scores) do
			table.insert(formspec_table_data, player_data.name)
			table.insert(formspec_table_data, string.format("%.2f", player_data.score))
			table.insert(formspec_table_data, player_data.deaths)
			table.insert(formspec_table_data, string.format("%.2f", player_data.chased_time))
		end

		formspec = formspec .. table.concat(formspec_table_data, ",") .. "]"
		minetest.show_formspec(invoker_name, "highscores", formspec)
	end
})