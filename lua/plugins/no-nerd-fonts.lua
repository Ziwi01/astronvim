-- Plain glyphs when PROVEASIO_NERD_FONTS=0. `icons_enabled` (lazy_setup.lua) covers
-- what AstroNvim takes from AstroUI; the plugins below hardcode their own glyphs.
local nnf = require "no_nerd_fonts"
if not nnf.enabled then return {} end

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@param opts AstroUIOpts
    opts = function(_, opts)
      local status = opts.status or {}
      opts.status = status
      status.separators = vim.tbl_extend("force", status.separators or {}, {
        breadcrumbs = " > ",
        path = " > ",
      })
      -- The scrollbar uses block eighths; an empty character hides it. The
      -- percentage next to it stays.
      status.providers = status.providers or {}
      status.providers.scrollbar = vim.tbl_extend("force", status.providers.scrollbar or {}, { chars = { "" } })
    end,
  },
  {
    "echasnovski/mini.indentscope",
    optional = true,
    opts = function(_, opts) opts.symbol = "│" end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    opts = function(_, opts)
      opts.popup_border_style = "rounded"
      opts.source_selector = opts.source_selector or {}
      opts.source_selector.separator = { left = " ", right = " " }
    end,
  },
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      opts.picker = opts.picker or {}
      opts.picker.prompt = "> "
      -- AstroNvim sets the indent guide and scope line to ▏
      if opts.indent then
        for _, part in ipairs { "indent", "scope" } do
          opts.indent[part] = vim.tbl_extend("force", opts.indent[part] or {}, { char = "│" })
        end
      end
      local defaults = require("snacks.picker.config.defaults").defaults.icons
      opts.picker.icons = nnf.icons(vim.tbl_deep_extend("force", defaults, opts.picker.icons or {}), nnf.snacks_picker)
    end,
  },
  {
    "folke/noice.nvim",
    optional = true,
    opts = function(_, opts)
      opts.cmdline = opts.cmdline or {}
      opts.cmdline.format = vim.tbl_deep_extend("force", opts.cmdline.format or {}, {
        cmdline = { icon = ":" },
        search_down = { icon = "/" },
        search_up = { icon = "?" },
        filter = { icon = "$" },
        lua = { icon = "lua" },
        help = { icon = "?" },
        calculator = { icon = "=" },
        input = { icon = ">" },
      })
    end,
  },
}
