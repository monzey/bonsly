return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
    keys = {
      {"<leader>ae", ":CopilotChatExplain<cr>", mode = "v", desc = "Explain code"},
      {"<leader>ar", ":CopilotChatReview<cr>", mode = "v", desc = "Review code"},
      {"<leader>at", ":CopilotChatTests<cr>", mode = "v", desc = "Generate tests"},
      {"<leader>am", ":CopilotChatCommit<cr>", mode = "v", desc = "Generate commit message"},
      {"<leader>af", ":CopilotChatFix<cr>", mode = "v", desc = "Fix code issues"},
    }
  },
}
