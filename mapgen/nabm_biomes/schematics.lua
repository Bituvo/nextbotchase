local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

function nabm_biomes.get_schematic_path(name)
    return (mod_path .. DIR_DELIM .. "schematics" .. DIR_DELIM .. name .. ".mts")
end
