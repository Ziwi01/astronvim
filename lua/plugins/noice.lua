return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      local utils = require "astrocore"
      return utils.extend_tbl(opts, {
        routes = {
          {
            -- Do not show "AutoSave message"
            filter = {
              event = "msg_show",
              find = "AutoSave:",
            },
            opts = { skip = true },
          },
          {
            -- Do not show "Config Change Detected"
            filter = {
              event = "notify",
              find = "Config Change Detected",
            },
            opts = { skip = true },
          },
        },
      })
    end,
  },
}
