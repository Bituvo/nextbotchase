local S = minetest.get_translator("nextbots_chatcommands")

-- Register a spawn command for each registered nextbot
for nextbot_name, data in pairs(nextbots.registered_nextbots) do
	formal_nextbot_name = data.formal_name

	minetest.register_chatcommand(nextbot_name, {
		description = S("Spawns @1 at your location with a given target", data.formal_name),
		privs = {server = true},
		params = "<" .. S("player_name") .. ">",

		func = function(invoker_name, target_name)
			if target_name == "" then
				return false, S('Invalid parameters, see "@1"', "/help " .. nextbot_name)
			end

			local invoker = minetest.get_player_by_name(invoker_name)
			local target = minetest.get_player_by_name(target_name)

			if target then
				nextbots.spawn_nextbot(nextbot_name, invoker:get_pos(), target, 1)
			else
				minetest.chat_send_player(invoker_name, S('The player "@1" either does not exist or is not logged in', target_name))
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
			if nextbot_name == "" or nextbot:get_luaentity().name == "nextbots:" .. nextbot_name then
				nextbot:remove()
				nextbots.spawned_nextbots[id] = nil

				removed_nextbots = removed_nextbots + 1
			end
		end

		if removed_nextbots == 0 then
			minetest.chat_send_player(invoker_name, S("No nextbots were found"))
		elseif removed_nextbots == 1 then
			minetest.chat_send_player(invoker_name, S("1 nextbot was removed"))
		else
			minetest.chat_send_player(invoker_name, S("@1 nextbots were removed", tostring(removed_nextbots)))
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

				minetest.chat_send_player(invoker_name, "Teleported to " .. minetest.pos_to_string(nextbot:get_pos()))
			end
		else
			minetest.chat_send_player(invoker_name, S('The player "@1" either does not exist or is not logged in', player_name))
		end
	end
})