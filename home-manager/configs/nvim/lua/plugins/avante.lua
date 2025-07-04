return {
  {
    "yetone/avante.nvim",
    opts = {
      provider = "copilot",
      providers = {
        copilot = {
          model = "claude-3.7-sonnet",
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
