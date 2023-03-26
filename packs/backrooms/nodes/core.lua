local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

minetest.register_node("br_core:null_node", {
    description = "just to trick minetest into loading mapblocks",
    pointable = false,
    groups = { dig_immediate = 3 },
    drawtype = "airlike",
    use_texture_alpha = "clip",
    sounds = {},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
})