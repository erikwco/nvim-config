-- LazyVim ya gestiona `format_on_save` para conform.nvim automáticamente
-- (con su propia lógica de tamaño, autocmds, etc).
-- Aquí SOLO definimos los formatters por filetype.
-- NOTA: el nombre del archivo es histórico (originalmente era solo para Go);
-- ahora declara formatters para varios lenguajes que no están cubiertos por
-- los extras de LazyVim.

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" }, -- orden: ejecuta en cadena
      },
    },
  },
}
