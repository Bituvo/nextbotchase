local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)

nabm_biomes = {}

-- biome registers
dofile(mod_path .. DIR_DELIM .. "biome_register.lua")
dofile(mod_path .. DIR_DELIM .. "schematics.lua")

-- biomes
-- dofile(mod_path .. DIR_DELIM .. "biomes" .. DIR_DELIM .. "grasslands.lua")
-- dofile(mod_path .. DIR_DELIM .. "biomes" .. DIR_DELIM .. "ocean.lua")
