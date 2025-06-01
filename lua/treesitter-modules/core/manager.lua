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
            M.attach(args.buf, args.match)
        end,
    })
end

---@private
---@param buf integer
---@param filetype string
function M.attach(buf, filetype)
    local language = vim.treesitter.language.get_lang(filetype) or filetype
    local attached = M.try_attach(buf, language)
    if M.config.auto_install and not attached then
        -- attempt to install missing language and attach
        ts.install(language):await(function()
            M.try_attach(buf, language)
        end)
    end
end

---@private
---@param buf integer
---@param language string
---@return boolean
function M.try_attach(buf, language)
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
