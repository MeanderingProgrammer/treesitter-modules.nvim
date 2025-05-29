---@class ts.mod.Manager
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
    if not vim.treesitter.language.add(language) then
        return
    end
    for _, mod in ipairs(M.modules) do
        M.reattach_module(mod, { buf = buf, language = language })
    end
end

---@private
---@param mod ts.mod.Module
---@param ctx ts.mod.Context
function M.reattach_module(mod, ctx)
    local name = mod.name()
    if not mod.enabled(ctx) then
        return
    end
    if M.cache:has(name, ctx.buf) then
        M.cache:remove(name, ctx.buf)
        mod.detach(ctx)
    end
    if not M.cache:has(name, ctx.buf) then
        M.cache:add(name, ctx.buf)
        mod.attach(ctx)
    end
end

return M
