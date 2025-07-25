---@class ts.mod.State
local M = {}

---called from init on setup
---@param config ts.mod.Config
function M.setup(config)
    require('treesitter-modules.core.manager').setup({
        auto_install = config.auto_install,
    })
    require('treesitter-modules.core.ts').setup({
        ensure_installed = config.ensure_installed,
        ignore_install = config.ignore_install,
        sync_install = config.sync_install,
    })
    require('treesitter-modules.mods.fold').setup(config.fold)
    require('treesitter-modules.mods.highlight').setup(config.highlight)
    require('treesitter-modules.mods.incremental').setup(
        config.incremental_selection
    )
    require('treesitter-modules.mods.indent').setup(config.indent)
end

return M
