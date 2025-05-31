---@alias ts.mod.Parsers string|string[]

---@class ts.mod.Ts
local M = {}

---@param parsers ts.mod.Parsers
---@return string[]
function M.parsers(parsers)
    local result = {} ---@type string[]
    if type(parsers) == 'string' then
        result[#result + 1] = parsers
    else
        result = parsers
    end
    return vim.tbl_contains(result, 'all') and M.available() or result
end

---@return string[]
function M.available()
    return require('nvim-treesitter').get_available()
end

---@return string[]
function M.installed()
    return require('nvim-treesitter').get_installed()
end

return M
