

minetest.register_node('nabm_liquids:water_source', {
    description = 'Water Source',
    groups = { water_source = 1, liquid = 1, water = 1, flowing = 0,},

    tiles = { {
        name = 'default_water.png^[opacity:190',
        backface_culling = false,
    } },
    use_texture_alpha = 'blend',
    drawtype = 'liquid',
    paramtype = 'light',
    waving = 3,

    walkable = false,
    liquid_move_physics = true,
    move_resistance = 1,
    pointable = false,
    diggable = false,
    buildable_to = true,
    liquidtype = "source",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 8,
    liquid_alternative_source = "nabm_liquids:water_source",
    liquid_alternative_flowing = "nabm_liquids:water_flowing",
    --_on_node_update = pmb_fluid_api.flow_maybe(0.5)
  })

  minetest.register_node('nabm_liquids:water_flowing', {
    description = 'Water Flowing',
    groups = { water_flowing = 1, liquid = 1, water = 1, flowing = 1},

    special_tiles = {
    {
        name = 'default_water.png^[opacity:190',
        backface_culling = false,
    },
    {
        name = 'default_water.png^[opacity:190',
        backface_culling = true,
    }
    },
    tiles = {'default_water.png^[opacity:190'},
    use_texture_alpha = 'blend',
    drawtype = "flowingliquid",

    paramtype = 'light',
    paramtype2 = "flowingliquid",
    waving = 3,

    walkable = false,
    liquid_move_physics = true,
    move_resistance = 1,
    pointable = false,
    diggable = false,
    buildable_to = true,
    liquidtype = "flowing",
    liquid_viscosity = 0,
    liquid_renewable = false,
    liquid_range = 8,
    liquid_alternative_source = "nabm_liquids:water_source",
    liquid_alternative_flowing = "nabm_liquids:water_flowing",
  })
