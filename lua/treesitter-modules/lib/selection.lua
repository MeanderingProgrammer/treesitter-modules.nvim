local Range = require('treesitter-modules.lib.range')
local ts = require('treesitter-modules.lib.ts')

---@class ts.mod.Selection
local M = {}

---@private
M.nodes = require('treesitter-modules.lib.nodes').new()

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
    if node then
        M.nodes:push(buf, node)
        M.select(node)
    end
end

---@param buf integer
---@param language string
function M.node_incremental(buf, language)
    local parser = M.parse(buf, language)
    if not parser then
        return
    end

    local range = Range.visual()
    local last = M.nodes:last(buf)
    local node = nil ---@type TSNode?

    if not last or not range:same(Range.node(last)) then
        -- handle re-initialization
        node = parser:named_node_for_range(range:ts(), {
            ignore_injections = false,
        })
        M.nodes:clear(buf)
    else
        -- iterate through parent parsers and nodes until we find a node with
        -- a different range
        parser = parser:language_for_range(range:ts())
        while parser and not node do
            node = parser:named_node_for_range(range:ts())
            while node and range:same(Range.node(node)) do
                node = node:parent()
            end
            parser = parser:parent()
        end
    end

    if node then
        M.nodes:push(buf, node)
        M.select(node)
    end
end

---@param buf integer
---@param language string
function M.scope_incremental(buf, language)
    -- TODO: implement
end

---@param buf integer
---@param language string
function M.node_decremental(buf, language)
    -- NOTE: if a user does incremental selection, moves the cursor, enters
    -- visual mode, then triggers this function, they will still jump back to
    -- their previous selection, this behavior matches the original.
    local node = M.nodes:pop(buf)
    if node then
        M.select(node)
    end
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
---@param node TSNode
function M.select(node)
    local range = Range.node(node)
    local mode = vim.api.nvim_get_mode()
    if mode.mode ~= 'v' then
        vim.api.nvim_cmd({ cmd = 'normal', bang = true, args = { 'v' } }, {})
    end
    vim.api.nvim_win_set_cursor(0, range:cursor_start())
    vim.cmd('normal! o')
    vim.api.nvim_win_set_cursor(0, range:cursor_end())
end

return M
