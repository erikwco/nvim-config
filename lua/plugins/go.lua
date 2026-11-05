-- Go: todo lo trae el extra `lang.go` de LazyVim (gopls con staticcheck+gofumpt,
-- goimports+gofumpt al guardar, golangci-lint, delve + nvim-dap-go, neotest-golang,
-- parsers de treesitter). Aquí solo lo que el extra no incluye.
-- templ está en plugins/go-templ.lua.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                shadow = true, -- variables que ocultan a otras del scope exterior
              },
            },
          },
        },
      },
    },
  },
}
