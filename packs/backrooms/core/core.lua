local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

-- init the player on join
minetest.register_on_joinplayer(function(player, last_login)
    if player.set_lighting then -- compat
	    player:set_lighting({ shadows = { intensity = tonumber(minetest.settings:get("br_shadow_intensity") or 0.33) } })
    end
end)