local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

function br_core.get_level_y(level)
    return level * br_core.level_height - br_core.offset + (br_core.level[level].base_height or 0)
end

function br_core.relocator_get_rift_or_nil(pos)
    local level = br_core.get_level(pos)
    for i, rift in pairs(rifts) do
        if rift.from_level == level
        and vector.distance(rift.pos, pos) < 10 then
            return rift
        end
    end
end

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