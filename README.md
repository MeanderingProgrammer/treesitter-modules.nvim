# treesitter-modules.nvim

Common modules to bridge nvim-treesitter & Neovim treesitter

> [!CAUTION]
>
> This plugin is extremely experimental at this stage and will likely need to change
> to accommodate updates to `nvim-treesitter`. Until the `main` branch becomes the
> default this plugin will also be in flux.

# Install

## lazy.nvim

```lua
{
    'MeanderingProgrammer/treesitter-modules.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ---@module 'treesitter-modules'
    ---@type ts.mod.UserConfig
    opts = {},
}
```

## packer.nvim

```lua
use({
    'MeanderingProgrammer/treesitter-modules.nvim',
    after = { 'nvim-treesitter' },
    config = function()
        require('treesitter-modules').setup({})
    end,
})
```

# Setup

## Default Configuration

```lua
require('treesitter-modules').setup({
    highlight = {
        enable = false,
        disable = {},
    },
    incremental_selection = {
        enable = false,
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
        },
    },
})
```

# Purpose

As [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) moves towards
a stable release they have made the decision to be less around providing functionality
directly, and more towards providing the tools to enable functionality. Specifically
they are focussed on making parsers and queries easily available, but not using those
queries to enable highlighting for example.

This makes a lot of sense in terms of maintenance, combining functionality with what
is essentially a package manager for parsers is a lot to put into one plugin and
splits developer effort over a large area. However, as a downside, users will now
need to write this common functionality within their individual configurations. It's
not complex logic, but for someone newer it may server as another barrier to entry.

This plugin aims to provide the functionality previously offered by `nvim-treesitter`
through simple configuration. It can also serves as a concrete example of how to
implement these functions within your own configuration. It is not meant to have
total parity with the original, option names may be different, some options may not
be available, some options may be new, and some may function slightly different.

While `nvim-treesitter` seeks to provide tools not functionality this plugin seeks
to provide common functionality not parity.

# Progress

- [ ] ensure_installed
- [x] highlight
- [x] incremental_selection
- [ ] indent
