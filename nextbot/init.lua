local nextbots = {}
local static_spawn = {x = 8, y = -4.5, z = 8}

minetest.register_entity("nextbot:obunga", {
    initial_properties = {
        pointable = false,
        visual = "sprite",
        visual_size = {x = 5, y = 5},
        textures = {"obunga.png"},
    },

    dtime = 0,
    next_pos = nil,
    chasing = true,

    on_activate = function(self, staticdata)
        self.player = minetest.get_player_by_name(staticdata)
    end,

    on_step = function(self, dtime, collisions)
        if not self.player then
            self.object:remove()
            return
        end

        if not self.chasing then
            return
        end

        self.dtime = self.dtime + dtime
        
        local player_pos = self.player:get_pos()
        if player_pos == nil then return end
        local obunga_pos = vector.round(self.object:get_pos())
        local real_player_pos = player_pos
        player_pos.y = -4
        obunga_pos.y = -4

        if self.dtime > 0.1 then
            self.dtime = 0

            local new_path = minetest.find_path(obunga_pos, player_pos, 10, 2, 5, "A*")
            if new_path and #new_path > 1 then
                self.next_pos = new_path[2]
                self.next_pos.y = -2
            else
                self.next_pos = nil
            end

            if self.next_pos then
                local obunga_pos = vector.round(self.object:get_pos())
                self.object:set_pos(obunga_pos)

                local velocity = vector.subtract(self.next_pos, obunga_pos)
                velocity.y = 0
                velocity = vector.multiply(velocity, 10)
                self.object:set_velocity(velocity)
            end
        end

        if vector.distance(real_player_pos, obunga_pos) < 2 then
            self.player:set_hp(0)
            self.chasing = false
            self.object:set_velocity({x = 0, y = 0, z = 0})
            minetest.chat_send_all(self.player:get_player_name() .. " was killed by Obunga")
            
            minetest.after(2, function() self.object:remove() end)
        end
    end
})

function add_nextbot(player, nextbot)
    local random = math.random(1, 4)
    local offset = {
        {x = 20, y = 2.5, z = 0},
        {x = 0, y = 2.5, z = 20},
        {x = -20, y = 2.5, z = 0},
        {x = 0, y = 2.5, z = -20}
    }
    offset = offset[random]

    if nextbot == "obunga" then
        local obunga = minetest.add_entity(vector.add(player:get_pos(), offset), "nextbot:obunga", player:get_player_name())
        nextbots[player:get_player_name()] = obunga
    end

    local yaw = 0

    if offset.x > 0 then
        yaw = 270
    elseif offset.x < 0 then
        yaw = 90
    elseif offset.z < 0 then
        yaw = 180
    end

    player:set_look_horizontal(math.rad(yaw))
end

-- Helper functions
function handle_new_player(player)
    player:set_physics_override({speed = 2})

    if not minetest.check_player_privs(player, {no_nextbot = true}) then
        player:set_pos(static_spawn)
        add_nextbot(player, "obunga")
    end
end

function delete_player_nextbot(player)
    local nextbot = nextbots[player:get_player_name()]

    if nextbot then
        nextbot:remove()
        nextbots[player:get_player_name()] = nil
    end
end

-- Player registrations
minetest.register_on_newplayer(handle_new_player)
minetest.register_on_joinplayer(handle_new_player)
minetest.register_on_respawnplayer(function(player)
    handle_new_player(player)
    return true
end)

minetest.register_on_dieplayer(delete_player_nextbot)
minetest.register_on_leaveplayer(delete_player_nextbot)

-- Priveleges
minetest.register_privilege("no_nextbot", {
    description = "No nextbots will chase players with this privelege",
    give_to_admin = true
})

-- Chat commands
minetest.unregister_chatcommand("serverinfo")
minetest.unregister_chatcommand("spawn")

minetest.register_chatcommand("spawn", {
    description = "Teleport yourself or another player to spawn",
    params = "[player]",
    func = function(name, param)
        minetest.chat_send_all(minetest.serialize(param))
        if param ~= "" then
            local player = minetest.get_player_by_name(param)
            
            if player then
                if minetest.check_player_privs(name, {server = true}) then
                    player:set_pos(static_spawn)
                    minetest.chat_send_player(name, 'Teleported "' .. param .. '" to spawn')
                else
                    minetest.chat_send_player(name, "You cannot send another player to spawn")
                end
            else
                minetest.chat_send_player(name, '"' .. param .. '" either does not exist or is not logged in')
            end
        else
            local player = minetest.get_player_by_name(name)

            player:set_pos(static_spawn)
            minetest.chat_send_player(name, "Teleported to spawn")
        end
    end
})

minetest.register_chatcommand("who", {
    description = "List who is currently logged in",
    func = function(name)
        local message = "Clients: "

        for _, player in ipairs(minetest.get_connected_players()) do
            message = message .. player:get_player_name() .. ", "
        end

        minetest.chat_send_player(name, string.sub(message, 1, -3))
    end
})

minetest.register_chatcommand("add_nextbot", {
    description = "Add a nextbot for a player at your location",
    privs = {server = true},
    params = "<player> <bot>",
    func = function(name, param)
        local victim, bot = string.match(param, "(%w+)%s(%w+)")
        if not victim or not bot or victim == "" or bot == "" then
            minetest.chat_send_player(name, "Invalid parameters; see /help add_nextbot")
            return
        end
        local invoker = minetest.get_player_by_name(name)
        victim = minetest.get_player_by_name(victim)

        if victim then
            if minetest.check_player_privs(victim, {no_nextbot = true}) then
                minetest.chat_send_player(invoker:get_player_name(), '"' .. victim:get_player_name() .. '" has the "no_nextbot" privilege')
            else
                local invoker_pos = invoker:get_pos()
                invoker_pos.y = -2.5

                local nextbot = minetest.add_entity(invoker_pos, "nextbot:" .. bot, victim:get_player_name())
                nextbots[victim:get_player_name()] = nextbot
            end
        else
            minetest.chat_send_player(name, '"' .. victim:get_player_name() .. '" either does not exist or is not logged in')
        end
    end
})