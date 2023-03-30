minetest.register_privilege("no_nextbot", {
    description = "No nextbots will chase players with this privelege",
    give_to_admin = true
})

minetest.register_chatcommand("add_nextbot", {
	description = "Add a nextbot for a player at your location",
	privs = {server = true},
	params = "<player> <bot> [force]",
	func = function(name, param)
		local target_name, nextbot_name, force = string.match(param, "(%w+)%s(%w+)%s?(%w*)")

		if not target_name or not nextbot_name or target_name == "" or nextbot_name == "" then
			minetest.chat_send_player(name, "Invalid arguments, see /help add_nextbot")
			return
		end

		local invoker = minetest.get_player_by_name(name)
		local target = minetest.get_player_by_name(target_name)

		if target then
			local should_spawn_nextbot = false

			if minetest.check_player_privs(target, {no_nextbot = true}) then
				if force == "" then
					minetest.chat_send_player(target_name.. ' has the "no_nextbot" privilege')
					return
				else
					should_spawn_nextbot = true
				end
			else
				should_spawn_nextbot = true
			end

			if should_spawn_nextbot then
				local pos = invoker:get_pos()
                pos.y = -2

				nextbot.add_nextbot(nextbot_name, target, pos)
			end
		else
			minetest.chat_send_player(name, '"' .. target_name .. '" either does not exist or is not logged in')
        end
	end
})

minetest.register_chatcommand("find_nextbot", {
    description = "Find a player's nextbot",
    privs = {server = true},
    params = "<player>",
    func = function(name, param)
        local invoker = minetest.get_player_by_name(name)
        local player = minetest.get_player_by_name(param)

        if player then
            local player_nextbot = nextbot.get_player_nextbot(player)

            if player_nextbot then
                invoker:set_pos(player_nextbot:get_pos())
                minetest.chat_send_player(name, "Teleported to " .. param .. "'s nextbot")
            else
                minetest.chat_send_player(name, "Nextbot not found")
            end
        else
            minetest.chat_send_player(name, '"' .. param .. '" either does not exist or is not logged in')
        end
    end
})

minetest.register_chatcommand("delete_nextbot", {
    description = "Delete a player's nextbot",
    privs = {server = true},
    params = "<player>",
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        delete_player_nextbot(player)
    end
})