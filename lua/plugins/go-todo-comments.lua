-- todo-comments: LazyVim ya lo trae con sus atajos (]t / [t, <leader>st / sT con
-- snacks, <leader>xt / xT con Trouble). Aquí solo personalizamos iconos y colores.
return {
  "folke/todo-comments.nvim",
  opts = {
    signs = true, -- muestra íconos en el gutter
    keywords = {
      FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
      PERF = { icon = " ", color = "hint", alt = { "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    },
    colors = {
      error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
      warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
      info = { "DiagnosticInfo", "#2563EB" },
      hint = { "DiagnosticHint", "#10B981" },
      default = { "Identifier", "#7C3AED" },
    },
  },
}
