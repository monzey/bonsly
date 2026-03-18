return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = {},
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        settings = {
          ["rust-analyzer"] = {
            rustfmt = {
              enable = false,
            },
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      },
    },
  },
}
