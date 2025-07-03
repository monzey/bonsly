return {
  {
    "NotAShelf/direnv.nvim",
    config = function()
      require("direnv").setup({
        autoload_direnv = false,
        statusline = {
          enabled = true,
          icon = "󱚟",
        },
      })
    end,
  },
}
