---@type LazySpec
return {
  -- Vim Table mode
  { "dhruvasagar/vim-table-mode" },
  -- Diff directories (:DirDiff <dir1> <dir2>)
  { "will133/vim-dirdiff" },
  -- Markdown support
  { "SidOfc/mkdx" },
  -- Fuzzy finder
  { "junegunn/fzf" },
  { "junegunn/fzf.vim" },
  -- Git graph
  { "junegunn/gv.vim" },
  -- GIT wrapper (`:G <any_git_command>`)
  { "tpope/vim-fugitive" },
  -- GIT manager in VIM. Awesome. (`:LazyGit`, or <Leader>gg)
  { "kdheepak/lazygit.nvim" },
  -- show git status on particular lines
  { "mhinz/vim-signify" },
  -- Trim trailing whitespace
  -- { "ntpeters/vim-better-whitespace" },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  -- goto Preview
  {
    "rmagatti/goto-preview", -- Edit preview in a floating windows. (`gpd`)
    config = function()
      require("goto-preview").setup {
        width = 120, -- Width of the floating window
        height = 25, -- Height of the floating window
        default_mappings = true, -- Bind default mappings
        debug = false, -- Print debug information
        opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
        post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
        -- You can use "default_mappings = true" setup option
        -- Or explicitly set keybindings
        -- vim.cmd("nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>")
        -- vim.cmd("nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>")
        -- vim.cmd("nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>")
      }
    end,
  },
  -- Running commands in TMUX split
  { "preservim/vimux" },
  -- Fallback search and replace (:Ack or <leader>a for search, :Acks or <leader>r to substitute)
  { "wincent/ferret" },
  -- Improve local search and replace
  {
    "roobert/search-replace.nvim",
    config = function()
      require("search-replace").setup {
        -- optionally override defaults
        -- default_replace_single_buffer_options = "gcI",
        -- default_replace_multi_buffer_options = "egcI",
      }
    end,
  },
}
