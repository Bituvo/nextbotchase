-- Disable inventories
minetest.register_on_joinplayer(function(player)
	player:set_inventory_formspec("")
end)