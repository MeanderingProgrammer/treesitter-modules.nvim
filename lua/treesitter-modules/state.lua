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
    require('treesitter-modules.mods.indent').setup(config.indent)
    M.install(config.ensure_installed)
end

---@private
---@param languages string|string[]
function M.install(languages)
    if #languages == 0 then
        return
    end
    require('nvim-treesitter').install(languages)
end

return M
