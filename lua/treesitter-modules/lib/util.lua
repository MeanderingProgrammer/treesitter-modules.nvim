---@alias ts.mod.Condition
---| boolean
---| string[]
---| fun(ctx: ts.mod.Context): boolean

---@class ts.mod.Util
local M = {}

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

---@param left string[]
---@param right string[]
---@return string[]
function M.left_anti(left, right)
    local result = {} ---@type string[]
    for _, value in ipairs(left) do
        if not vim.tbl_contains(right, value) then
            result[#result + 1] = value
        end
    end
    return result
end

return M
