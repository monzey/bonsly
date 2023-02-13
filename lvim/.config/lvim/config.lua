require 'colors.highlights'

-- vim.cmd([[ execute "set <A-j> =\ej" ]])
-- vim.cmd([[ execute "set <A-m> =\em" ]])
-- vim.cmd([[ execute "set <A-k> =\ek" ]])
-- vim.cmd([[ execute "set <A-l> =\el" ]])

--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "tokyonight"
vim.g.tokyonight_style = "night"
vim.g.neovide_transparency = 1
vim.opt.clipboard = 'unnamedplus'

local set = vim.opt -- set options

vim.opt.cmdheight = 1
vim.opt.cursorline = false
vim.opt.guifont = "FuraCode Nerd Font:h12"
vim.opt.winblend = 0

set.fillchars = set.fillchars + 'diff: '
-- vim.g.neovide_cursor_vfx_mode = "pixiedust"
vim.g.neovide_cursor_trail_length = 0.9
vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_fullscreen = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
-- lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = false
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

lvim.keys.normal_mode["<leader>S"] = "<cmd>lua require('spectre').open()<CR>"
lvim.keys.normal_mode["<CR>"] = ":"
lvim.keys.normal_mode["<leader>j"] = ":EslintFixAll<cr>"

lvim.keys.normal_mode["<A-j>"] = "<C-w>h"
lvim.keys.normal_mode["<A-k>"] = "<C-w>j"
lvim.keys.normal_mode["<A-l>"] = "<C-w>k"
lvim.keys.normal_mode["<A-m>"] = "<C-w>l"

lvim.keys.normal_mode["<C-k>"] = ":BufferLineCycleNext<cr>"
lvim.keys.normal_mode["<C-j>"] = ":BufferLineCyclePrev<cr>"

lvim.keys.normal_mode["<C-space>"] = ":Telescope buffers<cr>"
lvim.keys.normal_mode["<C-p>"] = ":Telescope find_files<cr>"
lvim.keys.normal_mode["<C-q>"] = ":tabclose<cr>"

lvim.keys.normal_mode["<leader>gD"] = ":DiffviewOpen<cr>"
lvim.keys.normal_mode["<leader>gh"] = ":DiffviewFileHistory<cr>"
-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.pickers.find_files.find_command = {
  "rg",
  "--hidden",
  "--ignore",
  "--files",
}
lvim.builtin.telescope.defaults.mappings = {
  -- for input mode
  i = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
    ["<esc>"] = actions.close
  },
  -- for normal mode
  n = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
  },
}

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
-- }

lvim.builtin.terminal.direction = "horizontal"

lvim.builtin.nvimtree.setup.view.side = "right"
-- lvim.builtin.nvimtree.show_icons.git = 0
lvim.builtin.nvimtree.setup.view.width = 40
lvim.builtin.nvimtree.setup.update_focused_file = {
  update_cwd = true,
  enable = true,
  ignore_list = {},
}

lvim.builtin.bufferline.options.separator_style = "padded_slant"

lvim.builtin.telescope.defaults.winblend = 0;
lvim.builtin.telescope.defaults.prompt_title = 'tamer';
lvim.builtin.telescope.defaults.results_title = '';
lvim.builtin.telescope.defaults.preview_title = '';
lvim.builtin.telescope.defaults.borderchars = {
    prompt = {'▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' };
    results = {'▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' };
    preview = {'▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' };
  };
lvim.builtin.telescope.defaults.prompt_prefix = "   "
lvim.builtin.telescope.defaults.selection_caret = "  "
lvim.builtin.telescope.defaults.entry_prefix = "  "
lvim.builtin.telescope.defaults.initial_mode = "insert"
lvim.builtin.telescope.defaults.selection_strategy = "reset"
lvim.builtin.telescope.defaults.sorting_strategy = "ascending"
lvim.builtin.telescope.defaults.layout_strategy = "horizontal"
lvim.builtin.telescope.defaults.layout_config = {
  horizontal = {
    prompt_position = "top",
    preview_width = 0.55,
    results_width = 0.8,
  },
  vertical = {
    mirror = false,
  },
  width = 0.99,
  height = 0.99,
  preview_cutoff = 120,
}

