


local function _debug(dtime)
  for _, player_ref in pairs(minetest.get_connected_players()) do
    local name = player_ref:get_player_name()
    if player_info.p[name].just_released.aux1 then
      local j = player_info.p[name].since_pressed.aux1 or 0
      player_ref:add_velocity(vector.new(0, 2 + j*10, 0))
    end
    if player_info.p[name].just_pressed.sneak
    and player_info.p[name].since_pressed.sneak
    and player_info.p[name].since_pressed.sneak < 1 then
      player_ref:add_velocity(vector.new(0, 10, 0))
    end
  end
end


-- minetest.register_globalstep(_debug)