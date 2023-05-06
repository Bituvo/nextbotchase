local S = minetest.get_translator("nextbots")

function nextbots._on_step(self, dtime)
	self._dtime = self._dtime + dtime

	-- Don't move if not chasing
	if not self._chasing then
		self.object:set_velocity(vector.new())
		return
	end

	-- Step <speed> times every second
	if self._dtime > 1 / self._speed then
		self._chase_time = self._chase_time + dtime
		self._dtime = 0

		-- Delete self if target can't be found
		if not self._target or not self._target:get_pos() or self._target:get_hp() == 0 then
			minetest.log("warning", "Prematurely removing nextbot (target not found)")
			local id = self._id
			nextbots.remove_nextbot(id)
			return
		end

		-- Delete self if target is dead
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

		-- Actually move
		local velocity = vector.multiply(vector.subtract(next_pos, self.object:get_pos()), self._speed)
		self.object:set_velocity(velocity)
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
		server.update_player_nametag(self._target)
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
    local origin = vector.round(vector.add(self.object:get_pos(), {x = 0, y = 1, z = 0}))
    origin.y = -4
    local node_name = minetest.get_node(origin).name

    while node_name ~= "air" and node_name ~= "ignore" do
        local left = vector.copy(origin)
        local right = vector.copy(origin)
        local forwards = vector.copy(origin)
        local backwards = vector.copy(origin)

        left.x = left.x - radius
        right.x = right.x + radius
        forwards.z = forwards.z + radius
        backwards.z = backwards.z - radius

        if minetest.get_node(left).name == "air" then
			left.y = self._fixed_y_position
            self.object:move_to(left)
            return true
        elseif minetest.get_node(right).name == "air" then
			right.y = self._fixed_y_position
            self.object:move_to(right)
            return true
        elseif minetest.get_node(forwards).name == "air" then
			forwards.y = self._fixed_y_position
            self.object:move_to(forwards)
            return true
        elseif minetest.get_node(backwards).name == "air" then
			backwards.y = self._fixed_y_position
            self.object:move_to(backwards)
            return true
        else
            if radius > 10 then
                minetest.log("warning", self._formal_name .. " is stuck in " ..
                    node_name .. " at " .. minetest.pos_to_string(origin))
                return false
            end

            minetest.log("warning", self._formal_name .. " is stuck in " .. node_name .. " at " ..
                minetest.pos_to_string(origin) .. ", trying again with radius=" .. tostring(radius))

            radius = radius + 1
            node_name = minetest.get_node(origin).name
        end
    end

    return true
end