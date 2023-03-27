minetest.unregister_chatcommand("spawn")

minetest.register_chatcommand("spawn", {
    description = "Teleport yourself or another player to spawn",
    params = "[player]",
    func = function(name, param)
        if param ~= "" then
            local player = minetest.get_player_by_name(param)
            
            if player then
                if minetest.check_player_privs(name, {server = true}) then
                    player:set_pos(nextbot.static_spawn)
                    minetest.chat_send_player(name, 'Teleported "' .. param .. '" to spawn')
                else
                    minetest.chat_send_player(name, "You cannot send another player to spawn")
                end
            else
                minetest.chat_send_player(name, '"' .. param .. '" either does not exist or is not logged in')
            end
        else
            local player = minetest.get_player_by_name(name)

            player:set_pos(nextbot.static_spawn)
            minetest.chat_send_player(name, "Teleported to spawn")
        end
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

minetest.register_on_joinplayer(function(player)
    local text = player:get_player_name()

    if minetest.check_player_privs(player, {server = true}) then
        text = minetest.colorize("purple", "[OWNER] ") .. text
    end

    player:set_nametag_attributes({text = text})
end)

minetest.register_chatcommand("restart", {
    description = "Restart the server after 20 seconds",
    privs = {server = true},
    params = "[reason]",
    func = function(name, param)
        minetest.chat_send_all(minetest.colorize("red", "Server restart requested by " .. name .. ": " .. param))
        minetest.request_shutdown(param, true, 20)
    end
})