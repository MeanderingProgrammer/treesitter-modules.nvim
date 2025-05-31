local util = require('treesitter-modules.lib.util')

---@class (exact) ts.mod.fold.Config: ts.mod.module.Config

---@class ts.mod.Fold: ts.mod.Module
---@field private config ts.mod.fold.Config
local M = {}

---@type ts.mod.fold.Config
M.default = {
    enable = false,
    disable = false,
}

---@private
---@type table<integer, string>
M.methods = {}

---@private
---@type table<integer, string>
M.expressions = {}

---called from state on setup
---@param config ts.mod.fold.Config
function M.setup(config)
    M.config = config
end

---@return string
function M.name()
    return 'fold'
end

---@param ctx ts.mod.Context
---@return boolean
function M.enabled(ctx)
    return util.enabled(M.config, ctx)
end

---@param ctx ts.mod.Context
function M.attach(ctx)
    M.methods[ctx.buf] = vim.wo.foldmethod
    M.expressions[ctx.buf] = vim.wo.foldexpr
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
end

---@param ctx ts.mod.Context
function M.detach(ctx)
    vim.wo.foldmethod = M.methods[ctx.buf]
    vim.wo.foldexpr = M.expressions[ctx.buf]
end

return M
