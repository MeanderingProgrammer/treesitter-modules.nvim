---@class ts.mod.Ts
local M = {}

---@param buf integer
---@param language string
---@return vim.treesitter.LanguageTree?
function M.parser(buf, language)
    local has, parser = pcall(vim.treesitter.get_parser, buf, language)
    return has and parser or nil
end

---@param language string
---@param name 'highlights'|'locals'
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
