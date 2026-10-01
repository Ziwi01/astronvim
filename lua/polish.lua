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

-- Use the bash Treesitter parser for zsh files (there is no dedicated zsh parser).
-- `vim.treesitter.language.register` maps the `zsh` filetype to the `bash` language,
-- so highlighting resolves automatically without a per-buffer FileType autocmd.
pcall(vim.treesitter.language.register, "bash", "zsh")
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

-- Run the OpenCode TUI in a REAL tmux pane (not a Neovim :terminal) so ccmux
-- can track it by its controlling TTY. Keeping $TMUX set is correct here: tmux
-- (not Neovim) renders opencode, so it handles the OSC 52 clipboard passthrough
-- natively -- the garbage "52;c;<base64>" issue only happened inside Neovim's
-- :terminal.
--
-- OpenCode v2 runs ONE background service that every TUI attaches to (it
-- starts with the first TUI). opencode.nvim finds it through
-- ~/.local/state/opencode/service.json and prompts the most recently updated
-- session for Neovim's cwd, whichever pane shows it.
local function opencode_bin()
  local bin = vim.fn.exepath "opencode"
  return bin ~= "" and bin or "opencode"
end

-- Directory Neovim was launched from, captured now (during startup, before the
-- rooter's `autochdir` can move the cwd). Used only as a safety fallback below.
local launch_cwd = vim.fn.getcwd()

-- Working directory to root a new OpenCode server at: follow the current project
-- (Neovim's cwd, kept per-project by the rooter) so spawning OpenCode in a
-- different repo during the same session roots it there. Fall back to the launch
-- directory only if the cwd is $HOME, so a stray non-repo file never drops
-- OpenCode into your entire home directory.
local function opencode_cwd()
  local cwd = vim.fn.getcwd()
  if vim.fs.normalize(cwd) == vim.fs.normalize(assert(vim.uv.os_homedir())) then return launch_cwd end
  return cwd
end

---@class OpencodePane
---@field id string     tmux pane id, e.g. "%8"
---@field win_id string tmux window id, e.g. "@5"

---List every tmux pane running opencode (across all windows/sessions).
---@return OpencodePane[]
local function opencode_panes()
  local fmt = "#{pane_id}\t#{window_id}\t#{pane_current_command}"
  local list = {}
  for _, line in ipairs(vim.fn.systemlist { "tmux", "list-panes", "-a", "-F", fmt }) do
    local id, win_id, cmd = unpack(vim.split(line, "\t"))
    if cmd == "opencode" then list[#list + 1] = { id = id, win_id = win_id } end
  end
  return list
end

---Open a new OpenCode TUI in a tmux pane rooted at Neovim's CWD, so you can
---run several agents side by side in the SAME repo (ccmux tracks each pane).
local function open_opencode_pane()
  local cmd = opencode_bin()
  -- Not inside tmux: fall back to a Neovim terminal, which needs $TMUX and
  -- $TMUX_PANE stripped to avoid broken OSC 52 clipboard sequences.
  if vim.env.TMUX == nil then
    require("snacks.terminal").open("env -u TMUX -u TMUX_PANE " .. cmd, {
      cwd = opencode_cwd(),
      win = { position = "right", enter = false },
    })
    return
  end
  -- Horizontal tmux split rooted at the current project (or the launch dir if
  -- that would be $HOME). `-d` keeps focus in Neovim.
  vim.fn.system { "tmux", "split-window", "-h", "-l", "40%", "-d", "-c", opencode_cwd(), cmd }
end

---Toggle the opencode pane's visibility WITHOUT killing it (the same
---break-pane/join-pane trick Vimux's VimuxTogglePane uses, but keyed off the
---opencode process so it survives nvim restarts and external launches).
---With multiple panes it prefers the one in the current window (hide it),
---otherwise brings one into the current window.
local function opencode_toggle()
  if vim.env.TMUX == nil then
    require("snacks.terminal").toggle("env -u TMUX -u TMUX_PANE " .. opencode_bin(), {
      cwd = opencode_cwd(),
      win = { position = "right", enter = false },
    })
    return
  end
  local panes = opencode_panes()
  if #panes == 0 then
    open_opencode_pane() -- not running yet -> start it
    return
  end
  local cur_win = (vim.fn.systemlist { "tmux", "display-message", "-p", "#{window_id}" })[1]
  for _, p in ipairs(panes) do
    if p.win_id == cur_win then
      vim.fn.system { "tmux", "break-pane", "-d", "-s", p.id } -- visible here -> hide
      return
    end
  end
  vim.fn.system { "tmux", "join-pane", "-h", "-l", "40%", "-s", panes[1].id } -- show here
end

---@type opencode.Opts
vim.g.opencode_opts = {
  server = {
    -- Called only when no OpenCode service is running: the first TUI starts it.
    start = open_opencode_pane,
  },
  events = {
    -- opencode runs in its own tmux pane, so permissions are answered there.
    -- Disable the Neovim-side permission UI (the Once/Always/Reject popup and the
    -- inline edit-diff approval) - it can't tell when you reply in the TUI and
    -- would otherwise hang. SSE events and file auto-reload stay enabled.
    permissions = {
      enabled = false,
    },
  },
}

-- Toggle the OpenCode pane (real tmux pane, tracked by ccmux)
vim.keymap.set({ "n", "t" }, "<C-.>", opencode_toggle, { desc = "Toggle OpenCode pane" })
vim.keymap.set("n", "<Leader>Ot", opencode_toggle, { desc = "Toggle OpenCode pane" })

-- Open an additional OpenCode TUI in THIS repo (parallel agents).
vim.keymap.set("n", "<Leader>ON", open_opencode_pane, { desc = "New OpenCode pane (this repo)" })

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
