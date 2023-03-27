local nextbots = {}
nextbot = {static_spawn = {x = 8, y = -4.5, z = 8}}

local default_nextbot_definition = {
    initial_properties = {
        pointable = false,
        visual = "sprite",
        visual_size = {x = 5, y = 5}
    },

    dtime = 0,
    deletion_timer = 0,
    next_pos = nil,
    started = false,
    chasing = false,

    on_activate = function(self, staticdata)
        self.player = minetest.get_player_by_name(staticdata)
    end
}

function register_nextbot(name, chat_name, speed)
    local new_nextbot_definition = default_nextbot_definition

    new_nextbot_definition.initial_properties.textures = {name .. ".png"}
    new_nextbot_definition.chat_name = chat_name
    new_nextbot_definition.on_step = function(self, dtime)
        if not self.player then
            self.object:remove()
            return
        end

        self.dtime = self.dtime + dtime

        if not self.started then
            if self.dtime > 1 then
                self.started = true
                self.chasing = true
                self.dtime = 0
            else
                return
            end
        end
        
        local player_pos = self.player:get_pos()
        if player_pos == nil then return end
        local bot_pos = vector.round(self.object:get_pos())
        local real_player_pos = player_pos
        player_pos.y = -4
        bot_pos.y = -4

        if self.chasing and self.dtime > 1 / speed then
            self.dtime = 0

            if self.player:get_hp() == 0 then
                self.object:remove()
                return
            end

            local new_path = minetest.find_path(bot_pos, player_pos, 10, 0, 0, "A*")
            if new_path and #new_path > 1 then
                self.next_pos = new_path[2]
                self.next_pos.y = -2
            else
                self.next_pos = nil
            end

            if self.next_pos then
                local bot_pos = vector.round(self.object:get_pos())
                self.object:set_pos(bot_pos)

                local velocity = vector.subtract(self.next_pos, bot_pos)
                velocity.y = 0
                velocity = vector.multiply(velocity, speed)
                self.object:set_velocity(velocity)
            end
        end

        if vector.distance(real_player_pos, bot_pos) < 2 then
            if self.deletion_timer == 0 then
                self.player:set_hp(0)
                self.chasing = false
                self.object:set_velocity({x = 0, y = 0, z = 0})

                minetest.chat_send_all(self.player:get_player_name() .. " was killed by " .. self.chat_name)
            elseif self.deletion_timer > 2 then
                self.object:remove()
                return
            end

            self.deletion_timer = self.deletion_timer + dtime
        end
    end

    minetest.register_entity("nextbot:" .. name, new_nextbot_definition)
end

-- Nextbot registration
register_nextbot("obunga", "Obunga", 10)

local nextbot_names = {"obunga"}

-- Helper functions
function add_nextbot(player, nextbot)
    local nextbot_exists = false
    for _, value in ipairs(nextbot_names) do
        if value == nextbot then
            nextbot_exists = true
        end
    end
    if not nextbot_exists then return end

    local random = math.random(1, 4)
    local offset = {
        {x = 20, y = 2.5, z = 0},
        {x = 0, y = 2.5, z = 20},
        {x = -20, y = 2.5, z = 0},
        {x = 0, y = 2.5, z = -20}
    }
    offset = offset[random]

    local bot_pos = vector.add(player:get_pos(), offset)
    local bot = minetest.add_entity(bot_pos, "nextbot:" .. nextbot, player:get_player_name())
    nextbots[player:get_player_name()] = bot

    local yaw = 0

    if offset.x > 0 then
        yaw = 270
    elseif offset.x < 0 then
        yaw = 90
    elseif offset.z < 0 then
        yaw = 180
    end

    player:set_look_horizontal(math.rad(yaw))
    player:set_look_vertical(0)
end

function handle_new_player(player)
    delete_player_nextbot(player)
    player:set_physics_override({speed = 2})

    if not minetest.check_player_privs(player, {no_nextbot = true}) and player:get_hp() > 0 then
        player:set_pos(nextbot.static_spawn)
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

minetest.register_on_leaveplayer(delete_player_nextbot)

-- Priveleges
minetest.register_privilege("no_nextbot", {
    description = "No nextbots will chase players with this privelege",
    give_to_admin = true
})

-- Chat commands
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

minetest.register_chatcommand("delete_nextbot", {
    description = "Delete a player's nextbot",
    privs = {server = true},
    params = "<player>",
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        delete_player_nextbot(player)
    end
})

minetest.register_chatcommand("restart", {
    description = "Restart the server after 20 seconds",
    privs = {server = true},
    params = "[reason]",
    func = function(name, param)
        minetest.request_shutdown(param, true, 20)
    end
})