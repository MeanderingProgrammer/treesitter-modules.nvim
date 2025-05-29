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
    local languages = M.resolve_languages()
    if #languages == 0 then
        return
    end
    local missing = {} ---@type string[]
    local installed = require('nvim-treesitter').get_installed()
    for _, language in ipairs(languages) do
        if not vim.tbl_contains(installed, language) then
            missing[#missing + 1] = language
        end
    end
    if #missing == 0 then
        return
    end
    local task = require('nvim-treesitter').install(missing)
    if M.config.sync_install then
        task:wait()
    end
end

---@private
---@return string[]
function M.resolve_languages()
    local languages = {} ---@type string[]
    local install = M.config.ensure_installed
    if type(install) == 'string' then
        languages[#languages + 1] = install
    else
        languages = install
    end
    if vim.tbl_contains(languages, 'all') then
        languages = require('nvim-treesitter').get_available()
    end
    return languages
end

return M
