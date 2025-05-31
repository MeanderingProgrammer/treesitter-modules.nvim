local ts = require('treesitter-modules.lib.ts')
local util = require('treesitter-modules.lib.util')

---@class (exact) ts.mod.hl.Config: ts.mod.module.Config
---@field additional_vim_regex_highlighting ts.mod.Condition

---@class ts.mod.Hl: ts.mod.Module
---@field private config ts.mod.hl.Config
local M = {}

---@type ts.mod.hl.Config
M.default = {
    enable = false,
    disable = false,
    -- setting this to true will run `:h syntax` and tree-sitter at the same time
    -- set this to `true` if you depend on 'syntax' being enabled
    -- using this option may slow down your editor, and duplicate highlights
    -- instead of `true` it can also be a list of languages
    additional_vim_regex_highlighting = false,
}

---called from state on setup
---@param config ts.mod.hl.Config
function M.setup(config)
    M.config = config
end

---@return string
function M.name()
    return 'highlight'
end

---@param ctx ts.mod.Context
---@return boolean
function M.enabled(ctx)
    return util.enabled(M.config, ctx) and ts.has(ctx.language, 'highlights')
end

---@param ctx ts.mod.Context
function M.attach(ctx)
    vim.treesitter.start(ctx.buf, ctx.language)
    if util.evaluate(M.config.additional_vim_regex_highlighting, ctx) then
        vim.bo[ctx.buf].syntax = 'on'
    end
end

---@param ctx ts.mod.Context
function M.detach(ctx)
    vim.treesitter.stop(ctx.buf)
end

return M
