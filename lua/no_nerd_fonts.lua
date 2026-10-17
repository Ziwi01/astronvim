-- Helpers for terminals without a Nerd Font (PROVEASIO_NERD_FONTS=0, set by Proveasio).
-- Such fonts often also lack block eighths (▏ ▁) and symbols like ❯, which show as
-- squares. Allowed: ASCII, box drawing (U+2500-U+257F) and ✓ (U+2713).
local M = {}

M.enabled = vim.env.PROVEASIO_NERD_FONTS == "0"

--- Whether a string uses only characters that fonts without Nerd Font icons have.
---@param s string
---@return boolean
function M.plain(s)
  s = s:gsub("\226[\148\149][\128-\191]", ""):gsub("\226\156\147", "")
  return not s:find "[\128-\255]"
end

--- A copy of an icon table with every icon that is not `plain` replaced by the
--- one at the same place in `ascii`, or by "" when there is none.
---@param icons table
---@param ascii? table
---@return table
function M.icons(icons, ascii)
  ascii = ascii or {}
  local out = {}
  for k, v in pairs(icons) do
    if type(v) == "table" then
      out[k] = M.icons(v, type(ascii[k]) == "table" and ascii[k] or {})
    elseif type(v) == "string" and not M.plain(v) then
      out[k] = type(ascii[k]) == "string" and ascii[k] or ""
    else
      out[k] = v
    end
  end
  return out
end

-- lazy.nvim `ui.icons`
M.lazy = {
  cmd = ": ",
  config = "cfg ",
  debug = "dbg ",
  event = "ev ",
  favorite = "* ",
  ft = "ft ",
  init = "init ",
  import = "imp ",
  keys = "keys ",
  lazy = "lazy ",
  loaded = "*",
  not_loaded = "o",
  plugin = "plug ",
  runtime = "rt ",
  require = "req ",
  source = "src ",
  start = "start ",
  task = "ok ",
  list = { "*", "->", "*", "-" },
}

-- snacks.nvim `picker.icons`
M.snacks_picker = {
  ui = { live = "live ", selected = "* ", unselected = "  " },
  git = {
    staged = "S",
    added = "A",
    deleted = "D",
    ignored = "I ",
    modified = "M",
    renamed = "R",
    unmerged = "U ",
  },
  diagnostics = { Error = "E ", Warn = "W ", Hint = "H ", Info = "I " },
  lsp = { unavailable = "-", enabled = "+ ", disabled = "- ", attached = "* " },
}

return M
