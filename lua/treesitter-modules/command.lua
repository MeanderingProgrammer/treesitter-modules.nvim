---@class ts.mod.Command
local M = {}

---called from plugin directory
function M.init()
    vim.api.nvim_create_user_command('TSUpdateSync', function()
        require('nvim-treesitter').update():wait()
    end, {
        desc = 'Update installed treesitter parsers synchronously',
    })
end

return M
