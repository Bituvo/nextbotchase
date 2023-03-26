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

-- not actually white, but close
minetest.register_node('br_core:white', {
    description = 'br_core:white',
    pointable = br_core.nodes_pointable or false,
    groups = { oddly_breakable_by_hand = 2 },
    tiles = { '(br_white.png)'..(br_core.dev_mode and '^(br_barrier.png^[colorize:#aaa:255)' or "")},
    sunlight_propagates = true,
    sounds = br_sounds.carpet(),
    paramtype = "light",
    light_source = 14,
}) pmb_util.register_slab("br_core:white")
minetest.register_node('br_core:black', {
    description = 'br_core:black',
    pointable = br_core.nodes_pointable or false,
    groups = { oddly_breakable_by_hand = 2 },
    tiles = { '(br_white.png^[colorize:#000:255)'..(br_core.dev_mode and '^(br_barrier.png^[colorize:#aaa:255)' or "")},
    sunlight_propagates = false,
    sounds = br_sounds.carpet(),
    paramtype = "light",
}) pmb_util.register_slab("br_core:black")


minetest.register_node('br_core:barrier', {
    description = 'barrier',
    pointable = br_core.nodes_pointable or false,
    groups = { oddly_breakable_by_hand = 2 },
    drawtype = (br_core.dev_mode and "glasslike") or "airlike",
    tiles = { (br_core.dev_mode and 'br_barrier.png') or "blank.png" },
    use_texture_alpha = "clip",
    sunlight_propagates = true,
    paramtype = "light",
}) pmb_util.register_slab("br_core:barrier")

