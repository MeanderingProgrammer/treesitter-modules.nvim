---@module 'nvim-treesitter'

local ts = require('treesitter-modules.core.ts')

---@class (exact) ts.mod.manager.Config
---@field auto_install boolean

---@class ts.mod.Manager
---@field private config ts.mod.manager.Config
local M = {}

---@private
M.group = vim.api.nvim_create_augroup('TreesitterModules', {})

---@private
M.cache = require('treesitter-modules.lib.cache').new()

---@private
---@type ts.mod.Module[]
M.modules = {
    require('treesitter-modules.mods.fold'),
    require('treesitter-modules.mods.highlight'),
    require('treesitter-modules.mods.incremental'),
    require('treesitter-modules.mods.indent'),
}

---called from state on setup
---@param config ts.mod.manager.Config
function M.setup(config)
    M.config = config
end

---called from plugin directory
function M.init()
    vim.api.nvim_create_autocmd('FileType', {
        group = M.group,
        callback = function(args)
            local buf, filetype = args.buf, args.match
            local language = vim.treesitter.language.get_lang(filetype)
            if not language then
                return
            end
            local attached = M.attach(buf, language)
            if not attached and M.config.auto_install then
                ts.install(language):await(function()
                    M.attach(buf, language)
                end)
            end
        end,
    })
end

---@param buf integer
---@return string[]
function M.active(buf)
    local result = {} ---@type string[]
    for _, mod in ipairs(M.modules) do
        local name = mod.name()
        if M.cache:has(name, buf) then
            result[#result + 1] = name
        end
    end
    return result
end

---@private
---@param buf integer
---@param language string
---@return boolean
function M.attach(buf, language)
    if not vim.treesitter.language.add(language) then
        return false
    end
    ---@type ts.mod.Context
    local ctx = { buf = buf, language = language }
    for _, mod in ipairs(M.modules) do
        local name = mod.name()
        if mod.enabled(ctx) then
            if M.cache:has(name, buf) then
                M.cache:remove(name, buf)
                mod.detach(ctx)
            end
            if not M.cache:has(name, buf) then
                M.cache:add(name, buf)
                mod.attach(ctx)
            end
        end
    end
    return true
end

return M
