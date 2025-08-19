return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy",
              },
              linkedProjects = {
                "Cargo.toml",
              },
              cargo = {
                buildScripts = {
                  enable = true,
                },
              },
            },
          },
        },
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
        ts_ls = {
          filetypes = {
            "typescript",
            "typescriptreact",
          },
        },
      },
      setup = {},
    },
  },
}
