

for i = 0, 8 do
    local color = (minetest.colorspec_to_colorstring and minetest.colorspec_to_colorstring({a=255, r=(20+i*10), g=(20+i*10), b=(30+i*10)})) or "#333"
    minetest.register_node('nl_fog:fog_'..i, {
        description = 'Foggy stuff',
        groups = { item_fog = 1, solid = 1, fog = 1, },
        tiles = { "nl_fog_base.png^[colorize:"..color.."^[opacity:"..(70 + i*20) },
        drawtype = "glasslike",
        sunlight_propagates = true,
        paramtype = "light",
        use_texture_alpha = "blend",
        sounds = {},
        pointable = false,
        drop = "",
        -- light_source = 1,
    })
end
