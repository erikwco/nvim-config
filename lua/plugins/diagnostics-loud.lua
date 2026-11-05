-- Diagnósticos "loud": que los errores no se te pasen por alto.
-- Aplica a TODOS los LSPs (Roslyn, gopls, jdtls, rust-analyzer, vtsls, etc).
--
-- Complementos en config/: `updatetime = 500` (options.lua) y los autocmds
-- `diag_float_on_hold` (float automático al reposar sobre un error) y
-- `diag_hl_loud` (colores/undercurl del tema) en autocmds.lua.

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- 1) vim.diagnostic.config global (LazyVim lo aplica desde opts.diagnostics)
      opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
        underline = true,
        update_in_insert = false, -- no spammear mientras escribes
        severity_sort = true,
        -- Virtual text: mensaje INLINE en la línea con el error
        virtual_text = {
          spacing = 2,
          source = "if_many", -- muestra fuente si hay varios LSPs
          prefix = "▎", -- barrita gruesa antes del mensaje
          format = function(diag)
            -- Incluye el código del error (CS1061, S1234, etc) en el mensaje
            local code = diag.code and (" [" .. tostring(diag.code) .. "]") or ""
            local msg = diag.message
            -- Trunca mensajes muy largos para que no rompan la línea
            if #msg > 120 then
              msg = msg:sub(1, 117) .. "..."
            end
            return msg .. code
          end,
        },
        -- Signs en la columna izquierda (gutter)
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
          },
        },
        -- Floats con border redondeado y formato rico
        float = {
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
          format = function(diag)
            local code = diag.code and (" [" .. tostring(diag.code) .. "]") or ""
            return diag.message .. code
          end,
        },
      })

      -- 2) Hover (K) con border redondeado.
      -- En Neovim 0.11+ vim.lsp.buf.hover() ya no pasa por vim.lsp.handlers ni
      -- acepta vim.lsp.with (eliminado en 0.13): las opciones van en la llamada.
      -- Se redefine el keymap K de LazyVim (buffer-local al attach del LSP).
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = {
        "K",
        function()
          return vim.lsp.buf.hover({ border = "rounded", max_width = 100 })
        end,
        desc = "Hover",
      }

      return opts
    end,
  },
}
