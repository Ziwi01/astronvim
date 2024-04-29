return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem["filtered_items"] = {
        visible = true,
        -- hide_dotfiles = false,
      }
      opts.window["auto_expand_width"] = true
    end,
  }
}
