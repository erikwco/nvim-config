-- Elixir: elixir-ls, treesitter, mix como formatter, neotest-elixir y DAP.
-- No se usa el extra `lang.elixir` de LazyVim a propósito: su spec de nvim-lint
-- hace `opts.linters_by_ft = { elixir = { "credo" } }` (reemplaza en vez de
-- mezclar) y borra los linters de los extras que cargan antes (hadolint de
-- lang.docker, por ejemplo). Este archivo cubre lo mismo sin ese efecto.
return {
  {
    "neovim/nvim-lspconfig",
    opts = { servers = { elixirls = {} } },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "elixir-ls" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "elixir", "heex", "eex" })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        elixir = { "mix" },
        heex = { "mix" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = { "jfpedroza/neotest-elixir" },
    opts = { adapters = { ["neotest-elixir"] = {} } },
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      -- La base de DAP la pone el extra dap.core; aquí solo el adaptador de Elixir.
      local dap = require("dap")
      dap.adapters.mix_task = {
        type = "executable",
        command = "elixir-ls-debugger",
      }
      -- ElixirLS anuncia una lista vacía y rechaza setExceptionBreakpoints.
      dap.listeners.before.event_initialized.elixir = function(session)
        if
          session.config.type == "mix_task" and vim.tbl_isempty(session.capabilities.exceptionBreakpointFilters or {})
        then
          session.capabilities.exceptionBreakpointFilters = nil
        end
      end
      dap.configurations.elixir = {
        {
          type = "mix_task",
          name = "mix test",
          request = "launch",
          task = "test",
          taskArgs = { "--trace" },
          projectDir = "${workspaceFolder}",
          requireFiles = { "test/**/test_helper.exs", "test/**/*_test.exs" },
          startApps = true,
        },
        {
          type = "mix_task",
          name = "mix run",
          request = "launch",
          task = "run",
          taskArgs = { "--no-halt" },
          projectDir = "${workspaceFolder}",
          startApps = true,
        },
      }
    end,
  },
}