minetest.register_node('br_core:light_diffuse', {
    description = 'barrier',
    pointable = br_core.dev_mode or false,
    groups = { oddly_breakable_by_hand = 2 },
    drawtype = (br_core.dev_mode and "glasslike") or "airlike",
    tiles = { 'br_barrier.png^[colorize:#339:255' },
    use_texture_alpha = "clip",
    walkable = false,
    paramtype = "light",
})
minetest.register_node('br_core:fog_blue', {
    description = 'br_core:fog_blue',
    pointable = br_core.nodes_pointable or false,
    groups = { oddly_breakable_by_hand = 2 },
    drawtype = "liquid",
    tiles = {
        {name='(br_meta_blank.png^[colorize:#3383a6:255'..
        "^(br_meta_overlay_dirt_2.png^[colorize:#ffffff03:255))^[opacity:220", backface_culling=true, align_style="world", scale=16},
        {name='br_meta_blank.png^[colorize:#33b3f6e0:255', backface_culling=true, align_style="world", scale=16},
        {name='blank.png^[colorize:#33436600:255', backface_culling=true},
    },
    use_texture_alpha = "blend",
    sunlight_propagates = true,
    paramtype = "light",
}) pmb_util.register_slab("br_core:fog_blue")

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

    minetest.register_node("br_core:wallpaper_"..variant.."_1", {
        description = "br_core:wallpaper_"..variant.."_1",
        _name_format = "br_core:wallpaper_".."[variant]".."_1",
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = {{
            name = "br_meta_blank.png^[colorize:"..(color.main)..":255"..
            "^(br_meta_overlay_wallpaper_1.png^[multiply:"..(color.highlight)..")"..
            "^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)",
            align_style = "world",
            scale = 16,
        }},
        sounds = br_sounds.carpet(),
        light_source = (br_core.fullbright) or 0,
    }) pmb_util.register_all_shapes("br_core:wallpaper_"..variant.."_1")
    add_overlay_variant("br_core:wallpaper_"..variant.."_1",
        "((br_skirting_board_0.png^[multiply:"..color.alt..")^(br_meta_overlay_dirt_1.png^[multiply:#334^[opacity:10"..
        "^[mask:(br_skirting_board_0.png)))", "skirting", {})
    minetest.register_craft({
        output = "br_core:wallpaper_"..variant.."_1".."_".."skirting",
        recipe = {
            {"br_core:wallpaper_"..variant.."_1"},
        }
    })

    minetest.register_node("br_core:wallpaper_"..variant.."_2", {
        description = "br_core:wallpaper_"..variant.."_2",
        _name_format = "br_core:wallpaper_".."[variant]".."_2",
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = {{
            name = "br_meta_blank.png^[colorize:"..(color.main)..":255"..
            "^(br_meta_overlay_wallpaper_2.png^[multiply:"..(color.lowlight)..")"..
            "^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)",
            align_style = "world",
            scale = 16,
        }},
        sounds = br_sounds.carpet(),
        light_source = (br_core.fullbright) or 0,
    }) pmb_util.register_all_shapes("br_core:wallpaper_"..variant.."_2")
    add_overlay_variant("br_core:wallpaper_"..variant.."_2",
        "((br_skirting_board_0.png^[multiply:"..color.alt..")^(br_meta_overlay_dirt_1.png^[multiply:#334^[opacity:10"..
        "^[mask:(br_skirting_board_0.png)))", "skirting", {})
    minetest.register_craft({
        output = "br_core:wallpaper_"..variant.."_2".."_".."skirting",
        recipe = {
            {"br_core:wallpaper_"..variant.."_2"},
        }
    })

    minetest.register_node("br_core:carpet_"..variant.."_1", {
        description = "br_core:carpet_"..variant.."_1",
        _name_format = "br_core:carpet_".."[variant]".."_1",
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = {{
            name = "br_meta_blank.png^[colorize:"..(color.main)..":255"..
            "^(br_meta_overlay_carpet_1.png^[multiply:"..("#112").."^[opacity:6)"..
            "^(br_meta_overlay_carpet_1.png^[multiply:"..(color.outline).."^[opacity:30^[transformR90)",
            align_style = "world",
            scale = 16,
        }},
        sounds = br_sounds.carpet(),
        light_source = (br_core.fullbright) or 0,
    }) pmb_util.register_all_shapes("br_core:carpet_"..variant.."_1")

    minetest.register_node("br_core:concrete_"..variant.."_ls", {
        description = "br_core:concrete_"..variant,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = shader_unfck(
            "br_meta_blank.png^[colorize:"..(color.main)..":255^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)"),
        sounds = br_sounds.concrete(),
        light_source = 1,
    }) pmb_util.register_all_shapes("br_core:concrete_"..variant.."_ls")

    minetest.register_node("br_core:concrete_dirty_"..variant, {
        description = "br_core:concrete_dirty_"..variant,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = {{
            name = "br_meta_blank.png^[colorize:"..(color.main)..":255^(br_meta_overlay_dirt_3.png^[multiply:#223^[opacity:50)",
            align_style = "world",
            scale = 16,
        }},
        sounds = br_sounds.concrete(),
        light_source = (br_core.fullbright) or 0,
    }) pmb_util.register_all_shapes("br_core:concrete_dirty_"..variant)
    add_overlay_variant("br_core:concrete_dirty_"..variant,
        "(br_skirting_board_0.png^(br_meta_overlay_dirt_1.png^[multiply:#334^[opacity:70))", "skirting", {})

    minetest.register_node("br_core:concrete_ruined_"..variant, {
        description = "br_core:concrete_ruined_"..variant,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = {{
            name = "br_meta_blank.png^[colorize:"..(color.main)..":255"..
            "^(br_meta_overlay_holes_0.png^[multiply:"..(color.raw)..")"..
            "^(br_meta_overlay_dirt_3.png^[multiply:#223^[opacity:50)"..
            "^(br_meta_overlay_rebar_0.png^[opacity:90)",
            align_style = "world",
            scale = 16,
        }},
        sounds = br_sounds.concrete(),
        light_source = (br_core.fullbright) or 0,
    }) pmb_util.register_all_shapes("br_core:concrete_ruined_"..variant)

    minetest.register_node("br_core:ceiling_conduit_"..variant, {
        description = "br_core:ceiling_conduit_"..variant,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = {{
            name = "(br_meta_blank.png^[colorize:"..(color.main)..":255"..
            "^(br_meta_overlay_dirt_3.png^[multiply:#223^[opacity:50))"..
            "^(br_meta_overlay_crisscross_0.png^[multiply:"..color.outline.."".."^[opacity:80)"..
            "^(br_meta_overlay_crisscross_1.png^[multiply:"..color.outline.."".."^[opacity:255)",
            align_style = "world",
            scale = 16,
        }},
        sounds = br_sounds.default(),
        light_source = (br_core.fullbright) or 0,
    }) pmb_util.register_all_shapes("br_core:ceiling_conduit_"..variant)

    minetest.register_node("br_core:ceiling_tiles_"..variant, {
        description = "br_core:ceiling_tiles_"..variant,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = shader_unfck(
            "br_meta_blank.png^[colorize:"..(color.main)..":255"..
            "^(br_meta_overlay_crisscross_2.png^[multiply:"..color.outline.."^[opacity:100)"..
            "^(br_meta_overlay_dirt_3.png^[multiply:#112^[opacity:10)"),
        sounds = br_sounds.default(),
        light_source = 1,
    })

    local nodebox = {
        type = "fixed",
        fixed = {
            {
                (-4)/16, (-8)/16, (-4)/16,
                ( 4)/16, ( 8)/16, ( 4)/16,
            },
            {
                (-4)/16, (-4)/16, ( 4)/16,
                ( 4)/16, ( 4)/16, ( 8)/16,
            },
        },
    }
    local pipe = {
        description = "br_core:pipe_connector_"..variant,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, dig_immediate = (br_core.dev_mode and 3) or 0, pipe = 1, },
        tiles = shader_unfck("br_meta_blank.png^[colorize:"..(color.main)..":255"..
            "^(br_meta_overlay_dirt_3.png^[multiply:#112^[opacity:10)"),
        drawtype = "nodebox",
        sounds = br_sounds.default(),
        node_box = nodebox,
        selection_box = nodebox,
        connects_to = { "group:pipe" },
        paramtype2 = "facedir",
        paramtype = "light",
        sunlight_propagates = true,
        on_place = function(itemstack, placer, pointed_thing)
            return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
        end,
        light_source = (br_core.fullbright) or 0,
    }
    minetest.register_node("br_core:pipe_connector_"..variant, pipe)

    -- pipe connected
    pipe = table.copy(pipe)
    pipe.node_box = {
        type = "fixed",
        fixed = {
            {
                (-4)/16, (-12)/16, (-4)/16,
                ( 4)/16, (  8)/16, ( 4)/16,
            },
        },
    }
    pipe.selection_box = pipe.node_box
