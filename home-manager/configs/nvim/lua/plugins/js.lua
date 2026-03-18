return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    -- REMOVE THIS once this issue is fixed: https://github.com/yioneko/vtsls/issues/159
    opts = {
      routes = {
        {
          filter = {
            event = "notify",
            find = "Request textDocument/documentHighlight failed",
          },
          opts = { skip = true },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
          },
          root_dir = require("lspconfig").util.root_pattern(
            "eslint.config.js",
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.json",
            ".git",
            "package.json"
          ),
          filetypes = {
            "javascript",
            "javascriptreact",
          },
        },
        vtsls = {
          settings = {
            typescript = {
              tsserver = {
                path = vim.fn.expand(
                  "$HOME/.local/share/nvim/mason/packages/typescript-language-server/node_modules/typescript/lib/tsserver.js"
                ),
              },
            },
          },
        },
      },
      setup = {},
    },
  },
}
