local translate = minetest.get_translator("rules")
local function S(message)
	return minetest.formspec_escape(translate(message))
end

local function show_rules(player)
	minetest.show_formspec(player:get_player_name(), "new_player",
		"formspec_version[5]" ..
		"size[10, 8]" ..
		"no_prepend[]" ..
		"bgcolor[#111a]" ..
		"label[1, 1;" .. S("Welcome to Backrooms Chase!") .. "]" ..
		"label[1, 2;" .. S("Before you begin playing, you must read and agree to the rules:") .. "]" ..
		"textlist[1, 2.5;8, 2.6;rules;1. " .. S("Don't swear or harass other players") ..
			",2. " .. S("Don't spam in chat") ..
			",3. " .. S("Don't use nonsense usernames (\"asjdhsdag\")") ..
			",4. " .. S("Don't ask for priveleges (\"can I have creative?\")") ..
			",5. " .. S("Don't roleplay (no exceptions)") ..
			",6. " .. S("Don't talk about controversial topics") .. "]" ..
		"label[1, 5.6;" .. S("Failure to comply with these rules may result in punishment.") .. "]" ..
		"button[1, 6;5, 1;rules_agree;" .. S("I have read and agreed to the rules") .. "]" ..
		"button[6.3, 6;2.7, 1;rules_disagree;" .. S("I disagree") .. "]"
	)
end

minetest.register_on_newplayer(function(player)
	if not minetest.check_player_privs(player, {server = true}) then
		player:get_meta():set_int("rules_agreed", 0)
		show_rules(player)
	end
end)

minetest.register_on_joinplayer(function(player)
	if not minetest.check_player_privs(player, {server = true}) then
		if player:get_meta():get_int("rules_agreed") == 0 then
			show_rules(player)
		end
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "new_player" then return end
	local name = player:get_player_name()

	if fields.rules_disagree or fields.quit then
		minetest.kick_player(name, S("Please read and agree to the rules."))
	elseif fields.rules_agree then
		player:get_meta():set_int("rules_agreed", 1)
		minetest.close_formspec(name, "new_player")
		nextbot.on_new_player(player)
	end
end)