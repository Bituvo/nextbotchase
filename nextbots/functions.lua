-- Each nextbot has an ID
local current_nextbot_id = 1

-- Spawn the nextbot just above the ground then add the functions
function nextbots.spawn_nextbot(name, pos, target, wait_time)
	local y_offset = nextbots.registered_nextbots[name].size / 2
	pos = vector.round(pos)
	pos.y = target:get_pos().y + y_offset

	local new_nextbot = minetest.add_entity(pos, "nextbots:" .. name)
	new_nextbot:get_luaentity()._fixed_y_position = pos.y
	new_nextbot:get_luaentity()._id = current_nextbot_id
	new_nextbot:get_luaentity()._target = target

	local created_successfully = true

	minetest.after(wait_time, function()
		local luaentity = new_nextbot:get_luaentity()

		if not luaentity or not target then
			created_successfully = false
			return
		end

		local target_meta = target:get_meta()
		
		if not target_meta then
			created_successfully = false
			return
		end

		target_meta:set_int("being_chased", 1)
		luaentity._chasing = true

		luaentity._sound_handle = minetest.sound_play(name, {
			object = new_nextbot,
			loop = true,
			max_hear_distance = 16,
			to_player = target:get_player_name()
		})

		-- Logic
		luaentity.on_step = nextbots._on_step
		luaentity._on_reach_target = nextbots._on_reach_target
		luaentity._stay_unstuck = nextbots._stay_unstuck
	end)

	if created_successfully then
		nextbots.spawned_nextbots[current_nextbot_id] = new_nextbot
		target:get_meta():set_int("nextbot_id", current_nextbot_id)
		
		current_nextbot_id = current_nextbot_id + 1
	else
		minetest.log("warning", "Nextbot creation failed")
	end
end

-- Find nextbot from target name or nextbot ID
function nextbots.find_nextbot(name_or_id)
	if type(name_or_id) == "number" then
		return nextbots.spawned_nextbots[name_or_id]
	end

	for target_name, nextbot in ipairs(nextbots.spawned_nextbots) do
		if target_name == name_or_id then
			return nextbot
		end
	end
end

local function _set_target_meta(luaentity)
	local target_meta = luaentity._target:get_meta()
	target_meta:set_int("nextbot_id", 0)
end

local function remove_nextbot(object, name_or_id)
	if object then
		local luaentity = object:get_luaentity()
		-- Player might have left at just the wrong time
		if not pcall(_set_target_meta, luaentity) then return end

		minetest.sound_stop(luaentity._sound_handle)
		object:remove()
		
		if type(name_or_id) == "number" then
			nextbots.spawned_nextbots[name_or_id] = nil
		else
			for target_name, nextbot in ipairs(nextbots.spawned_nextbots) do
				if target_name == name_or_id then
					nextbots.spawned_nextbots[nextbot:get_luaentity()._id] = nil
				end
			end
		end
	end
end

-- Properly remove nextbot
function nextbots.remove_nextbot(name_or_id)
	if type(name_or_id) == "number" then
		remove_nextbot(nextbots.spawned_nextbots[name_or_id], name_or_id)
	end

	remove_nextbot(nextbots.find_nextbot(name_or_id))
end