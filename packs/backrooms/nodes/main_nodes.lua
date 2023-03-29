local debug = br_core.debug

-- adds a variant of a node by overlaying
local function add_overlay_variant(name, overlay_tex, variant_type, flags)
    flags = flags or {}
    local node_name = name.."_"..variant_type
    local node = minetest.registered_nodes[name]
    local copy = table.copy(node)
    if copy.tiles[1].name then
        copy.tiles[1].name = "("..node.tiles[1].name..")^"..overlay_tex
    else
        copy.tiles[1] = "("..node.tiles[1]..")^"..overlay_tex
    end
    copy.description = node.description.."_"..variant_type
    minetest.register_node(node_name, copy)
    if flags.make_shapes then pmb_util.register_all_shapes(node_name) end
end

minetest.register_node("br_core:carpet_0", {
    tiles = { "br_".."carpet_0.png" },
    light_source = (br_core.fullbright) or 0,
})

minetest.register_node("br_core:wallpaper_0", {
    tiles = { "br_".."wallpaper_0.png" },
    light_source = (br_core.fullbright) or 0,
}) add_overlay_variant("br_core:wallpaper_0", "(br_skirting_board_0.png^[sheet:16x16:0,0^[multiply:#d9d8c4)", "skirting", {})

-- add hardcoded shading back in, but do it in a way that doesn't suck
-- this is due to minetest hardcoding nodes to have a certain discoloration
-- to mimic directional shading, that cannot be disabled and prevents the
-- creation of white ceilings, since the brightest color you can achieve for
-- the underside of a node is #8a8a97 (VERY dark) so we have to use light_source = 1
-- and use this jank workaround
local shaders = {"#c8c8c8", "#eee", "#ddd"}
local engine_shaders = {"#aaa", "#aaaaaf", "#d4d4d9"}
local function shader_unfck(tex, sides)
    local s = sides or engine_shaders
    return {
        {
            name = tex.."^[multiply:#fff",
            align_style = "world",
            scale = 16
        },
        {
            name = tex.."^[multiply:"..s[1],
            align_style = "world",
            scale = 16
        },
        {
            name = tex.."^[multiply:"..s[2],
            align_style = "world",
            scale = 16
        },
        {
            name = tex.."^[multiply:"..s[2],
            align_style = "world",
            scale = 16
        },
        {
            name = tex.."^[multiply:"..s[3],
            align_style = "world",
            scale = 16
        },
        {
            name = tex.."^[multiply:"..s[3],
            align_style = "world",
            scale = 16
        },
    }
end

minetest.register_node("br_core:ceiling_conduit_grey", {
    tiles = {{
        name = "(br_meta_blank.png^[colorize:#889:255"..
        "^(br_meta_overlay_dirt_1.png^[multiply:#223^[opacity:10))",
        align_style = "world",
        scale = 16,
    }},
    light_source = (br_core.fullbright) or 0,
})

minetest.register_node("br_core:concrete_grey", {
    tiles = {{
        name = "br_meta_blank.png^[colorize:#889:255^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)",
        align_style = "world",
        scale = 16,
    }},
    light_source = (br_core.fullbright) or minetest.LIGHT_MAX,
})

minetest.register_node("br_core:ceiling_tiles_yellow", {
    tiles = shader_unfck(
        "br_meta_blank.png^[colorize:#c5b794:255"..
        "^(br_meta_overlay_crisscross_2.png^[multiply:#ddc^[opacity:100)"..
        "^(br_meta_overlay_dirt_1.png^[multiply:#112^[opacity:10)"),
    light_source = 1,
})

selectionbox = {
    type = "fixed",
    fixed = {
        {
            -5/16, -8/16, -8/16,
             5/16, -4/16,  8/16,
        },
    },
}

nodebox = {
    type = "fixed",
    fixed = {
        {
            -7/16, -8/16, -8/16,
             7/16, -7/16,  8/16,
        },
    },
}

minetest.register_node("br_core:ceiling_light_3", {
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_ceiling_light_1.png" },
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    paramtype = "light",
    light_source = 14,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})

minetest.register_node("br_core:ceiling_light_3_off", {
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_ceiling_light_1.png^[multiply:#cfcecf" },
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})