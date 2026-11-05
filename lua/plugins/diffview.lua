-- diffview+ (fork mantenido de sindrets/diffview.nvim)
-- https://github.com/dlyongemallo/diffview-plus.nvim
--
-- Diff de working tree / index / revs en un solo tabpage, historial de archivo,
-- merge tool 3/4-way, staging de hunks/archivos. Compatible con gitsigns
-- (LazyVim ya lo trae: el panel se refresca al stage/unstage).
--
-- Keymaps bajo <leader>gv* para NO chocar con:
--   <leader>d*  → DAP / debug (extra dap.core)
--   <leader>gh* → gitsigns hunks (LazyVim)
--   <leader>gs / gd / gg / gb / gl → Snacks git (LazyVim)
-- El toggle es <leader>gvv (no <leader>gv) para que la tecla no sea atajo y
-- prefijo a la vez.
--
-- Comandos útiles (también con :):
--   :DiffviewOpen                  working tree vs index
--   :DiffviewOpen origin/main...HEAD   review estilo PR
--   :DiffviewFileHistory %         historial del buffer
--   :DiffviewClose  /  g? en un buffer de diffview para ver maps internos

return {
  {
    "dlyongemallo/diffview-plus.nvim",
    version = "*",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggle",
      "DiffviewFileHistory",
      "DiffviewDiffFiles",
      "DiffviewMergeFiles",
      "DiffviewDiffDirs",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewLog",
    },
    -- Lazy-load también al primer atajo (sin esperar a un :cmd).
    keys = {
      {
        "<leader>gvv",
        "<cmd>DiffviewToggle<cr>",
        desc = "Diffview: toggle",
      },
      {
        "<leader>gvo",
        "<cmd>DiffviewOpen<cr>",
        desc = "Diffview: open (working tree)",
      },
      {
        "<leader>gvc",
        "<cmd>DiffviewClose<cr>",
        desc = "Diffview: close",
      },
      {
        "<leader>gvh",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "Diffview: history (file)",
      },
      {
        "<leader>gvH",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Diffview: history (repo)",
      },
      {
        "<leader>gvl",
        "<cmd>.DiffviewFileHistory --follow<cr>",
        desc = "Diffview: history (line)",
      },
      {
        "<leader>gvh",
        "<Esc><cmd>'<,'>DiffviewFileHistory --follow<cr>",
        mode = "v",
        desc = "Diffview: history (selection)",
      },
      {
        -- Diff vs main/master (útil antes de merge / review local)
        "<leader>gvm",
        function()
          local ok = vim.fn.systemlist({ "git", "rev-parse", "--verify", "main" })
          local branch = (vim.v.shell_error == 0 and ok[1] and ok[1] ~= "") and "main" or "master"
          vim.cmd("DiffviewOpen " .. branch)
        end,
        desc = "Diffview: vs main/master",
      },
      {
        -- Symmetric range típico de PR: solo lo que introduce la rama actual
        "<leader>gvp",
        function()
          local main = vim.fn.systemlist({ "git", "rev-parse", "--verify", "origin/main" })
          local base = (vim.v.shell_error == 0 and main[1] and main[1] ~= "") and "origin/main" or "origin/master"
          vim.cmd("DiffviewOpen " .. base .. "...HEAD")
        end,
        desc = "Diffview: PR vs origin/main",
      },
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true, -- nvim-web-devicons / mini.icons (LazyVim ya trae uno)
      show_help_hints = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true, -- menos ruido al resolver conflictos
          winbar_info = true,
        },
        file_history = { layout = "diff2_horizontal" },
      },
      file_panel = {
        listing_style = "tree",
        win_config = { position = "left", width = 35 },
      },
      -- Marcar archivos ya revisados en un PR y persistir entre reinicios.
      persist_selections = { enabled = true },
      hooks = {
        diff_buf_read = function()
          vim.opt_local.wrap = false
          vim.opt_local.list = false
        end,
      },
    },
  },
}
