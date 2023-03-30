local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)

br_core.level = {}
br_core.level_for_index = {}

function br_core.register_level(p)
    if p.level > 180 then error("CANNOT REGISTER LEVEL "..p.level.." AS IT WOULD EXCEED HEIGHT LIMIT") end
    if not p.biome_names then p.biome_names = {} end
    p.index = #br_core.level_for_index+1
    br_core.level[p.level] = p
    br_core.level_for_index[#br_core.level_for_index+1] = p.level
end
local biome_id_count = 0

function br_core.register_biome(p)
    biome_id_count = biome_id_count + 1
    p.uid = biome_id_count
    p.vert_schems = {}
    p.segheight = p.segheight or 80
    for i, schem in pairs(p.schems) do
        local all_layers = false
        if not schem.vertical_segments then
            schem.vertical_segments = {}
            all_layers = true
        end
        for k=0, math.floor(br_core.chunk_width / p.segheight) + 1 do
            if not p.vert_schems[k] then p.vert_schems[k] = {} end
            if all_layers or schem.vertical_segments[k] == 1 then
                for l=1, schem.prevalence or 1 do
                    p.vert_schems[k][#p.vert_schems[k]+1] = p.schems[i]
                end
            end
        end
    end
    if not br_core.level[p.level].biome then br_core.level[p.level].biome = {} end
    -- make a pointer to the biome so you can reference it by name
    if p.name and not br_core.level[p.level].biome_names[p.name] then
        br_core.level[p.level].biome_names[p.name] = {def=p, index=#br_core.level[p.level].biome+1}
    end
    for i=1, p.prevalence or 1 do
        br_core.level[p.level].biome[#br_core.level[p.level].biome+1] = p
    end
end
function br_core.index_to_level(index)
    return br_core.level_for_index[index]
end

function br_core.sort_levels()
    table.sort(br_core.level_for_index, function(a, b) return a < b end)
    for i, level in pairs(br_core.level_for_index) do
        br_core.level[level].index = i
    end
end


minetest.register_on_mods_loaded(function()
    minetest.register_ore({
        ore_type       = "stratum",
        ore            = "air",
        wherein        = {"group:clear_after_mapgen"},
        y_min = -180 * br_core.level_height - br_core.offset,
        y_max =  180 * br_core.level_height - br_core.offset + br_core.level_height - 1,
    })
end)