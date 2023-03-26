

-- this is intended to form a node update system, where if a node is updated by being dug, it notifies its neighbours in case they need to do something in response.

pmb_node_update = {}


pmb_node_update.update_functions = {}


local calls = 0
local call_limit = 500 -- per step

local function reset_calls(dtime)
  -- if calls ~= 0 then
  --   minetest.log(calls)
  -- end
  calls = 0
end

minetest.register_globalstep(reset_calls)

function pmb_node_update.register_on_node_update(name, func)
  pmb_node_update.update_functions[name] = func
end

local adjacent = {
  [0] = vector.new(0, 1, 0),
  [1] = vector.new(0, -1, 0),
  [2] = vector.new(1, 0, 0),
  [3] = vector.new(-1, 0, 0),
  [4] = vector.new(0, 0, 1),
  [5] = vector.new(0, 0, -1),
}

function pmb_node_update.update_node_propagate(pos, cause, user, count, delay, payload, last_pos)
  if not delay then delay = 0.1 end
  -- only allow a certain limit on total updates per server step
  calls = calls + 1
  if calls > call_limit then
    minetest.log("warning", "WARNING! TOO MANY NODE UPDATES ARE HAPPENING.")
    return false end

  -- only allow 15 recursions per update
  if count <= 0 then return end

  if not last_pos then
    pmb_node_update.update_node(pos, cause, user, count-1, delay, payload, pos)
  end
  local offset = 2 -- math.random(0, 5)
  for i=0, #adjacent do
    local p = adjacent[(i + offset) % 6]
    local v = vector.add(pos, p)
    if (not last_pos) or v ~= last_pos then
      -- the first update should be instant, and if you set the delay to 0 then
      if count == 0 or delay == 0 then
        pmb_node_update.update_node(v, cause, user, count-1, delay, payload, pos)
      else
        minetest.after(delay, pmb_node_update.update_node, v, cause, user, count+1, delay, payload, pos)
      end
    end
  end
end

function pmb_node_update.update_node(pos, cause, user, count, delay, payload, last_pos)
  if count <= 0 then return false end

  local node = minetest.registered_nodes[(minetest.get_node(pos).name)]

  if node then
    local updated = false
    if node._on_node_update then
      -- allow the payload to propogate
      payload = node._on_node_update(pos, cause, user, count-1, payload, last_pos)
      if payload ~= false and payload ~= nil then
        updated = true
      end
    end
    -- go through the registered update funcs and if any of them return true, propogate the update
    for _, node_func in pairs(pmb_node_update.update_functions) do
      if node_func(pos, cause, user, count) then
        updated = true
      end
    end

    if updated then
      pmb_node_update.update_node_propagate(pos, cause, user, count-1, delay, payload, last_pos)
      return true
    end
  end
end



minetest.register_on_dignode(
  function(pos, oldnode, digger)
    pmb_node_update.update_node_propagate(pos, "dig", digger, 15)
  end
)
minetest.register_on_placenode(
  function(pos, oldnode, digger)
    pmb_node_update.update_node_propagate(pos, "place", digger, 15)
  end
)
minetest.register_on_punchnode(
  function(pos, node, puncher, pointed_thing)
    pmb_node_update.update_node(pos, "punch", puncher, 15)
  end
)


