

player_info.nodes_to_check = {
  feet = vector.new(0,   0,    0),
  head = vector.new(0,   1.05,  0),
  below = vector.new(0, -0.55, 0),
  above = vector.new(0,  1.55, 0),
}

function player_info.do_node_checks(player)
  local name = player:get_player_name()
  local pli = player_info.p[name]
  local pos = player:get_pos()
  for node, vect in pairs(player_info.nodes_to_check) do
    pli.nodes[node] = minetest.get_node(vector.add(pos, vect)).name
  end

  if minetest.get_item_group(pli.nodes["feet"], "liquid") ~= 0 then
    pli.in_liquid = true
  else
    pli.in_liquid = false
  end
end


local function is_solid_block(pointed_thing)
  if pointed_thing.type == "node" then
    local node = minetest.get_node(pointed_thing.under)
    local def = minetest.registered_nodes[node.name]
    if def.walkable then
      return true
    end
  end
end
local function is_node(pointed_thing)
  if pointed_thing.type == "node" then
    return true
  end
end

function player_info.get_first_from_raycast(spos, epos, condition)
  local ray = minetest.raycast(spos, epos, false, true)
  for pointed_thing in ray do
    if condition(pointed_thing) then
      return pointed_thing
    end
  end
end

function player_info.do_raycasts(player)
  local name = player:get_player_name()
  local pli = player_info.p[name]
  local head_height = player:get_properties().collisionbox[5]
  local spos = player:get_pos()
  spos = vector.offset(spos, 0, head_height, 0)
  local epos = vector.offset(spos, 0, 0.01, 0)

  local pointed_thing = player_info.get_first_from_raycast(spos, epos, is_node)

  local pointed_node
  if pointed_thing then
    pointed_node = minetest.get_node(pointed_thing.under).name
  else
    local node = minetest.get_node(epos)
    local def = minetest.registered_nodes[node.name]
    if node.name ~= "air" and node.name ~= "ignore" and not def.pointable then
      pointed_node = node.name
    end
  end
  if true then
    if pointed_node ~= pli.head_node then
      -- minetest.log("FOUND NODE "..(pointed_node or ""))
      player_info.on_enter_node(player, "eyes", pointed_node, pli.head_node)
    end
    pli.head_node = pointed_node
  end
end

function player_info.positions_on_step(player, dtime)
  local name = player:get_player_name()
  local pli = player_info.p[name]
  player_info.do_node_checks(player)
  player_info.do_raycasts(player)
end

