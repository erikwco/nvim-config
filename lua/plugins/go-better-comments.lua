return {
  {
    "folke/paint.nvim",
    event = "LazyFile",
    config = function()
      -- Filetypes reales (antes decía js/ts/tsx, que no existen → nunca aplicaba en JS/TS)
      local code_filetypes = {
        "go", "java", "cs", "rust", "dart",
        "javascript", "javascriptreact", "typescript", "typescriptreact",
      }
      local function apply_highlights()
        for name, source in pairs({
          PaintBlue = "Function",
          PaintRed = "DiagnosticError",
          PaintGreen = "String",
          PaintYellow = "DiagnosticWarn",
          PaintMagenta = "Statement",
        }) do
          local color = vim.api.nvim_get_hl(0, { name = source, link = false }).fg
          vim.api.nvim_set_hl(0, name, { fg = color })
        end
      end
      apply_highlights()

      -- 2) inicia paint con prioridad alta y reemplazo de fg (no combine)
      require("paint").setup({
        -- si tu versión no soporta `priority`, lo ignora sin romper
        priority = 1000,
        highlights = {
          -- Go / JS / TS / Java / C#
          {
            filter = { filetype = code_filetypes },
            pattern = "^%s*//%*.*",
            hl = "PaintBlue",
            hl_mode = "replace",
          },
          {
            filter = { filetype = code_filetypes },
            pattern = "^%s*//%?.*",
            hl = "PaintRed",
            hl_mode = "replace",
          },
          {
            filter = { filetype = code_filetypes },
            pattern = "^%s*//%+.*",
            hl = "PaintGreen",
            hl_mode = "replace",
          },
          {
            filter = { filetype = code_filetypes },
            pattern = "^%s*//%-.*",
            hl = "PaintYellow",
            hl_mode = "replace",
          },
          {
            filter = { filetype = code_filetypes },
            pattern = "^%s*//!.*",
            hl = "PaintMagenta",
            hl_mode = "replace",
          },

          -- Lua (comentarios con --)
          { filter = { filetype = "lua" }, pattern = "^%s*%-%-%*.*", hl = "PaintBlue", hl_mode = "replace" },
          { filter = { filetype = "lua" }, pattern = "^%s*%-%-%?.*", hl = "PaintRed", hl_mode = "replace" },
          { filter = { filetype = "lua" }, pattern = "^%s*%-%-%+.*", hl = "PaintGreen", hl_mode = "replace" },
          { filter = { filetype = "lua" }, pattern = "^%s*%-%-%-.*", hl = "PaintYellow", hl_mode = "replace" },
        },
      })

      -- 3) si cambias de colorscheme, re-aplica colores
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("paint_theme", { clear = true }),
        callback = apply_highlights,
      })
    end,
  },
}
