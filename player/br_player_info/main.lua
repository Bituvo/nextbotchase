
local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

player_info = {
    version = "b1",
    p = {},
}


function player_info.player_die()
end
function player_info.player_leave()
end
function player_info.player_join()
end

local function get_controls_blank(val)
    return {
    sneak = val,
    up    = val,
    down  = val,
    left  = val,
    right = val,
    jump  = val,
    aux1  = val,
    aux2  = val,
    dig   = val,
    place = val,
    zoom  = val,
    }
end

player_info.on_released = get_controls_blank({})
player_info.on_pressed = get_controls_blank({})
player_info.on_moved = {}

local function get_shell()
    return {
        ctrl = get_controls_blank(false),
        just_released = {},
        just_pressed = {},
        since_pressed = get_controls_blank(0),
        since_released = get_controls_blank(0),
        health = 20,
        hunger = 20,
        invulnerable = false,
        can_sprint = true,
        creative = false,
        height = 1.7,
        eye_offset = vector.new(),
        hud_effect = {},
        head_node = false,
        nodes = {
        feet = "",
        head = "",
        below = "",
        above = "",},
        on_floor = false,
        in_liquid = false,
        is_moving = false,
        just_moved = false,
        last_pos = nil,
        damage_from = { fall = 1 }
    }
end


dofile(mod_path .. DIR_DELIM .. "head_in_node.lua")
dofile(mod_path .. DIR_DELIM .. "positions.lua")
dofile(mod_path .. DIR_DELIM .. "debug.lua")
dofile(mod_path .. DIR_DELIM .. "damage.lua")

function player_info.get(player_ref)
    if player_ref and player_ref.is_player and player_ref:is_player() then
        return player_info.p[player_ref:get_player_name()]
    else
        return nil
    end
end

function player_info.on_step(dtime)
    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        if not player_info.p[name] then player_info.p[name] = get_shell() end
        player_info.positions_on_step(player, dtime)
        player_info.p[name].eye_offset = player:get_eye_offset()
        player_info.p[name].eye_offset = vector.offset(vector.multiply(player_info.p[name].eye_offset, 0.1), 0, 1.7, 0)
    end
end

minetest.register_globalstep(player_info.on_step)

minetest.register_on_joinplayer(player_info.player_join)
minetest.register_on_leaveplayer(player_info.player_leave)
minetest.register_on_dieplayer(player_info.player_die)

