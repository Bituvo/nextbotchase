local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)

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
    description = "br_core:carpet_0",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
    tiles = { "br_".."carpet_0.png" },
    sounds = br_sounds.carpet(),
    light_source = (br_core.fullbright) or 0,
}) pmb_util.register_all_shapes("br_core:carpet_0")

minetest.register_node("br_core:wallpaper_0", {
    description = "br_core:wallpaper_0",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
    tiles = { "br_".."wallpaper_0.png" },
    sounds = br_sounds.carpet(),
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

br_core.node_colors = {
    black =     { main="#334",    alt="#556",    outline="#556",    highlight="#444455", lowlight="#112"   , raw="#445"},
    dark_grey = { main="#556",    alt="#a97",    outline="#778",    highlight="#666677", lowlight="#445"   , raw="#77777e"},
    grey =      { main="#889",    alt="#fff",    outline="#99a",    highlight="#9999aa", lowlight="#668"   , raw="#838397"},
    light_grey ={ main="#aab",    alt="#fff",    outline="#ccd",    highlight="#bbbbcc", lowlight="#88a"   , raw="#9b9ba4"},
    white =     { main="#eee",    alt="#99a",    outline="#fff",    highlight="#ffffff", lowlight="#dde"   , raw="#f6eeee"},
    red =       { main="#e15d55", alt="#fff",    outline="#cc8c7e", highlight="#e97b74", lowlight="#c35350", raw="#b5b5c0"},
    dark_red =  { main="#641d2b", alt="#fff",    outline="#daa",    highlight="#742d3b", lowlight="#54171b", raw="#6d6d73"},
    orange =    { main="#b85",    alt="#778",    outline="#a75",    highlight="#cc9966", lowlight="#a75"   , raw="#888899"},
    rust =      { main="#756052", alt="#fff",    outline="#877263", highlight="#877767", lowlight="#655052", raw="#6d6d73"},
    green =     { main="#4d7953", alt="#fff",    outline="#8c8b7d", highlight="#838962", lowlight="#4a7553", raw="#77777e"},
    blue =      { main="#478",    alt="#fff",    outline="#799598", highlight="#558899", lowlight="#367"   , raw="#b5b5c0"},
    yellow =    { main="#c5b794", alt="#d9d8c4", outline="#ddc",    highlight="#d5c7a4", lowlight="#b5a784", raw="#b5b5c0"},
}
-- make tons of variant nodes
for variant, color in pairs(br_core.node_colors) do
    minetest.register_node("br_core:concrete_"..variant, {
        description = "br_core:concrete_"..variant,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = {{
            name = "br_meta_blank.png^[colorize:"..(color.main)..":255^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)",
            align_style = "world",
            scale = 16,
        }},
        sounds = br_sounds.concrete(),
        light_source = (br_core.fullbright) or minetest.LIGHT_MAX,
    }) pmb_util.register_all_shapes("br_core:concrete_"..variant)
    add_overlay_variant("br_core:concrete_"..variant,
        "((br_skirting_board_0.png^[multiply:"..color.alt..")^(br_meta_overlay_dirt_1.png^[multiply:#334^[opacity:10"..
        "^[mask:(br_skirting_board_0.png)))", "skirting", {})
    minetest.register_craft({
        output = "br_core:concrete_"..variant.."_".."skirting",
        recipe = {
            {"br_core:concrete_"..variant},
        }
    })

    minetest.register_node("br_core:concrete_"..variant.."_ls", {
        description = "br_core:concrete_"..variant,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = shader_unfck(
            "br_meta_blank.png^[colorize:"..(color.main)..":255^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)"),
        sounds = br_sounds.concrete(),
        light_source = 1,
    }) pmb_util.register_all_shapes("br_core:concrete_"..variant.."_ls")

    minetest.register_node("br_core:ceiling_tiles_"..variant, {
        description = "br_core:ceiling_tiles_"..variant,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = shader_unfck(
            "br_meta_blank.png^[colorize:"..(color.main)..":255"..
            "^(br_meta_overlay_crisscross_2.png^[multiply:"..color.outline.."^[opacity:100)"..
            "^(br_meta_overlay_dirt_1.png^[multiply:#112^[opacity:10)"),
        sounds = br_sounds.default(),
        light_source = 1,
    })
end

minetest.register_alias("br_core:ceiling_tiles_0", "br_core:ceiling_tiles_yellow")

minetest.register_node("br_core:ceiling_light_0", {
    description = "br_core:ceiling_light_0",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    tiles = { "br_ceiling_light_0.png" },
    sounds = br_sounds.default(),
    paramtype = "light",
    light_source = 14,
    drawtype = (debug and "airlike") or "regular",
})
minetest.register_node("br_core:ceiling_light_0_off", {
    description = "br_core:ceiling_light_0_off",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    tiles = { "br_ceiling_light_0.png^[multiply:#cfcecf" },
    sounds = br_sounds.default(),
    light_source = 0,
    drawtype = (debug and "airlike") or "regular",
})

local selectionbox = {
    type = "fixed",
    fixed = {
        {
            -5/16, -8/16, -8/16,
             5/16, -4/16,  8/16,
        },
    },
}
local nodebox = {
    type = "fixed",
    fixed = {
        {
            -2/16, -8/16, -8/16,
            -1/16, -7/16,  8/16,
        },
        {
            1/16, -8/16, -8/16,
            2/16, -7/16,  8/16,
        },
    },
}
minetest.register_node("br_core:ceiling_light_1", {
    description = "Block",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_ceiling_light_1.png" },
    sounds = br_sounds.default(),
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
minetest.register_node("br_core:ceiling_light_1_off", {
    description = "Block",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_ceiling_light_1.png^[multiply:#cfcecf" },
    sounds = br_sounds.default(),
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    light_source = 0,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
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
            -3/16, -8/16, -8/16,
             3/16, -5/16,  8/16,
        },
    },
}
minetest.register_node("br_core:ceiling_light_2", {
    description = "br_core:ceiling_light_2",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_ceiling_light_1.png" },
    sounds = br_sounds.default(),
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
minetest.register_node("br_core:ceiling_light_2_off", {
    description = "br_core:ceiling_light_2_off",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_ceiling_light_1.png^[multiply:#cfcecf" },
    sounds = br_sounds.default(),
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    -- light_source = 0,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
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
    description = "br_core:ceiling_light_3",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_ceiling_light_1.png" },
    sounds = br_sounds.default(),
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
    description = "br_core:ceiling_light_3_off",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_ceiling_light_1.png^[multiply:#cfcecf" },
    sounds = br_sounds.default(),
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    -- light_source = 0,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})

-- skirting boards
minetest.register_node("br_core:skirting_0", {
    description = "Block",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
    tiles = {{
        name = "br_meta_blank.png^[colorize:#99a:255^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)",
        align_style = "world",
        scale = 16,
    }},
    drawtype = "nodebox",
    sounds = br_sounds.default(),
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
    light_source = (br_core.fullbright) or 0,
})

minetest.register_node("br_core:skirting_1", {
    description = "Block",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
    tiles = {{
        name = "br_meta_blank.png^[colorize:#556:255^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)",
        align_style = "world",
        scale = 16,
    }},
    drawtype = "nodebox",
    sounds = br_sounds.default(),
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
    light_source = (br_core.fullbright) or 0,
})

local function place_door_handle(pos, placer, itemstack, pointed_thing)
    local pi = player_info.get(placer)
    if pi and pi.ctrl.aux1 then
        local node = minetest.get_node(pos)
        node.name = node.name.."_outer"
        minetest.swap_node(pos, node)
    end
end
-- door handle

local function register_door_handle(name, box)
    local handle = {
        description = "br_core:door_handle_0",
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 0, dig_immediate = (br_core.dev_mode and 3) or 0 },
        tiles = {{
            name = "br_meta_blank.png^[colorize:#eef:255^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)",
            align_style = "world",
            scale = 16,
        }},
        drawtype = "nodebox",
        sounds = br_sounds.default(),
        node_box = nodebox,
        selection_box = {
            type = "fixed",
            fixed = {{
                -4/16, -16/16, -4/16,
                 4/16,  -6/16,  4/16,
            }}},
        paramtype2 = "facedir",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        on_place = function(itemstack, placer, pointed_thing)
            return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
        end,
    }
    -- make inner
    handle.node_box = box
    handle.drop = name
    handle.after_place_node = nil
    minetest.register_node(name.."_outer", table.copy(handle))
    local offset = -8/16 -- pushes the handle back so it matches up with a half slab, which is applied to the two y vals below
    for i, nb in pairs(box.fixed) do
        nb[2] = nb[2] + offset
        nb[5] = nb[5] + offset
    end
    handle.after_place_node = place_door_handle
    minetest.register_node(name, handle) -- don't need copy because it's the last one
end

register_door_handle("br_core:door_handle_0", {
    type = "fixed",
    fixed = {
        {
            -2/16, (-8)/16, -2/16,
             2/16, (-6)/16,  2/16,
        },
    },
})

register_door_handle("br_core:door_handle_1", {
    type = "fixed",
    fixed = {
        {
            (-1-5)/16, (-8)/16, -1/16,
            ( 1-5)/16, (-7)/16,  1/16,
        },
        {
            (-1+5)/16, (-8)/16, -1/16,
            ( 1+5)/16, (-7)/16,  1/16,
        },
        {
            -6/16, (-7)/16, -1/16,
             6/16, (-6)/16,  1/16,
        },
    },
})


minetest.register_node("br_core:invis_light_14", {
    description = "br_core:invis_light_14",
    pointable = br_core.dev_mode or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = {"blank.png" },
    use_texture_alpha = "clip",
    sounds = br_sounds.default(),
    paramtype = "light",
    light_source = 14,
    walkable = false,
})

minetest.register_node("br_core:invis_light_8", {
    description = "br_core:invis_light_8",
    pointable = br_core.dev_mode or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = {"blank.png" },
    use_texture_alpha = "clip",
    sounds = br_sounds.default(),
    paramtype = "light",
    light_source = 8,
    walkable = false,
})

local function world_align_textures(tiles)
    for i, t in pairs(tiles) do
        tiles[i] = {
            name = t,
            align_style = "world",
        }
    end
    return tiles
end