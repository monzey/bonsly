local M = {}

function M.setup(_, opts)
  require("unified").setup(opts)
  local command = require("unified.command")
  local run = command.run
  command.run = function(args, command_opts)
    if args ~= "reset" and vim.bo.filetype == "snacks_dashboard" then
      vim.cmd("enew")
    end
    return run(args, command_opts)
  end
  local state = require("unified.state")
  local tree = require("unified.file_tree")
  local actions = require("unified.file_tree.actions")
  local navigation = require("unified.navigation")
  local tab = vim.api.nvim_get_current_tabpage()
  local group = vim.api.nvim_create_augroup("openvide_nvim_view", { clear = true })

  local function tree_visible()
    return state.file_tree_win and vim.api.nvim_win_is_valid(state.file_tree_win)
  end

  local function select_file()
    local tree_state = require("unified.file_tree.state")
    local node = tree_state.line_to_node[vim.api.nvim_win_get_cursor(0)[1] - 1]
    if not node or node.is_dir then
      return
    end
    actions.toggle_node()
    if state.main_win and vim.api.nvim_win_is_valid(state.main_win)
      and vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(state.main_win)) == node.path then
      vim.api.nvim_set_current_win(state.main_win)
    end
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "unified_tree",
    callback = function(event)
      -- Override the ftplugin selection to focus the code window.
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(event.buf) then
          for _, key in ipairs({ "<CR>", "l" }) do
            vim.keymap.set("n", key, select_file, { buffer = event.buf, desc = "Open changed file" })
          end
        end
      end)
    end,
  })
  vim.keymap.set("n", "<leader>b", function()
    if tree_visible() then
      vim.api.nvim_win_close(state.file_tree_win, true)
    elseif state.is_active() then
      tree.show(state.get_commit_base())
      vim.api.nvim_set_current_win(state.file_tree_win)
    else
      vim.cmd("Unified HEAD")
    end
  end, { desc = "Toggle changed files" })
  vim.keymap.set("n", "<leader>gD", function()
    require("unified.command").reset()
    -- LazyVim may already manage Diffview; otherwise load the Nix-supplied plugin.
    if vim.fn.exists(":DiffviewOpen") == 0 then
      vim.cmd.runtime("plugin/diffview.lua")
    end
    vim.cmd("DiffviewOpen")
  end, { desc = "Open Diffview" })
  vim.keymap.set("n", "]h", navigation.next_hunk, { desc = "Next diff hunk" })
  vim.keymap.set("n", "[h", navigation.previous_hunk, { desc = "Previous diff hunk" })

  vim.api.nvim_create_autocmd({ "BufEnter", "FileChangedShellPost", "TextChanged", "InsertLeave" }, {
    group = group,
    callback = function(event)
      if not state.is_active() or vim.api.nvim_get_current_tabpage() ~= tab
        or vim.bo[event.buf].buftype ~= "" or vim.api.nvim_buf_get_name(event.buf) == "" then
        return
      end
      vim.wo.wrap, vim.wo.linebreak, vim.wo.breakindent = true, true, true
      require("unified.diff").show(state.get_commit_base(), event.buf)
    end,
  })

  -- Watch external agent edits too. checktime preserves modified buffers and
  -- uses Neovim's normal conflict handling rather than forcing a reload.
  local timer = assert(vim.uv.new_timer())
  local busy, status, selected = false, nil, false
  timer:start(200, 1000, vim.schedule_wrap(function()
    if busy or not state.is_active() or vim.api.nvim_get_current_tabpage() ~= tab then
      return
    end
    vim.cmd("checktime")
    if not selected and tree_visible() then
      local tree_state = require("unified.file_tree.state")
      local lines = vim.tbl_keys(tree_state.line_to_node)
      table.sort(lines)
      for _, line in ipairs(lines) do
        local node = tree_state.line_to_node[line]
        if not node.is_dir then
          vim.api.nvim_win_call(state.file_tree_win, function()
            vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
            actions.toggle_node()
          end)
          if state.main_win and vim.api.nvim_win_is_valid(state.main_win)
            and vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(state.main_win)) == node.path then
            selected = true
            vim.api.nvim_set_current_win(state.main_win)
          end
          break
        end
      end
    end
    busy = true
    vim.system({ "git", "status", "--porcelain=v1", "-z", "--untracked-files=all" }, {},
      vim.schedule_wrap(function(result)
        busy = false
        if result.code ~= 0 or not state.is_active() or vim.api.nvim_get_current_tabpage() ~= tab then
          return
        end
        if result.stdout ~= status and tree_visible() then
          vim.api.nvim_win_call(state.file_tree_win, actions.refresh)
        end
        status = result.stdout
      end))
  end))
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    once = true,
    callback = function()
      timer:stop()
      timer:close()
    end,
  })
end

return M
