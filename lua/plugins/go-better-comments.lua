return {
  {
    "folke/paint.nvim",
    event = "BufReadPost", -- carga con buffer real
    config = function()
      -- 1) define los grupos DESPUÉS del tema
      local set = vim.api.nvim_set_hl
      set(0, "PaintBlue", { fg = "#61afef" })
      set(0, "PaintRed", { fg = "#e86671" })
      set(0, "PaintGreen", { fg = "#98c379" })
      set(0, "PaintYellow", { fg = "#e5c07b" })
      set(0, "PaintMagenta", { fg = "#c678dd" })

      -- 2) inicia paint con prioridad alta y reemplazo de fg (no combine)
      require("paint").setup({
        -- si tu versión no soporta `priority`, lo ignora sin romper
        priority = 1000,
        highlights = {
          -- Go / JS / TS / Java / C#
          {
            filter = { filetype = { "go", "js", "ts", "tsx", "java", "cs" } },
            pattern = "^%s*//%*.*",
            hl = "PaintBlue",
            hl_mode = "replace",
          },
          {
            filter = { filetype = { "go", "js", "ts", "tsx", "java", "cs" } },
            pattern = "^%s*//%?.*",
            hl = "PaintRed",
            hl_mode = "replace",
          },
          {
            filter = { filetype = { "go", "js", "ts", "tsx", "java", "cs" } },
            pattern = "^%s*//%+.*",
            hl = "PaintGreen",
            hl_mode = "replace",
          },
          {
            filter = { filetype = { "go", "js", "ts", "tsx", "java", "cs" } },
            pattern = "^%s*//%-.*",
            hl = "PaintYellow",
            hl_mode = "replace",
          },
          {
            filter = { filetype = { "go", "js", "ts", "tsx", "java", "cs" } },
            pattern = "^%s*//!.*",
            hl = "PaintMagenta",
            hl_mode = "replace",
          },

          -- Lua (comentarios con --)
          { filter = { filetype = "lua" }, pattern = "^%s*%-%-%*.*", hl = "PaintBlue", hl_mode = "replace" },
          { filter = { filetype = "lua" }, pattern = "^%s*%-%-%?.*", hl = "PaintRed", hl_mode = "replace" },
          { filter = { filetype = "lua" }, pattern = "^%s*%-%-%+.*", hl = "PaintGreen", hl_mode = "replace" },
          { filter = { filetype = "lua" }, pattern = "^%s*%-%%-.*", hl = "PaintYellow", hl_mode = "replace" },
        },
      })

      -- 3) si cambias de colorscheme, re-aplica colores
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          set(0, "PaintBlue", { fg = "#61afef" })
          set(0, "PaintRed", { fg = "#e86671" })
          set(0, "PaintGreen", { fg = "#98c379" })
          set(0, "PaintYellow", { fg = "#e5c07b" })
          set(0, "PaintMagenta", { fg = "#c678dd" })
        end,
      })
    end,
  },
}
