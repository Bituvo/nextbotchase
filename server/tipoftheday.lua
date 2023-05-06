local S = minetest.get_translator("server")

local tips = {
	S("Run as long as you can to increase your rank"),
	S('Do "/skin" to change your skin'),
	S("Nextbots use the A* algorithm"),
	S('Do "/rules" to see the server rules'),
	S("You have a two second head start"),
	S("You may hear something behind you"),
	S("There are six different nextbots"),
	S("Each nextbot has a different size and speed"),
	S("Don't run into the traps"),
	S("Don't get lost in the shadow areas"),
	S("Nextbots never give up"),
	S("Mods can see your chat messages"),
	S('Do "/score" to see your or another player\'s score'),
	S('Do "/highscores" to see player highscores')
}

minetest.register_on_joinplayer(function(player)
	-- Cycle through tips each day
	local tip = tips[(tonumber(os.date("%j")) - 1) % #tips + 1]

	minetest.chat_send_player(player:get_player_name(),
		minetest.colorize(server.info_color, S("Tip of the day: ")) .. tip
	)
end)