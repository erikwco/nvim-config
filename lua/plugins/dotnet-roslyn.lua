-- C# vía Roslyn LSP (reemplaza OmniSharp).
-- Roslyn LSP es el servidor oficial de Microsoft: autoimport real,
-- code actions completas, soporte SDK 9/10 y mucho más rápido.

return {
  -- 1) Mason: añadir registry de Crashdummyy (donde vive el paquete `roslyn`)
  --    e instalar la versión distribuida con VS Code.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.registries = opts.registries or {
        "github:mason-org/mason-registry",
      }
      if not vim.tbl_contains(opts.registries, "github:Crashdummyy/mason-registry") then
        table.insert(opts.registries, "github:Crashdummyy/mason-registry")
      end
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "roslyn") then
        table.insert(opts.ensure_installed, "roslyn")
      end
    end,
  },

  -- 2) Saltar el setup de OmniSharp que trae el extra lang.dotnet de LazyVim
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        omnisharp = function()
          return true -- LazyVim convention: true = no llamar a lspconfig.setup
        end,
      },
    },
  },

  -- 3) Roslyn LSP
  {
    "seblyng/roslyn.nvim",
    ft = { "cs" },
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      filewatching = "auto",
      choose_target = nil, -- elige automáticamente .sln/.csproj
      ignore_target = nil,
      broad_search = false,
      lock_target = false,
    },
    -- Registrar antes de cargar el plugin: este habilita el LSP al cargarse.
    init = function()
      -- El servidor instalado por Mason puede ser anterior al modo daemon.
      -- stdio funciona también con esas versiones (por ejemplo, Roslyn 5.8).
      vim.lsp.config("roslyn", {
        cmd = {
          "roslyn-language-server", -- Mason añade su directorio bin al PATH.
          "--stdio",
          "--clientProcessId",
          tostring(vim.uv.os_getpid()),
        },
        -- Los ajustes del servidor van en vim.lsp.config, no en opts.config.
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
          },
          ["csharp|completion"] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true, -- autoimport
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|background_analysis"] = {
            dotnet_compiler_diagnostics_scope = "fullSolution",
            dotnet_analyzer_diagnostics_scope = "fullSolution",
          },
          ["csharp|symbol_search"] = {
            dotnet_search_reference_assemblies = true,
          },
        },
      })
    end,
  },
}
