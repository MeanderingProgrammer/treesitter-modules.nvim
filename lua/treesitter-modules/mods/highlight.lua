---@class (exact) ts.mod.highlight.Config
---@field enable boolean
---@field disable string[]

---@class ts.mod.Highlight: ts.mod.Interface
---@field private config ts.mod.highlight.Config
local M = {}

---@type ts.mod.highlight.Config
M.default = {
    enable = false,
    disable = {},
}

---called from state on setup
---@param config ts.mod.highlight.Config
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
        and #vim.treesitter.query.get_files(ctx.language, 'highlights') > 0
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
