-- Rust: todo lo trae el extra `lang.rust` de LazyVim (rustaceanvim sin pin de
-- versión, crates.nvim, codelldb por Mason, rust_analyzer deshabilitado en
-- lspconfig, checkOnSave, neotest). Aquí solo los ajustes propios, que el extra
-- mezcla con `tbl_deep_extend("keep", vim.g.rustaceanvim, opts)`.
-- Atajos que añade el extra en buffers .rs: <leader>cR code action de RustLsp,
-- <leader>dr debuggables.
return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      tools = {
        float_win_config = { border = "rounded" },
        hover_actions = { replace_builtin_hover = true },
        executor = "termopen",
      },
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" }, -- clippy al guardar (checkOnSave lo activa el extra)
            completion = { postfix = { enable = true } },
          },
        },
      },
    },
  },
}
