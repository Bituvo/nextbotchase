local storage = minetest.get_mod_storage()
local S = minetest.get_translator("server")
-- Normal translation is not enough, we need hyper-translation (formspec escaping)
local function FSS(...)
	return minetest.formspec_escape(S(...))
end

-- Coloring functions
local err = function(message) return minetest.colorize(server.error_color, message) end
local suc = function(message) return minetest.colorize(server.success_color, message) end

-- Create a formspec textlist at the given y-position
local function get_rules_textlist(y)
	return "textlist[1, " .. tostring(y) .. ";10, 3.6;rules" ..
		";1. " .. FSS("Don't swear or harass other players") ..
		",2. " .. FSS("Don't spam in chat") ..
		",3. " .. FSS("Don't use nonsense usernames (\"asjdhsdag\")") ..
		",4. " .. FSS("Don't ask for priveleges (\"can I have creative?\")") ..
		",5. " .. FSS("Don't roleplay (no exceptions)") ..
		",6. " .. FSS("Don't talk about controversial topics") ..
	"]"
end

-- Show the "new player rules list" to a player
function server.show_new_player_rules(player)
	minetest.log("action", "Showing server rules to newcomer " .. player:get_player_name())
	minetest.show_formspec(player:get_player_name(), "new_player",
		"formspec_version[5]" ..
		"size[12, 9]" ..
		"no_prepend[]" ..
		"bgcolor[#111a]" ..
		"label[1, 1;" .. FSS("Welcome to Backrooms Chase!") .. "]" ..
		"label[1, 2;" .. FSS("Before you begin playing, you must read and agree to the rules:") .. "]" ..
		get_rules_textlist(2.5) ..
		"label[1, 6.6;" .. FSS("Failure to comply with these rules may result in punishment.") .. "]" ..
		"button[1.5, 7;6, 1;rules_agree;" .. FSS("I have read and agreed to the rules") .. "]" ..
		"button[7.8, 7;2.7, 1;rules_disagree;" .. FSS("I disagree") .. "]"
	)
end

-- Show the normal rules list to a player
local function show_rules(player)
	minetest.show_formspec(player:get_player_name(), "rules",
		"formspec_version[5]" ..
		"size[12, 7.5]" ..
		"no_prepend[]" ..
		"bgcolor[#111a]" ..
		"label[1, 1;" .. FSS("Backrooms Chase rules:") .. "]" ..
		get_rules_textlist(1.5) ..
		"button_exit[4.5, 5.5;3, 1;exit;OK]"
	)
end

minetest.register_chatcommand("rules", {
	description = S("Show the server rules to yourself or another player"),
	params = "[" .. S("player_name") .. "]",
	func = function(invoker_name, target_name)
		if target_name == "" then
			minetest.log("action", "Showing server rules to " .. invoker_name)
			show_rules(minetest.get_player_by_name(invoker_name))
		
		elseif minetest.check_player_privs(invoker_name, {server = true}) then
			local target = minetest.get_player_by_name(target_name)

			if target then
				minetest.log("action", invoker_name .. " showed server rules to " .. target_name)
				show_rules(target)
				return true, suc(S("Showed rules to @1", target_name))
			else
				return false, err(S('The player "@1" either does not exist or is not logged in', target_name))
			end
		else
			return false, err(S("You need the '@1' privilege to show the rules to another player", "server"))
		end
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "new_player" then return end
	local name = player:get_player_name()

	-- Kick player if they don't agree to the rules
	if fields.rules_disagree or fields.quit then
		minetest.kick_player(name, S("Please read and agree to the rules."))
		minetest.log("action", "Kicked " .. name .. " for not agreeing to the rules")
	elseif fields.rules_agree then
		minetest.log("action", name .. " agreed to the rules")
		player:get_meta():set_int("rules_agreed", 1)
		minetest.close_formspec(name, "new_player")
		
		nextbots.handle_new_player(player)
	end
end)

-- Show a player the rules if they have not agreed to them yet
minetest.register_on_newplayer(function(player)
	player:set_physics_override({speed = server.player_speed})
	player:get_meta():set_int("nextbot_id", 0)
	
	if not minetest.check_player_privs(player, {server = true}) then
		server.prepare_player(player)
		
		player:get_meta():set_int("rules_agreed", 0)
		player:set_pos(server.static_spawn)
		server.show_new_player_rules(player)
	end
end)

-- Ditto, but also spawn a nextbot
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	local formspec_version = minetest.get_player_information(player_name).formspec_version

	-- Don't allow Multicrap
	if formspec_version < 6 then
		minetest.kick_player(player_name, S("Your Minetest/MultiCraft client is outdated. Please update to Minetest 5.7.0"))
		minetest.log("action", "Kicked " .. player_name .. " for outdated client (formspec version: " .. tostring(formspec_version) .. ")")

		storage:set_int("multicraft", storage:get_int("multicraft") + 1)
		return
	end

	storage:set_int("minetest", storage:get_int("minetest") + 1)

	player:set_physics_override({speed = server.player_speed})
	player:get_meta():set_int("nextbot_id", 0)

	if not minetest.check_player_privs(player, {server = true}) then
		server.prepare_player(player)
		
		if player:get_hp() > 0 then
			if player:get_meta():get_int("rules_agreed") == 0 then
				server.show_new_player_rules(player)
				return
			else
				nextbots.handle_new_player(player)
			end
		end
	end
end)