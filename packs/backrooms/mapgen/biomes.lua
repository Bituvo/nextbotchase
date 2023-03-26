local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

local function sch(name)
    return mod_path .. DIR_DELIM .. "schematics" .. DIR_DELIM .. name .. ".mts"
end

br_core.register_level({
    level = 0,
    desc = "Level 0",
    danger = 1,
    grace_dist = 5,
    biome = {},
    segsize = 20,
    base_height = 28,
    biome_roughness = 195,
    biome_pixelization = 4,
    sky = {
        clouds = false,
        base_color = "#001",
        type = "plain"
    },
})

br_core.register_biome({
    level = 0,
    desc = "Level 0 columns",
    danger = 1,
    on_generate = nil,
    segheight = 20,
    can_generate = function(pos) -- must be deterministic
        if vector.distance(pos, vector.new(0, pos.y, 0)) > 10
        and vector.distance(pos, vector.new(0, pos.y, 0)) < 30 then
            return false
        else
            return true
        end
    end,
    schems = {
        {name=sch("0_20_1_columns_0"), vertical_segments={1,0}},
        {name=sch("0_20_2_columns_0"), vertical_segments={0,1}, rotation="0"},
    }
})
br_core.register_biome({
    level = 0,
    desc = "Level 0 main",
    danger = 1,
    on_generate = nil,
    segheight = 20,
    prevalence = 5,
    schems = {
        {name=sch("0_20_1_columns_0"), vertical_segments={1,0}},
        --
        {name=sch("0_20_2_columns_0"), vertical_segments={0,1}, rotation="0"},

        {name=sch("0_20_2_walls_0"), vertical_segments={0,1}},
        {name=sch("0_20_2_walls_1"), vertical_segments={0,1}},
        {name=sch("0_20_2_walls_2"), vertical_segments={0,1}},
        {name=sch("0_20_2_walls_3"), vertical_segments={0,1}},
    }
})
br_core.register_biome({
    level = 0,
    desc = "Level 0 concrete",
    danger = 1,
    on_generate = nil,
    segheight = 20,
    prevalence = 1,
    can_generate = function(pos) -- must be deterministic
        if vector.distance(pos, vector.new(0, pos.y, 0)) > 30 then
            return true
        else
            return false
        end
    end,
    schems = {
        {name=sch("0_20_1_columns_0"), vertical_segments={1,0}},
        --
        {name=sch("0_20_2_walls_concrete_0"), vertical_segments={0,1}, prevalence=9},
        {name=sch("0_20_2_walls_concrete_1"), vertical_segments={0,1}, prevalence=5},
    }
})
br_core.register_biome({
    level = 0,
    desc = "Level 0 nolight",
    danger = 1,
    on_generate = nil,
    segheight = 20,
    prevalence = 2,
    schems = {
        {name=sch("0_20_1_columns_0"), vertical_segments={1,0}},
        --
        {name=sch("0_20_2_nolight_walls_0"), vertical_segments={0,1}, prevalence=3},
        {name=sch("0_20_2_nolight_walls_1"), vertical_segments={0,1}, prevalence=3},
        {name=sch("0_20_2_nolight_walls_2"), vertical_segments={0,1}, prevalence=3},
        {name=sch("0_20_2_nolight_columns_0"), vertical_segments={0,1}, prevalence=2},
    }
})
br_core.register_biome({
    level = 0,
    desc = "Level 0 dark",
    danger = 1,
    on_generate = nil,
    segheight = 20,
    prevalence = 1,
    can_generate = function(pos) -- must be deterministic
        if vector.distance(pos, vector.new(0, pos.y, 0)) > 30 then
            return true
        else
            return false
        end
    end,
    schems = {
        {name=sch("0_20_1_columns_0"), vertical_segments={1,0}},
        --
        {name=sch("0_20_2_dark_0"), vertical_segments={0,1}, prevalence=8},
        {name=sch("0_20_2_dark_walls_0"), vertical_segments={0,1}, prevalence=8},
        {name=sch("0_20_2_dark_walls_1"), vertical_segments={0,1}, prevalence=8},
        --
        {name=sch("0_20_2_dark_walls_2"), vertical_segments={0,1}, prevalence=4},
    }
})