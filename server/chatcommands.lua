local S = minetest.get_translator("chatcommands")

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
        local reason = param
        if reason == "" then
			reason = "No reason specified"
		end

        for _, player in ipairs(minetest.get_connected_players()) do
            -- if not minetest.check_player_privs(player, {server = true}) then
            minetest.show_formspec(player:get_player_name(), "restart_notification", "formspec_version[5]" ..
                "size[8, 6]" ..
                "no_prepend[]" ..
                "bgcolor[#111a]" ..
                "label[1, 1;" .. S("The server will restart in 20 seconds!") .. "]" ..
                "label[1, 2;" .. S("Reason: @1", minetest.wrap_text(reason, 35)) .. "]" ..
                "button_exit[2.5, 4;3, 1;close_restart_notification;Ok]"
            )
            -- end
        end
		
        minetest.log("action", name .. " restarted the server (reason: " .. reason .. ")")
        minetest.chat_send_all(minetest.colorize("red", "Server restart requested by " .. name .. ": " .. reason .. " (wait a bit before reconnecting)"))
        minetest.request_shutdown(param .. "\n\nWait a bit before reconnecting.\nIf the server doesn't reboot, Discord PM the admin: Thresher#9632", true, 20)
        minetest.clear_objects()
    end
})