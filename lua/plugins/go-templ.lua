-- templ (github.com/a-h/templ): LSP, treesitter y formato.
-- Neovim ya detecta *.templ como filetype "templ" (vim.filetype), no hace falta registrarlo.
return {
  -- 1. LSP: templ + htmx, y gopls enterado de los .templ
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.templ = {
        filetypes = { "templ" },
      }
      -- Opcional: soporte para HTMX
      opts.servers.htmx = {
        filetypes = { "html", "templ" },
      }
      -- gopls necesita saber que debe mirar otros archivos aparte de .go
      opts.servers.gopls = opts.servers.gopls or {}
      opts.servers.gopls.settings = opts.servers.gopls.settings or {}
      opts.servers.gopls.settings.gopls = opts.servers.gopls.settings.gopls or {}
      opts.servers.gopls.settings.gopls.templateExtensions = { "templ" }
    end,
  },

  -- 2. Syntax highlighting (treesitter)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "templ" })
      end
    end,
  },

  -- 3. Formateo automático al guardar con `templ fmt`
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.templ = { "templ" }
    end,
  },
}
