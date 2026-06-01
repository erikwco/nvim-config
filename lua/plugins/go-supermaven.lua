return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    cmd = { "SupermavenUseFree", "SupermavenUsePro" },
    opts = {
      keymaps = {
        -- accept_suggestion = "<M-l>", -- evita conflictos con <Tab> de cmp/blink
        -- accept_word = "<M-w>",
        -- clear_suggestion = "<C-]>",
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      -- si usas cmp/blink como fuente, puedes apagar el inline:
      color = {
        suggestion_color = "#ffffff",
        cterm = 244,
      },
      disable_inline_completion = false,
      disable_keymaps = false,
      ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
      log_level = "info",
    },
  },
}

--  maven manual settings
--require("supermaven-nvim").setup({
--  keymaps = {
--    accept_suggestion = "<Tab>",
--    clear_suggestion = "<C-]>",
--    accept_word = "<C-j>",
--  },
--  ignore_filetypes = { cpp = true }, -- or { "cpp", }
--  color = {
--    suggestion_color = "#ffffff",
--    cterm = 244,
--  },
--  log_level = "info", -- set to "off" to disable logging completely
--  disable_inline_completion = false, -- disables inline completion for use with cmp
--  disable_keymaps = false, -- disables built in keymaps for more manual control
--  condition = function()
--    return false
--  end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
--})
