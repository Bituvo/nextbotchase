
local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)


if (not minetest.get_modpath("player_info")) or (not player_info.version) or (player_info.version < "b1") then
    dofile(mod_path .. DIR_DELIM .. "main.lua")
end
