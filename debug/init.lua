local S = minetest.get_translator("debug")
local debug_path = minetest.get_worldpath() .. "/debug.txt"

-- Get the last <num_lines> lines of debug.txt (etim3 put it in the worldpath)
local function get_debug_lines(num_lines)
	local lines = {}
	local lines_read = 0

	for line in io.lines(debug_path) do
		if #lines <= num_lines then
			if line == "  Separator" then
				table.insert(lines, "")
				table.insert(lines, "#00ff00Server restarted")
				table.insert(lines, "")
				lines_read = lines_read + 3
			else
				line = line:sub(22, -1)

				if line ~= "" then
					if line:sub(1, 5) == "ERROR" then
						line = "#ff0000" .. line
					elseif line:sub(1, 7) == "WARNING" then
						line = "#ffff00" .. line
					elseif line:sub(1, 6) == "ACTION" then
						line = "#aaffaa" .. line
					end

					table.insert(lines, line)
					lines_read = lines_read + 1
				end
			end
		end
	end

	if lines_read > 0 then
		return lines
	else
		return {S("The debug file is empty")}
	end
end

minetest.register_chatcommand("debug", {
	description = S("Shows the last <lines> lines of the debug file"),
	privs = {server = true},
	params = "<lines>",

	func = function(name, lines)
		local num_lines = tonumber(lines)

		if not num_lines then
			minetest.chat_send_player(name, S("Invalid line count"))
			return
		end

		local formspec = "formspec_version[5]" ..
			"size[20, 10.5]" ..
			"no_prepend[]" ..
			"bgcolor[#111a]" ..
			"label[1, 1;" .. S("Last @1 lines of debug file:", lines) .. "]" ..
			"button_exit[15, 8.5;4, 1;exit_debug;" .. S("Close") .. "]" ..
			"button[10, 8.5;4.5, 1;clear_debug_btn;" .. S("Clear debug file") .. "]" ..
			"textlist[1, 1.5;18, 6.5;debug;"

		-- Add retrieving text here

		local debug_lines = get_debug_lines(num_lines)
		for _, line in ipairs(debug_lines) do
			formspec = formspec .. minetest.formspec_escape(line) .. ","
		end

		formspec = formspec:sub(1, -2)
		formspec = formspec .. "]"

		minetest.show_formspec(name, "debug", formspec)
	end
})

local function show_clear_debug_confirmation_formspec(player)
	minetest.show_formspec(player:get_player_name(), "clear_debug_confirmation",
		"formspec_version[5]" ..
		"size[8.5, 4]" ..
		"no_prepend[]" ..
		"bgcolor[#111a]" ..
		"label[1, 1;" .. S("Are you sure you want to clear the debug file?") .. "]" ..
		"button_exit[1, 2;3, 1;cancel_clear_debug;" .. S("Cancel") .. "]" ..
		"button[4.5, 2;3, 1;confirm_clear_debug;" .. S("Delete") .. "]"
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- Clear debug.txt
	if minetest.check_player_privs(player, {server = true}) and formname == "debug" and fields.clear_debug_btn then
		minetest.close_formspec(player:get_player_name(), "debug")
		minetest.after(0.1, function() show_clear_debug_confirmation_formspec(player) end)

	-- Clear debug.txt confirmation
	elseif minetest.check_player_privs(player, {server = true}) and formname == "clear_debug_confirmation" and fields.confirm_clear_debug then
		minetest.close_formspec(player:get_player_name(), "clear_debug_confirmation")
		io.open(debug_path, "w"):close()
	end
end)