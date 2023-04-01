-- Entity definition that all nextbots have in common
local default_nextbot_definition = {
	initial_properties = {
        pointable = false,
        visual = "sprite",
        visual_size = {x = 5, y = 5}
    },

    dtime = 0,
    deletion_timer = 0,
    path = {},
    next_pos = nil,
	steps = 0,
    chasing = false,

	on_reach_target = function(self)
		-- Kill player and stop moving
		self.target:set_hp(0)
		self.chasing = false
		self.object:set_velocity(vector.new())

		-- Delete self after two seconds
		minetest.after(2, function() self.object:remove() end)
	end
}

function nextbot.register_nextbot(nextbot_def)
	local new_nextbot_definition = table.copy(default_nextbot_definition)

	new_nextbot_definition.initial_properties.textures = {nextbot_def.name .. ".png"}
	new_nextbot_definition.formal_name = nextbot_def.formal_name
	new_nextbot_definition.speed = nextbot_def.speed

	minetest.register_entity("nextbot:" .. nextbot_def.name, new_nextbot_definition)
end

function nextbot.add_nextbot(name, target, pos)
	local new_nextbot = minetest.add_entity(pos, "nextbot:" .. name)

	-- Set position and target
	new_nextbot:set_pos(pos)
	new_nextbot:get_luaentity().target = target
	-- Set on_step function (contains pathfinding logic)
	new_nextbot:get_luaentity().on_step = function(self, dtime)
		self.dtime = self.dtime + dtime

		-- Start moving after one second
		if not self.chasing then
			if self.dtime > 1 then
				self.dtime = 0
				self.chasing = true
			else
				return
			end
		end

		-- The nextbot "steps" <speed> times per second
		if self.chasing and self.dtime > (1 / self.speed) then
			self.dtime = 0

			-- Stop if target is already dead
			if self.target:get_hp() == 0 then
				self.on_reach_target(self)
				return
			end

			-- Delete self if target can't be found
			if not self.target:get_pos() then
				self.object:remove()
				return
			end

			local target_pos = self.target:get_pos()
			-- Round bot position for pathfinding
			local bot_pos = vector.round(self.object:get_pos())
			target_pos.y = -4
			bot_pos.y = -4
			local distance_to_target = vector.distance(bot_pos, target_pos)

			-- Set pathfinding frequency depending on distance to target
			local modulo = 1
			if distance_to_target > 50 then
				modulo = 4
			elseif distance_to_target > 35 then
				modulo = 3
			elseif distance_to_target > 20 then
				modulo = 2
			end

			-- Pathfind
			if self.steps % modulo == 0 then
				self.path = minetest.find_path(vector.round(bot_pos), target_pos, 10, 0, 0, "A*")
			end

			-- Set next position if a path was found
			if self.path and #self.path > 1 then
				self.next_pos = self.path[self.steps % modulo + 2]
				self.next_pos.y = -2
			else
				self.next_pos = nil
				bot_pos.y = -2
				self.object:set_pos(bot_pos)
			end

			if self.next_pos then
				self.steps = self.steps + 1
				-- Smoothly move toward next point
				local velocity = vector.multiply(vector.subtract(self.next_pos, bot_pos), self.speed)
				velocity.y = 0

				self.object:set_velocity(velocity)
			end

			if distance_to_target < 2 then
				-- Collided with player
				self.on_reach_target(self)
				minetest.chat_send_all(self.target:get_player_name() .. " was killed by " .. self.formal_name)
			end
		end
	end

	nextbot.spawned_nextbots[target:get_player_name()] = new_nextbot
end