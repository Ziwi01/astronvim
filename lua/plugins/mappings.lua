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
        ["<A-Right>"] = { ":TmuxNavigateRight<cr>", desc = "TMUX/VIM navigate right" },
        ["<A-Up>"] = { ":TmuxNavigateUp<cr>", desc = "TMUX/VIM navigate up" },
        ["<A-Down>"] = { ":TmuxNavigateDown<cr>", desc = "TMUX/VIM navigate down" },
        ["<Leader>bD"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        ["<Leader>gi"] = { name = "GH Commands" },
        ["<Leader>gip"] = { name = "GH Pull Requests" },
        ["<Leader>gipc"] = { "<cmd>GHClosePR<cr>", desc = "GH PR Close" },
        ["<Leader>gipd"] = { "<cmd>GHPRDetails<cr>", desc = "GH PR Details" },
        ["<Leader>gipe"] = { "<cmd>GHExpandPR<cr>", desc = "GH PR Expand" },
        ["<Leader>gipo"] = { "<cmd>GHOpenPR<cr>", desc = "GH PR Open" },
        ["<Leader>gipp"] = { "<cmd>GHPopOutPR<cr>", desc = "GH PR PopOut" },
        ["<Leader>gipr"] = { "<cmd>GHRefreshPR<cr>", desc = "GH PR Refresh" },
        ["<Leader>gipt"] = { "<cmd>GHOpenToPR<cr>", desc = "GH PR Open To" },
        ["<Leader>gipz"] = { "<cmd>GHCollapsePR<cr>", desc = "GH PR Collapse" },
        ["<Leader>gic"] = { name = "GH Commits" },
        ["<Leader>gicc"] = { "<cmd>GHCloseCommit<cr>", desc = "GH Commit Close" },
        ["<Leader>gice"] = { "<cmd>GHExpandCommit<cr>", desc = "GH Commit Expand" },
        ["<Leader>gico"] = { "<cmd>GHOpenToCommit<cr>", desc = "GH Commit Open To" },
        ["<Leader>gicp"] = { "<cmd>GHPopOutCommit<cr>", desc = "GH Commit Pop Out" },
        ["<Leader>gicz"] = { "<cmd>GHCollapseCommit<cr>", desc = "GH Commit Collapse" },
        ["<Leader>gii"] = { name = "GH Issues" },
        ["<Leader>giip"] = { "<cmd>GHPreviewIssue<cr>", desc = "GH Issue Preview" },
        ["<Leader>gir"] = { name = "GH Reviews" },
        ["<Leader>girb"] = { "<cmd>GHStartReview<cr>", desc = "GH Review Begin" },
        ["<Leader>girc"] = { "<cmd>GHCloseReview<cr>", desc = "GH Review Close" },
        ["<Leader>gird"] = { "<cmd>GHDeleteReview<cr>", desc = "GH Review Delete" },
        ["<Leader>gire"] = { "<cmd>GHExpandReview<cr>", desc = "GH Review Expand" },
        ["<Leader>girs"] = { "<cmd>GHSubmitReview<cr>", desc = "GH Review Submit" },
        ["<Leader>girz"] = { "<cmd>GHCollapseReview<cr>", desc = "GH Review Collapse" },
        ["<Leader>git"] = { name = "GH Threads" },
        ["<Leader>gitc"] = { "<cmd>GHCreateThread<cr>", desc = "GH Thread Create" },
        ["<Leader>gitn"] = { "<cmd>GHNextThread<cr>", desc = "GH Thread Next" },
        ["<Leader>gitt"] = { "<cmd>GHToggleThread<cr>", desc = "GH Thread Toggle" },
        ["<Leader>gil"] = { "<cmd>LTPanel<cr>", desc = "GH Toggle Panel" },
      },
      v = {
        ["p"] = { '"_dP', desc = "Paste without copy" },
      },
    },
  },
}