lvim.builtin.telescope.defaults.borderchars = {" ", " ", " ", " ", " ", " ", " ", " "}
lvim.builtin.telescope.pickers = {
  find_files = {
    hidden = true
  }
}

lvim.builtin.dap.active = true

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.terminal.active = true
lvim.builtin.alpha.footer = ""
lvim.builtin.alpha.custom_header = {
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⡀⡢⡊⢄⠄⢀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠄⠀⠀⢢⢊⢆⣃⢇⢎⡢⡩⡣⣑⢢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⡀⠠⢄⢠⢰⠕⠁⠀⠀⠈⡌⡲⡘⡔⢕⢜⠜⡜⡔⡕⡱⡡⡠⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⣐⣆⠧⢧⢻⢪⡎⣾⠀⠀⠀⠀⠀⠀⠨⢘⠌⢎⠆⡇⡣⡱⡸⣀⠈⠈⠊⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⡱⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⢀⢠⡠⢧⢓⠕⢜⢘⠌⢆⡫⡺⡰⠄⠀⠀⠀⠀⠀⠀⠀⠀⠁⠑⣊⢎⢪⠸⡘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣘⡮⣣⣇⡆⡄⡀⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⢀⢸⢜⢎⠪⡊⡢⠣⡑⡅⡣⡱⣪⠪⣹⠰⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠱⡑⡕⢍⠅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣔⡖⡝⡮⡲⡹⡪⣒⢄⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⢀⡢⡏⢎⠢⢣⢑⠜⢌⡊⢆⢕⢸⡰⠱⡘⡎⠦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡑⢕⢱⢑⢍⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢜⢮⢪⢣⡣⡣⡣⡊⢎⢮⡢⡀⠀⠀⠀⠀    ",
"⠀⢀⢢⢏⠪⡂⢇⠕⡌⡪⠢⡊⢆⠕⢜⢸⢘⢌⢎⢧⣣⢢⠄⡀⠀⠀⠀⠀⠀⠀⠪⡨⠢⡣⡱⡁⠀⠀⠀⠀⠀⠀⠀⠀⢀⢜⢮⢣⠣⢣⢣⢣⢣⢊⠪⢢⢑⢕⣕⢤⠀⠀    ",
"⠠⡱⡏⡜⢌⢪⠢⠃⠚⠊⠪⠸⡐⢕⠱⡱⡑⡕⢜⢔⢭⢳⡫⡮⣦⢠⢀⠀⠀⠀⢕⠨⡨⢢⠣⡪⠀⠀⠀⠀⢀⡀⡤⣢⡣⣏⢇⢣⢑⢕⡕⡕⡕⢜⠸⡐⢕⢰⠨⡳⣁⠀    ",
"⢇⡯⣣⠱⠃⠀⠀⠀⠀⠀⠀⠈⠪⢪⢸⢪⢊⢎⢪⠢⡣⡳⡝⣞⢮⡳⣕⢝⢕⢠⠢⡑⢌⠢⡃⡇⢇⢎⢕⡽⣜⢮⢯⡺⡝⣎⢇⢕⢑⢜⢜⡜⡮⡪⡘⡌⢆⢕⢑⢜⢇⡀    ",
"⢕⢽⠜⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⡱⡱⡱⠑⠃⠉⠈⡓⠽⢎⢚⠜⡊⢔⠨⢢⢑⠌⡢⡑⢔⠡⡫⢪⠓⠯⠮⠳⠧⡳⠝⢮⢪⠢⡑⡵⣣⢳⠁⠈⠘⡬⡢⡑⢕⢜⢜⠅    ",
"⠣⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⠍⠀⠀⠀⡀⢔⠡⠑⠑⠰⣕⡌⡆⡕⢅⠢⢂⠢⡊⡔⡑⡸⢨⠪⣪⠪⠘⠔⠌⢅⠀⠈⢪⠸⣸⡊⠁⠀⠀⢰⢪⠨⠓⢕⢕⢝⢴    ",
"⠨⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢄⠢⡘⢌⠲⡁⠀⠀⠀⠗⢅⠣⡊⠔⠁⠁⠀⠀⠀⠈⠈⢎⠽⡅⠀⠀⠀⠈⠆⢕⢐⢀⠱⠕⠀⠀⠀⠀⢣⠳⠀⠂⠀⢳⢝⢜    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠳⠂⠕⡨⠢⠱⡀⠀⢀⢨⠑⢅⡕⠀⡀⠄⠐⠀⠁⠈⢀⠈⢄⠱⣁⠀⠀⠀⢀⠣⢑⠌⠆⢕⡱⠀⠀⠀⠀⡀⠅⡦⠀⠀⠈⡯⡪    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠋⠂⠀⠓⠂⢀⢢⠡⡑⡑⠀⠀⡀⠀⠠⠐⠈⠀⡀⠐⡐⢐⠐⡄⠀⠀⠑⠃⠀⡧⠕⠈⠀⠀⠀⠀⠠⠄⠸⠨⡃⠀⠀⠹⠌    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⡠⢃⠕⡨⢢⠀⠄⠁⠀⠀⠂⠀⠂⠁⢀⢐⢐⠐⡀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠱⠀⠀⠎⠫⡀⠊⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⢔⢢⢪⢕⡢⣒⢆⠄⢕⠨⡂⢕⠨⣢⠀⠄⠀⠂⠁⡀⠁⡀⠂⡐⡀⠢⢈⠄⢹⢒⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⢁⠀⡐⠜⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⢀⢔⢣⢓⢕⢕⢣⢣⢓⠵⡡⠃⡢⢑⠌⡢⡑⢼⠨⠐⠡⡈⠄⠄⠂⠄⠅⠂⠌⠨⢐⠈⡆⢕⢐⢅⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⡨⡒⠉⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⢠⢢⠣⡣⡃⡇⡕⡕⢕⢕⢣⠂⢅⠪⡐⡑⡔⡱⡙⠄⠅⠡⢐⠈⠄⠅⠡⠨⠈⠌⠨⠐⡬⠨⡂⢕⢐⠅⢕⡀⠀⠀⠀⠀⣀⢄⢎⠊⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⡇⡇⡇⡇⣕⢕⢕⢝⢜⢎⢎⡪⢢⢑⢌⢎⢜⠨⠀⠅⠌⡨⠐⠨⠠⠡⠁⠅⠡⢁⢅⢕⠜⡌⠢⡑⡐⡅⢅⢖⢆⢆⡝⡜⡜⠌⠁⠀⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⠘⠪⡪⢮⠪⡪⡚⡪⢪⠱⡑⡜⡸⡘⡜⡊⡒⡊⠌⡬⡐⠄⠅⣅⠅⠪⡌⡪⡊⡇⢏⡒⡇⡇⢇⢪⢘⢌⢎⢪⠱⠱⠑⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠐⢕⣑⢌⠪⡸⢱⠱⡡⡣⡱⣸⠐⠐⠊⠈⠀⠈⠁⠀⠀⠀⠀⠀⠀⠁⠁⠑⠚⠈⢪⠪⡚⢜⢌⢆⠣⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠜⢢⡑⢣⠪⠘⠌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠃⠡⢐⠣⢘⠄⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ",
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⡤⠈⠁⠨⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ",
}

