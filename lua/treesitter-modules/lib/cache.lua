---@alias ts.mod.Set table<integer, true>

---@class ts.mod.Cache
---@field private sets table<string, ts.mod.Set>
local Cache = {}
Cache.__index = Cache

---@return ts.mod.Cache
function Cache.new()
    local self = setmetatable({}, Cache)
    self.sets = {}
    return self
end

---@param name string
---@param buf integer
---@return boolean
function Cache:has(name, buf)
    return self:get(name)[buf] == true
end

---@param name string
---@param buf integer
function Cache:add(name, buf)
    self:get(name)[buf] = true
end

---@param name string
---@param buf integer
function Cache:remove(name, buf)
    self:get(name)[buf] = nil
end

---@private
---@param name string
---@return ts.mod.Set
function Cache:get(name)
    if not self.sets[name] then
        self.sets[name] = {}
    end
    return assert(self.sets[name])
end

return Cache
