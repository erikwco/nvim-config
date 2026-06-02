-- ============================================================================
-- Neovim minimal config — SERVER (edición de archivos)
-- ============================================================================
-- Autocontenido. NO usa LazyVim, NO Mason, NO LSP, NO toolchains.
-- Solo: telescope (fuzzy find) + neo-tree (árbol) + treesitter (highlight) +
-- catppuccin (tema) + QoL básico. Arranque <1s.
--
-- INSTALAR EN EL SERVER (una línea, desde este repo):
--   mkdir -p ~/.config/nvim
--   curl -fLo ~/.config/nvim/init.lua \
--     https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/server/init.lua
--   nvim   # lazy.nvim se bootstrappea e instala los plugins
--
-- Requisitos en el server:
--   neovim 0.10+ (tarball oficial), git, ripgrep (rg), build-essential (treesitter)
--   ripgrep = <leader>fg (grep). fd opcional (find más rápido).
--   Ver server/README.md para la guía completa.
-- ============================================================================

-- ── Leader (Space, igual que tu Mac) ───────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Opciones ────────────────────────────────────────────────────────────────
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.undofile = true -- historial de undo persistente
opt.clipboard = "unnamedplus"
opt.splitright = true
opt.splitbelow = true
opt.cursorline = true
opt.cpoptions:append("I") -- preserva indentación de líneas vacías (como tu Mac)

-- ── Clipboard sobre SSH (OSC52) ──────────────────────────────────────────────
-- Hace que al hacer yank en el server, el texto llegue al portapapeles de tu Mac
-- (Ghostty soporta OSC52). Solo se activa si estás en sesión SSH.
if os.getenv("SSH_TTY") then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

-- ── Bootstrap lazy.nvim ──────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ──────────────────────────────────────────────────────────────────
require("lazy").setup({
  -- Tema (igual que tu Mac)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Árbol de archivos (neo-tree, como en tu Mac)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer (toggle)" },
      { "<leader>o", "<cmd>Neotree focus<cr>", desc = "Explorer (focus)" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_current",
        filtered_items = {
          hide_dotfiles = false, -- en server quieres ver dotfiles (.bashrc, etc.)
          hide_gitignored = false,
        },
      },
      window = {
        width = 32,
        mappings = {
          ["<space>"] = "none", -- libera Space para el leader
        },
      },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep (texto)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recientes" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buscar en buffer" },
    },
    opts = {
      defaults = {
        file_ignore_patterns = { "node_modules", "%.git/" },
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
      },
    },
  },

  -- Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "lua",
          "vim",
          "vimdoc",
          "json",
          "jsonc",
          "yaml",
          "toml",
          "ini",
          "markdown",
          "markdown_inline",
          "html",
          "css",
          "javascript",
          "dockerfile",
          "gitignore",
          "diff",
          "ssh_config",
          "nginx",
        },
        auto_install = true, -- instala el parser que falte al abrir un archivo
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- QoL
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "lewis6991/gitsigns.nvim", event = "VeryLazy", opts = {} },
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = { options = { theme = "catppuccin", globalstatus = true } },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
}, {
  -- Config de lazy: sin checks de update molestos en un server
  checker = { enabled = false },
  change_detection = { notify = false },
})

-- ── Keymaps básicos ──────────────────────────────────────────────────────────
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Guardar" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Cerrar ventana" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Salir de todo" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Quitar resaltado búsqueda" })

-- Navegación entre splits (Ctrl + h/j/k/l)
map("n", "<C-h>", "<C-w>h", { desc = "Split izquierda" })
map("n", "<C-j>", "<C-w>j", { desc = "Split abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Split arriba" })
map("n", "<C-l>", "<C-w>l", { desc = "Split derecha" })

-- Mover líneas con Alt+j/k
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Mover línea abajo" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Mover línea arriba" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Mover selección abajo" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Mover selección arriba" })

-- Guardar indentación al pegar en visual
map("x", "p", [["_dP]], { desc = "Pegar sin pisar el registro" })
