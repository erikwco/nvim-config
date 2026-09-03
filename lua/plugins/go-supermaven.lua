-- Supermaven: ghost text. Por defecto PARADO para no pelear con Copilot NES.
-- Sigue instalado: <leader>uS lo enciende (y apaga NES). <leader>ue cambia de motor.
-- <Tab> lo resuelve blink (snippet → NES → ghost de Supermaven si está activo).

return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = true,
    cmd = {
      "SupermavenStart",
      "SupermavenStop",
      "SupermavenToggle",
      "SupermavenUseFree",
      "SupermavenUsePro",
      "SupermavenStatus",
    },
    opts = {
      keymaps = {
        -- nil: no robar <Tab>; lo acepta blink via LazyVim.cmp.actions.ai_accept
        accept_suggestion = nil,
        accept_word = nil,
        clear_suggestion = nil,
      },
      disable_keymaps = true,
      disable_inline_completion = false,
      ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
      color = {
        suggestion_color = "#ffffff",
        cterm = 244,
      },
      log_level = "info",
    },
    config = function(_, opts)
      require("supermaven-nvim").setup(opts)
      require("supermaven-nvim.completion_preview").suggestion_group = "SupermavenSuggestion"
      -- setup() arranca el binario; lo paramos salvo que el usuario ya haya
      -- elegido supermaven con <leader>uS / <leader>ue.
      if vim.g.ai_engine ~= "supermaven" then
        require("supermaven-nvim.api").stop()
      end
    end,
  },

  {
    "folke/noice.nvim",
    optional = true,
    opts = function(_, opts)
      opts.routes = opts.routes or {}
      vim.list_extend(opts.routes, {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "Starting Supermaven" },
              { find = "Stopping Supermaven" },
              { find = "Supermaven is not running" },
              { find = "Supermaven Free Tier" },
            },
          },
          opts = { skip = true },
        },
      })
    end,
  },
}
