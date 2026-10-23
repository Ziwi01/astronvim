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
---@param session? { id: string, dir: string } reopen this session in its directory instead
local function open_opencode_pane(session)
  local cwd = session and session.dir or opencode_cwd()
  local argv = { opencode_bin() }
  if session then vim.list_extend(argv, { session.dir, "--session", session.id }) end
  -- Not inside tmux: fall back to a Neovim terminal, which needs $TMUX and
  -- $TMUX_PANE stripped to avoid broken OSC 52 clipboard sequences.
  if vim.env.TMUX == nil then
    require("snacks.terminal").open(vim.list_extend({ "env", "-u", "TMUX", "-u", "TMUX_PANE" }, argv), {
      cwd = cwd,
      win = { position = "right", enter = false },
    })
    return
  end
  -- Horizontal tmux split rooted at the current project (or the launch dir if
  -- that would be $HOME). `-d` keeps focus in Neovim.
  vim.fn.system(vim.list_extend({ "tmux", "split-window", "-h", "-l", "40%", "-d", "-c", cwd }, argv))
end

---Browse OpenCode sessions of every directory with `ocs` (deployed by
---Proveasio) in a floating terminal, then open the picked one in a new pane.
local function browse_opencode_sessions()
  if vim.fn.executable "ocs" == 0 then
    vim.notify("ocs not found on PATH", vim.log.levels.ERROR)
    return
  end
  local out = vim.fn.tempname()
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "none",
  })
  -- fzf draws on the tty, so only the "<id>\t<dir>" result lands in `out`.
  vim.fn.jobstart({ "sh", "-c", 'ocs --print > "$1"', "ocs", out }, {
    term = true,
    on_exit = function(_, code)
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
        local ok, lines = pcall(vim.fn.readfile, out)
        vim.fn.delete(out)
        if code ~= 0 or not ok or not lines[1] or lines[1] == "" then return end
        local id, dir = unpack(vim.split(lines[1], "\t", { plain = true }))
        open_opencode_pane { id = id, dir = dir }
      end)
    end,
  })
  vim.cmd.startinsert()
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
    start = function() open_opencode_pane() end,
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
vim.keymap.set("n", "<Leader>ON", function() open_opencode_pane() end, { desc = "New OpenCode pane (this repo)" })

-- Pick an OpenCode session from any directory and open it in a new pane.
vim.keymap.set("n", "<Leader>OS", browse_opencode_sessions, { desc = "Browse OpenCode sessions (ocs)" })

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
