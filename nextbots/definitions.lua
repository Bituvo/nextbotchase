-- Properties that all nextbots share
local common_nextbot_definition = {
	initial_properties = {
		physical = false,
		show_on_minimap = true,
		use_texture_alpha = true
	},

	dtime = 0,
	chasing = false,

	-- "But Ma, what happens when I get him?"
	on_reach_target = function(self)
		-- "Kill him and stop moving"
		self.chasing = false
		self.target:set_hp(0)
		self.object:set_velocity(vector.new())

		minetest.chat_send_all(self.target:get_player_name() .. " was killed by " .. self.formal_name)

		-- "Then kill yourself after a couple seconds" (stay mad)
		minetest.after(2, function()
			minetest.sound_stop(self.sound_handle)
			local target_name = self.target:get_player_name()
			self.object:remove()
			nextbots.spawned_nextbots[target_name] = nil
		end)
	end,

	-- If nextbot is stuck in a wall
	stay_unstuck = function(self)
		if minetest.get_node(self.object:get_pos()).name ~= "air" then
			local origin = vector.round(self.object:get_pos())
			origin.y = -4

			local left = origin
			local right = origin
			local forwards = origin
			local backwards = origin

			left.x = left.x - 1
			right.x = right.x + 1
			forwards.z = forwards.z + 1
			backwards.z = backwards.z - 1

			if minetest.get_node(left).name == "air" then
				self.object:move_to(left)
			elseif minetest.get_node(right).name == "air" then
				self.object:move_to(right)
			elseif minetest.get_node(forwards).name == "air" then
				self.object:move_to(forwards)
			elseif minetest.get_node(backwards).name == "air" then
				self.object:move_to(backwards)
			else
				-- We are too stuck
				self.object:remove()
			end
		end
	end
}

-- Nextbot-definitionator factory constructor
local function get_new_nextbot_definition(name, formal_name, speed, size)
	local new_nextbot_definition = table.copy(common_nextbot_definition)
	
	new_nextbot_definition.initial_properties.textures = {name .. ".png"}
	new_nextbot_definition.initial_properties.visual_size = {x = size, y = size}
	new_nextbot_definition.formal_name = formal_name
	new_nextbot_definition.real_name = name
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
nextbots.register_nextbot("alternate", "Alternate", 10, 4)
nextbots.register_nextbot("pinhead", "Pinhead", 11, 4)
nextbots.register_nextbot("munci", "Munci", 11, 5)