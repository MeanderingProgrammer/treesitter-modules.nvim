---@meta

---@class (exact) ts.mod.UserConfig
---@field highlight? ts.mod.highlight.UserConfig
---@field incremental_selection? ts.mod.incremental.UserConfig

---@class (exact) ts.mod.highlight.UserConfig
---@field enable? boolean
---@field disable? string[]

---@class (exact) ts.mod.incremental.UserConfig
---@field enable? boolean
---@field keymaps? ts.mod.incremental.keymap.UserConfig

---@class (exact) ts.mod.incremental.keymap.UserConfig
---@field init_selection? string|boolean
---@field node_incremental? string|boolean
---@field scope_incremental? string|boolean
---@field node_decremental? string|boolean
