---@class ts.mod.Init
local M = {}

---@class (exact) ts.mod.Config
---@field ensure_installed ts.mod.Parsers
---@field ignore_install ts.mod.Parsers
---@field sync_install boolean
---@field auto_install boolean
---@field highlight ts.mod.hl.Config
---@field incremental_selection ts.mod.inc.Config
---@field indent ts.mod.indent.Config

---@private
---@type boolean
M.initialized = false

---@type ts.mod.Config
M.default = {
    -- list of parser names, or 'all', that must be installed
    ensure_installed = {},
    -- list of parser names, or 'all', to ignore installing
    ignore_install = {},
    -- install parsers in ensure_installed synchronously
    sync_install = false,
    -- automatically install missing parsers when entering buffer
    auto_install = false,
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
