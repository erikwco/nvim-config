return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true, -- activa checks potentes
              gofumpt = true, -- estilo estricto
              analyses = {
                unusedparams = true,
                nilness = true,
                shadow = true,
                unusedwrite = true,
                fieldalignment = false, -- habilítalo si te interesa
              },
            },
          },
        },
      },
    },
  },
}
