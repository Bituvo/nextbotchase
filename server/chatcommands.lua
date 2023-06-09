-- local storage = minetest.get_mod_storage()
local S = minetest.get_translator("server")

-- Coloring functions
local err = function(message) return minetest.colorize(server.error_color, message) end
local suc = function(message) return minetest.colorize(server.success_color, message) end
local inf = function(message) return minetest.colorize(server.info_color, message) end

-- Remove garbage
minetest.unregister_chatcommand("spawn")
minetest.unregister_chatcommand("killme")
minetest.unregister_chatcommand("clearobjects")
minetest.unregister_chatcommand("ban")

minetest.register_chatcommand("spawn", {
	description = S("Teleport to spawn"),
	privs = {server = true},

	func = function(name)
		local player = minetest.get_player_by_name(name)
		player:set_pos(server.static_spawn)

		minetest.log("action", name .. " teleported to spawn")
		return true, suc(S("Teleported to spawn"))
	end
})

minetest.register_chatcommand("who", {
	description = S("List who is currently logged in"),

	func = function(name)
		local message = inf(S("Clients: "))

		for _, player in ipairs(minetest.get_connected_players()) do
			local player_rank_color = server.get_player_rank(player:get_player_name()).color
			message = message .. minetest.colorize(player_rank_color, player:get_player_name()) .. ", "
		end

		minetest.log("action", name .. " viewed clients list")
		return true, string.sub(message, 1, -3)
	end
})

-- For updating stuff (etim3 has an auto-pull + restart script running)
minetest.register_chatcommand("restart", {
	description = S("Restarts the server after 20 seconds"),
	privs = {server = true},
	params = "[" .. S("reason") .. "]",

	func = function(invoker_name, reason)
		if reason == "" then
			reason = S("No reason specified")
		end
		reason = err(reason)

		for _, player in ipairs(minetest.get_connected_players()) do
			if player:get_player_name() ~= invoker_name then
				minetest.show_formspec(player:get_player_name(), "restart_notification", "formspec_version[5]" ..
					"size[8, 6]" ..
					"no_prepend[]" ..
					"bgcolor[#111a]" ..
					"label[1, 1;" .. S("The server will restart in 20 seconds!") .. "]" ..
					"label[1, 2;" .. S("Reason: @1", minetest.wrap_text(reason, 35)) .. "]" ..
					"button_exit[2.5, 4;3, 1;close_restart_notification;Ok]"
				)
			end
		end

		minetest.log("action", invoker_name .. " restarted the server (reason: " .. reason .. ")")

		minetest.clear_objects()
		minetest.request_shutdown(
			reason .. "\n\n" .. S("Wait three minutes before reconnecting.") .. "\n" ..
			S("If the server doesn't reboot, Discord PM the admin: @1", "Thresher#9632"),
		true, 20)

		return true, inf(S("Server restart requested by @1: @2 (wait three minutes before reconnecting)",
			invoker_name, reason))
	end
})

-- minetest.register_chatcommand("analytics", {
-- 	description = S("View server analytics"),
-- 	privs = {server = true},

-- 	func = function(_)
-- 		return true,
-- 			inf(S("MultiCraft clients: @1", tostring(storage:get_int("multicraft")))) .. "\n" ..
-- 			inf(S("Minetest clients: @1", tostring(storage:get_int("minetest"))))
-- 	end
-- })