-- Debug de JavaScript / TypeScript / React vía js-debug (Microsoft).
-- Requiere js-debug-adapter instalado por Mason (ya lo tienes).
--
-- Atajos genéricos de DAP (<leader>db, <leader>dc, F5, F9...) ya están
-- definidos en debug.lua y config/keymaps.lua. Aquí solo registramos
-- el adapter y las configurations por filetype.

return {
  -- 1) Mason: instalar js-debug-adapter
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "js-debug-adapter" })
    end,
  },

  -- 2) Bridge: nvim-dap-vscode-js conecta js-debug al protocolo DAP
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    config = function()
      local mason = vim.fn.stdpath("data") .. "/mason"
      require("dap-vscode-js").setup({
        debugger_path = mason .. "/packages/js-debug-adapter",
        debugger_cmd = { "js-debug-adapter" }, -- Mason crea el shim en PATH
        adapters = {
          "pwa-node",
          "pwa-chrome",
          "pwa-msedge",
          "node-terminal",
          "pwa-extensionHost",
        },
      })

      local dap = require("dap")
      local js_filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

      for _, ft in ipairs(js_filetypes) do
        dap.configurations[ft] = {
          -- Node: lanzar el archivo actual
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file (Node)",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
          },
          -- Node: lanzar con ts-node/tsx si es TS sin transpilar
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
          -- Node: attach a proceso ya corriendo con --inspect
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node (--inspect, :9229)",
            processId = require("dap.utils").pick_process,
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
            runtimeArgs = {
              "./node_modules/jest/bin/jest.js",
              "--runInBand",
              "--no-coverage",
              "${file}",
            },
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
            runtimeArgs = {
              "./node_modules/vitest/vitest.mjs",
              "run",
              "${file}",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
          },
          -- React: attach a Chrome en localhost (asume que el dev server ya corre)
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
      end
    end,
  },
}
