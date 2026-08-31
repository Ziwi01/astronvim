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

-- Run opencode's `--port` server in a REAL tmux pane (not a Neovim :terminal)
-- so ccmux can track it by its controlling TTY. opencode.nvim discovers this
-- server via `pgrep opencode.*--port` + lsof and attaches to it instead of
-- spawning its own copy. Keeping $TMUX set is correct here: tmux (not Neovim)
-- renders opencode, so it handles the OSC 52 clipboard passthrough natively --
-- the garbage "52;c;<base64>" issue only happened inside Neovim's :terminal.
local function opencode_bin()
  local bin = vim.fn.exepath("opencode")
  return bin ~= "" and bin or "opencode"
end

---List every tmux pane running opencode (across all windows/sessions).
---@return { pane: string, win: string }[]
local function opencode_panes()
  local fmt = "#{pane_id} #{window_id} #{pane_current_command}"
  local list = {}
  for _, line in ipairs(vim.fn.systemlist { "tmux", "list-panes", "-a", "-F", fmt }) do
    local pane_id, win_id, cmd = line:match "^(%%%d+)%s+(@%d+)%s+(.+)$"
    if cmd == "opencode" then list[#list + 1] = { pane = pane_id, win = win_id } end
  end
  return list
end

---Spawn a new `opencode --port` server in a tmux pane rooted at Neovim's CWD.
---
---Used both as opencode.nvim's `server.start` (which the plugin only calls when
---no server overlaps the current repo) and by the "new instance" mapping below,
---so you can run several agents side by side in the SAME repo: ccmux tracks each
---pane, and opencode.nvim's cwd-filtered picker lets you choose which one an
---action drives. `-c <cwd>` makes the server's cwd match Neovim's so that
---discovery/overlap filtering resolves it cleanly.
local function open_opencode_server()
  local cmd = opencode_bin() .. " --port"
  -- Not inside tmux: fall back to the previous Neovim terminal behaviour, which
  -- needs $TMUX/$TMUX_PANE stripped to avoid broken OSC 52 clipboard sequences.
  if vim.env.TMUX == nil then
    require("snacks.terminal").open("env -u TMUX -u TMUX_PANE " .. cmd, {
      win = { position = "right", enter = false },
    })
    return
  end
  -- Open opencode in a horizontal tmux split, rooted at Neovim's CWD. `-d` keeps
  -- focus in Neovim. No "already running?" guard: the plugin only calls this when
  -- it found no cwd-matching server, and the mapping wants a fresh instance.
  vim.fn.system { "tmux", "split-window", "-h", "-l", "40%", "-d", "-c", vim.fn.getcwd(), cmd }
end

---Toggle the opencode pane's visibility WITHOUT killing the server (the same
---break-pane/join-pane trick Vimux's VimuxTogglePane uses, but keyed off the
---opencode process so it survives nvim restarts and external launches).
---With multiple servers it prefers the one in the current window (hide it),
---otherwise brings one into the current window.
local function opencode_toggle()
  if vim.env.TMUX == nil then
    require("snacks.terminal").toggle("env -u TMUX -u TMUX_PANE " .. opencode_bin() .. " --port", {
      win = { position = "right", enter = false },
    })
    return
  end
  local panes = opencode_panes()
  if #panes == 0 then
    open_opencode_server() -- not running yet -> start it
    return
  end
  local cur_win = (vim.fn.systemlist { "tmux", "display-message", "-p", "#{window_id}" })[1]
  for _, p in ipairs(panes) do
    if p.win == cur_win then
      vim.fn.system { "tmux", "break-pane", "-d", "-s", p.pane } -- visible here -> hide
      return
    end
  end
  vim.fn.system { "tmux", "join-pane", "-h", "-l", "40%", "-s", panes[1].pane } -- show here
end

---@type opencode.Opts
vim.g.opencode_opts = {
  server = {
    start = open_opencode_server,
  },
  events = {
    -- opencode now runs in its own tmux pane, so permissions are answered there.
    -- Disable the Neovim-side permission UI (the Once/Always/Reject popup and the
    -- inline edit-diff approval) - it can't tell when you reply in the TUI and
    -- would otherwise hang. SSE events and file auto-reload stay enabled.
    permissions = {
      enabled = false,
    },
  },
}

-- Toggle the OpenCode server pane (real tmux pane, tracked by ccmux)
vim.keymap.set({ "n", "t" }, "<C-.>", opencode_toggle, { desc = "Toggle OpenCode pane" })
vim.keymap.set("n", "<Leader>Ot", opencode_toggle, { desc = "Toggle OpenCode pane" })

-- Spawn an additional OpenCode instance in THIS repo (parallel agents). ccmux
-- tracks each; opencode.nvim prompts to pick which server an action targets.
vim.keymap.set("n", "<Leader>ON", open_opencode_server, { desc = "New OpenCode instance (this repo)" })

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
