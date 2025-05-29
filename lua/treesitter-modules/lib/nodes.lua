---@class ts.mod.nodes.Entry
---@field tick integer
---@field nodes TSNode[]

---@class ts.mod.Nodes
---@field private entries table<integer, ts.mod.nodes.Entry>
local Nodes = {}
Nodes.__index = Nodes

---@return ts.mod.Nodes
function Nodes.new()
    local self = setmetatable({}, Nodes)
    self.entries = {}
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
    self.entries[buf] = nil
end

---@private
---@param buf integer
---@return TSNode[]
function Nodes:get(buf)
    -- clear nodes on change tick, calling any methods on invalid nodes causes
    -- neovim to hard crash
    local entry = self.entries[buf]
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    if not entry or entry.tick ~= tick then
        entry = { tick = tick, nodes = {} }
        self.entries[buf] = entry
    end
    return entry.nodes
end

return Nodes
