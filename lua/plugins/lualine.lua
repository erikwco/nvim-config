-- ============================================================================
-- lualine: mostrar el encoding (charset) y el fin de línea en la barra
-- ============================================================================
-- LazyVim no muestra el encoding ni el fileformat por defecto. Los agregamos a
-- la sección derecha (lualine_x). El encoding se resalta en ROJO cuando NO es
-- utf-8, para detectar archivos legacy (cp1252/latin1) de un vistazo.
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.sections = opts.sections or {}
    opts.sections.lualine_x = opts.sections.lualine_x or {}

    -- encoding del archivo: utf-8, latin1, cp1252…
    table.insert(opts.sections.lualine_x, {
      "encoding",
      color = function()
        local enc = (vim.bo.fileencoding ~= "" and vim.bo.fileencoding) or vim.o.encoding
        if enc ~= "utf-8" then
          local fg = vim.api.nvim_get_hl(0, { name = "DiagnosticError", link = false }).fg
          return { fg = fg and string.format("#%06x", fg), gui = "bold" }
        end
      end,
    })

    -- fin de línea: unix / dos / mac (con icono)
    table.insert(opts.sections.lualine_x, { "fileformat" })
  end,
}
