-- Properties that all nextbots share
local common_nextbot_definition = {
	initial_properties = {
		physical = false,
		show_on_minimap = true,
		use_texture_alpha = true,
		static_save = false,
		selectionbox = {}
	},

	_dtime = 0,
	_chase_time = 0,
	_chasing = false,
	_steps = 0,
	_path = {},

	_id = 0,
	_fixed_y_position = 0,
	_target = nil,

	_formal_name = "",
	_technical_name = "",
	_speed = 0,

	_sound_handle = nil,
	
	_on_reach_target = nil,
	_stay_unstuck = nil
}

-- Nextbot definition factory
local function get_new_nextbot_definition(name, formal_name, speed, size)
	local new_nextbot_definition = table.copy(common_nextbot_definition)
	
	new_nextbot_definition.initial_properties.textures = {name .. ".png"}
	new_nextbot_definition.initial_properties.visual_size = {x = size, y = size}
	new_nextbot_definition.initial_properties.selectionbox = {
		-0.75, size / -2 + 0.5, -0.75,
		0.75, size / 2 - 0.5, 0.75
	}
	new_nextbot_definition._formal_name = formal_name
	new_nextbot_definition._technical_name = name
	new_nextbot_definition._speed = speed

	return new_nextbot_definition
end

function nextbots.register_nextbot(technical_name, formal_name, speed, size, probability)
	nextbots.registered_nextbots[technical_name] = {
		formal_name = formal_name,
		speed = speed,
		size = size,
		probability = probability
	}

	local new_nextbot_definition = get_new_nextbot_definition(technical_name, formal_name, speed, size)
	minetest.register_entity("nextbots:" .. technical_name, new_nextbot_definition)

	minetest.log("action", "Nextbots: registered " .. formal_name .. " as " .. technical_name)
end

-- In order of appearance
-- Technical name, formal name, steps/second, size (nodes), probability
nextbots.register_nextbot("obunga",    "Obunga", 			   20, 5, 5)
nextbots.register_nextbot("selene",    "Selene Delgado López", 22, 4, 3)
nextbots.register_nextbot("thisman",   "This Man",			   22, 5, 2)
nextbots.register_nextbot("alternate", "Alternate",            20, 4, 4)
nextbots.register_nextbot("pinhead",   "Pinhead",              23, 4, 1)
nextbots.register_nextbot("munci",     "Munci",                21, 5, 2)