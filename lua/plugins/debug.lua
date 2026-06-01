return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-jdtls", -- Este es el correcto para Java
      "nvim-neotest/nvim-nio",
    },
    keys = {
      -- Breakpoints
      { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "Toggle Breakpoint" },
      {
        "<leader>dB",
        "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
        desc = "Conditional Breakpoint",
      },
      {
        "<leader>dl",
        "<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
        desc = "Logpoint",
      },
      -- Debugger Control
      { "<leader>dc", "<cmd>DapContinue<CR>", desc = "Start/Continue" },
      { "<leader>di", "<cmd>DapStepInto<CR>", desc = "Step Into" },
      { "<leader>do", "<cmd>DapStepOver<CR>", desc = "Step Over" },
      { "<leader>dO", "<cmd>DapStepOut<CR>", desc = "Step Out" },
      { "<leader>dr", "<cmd>DapToggleRepl<CR>", desc = "Toggle REPL" },
      { "<leader>dt", "<cmd>DapTerminate<CR>", desc = "Terminate" },
      { "<leader>dp", "<cmd>lua require('dap.ui.widgets').preview()<CR>", desc = "Preview" },
      -- DAP-UI
      { "<leader>du", "<cmd>lua require('dapui').toggle()<CR>", desc = "Toggle UI" },
      { "<leader>de", "<cmd>lua require('dapui').eval()<CR>", desc = "Evaluate Expression" },
      { "<leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<CR>", desc = "Hover Variables" },
      {
        "<leader>dw",
        "<cmd>lua local widgets=require('dap.ui.widgets');widgets.centered_float(widgets.scopes)<CR>",
        desc = "Widgets",
      },

      -- Session
      { "<leader>ds", "<cmd>lua require('dap').continue()<CR>", desc = "Start Debug Session" },
      { "<leader>dq", "<cmd>lua require('dap').close()<CR>", desc = "Quit Debug Session" },
    },
    config = function()
      local dap = require("dap")
      -- Iconos para breakpoints (requiere un Nerd Font)
      vim.fn.sign_define("DapBreakpoint", { text = "⬤", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "⬕", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
      )
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStopped", numhl = "" })
      -- Java/Spring Boot:
      -- Las configurations las puebla JDTLS automáticamente en on_attach
      -- (require("jdtls.dap").setup_dap_main_class_configs() detecta las clases
      -- con main() del proyecto). Aquí solo añadimos un "Attach" genérico
      -- para el caso `mvnw spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=...port=5005"`
      -- o `gradle bootRun --debug-jvm`.
      dap.configurations.java = dap.configurations.java or {}
      table.insert(dap.configurations.java, {
        type = "java",
        request = "attach",
        name = "Attach to remote JVM (port 5005)",
        hostName = "localhost",
        port = 5005,
      })

      -- Highlights personalizados
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#993939", bg = "#31353f" })
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef", bg = "#31353f" })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bg = "#31353f" })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<leader>duc", "<cmd>lua require('dapui').close()<CR>", desc = "Close DAP UI" },
      { "<leader>duf", "<cmd>lua require('dapui').float_element()<CR>", desc = "Float Element" },
    },
    config = function()
      local dapui = require("dapui")
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 10,
          },
        },
      })
      local dap = require("dap")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
