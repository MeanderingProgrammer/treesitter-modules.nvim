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
    M.install()
end

---@private
function M.install()
    local languages = M.config.ensure_installed
    if #languages == 0 then
        return
    end
    local task = require('nvim-treesitter').install(languages)
    if M.config.sync_install then
        task:wait()
    end
end

return M
