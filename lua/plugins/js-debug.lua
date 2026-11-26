-- Debug de JavaScript / TypeScript / React vía js-debug (Microsoft).
--
-- El extra `lang.typescript` de LazyVim ya instala js-debug-adapter por Mason y
-- registra los adapters pwa-node / pwa-chrome / pwa-msedge (y sus alias sin
-- "pwa-") con configurations básicas "Launch file" y "Attach". Aquí solo
-- AÑADIMOS configurations extra (tsx, Jest, Vitest, Chrome en 3000/5173).
-- Ya no se usa mxsdev/nvim-dap-vscode-js (sin mantenimiento desde 2023).
--
-- Atajos genéricos de DAP: <leader>d* (extra dap.core) y F5/F9/F10/F11 (config/keymaps.lua).

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      local js_filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

      local extra_configs = {
        -- Node: lanzar con tsx si es TS sin transpilar
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file with tsx (TS)",
          runtimeExecutable = "tsx",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          skipFiles = { "<node_internals>/**", "node_modules/**" },
        },
        -- Jest: archivo actual
        {
          type = "pwa-node",
          request = "launch",
          name = "Debug Jest (current file)",
          runtimeExecutable = "node",
          runtimeArgs = { "./node_modules/jest/bin/jest.js", "--runInBand", "--no-coverage", "${file}" },
          rootPath = "${workspaceFolder}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
          sourceMaps = true,
          skipFiles = { "<node_internals>/**", "node_modules/**" },
        },
        -- Vitest: archivo actual
        {
          type = "pwa-node",
          request = "launch",
          name = "Debug Vitest (current file)",
          runtimeExecutable = "node",
          runtimeArgs = { "./node_modules/vitest/vitest.mjs", "run", "${file}" },
          rootPath = "${workspaceFolder}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
          sourceMaps = true,
          skipFiles = { "<node_internals>/**", "node_modules/**" },
        },
        -- React: Chrome contra el dev server (asume que ya corre)
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome → localhost:3000 (React)",
          url = "http://localhost:3000",
          webRoot = "${workspaceFolder}",
          sourceMaps = true,
          userDataDir = false,
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome → localhost:5173 (Vite)",
          url = "http://localhost:5173",
          webRoot = "${workspaceFolder}",
          sourceMaps = true,
          userDataDir = false,
        },
      }

      for _, ft in ipairs(js_filetypes) do
        dap.configurations[ft] = dap.configurations[ft] or {}
        for _, cfg in ipairs(extra_configs) do
          table.insert(dap.configurations[ft], cfg)
        end
      end
    end,
  },
}
