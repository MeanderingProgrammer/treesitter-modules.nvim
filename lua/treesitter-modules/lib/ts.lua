---@class ts.mod.Ts
local M = {}

---@param buf integer
---@param language string
---@return vim.treesitter.LanguageTree?
function M.parser(buf, language)
    local has, parser = pcall(vim.treesitter.get_parser, buf, language)
    return has and parser or nil
end

return M