-- {
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠡⠀⠑⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢂⠁⠄⢑⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠠⠐⠈⠠⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⡈⢀⠂⠌⠂⢄⠀⠀⠀⠀⠀⠀⡀⠄⢐⠈⠠⠐⡨⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⡀⡅⠐⠐⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢐⠠⠐⢀⠅⢀⠁⠐⠀⠌⠠⠁⠄⠐⡀⠨⢠⠑⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠄⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⡀⠔⠀⠀⠂⠀⡈⠐⠠⢀⠀⠀⠀⢀⡀⣀⢀⠀⡅⠠⠁⠀⠄⢀⠁⡐⢈⠠⠈⠄⡁⠄⠕⠁⠀⠀⠀⠀⠀⠀⠀⢀⠠⠠⠂⠁⠀⡀⠁⡁⠅⠂"
--   "⠀⠀⠀⠀⠀⠨⠂⠀⠠⠈⠀⠁⠀⠄⠂⠐⢈⠰⢪⣑⢌⡔⠑⠁⠄⡂⠄⠁⠄⠂⠠⠐⠀⢄⢑⢐⠠⡉⠀⠀⠀⠀⠀⠀⡀⠄⠂⠁⡀⠄⠀⠂⠁⠠⡐⠈⠀⠀"
--   "⠀⠀⠀⠀⠀⠁⠄⠰⠠⠐⠨⠄⠅⠄⡁⠌⠠⠐⠈⠪⡗⢧⢧⢌⠄⢂⢂⠂⡐⠈⠄⢂⠱⢐⠐⠄⢅⠌⢲⢐⢢⢢⠄⠊⡀⠂⠁⠄⢀⠠⠀⠂⠰⢈⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⡀⡀⠀⠀⠀⠀⠀⠀⠈⠈⠢⣅⡂⠘⡔⣝⢭⠯⡦⡈⡂⠄⢨⠨⡐⢈⠄⣅⣅⢥⢌⢤⢕⠕⠁⠄⡁⢄⡨⠠⠂⠄⠄⡀⠆⠊⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠠⠂⠂⢎⢦⡪⣕⠕⠕⡔⢅⠣⡱⢰⡘⡐⠕⢥⣂⡚⠵⣫⢯⡆⠂⡀⠆⠅⣢⣖⣟⢾⣸⠵⠝⡊⢐⡠⣕⢶⣝⣕⢗⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀"
--   "⢐⠀⣐⠠⠀⢕⢄⢂⢄⠂⡀⠄⣘⢼⡸⣜⠼⠁⠀⠀⠀⠀⠉⠈⢲⣲⡪⡂⢠⢡⢵⡱⣑⡩⣩⡰⡬⣲⠮⡫⢱⢱⣫⣞⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠢⠐⢔⠀⡑⡸⣂⠣⠜⠀⠄⢐⢌⠪⠌⠂⠂⠂⠂⠄⠀⠀⠀⠀⠀⠱⡽⣕⢧⡳⡣⡯⡺⣪⢗⡯⠏⠓⠓⠊⠆⣜⢌⠢⡊⢆⠆⠂⠢⣒⡲⣠⠤⠠⢀⠀⠀⠀"
--   "⠀⠀⠠⣂⢐⠬⠀⠉⡡⠈⡐⡜⢄⢂⠂⠄⠂⠡⠈⠄⡡⠀⠀⠀⠀⡠⣻⢝⣗⢯⣟⢾⢽⠽⠉⢀⠔⠐⠈⡀⡐⠑⠧⡳⡱⡝⡀⠄⠁⡆⢄⢄⡂⠠⠀⠅⠀⠀"
--   "⠀⠀⠀⠈⠀⠁⠀⠀⠈⠊⠂⠊⠀⢑⡢⠌⡄⡡⡈⡐⠈⠀⠀⠀⡬⡢⡊⡓⠵⢝⠾⢝⢏⠣⡀⢠⠐⢈⠀⠠⠠⢁⠂⢌⣑⢚⡀⠌⠀⣇⢆⢕⢬⠐⠈⡘⠄⡑"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡡⢠⠠⡀⢀⡀⢄⠢⡑⢔⢱⠨⡊⡪⠪⣘⢔⠕⢍⢪⡣⡣⡢⢌⢔⠨⣄⠎⢂⢐⠱⢢⠨⢔⠭⠫⠓⢱⠠⢅⠜⠈⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⡃⢎⢢⢣⡳⡑⢌⡢⠱⠌⠆⢣⢑⠌⠌⡜⡜⢔⠱⠁⡧⡳⡝⠜⠪⠲⣕⢕⠑⠁⠃⠁⠈⠈⠈⠀⠀⠀⠀⠈⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣣⡫⡣⠯⡺⣜⢽⠀⠀⠀⠀⠀⠀⠣⠪⡨⡣⠋⠁⠀⠀⠘⢍⠠⢀⠁⡅⣂⠢⠡⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠀⡁⠄⡑⠌⡞⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡄⠀⠎⠄⠠⡑⡅⡑⡀⡀⠄⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⡠⠢⠂⠂⠄⠄⡐⡁⢄⠂⠄⠂⢄⠱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⢁⠂⡅⢠⢃⠈⠌⠨⡀⡢⠊⠀⠅⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠊⢀⡰⡑⡌⢄⢱⠠⢠⠀⡘⢄⠑⠄⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠨⠀⢌⢪⢑⢅⠇⡇⢇⢣⢱⠱⠁⠈⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠁⠃⢇⢕⡠⡪⢪⢐⠌⠌⠌⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡅⠐⠈⢜⢌⢆⢇⢣⢃⢇⠕⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⡃⢎⢪⠢⡣⠡⢁⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢡⠀⠅⠢⡱⡘⡔⢅⢕⠸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢑⠅⢕⠱⡘⠌⢄⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⠄⡁⢎⢌⢊⠢⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠢⡑⠕⢅⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠨⢀⠇⢥⡑⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
--   "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⠢⡐⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
-- }

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---@usage Select which servers should be configured manually. Requires `:LvimCacheReset` to take effect.
-- See the full default list `:lua print(vim.inspect(lvim.lsp.override))`
-- vim.list_extend(lvim.lsp.override, { "pyright" })

