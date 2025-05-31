---@meta

---@class (exact) ts.mod.UserConfig
---@field ensure_installed? ts.mod.Parsers
---@field ignore_install? ts.mod.Parsers
---@field sync_install? boolean
---@field auto_install? boolean
---@field fold? ts.mod.fold.UserConfig
---@field highlight? ts.mod.hl.UserConfig
---@field incremental_selection? ts.mod.inc.UserConfig
---@field indent? ts.mod.indent.UserConfig

---@class (exact) ts.mod.fold.UserConfig: ts.mod.module.UserConfig

---@class (exact) ts.mod.hl.UserConfig: ts.mod.module.UserConfig
---@field additional_vim_regex_highlighting? ts.mod.Condition

---@class (exact) ts.mod.inc.UserConfig: ts.mod.module.UserConfig
---@field keymaps? ts.mod.inc.Keymaps

---@class (exact) ts.mod.indent.UserConfig: ts.mod.module.UserConfig

---@class (exact) ts.mod.module.UserConfig
---@field enable? ts.mod.Condition
---@field disable? ts.mod.Condition
