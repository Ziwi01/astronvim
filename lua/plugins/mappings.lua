-- Open lazygit (toggleterm float) rooted at the current file's git repository.
-- AstroNvim's stock <Leader>gg caches a single lazygit terminal and freezes its
-- cwd at first open, so after cd-ing into another repo it reopens the wrong one.
-- When the current file is inside a repo we pass `-p <root>`, which targets the
-- correct repo AND makes the terminal cache key unique per repo. When it is NOT
-- in a repo we run plain `lazygit` (no `-p`, which would force a non-existent
-- `<dir>/.git/` and make lazygit exit immediately), so it shows its normal
-- "Not in a git repository" prompt. Either way we keep toggleterm's bordered UI.
local function lazygit_here()
  local buf_name = vim.api.nvim_buf_get_name(0)
  -- Prefer the current file's directory, but only for real file buffers. For
  -- neo-tree / terminal / dashboard / unnamed buffers, fall back to the working
  -- directory, which neo-tree's "set root" (`.`) and the rooter keep pointed at
  -- the current project -- so `<Leader>gg` works even with no file open.
  local start = (vim.bo.buftype == "" and buf_name ~= "") and vim.fs.dirname(buf_name) or vim.fn.getcwd()
  local root = vim.fs.root(start, ".git")
  require("astrocore").toggle_term_cmd {
    cmd = root and ("lazygit -p " .. vim.fn.shellescape(root)) or "lazygit",
    dir = root or start,
    direction = "float",
  }
end

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
        ["<Leader>z"] = { "<cmd>Telescope zoxide list<cr>", desc = "Zoxide" },
        -- Open lazygit in the current file's repo (see `lazygit_here` above):
        -- fixes the stock mapping reopening the wrong repo after a cd, without
        -- losing toggleterm's bordered lazygit UI (snacks renders borderless).
        ["<Leader>gg"] = { lazygit_here, desc = "Lazygit (current repo)" },
        ["<Leader>tl"] = { lazygit_here, desc = "Lazygit (current repo)" },
        -- Append @buffer to the prompt window instead of submitting immediately.
        -- opencode.nvim submits unless the prompt ends with a trailing space.
        ["<Leader>O+"] = {
          function() require("opencode").prompt "@buffer " end,
          desc = "Add buffer to prompt",
        },
      },
      v = {
        ["p"] = { '"_dP', desc = "Paste without copy" },
      },
    },
  },
}
