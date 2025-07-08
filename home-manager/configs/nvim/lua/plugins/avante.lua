return {
  {
    "yetone/avante.nvim",
    opts = {
      provider = "copilot",
      providers = {
        copilot = {
          model = "gpt-4.1",
        },
      },
      windows = {
        sidebar_header = {
          enabled = false,
        },
      },
    },
  },
}
