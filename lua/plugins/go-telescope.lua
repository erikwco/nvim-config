return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        -- Aquí puedes agregar patrones regex para ignorar siempre
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "dist/",
          "tmp/",
        },
      },
    },
  },
}
