-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<A-j>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<A-k>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<A-l>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<A-m>", "<C-w>l", { silent = true })

vim.keymap.set("n", "<C-k>", "<cmd>bn<cr>", { silent = true })
vim.keymap.set("n", "<C-j>", "<cmd>bp<cr>", { silent = true })
vim.keymap.set({ "n", "i" }, "<localleader>w", "<cmd>w<cr>", { silent = true })
