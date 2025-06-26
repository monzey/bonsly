return {
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
            'javascript',
            'javascriptreact'
          }
        },
        ts_ls = {
          filetypes = {
            'typescript',
            'typescriptreact'
          }
        },
      },
      setup = { },
    },
  }
}
