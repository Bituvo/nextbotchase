local S = minetest.get_translator("anticurse")
local modpath = minetest.get_modpath("anticurse")

local function load_blacklist()
	return io.lines(modpath .. "/blacklist.txt")
end

local function handle_message(name, message)
	for word in load_blacklist() do
		if string.find(message, "%f[%a]" .. word .. "%f[%A]") then
			minetest.kick_player(name, S("No cursing allowed!") .. "\n\n" .. S('You said: "@1" (@2)', message, word))
			server.admin_chat_send(S('Kicked @1 for cursing ("@2")', name, message))
			minetest.log("action", "Kicked " .. name .. ' for cursing ("' .. message .. '")')

			return true
		end
	end
end

minetest.register_on_chat_message(function(name, message)
	return handle_message(name, message)
end)