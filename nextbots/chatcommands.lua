-- Register a spawn command for each registered nextbot
for nextbot_name, data in pairs(nextbots.registered_nextbots) do
	formal_nextbot_name = data.formal_name

	minetest.register_chatcommand(nextbot_name, {
		description = "Spawns " .. data.formal_name .. " at your location",
		privs = {server = true},
		params = "<player_name>",

		func = function(invoker_name, target_name)
			if target_name == "" then
				return false, "Invalid parameters, see /help " .. nextbot_name
			end

			local invoker = minetest.get_player_by_name(invoker_name)
			local target = minetest.get_player_by_name(target_name)

			if target then
				nextbots.spawn_nextbot(nextbot_name, invoker:get_pos(), target, 1)
			else
				minetest.chat_send_player(invoker, "The player '" .. target_name .. "' either does not exist or is not logged in")
			end
		end
	})
end

minetest.register_chatcommand("clear", {
	description = "Deletes each nextbot with a certain name (empty name to delete all)",
	privs = {server = true},
	params = "[nextbot_name]",

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
			minetest.chat_send_player(invoker_name, "No nextbots were found")
		elseif removed_nextbots == 1 then
			minetest.chat_send_player(invoker_name, "1 nextbot was removed")
		else
			minetest.chat_send_player(invoker_name, tostring(removed_nextbots) .. " nextbots were removed")
		end
	end
})

