-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- Uniquement si on est dans un terminal Kitty

-- On définit nos caractères de bordure Unicode une seule fois
local beautiful_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }

-- On sauvegarde la fonction originale de Neovim
local original_open_win = vim.api.nvim_open_win

-- On remplace la fonction par notre version améliorée
vim.api.nvim_open_win = function(bufnr, enter, config)
  -- Si la configuration de la fenêtre n'a pas déjà une bordure définie...
  if config and config.border == nil then
    -- ... alors on injecte la nôtre !
    config.border = beautiful_border
  end

  -- Enfin, on appelle la fonction originale avec la configuration (peut-être) modifiée
  return original_open_win(bufnr, enter, config)
end
