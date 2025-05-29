local selection = require('treesitter-modules.lib.selection')
local util = require('treesitter-modules.lib.util')

---@class (exact) ts.mod.inc.Config
---@field enable ts.mod.Condition
---@field disable ts.mod.Condition
---@field keymaps ts.mod.inc.Keymaps

---@alias ts.mod.inc.Keymaps table<ts.mod.inc.Kind, ts.mod.inc.Keymap>

---@alias ts.mod.inc.Kind
---| 'init_selection'
---| 'node_incremental'
---| 'scope_incremental'
---| 'node_decremental'

---@alias ts.mod.inc.Keymap string|false

---@class (exact) ts.mod.inc.Details
---@field [1] string mode
---@field [2] string description

---@class ts.mod.Inc: ts.mod.Module
---@field private config ts.mod.inc.Config
local M = {}

---@type ts.mod.inc.Config
M.default = {
    enable = false,
    disable = false,
    -- set value to `false` to disable individual mapping
    keymaps = {
        init_selection = 'gnn',
        node_incremental = 'grn',
        scope_incremental = 'grc',
        node_decremental = 'grm',
    },
}

---@private
---@type table<ts.mod.inc.Kind, ts.mod.inc.Details>
M.details = {
    init_selection = { 'n', 'Start selecting nodes with treesitter-modules' },
    node_incremental = { 'x', 'Increment selection to named node' },
    scope_incremental = { 'x', 'Increment selection to surrounding scope' },
    node_decremental = { 'x', 'Shrink selection to previous named node' },
}

---called from state on setup
---@param config ts.mod.inc.Config
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
    return util.evaluate(M.config.enable, ctx)
        and not util.evaluate(M.config.disable, ctx)
end

---@param ctx ts.mod.Context
function M.attach(ctx)
    M.map(ctx, 'init_selection', selection.init_selection)
    M.map(ctx, 'node_incremental', selection.node_incremental)
    M.map(ctx, 'scope_incremental', selection.scope_incremental)
    M.map(ctx, 'node_decremental', selection.node_decremental)
end

---@private
---@param ctx ts.mod.Context
---@param kind ts.mod.inc.Kind
---@param rhs fun(buf: integer, language: string)
function M.map(ctx, kind, rhs)
    local lhs = M.config.keymaps[kind]
    if lhs == false then
        return
    end
    local details = M.details[kind]
    vim.keymap.set(details[1], lhs, function()
        rhs(ctx.buf, ctx.language)
    end, { buffer = ctx.buf, silent = true, desc = details[2] })
end

---@param ctx ts.mod.Context
function M.detach(ctx)
    M.delete(ctx, 'init_selection')
    M.delete(ctx, 'node_incremental')
    M.delete(ctx, 'scope_incremental')
    M.delete(ctx, 'node_decremental')
end

---@private
---@param ctx ts.mod.Context
---@param kind ts.mod.inc.Kind
function M.delete(ctx, kind)
    local lhs = M.config.keymaps[kind]
    if lhs == false then
        return
    end
    local details = M.details[kind]
    pcall(vim.keymap.del, details[1], lhs, { buffer = ctx.buf })
end

return M
