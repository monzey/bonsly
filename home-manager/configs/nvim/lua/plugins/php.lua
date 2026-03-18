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
}
