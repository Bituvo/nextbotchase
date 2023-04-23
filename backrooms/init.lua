local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)

br_core = {
    debug = false,
    level_height = 160,
    chunk_width = 80,
    fullbright = false, --debug
    mapgen = "nil",
    generator = "main",
    dev_mode = false,
    nodes_pointable = true,
    offset = 32
}

br_core.mapgen = minetest.get_mapgen_setting("mg_name")
-- set mapgen params if correct mapgen setting
if br_core.mapgen == "v7" then
    minetest.set_mapgen_params({
        mgname = "singlenode",
        flags = "nocaves,nodungeons,light,decorations,biomes,ores",
    })
end

if minetest.is_creative_enabled() or br_core.mapgen == "flat" then
    br_core.fullbright = 1
    br_core.dev_mode = true
    br_core.nodes_pointable = false
end
br_core.fullbright = 0

minetest.register_on_joinplayer(function(player)
    if not minetest.check_player_privs(player, {server = true}) then
        minetest.sound_play("hum", {
            to_player = player:get_player_name(),
            loop = true
        })
    end
end)

dofile(mod_path .. DIR_DELIM .. "mapgen" .. DIR_DELIM .. "mapgen.lua")
-- makes nodes
dofile(mod_path .. DIR_DELIM .. "nodes" .. DIR_DELIM .. "main_nodes.lua")
dofile(mod_path .. DIR_DELIM .. "nodes" .. DIR_DELIM .. "core.lua")