-- nvim-ufo: fold mejorado con info del LSP + persistencia confiable.
--
-- Mantenemos TODOS los atajos nativos de fold de Vim sin tocar:
--   zc / zo / za  → cerrar / abrir / toggle fold bajo cursor (NATIVOS)
--   zC / zO       → cerrar / abrir recursivamente (NATIVOS)
--   zj / zk       → saltar al siguiente / anterior fold (NATIVOS)
--   zM / zR       → cerrar / abrir TODOS (UFO los acelera, pero comportamiento igual)
--
-- Bonus opcional:
--   zK            → peek del contenido del fold sin abrirlo (NUEVO)

return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    init = function()
      -- UFO necesita estas opciones globales
      vim.o.foldcolumn = "1" -- columna estrecha mostrando triángulos de fold
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    opts = {
      -- Config del preview window (zK).
      -- Por defecto UFO linkea su Normal al Normal global del editor, así que
      -- el preview queda con el mismo color exacto y se ve "pegado" al fondo.
      -- Usar el fondo de Pmenu lo distingue del editor en claro y oscuro.
      preview = {
        win_config = {
          border = "rounded",
          winblend = 0, -- 0 = sin transparencia/blend
          winhighlight = "Normal:UfoPreviewNormal,FloatBorder:UfoPreviewBorder,CursorLine:UfoPreviewCursorLine",
        },
        mappings = {
          scrollB = "<C-b>",
          scrollF = "<C-f>",
          scrollU = "<C-u>",
          scrollD = "<C-d>",
          jumpTop = "[",
          jumpBot = "]",
        },
      },
      -- Proveedores de fold por filetype.
      -- UFO acepta máximo 2: { main, fallback }.
      -- Para filetypes con LSP: "lsp" como main, "indent" como fallback
      --   (mientras el LSP carga, usa indent; cuando esté listo, usa rangos del LSP).
      -- Para el resto: "treesitter" como main, "indent" como fallback.
      provider_selector = function(_, filetype, _)
        local lsp_filetypes = {
          "cs",
          "java",
          "go",
          "rust",
          "typescript",
          "typescriptreact",
          "javascript",
          "javascriptreact",
          "python",
          "lua",
        }
        if vim.tbl_contains(lsp_filetypes, filetype) then
          return { "lsp", "indent" }
        end
        return { "treesitter", "indent" }
      end,
      -- Texto bonito para folds cerrados: "{ }  ↙ 12 lines"
      fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
        local new_virt_text = {}
        local suffix = ("  󰁂 %d "):format(end_lnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virt_text) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(new_virt_text, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(new_virt_text, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(new_virt_text, { suffix, "MoreMsg" })
        return new_virt_text
      end,
    },
    config = function(_, opts)
      require("ufo").setup(opts)

      -- Usar los colores del tema activo también en el preview de zK.
      local function apply_ufo_hl()
        for name, source in pairs({
          UfoPreviewNormal = "Pmenu",
          UfoPreviewBorder = "FloatBorder",
          UfoPreviewCursorLine = "CursorLine",
          UfoPreviewWinBar = "Pmenu",
          UfoPreviewSbar = "PmenuSbar",
          UfoPreviewThumb = "PmenuThumb",
        }) do
          vim.api.nvim_set_hl(0, name, { link = source })
        end
      end
      apply_ufo_hl()
      -- Re-aplicar si cambias colorscheme
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("ufo_hl", { clear = true }),
        callback = apply_ufo_hl,
      })

      -- Versiones aceleradas de zM/zR (mismo comportamiento que las nativas,
      -- pero MUCHO más rápidas en archivos grandes con muchos folds).
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds (UFO)" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds (UFO)" })

      -- Bonus: zK hace "peek" del contenido del fold sin abrirlo.
      -- Si no hay fold bajo el cursor, hace fallback a vim.lsp.buf.hover().
      vim.keymap.set("n", "zK", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = "Peek fold (or LSP hover)" })
    end,
  },
}
