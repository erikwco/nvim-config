-- Silenciar el spam de progreso LSP (sobre todo jdtls, que manda un token de
-- progreso por documento al indexar: "Publish Diagnostics", "Validate documents"...
-- que se apilaban de abajo hacia arriba llenando la pantalla).
--
-- Se desactiva SOLO el progreso LSP. Los diagnósticos, hovers, code actions,
-- mensajes de error y demás siguen igual. El estado del LSP se sigue viendo
-- en la statusline.
--
-- El popup flotante de `:` (command_palette) se dejó como en LazyVim.
-- Si nui volviera a crashear, esos errores se filtran para no inundar.

return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.lsp = vim.tbl_deep_extend("force", opts.lsp or {}, {
        progress = { enabled = false },
      })

      opts.routes = opts.routes or {}
      vim.list_extend(opts.routes, {
        {
          filter = {
            event = "lsp",
            kind = "progress",
          },
          opts = { skip = true },
        },
        {
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
        {
          filter = { find = "is_window_valid" },
          opts = { skip = true },
        },
        {
          filter = { find = "nui/popup/border.lua" },
          opts = { skip = true },
        },
      })
      return opts
    end,
  },

  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      local prev = opts.notifier and opts.notifier.filter
      opts.notifier = opts.notifier or {}
      opts.notifier.filter = function(notif)
        local msg = notif.msg or ""
        if msg:find("is_window_valid", 1, true) or msg:find("nui/popup/border.lua", 1, true) then
          return false
        end
        if prev then
          return prev(notif)
        end
        return true
      end
    end,
  },
}