end

minetest.register_alias("br_core:ceiling_tiles_0", "br_core:ceiling_tiles_yellow")


local sign_box = {
    type = "fixed",
    fixed = {
        {
            (-4)/16, (-8)/16, (-1)/16,
            ( 4)/16, (-6)/16, ( 1)/16,
        },
        {
            (-7)/16, (-6)/16, (-2)/16,
            ( 7)/16, ( 3)/16, ( 2)/16,
        },
    },
}
minetest.register_node("br_core:sign_exit", {
    description = "br_core:sign_exit",
    pointable = br_core.nodes_pointable or false,
    groups = { dig_immediate = (br_core.dev_mode and 3) or 0 },
    drawtype = "nodebox",
    paramtype2 = "facedir",
    paramtype = "light",
    selection_box = sign_box,
    node_box = sign_box,
    sunlight_propagates = true,
    walkable = false,
    tiles = {
        { name = "br_sign_exit_side.png^[transformR180"},
        { name = "br_sign_exit_side.png^[transformR180"},
        { name = "br_sign_exit_side.png^[transformR180"},
        { name = "br_sign_exit_side.png^[transformR180"},
        { name = "br_sign_exit.png^[transformFY"},
        { name = "br_sign_exit.png^[transformR180"},
    },
    sounds = br_sounds.default(),
    light_source = 9,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})


