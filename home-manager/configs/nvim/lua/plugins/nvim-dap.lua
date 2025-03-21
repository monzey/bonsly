return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    dap.adapters.node = {
      type = "executable",
      -- port = "9229",
      -- executable = {
        command = "node",
        args = { os.getenv('HOME') .. "/.local/share/nvim/mason/bin/js-debug-adapter", "9229" },
      -- }
    }

    dap.configurations.javascript = {
      {
        name = "Launch file",
        type = "node", 
        request = "launch",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
    }
  end,
}
