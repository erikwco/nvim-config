-- Configuración extra para kulala.nvim (REST client).
-- El extra `lazyvim.plugins.extras.util.rest` ya instala el plugin y los
-- atajos <leader>R*. Aquí ajustamos dos cosas:
--   1. Treesitter parser `kulala_http` (requerido por versiones recientes)
--   2. Desactivar el formatter del LSP interno de kulala — al guardar reescribía
--      el archivo añadiendo `###` automáticos, lo cual rompe el scope de las
--      variables `@var = ...` declaradas al inicio.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "kulala_http" })
    end,
  },

  {
    "mistweaverco/kulala.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.lsp = opts.lsp or {}
      -- false desactiva el formatter del LSP interno; el LSP sigue activo
      -- para completion, hover, definition, etc.
      opts.lsp.formatter = false
      -- También se podría desactivar todo el LSP con: opts.lsp.enable = false
      -- pero perderías completion de headers, variables, etc. Mejor solo el formatter.
      return opts
    end,
  },
}
