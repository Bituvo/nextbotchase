-- Properties that all nextbots share
local common_nextbot_definition = {
	initial_properties = {
		physical = false,
		show_on_minimap = true
	},

	dtime = 0,
	chasing = false,

	-- "But Ma, what happens when I get him?"
	on_reach_target = function(self)
		-- "Kill him and stop moving"
		self.chasing = false
		self.target:set_hp(0)
		self.object:set_velocity(vector.new())

		-- "Then kill yourself after a couple seconds" (stay mad)
		minetest.after(2, function() self.object:remove() end)
	end
}

-- Nextbot-definitionator factory constructor
local function get_new_nextbot_definition(name, formal_name, speed, size)
	local new_nextbot_definition = table.copy(common_nextbot_definition)
	
	new_nextbot_definition.initial_properties.textures = {name .. ".png"}
	new_nextbot_definition.initial_properties.visual_size = {x = size, y = size}
	new_nextbot_definition.formal_name = formal_name
	new_nextbot_definition.speed = speed

	return new_nextbot_definition
end

function nextbots.register_nextbot(name, formal_name, speed, size)
	nextbots.registered_nextbots[name] = {
		formal_name = formal_name,
		speed = speed,
		size = size
	}

	local new_nextbot_definition = get_new_nextbot_definition(name, formal_name, speed, size)
	minetest.register_entity("nextbots:" .. name, new_nextbot_definition)
end

-- In order of appearance
nextbots.register_nextbot("obunga", "Obunga", 10, 5)
nextbots.register_nextbot("selene", "Selene Delgado López", 11, 4)
nextbots.register_nextbot("thisman", "This Man", 11, 5)