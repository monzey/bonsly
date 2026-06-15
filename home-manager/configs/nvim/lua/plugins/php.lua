return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- On vide les formateurs pour le PHP
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.php = {}

      -- On désactive le fallback sur le LSP pour TOUT le monde
      -- (ou juste pour PHP si tu préfères)
      opts.lsp_fallback = false
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft.php = {}
      opts.lsp_fallback = false
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      local dap = require("dap")

      dap.adapters.php = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/php-debug-adapter",
      }

      dap.configurations.php = {
        {
          name = "Listen for Xdebug",
          type = "php",
          request = "launch",
          port = 9003,
          -- Si ton code est dans Docker, mapper le chemin container → local :
          pathMappings = {
            ["/opt/projects/rgsupv-dashboard"] = "${workspaceFolder}",
          },
        },
      }
    end,
  },
}
