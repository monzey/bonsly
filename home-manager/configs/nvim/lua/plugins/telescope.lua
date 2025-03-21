return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = { '^\\.git/', '^\\.DS_Store', '^\\.gitignore' }, -- ajoute d'autres motifs si nécessaire
    },
    pickers = {
      find_files = {
        hidden = true, -- permet d'afficher les fichiers cachés
      },
    },
  }
}
