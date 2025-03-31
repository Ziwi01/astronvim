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
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = true, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
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
