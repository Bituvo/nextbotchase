

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    local p = player_info.get(player)
    if (p ~= nil) and p.damage_from[reason.type] ~= nil then
        hp_change = hp_change * p.damage_from[reason.type]
    end
    return hp_change
end, true)
