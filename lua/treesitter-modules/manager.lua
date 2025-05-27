---@class ts.mod.Manager
local M = {}

---@private
M.group = vim.api.nvim_create_augroup('TreesitterModules', {})

---@private
---@type ts.mod.Interface[]
M.modules = {
    require('treesitter-modules.mods.highlight'),
}

---called from plugin directory
function M.init()
    vim.api.nvim_create_autocmd('FileType', {
        group = M.group,
        callback = function(args)
            M.attach(args.buf)
        end,
    })
end

---@private
---@param buf integer
function M.attach(buf)
    for _, mod in ipairs(M.modules) do
        if mod.enabled() then
            mod.attach(buf)
        end
    end
end

return M
