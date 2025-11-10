return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin
    config = function()
      require("mcphub").setup({})
    end,
    opts = {
      extensions = {
        avante = {
          make_slash_commands = true, -- make /slash commands from MCP server prompts
        },
      },
    },
  },
}
