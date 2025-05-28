local Range = require('treesitter-modules.lib.range')
local ts = require('treesitter-modules.lib.ts')

---@class ts.mod.Selection
local M = {}

---@param buf integer
---@param language string
function M.init_selection(buf, language)
    local parser = M.parse(buf, language)
    if not parser then
        return
    end
    local node = vim.treesitter.get_node({
        bufnr = buf,
        ignore_injections = false,
    })
    if not node then
        return
    end
    M.select(Range.node(node))
end

---@param buf integer
---@param language string
function M.node_incremental(buf, language)
    local parser = M.parse(buf, language)
    if not parser then
        return
    end
    -- iterate through parent parsers and nodes until we find a node outside of range
    local range = Range.visual()
    parser = parser:language_for_range(range:ts())
    local node = nil ---@type TSNode?
    while parser and not node do
        node = parser:named_node_for_range(range:ts())
        while node and range:same(Range.node(node)) do
            node = node:parent()
        end
        parser = parser:parent()
    end
    if not node then
        return
    end
    M.select(Range.node(node))
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
---@return vim.treesitter.LanguageTree?
function M.parse(buf, language)
    local parser = ts.parser(buf, language)
    if not parser then
        return nil
    end
    -- 1-indexed inclusive -> 0-indexed exclusive
    local first, last = vim.fn.line('w0'), vim.fn.line('w$')
    parser:parse({ first - 1, last })
    return parser
end

---@private
---@param range ts.mod.Range
function M.select(range)
    local mode = vim.api.nvim_get_mode()
    if mode.mode ~= 'v' then
        vim.api.nvim_cmd({ cmd = 'normal', bang = true, args = { 'v' } }, {})
    end
    vim.api.nvim_win_set_cursor(0, range:cursor_start())
    vim.cmd('normal! o')
    vim.api.nvim_win_set_cursor(0, range:cursor_end())
end

return M
