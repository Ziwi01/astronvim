return {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      chat = {
        adapter = {
          name = "copilot",
          model = "claude-sonnet-4.6",
        },
      },
    },
  },
}
