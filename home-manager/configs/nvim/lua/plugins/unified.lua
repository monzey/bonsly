local plugins = vim.fn.stdpath("data") .. "/nix-plugins/"

return {
  {
    "axkirillov/unified.nvim",
    dir = plugins .. "unified.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    cmd = "Unified",
    keys = { { "<leader>gu", "<cmd>Unified HEAD<cr>", desc = "Unified diff (HEAD)" } },
    opts = { auto_refresh = false, file_tree = { width = 28, focus = false } },
    config = function(_, opts)
      require("config.unified").setup(_, opts)
    end,
  },
}
