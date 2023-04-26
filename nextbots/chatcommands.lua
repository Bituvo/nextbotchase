local storage = minetest.get_mod_storage()
local S = minetest.get_translator("nextbots_chatcommands")

-- Coloring functions
local err = function(message) return minetest.colorize(server.error_color, message) end
local suc = function(message) return minetest.colorize(server.success_color, message) end
local inf = function(message) return minetest.colorize(server.info_color, message) end

-- Register a spawn command for each registered nextbot
for nextbot_name, data in pairs(nextbots.registered_nextbots) do
	minetest.register_chatcommand(nextbot_name, {
		description = S("Spawns @1 at your location with a given target", data.formal_name),
		privs = {server = true},
		params = "<" .. S("player_name") .. ">",

		func = function(invoker_name, target_name)
			if target_name == "" then
				return false, err(S('Invalid parameters, see "@1"', "/help " .. nextbot_name))
			end

			local invoker = minetest.get_player_by_name(invoker_name)
			local target = minetest.get_player_by_name(target_name)

			if target then
				nextbots.spawn_nextbot(nextbot_name, invoker:get_pos(), target, 1)
				minetest.log("action", invoker_name .. " spawned " .. nextbot_name .. " with target " .. target_name)
				return true, suc(S("Successfully spawned @1", nextbots.registered_nextbots[nextbot_name].formal_name))
			else
				return false, err(S('The player "@1" either does not exist or is not logged in', target_name))
			end
		end
	})
end

minetest.register_chatcommand("clear", {
	description = S("Deletes each nextbot with a certain name (empty name to delete all)"),
	privs = {server = true},
	params = "[" .. S("nextbot_name") .. "]",

	func = function(invoker_name, nextbot_name)
		local removed_nextbots = 0
		for id, nextbot in pairs(nextbots.spawned_nextbots) do
			if nextbot_name == "" or nextbot:get_luaentity()._technical_name == nextbot_name then
				nextbot:remove()
				nextbots.spawned_nextbots[id] = nil

				removed_nextbots = removed_nextbots + 1
			end
		end

		if removed_nextbots == 0 then
			return false, inf(S("No nextbots were found"))
		elseif removed_nextbots == 1 then
			minetest.log("action", "/clear: Removed 1 nextbot")
			return true, suc(S("1 nextbot was removed"))
		else
			minetest.log("action", "/clear: Removed " .. removed_nextbots .. " nextbots")
			return true, suc(S("@1 nextbots were removed", removed_nextbots))
		end
	end
})

minetest.register_chatcommand("find", {
	description = S("Finds a player's nextbot"),
	privs = {server = true},
	params = "<" .. S("player_name") .. ">",

	func = function(invoker_name, player_name)
		local invoker = minetest.get_player_by_name(invoker_name)
		local player = minetest.get_player_by_name(player_name)

		if player then
			local player_nextbot_id = player:get_meta():get_int("nextbot_id")

			if player_nextbot_id > 0 then
				local nextbot = nextbots.spawned_nextbots[player_nextbot_id]
				invoker:set_pos(nextbot:get_pos())

				minetest.log("action", invoker_name .. " teleported to " .. player_name .. "'s nextbot")
				return true, suc(S("Teleported to @1", minetest.pos_to_string(nextbot:get_pos())))
			end
		else
			return false, err(S('The player "@1" either does not exist or is not logged in', player_name))
		end
	end
})

local function get_player_score(player_name)
	local player_data = storage:get_string(player_name)
	local player_score = 0

	if player_data ~= "" then
		player_data = minetest.deserialize(player_data)
		player_score = player_data.score
	end

	return player_score
end

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
			local player = minetest.get_player_by_name(player_name)

			if player then
				local player_score = get_player_score(player_name)

				minetest.log("action", invoker_name .. " viewed " .. player_name .. "'s score: " .. player_score)
				return true, inf(S("@1's score: @2", player_name, player_score))
			else
				return false, err(S('The player "@1" either does not exist or is not logged in', player_name))
			end
		end
	end
})