#!/bin/sh
# Comprueba la configuración instalada con un proyecto Mix temporal.
set -eu
check_dir=$(mktemp -d "${TMPDIR:-/tmp}/nvim-elixir-check.XXXXXX")
trap 'rm -rf "$check_dir"' EXIT
mix new "$check_dir/elixir_check"
cd "$check_dir/elixir_check"
mix test
cat > "$check_dir/validate.lua" <<'LUA'
vim.schedule(function()
  local ok, err = xpcall(function()
    assert(vim.bo.filetype == 'elixir', 'Elixir filetype missing')
    assert(vim.bo.shiftwidth == 2, 'Elixir must use two-space indent')
    for _, lang in ipairs({ 'elixir', 'heex', 'eex' }) do
      assert(vim.treesitter.language.add(lang), lang .. ' parser missing')
    end
    local parser = vim.treesitter.get_parser(0, 'elixir')
    assert(not parser:parse()[1]:root():has_error(), 'Elixir parse failed')
    print('PASS: filetype, indentation, syntax parsers')
    assert(vim.wait(180000, function()
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = 'elixirls' })) do
        if client.initialized then return true end
      end
    end, 100), 'ElixirLS did not attach')
    local client = vim.lsp.get_clients({ bufnr = 0, name = 'elixirls' })[1]
    local hello_line
    for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      if line:match('^  def hello') then hello_line = i - 1; break end
    end
    assert(hello_line, 'Sample function missing')
    local hover = client:request_sync('textDocument/hover', {
      textDocument = { uri = vim.uri_from_bufnr(0) },
      position = { line = hello_line, character = 7 },
    }, 60000, 0)
    assert(hover and not hover.err and hover.result and hover.result.contents, 'LSP hover failed: ' .. vim.inspect(hover))
    print('PASS: ElixirLS connected and returned hover documentation')
    local conform = require('conform')
    assert(conform.get_formatter_info('mix').available, 'mix formatter unavailable')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'defmodule ElixirCheck do', 'def hello,do: :world', 'end' })
    local format_error
    conform.format({ async = false, timeout_ms = 30000, lsp_format = 'never' }, function(e) format_error = e end)
    assert(not format_error, tostring(format_error))
    assert(vim.api.nvim_buf_get_lines(0, 1, 2, false)[1] == '  def hello, do: :world', 'mix format did not format buffer')
    vim.cmd('write')
    print('PASS: mix format changed the buffer correctly')
    local neotest = require('neotest')
    local testfile = vim.fn.getcwd() .. '/test/elixir_check_test.exs'
    vim.cmd.edit(testfile)
    neotest.run.run(testfile)
    local counts
    assert(vim.wait(90000, function()
      for _, id in ipairs(neotest.state.adapter_ids()) do
        if id:find('neotest%-elixir') then
          counts = neotest.state.status_counts(id)
          if counts and counts.passed > 0 and counts.running == 0 then return true end
        end
      end
    end, 100), 'Neotest did not report passing Elixir tests: ' .. vim.inspect(counts))
    assert(counts.failed == 0, vim.inspect(counts))
    print('PASS: neotest-elixir executed ExUnit tests: ' .. vim.inspect(counts))
    local dap = require('dap')
    assert(dap.adapters.mix_task and vim.fn.executable(dap.adapters.mix_task.command) == 1, 'Elixir debug adapter unavailable')
    local stopped, exited, successful = false, false, false
    local debug_output = {}
    dap.listeners.after.event_output.elixir_check = function(_, body)
      if body.category ~= 'telemetry' then
        debug_output[#debug_output + 1] = body.output
        if body.output:find('returning code 0', 1, true) then successful = true end
      end
    end
    dap.listeners.after.event_exited.elixir_check = function(_, body) successful = body.exitCode == 0 end
    dap.listeners.after.event_terminated.elixir_check = function() exited = true end
    dap.listeners.after.event_stopped.elixir_check = function(session, body)
      stopped = body.reason == 'breakpoint'
      -- Permite que DAP obtenga el stack antes de continuar el proceso detenido.
      vim.defer_fn(function()
        session:request('continue', { threadId = body.threadId, singleThread = true }, function() end)
      end, 200)
    end
    vim.cmd.edit(vim.fn.getcwd() .. '/lib/elixir_check.ex')
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    dap.set_breakpoint()
    dap.run(vim.deepcopy(dap.configurations.elixir[1]))
    assert(vim.wait(90000, function() return exited end, 100), 'DAP did not complete')
    assert(stopped, 'DAP did not stop at breakpoint')
    assert(successful, 'DAP task failed: ' .. table.concat(debug_output, ''))
    print('PASS: DAP stopped at a breakpoint and completed mix test')
  end, debug.traceback)
  vim.lsp.stop_client(vim.lsp.get_clients(), true)
  if not ok then print('FAIL: ' .. tostring(err)) end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end)
LUA
NVIM_ELIXIR_CHECK_LUA="$check_dir/validate.lua" nvim --headless -n -i NONE lib/elixir_check.ex '+lua dofile(vim.env.NVIM_ELIXIR_CHECK_LUA)'
