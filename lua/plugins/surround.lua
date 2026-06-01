return {
  "kylechui/nvim-surround",
  version = "*", -- Usa la versión estable
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuración por defecto está bien
    })
  end,
}
