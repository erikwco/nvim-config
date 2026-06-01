-- Soporte para archivos Gradle con Groovy DSL (build.gradle, settings.gradle).
--
-- CONTEXTO IMPORTANTE:
-- No existe un LSP "Gradle-aware" decente. Lo que de verdad te da asistencia
-- en proyectos Gradle es JDTLS (nvim-jdtls): al abrir el proyecto importa el
-- build de Gradle, resuelve dependencias y classpath, y te da LSP completo en
-- tu código .java. Eso YA funciona con tu config de jdtls-lombok.lua.
--
-- Lo único que falta es asistencia editando el build.gradle EN SÍ. Para eso:
--   1. Treesitter `groovy` → highlighting + folds + indent (ganancia clara) ✅
--   2. groovyls → autocompletion genérico de Groovy (valor limitado para el
--      DSL de Gradle, consume RAM). Opcional, comentado abajo.

return {
  -- 1) Treesitter: highlighting de Groovy (build.gradle, settings.gradle, *.groovy)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "groovy" })
    end,
  },

  -- 2) Asegurar que los archivos Gradle se detecten como filetype "groovy"
  --    (Neovim ya lo hace para build.gradle, pero reforzamos settings.gradle, etc.)
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.filetype.add({
        extension = { gradle = "groovy" },
        filename = {
          ["build.gradle"] = "groovy",
          ["settings.gradle"] = "groovy",
        },
        pattern = {
          [".*%.gradle"] = "groovy",
        },
      })
    end,
  },

  -- 3) (OPCIONAL) groovyls — Groovy Language Server.
  --    Descomenta TODO este bloque si quieres autocompletion en build.gradle.
  --    Advertencia: entiende Groovy genérico, NO el modelo de Gradle (tasks,
  --    plugin extensions como `application{}`, `shadowJar{}`, etc.). Consume
  --    ~200-400 MB de RAM. Para la mayoría no vale la pena vs solo treesitter.
  --
  -- {
  --   "mason-org/mason.nvim",
  --   opts = function(_, opts)
  --     opts.ensure_installed = opts.ensure_installed or {}
  --     vim.list_extend(opts.ensure_installed, { "groovy-language-server" })
  --   end,
  -- },
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     servers = {
  --       groovyls = {
  --         filetypes = { "groovy" },
  --         -- Evita que arranque en archivos enormes generados
  --         settings = {
  --           groovy = {
  --             classpath = {}, -- puedes añadir jars de Gradle si quieres más completion
  --           },
  --         },
  --       },
  --     },
  --   },
  -- },
}
