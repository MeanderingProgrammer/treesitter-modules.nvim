---@class ts.mod.State
---@field private config ts.mod.Config
local M = {}

---called from init on setup
---@param config ts.mod.Config
function M.setup(config)
    M.config = config
    require('treesitter-modules.mods.highlight').setup(config.highlight)
    require('treesitter-modules.mods.incremental').setup(
        config.incremental_selection
    )
end

return M
