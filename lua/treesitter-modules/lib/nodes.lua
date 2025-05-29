---@class ts.mod.Nodes
---@field private values table<integer, TSNode[]>
local Nodes = {}
Nodes.__index = Nodes

---@return ts.mod.Nodes
function Nodes.new()
    local self = setmetatable({}, Nodes)
    self.values = {}
    return self
end

---@param buf integer
---@param node TSNode
function Nodes:push(buf, node)
    local nodes = self:get(buf)
    nodes[#nodes + 1] = node
end

---@param buf integer
---@return TSNode?
function Nodes:pop(buf)
    local nodes = self:get(buf)
    if #nodes > 0 then
        nodes[#nodes] = nil
    end
    return nodes[#nodes]
end

---@param buf integer
---@return TSNode?
function Nodes:last(buf)
    local nodes = self:get(buf)
    return nodes[#nodes]
end

---@param buf integer
function Nodes:clear(buf)
    self.values[buf] = {}
end

---@private
---@param buf integer
---@return TSNode[]
function Nodes:get(buf)
    if not self.values[buf] then
        self.values[buf] = {}
    end
    return assert(self.values[buf])
end

return Nodes
