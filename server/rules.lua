local S = minetest.get_translator("rules")
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
	params = "[player_name]",
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
			return false, err(S("You need the 'server' privilege to show the rules to another player"))
		end
	end
})