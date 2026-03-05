return { -- override blink.cmp plugin
  "Saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "super-tab",
      ["<Up>"] = {},
      ["<Down>"] = {},
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.snippet_jump_backward()
          elseif cmp.is_visible() then
            return cmp.select_prev()
          end
        end,
        function()
          -- Dismiss Copilot inline suggestion if visible
          if require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").dismiss()
            return true
          end
        end,
        "fallback",
      },
      -- Cycle Copilot inline suggestions
      ["<M-]>"] = {
        function()
          if require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").next()
            return true
          end
        end,
        "fallback",
      },
      ["<M-[>"] = {
        function()
          if require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").prev()
            return true
          end
        end,
        "fallback",
      },
      -- Accept Copilot inline suggestion when no blink menu is open
      ["<Tab>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          elseif cmp.is_visible() then
            return cmp.select_next()
          end
        end,
        function()
          -- Accept Copilot inline suggestion if available
          if require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").accept()
            return true
          end
        end,
        "fallback",
      },
    },
    sources = {
      default = { "copilot", "lsp", "path", "snippets", "buffer" },
      providers = {
        emoji = {
          score_offset = 50,
        },
        git = {
          score_offset = 10,
        },
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },
  },
}
