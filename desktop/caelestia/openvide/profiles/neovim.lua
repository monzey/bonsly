-- Session profile loaded by openvide after the user's Neovim configuration.
if vim.g.openvide_profile_loaded then
  return
end
vim.g.openvide_profile_loaded = true


local group = vim.api.nvim_create_augroup("openvide_nvim_startup", { clear = true })
local ready = not vim.g.lazy_did_setup
local scheduled, stdin = false, false

local function open_diff()
  if not ready or scheduled or vim.v.vim_did_enter == 0 or #vim.api.nvim_list_uis() == 0 then
    return
  end
  scheduled = true
  vim.schedule(function()
    vim.api.nvim_del_augroup_by_id(group)
    if stdin or vim.fn.argc(-1) > 0 or vim.bo.modified then
      return
    end
    if vim.api.nvim_buf_get_name(0) ~= "" and vim.bo.filetype ~= "snacks_dashboard" then
      return
    end
    if not vim.fs.root(vim.uv.cwd(), { ".git" }) then
      return
    end
    vim.cmd("Unified HEAD")
  end)
end

-- LazyVim's dashboard and Neovide's UI may become ready in either order.
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "VeryLazy",
  once = true,
  callback = function()
    ready = true
    open_diff()
  end,
})
vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter" }, { group = group, callback = open_diff })
vim.api.nvim_create_autocmd("StdinReadPre", {
  group = group,
  callback = function()
    stdin = true
  end,
})
open_diff()
