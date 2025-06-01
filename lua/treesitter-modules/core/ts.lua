local util = require('treesitter-modules.lib.util')

---@class (exact) ts.mod.ts.Config
---@field ensure_installed ts.mod.Languages
---@field ignore_install ts.mod.Languages
---@field sync_install boolean

---@alias ts.mod.Languages string|string[]

---@class ts.mod.Ts
---@field private config ts.mod.ts.Config
local M = {}

---called from state on setup
---@param config ts.mod.ts.Config
function M.setup(config)
    M.config = config
    local task = M.install(config.ensure_installed)
    if config.sync_install then
        task:wait()
    end
end

---@param languages ts.mod.Languages
---@return async.Task
function M.install(languages)
    local ignore = M.config.ignore_install
    local install = util.difference(M.resolve(languages), M.resolve(ignore))
    return require('nvim-treesitter').install(install)
end

---@private
---@param languages ts.mod.Languages
---@return string[]
function M.resolve(languages)
    local result = {} ---@type string[]
    if type(languages) == 'string' then
        result[#result + 1] = languages
    else
        result = languages
    end
    local all = vim.tbl_contains(result, 'all')
    return all and require('nvim-treesitter').get_available() or result
end

return M
