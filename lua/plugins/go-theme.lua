return {
  {
    "LazyVim/LazyVim",
    -- El colorscheme genérico respeta el fondo detectado por Neovim.
    -- La función por defecto de LazyVim fuerza Moon al arrancar en claro.
    opts = { colorscheme = "tokyonight" },
  },
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
    },
  },
}
