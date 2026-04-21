-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.maplocalleader = ","
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
vim.o.linespace = 6
vim.opt.fillchars = {
  vert = "│",
}
vim.g.root_spec = { { ".git" } }
vim.g.neovide_cursor_vfx_mode = { "pixiedust" }
vim.g.neovide_cursor_trail_size = 0.2

vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = function()
    vim.b.autoformat = false -- Désactive l'autoformat juste pour ce buffer
    vim.opt_local.formatexpr = "" -- Tue la fonction LazyVim que tu as vue
  end,
})
