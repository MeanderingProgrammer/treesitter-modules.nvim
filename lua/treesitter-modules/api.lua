local selection = require('treesitter-modules.lib.selection')

---@param cb fun(buf: integer, language: string)
local function with_context(cb)
    local buf = vim.api.nvim_get_current_buf()
    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if ok and parser then
        cb(buf, parser:lang())
    end
end

---@class ts.mod.Api
local M = {}

function M.init_selection()
    with_context(selection.init_selection)
end

function M.node_incremental()
    with_context(selection.node_incremental)
end

function M.scope_incremental()
    with_context(selection.scope_incremental)
end

function M.node_decremental()
    with_context(selection.node_decremental)
end

return M
