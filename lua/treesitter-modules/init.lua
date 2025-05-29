---@class ts.mod.Init
local M = {}

---@class (exact) ts.mod.Config
---@field ensure_installed string|string[]
---@field highlight ts.mod.hl.Config
---@field incremental_selection ts.mod.inc.Config
---@field indent ts.mod.indent.Config

---@private
---@type boolean
M.initialized = false

---@type ts.mod.Config
M.default = {
    ensure_installed = {},
    highlight = require('treesitter-modules.mods.highlight').default,
    incremental_selection = require('treesitter-modules.mods.incremental').default,
    indent = require('treesitter-modules.mods.indent').default,
}

---@param opts? ts.mod.UserConfig
function M.setup(opts)
    -- skip initialization if already done and input is empty
    if M.initialized and vim.tbl_count(opts or {}) == 0 then
        return
    end
    M.initialized = true
    local config = vim.tbl_deep_extend('force', M.default, opts or {})
    require('treesitter-modules.state').setup(config)
end

return M
