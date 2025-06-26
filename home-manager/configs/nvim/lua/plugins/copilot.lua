return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      sticky = {
        '#buffer',
        '#files'
      }
    },
    keys = {
      {"<leader>ae", ":CopilotChatExplain<cr>", mode = "v", desc = "Explain code"},
      {"<leader>ar", ":CopilotChatReview<cr>", mode = "v", desc = "Review code"},
      {"<leader>at", ":CopilotChatTests<cr>", mode = "v", desc = "Generate tests"},
      {"<leader>am", ":CopilotChatCommit<cr>", mode = "v", desc = "Generate commit message"},
      {"<leader>af", ":CopilotChatFix<cr>", mode = "v", desc = "Fix code issues"},
    }
  },
}
