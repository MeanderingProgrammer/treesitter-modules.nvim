local ts = require('treesitter-modules.lib.ts')

---@class ts.mod.Manager
local M = {}

---@private
M.group = vim.api.nvim_create_augroup('TreesitterModules', {})

---@private
M.cache = require('treesitter-modules.lib.cache').new()

---@private
---@type ts.mod.Interface[]
M.modules = {
    require('treesitter-modules.mods.highlight'),
    require('treesitter-modules.mods.incremental'),
}

---called from plugin directory
function M.init()
    vim.api.nvim_create_autocmd('FileType', {
        group = M.group,
        callback = function(args)
            M.reattach(args.buf)
        end,
    })
end

---@private
---@param buf integer
function M.reattach(buf)
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
    local language = vim.treesitter.language.get_lang(filetype) or filetype
    for _, mod in ipairs(M.modules) do
        M.reattach_module(mod, { buf = buf, language = language })
    end
end

---@private
---@param mod ts.mod.Interface
---@param ctx ts.mod.Context
function M.reattach_module(mod, ctx)
    local name = mod.name()
    if not ts.parser(ctx.buf, ctx.language) then
        return
    end
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
