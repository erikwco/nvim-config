-- Diagnósticos "loud": que los errores no se te pasen por alto.
-- Aplica a TODOS los LSPs (Roslyn, gopls, jdtls, rust-analyzer, vtsls, etc).

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- 1) Configurar vim.diagnostic globalmente
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

      return opts
    end,
  },

  -- 3) Auto-abrir diagnostic float al pasar 500ms sobre una línea con error
  --    + setear updatetime para que CursorHold dispare rápido
  --    + LSP hover/signature_help con border redondeado
  {
    "folke/snacks.nvim", -- ya está en tu setup; lo usamos como hook de "VeryLazy"
    opts = function()
      vim.opt.updatetime = 500 -- CursorHold cada 500ms (default es 4000)

      vim.api.nvim_create_autocmd("CursorHold", {
        group = vim.api.nvim_create_augroup("diag_float_on_hold", { clear = true }),
        callback = function()
          -- Solo abre si hay diagnósticos en la línea actual
          local line = vim.api.nvim_win_get_cursor(0)[1] - 1
          local diags = vim.diagnostic.get(0, { lnum = line })
          if #diags == 0 then
            return
          end
          -- No abrir si ya hay un float visible
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative ~= "" then
              return
            end
          end
          vim.diagnostic.open_float(nil, {
            focus = false,
            scope = "line",
            border = "rounded",
            source = "if_many",
          })
        end,
      })

      -- Hover y signature_help con border redondeado (Neovim 0.10+ usa vim.lsp.buf.hover())
      vim.lsp.handlers["textDocument/hover"] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", max_width = 100 })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", max_width = 100 })
    end,
  },

  -- 4) Highlights más contrastados para los squiggles (undercurl rojo brillante en errores)
  {
    "LazyVim/LazyVim",
    opts = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("diag_hl_loud", { clear = true }),
        callback = function()
          -- Undercurl (la "rayita" debajo del símbolo)
          -- Error: rojo brillante para que NO se pase por alto
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#FF5555" })
          -- Warn: naranja apagado (no rojo, no se confunde con error)
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#E5A05C" })
          -- Info: cyan suave
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#7AC5D8" })
          -- Hint: verde menta apagado
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#6FAE91" })

          -- Virtual text inline (el mensaje a la derecha de la línea)
          -- Error: rojo saturado, bold para que destaque
          vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#FF6E6E", bold = true, italic = true })
          -- Warn: naranja medio
          vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#D9A05B", italic = true })
          -- Info: cyan apagado, sin bold (informativo, no urgente)
          vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#7AC5D8", italic = true })
          -- Hint: gris-verde, casi se confunde con comentario (sugerencias del LSP)
          vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#6C7A89", italic = true })

          -- Signs en la columna (los iconos ●▲◆)
          vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#FF5555", bold = true })
          vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#E5A05C" })
          vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#7AC5D8" })
          vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#6FAE91" })

          -- Texto de los floats
          vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = "#FF6E6E", bold = true })
          vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = "#E5A05C" })
          vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = "#7AC5D8" })
          vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = "#6C7A89" })
        end,
      })
      -- Disparar también ahora (si el tema ya está cargado al arrancar)
      vim.cmd("doautocmd ColorScheme")
    end,
  },
}
