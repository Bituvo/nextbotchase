local storage = minetest.get_mod_storage()

minetest.register_on_newplayer(function(player)
	local player_information = minetest.get_player_information(player:get_player_name())

	if player_information.formspec_version == 1 then
		-- MultiCraft
		local mc_users = storage:get_int("multicraft")
		mc_users = mc_users + 1
		storage:set_int("multicraft", mc_users)

	else
		-- Minetest
		local mt_users = storage:get_int("minetest")
		mt_users = mt_users + 1
		storage:set_int("minetest", mt_users)
	end
end)

minetest.register_chatcommand("analytics", {
	description = "View analytics",
	privs = {server = true},

	func = function(name)
		minetest.chat_send_player(name, "MultiCraft users: " .. tostring(storage:get_int("multicraft")))
		minetest.chat_send_player(name, "Minetest users: " .. tostring(storage:get_int("minetest")))
	end
})