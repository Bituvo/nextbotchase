
local vmax = 0
local vmin = -20

for i = 0, 0 do
minetest.register_ore({
    ore_type       = "stratum",
    ore            = "nabm_stone:stone",
    wherein        = {"air", "group:liquid"},
    y_min = 0-i*1,
    y_max = 0-i*1,
})
end

minetest.register_ore({
    ore_type       = "stratum",
    ore            = "nl_fog:fog_0",
    wherein        = {"air", "group:liquid"},
    y_min = -1,
    y_max = -1,
})
