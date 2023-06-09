local S = minetest.get_translator("chatlog")
local chatlog_path = minetest.get_worldpath() .. "/chat.txt"

local function get_chat_lines(num_lines)
	local total_lines = 0
	for _ in io.lines(chatlog_path) do
		total_lines = total_lines + 1
	end

	local lines = {}
	local current_line = 0
	for line in io.lines(chatlog_path) do
		current_line = current_line + 1

		if current_line > total_lines - num_lines then
			table.insert(lines, line)
		end
	end

	if current_line == 0 then
		return {S("Chat log is empty")}
	end

	return lines
end

minetest.register_chatcommand("chatlog", {
	description = S("Show the last <lines> lines of the chat log"),
	privs = {server = true},
	params = "<lines>",

	func = function(name, lines)
		local num_lines = tonumber(lines)

		if not num_lines then
			minetest.chat_send_player(name, S("Invalid line count"))
			return
		end

		local formspec = "formspec_version[5]" ..
			"size[15, 10.5]" ..
			"no_prepend[]" ..
			"bgcolor[#111a]" ..
			"label[1, 1;" .. S("Last @1 lines of the chat:", lines) .. "]" ..
			"button_exit[10, 8.5;4, 1;exit_chatlog;" .. S("Close") .. "]" ..
			"button[5.5, 8.5;4, 1;clear_chatlog_btn;" .. S("Clear chat log") .. "]" ..
			"textlist[1, 1.5;13, 6.5;chatlog;"

		-- Add retrieving text here

		local chat_lines = get_chat_lines(num_lines)
		for _, line in ipairs(chat_lines) do
			formspec = formspec .. minetest.formspec_escape(line) .. ","
		end

		formspec = formspec:sub(1, -2)
		formspec = formspec .. "]"
		minetest.show_formspec(name, "chatlog", formspec)
	end
})

local function show_clear_chatlog_confirmation_formspec(player)
	minetest.show_formspec(player:get_player_name(), "clear_chatlog_confirmation",
		"formspec_version[5]" ..
		"size[8.5, 4]" ..
		"no_prepend[]" ..
		"bgcolor[#111a]" ..
		"label[1, 1;" .. S("Are you sure you want to delete the chat log?") .. "]" ..
		"button_exit[1, 2;3, 1;cancel_clear_chatlog;" .. S("Cancel") .. "]" ..
		"button[4.5, 2;3, 1;confirm_clear_chatlog;" .. S("Delete") .. "]"
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- Clear chatlog
	if minetest.check_player_privs(player, {server = true}) and formname == "chatlog" and fields.clear_chatlog_btn then
		minetest.close_formspec(player:get_player_name(), "chatlog")
		minetest.after(0.1, function() show_clear_chatlog_confirmation_formspec(player) end)

	-- Clear chatlog confirmation
	elseif minetest.check_player_privs(player, {server = true}) and
	  formname == "clear_chatlog_confirmation" and fields.confirm_clear_chatlog then
		minetest.close_formspec(player:get_player_name(), "clear_chatlog_confirmation")
		io.open(chatlog_path, "w"):close()
	end
end)

minetest.register_on_chat_message(function(name, message)
	local chat = io.open(chatlog_path, "a")
	chat:write(minetest.strip_colors(minetest.format_chat_message(name, message) .. "\n"))
	chat:close()
end)