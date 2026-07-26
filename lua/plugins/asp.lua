-- asp.nvim — soporte de Classic ASP (instalación local, sin GitHub).
-- `dir` apunta a la carpeta del repo; lazy.nvim no clona nada.
return {
  {
    dir = "/Users/erik/Developments/idear/projects/ai/asp-neovim",
    name = "asp.nvim",
    build = "make parsers", -- compila aspclassic + vbscript (necesita tree-sitter CLI + node)
    ft = "asp", -- carga perezosa al abrir un .asp/.inc
    opts = {}, -- llama a require('asp').setup({}); aquí podrías fijar virtual_root
  },
}
