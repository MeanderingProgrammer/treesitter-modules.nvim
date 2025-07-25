---@class ts.mod.Set
---@field private set table<string, true?>
local Set = {}
Set.__index = Set

---@return ts.mod.Set
function Set.new()
    local self = setmetatable({}, Set)
    self.set = {}
    return self
end

---@param name string
---@return boolean
function Set:has(name)
    return self.set[name] == true
end

---@param name string
function Set:add(name)
    self.set[name] = true
end

---@param name string
function Set:remove(name)
    self.set[name] = nil
end

return Set
