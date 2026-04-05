if vim.g.loaded_treesitter_modules then
    return
end
vim.g.loaded_treesitter_modules = true

require('treesitter-modules').setup()
require('treesitter-modules.core.command').init()
require('treesitter-modules.core.manager').init()
