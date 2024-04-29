return {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          -- navigate buffer tabs with `H` and `L`
          L = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          H = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
          -- TMUX/VIM seamless navigation with ALT + arrows
          ["<A-Left>"] = { ":TmuxNavigateLeft<cr>", desc = "TMUX/VIM navigate left" },
          ["<A-Right>"] = { ":TmuxNavigateRight<cr>" , desc = "TMUX/VIM navigate right" },
          ["<A-Up>"] = { ":TmuxNavigateUp<cr>" , desc = "TMUX/VIM navigate up" },
          ["<A-Down>"] = { ":TmuxNavigateDown<cr>" , desc = "TMUX/VIM navigate down" },
          ["<Leader>bD"] = {
            function()
              require("astroui.status.heirline").buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Pick to close",
          },
        },
        v = {
          ["p"] = { '"_dP', desc = "Paste without copy" }
        }
      }
    }
}
