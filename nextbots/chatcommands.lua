local storage = minetest.get_mod_storage()
local S = minetest.get_translator("nextbots")

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
				return false, err(S('Invalid parameters, see "/help @1"', nextbot_name))
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
				nextbots.remove_nextbot(id)
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
			local nextbot = nextbots.find_nextbot(player_name)

			if nextbot then
				invoker:set_pos(nextbot:get_pos())

				minetest.log("action", invoker_name .. " teleported to " .. player_name .. "'s nextbot")
				return true, suc(S("Teleported to @1", minetest.pos_to_string(nextbot:get_pos())))
			else
				return false, err(S("Nextbot not found"))
			end
		else
			return false, err(S('The player "@1" either does not exist or is not logged in', player_name))
		end
	end
})