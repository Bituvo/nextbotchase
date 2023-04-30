-- I would put this in `server` but it can't access the high scores

function server.get_player_rank(player_name)
	if minetest.check_player_privs(player_name, {server = true}) then
		return {rank = "Admin", color = "#f00"}
	end

	local player_score = nextbots.get_player_score(player_name)

	if player_score < 5 then
		return {rank = "Runner", color = "#ff5733"}
	elseif player_score < 10 then
		return {rank = "Evader", color = "#00ff7f"}
	elseif player_score < 20 then
		return {rank = "Dodger", color = "#00bfff"}
	elseif player_score < 30 then
		return {rank = "Sprinter", color = "#ff2e2e"}
	end

	return {rank = "Survivor", color = "#ffc300"}
end

-- Chat messages
function minetest.format_chat_message(name, message)
	local player_rank = server.get_player_rank(name)
	return minetest.colorize(player_rank.color, "[" .. player_rank.rank .. "] ") .. name .. ": " .. message
end

function server.update_player_nametag(player)
	local player_name = player:get_player_name()
	local player_rank = server.get_player_rank(player_name)

	player:set_nametag_attributes({
		text = minetest.colorize(player_rank.color, "[" .. player_rank.rank .. "] ") .. player_name
	})
end

-- Set nametags
minetest.register_on_joinplayer(server.update_player_nametag)