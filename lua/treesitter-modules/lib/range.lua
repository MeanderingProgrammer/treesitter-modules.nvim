---@class ts.mod.Range
---@field private range Range4 0-based inclusive
local Range = {}
Range.__index = Range

---@param node TSNode
---@return ts.mod.Range
function Range.node(node)
    local srow, scol, erow, ecol = node:range()
    -- have: 0-indexed exclusive (unaligned)
    if ecol == 0 then
        -- ending at the start of a row requires moving to the end of the
        -- previous row to ensure result is aligned to end of line
        erow = erow - 1
        local line = vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1]
        ecol = math.max(#line, 1)
    end
    -- have: 0-indexed exclusive (aligned)
    ecol = ecol - 1
    -- have: 0-indexed inclusive (aligned)
    return Range.new({ srow, scol, erow, ecol })
end

---@return ts.mod.Range
function Range.visual()
    local _, srow, scol, _ = unpack(vim.fn.getpos('.'))
    local _, erow, ecol, _ = unpack(vim.fn.getpos('v'))
    -- have: 1-indexed inclusive
    srow = srow - 1
    scol = scol - 1
    erow = erow - 1
    ecol = ecol - 1
    -- have: 0-indexed inclusive
    if srow < erow or (srow == erow and scol <= ecol) then
        return Range.new({ srow, scol, erow, ecol })
    else
        return Range.new({ erow, ecol, srow, scol })
    end
end

---@private
---@param range Range4 0-based inclusive
---@return ts.mod.Range
function Range.new(range)
    local self = setmetatable({}, Range)
    self.range = range
    return self
end

---@param other ts.mod.Range
---@return boolean
function Range:same(other)
    return vim.deep_equal(self.range, other.range)
end

---@return integer[]
function Range:pos_start()
    return Range.pos(self.range[1], self.range[2])
end

---@return integer[]
function Range:pos_end()
    return Range.pos(self.range[3], self.range[4])
end

---@private
---@param row integer
---@param col integer
---@return integer[]
function Range.pos(row, col)
    return { 0, row + 1, col + 1, 0 }
end

---@return Range4
function Range:ts()
    -- 0-indexed inclusive -> 0-indexed exclusive
    ---@type Range4
    return { self.range[1], self.range[2], self.range[3], self.range[4] + 1 }
end

return Range
