local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)

-------------------------------
--------- DECORATIONS ---------
-------------------------------

local perlin = {}
local function register_noise(p)
    perlin[p.name] = p
end

local cid = {}
local nam = {}
local air = nil

minetest.register_on_mods_loaded(function()
    local on_gen_list = br_core.get_on_generate_node_list()
    for node_name, list in pairs(on_gen_list) do
        local contentid = minetest.get_content_id(node_name)
        cid[node_name] = contentid
        nam[contentid] = node_name
    end
    air = minetest.get_content_id("air")
end)

register_noise({
    name = "variant",
    np = {
        offset = 0.5,
        scale = 0.5,
        spread = {x = 1, y = 1, z = 1},
        seed = 678567 + minetest.get_mapgen_setting("seed"),
        octaves = 1,
        persist = 0.1,
        lacunarity = 2.0,
    },
    perlin = nil,
    data = {},
})
register_noise({
    name = "biome",
    np = {
        offset = 0.5,
        scale = 0.5,
        spread = {x = 80, y = 80, z = 80},
        seed = 87602 + minetest.get_mapgen_setting("seed"),
        octaves = 1,
        persist = 0,
        lacunarity = 2.0,
    },
    perlin = nil,
    data = {},
})

local rotations = {
    "0", "90", "180", "270"
}

local function level_from_vm(minp)
    local level = math.floor((minp.y + br_core.offset) / br_core.level_height)
    if br_core.level[level]then
        return level, math.floor((minp.y + br_core.offset) / br_core.chunk_width) - level * (br_core.level_height / br_core.chunk_width)
    end
end


if br_core.mapgen == "flat" then
    minetest.register_ore({
        ore_type       = "stratum",
        ore            = "br_core:barrier",
        wherein        = {"air", "group:liquid"},
        y_min = -32,
        y_max = -32,
    })
end

local function to_grid(n, seg)
    seg = seg or br_core.chunk_width
    return math.floor((n+16)/seg)
end

