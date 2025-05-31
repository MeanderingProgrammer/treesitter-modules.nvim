---@alias ts.mod.Condition
---| boolean
---| string[]
---| fun(ctx: ts.mod.Context): boolean

---@class ts.mod.Util
local M = {}

---@param config ts.mod.module.Config
---@param ctx ts.mod.Context
---@return boolean
function M.enabled(config, ctx)
    return M.evaluate(config.enable, ctx)
        and not M.evaluate(config.disable, ctx)
end

---@param condition ts.mod.Condition
---@param ctx ts.mod.Context
---@return boolean
function M.evaluate(condition, ctx)
    if type(condition) == 'boolean' then
        return condition
    elseif type(condition) == 'table' then
        return vim.tbl_contains(condition, ctx.language)
    elseif type(condition) == 'function' then
        return condition(ctx)
    else
        error(('invalid condition type: %s'):format(type(condition)))
    end
end

---@param language string
---@param name 'highlights'|'indents'|'locals'
---@return boolean
function M.has_query(language, name)
    return #vim.treesitter.query.get_files(language, name) > 0
end

---Elements in left that are also in right
---@param left string[]
---@param right string[]
---@return string[]
function M.intersection(left, right)
    return M.filter(left, function(value)
        return vim.tbl_contains(right, value)
    end)
end

---Elements in left that are not in right
---@param left string[]
---@param right string[]
---@return string[]
function M.difference(left, right)
    return M.filter(left, function(value)
        return not vim.tbl_contains(right, value)
    end)
end

---@private
---@param values string[]
---@param predicate fun(value: string): boolean
---@return string[]
function M.filter(values, predicate)
    local result = {} ---@type string[]
    for _, value in ipairs(values) do
        if predicate(value) then
            result[#result + 1] = value
        end
    end
    return result
end

return M
