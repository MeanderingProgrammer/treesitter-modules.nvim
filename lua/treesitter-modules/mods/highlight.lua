local ts = require('treesitter-modules.lib.ts')

---@class (exact) ts.mod.hl.Config
---@field enable boolean
---@field disable string[]

---@class ts.mod.Hl: ts.mod.Module
---@field private config ts.mod.hl.Config
local M = {}

---@type ts.mod.hl.Config
M.default = {
    enable = false,
    disable = {},
}

---called from state on setup
---@param config ts.mod.hl.Config
function M.setup(config)
    M.config = config
end

---@return string
function M.name()
    return 'highlight'
end

---@param ctx ts.mod.Context
---@return boolean
function M.enabled(ctx)
    return M.config.enable
        and not vim.tbl_contains(M.config.disable, ctx.language)
        and ts.has(ctx.language, 'highlights')
end

---@param ctx ts.mod.Context
function M.attach(ctx)
    vim.treesitter.start(ctx.buf, ctx.language)
end

---@param ctx ts.mod.Context
function M.detach(ctx)
    vim.treesitter.stop(ctx.buf)
end

return M