-- ---@usage setup a server -- see: https://www.lunarvim.org/languages/#overriding-the-default-configuration
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pylsp", opts)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

lvim.lsp.automatic_servers_installation = false
vim.list_extend(lvim.lsp.override, { "tsserver" })

require("lspconfig")["tsserver"].setup({
  filetypes = {"typescript", "typescriptreact", "typescript.tsx" }
})

require("lspconfig")["eslint"].setup({
  -- cmd = { "eslint" },
  settings = {
    -- codeAction = {
    --   disableRuleComment = {
    --     enable = true,
    --     location = "separateLine"
    --   },
    --   showDocumentation = {
    --     enable = true
    --   }
    -- },
    codeActionOnSave = {
      enable = true,
      mode = "all"
    },
    -- format = true,
    -- nodePath = "",
    -- onIgnoredFiles = "off",
    -- packageManager = "npm",
    -- quiet = false,
    -- rulesCustomizations = {},
    -- run = "onType",
    -- useESLintClass = false,
    -- validate = "on",
    -- workingDirectory = {
    --   mode = "location"
    -- }
  }
})

-- set a formatter, this will override the language server formatting capabilities (if it exists)
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   {
--     -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "eslint",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     -- extra_args = { "--print-with", "100" },
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "javascriptreact" },
--   },
-- }

-- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   {
--     command = "eslint",
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "javascriptreact" },
--   },
-- }

-- Additional Plugins
lvim.plugins = {
  { "beanworks/vim-phpfmt" },
  { "junegunn/vim-easy-align" },
  { "folke/tokyonight.nvim" },
  -- {
  --   "sunjon/shade.nvim",
  --   config = function()
  --     require'shade'.setup({
  --       overlay_opacity = 50,
  --       opacity_step = 1,
  --       keys = {
  --         brightness_up    = '<C-Up>',
  --         brightness_down  = '<C-Down>',
  --         toggle           = '<leader>s',
  --       }
  --     })
  --   end
  -- },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd "highlight default link gitblame SpecialComment"
      vim.g.gitblame_enabled = 0
      vim.g.gitblame_ignored_filetypes = { 'NvimTree', 'spectre_panel', 'DiffviewFiles', 'DiffviewFileHistory', 'octo', 'octo_panel' }
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  { "tpope/vim-surround" },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufRead",
    config = function()
      require'indent_blankline'.setup({
        char = "▏",
        filetype_exclude = {"help", "terminal", "dashboard", "NvimTree", "lsp-installer", "spectre_panel", "packer"},
        buftype_exclude = {"terminal", "NvimTree"},
        show_trailing_blankline_indent = false,
        show_first_indent_level = false
      })
    end
  },
  {
    "ggandor/lightspeed.nvim",
    event = "BufRead",
  },
  { "folke/twilight.nvim" },
  {
    "sindrets/diffview.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function ()
      require'diffview'.setup({
        file_panel = {
          listing_style = "list"
        }
      })
    end
  },
  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup {
        window = {
          backdrop = 0,
          options = {
            number = true
          }
        },
        plugins = {
          gitsigns = { enabled = true }
        }
      }
    end
  },
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require'scrollbar'.setup()
    end
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require'colorizer'.setup()
    end
  },
  {
    "windwp/nvim-spectre",
    config = function ()
      require'spectre'.setup({
        line_sep_start = '                                          ',
        result_padding = ' ',
        line_sep       = '                                          ',
        mapping = {
          ['send_to_qf'] = {
            map = "<leader>f",
            cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
            desc = "send all item to quickfix"
          },
        }
      })
    end
  },
  { "pwntester/octo.nvim" },
  { "chrisbra/unicode.vim" },
  { "nelsyeung/twig.vim" },
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--   { "BufWritePre", "<buffer>", ":EslintFixAll" },
-- }
