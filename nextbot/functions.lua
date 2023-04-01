nextbot.spawned_nextbots = {}

-- Nextbot offset from newly spawned players
local offset = {
	{x = 20, y = 2.5, z = 0},
	{x = 0, y = 2.5, z = 20},
	{x = -20, y = 2.5, z = 0},
	{x = 0, y = 2.5, z = -20}
}

-- Make the player look in the direction of the returned nextbot position
local function handle_new_nextbot_spawning(player)
	local random = math.random(1, 4)
    local bot_offset = offset[random]

	local yaw = 0
    if bot_offset.x > 0 then
        yaw = 270
    elseif bot_offset.x < 0 then
        yaw = 90
    elseif bot_offset.z < 0 then
        yaw = 180
    end
    player:set_look_horizontal(math.rad(yaw))
    player:set_look_vertical(0)

	return vector.add(player:get_pos(), bot_offset)
end

function nextbot.get_player_nextbot(player)
	-- Returns nil if it doesn't exist, which is close enough to false
	return nextbot.spawned_nextbots[player:get_player_name()]
end

function nextbot.delete_player_nextbot(player)
	local player_nextbot = nextbot.get_player_nextbot(player)

	if player_nextbot then
		player_nextbot:remove()
		nextbot.spawned_nextbots[player:get_player_name()] = nil
	end
end

function nextbot.on_new_player(player)
	nextbot.delete_player_nextbot(player)
	player:set_physics_override({speed = 2})

	-- Don't automatically add nextbots to players with the server privelege
	if not minetest.check_player_privs(player, {no_nextbot = true}) and player:get_hp() > 0 then
		player:set_pos({x = 8, y = -4.5, z = 8})
		local bot_pos = handle_new_nextbot_spawning(player)
        nextbot.add_nextbot(nextbot.nextbots[math.random(1, #nextbot.nextbots)].name, player, bot_pos)
    end
end

minetest.register_on_shutdown(minetest.clear_objects)