-- Flutter / Dart en Neovim vía flutter-tools.nvim.
--
-- flutter-tools MANEJA el Dart LSP (dartls) por sí solo — NO se instala aparte
-- por Mason; viene dentro del SDK de Flutter. Por eso NO activamos el extra
-- `lang.dart` de LazyVim (que arrancaría un segundo dartls y duplicaría todo).
--
-- SDK: ~/Apps/flutter (apuntamos directo al binario, sin depender del PATH).

return {
  -- Parser de treesitter para Dart (highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "dart" })
    end,
  },

  -- flutter-tools: LSP + run + hot reload + devices/emulators + outline
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = { "nvim-lua/plenary.nvim" }, -- devices/comandos vía vim.ui.select (snacks)
    opts = function()
      -- Capabilities de blink.cmp (tu motor de completion) para el LSP
      local capabilities
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities()
      end

      return {
        -- Ruta al binario de Flutter (PATH-independiente)
        flutter_path = vim.fn.expand("~/Apps/flutter/bin/flutter"),

        -- Cierra tags con el nombre del widget al final ( // Widget )
        closing_tags = {
          highlight = "Comment",
          prefix = "  // ",
          enabled = true,
        },

        -- Log de la app corriendo (flutter run) en un buffer
        dev_log = {
          enabled = true,
          open_cmd = "botright 15split", -- log abajo, 15 líneas
        },

        -- Recarga en caliente al guardar
        dev_tools = {
          autostart = false, -- no abrir DevTools solo; se abre con :FlutterDevTools
          auto_open_browser = false,
        },

        -- Widget outline (árbol de widgets) en un panel
        widget_guides = { enabled = true },

        -- Decoraciones del outline
        outline = {
          open_cmd = "30vnew",
          auto_open = false,
        },

        lsp = {
          capabilities = capabilities,
          -- color = { enabled = true }, -- resalta colores en el código
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt", -- al renombrar clase, ofrece renombrar archivo
            enableSnippets = true,
            updateImportsOnRename = true, -- arregla imports al mover/renombrar archivos
          },
        },
      }
    end,
    keys = {
      -- Prefix <leader>F* (Flutter)
      { "<leader>Fr", "<cmd>FlutterRun<cr>", desc = "Flutter: Run", ft = "dart" },
      { "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Flutter: Quit", ft = "dart" },
      { "<leader>Fl", "<cmd>FlutterReload<cr>", desc = "Flutter: Hot Reload", ft = "dart" },
      { "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Flutter: Hot Restart", ft = "dart" },
      { "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Flutter: Devices", ft = "dart" },
      { "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Flutter: Emulators", ft = "dart" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Flutter: Outline (widgets)", ft = "dart" },
      { "<leader>FD", "<cmd>FlutterDevTools<cr>", desc = "Flutter: DevTools", ft = "dart" },
      { "<leader>Fc", "<cmd>FlutterLogClear<cr>", desc = "Flutter: Clear log", ft = "dart" },
      { "<leader>Fp", "<cmd>FlutterLogToggle<cr>", desc = "Flutter: Toggle log panel", ft = "dart" },
      { "<leader>Fs", "<cmd>FlutterSuper<cr>", desc = "Flutter: Go to superclass", ft = "dart" },
      { "<leader>Fg", "<cmd>FlutterPubGet<cr>", desc = "Flutter: pub get", ft = "dart" },
      { "<leader>Fu", "<cmd>FlutterPubUpgrade<cr>", desc = "Flutter: pub upgrade", ft = "dart" },
      { "<leader>Fa", "<cmd>FlutterAttach<cr>", desc = "Flutter: Attach a app corriendo", ft = "dart" },
      { "<leader>Fb", "<cmd>FlutterToggleBrightness<cr>", desc = "Flutter: Toggle brightness (light/dark)", ft = "dart" },
    },
    config = function(_, opts)
      require("flutter-tools").setup(opts)
    end,
  },
}
