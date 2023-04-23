local debug_path = minetest.get_worldpath() .. "/debug.txt"

-- Get the last <num_lines> lines of debug.txt (etim3 put it in the worldpath)
local function get_debug_lines(num_lines)
	local lines = {}
	local file = io.open(debug_path, "r")

	if file then
		local pos = file:seek("end")
		local lines_read = 0

		while pos > 0 and lines_read <= num_lines do
			local line = ""

			while true do
				pos = pos - 1
				file:seek("set", pos)
				local char = file:read(1)

				if char == "\n" or pos == 0 then
					if line ~= "" then
						line = line:sub(22, -1)

						if line:sub(1, 5) == "ERROR" then
							line = "#ff0000" .. line
						elseif line:sub(1, 7) == "WARNING" then
							line = "#ffff00" .. line
						elseif line:sub(1, 6) == "ACTION" then
							line = "#aaffaa" .. line
						end

						table.insert(lines, 1, line)
						lines_read = lines_read + 1
						break
					end
				else
					line = char .. line
				end
			end
		end

		file:close()

		if lines_read > 0 then
			return lines
		else
			return {"debug.txt is empty"}
		end
	else
		return {"debug.txt not found (path: " .. debug_path .. ")"}
	end
end

minetest.register_chatcommand("debug", {
	description = "Shows the last <lines> lines of debug.txt",
	privs = {server = true},
	params = "<lines>",

	func = function(name, lines)
		local num_lines = tonumber(lines)

		if not num_lines then
			minetest.chat_send_player(name, "Invalid line count")
			return
		end

		local formspec = "formspec_version[5]" ..
			"size[15, 10.5]" ..
			"no_prepend[]" ..
			"bgcolor[#111a]" ..
			"label[1, 1;Last " .. lines .. " lines of debug.txt:]" ..
			"button_exit[10, 8.5;4, 1;exit;Close]" ..
			"button[5.5, 8.5;4, 1;clear;Clear debug.txt]" ..
			"textlist[1, 1.5;13, 6.5;debug;"

		minetest.chat_send_player(name, "Retrieving...")

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
	minetest.show_formspec(player:get_player_name(), "clear_debug_confirm",
		"formspec_version[5]" ..
		"size[8.5, 4]" ..
		"no_prepend[]" ..
		"bgcolor[#111a]" ..
		"label[1, 1;Are you sure you want to delete debug.txt?]" ..
		"button_exit[1, 2;3, 1;exit;Cancel]" ..
		"button[4.5, 2;3, 1;clear_confirm;Delete]"
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- Clear debug.txt
	if minetest.check_player_privs(player, {server = true}) and fields.clear then
		minetest.close_formspec(player:get_player_name(), "debug")
		minetest.after(0.1, function() show_clear_debug_confirmation_formspec(player) end)

	-- Clear debug.txt confirmation
	elseif minetest.check_player_privs(player, {server = true}) and fields.clear_confirm then
		minetest.close_formspec(player:get_player_name(), "clear_debug_confirm")
		io.open(debug_path, "w"):close()
	end
end)