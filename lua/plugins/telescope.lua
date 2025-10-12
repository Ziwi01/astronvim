return {
  {
    require("telescope").setup {
      -- (other Telescope configuration...)
      extensions = {
        zoxide = {
          prompt_title = "[ Zoxide find files ]",
          mappings = {
            default = {
              after_action = function() vim.cmd("Neotree") end,
            },
          },
        },
      },
    },
  },
}
