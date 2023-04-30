-- I would put this in `server` but it can't access the high scores

function server.get_player_role(player_name)
	if minetest.check_player_privs(player_name, {server = true}) then
		return {role = "Admin", color = "#f00"}
	end

	local player_score = nextbots.get_player_score(player_name)

	if player_score < 5 then
		return {role = "Runner", color = "#ff5733"}
	elseif player_score < 10 then
		return {role = "Evader", color = "#00ff7f"}
	elseif player_score < 20 then
		return {role = "Dodger", color = "#00bfff"}
	elseif player_score < 30 then
		return {role = "Sprinter", color = "#ff2e2e"}
	end

	return {role = "Survivor", color = "#ffc300"}
end

-- Set nametags
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	local player_role = server.get_player_role(player_name)

	player:set_nametag_attributes({
		text = minetest.colorize(player_role.color, "[" .. player_role.role .. "] ") .. player_name
	})
end)