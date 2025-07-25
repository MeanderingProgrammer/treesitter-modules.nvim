local Set = require('treesitter-modules.lib.set')

---@class ts.mod.Cache
---@field private sets table<integer, ts.mod.Set?>
local Cache = {}
Cache.__index = Cache

---@return ts.mod.Cache
function Cache.new()
    local self = setmetatable({}, Cache)
    self.sets = {}
    return self
end

---@param buf integer
---@return ts.mod.Set
function Cache:get(buf)
    if not self.sets[buf] then
        self.sets[buf] = Set.new()
    end
    return assert(self.sets[buf])
end

return Cache
