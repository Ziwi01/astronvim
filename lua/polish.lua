-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    -- let treesitter use bash highlight for zsh files as well
    require("nvim-treesitter.highlight").attach(0, "bash")
  end,
})
vim.api.nvim_create_autocmd("BufRead", {
  -- Force `Jenkinsfile` to groovy filetype.
  pattern = { "Jenkinsfile" },
  command = "set ft=groovy",
})

-- Use win32yank for the system clipboard on WSL so Neovim's own yanks and any
-- OSC 52 consumed from :terminal children land on the Windows clipboard
-- (instead of a non-existent X11 clipboard via the auto-detected xclip).
if vim.fn.executable "win32yank.exe" == 1 then
  vim.g.clipboard = {
    name = "win32yank",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

-- Clear $TMUX/$TMUX_PANE so opencode does not think it is running directly
-- inside tmux. Otherwise it wraps its OSC 52 clipboard copies in a tmux
-- passthrough DCS, which Neovim's :terminal cannot decode and renders as
-- garbage "52;c;<base64>" text. Without $TMUX, opencode emits a plain OSC 52
-- that Neovim consumes correctly via the win32yank clipboard provider above.
local opencode_cmd = "env -u TMUX -u TMUX_PANE opencode --port"
---@type snacks.terminal.Opts
local snacks_terminal_opts = {
  win = {
    position = "right",
    enter = false,
  },
}
---@type opencode.Opts
vim.g.opencode_opts = {
  server = {
    start = function() require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts) end,
  },
}

-- Toggle the OpenCode terminal
vim.keymap.set(
  { "n", "t" },
  "<C-.>",
  function() require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts) end,
  { desc = "Toggle OpenCode" }
)

-- Attach LSP for Azure Pipelines for YAML files in .azuredevops directory
-- vim.api.nvim_create_autocmd("BufRead", {
--   pattern = "*/.azuredevops/*.y*ml",
--   callback = function()
--     require("astrolsp").setup {
--       opts = {
--         config = {
--           azure_pipelines_ls = {
--             settings = {
--               yaml = {
--                 schemas = {
--                   ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
--                     "*/.azuredevops/**/*.y*ml",
--                   },
--                 },
--               },
--             },
--           },
--         },
--       },
--     }
--   end,
-- })
