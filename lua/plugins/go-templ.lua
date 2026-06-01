return {
  -- 1. Reconocimiento de tipo de archivo
  -- Le decimos a Neovim que los archivos .templ son de tipo "templ"
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Añadir templ a la lista de servidores
      opts.servers = opts.servers or {}
      opts.servers.templ = {
        filetypes = { "templ" },
      }
      -- Opcional: Soporte para HTMX
      opts.servers.htmx = {
        filetypes = { "html", "templ" },
      }

      -- Configuración importante para gopls
      -- gopls necesita saber que debe mirar otros archivos aparte de .go
      opts.servers.gopls = opts.servers.gopls or {}
      opts.servers.gopls.settings = opts.servers.gopls.settings or {}
      opts.servers.gopls.settings.gopls = opts.servers.gopls.settings.gopls or {}
      opts.servers.gopls.settings.gopls.templateExtensions = { "templ" }
    end,
  },

  -- 2. Syntax Highlighting (Treesitter)
  -- Esto arregla que el código se vea plano (sin colores)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Aseguramos que el parser de templ se instale
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "templ" })
      end

      -- Registramos templ para que use el parser correcto
      vim.treesitter.language.register("templ", "templ")
    end,
  },

  -- 3. Registro manual del filetype (Doble seguridad)
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add({
        extension = {
          templ = "templ",
        },
      })
    end,
  },

  -- 4. Formateo automático al guardar
  -- Templ necesita formatearse con `templ fmt`
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.templ = { "templ" }
    end,
  },
}

-- lua/plugins/go-templ.lua
-- return {
--   -- Treesitter + parser templ + ftdetect + autogen
--   {
--     "nvim-treesitter/nvim-treesitter",
--     build = ":TSUpdate",
--
--     -- init corre temprano: perfecto para filetype
--     init = function()
--       -- Reconocer *.templ como filetype "templ"
--       vim.filetype.add({ extension = { templ = "templ" } })
--       -- Regenerar .go al guardar .templ (puedes quitarlo si usas `templ generate --watch`)
--       vim.api.nvim_create_autocmd("BufWritePost", {
--         pattern = "*.templ",
--         callback = function()
--           vim.fn.jobstart({ "templ", "generate" }, { cwd = vim.fn.getcwd() })
--         end,
--       })
--     end,
--
--     -- config: registrar parser y configurar TS
--     config = function(_, _)
--       local ok_cfg, ts_configs = pcall(require, "nvim-treesitter.configs")
--       if not ok_cfg then
--         return
--       end
--
--       -- Registrar parser externo si la API existe
--       local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
--       if ok_parsers and parsers.get_parser_configs then
--         local parser_config = parsers.get_parser_configs()
--         parser_config.templ = {
--           install_info = {
--             url = "https://github.com/vrischmann/tree-sitter-templ",
--             files = { "src/parser.c", "src/scanner.c" },
--             branch = "main",
--           },
--           filetype = "templ",
--         }
--       end
--
--       -- Merge con tus opts existentes (si usas LazyVim)
--       local ensure = { "go", "templ", "lua", "html", "css", "bash", "json" }
--       local ok_opts, lazy_opts = pcall(function()
--         return require("lazy.core.plugin").values(require("lazy.core.config").plugins["nvim-treesitter"], "opts")
--       end)
--       local base = (ok_opts and lazy_opts) or {}
--       base.ensure_installed = base.ensure_installed or {}
--       for _, lang in ipairs(ensure) do
--         if not vim.tbl_contains(base.ensure_installed, lang) then
--           table.insert(base.ensure_installed, lang)
--         end
--       end
--       base.highlight = base.highlight or { enable = true }
--
--       ts_configs.setup(base)
--     end,
--   },
--
--   -- Mason: instala gopls y templ LSP
--   {
--     "manson-org/mason.nvim",
--     opts = function(_, opts)
--       opts = opts or {}
--       opts.ensure_installed = opts.ensure_installed or {}
--       for _, pkg in ipairs({ "gopls", "templ" }) do
--         if not vim.tbl_contains(opts.ensure_installed, pkg) then
--           table.insert(opts.ensure_installed, pkg)
--         end
--       end
--       return opts
--     end,
--   },
--
--   -- LSP: gopls + templ
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       servers = {
--         gopls = {
--           settings = {
--             gopls = {
--               gofumpt = true,
--               staticcheck = true,
--               analyses = { unusedparams = true },
--             },
--           },
--         },
--         templ = {},
--       },
--     },
--   },
--
--   -- Formateo: templ fmt (.templ) y gofumpt+goimports (Go)
--   {
--     "stevearc/conform.nvim",
--     opts = {
--       formatters_by_ft = {
--         templ = { "templ" },
--         go = { "gofumpt", "goimports" },
--       },
--     },
--   },
-- }
