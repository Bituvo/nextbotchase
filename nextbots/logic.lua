-- Each nextbot has an ID so we can, well, IDentify it
local current_nextbot_id = 1

-- Spawn the nextbot just above the ground and then add the functions 'n stuff
function nextbots.spawn_nextbot(name, pos, target, wait_time)
	local y_offset = nextbots.registered_nextbots[name].size / 2
	pos = vector.round(pos)
	pos.y = target:get_pos().y + y_offset

	local new_nextbot = minetest.add_entity(pos, "nextbots:" .. name)
	new_nextbot:get_luaentity().fixed_y_position = pos.y
	new_nextbot:get_luaentity().id = current_nextbot_id
	new_nextbot:get_luaentity().target = target

	-- Pathfinding logic
	minetest.after(wait_time, function()
		-- It's chasin' time
		new_nextbot:get_luaentity().chasing = true

		new_nextbot:get_luaentity().sound_handle = minetest.sound_play(name, {
			object = new_nextbot,
			loop = true,
			max_hear_distance = 16,
			to_player = target:get_player_name()
		})

		new_nextbot:get_luaentity().on_step = function(self, dtime)
			self.dtime = self.dtime + dtime
			self.chase_time = self.chase_time + dtime

			if self.dtime > 1 / self.speed and self.chasing then
				self.dtime = 0

				-- Delete self if target is already dead or can't be found
				if not self.target or not self.target:get_pos() or self.target:get_hp() == 0 then
					minetest.sound_stop(self.sound_handle)
					self.object:remove()
					return
				end

				local bot_pos = vector.round(self.object:get_pos())
				local target_pos = vector.round(self.target:get_pos())
				-- Set both y-positions to ground level
				bot_pos.y = -4
				target_pos.y = -4

				-- Check if we have reached the target before pathfinding
				if vector.distance(bot_pos, target_pos) < 2 then
					minetest.sound_fade(self.sound_handle, 1.5, 0)
					self.on_reach_target(self)
					return
				end

				-- Here's the fun part
				local path = minetest.find_path(bot_pos, target_pos, 10, 0, 0, "A*")
				local next_pos = bot_pos

				if path and #path > 1 then
					next_pos = path[2]
					next_pos.y = self.fixed_y_position
				else
					self.stay_unstuck(self)
					return
				end

				local velocity = vector.multiply(vector.subtract(next_pos, self.object:get_pos()), self.speed)
				velocity.y = 0 -- Probably not needed, but we'll do it anyways (for good measure)

				self.object:set_velocity(velocity)
			end
		end
	end)

	nextbots.spawned_nextbots[current_nextbot_id] = new_nextbot
	current_nextbot_id = current_nextbot_id + 1
end