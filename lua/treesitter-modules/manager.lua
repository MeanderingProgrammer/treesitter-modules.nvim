local ts = require('treesitter-modules.lib.ts')

---@class (exact) ts.mod.manager.Config
---@field ignore_install ts.mod.Parsers
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
            M.reattach(args.buf, args.match)
        end,
    })
end

---@private
---@param buf integer
---@param filetype string
function M.reattach(buf, filetype)
    local language = vim.treesitter.language.get_lang(filetype) or filetype
    if vim.treesitter.language.add(language) then
        M.reattach_modules(buf, language)
        return
    end
    -- attempt to install parser if it is missing when configured to
    if not M.config.auto_install then
        return
    end
    if vim.tbl_contains(ts.parsers(M.config.ignore_install), language) then
        return
    end
    if not vim.tbl_contains(ts.available(), language) then
        return
    end
    require('nvim-treesitter').install(language):await(function()
        M.reattach_modules(buf, language)
    end)
end

---@private
---@param buf integer
---@param language string
function M.reattach_modules(buf, language)
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
end

return M
