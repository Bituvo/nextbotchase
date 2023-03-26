local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)


local save_path = minetest.get_worldpath()
local function find_backend()
    local file = io.open(save_path..DIR_DELIM.."world.mt", "r")
    if not file then
        minetest.chat_send_all("ERROR: CANNOT OPEN world.mt TO CHECK BACKEND. ASSUMING \"sqlite3\".")
        return "sqlite3"
    end
    local content = file:read("*a")
    content = string.split(content, "\n")
    for i, line in pairs(content) do
        local st = string.split(line, " = ")
        if st[1] == "backend" then
            return st[2]
        end
    end
end
local backend = find_backend()

local changes_made = false
world_storage = {
    data = {},
    get_file = function(self, mode)
        local file = io.open(save_path..DIR_DELIM.."_world_storage.txt", mode)
        return file
    end,
    save = function(self)
        local file = self:get_file("w")
        local datastring = minetest.serialize(self.data)
        changes_made = false
        file:write(datastring)
        file:close()
        minetest.log("action", "saving storage")
    end,
    load = function(self)
        local file = self:get_file("r")
        if not file then
            self:save()
            return
        end
        local data = minetest.deserialize(file:read("*a"))
        file:close()
        if data then self.data = table.copy(data)
        else
            self:save()
            minetest.log("warning", "CANNOT READ world_storage FILE!")
        end
    end,
    get_key = function(self, key)
        -- self:load()
        return self.data[key]
    end,
    set_key = function(self, key, val)
        self.data[key] = val
        changes_made = true
        -- self:save()
    end,
}
if backend == "dummy" then
    world_storage.data = {}
    world_storage:save()
else
    world_storage:load()
end

local timer = 0
minetest.register_globalstep(function(dtime)
    if not changes_made then return end
    if timer < 5 then timer = timer + dtime return
    else timer = 0 end
    world_storage:save()
end)

world_storage:set_key("yay", 2987)

minetest.register_on_leaveplayer(function(ObjectRef, timed_out)
    world_storage:save()
end)
