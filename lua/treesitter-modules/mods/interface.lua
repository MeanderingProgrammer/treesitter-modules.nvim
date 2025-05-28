---@meta

---@class ts.mod.Context
---@field buf integer
---@field language string

---@class ts.mod.Interface
---@field name fun(): string
---@field enabled fun(ctx: ts.mod.Context): boolean
---@field attach fun(ctx: ts.mod.Context)
---@field detach fun(ctx: ts.mod.Context)
