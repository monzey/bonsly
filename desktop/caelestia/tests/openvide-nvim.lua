-- Run with OPENVIDE_TEST_PLUGINS=<built-shell>/share/caelestia-shell/assets/nvim-plugins
-- XDG_CACHE_HOME=/tmp/openvide-test-cache NVIM_LOG_FILE=/tmp/openvide-test.log
-- nvim --headless -u NONE -i NONE -c 'luafile desktop/caelestia/tests/openvide-nvim.lua'
local root = vim.fs.dirname(vim.fs.dirname(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")))
local plugins = assert(vim.env.OPENVIDE_TEST_PLUGINS, "Set OPENVIDE_TEST_PLUGINS to the packaged plugin directory")
vim.schedule(function()
  local ok, err = xpcall(function()
    local repo = vim.fn.tempname()
    vim.fn.mkdir(repo, 'p')
    for _, plugin in ipairs({ 'unified.nvim', 'diffview.nvim', 'plenary.nvim' }) do
      vim.opt.runtimepath:prepend(plugins .. '/' .. plugin)
    end
    vim.cmd('filetype plugin on')
    vim.o.linespace = 6
    vim.o.autoread = true
    vim.o.hidden = true
    vim.o.swapfile = false
    vim.g.mapleader = ' '
    vim.cmd.cd(repo)
    local function git(args)
      local command = { 'git', '-c', 'core.hooksPath=/dev/null' }
      vim.list_extend(command, args)
      local result = vim.system(command, { cwd = repo }):wait()
      assert(result.code == 0, result.stderr)
    end
    git({ 'init', '-q' })
    git({ 'config', 'diff.external', 'difft' })
    vim.fn.writefile({ 'local value = 1', 'return value' }, repo .. '/test.lua')
    git({ 'add', 'test.lua' })
    git({ '-c', 'user.name=Test', '-c', 'user.email=test@example.invalid', 'commit', '--allow-empty', '-qm', 'fixture' })
    -- The headless harness supplies the UI presence needed by the startup gate.
    vim.api.nvim_list_uis = function() return { {} } end
    local common = root .. '/../../home-manager/configs/nvim'
    vim.opt.runtimepath:prepend(common)
    require('config.unified').setup(nil, { auto_refresh = false, file_tree = { width = 28, focus = false } })
    assert(not require('unified.state').is_active(), 'ordinary startup leaves diff closed')
    vim.cmd.runtime('plugin/unified.lua')
    vim.bo.buftype = 'nofile'
    vim.bo.filetype = 'snacks_dashboard'
    local dashboard = vim.api.nvim_get_current_buf()
    dofile(root .. '/assets/openvide-nvim.lua')
    local function wait_for(predicate, label)
      assert(vim.wait(5000, predicate, 30), label .. '\n' .. vim.fn.execute('messages'))
    end
    wait_for(function() return package.loaded['unified.state'] and require('unified.state').is_active() end, 'startup')
    assert(vim.o.linespace == 6, 'startup preserves line spacing')
    local state = require('unified.state')
    wait_for(function() return state.file_tree_win and vim.api.nvim_win_is_valid(state.file_tree_win) end, 'clean tree')
    vim.fn.writefile({ 'local value = 2', 'return value' }, repo .. '/test.lua')
    wait_for(function() return state.main_win and vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(state.main_win)) == repo .. '/test.lua' end, 'first agent change selected')
    assert(vim.api.nvim_win_is_valid(state.file_tree_win), 'tree stays visible after automatic selection')
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      assert(vim.api.nvim_win_get_buf(win) ~= dashboard, 'dashboard replaced')
    end
    local buf = vim.api.nvim_win_get_buf(state.main_win)
    assert(vim.bo[buf].buftype == '' and vim.bo[buf].modifiable and vim.bo[buf].filetype == 'lua', 'real editable lua buffer')
    wait_for(function() return require('unified.diff').is_diff_displayed(buf) end, 'inline diff rendered')
    vim.fn.writefile({ 'local value = 3', 'return value' }, repo .. '/test.lua')
    wait_for(function() return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == 'local value = 3' end, 'external reload')
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, { 'local value = 4' })
    vim.api.nvim_exec_autocmds('TextChanged', { buffer = buf })
    assert(vim.bo[buf].modified and require('unified.diff').is_diff_displayed(buf), 'unsaved edit diff')
    vim.fn.writefile({ 'local value = 5', 'return value' }, repo .. '/test.lua')
    vim.wait(1500)
    assert(vim.bo[buf].modified and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == 'local value = 4', 'unsaved edits protected')
    vim.cmd('write!')
    assert(vim.fn.readfile(repo .. '/test.lua')[1] == 'local value = 4', 'save works')
    -- Execute the actual mappings through their Lua callbacks.
    local maps = {}
    for _, map in ipairs(vim.api.nvim_get_keymap('n')) do maps[map.lhs] = map.callback end
    maps[' b']()
    assert(not vim.api.nvim_win_is_valid(state.file_tree_win), 'manual toggle hides tree')
    maps[' b']()
    wait_for(function() return state.file_tree_win and vim.api.nvim_win_is_valid(state.file_tree_win) end, 'tree toggle')
    local tree_state = require('unified.file_tree.state')
    wait_for(function() return next(tree_state.line_to_node) ~= nil end, 'tree repopulated')
    vim.wait(100)
    local line = vim.tbl_keys(tree_state.line_to_node)[1]
    vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
    local select
    for _, map in ipairs(vim.api.nvim_buf_get_keymap(tree_state.buffer, 'n')) do if map.lhs == '<CR>' then select = map.callback end end
    assert(select, 'selection mapping installed')
    select()
    assert(vim.api.nvim_win_is_valid(state.file_tree_win), 'manual selection keeps tree')
    assert(vim.api.nvim_get_current_win() == state.main_win, 'selection focuses code')
    assert(vim.o.linespace == 6, 'diff selection preserves line spacing')
    maps[' gD']()
    wait_for(function() return not state.is_active() and vim.fn.exists(':DiffviewClose') == 2 end, 'diffview available')
    vim.cmd('DiffviewClose')
    print('PASS: clean startup, agent edits, inline rendering, real buffer, edit/save, unsaved protection, tree toggle/select, Diffview')
  end, debug.traceback)
  if not ok then
    print(err)
    vim.cmd('cquit')
  end
  vim.cmd('qa!')
end)
