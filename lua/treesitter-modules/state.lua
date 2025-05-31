local ts = require('treesitter-modules.ts')
local util = require('treesitter-modules.lib.util')

---@class ts.mod.State
---@field private config ts.mod.Config
local M = {}

---called from init on setup
---@param config ts.mod.Config
function M.setup(config)
    M.config = config
    require('treesitter-modules.manager').setup({
        ignore_install = M.config.ignore_install,
        auto_install = M.config.auto_install,
    })
    require('treesitter-modules.mods.fold').setup(config.fold)
    require('treesitter-modules.mods.highlight').setup(config.highlight)
    require('treesitter-modules.mods.incremental').setup(
        config.incremental_selection
    )
    require('treesitter-modules.mods.indent').setup(config.indent)
    M.install()
end

---@private
function M.install()
    -- while install skips existing parsers it also echos information without a
    -- way to turn it off, to avoid this on every startup we resolve the list of
    -- missing languages here and skip installing if there aren't any
    local install = ts.parsers(M.config.ensure_installed)
    if #install == 0 then
        return
    end
    install = util.difference(install, ts.parsers(M.config.ignore_install))
    if #install == 0 then
        return
    end
    install = util.difference(install, ts.installed())
    if #install == 0 then
        return
    end
    local task = require('nvim-treesitter').install(install)
    if M.config.sync_install then
        task:wait()
    end
end

return M
