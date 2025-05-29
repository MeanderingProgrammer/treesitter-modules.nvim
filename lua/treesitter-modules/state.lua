local util = require('treesitter-modules.lib.util')

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
    -- while install skips existing parsers it also echos information without a
    -- way to turn it off, to avoid this on every startup we resolve the list of
    -- missing languages here and skip installing if there aren't any
    local install = M.resolve_install(M.config.ensure_installed)
    if #install == 0 then
        return
    end

    local ignore = M.resolve_install(M.config.ignore_install)
    install = util.left_anti(install, ignore)
    if #install == 0 then
        return
    end

    local installed = require('nvim-treesitter').get_installed()
    install = util.left_anti(install, installed)
    if #install == 0 then
        return
    end

    local task = require('nvim-treesitter').install(install)
    if M.config.sync_install then
        task:wait()
    end
end

---@private
---@param install ts.mod.Install
---@return string[]
function M.resolve_install(install)
    local result = {} ---@type string[]
    if type(install) == 'string' then
        result[#result + 1] = install
    else
        result = install
    end
    if vim.tbl_contains(result, 'all') then
        result = require('nvim-treesitter').get_available()
    end
    return result
end

return M
