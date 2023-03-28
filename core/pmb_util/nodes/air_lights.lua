

local delme = function(p)
    local node = minetest.get_node(p)
    if minetest.get_item_group(node.name, "pmb_util_transient_light") > 0 then
        minetest.set_node(p, {name = "air"})
    end
end

for i = 1, 14 do
    minetest.register_node("pmb_util:light_node_"..i, {
        description = "Light",
        groups = { pmb_util_transient_light = i, },
        paramtype = 'light',
        drawtype = "airlike",
        floodable = true,
        pointable = false,
        walkable = false,
        buildable_to = true,
        drop = "",
        light_source = i,
        on_timer = delme,
        on_construct = function(pos)
            minetest.get_node_timer(pos):start(5)
        end
    })
end