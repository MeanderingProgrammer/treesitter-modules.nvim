---@class (exact) ts.mod.highlight.Config
---@field enable boolean

---@class ts.mod.Highlight: ts.mod.Interface
---@field private config ts.mod.highlight.Config
local M = {}

---@type ts.mod.highlight.Config
M.default = {
    enable = false,
}

---@private
---@type integer[]
M.buffers = {}

---called from state on setup
---@param config ts.mod.highlight.Config
function M.setup(config)
    M.config = config
end

---@return boolean
function M.enabled()
    return M.config.enable
end

---@param buf integer
function M.attach(buf)
    local reattach = vim.tbl_contains(M.buffers, buf)
    if vim.tbl_contains(M.buffers, buf) then
        vim.treesitter.stop(buf)
    end
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
    local language = vim.treesitter.language.get_lang(filetype) or filetype
    local files = vim.treesitter.query.get_files(language, 'highlights')
    if #files > 0 then
        vim.treesitter.start(buf, language)
    end
    if not reattach then
        M.buffers[#M.buffers + 1] = buf
    end
end

return M