function br_core.generators.main(minp, maxp)
    local level, level_chunk = level_from_vm(minp)
    local level_def = br_core.level[level]
    if (not br_core.level[level])
    or ((level_chunk ~= 0) and (not level_def.level_height))
    or (level_def.level_height and (level_def.level_height < level_chunk * br_core.chunk_width)) then return end
    local segsize = br_core.level[level].segsize
    local chunk_width = br_core.chunk_width
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")

    local sidelen = math.floor((chunk_width/segsize))
    local permapdims3d = {x = sidelen + 2, y = chunk_width + 2, z = sidelen + 2}

    -- get the perlin noise data
    for name, p in pairs(perlin) do
        p.perlin = ((p.sidelen == sidelen) and p.perlin) or minetest.get_perlin_map(p.np, permapdims3d)
        p.data3d = p.perlin:get_3d_map(vector.offset(vector.divide(minp, segsize), -1, -1, -1))
    end

    local biomes = br_core.level[level].biome

    local ni = 1
    for z = 1, sidelen do
        for x = 1, sidelen do
            local biome
            -- if the level has a generation algo, use it
            local on_generate_biome = level_def.on_generate and level_def.on_generate(vector.new(
                x + to_grid(minp.x, segsize),
                0,
                z + to_grid(minp.z, segsize)), perlin
            )
            if on_generate_biome then
                local index = br_core.level[level].biome_names[on_generate_biome].index
                biome = br_core.level[level].biome[index]
            end
            -- if you didn't get one, find one
            if not biome then
                -- get the biome for this horizontal segment location
                local zero_dist = math.sqrt((x + to_grid(minp.x, segsize)) ^ 2 + (z + to_grid(minp.z, segsize)) ^ 2)
                local biomeindex = 1
                if zero_dist > (level_def.grace_dist or 20)
                or (not biomes[biomeindex].can_generate)
                or not biomes[biomeindex].can_generate(vector.new(x + to_grid(minp.x, segsize), 0, z + to_grid(minp.z, segsize))) then
                    -- get a random biome from the list based on the noise
                    local pxfactor = level_def.biome_pixelization or 1
                    local nv = perlin.biome.data3d[math.ceil(z/pxfactor)*pxfactor+1][2][math.ceil(x/pxfactor)*pxfactor+1]
                    biomeindex = math.floor(nv * (level_def.biome_roughness or 37.239) * #biomes) % (#biomes) + 1
                    -- don't bother checking the same biome, skip duplicates
                    local last_biome = biomes[biomeindex].uid
                    -- check this biome can go here, and if not, cycle through until you find one that works
                    for i=0, #biomes - 1 do
                        local index = (biomeindex + i) % #biomes + 1
                        if (i==0) or last_biome ~= biomes[index].uid then
                            last_biome = biomes[index].uid
                            if ((not biomes[index].can_generate)
                            or biomes[index].can_generate(vector.new(x + to_grid(minp.x, segsize), 0, z + to_grid(minp.z, segsize))) == true) then
                                biomeindex = index
                                break -- when you find one, end the search
                            end
                        end
                    end
                end
                -- get the biome definition so we know stuff about the biome
                biome = br_core.level[level].biome[biomeindex]
            end
            ----------------------
            -- ACTUAL PLACEMENT --
            ----------------------
            local skips = 0 -- for 'multi storey' schems
            -- use y=2 instead of one because the perlin is offset
            local rotation = rotations[(math.floor(92801747 * perlin.variant.data3d[z+1][2][x+1]) % #rotations) + 1]
            for y = 1, math.ceil(chunk_width / biome.segheight) do
                if skips < 1 then
                    -- get a random variant based on the noise
                    local variant = math.floor(perlin.variant.data3d[z+1][y+1][x+1] * 1293678.421) % #biome.vert_schems[y] + 1
                    local schem = biome.vert_schems[y][variant]
                    -- get a new schem if this one shouldn't spawn here
                    if schem and schem.can_generate
                    and not schem.can_generate(vector.new(x + to_grid(minp.x, segsize), y, z + to_grid(minp.z, segsize))) then
                        for i=0, #biome.vert_schems[y] - 1 do
                            local index = (variant + i) % #biome.vert_schems[y] + 1
                            if biome.vert_schems[index] and ((not biome.vert_schems[index].can_generate)
                            or biome.vert_schems[index].can_generate(vector.new(
                            x + to_grid(minp.x, segsize),
                            y,
                            z + to_grid(minp.z, segsize))) == true) then
                                variant = index
                                schem = biome.vert_schems[y][variant]
                                break -- when you find one, end the search
                            end
                        end
                    end
                    -- now place the schematic
                    if schem then
                        if y == 1 then
                            rotation = (schem.rotation or schem.no_rotation and "0") or rotation
                        end
                        local y_offset = schem.y_offset or 0
                        local pos = vector.new((x-1)*segsize+minp.x, (y-1)*biome.segheight+minp.y + y_offset, (z-1)*segsize+minp.z)
                        local rot = schem.rotation or rotation
                        if schem.free_rotation then
                            rot = rotations[(math.floor(92801747 * perlin.variant.data3d[z+1][y+1][x+1]) % #rotations) + 1]
                        end
                        if not minetest.place_schematic_on_vmanip(vm, pos, schem.name, rot, nil, true, nil) then
                            minetest.log("warning", "ERROR NO FAILED TO PLACE SCHEMATIC WHEN GENERATING")
                        end
                    end
                    ni = ni + 1
                    if schem and schem.skip_above then
                        skips = (schem.skip_above)
                    end
                else
                    skips = skips - 1
                    ni = ni + 1
                end
            end
        end
    end
    -- vm:set_data(data)
    minetest.generate_decorations(vm, minp, maxp)
    minetest.generate_ores(vm, minp, maxp)

	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}

    local data = vm:get_data()
    for i in area:iterp(minp, maxp) do
        local pos = area:position(i)
        if nam[data[i]] then
            br_core.on_generate_node(nam[data[i]], pos)
        elseif data[i] == air and (pos.x%16 == 7) and (pos.y%16 == 7) and (pos.z%16 == 7) then
            minetest.set_node(pos, {name="br_core:null_node"})
        end
    end

    -- vm:set_data(data)

    vm:calc_lighting()
    vm:write_to_map()
    vm:update_liquids()
end
