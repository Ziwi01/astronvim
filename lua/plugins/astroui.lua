-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "astrodark",
    -- Group icons used in user.lua (Nerd Font v3, Material Design set)
    icons = {
      GitHub = "󰊤",
      Markdown = "󰍔",
      Table = "󰓫",
    },
  },
}
