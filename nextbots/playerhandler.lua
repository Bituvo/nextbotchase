minetest.register_privilege("no_nextbot", {
	description = "Nextbots will not automatically spawn for players with this privilege",
	give_to_admin = true
})

-- Nextbot offsets from players
local offsets = {
	{x = nextbots.player_spawn_offset, y = 0, z = 0},
	{x = 0, y = 0, z = nextbots.player_spawn_offset},
	{x = -nextbots.player_spawn_offset, y = 0, z = 0},
	{x = 0, y = 0, z = -nextbots.player_spawn_offset}
}

-- Get a random nextbot name
local function get_random_nextbot_name()
	local nextbot_names = {}

	for nextbot_name, _ in pairs(nextbots.registered_nextbots) do
		table.insert(nextbot_names, nextbot_name)
	end

	return nextbot_names[math.random(1, #nextbot_names)]
end

-- Do relocating and nextbot spawning when a player is ready
function nextbots.handle_new_player(player)
	player:set_pos(server.static_spawn)
	player:set_physics_override({speed = 2})

	-- Ignore staff (you shouldn't do this or I will punish you)
	if minetest.check_player_privs(player, {server = true}) then return end

	local bot_offset = offsets[math.random(1, 4)]
	local bot_pos = vector.add(player:get_pos(), bot_offset)
	local yaw = 0

	-- Make the player look at the nextbot
	if bot_offset.x > 0 then
		yaw = 270
	elseif bot_offset.x < 0 then
		yaw = 90
    elseif bot_offset.z < 0 then
        yaw = 180
    end

	player:set_look_horizontal(math.rad(yaw))
	player:set_look_vertical(0)

	nextbots.spawn_nextbot(get_random_nextbot_name(), bot_pos, player, 2)
end