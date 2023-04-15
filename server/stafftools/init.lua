stafftools = {}

function stafftools.admin_chat_send(message)
    for _, player in ipairs(minetest.get_connected_players()) do
        if minetest.check_player_privs(player, {server = true}) then
            minetest.chat_send_player(player:get_player_name(), message)
        end
    end
end

-- Make owners have purple nametags
minetest.register_on_joinplayer(function(player)
    local text = player:get_player_name()

    if minetest.check_player_privs(player, {server = true}) then
        text = minetest.colorize("purple", "[OWNER] ") .. text
    end

    player:set_nametag_attributes({text = text})
end)