local framebox = br_core.get_full_frame({inner=true, width=6/16, thickness=1/16, nobottom=true})
minetest.register_node("br_core:doorframe_0", {
    description = "br_core:doorframe_0",
    pointable = br_core.nodes_pointable or false,
    groups = { suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
    tiles = {{
        name = "br_meta_blank.png^[colorize:#99a:255^(br_meta_overlay_dirt_1.png^[multiply:#753^[opacity:10)",
        align_style = "world",
        scale = 16,
    }},
    drawtype = "nodebox",
    connects_to = { "group:full_solid" },
    node_box = framebox,
    sounds = br_sounds.default(),
    light_source = (br_core.fullbright) or 0,
})

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
            -1/16, -7/16, -8/16,
             1/16, -6/16,  8/16,
        },
        {
            -2/16, -8/16, -8/16,
             2/16, -7/16,  8/16,
        },
    },
}
minetest.register_node("br_core:emergency_light_0", {
    description = "Block",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = {
        "br_emergency_light_0.png",
        "br_emergency_light_0.png",
        "br_emergency_light_0_side.png",
    },
    sounds = br_sounds.default(),
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    paramtype = "light",
    light_source = 8,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})
minetest.register_node("br_core:emergency_light_off", {
    description = "Block",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_emergency_light_0.png" },
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
            -4/16, -8/16, -4/16,
             4/16, -4/16,  4/16,
        },
    },
}
nodebox = {
    type = "fixed",
    fixed = {
        {
            -2/16, -8/16, -2/16,
             2/16, -7.5/16,  2/16,
        },
    },
}
minetest.register_node("br_core:emergency_light_1", {
    description = "Block",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = {
        "br_ceiling_light_1.png",
    },
    sounds = br_sounds.default(),
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    paramtype = "light",
    light_source = 10,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})
minetest.register_node("br_core:emergency_light_1_off", {
    description = "Block",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = (debug and "airlike") or "nodebox",
    tiles = { "br_ceiling_light_1.png^[multiply:#cfcecf" },
    sounds = br_sounds.default(),
    node_box = nodebox,
    selection_box = selectionbox,
    paramtype2 = "facedir",
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})


local flat_box = {
    type = "fixed",
    fixed = {
        {
            (-8)/16, (-7.9)/16, (-8)/16,
            ( 8)/16, (-7.8)/16, ( 8)/16,
        },
    },
}
minetest.register_node("br_core:sign_x", {
    description = "br_core:sign_x",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = "nodebox",
    tiles = {
        "br_sign_x.png^[transformR90",
    },
    use_texture_alpha = "clip",
    sounds = br_sounds.default(),
    node_box = flat_box,
    selection_box = flat_box,
    paramtype2 = "facedir",
    paramtype = "light",
    light_source = 1,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})
minetest.register_node("br_core:sign_exclaim", {
    description = "br_core:sign_exclaim",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = "nodebox",
    tiles = {
        "br_sign_exclaim.png^[transformR90",
    },
    use_texture_alpha = "clip",
    sounds = br_sounds.default(),
    node_box = flat_box,
    selection_box = flat_box,
    paramtype2 = "facedir",
    paramtype = "light",
    light_source = 1,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})
minetest.register_node("br_core:sign_phone", {
    description = "br_core:sign_phone",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = "nodebox",
    tiles = {
        "br_sign_phone.png^[transformR90",
    },
    use_texture_alpha = "clip",
    sounds = br_sounds.default(),
    node_box = flat_box,
    selection_box = flat_box,
    paramtype2 = "facedir",
    paramtype = "light",
    light_source = 1,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})
minetest.register_node("br_core:sign_no_entry", {
    description = "br_core:sign_no_entry",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = "nodebox",
    tiles = {
        "br_sign_no_entry.png^[transformR90",
    },
    use_texture_alpha = "clip",
    sounds = br_sounds.default(),
    node_box = flat_box,
    selection_box = flat_box,
    paramtype2 = "facedir",
    paramtype = "light",
    light_source = 1,
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})
for i=0, 1 do
    minetest.register_node("br_core:sign_various_"..i, {
        description = "br_core:sign_various_"..i,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
        drawtype = "nodebox",
        tiles = {
            "br_sign_various_"..i..".png^[transformR90",
        },
        use_texture_alpha = "clip",
        sounds = br_sounds.default(),
        node_box = flat_box,
        selection_box = flat_box,
        paramtype2 = "facedir",
        paramtype = "light",
        light_source = 1,
        walkable = false,
        on_place = function(itemstack, placer, pointed_thing)
            return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
        end,
    })
end

