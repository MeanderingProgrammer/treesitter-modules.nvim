local ts = require('treesitter-modules.lib.ts')

---@class ts.mod.Selection
local M = {}

---@param buf integer
---@param language string
function M.init(buf, language)
    if not M.parse(buf, language) then
        return
    end
    local node = vim.treesitter.get_node({ bufnr = buf })
    if not node then
        return
    end
    M.select(M.api_range(buf, node))
end

---@param buf integer
---@param language string
function M.node_incremental(buf, language)
    if not M.parse(buf, language) then
        return
    end
    local node = vim.treesitter.get_node({ bufnr = buf })
    if not node then
        return
    end
    local i = 0
    local range = M.api_range(buf, node)
    -- TODO: selected node is too small
    while node and vim.deep_equal(range, M.api_range(buf, node)) do
        i = i + 1
        node = node:parent()
    end
    if not node then
        return
    end
    M.select(M.api_range(buf, node))
end

---@param buf integer
---@param language string
function M.scope_incremental(buf, language)
    -- TODO: implement
end

---@param buf integer
---@param language string
function M.node_decremental(buf, language)
    -- TODO: implement
end

---@private
---@param buf integer
---@param language string
---@return boolean
function M.parse(buf, language)
    local parser = ts.parser(buf, language)
    if not parser then
        return false
    end
    parser:parse({ vim.fn.line('w0') - 1, vim.fn.line('w$') })
    return true
end

---@private
---@param buf integer
---@param node TSNode
---@return Range4
function M.api_range(buf, node)
    local srow, scol, erow, ecol = node:range()
    srow = srow + 1
    erow = erow + 1
    if ecol == 0 then
        -- use the value of the last col of the previous row instead
        erow = erow - 1
        local lines = vim.api.nvim_buf_get_lines(buf, erow - 1, erow, false)
        ecol = math.max(#lines[1], 1)
    end
    return { srow, scol, erow, ecol - 1 }
end

---@private
---@param range Range4
function M.select(range)
    local mode = vim.api.nvim_get_mode()
    if mode.mode ~= 'v' then
        vim.api.nvim_cmd({ cmd = 'normal', bang = true, args = { 'v' } }, {})
    end
    vim.api.nvim_win_set_cursor(0, { range[1], range[2] })
    vim.cmd('normal! o')
    vim.api.nvim_win_set_cursor(0, { range[3], range[4] })
end

return M
