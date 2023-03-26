

nabm_biomes.registered_biomes = {}
nabm_biomes.biome_group = {}
nabm_biomes.all_biomes = {}

function nabm_biomes.register_biome(biome, groups)
    -- if this is the first time a group was added, make room for that in the table
    -- actually register the biome in minetest
    minetest.register_biome(biome)
    -- add the biome to a list for access later
    nabm_biomes.registered_biomes[biome.name] = biome
    nabm_biomes.all_biomes[#nabm_biomes.all_biomes + 1] = biome.name
    -- add it to groups so you can use the groups for adding structures and so on later
    minetest.register_biome(biome)
    for _, group in pairs(groups) do
        -- make sure it has the group listed so it's not indexing nil
        if nabm_biomes.biome_group[group] == nil then
            nabm_biomes.biome_group[group] = {} end
        -- add the biome name to the list
        nabm_biomes.biome_group[group][#nabm_biomes.biome_group[group]+1] = biome.name
    end
end