local alarm_box = {
    type = "fixed",
    fixed = {
        {
            ( 0)/16, (-8)/16, (-2)/16,
            ( 6)/16, (-5)/16, ( 2)/16,
        },
    },
}
minetest.register_node("br_core:fire_alarm", {
    description = "br_core:fire_alarm",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = "nodebox",
    tiles = {
        "br_fire_alarm.png^[transformR90",
        "br_fire_alarm.png^[transformR90",
        "br_fire_alarm.png^[transformR180", -- bottom
        "br_fire_alarm.png^[transformR180", -- top
        "br_fire_alarm.png^[transformR270", -- right
        "br_fire_alarm.png^[transformR90",
    },
    use_texture_alpha = "opaque",
    sounds = br_sounds.default(),
    node_box = alarm_box,
    selection_box = alarm_box,
    paramtype2 = "facedir",
    paramtype = "light",
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})
local socket_box = {
    type = "fixed",
    fixed = {
        {
            (-4)/16, (-8)/16, (-4)/16,
            ( 0)/16, (-7)/16, ( 4)/16,
        },
    },
}
minetest.register_node("br_core:power_socket", {
    description = "br_core:power_socket",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1, dig_immediate = (br_core.dev_mode and 3) or 0, },
    drawtype = "nodebox",
    tiles = {
        "br_power_socket.png^[transformR90",
        "br_power_socket.png^[transformR90",
        "br_power_socket.png^[transformR180", -- bottom
        "br_power_socket.png^[transformR180", -- top
        "br_power_socket.png^[transformR270", -- right
        "br_power_socket.png^[transformR90",
    },
    use_texture_alpha = "opaque",
    sounds = br_sounds.default(),
    node_box = socket_box,
    selection_box = socket_box,
    paramtype2 = "facedir",
    paramtype = "light",
    walkable = false,
    on_place = function(itemstack, placer, pointed_thing)
        return minetest.rotate_and_place(itemstack, placer, pointed_thing, nil, {})
    end,
})

minetest.register_node("br_core:duct_0", {
    description = "br_core:duct_0",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
    tiles = { "br_".."duct_0.png" },
    sounds = br_sounds.concrete(),
    light_source = (br_core.fullbright) or 0,
}) pmb_util.register_all_shapes("br_core:duct_0")


selectionbox = {
    type = "fixed",
    fixed = {
        {
            -8/16, -8/16,  8/16,
             8/16,  0/16,  0/16,
        },
    },
}
nodebox = {
    type = "fixed",
    fixed = {
        {
            -8/16, -8/16,  8/16,
             8/16, -4/16,  7/16,
        },
    },
}
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



selectionbox = {
    type = "fixed",
    fixed = {
        {
            -8/16, -8/16,  -8/16,
             8/16, -4/16,  8/16,
        },
    },
}
-- ladders
minetest.register_node("br_core:ladder_steel_0", {
    description = "Block",
    pointable = br_core.nodes_pointable or false,
    groups = { solid = 0, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
    tiles = {{
        name = "br_ladder_steel_0.png",
        align_style = "world",
        scale = 16,
    }},
    use_texture_alpha = "clip",
    drawtype = "signlike",
    sounds = br_sounds.default(),
    selection_box = selectionbox,
    climbable = true,
    paramtype2 = "wallmounted",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
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
    tiles = { (br_core.dev_mode and 'br_barrier.png^[colorize:#ff0:255') or "blank.png" },
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
    tiles = { (br_core.dev_mode and 'br_barrier.png^[colorize:#aa0:255') or "blank.png" },
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
for i=0, 2 do
    minetest.register_node("br_core:pool_tiles_"..i, {
        description = "br_core:pool_tiles_"..i,
        pointable = br_core.nodes_pointable or false,
        groups = { solid = 1, full_solid = 1, suffocates = 2, oddly_breakable_by_hand = 2, cracky = 1 },
        tiles = world_align_textures({
            "br_tiles_"..i..".png", -- top
        }),
        sounds = br_sounds.tile(),
        light_source = (br_core.fullbright) or 0,
    }) pmb_util.register_all_shapes("br_core:pool_tiles_"..i)
end