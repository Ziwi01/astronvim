-- OpenCode v2 needs opencode.nvim `main` (the v1.x tags only speak the v1
-- `--port` + `/tui/*` API). `main` finds the background service through
-- ~/.local/state/opencode/service.json and prompts the most recently updated
-- session for Neovim's cwd. To go back to OpenCode v1, pin `tag = "v1.0.2"`.
-- Pane handling and mapping fixes live in polish.lua and plugins/mappings.lua.
---@type LazySpec
return {
  "NickvanDyke/opencode.nvim",
  branch = "main",
}
