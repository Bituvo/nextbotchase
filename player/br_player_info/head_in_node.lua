
player_info.in_node_effect = {
    eyes = {},
    feet = {},
}
local hin = player_info.in_node_effect

function player_info.register_in_node_effect(param)
    if not hin[param.body_part] then hin[param.body_part] = {} end
    if not hin[param.body_part][param.node_name] then hin[param.body_part][param.node_name] = {} end
    local list = hin[param.body_part][param.node_name]
    param.hud_id = nil
    list[#list+1] = param
end

local function do_hud_effect(player, def)
    local hud_id = player:hud_add(def.hud)
    local p = player_info.p[player:get_player_name()]
    p.hud_effect[def.name] = hud_id
end
local function end_hud_effect(player, def)
    local hud_id = player_info.p[player:get_player_name()].hud_effect[def.name]
    local p = player_info.p[player:get_player_name()]
    p.hud_effect[def.name] = nil
    player:hud_remove(hud_id)
end

local function do_all_effects(player, body_part, enter_node, exit_node)
    if enter_node and hin[body_part][enter_node] then
        for i, def in ipairs(hin[body_part][enter_node]) do
            if def.on_enter then
                def.on_enter(player, def)
            end
            if def.hud then
                do_hud_effect(player, def)
            end
        end
    end
    if exit_node and hin[body_part][exit_node] then
        for i, def in ipairs(hin[body_part][exit_node]) do
            if def.on_exit then
                def.on_exit(player, def)
            end
            if def.hud then
                end_hud_effect(player, def)
            end
        end
    end
end

function player_info.on_enter_node(player, body_part, enter_node, exit_node)
    if hin[body_part] then
        do_all_effects(player, body_part, enter_node, exit_node)
    end
end

