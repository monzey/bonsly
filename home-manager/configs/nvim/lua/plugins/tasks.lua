return {
  {
    "stevearc/overseer.nvim",
    opts = {
      task_list = {
        bindings = {
          ["<C-c>"] = "Stop",
        },
      },
      templates = {
        "builtin",
        "user.just",
        "vscode",
      },
    },
    keys = {
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run task" },
      { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Toggle tasks" },
      { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
    },
  },
}
