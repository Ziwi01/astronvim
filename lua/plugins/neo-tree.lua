-- Neo-Tree customizations
--
-- Adds a "diff source" workflow that drives CodeDiff's directory comparison
-- directly from the file tree:
--   * `gm` on a directory  -> mark it as the diff source (toggles off if it is
--                             already the marked directory)
--   * `gd` on a directory  -> run `:CodeDiff dir <source> <target>` comparing
--                             the marked source against the directory under the
--                             cursor
-- The marked directory is shown with a dimmed `(diff source)` tag, mirroring the
-- native `(copied)` / `(cut)` clipboard markers.

-- Holds the absolute path of the directory currently marked as the diff source.
local diff_source ---@type string?

-- Reference to neo-tree's default clipboard component so we can fall back to it
-- for the normal cut/copy markers when a node is not the diff source.
local default_clipboard = require("neo-tree.sources.common.components").clipboard
local highlights = require "neo-tree.ui.highlights"

--- Redraw every open filesystem tree so the `(diff source)` marker updates.
local function redraw() require("neo-tree.sources.manager").redraw "filesystem" end

--- Resolve the directory node under the cursor, warning if it is not a directory.
---@param state table neo-tree source state
---@return table? node the directory node, or nil if the cursor is not on a directory
local function get_dir_node(state)
  local node = state.tree:get_node()
  if not node or node.type ~= "directory" then
    vim.notify("Diff: not a directory", vim.log.levels.WARN, { title = "Neo-Tree" })
    return nil
  end
  return node
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem["filtered_items"] = {
        visible = true,
        -- hide_dotfiles = false,
      }
      opts.window["auto_expand_width"] = false

      -- Override the `clipboard` component (already wired into the file and
      -- directory renderers) so it also renders the `(diff source)` marker.
      opts.filesystem.components = opts.filesystem.components or {}
      opts.filesystem.components.clipboard = function(config, node, state)
        if diff_source and node:get_id() == diff_source then
          return { text = " (diff source)", highlight = config.highlight or highlights.DIM_TEXT }
        end
        return default_clipboard(config, node, state)
      end

      -- Custom commands.
      opts.filesystem.commands = opts.filesystem.commands or {}

      -- `gm`: toggle the directory under the cursor as the diff source.
      opts.filesystem.commands.codediff_mark_source = function(state)
        local node = get_dir_node(state)
        if not node then return end
        local path = node:get_id()
        if diff_source == path then
          diff_source = nil
          vim.notify("Diff source unmarked", vim.log.levels.INFO, { title = "Neo-Tree" })
        else
          diff_source = path
          vim.notify("Diff source: " .. path, vim.log.levels.INFO, { title = "Neo-Tree" })
        end
        redraw()
      end

      -- `gd`: diff the marked source against the directory under the cursor.
      opts.filesystem.commands.codediff_diff_target = function(state)
        local node = get_dir_node(state)
        if not node then return end
        if not diff_source then
          vim.notify("No diff source marked (use gm on a directory first)", vim.log.levels.WARN, { title = "Neo-Tree" })
          return
        end
        local target = node:get_id()
        if target == diff_source then
          vim.notify("Diff source and target are the same directory", vim.log.levels.WARN, { title = "Neo-Tree" })
          return
        end
        local source = diff_source
        diff_source = nil
        redraw()
        vim.cmd(string.format("CodeDiff dir %s %s", vim.fn.fnameescape(source), vim.fn.fnameescape(target)))
      end

      -- Keybindings (buffer-local to the Neo-Tree window).
      opts.filesystem.window = opts.filesystem.window or {}
      opts.filesystem.window.mappings = opts.filesystem.window.mappings or {}
      opts.filesystem.window.mappings["gm"] = "codediff_mark_source"
      opts.filesystem.window.mappings["gd"] = "codediff_diff_target"
    end,
  },
}
