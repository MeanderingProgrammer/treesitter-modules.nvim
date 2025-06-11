---@class ts.mod.Command
local M = {}

---called from plugin directory
function M.init()
    vim.api.nvim_create_user_command('TSUpdateSync', function()
        require('nvim-treesitter').update():wait()
    end, { desc = 'Update installed treesitter parsers synchronously' })

    vim.api.nvim_create_user_command('TSModuleInfo', function()
        local buf = vim.api.nvim_get_current_buf()
        local active = require('treesitter-modules.core.manager').active(buf)
        local info = #active == 0 and 'none' or table.concat(active, ', ')
        vim.print(('active treesitter modules: %s'):format(info))
    end, { desc = 'Print information about active modules' })
end

return M
