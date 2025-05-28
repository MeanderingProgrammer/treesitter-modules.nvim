local selection = require('treesitter-modules.selection')

---@class (exact) ts.mod.incremental.Config
---@field enable boolean
---@field keymaps ts.mod.incremental.keymap.Config

---@class (exact) ts.mod.incremental.keymap.Config
---@field init_selection string|boolean
---@field node_incremental string|boolean
---@field scope_incremental string|boolean
---@field node_decremental string|boolean

---@class ts.mod.Incremental: ts.mod.Interface
---@field private config ts.mod.incremental.Config
local M = {}

---@type ts.mod.incremental.Config
M.default = {
    enable = false,
    keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm',
    },
}

---called from state on setup
---@param config ts.mod.incremental.Config
function M.setup(config)
    M.config = config
end

---@return string
function M.name()
    return 'incremental'
end

---@param ctx ts.mod.Context
---@return boolean
function M.enabled(ctx)
    return M.config.enable
end

---@param ctx ts.mod.Context
function M.attach(ctx)
    local keymaps = M.config.keymaps
    M.map(ctx, 'n', keymaps.init_selection, function()
        selection.init(ctx.buf, ctx.language)
    end, 'Start selecting nodes with treesitter-modules')
    M.map(ctx, 'x', keymaps.node_incremental, function()
        selection.node_incremental(ctx.buf, ctx.language)
    end, 'Increment selection to named node')
    M.map(ctx, 'x', keymaps.scope_incremental, function()
        selection.scope_incremental(ctx.buf, ctx.language)
    end, 'Increment selection to surrounding scope')
    M.map(ctx, 'x', keymaps.node_decremental, function()
        selection.node_decremental(ctx.buf, ctx.language)
    end, 'Shrink selection to previous named node')
end

---@private
---@param ctx ts.mod.Context
---@param mode string
---@param lhs string|boolean
---@param rhs function
---@param desc string
function M.map(ctx, mode, lhs, rhs, desc)
    if type(lhs) == 'boolean' then
        return
    end
    vim.keymap.set(mode, lhs, rhs, {
        buffer = ctx.buf,
        silent = true,
        desc = desc,
    })
end

---@param ctx ts.mod.Context
function M.detach(ctx)
    local keymaps = M.config.keymaps
    M.delete(ctx, 'n', keymaps.init_selection)
    M.delete(ctx, 'x', keymaps.node_incremental)
    M.delete(ctx, 'x', keymaps.scope_incremental)
    M.delete(ctx, 'x', keymaps.node_decremental)
end

---@private
---@param ctx ts.mod.Context
---@param mode string
---@param lhs string|boolean
function M.delete(ctx, mode, lhs)
    if type(lhs) == 'boolean' then
        return
    end
    pcall(vim.keymap.del, mode, lhs, { buffer = ctx.buf })
end

return M
