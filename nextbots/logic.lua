local S = minetest.get_translator("nextbots")

function nextbots._on_step(self, dtime)
	self._dtime = self._dtime + dtime
	self._chase_time = self._chase_time + dtime

	-- Step <speed> times every second
	if self._dtime > 1 / self._speed and self._chasing then
		self._dtime = 0

		-- Delete self if target is already dead or can't be found
		if not self._target or not self._target:get_pos() or self._target:get_hp() == 0 then
			local id = self._id
			nextbots.remove_nextbot(id)
			return
		end

		local bot_pos = vector.round(self.object:get_pos())
		local target_pos = vector.round(self._target:get_pos())
		-- Set both y-positions to ground level
		bot_pos.y = -4
		target_pos.y = -4
		local distance_to_target = vector.distance(bot_pos, target_pos)

		-- Check if we have reached the target before pathfinding
		if distance_to_target < 1.5 then
			self._on_reach_target(self)
			return
		end

		-- Set pathfinding frequency depending on distance to target
		local modulo = math.max(math.min(math.floor(distance_to_target / 10), 5), 1)
		
		if self._steps % modulo == 0 then
			self._path = minetest.find_path(bot_pos, target_pos, 10, 0, 0, "A*")
		end

		local next_pos = bot_pos

		if self._path and #self._path > 1 then
			next_pos = self._path[self._steps % modulo + 2]
			next_pos.y = self._fixed_y_position
		else
			self._stay_unstuck(self)
			return
		end

		-- Actually move
		local velocity = vector.multiply(vector.subtract(next_pos, self.object:get_pos()), self._speed)
		self.object:set_velocity(velocity)
		self._steps = self._steps + 1
	end
end

function nextbots._on_reach_target(self)
	self._chasing = false
	self._target:set_hp(0)
	self.object:set_velocity(vector.new())

	minetest.sound_fade(self._sound_handle, 1.5, 0)
	nextbots.calculate_score(self._target, self._chase_time, self._speed)
	minetest.chat_send_all(minetest.colorize(server.death_color,
		S("@1 was killed by @2", self._target:get_player_name(), self._formal_name))
	)
	minetest.log("action", self._target:get_player_name() .. " was killed by " .. self._technical_name)

	-- Remove self
	minetest.after(2, function()
		nextbots.remove_nextbot(self._id)
	end)
end

function nextbots._stay_unstuck(self)
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
			minetest.log("warning", self._technical_name .. " is stuck at " .. minetest.pos_to_string(origin))
		end
	end
end