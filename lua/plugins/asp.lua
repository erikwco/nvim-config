-- asp.nvim — soporte de Classic ASP (VBScript + HTML + JavaScript).
-- Instalado desde GitHub: https://github.com/erikwco/asp.nvim
-- `build = "make parsers"` sólo necesita un compilador C (el parser.c
-- viene versionado en el repo). Para el resaltado de las regiones HTML y
-- del JS de cliente hacen falta los parsers html/javascript/css de
-- nvim-treesitter (:TSInstall html javascript css).
return {
  {
    "erikwco/asp.nvim",
    build = "make parsers",
    ft = "asp", -- carga perezosa al abrir un .asp/.inc
    opts = {}, -- require('asp').setup({}); aquí podrías fijar virtual_root
  },
}

-- ¿Querés seguir hackeando el plugin localmente? Volvé a la forma con
-- `dir` para que los cambios se reflejen sin push:
--   {
--     dir = "/Users/erik/Developments/idear/projects/ai/asp-neovim",
--     name = "asp.nvim",
--     build = "make parsers",
--     ft = "asp",
--     opts = {},
--   },
