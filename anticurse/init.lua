local storage = minetest.get_mod_storage()
-- Load current banned words, or empty list
local banned_words = storage:get_string("banned_words")
if banned_words == "" then
	banned_words = {}
else
	banned_words = minetest.deserialize(banned_words)
end

-- Return true if the message contains banned words
function handle_message(name, message)
	if minetest.check_player_privs(name, {server = true}) then return end

	message = string.lower(message)

	for _, word in ipairs(banned_words) do
		if string.find(message, word) then
			minetest.kick_player(name, "No cursing allowed!\n\nYou said: " .. message)
			server.admin_chat_send(minetest.colorize("red", name .. ": ") .. message)
			minetest.chat_send_all(name .. " kicked for cursing")
			minetest.log("action", name .. ' warned for cursing: "' .. message .. '"')
			
			return true
		end
	end
end

-- If a word is banned, return true and its index in the banned words list
function is_banned(word)
	for index, value in ipairs(banned_words) do
		if value == word then
			return true, index
		end
	end
end

-- Save desynced banned words list to mod storage
function update_banned_words()
	storage:set_string("banned_words", minetest.serialize(banned_words))
end

-- Handle all chat messages and chat commands
minetest.register_on_chat_message(function(name, message)
	return handle_message(name, message)
end)

minetest.register_on_chatcommand(function(name, command, params)
	if command == "msg" or command == "me" or command == "pm" then
		return handle_message(name, "/" .. command .. " " .. params)
	end
end)

-- Server chat commands
minetest.register_chatcommand("ban_word", {
	description = "Bans a word",
	privs = {server = true},
	params = "<word>",
	func = function(name, param)
		table.insert(banned_words, param)
		update_banned_words()

		minetest.chat_send_player(name, 'Banned "' .. param .. '"')
	end
})

minetest.register_chatcommand("unban_word", {
	description = "Unbans a word",
	privs = {server = true},
	params = "<word>",
	func = function(name, param)
		local banned, index = is_banned(param)

		if banned then
			table.remove(banned_words, index)
			update_banned_words()

			minetest.chat_send_player(name, 'Unbanned "' .. param .. '"')
		else
			minetest.chat_send_player(name, '"' .. param .. '" is already allowed')
		end
	end
})

minetest.register_chatcommand("list_banned_words", {
	description = "List all banned words",
	privs = {server = true},
	func = function(name)
		if #banned_words == 0 then
			minetest.chat_send_player(name, "There are no banned words")
		else
			local message = "Banned words: "

			for _, word in ipairs(banned_words) do
				message = message .. word .. ", "
			end

			minetest.chat_send_player(name, string.sub(message, 1, -3))
		end
	end
})