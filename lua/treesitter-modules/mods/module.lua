---@meta

---@class (exact) ts.mod.module.Config
---@field enable ts.mod.Condition
---@field disable ts.mod.Condition

---@class ts.mod.Context
---@field buf integer
---@field language string

---@class ts.mod.Module
---@field name fun(): string
---@field enabled fun(ctx: ts.mod.Context): boolean
---@field attach fun(ctx: ts.mod.Context)
---@field detach fun(ctx: ts.mod.Context)
