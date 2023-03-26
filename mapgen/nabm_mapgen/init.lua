local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

-- these tell minetest what nodes to generate in the world
minetest.register_alias('mapgen_stone', 'air')
minetest.register_alias('mapgen_water_source', 'air')
minetest.register_alias('mapgen_river_water_source', 'air')
