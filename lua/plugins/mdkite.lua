---@type LazySpec
return {
  "selimacerbas/mdkite.nvim",
  dependencies = { { "selimacerbas/kitehost.nvim", version = ">=2.0.0" } },
  cmd = "MdKite",
  ft = "markdown",
  opts = {},
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>Mp"] = { "<cmd>MdKite toggle<cr>", desc = "Toggle preview" },
            ["<Leader>Mr"] = { "<cmd>MdKite refresh<cr>", desc = "Refresh preview" },
          },
        },
      },
    },
  },
}
