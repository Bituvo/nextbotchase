local S = minetest.get_translator("definitions")

-- Properties that all nextbots share
local common_nextbot_definition = {
	initial_properties = {
		physical = false,
		show_on_minimap = true,
		use_texture_alpha = true,
		static_save = false
	},

	_dtime = 0,
	_chase_time = 0,
	_chasing = false,
	_steps = 0,
	_path = {},

	_id = 0,
	_fixed_y_position = 0,
	_target = nil,

	_on_reach_target = function(self)
		self._chasing = false
		self._target:set_hp(0)
		self.object:set_velocity(vector.new())

		local target_meta = self._target:get_meta()
		local target_chased_time = target_meta:get_float("chased_time") + self._chase_time
		local target_deaths = target_meta:get_int("deaths") + 1
		target_meta:set_float("chased_time", target_chased_time)
		target_meta:set_int("deaths", target_deaths)
		target_meta:set_int("being_chased", 0)

		-- Score calculation
		local score = 0
		if target_deaths < 5 then
			score = target_chased_time / (target_deaths * 3)
		else
			score = target_chased_time / (target_deaths + 3)
		end
		score = score + self.speed / 15
		target_meta:set_float("score", score)

		minetest.chat_send_all(S("@1 was killed by @2", self._target:get_player_name(), self.formal_name))
		minetest.log("action", self._target:get_player_name() .. " was killed by " .. self.formal_name)

		-- Remove self
		minetest.after(2, function()
			local player_nextbot_id = target_meta:get_int("nextbot_id")

			self.object:remove()
			nextbots.spawned_nextbots[player_nextbot_id] = nil
			target_meta:set_int("nextbot_id", 0)
		end)
	end,

	-- If nextbot is stuck in a wall
	_stay_unstuck = function(self)
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
			end
		end
	end
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
nextbots.register_nextbot("obunga",    "Obunga", 			   20, 5)
nextbots.register_nextbot("selene",    "Selene Delgado López", 22, 4)
nextbots.register_nextbot("thisman",   "This Man",			   22, 5)
nextbots.register_nextbot("alternate", "Alternate",            20, 4)
nextbots.register_nextbot("pinhead",   "Pinhead",              23, 4)
nextbots.register_nextbot("munci",     "Munci",                21, 5)