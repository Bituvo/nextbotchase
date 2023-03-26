

function player_info.release(player, key)
  player_info.p[player].ctrl[key] = false
  player_info.p[player].just_released[key] = true

  -- call functions registered to this action
  for i, func in pairs(player_info.on_released[key]) do
    func(player, key)
  end
end
function player_info.press(player, key)
  player_info.p[player].ctrl[key] = true
  player_info.p[player].just_pressed[key] = true

  -- call functions registered to this action
  for i, func in pairs(player_info.on_pressed[key]) do
    func(player, key)
  end
end
-- function player_info.hold(player, key, dtime)
--   player_info.p[player].since_pressed[key] = player_info.p[player].since_pressed[key] + dtime
-- end
function player_info.reset_just_pressed(player)
  player_info.p[player].just_pressed = {}
  player_info.p[player].just_released = {}
end
function player_info.count_time_since_released(player, dtime)
  for key, is_key in pairs(player_info.p[player].ctrl) do


    if player_info.p[player].just_pressed[key] then
      player_info.p[player].since_pressed[key] = dtime
    end
    if player_info.p[player].just_released[key] then
      player_info.p[player].since_released[key] = dtime
    end

    player_info.p[player].since_pressed[key] = player_info.p[player].since_pressed[key] + dtime
    player_info.p[player].since_released[key] = player_info.p[player].since_released[key] + dtime
  end
end

local move_key = {
  up = true, down = true, left = true, right = true
}

function player_info.controls_on_step(player, dtime)
  local name = player:get_player_name()
  local ctrl = player:get_player_control()

  -- keep track of how long it's been since you pressed a key
  -- do this now so it's a step behind the ctrl update
  player_info.count_time_since_released(name, dtime)

  player_info.reset_just_pressed(name)

  local pli = player_info.get(player)
  pli.just_moved = pli.is_moving
  pli.is_moving = false

  -- go through each key and compare them to the player's keys
  if ctrl then
    for key, oldval in pairs(player_info.p[name].ctrl) do

      -- if it's changes, say so
      if oldval ~= ctrl[key] then
        if oldval == false then
          player_info.press(name, key)
        elseif oldval == true then
          player_info.release(name, key)
        end
      -- if it's the same, count how long it's been the same
      elseif oldval == ctrl[key]
      and ctrl[key] then
        -- player_info.hold(name, key, dtime)
      end
      if ctrl[key] and not pli.is_moving and move_key[key] then
        pli.is_moving = ctrl[key]
        pli.just_moved = pli.is_moving and not pli.just_moved
      end
    end
    pli.is_sneaking = ctrl.sneak
    pli.is_punching = ctrl.dig
  end
end
