---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
      },
    },
    rooter = {
      autochdir = true,
    },
    -- autocmds = {
    --   lsp_attach_azurepipelines = {
    --     {
    --       event = { "BufRead" },
    --       desc = "Attach Azure Pipelines LS when in .azuredevops directory",
    --       pattern = "*/.azuredevops/*.yaml",
    --       callback = function()
    --         require("lspconfig").azure_pipelines_ls.setup {
    --           settings = {
    --             yaml = {
    --               schemas = {
    --                 ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
    --                   "*/.azuredevops/**/*.y*ml",
    --                 },
    --               },
    --             },
    --           },
    --         }
    --         -- require("lspconfig").yamlls.setup {
    --         --   settings = {
    --         --     yaml = {
    --         --       schemaStore = {
    --         --         -- You must disable built-in schemaStore support if you want to use
    --         --         -- this plugin and its advanced options like `ignore`.
    --         --         enable = false,
    --         --         -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
    --         --         url = "",
    --         --       },
    --         --       schemas = require("schemastore").yaml.schemas {
    --         --         select = {
    --         --           "Azure Pipelines",
    --         --         },
    --         --       },
    --         --     },
    --         --   },
    --         -- }
    --       end,
    --     },
    --   },
    -- },
  },
}
