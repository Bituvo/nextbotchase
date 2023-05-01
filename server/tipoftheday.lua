local S = minetest.get_translator("server")

local tips = {
	"Run as long as you can to increase your rank",
	'Do "/skin" to change your skin',
	"Nextbots use the A* algorithm",
	'Do "/rules" to see the server rules',
	"You have a two second head start",
	"You may hear something behind you",
	"There are six different nextbots",
	"Each nextbot has a different size and speed",
	"Don't run into the traps",
	"Don't get lost in the shadow areas",
	"Nextbots never give up",
	"Mods can see your chat messages",
	'Do "/score" to see your or another player\'s score'
}

minetest.register_on_joinplayer(function(player)
	-- Cycle through tips each day
	local tip = tips[(tonumber(os.date("%j")) - 1) % #tips + 1]

	minetest.chat_send_player(player:get_player_name(),
		minetest.colorize(server.info_color, S("Tip of the day: ")) .. S(tip)
	)
end)