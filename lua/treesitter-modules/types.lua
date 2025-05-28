---@meta

---@class (exact) ts.mod.UserConfig
---@field highlight? ts.mod.hl.UserConfig
---@field incremental_selection? ts.mod.inc.UserConfig

---@class (exact) ts.mod.hl.UserConfig
---@field enable? boolean
---@field disable? string[]

---@class (exact) ts.mod.inc.UserConfig
---@field enable? boolean
---@field keymaps? ts.mod.inc.Keymaps
