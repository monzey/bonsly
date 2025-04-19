return {
  {
    "snacks.nvim",
    keys = {
      { "<a-m>", mode = { "i", "n" }, false },
    },
    opts = {
      dashboard = {
        preset = {
          header = [[
            gg ez
          ]]
        }
      },
      picker = {
        finder = "files",
        format = "file",
        show_empty = true,
        hidden = false,
        ignored = false,
        follow = false,
        supports_live = true,
      }
    }
  },
}
