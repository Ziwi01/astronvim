---@type LazySpec
return {
  {
    "rickhowe/diffchar.vim", -- VSCode-style precise diff highlights
    -- Its default <Leader>g / <Leader>p shadow the Git / Packages groups.
    -- Remapped to <Leader>gD* in mappings.lua.
    init = function() vim.g.DiffCharDoMapping = 0 end,
  },
  {
    "bullets-vim/bullets.vim", -- better lists/bullets
    -- Defaults minus <leader>x (shadows the Quickfix/Lists group).
    -- Checkbox toggling is available as mkdx's <Leader>Mt.
    init = function()
      vim.g.bullets_set_mappings = 0
      vim.g.bullets_custom_mappings = {
        { "imap", "<cr>", "<Plug>(bullets-newline)" },
        { "inoremap", "<C-cr>", "<cr>" },
        { "nmap", "o", "<Plug>(bullets-newline)" },
        { "vmap", "gN", "<Plug>(bullets-renumber)" },
        { "nmap", "gN", "<Plug>(bullets-renumber)" },
        { "imap", "<C-t>", "<Plug>(bullets-demote)" },
        { "nmap", ">>", "<Plug>(bullets-demote)" },
        { "vmap", ">", "<Plug>(bullets-demote)" },
        { "imap", "<C-d>", "<Plug>(bullets-promote)" },
        { "nmap", "<<", "<Plug>(bullets-promote)" },
        { "vmap", "<", "<Plug>(bullets-promote)" },
      }
    end,
  },
  -- Fix: ansible-vim's ftdetect sets `ft=ansible` on Neovim, but ansiblels
  -- expects `yaml.ansible` (and yamlls expects `yaml`), so neither attaches.
  -- Remap the stray `ansible` filetype back to `yaml.ansible`.
  {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        ansible_filetype_fix = {
          {
            event = "FileType",
            pattern = "ansible",
            desc = "Map ansible-vim's plain 'ansible' ft to yaml.ansible so ansiblels/yamlls attach",
            callback = function(ev) vim.bo[ev.buf].filetype = "yaml.ansible" end,
          },
        },
      },
    },
  },
  -- astrocommunity treesj binds TSJToggle to <Leader>m, which is also the
  -- multiple-cursors group prefix (n and x share one table there). Keep the
  -- group, drop the command; TSJToggle lives on <Leader>J (mappings.lua).
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      for _, mode in ipairs { "n", "x" } do
        local map = opts.mappings[mode] and opts.mappings[mode]["<Leader>m"]
        if type(map) == "table" then
          map[1] = nil
          map.desc = require("astroui").get_icon("MultipleCursors", 1, true) .. "MultipleCursors"
        end
      end
      -- astrocommunity openingh renames the Git group to "OpenInGH"; restore it.
      -- Group names with icons are set here, where astroui is available.
      local icon = require("astroui").get_icon
      for lhs, desc in pairs {
        ["<Leader>g"] = icon("Git", 1, true) .. "Git",
        ["<Leader>G"] = icon("GitHub", 1, true) .. "Github commands",
        ["<Leader>M"] = icon("Markdown", 1, true) .. "Markdown",
        ["<Leader>T"] = icon("Table", 1, true) .. "Table mode",
      } do
        opts.mappings.n[lhs] = { desc = desc }
        if lhs ~= "<Leader>G" then opts.mappings.x[lhs] = { desc = desc } end
      end
    end,
  },
  -- Enable Copilot suggestions for YAML and Ansible filetypes
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = {
        yaml = true,
        ["yaml.ansible"] = true,
      },
    },
  },
  -- Vim Table mode (default <Leader>t prefix shadows the Terminal group)
  {
    "dhruvasagar/vim-table-mode",
    init = function()
      vim.g.table_mode_map_prefix = "<Leader>T"
      vim.g.table_mode_tableize_d_map = "<Leader>TT"
    end,
  },
  -- Diff directories (:DirDiff <dir1> <dir2>)
  { "will133/vim-dirdiff" },
  -- Markdown support
  {
    "SidOfc/mkdx",
    -- Default prefix is <leader>, which dumps ~20 maps onto the root and
    -- shadows Buffers/Terminal. Group them under <Leader>M with mdkite.
    init = function() vim.g["mkdx#settings"] = { map = { prefix = "<leader>M" } } end,
  },
  {
    "yousefhadder/markdown-plus.nvim",
    ft = "markdown",
    opts = {},
  },
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
  {
    "ntpeters/vim-better-whitespace",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.better_whitespace_filetypes_blacklist = {
        "diff",
        "git",
        "gitcommit",
        "unite",
        "qf",
        "help",
        "markdown",
        "fugitive",
        "snacks_dashboard",
        "snacks_notif",
        "snacks_terminal",
        "snacks_win",
        "alpha",
        "lazy",
        "mason",
        "neo-tree",
      }
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  -- goto Preview
  {
    "rmagatti/goto-preview", -- Edit preview in a floating windows. (`gpd`)
    dependencies = { "rmagatti/logger.nvim" },
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
  -- Fallback search and replace (:Ack / :Acks). Default <Leader>a/l/r/s maps
  -- shadow root groups; remapped under <Leader>s in mappings.lua.
  {
    "wincent/ferret",
    init = function() vim.g.FerretMap = 0 end,
  },
  -- Descriptions for buffer-local maps created by mkdx (markdown) and
  -- vim-table-mode (while table mode is active). Without them which-key shows
  -- the `<Plug>(...)` rhs, leaving a stray `)`.
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        -- mkdx
        { "<Leader>M'", desc = "Toggle quote", mode = { "n", "x" } },
        { "<Leader>M-", desc = "Checkbox state backward", mode = { "n", "x" } },
        { "<Leader>M=", desc = "Checkbox state forward", mode = { "n", "x" } },
        { "<Leader>M[", desc = "Promote header" },
        { "<Leader>M]", desc = "Demote header" },
        { "<Leader>Mt", desc = "Toggle checkbox", mode = { "n", "x" } },
        { "<Leader>Ml", group = "Lists/links", mode = { "n", "x" } },
        { "<Leader>Mlt", desc = "Toggle checklist", mode = { "n", "x" } },
        { "<Leader>Mll", desc = "Toggle list", mode = { "n", "x" } },
        { "<Leader>Mln", desc = "Wrap link", mode = { "n", "x" } },
        { "<Leader>M/", desc = "Italic", mode = { "n", "x" } },
        { "<Leader>Mb", desc = "Bold", mode = { "n", "x" } },
        { "<Leader>M`", desc = "Inline code", mode = { "n", "x" } },
        { "<Leader>Ms", desc = "Strike through", mode = { "n", "x" } },
        { "<Leader>M,", desc = "Convert to table", mode = "x" },
        { "<Leader>Mi", desc = "Generate/update TOC" },
        { "<Leader>MI", desc = "TOC in quickfix" },
        { "<Leader>ML", desc = "Dead links in quickfix" },
        { "<Leader>Mj", desc = "Jump to header" },
        { "<Leader>Mk", desc = "Toggle kbd tag", mode = { "n", "x" } },
        -- vim-table-mode
        { "<Leader>Tm", desc = "Toggle table mode" },
        { "<Leader>Tt", desc = "Tableize", mode = { "n", "x" } },
        { "<Leader>TT", desc = "Tableize with delimiter", mode = "x" },
        { "<Leader>Tr", desc = "Realign table" },
        { "<Leader>Td", group = "Delete" },
        { "<Leader>Tdd", desc = "Delete row" },
        { "<Leader>Tdc", desc = "Delete column" },
        { "<Leader>Ti", group = "Insert column" },
        { "<Leader>Tic", desc = "Insert column after" },
        { "<Leader>TiC", desc = "Insert column before" },
        { "<Leader>Tf", group = "Formula" },
        { "<Leader>Tfa", desc = "Add formula" },
        { "<Leader>Tfe", desc = "Evaluate formula" },
        { "<Leader>T?", desc = "Echo cell representation" },
        { "<Leader>Ts", desc = "Sort column" },
      },
    },
  },
}
