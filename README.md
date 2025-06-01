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
    requires = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
        require('treesitter-modules').setup({})
    end,
})
```

# Setup

## Default Configuration

```lua
require('treesitter-modules').setup({
    -- list of parser names, or 'all', that must be installed
    ensure_installed = {},
    -- list of parser names, or 'all', to ignore installing
    ignore_install = {},
    -- install parsers in ensure_installed synchronously
    sync_install = false,
    -- automatically install missing parsers when entering buffer
    auto_install = false,
    fold = {
        enable = false,
        disable = false,
    },
    highlight = {
        enable = false,
        disable = false,
        -- setting this to true will run `:h syntax` and tree-sitter at the same time
        -- set this to `true` if you depend on 'syntax' being enabled
        -- using this option may slow down your editor, and duplicate highlights
        -- instead of `true` it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = false,
        disable = false,
        -- set value to `false` to disable individual mapping
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
        },
    },
    indent = {
        enable = false,
        disable = false,
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

# Do I Need This Plugin?

The short answer to this question is always no, but in this particular case it depends
entirely on what features you care about. The new version of `nvim-treesitter` provides
powerful and simple APIs to replace all the old builtin modules, the only exception
to this is incremental selection. If you care about incremental selection specifically
then this plugin is an excellent choice to avoid writing your own implementation
of that feature, you're more than welcome to copy the code related to it from this
repo if you prefer to avoid the dependency. All other features can be implemented
in your configuration in about 20 lines of code. You can use the below examples as
a sort of migration guide as well, they are written for `lazy.nvim` but should be
simple to apply to other plugin managers.

## Implementing Yourself

```lua
-- this is what you previously passed to ensure_installed
local languages = { 'c', 'lua', 'rust' }
return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
        -- replicate `ensure_installed`, runs asynchronously, skips existing languages
        require('nvim-treesitter').install(languages)

        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('treesitter.setup', {}),
            callback = function(args)
                local buf = args.buf
                local filetype = args.match

                -- you need some mechanism to avoid running on buffers that do not
                -- correspond to a language (like oil.nvim buffers), this implementation
                -- checks if a parser exists for the current language
                local language = vim.treesitter.language.get_lang(filetype) or filetype
                if not vim.treesitter.language.add(language) then
                    return
                end

                -- replicate `fold = { enable = true }`
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

                -- replicate `highlight = { enable = true }`
                vim.treesitter.start(buf, language)

                -- replicate `indent = { enable = true }`
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                -- `incremental_selection = { enable = true }` cannot be easily replicated
            end,
        })
    end,
}
```

## Using this Plugin

```lua
-- this is what you previously passed to ensure_installed
local languages = { 'c', 'lua', 'rust' }
return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
    },
    {
        'MeanderingProgrammer/treesitter-modules.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        opts = {
            ensure_installed = languages,
            fold = { enable = true },
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = { enable = true },
        },
    },
}
```

# Progress

- [x] ensure_installed
- [x] highlight
- [x] incremental_selection
- [x] indent
