---@meta

---@class (exact) ts.mod.UserConfig
---@field ensure_installed? string|string[]
---@field highlight? ts.mod.hl.UserConfig
---@field incremental_selection? ts.mod.inc.UserConfig
---@field indent? ts.mod.indent.UserConfig

---@class (exact) ts.mod.hl.UserConfig
---@field enable? boolean
---@field disable? string[]

---@class (exact) ts.mod.inc.UserConfig
---@field enable? boolean
---@field keymaps? ts.mod.inc.Keymaps

---@class (exact) ts.mod.indent.UserConfig
---@field enable? boolean
