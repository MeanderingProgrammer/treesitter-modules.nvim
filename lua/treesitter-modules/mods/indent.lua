local util = require('treesitter-modules.lib.util')

---@class (exact) ts.mod.indent.Config: ts.mod.module.Config

---@class ts.mod.Indent: ts.mod.Module
---@field private config ts.mod.indent.Config
local M = {}

---@type ts.mod.indent.Config
M.default = {
    enable = false,
    disable = false,
}

---@private
---@type table<integer, string>
M.expressions = {}

---called from state on setup
---@param config ts.mod.indent.Config
function M.setup(config)
    M.config = config
end

---@return string
function M.name()
    return 'indent'
end

---@param ctx ts.mod.Context
---@return boolean
function M.enabled(ctx)
    return util.enabled(M.config, ctx)
        and util.has_query(ctx.language, 'indents')
end

---@param ctx ts.mod.Context
function M.attach(ctx)
    M.expressions[ctx.buf] = vim.bo.indentexpr
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

---@param ctx ts.mod.Context
function M.detach(ctx)
    vim.bo.indentexpr = M.expressions[ctx.buf]
end

return M
