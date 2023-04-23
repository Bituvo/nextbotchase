-- Each nextbot has an ID
local current_nextbot_id = 1

-- Spawn the nextbot just above the ground then add the functions
function nextbots.spawn_nextbot(name, pos, target, wait_time)
	local y_offset = nextbots.registered_nextbots[name].size / 2
	pos = vector.round(pos)
	pos.y = target:get_pos().y + y_offset

	local new_nextbot = minetest.add_entity(pos, "nextbots:" .. name)
	new_nextbot:get_luaentity().fixed_y_position = pos.y
	new_nextbot:get_luaentity().id = current_nextbot_id
	new_nextbot:get_luaentity().target = target

	local created_successfully = true

	-- Pathfinding logic
	minetest.after(wait_time, function()
		if not new_nextbot:get_luaentity() then
			created_successfully = false
			return
		end

		target:get_meta():set_int("being_chased", 1)
		new_nextbot:get_luaentity().chasing = true

		-- Play sound
		new_nextbot:get_luaentity().sound_handle = minetest.sound_play(name, {
			object = new_nextbot,
			loop = true,
			max_hear_distance = 16,
			to_player = target:get_player_name()
		})

		new_nextbot:get_luaentity().on_step = function(self, dtime)
			self.dtime = self.dtime + dtime
			self.chase_time = self.chase_time + dtime

			-- Step <speed> times every second
			if self.dtime > 1 / self.speed and self.chasing then
				self.dtime = 0

				-- Delete self if target is already dead or can't be found
				if not self.target or not self.target:get_pos() or self.target:get_hp() == 0 then
					minetest.sound_stop(self.sound_handle)
					local id = self.id
					self.object:remove()
					nextbots.spawned_nextbots[id] = nil
					return
				end

				local bot_pos = vector.round(self.object:get_pos())
				local target_pos = vector.round(self.target:get_pos())
				-- Set both y-positions to ground level
				bot_pos.y = -4
				target_pos.y = -4
				local distance_to_target = vector.distance(bot_pos, target_pos)

				-- Check if we have reached the target before pathfinding
				if distance_to_target < 2 then
					minetest.sound_fade(self.sound_handle, 1.5, 0)
					self.on_reach_target(self)
					return
				end

				-- Set pathfinding frequency depending on distance to target
				local modulo = math.max(math.min(math.floor(distance_to_target / 10), 5), 1)
				minetest.chat_send_all(minetest.pos_to_string(bot_pos))
				
				if self.steps % modulo == 0 then
					self.path = minetest.find_path(bot_pos, target_pos, 10, 0, 0, "A*")
				end

				local next_pos = bot_pos

				if self.path and #self.path > 1 then
					next_pos = self.path[self.steps % modulo + 2]
					next_pos.y = self.fixed_y_position
				else
					self.stay_unstuck(self)
					return
				end

				-- Actually move
				local velocity = vector.multiply(vector.subtract(next_pos, self.object:get_pos()), self.speed)
				self.object:set_velocity(velocity)
				self.steps = self.steps + 1
			end
		end
	end)

	if created_successfully then
		nextbots.spawned_nextbots[current_nextbot_id] = new_nextbot
		current_nextbot_id = current_nextbot_id + 1
	end
end