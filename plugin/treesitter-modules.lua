local initialized = false
if initialized then
    return
end
initialized = true

require('treesitter-modules').setup()
require('treesitter-modules.core.command').init()
require('treesitter-modules.core.manager').init()
