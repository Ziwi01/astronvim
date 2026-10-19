---@type LazySpec
return {
  "emrearmagan/atlas.nvim",
  cmd = { "Atlas" },
  dependencies = { "esmuellert/codediff.nvim" },
  ---@type AtlasConfig
  opts = {
    providers = {
      github = {},
    },
  },
}
