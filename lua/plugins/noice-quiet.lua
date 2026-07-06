-- Silenciar el spam de progreso LSP (sobre todo jdtls, que manda un token de
-- progreso por documento al indexar: "Publish Diagnostics", "Validate documents"...
-- que se apilaban de abajo hacia arriba llenando la pantalla).
--
-- Se desactiva SOLO el progreso LSP. Los diagnósticos, hovers, code actions,
-- mensajes de error y demás siguen igual. El estado del LSP se sigue viendo
-- en la statusline.

return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = {
          enabled = false, -- adiós al spam de "Publish Diagnostics jdtls" apilado
        },
      },
      -- Filtro extra: por si algún LSP manda estos como mensajes normales,
      -- los mandamos al historial (no como popup).
      routes = {
        {
          filter = {
            event = "lsp",
            kind = "progress",
          },
          opts = { skip = true },
        },
        {
          -- jdtls a veces manda "Validate documents" / "Publish Diagnostics"
          -- como notificaciones. Al historial, no como popup.
          filter = {
            event = "notify",
            find = "Validate documents",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "notify",
            find = "Publish Diagnostics",
          },
          opts = { skip = true },
        },
      },
    },
  },
}
