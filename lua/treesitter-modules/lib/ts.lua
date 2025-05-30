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

---@param language string
---@param name 'highlights'|'indents'|'locals'
---@return boolean
function M.has(language, name)
    return #vim.treesitter.query.get_files(language, name) > 0
end

---@param buf integer
---@param language string
---@param root TSNode
---@return TSNode[]
function M.scopes(buf, language, root)
    if not M.has(language, 'locals') then
        return {}
    end
    local query = vim.treesitter.query.get(language, 'locals')
    if not query then
        return {}
    end
    local result = {} ---@type TSNode[]
    local start, _, stop, _ = root:range()
    for _, match in query:iter_matches(root, buf, start, stop + 1) do
        for id, nodes in pairs(match) do
            local capture = query.captures[id]
            if capture == 'local.scope' then
                for _, node in ipairs(nodes) do
                    result[#result + 1] = node
                end
            end
        end
    end
    return result
end

return M
