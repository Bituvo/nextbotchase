-- Remove garbage
minetest.unregister_chatcommand("spawn")
minetest.unregister_chatcommand("killme")

minetest.register_chatcommand("spawn", {
    description = "Teleport to spawn",
    privs = {server = true},
    
    func = function(name)
        local player = minetest.get_player_by_name(name)
        player:set_pos(server.static_spawn)

        minetest.chat_send_player(name, "Teleported to spawn")
    end
})

minetest.register_chatcommand("who", {
    description = "List who is currently logged in",
    func = function(name)
        local message = "Clients: "

        for _, player in ipairs(minetest.get_connected_players()) do
            message = message .. player:get_player_name() .. ", "
        end

        minetest.chat_send_player(name, string.sub(message, 1, -3))
    end
})

-- For updating stuff (etim3 has an auto-pull + restart script running)
minetest.register_chatcommand("restart", {
    description = "Restart the server after 20 seconds",
    privs = {server = true},
    params = "[reason]",
    func = function(name, param)
		if param == "" then
			param = "No reason specified"
		end
		
        minetest.chat_send_all(minetest.colorize("red", "Server restart requested by " .. name .. ": " .. param .. " (wait a bit before reconnecting)"))
        minetest.request_shutdown(param .. "\n\nWait a bit before reconnecting.\nIf the server doesn't reboot, Discord PM the admin: Thresher#9632", true, 20)
        minetest.clear_objects()
    end
})