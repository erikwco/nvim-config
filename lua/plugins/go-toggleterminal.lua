return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = function()
      return {
        -- tamaño según dirección
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.4)
          end
        end,
        open_mapping = [[<C-`>]], -- cambia si tu terminal no envía <C-`>
        start_in_insert = true,
        insert_mappings = false,
        terminal_mappings = true,
        persist_size = true,
        direction = "float", -- "horizontal" | "vertical" | "float"
        shade_terminals = true,
        hide_numbers = true,
        shell = vim.o.shell, -- usa tu shell (zsh en tu caso)
        float_opts = { border = "rounded", winblend = 0 },
      }
    end,
    keys = {
      -- toggles rápidos numerados
      { "<leader>1", "<cmd>1ToggleTerm dir=git_dir<cr>", desc = "Terminal 1 (repo root)" },
      { "<leader>2", "<cmd>2ToggleTerm dir=git_dir<cr>", desc = "Terminal 2 (repo root)" },
      { "<leader>3", "<cmd>3ToggleTerm dir=git_dir<cr>", desc = "Terminal 3 (repo root)" },
      -- enviar selección/línea al terminal #1 (útil para REPLs)
      { "<leader>sl", "<cmd>ToggleTermSendCurrentLine 1<cr>", mode = "n", desc = "Send Line -> Term1" },
      { "<leader>sv", "<cmd>ToggleTermSendVisualSelection 1<cr>", mode = "v", desc = "Send Visual -> Term1" },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      -- Keymaps cómodos en modo terminal
      local function set_terminal_keymaps()
        local o = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], o)
        vim.keymap.set("t", "jk", [[<C-\><C-n>]], o)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], o)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], o)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], o)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], o)
      end
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*toggleterm#*",
        callback = set_terminal_keymaps,
      })
    end,
  },
}
