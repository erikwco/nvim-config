-- Override de la extra `lazyvim.plugins.extras.lang.sql` (vim-dadbod-ui).
--
-- Cambios respecto al default:
--   1. La extra usa <leader>D para "Toggle DBUI", pero ese atajo ya es nuestro
--      terminal lateral. Lo movemos a <leader>Q (Q = Query).
--   2. Desactivamos nvim-notify (no lo tienes instalado; Snacks intercepta vim.notify).
--   3. Pre-configuramos conexiones via vim.g.dbs (puedes sobreescribirlas en cada
--      proyecto con un `.lazy.lua` local, ver ejemplo abajo).

-- ============================================================================
-- 🔌 CONEXIONES
-- ============================================================================
-- Tres formas, de menos a más segura:
--
-- A) Hardcodeadas aquí (NO recomendado para passwords reales):
--      vim.g.dbs = {
--        postgres_local = "postgres://erik:erik@localhost:5432/mydb",
--      }
--
-- B) Desde variables de entorno (mejor):
--      vim.g.dbs = {
--        pg_dev  = os.getenv("PG_DEV_URL"),
--        pg_prod = os.getenv("PG_PROD_URL"),
--      }
--    Y en ~/.zshrc: export PG_DEV_URL="postgres://user:pass@host:5432/db"
--
-- C) Por proyecto, en un `.lazy.lua` (gitignored) en la raíz del repo:
--      vim.g.dbs = { proyecto_x = "postgres://..." }
--      return {}
--    Más detalles: https://www.lazyvim.org/configuration/lazy.nvim
--
-- También puedes añadir conexiones desde la UI (`<leader>Q` → `A` o
-- `:DBUIAddConnection`); se guardan en ~/.local/share/nvim/dadbod_ui/.

vim.g.dbs = vim.g.dbs or {
  -- Descomenta y ajusta a tus conexiones reales:
  -- pg_local = "postgres://" .. os.getenv("USER") .. "@localhost:5432/postgres",
  -- pg_dev   = os.getenv("PG_DEV_URL")  or "",
  -- ora_qa   = os.getenv("ORA_QA_URL")  or "", -- (cuando configures Oracle)
}

return {
  -- Override de keymap: <leader>D ya es terminal lateral, movemos DBUI a <leader>Q.
  {
    "kristijanhusak/vim-dadbod-ui",
    keys = function(_, keys)
      -- Filtra los keymaps del default que choquen con <leader>D
      local filtered = {}
      for _, k in ipairs(keys or {}) do
        if k[1] ~= "<leader>D" then
          table.insert(filtered, k)
        end
      end
      -- Añade nuestros propios atajos bajo <leader>Q*
      vim.list_extend(filtered, {
        { "<leader>Q", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI (Query)" },
        { "<leader>Qa", "<cmd>DBUIAddConnection<CR>", desc = "DBUI: Add connection" },
        { "<leader>Qf", "<cmd>DBUIFindBuffer<CR>", desc = "DBUI: Find buffer" },
        { "<leader>Qr", "<cmd>DBUIRenameBuffer<CR>", desc = "DBUI: Rename buffer" },
        { "<leader>Ql", "<cmd>DBUILastQueryInfo<CR>", desc = "DBUI: Last query info" },
      })
      return filtered
    end,
    init = function()
      local data_path = vim.fn.stdpath("data")

      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
      vim.g.db_ui_use_nerd_fonts = true
      -- Snacks intercepta vim.notify; nvim-notify NO está instalado.
      vim.g.db_ui_use_nvim_notify = false
      -- No ejecutar queries automáticamente al guardar (default sano)
      vim.g.db_ui_execute_on_save = false
      -- Mostrar el cliente DB al inicio del nombre del archivo de query
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 35
      -- Forzar uso de psql con argumentos legibles
      vim.g.db_ui_force_echo_notifications = true
    end,
  },
}
