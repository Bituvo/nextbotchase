local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)

local get_biome = function(pos)
    return 0
end
br_core.get_biome = get_biome

br_core.generator = "main"

br_core.generators = {}

if br_core.mapgen == "flat" then
    br_core.generator = "flat"
    minetest.register_ore({
        ore_type       = "stratum",
        ore            = "br_core:barrier",
        wherein        = {"air", "group:liquid"},
        y_min = -32,
        y_max = -32,
    })
end

dofile(mod_path .. DIR_DELIM .. "mapgen" .. DIR_DELIM .. "biome_register.lua")
dofile(mod_path .. DIR_DELIM .. "mapgen" .. DIR_DELIM .. "biomes.lua")
dofile(mod_path .. DIR_DELIM .. "mapgen" .. DIR_DELIM .. "mg_main.lua")

minetest.register_on_generated(function(minp, maxp)
    if br_core.generator ~= "flat" then
        return br_core.generators[br_core.generator](minp, maxp)
    end
end)
