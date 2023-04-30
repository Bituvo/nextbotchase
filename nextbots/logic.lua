local S = minetest.get_translator("nextbots")

function nextbots._on_step(self, dtime)
	self._dtime = self._dtime + dtime
	self._chase_time = self._chase_time + dtime

	-- Step <speed> times every second
	if self._dtime > 1 / self._speed and self._chasing then
		self._dtime = 0

		-- Delete self if target is already dead or can't be found
		if not self._target or not self._target:get_pos() then
			minetest.log("warning", "Prematurely removing nextbot (target not found")
			self._remove_self(self)
			return
		end

		if self._target:get_hp() == 0 then
			minetest.log("warning", "Prematurely removing nextbot (target is dead)")
			self._remove_self(self)
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
			self._stay_unstuck(self, 1)
			return
		end

		self.object:move_to(next_pos)
		self._steps = self._steps + 1
	end
end

function nextbots._remove_self(self)
	nextbots.remove_nextbot(self._id)
end

function nextbots._on_reach_target(self)
	self._chasing = false
	self._target:set_hp(0)
	self.object:set_velocity(vector.new())

	minetest.sound_fade(self._sound_handle, 1.5, 0)
	local target_name = self._target:get_player_name()

	local previous_rank = server.get_player_rank(target_name)
	nextbots.calculate_score(self._target, self._chase_time, self._speed)
	local current_rank = server.get_player_rank(target_name)

	if previous_rank.rank ~= current_rank.rank then
		-- Player rank updated
		minetest.log("action", target_name .. " is now at " .. current_rank.rank .. " rank")
		minetest.chat_send_all(S("@1 is now @2 rank",
			target_name, minetest.colorize(current_rank.color, "[" .. current_rank.rank .. "]")
		))
	end

	if not minetest.check_player_privs(target_name, {server = true}) then
		minetest.chat_send_all(minetest.colorize(server.death_color,
			S("@1 was killed by @2", target_name, self._formal_name))
		)
		minetest.log("action", target_name .. " was killed by " .. self._technical_name)
	end

	-- Remove self
	minetest.after(2, function()
		self._remove_self(self)
	end)
end

function nextbots._stay_unstuck(self, radius)
	if minetest.get_node(self.object:get_pos()).name ~= "air" then
		local origin = vector.round(self.object:get_pos())
		origin.y = -4

		local left = origin
		local right = origin
		local forwards = origin
		local backwards = origin

		left.x = left.x - radius
		right.x = right.x + radius
		forwards.z = forwards.z + radius
		backwards.z = backwards.z - radius

		if minetest.get_node(left).name == "air" then
			self.object:move_to(left)
		elseif minetest.get_node(right).name == "air" then
			self.object:move_to(right)
		elseif minetest.get_node(forwards).name == "air" then
			self.object:move_to(forwards)
		elseif minetest.get_node(backwards).name == "air" then
			self.object:move_to(backwards)
		else
			minetest.log("warning",
				self._formal_name .. " is stuck at " .. minetest.pos_to_string(origin) .. ", trying again with radius=" .. tostring(radius)
			)
			nextbots._stay_unstuck(self, radius + 1)
		end
	end
end