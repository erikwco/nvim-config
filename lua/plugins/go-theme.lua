return {
  {
    "LazyVim/LazyVim",
    -- El colorscheme genérico respeta el fondo detectado por Neovim.
    -- La función por defecto de LazyVim fuerza Moon al arrancar en claro.
    opts = { colorscheme = "tokyonight" },
  },
  {
    -- LazyVim ya instala catppuccin (lazy); solo fijamos el flavour por si lo
    -- activas con <leader>uC. Sin lazy=false/priority: no carga al arranque.
    "catppuccin/nvim",
    name = "catppuccin",
    opts = { flavour = "mocha" },
  },
}
