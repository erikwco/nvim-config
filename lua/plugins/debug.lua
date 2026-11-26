-- DAP: la base (nvim-dap, dap-ui con auto open/close, virtual text, mason-nvim-dap,
-- launch.json y los atajos <leader>d*) la pone el extra `dap.core` de LazyVim.
-- Los adapters por lenguaje viven en sus archivos: dotnet-dap.lua, js-debug.lua,
-- elixir.lua, jdtls-lombok.lua (Java), extras lang.go / lang.rust.
-- Teclas de función (F5/F9/F10/F11) en config/keymaps.lua.
return {
  -- Iconos de breakpoints (LazyVim los define desde config.icons.dap)
  {
    "LazyVim/LazyVim",
    opts = {
      icons = {
        dap = {
          Breakpoint = { "⬤", "DiagnosticError" },
          BreakpointCondition = { "⬕", "DiagnosticWarn" },
          BreakpointRejected = { "⬤", "DiagnosticHint" },
          LogPoint = { "◆", "DiagnosticInfo" },
          Stopped = { "→", "DiagnosticOk", "DapStoppedLine" },
        },
      },
    },
  },

  {
    "mfussenegger/nvim-dap",
    keys = {
      -- Atajos extra; <leader>dw (hover de variables) y <leader>de (eval) ya los da el extra.
      {
        "<leader>dv",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.scopes)
        end,
        desc = "Scopes (float)",
      },
      {
        "<leader>df",
        function()
          require("dapui").float_element()
        end,
        desc = "Dap UI: float element",
      },
    },
    opts = function()
      local dap = require("dap")
      -- Java/Spring Boot: las configurations las puebla JDTLS en on_attach
      -- (setup_dap_main_class_configs detecta las clases con main()). Aquí solo
      -- añadimos un "Attach" genérico para `mvnw spring-boot:run` con JDWP en :5005
      -- (<leader>md) o `gradlew bootRun --debug-jvm` (<leader>Gd).
      dap.configurations.java = dap.configurations.java or {}
      table.insert(dap.configurations.java, {
        type = "java",
        request = "attach",
        name = "Attach to remote JVM (port 5005)",
        hostName = "localhost",
        port = 5005,
      })
    end,
  },
}
