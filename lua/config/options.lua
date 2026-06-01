-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Mantener el fondo sólido del colorscheme (catppuccin-mocha: #1e1e2e).
-- Antes había un autocmd que ponía `Normal guibg=NONE` para hacer transparente
-- el editor y que se mezclara con el terminal, pero eso causaba que:
--   * El editor se viera del color del terminal (gris en tu caso)
--   * Los floats de UFO peek (zK) usaran ese Normal transparente → ilegibles
-- Quitándolo, vuelve el dark blue de catppuccin a todo: editor, sidebar, floats.
--
-- Si en algún momento quieres recuperar transparencia (raro), descomenta esta línea:
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none", ctermbg = "none" })

-- =======================================================================================
-- Folds (plegado de código)
-- =======================================================================================
-- LazyVim por defecto usa treesitter para detectar folds inteligentes (clases,
-- métodos, bloques, etc.) y los abre todos al cargar un archivo.
--
-- foldlevelstart controla cuánto se "expande" al abrir:
--   99 = todos abiertos (default LazyVim)
--    0 = TODOS cerrados (solo verás encabezados de class/method al abrir)
--    1 = primer nivel abierto, el resto cerrado
--
-- Como persistimos los folds (ver auto_view en autocmds.lua), esto solo
-- aplica la PRIMERA vez que abres un archivo (cuando aún no hay view guardado).
-- Te dejo en 99 (abierto) que es lo más cómodo; al cerrar folds y guardar,
-- el sistema los recuerda. Cambia a 0 si prefieres que TODO empiece cerrado.
vim.opt.foldlevelstart = 99
-- vim.opt.foldlevelstart = 0   -- Descomenta esto si quieres TODO cerrado al abrir

-- IMPORTANTE para que mkview persista los folds:
-- viewoptions debe incluir "folds". Por defecto Neovim lo trae, pero lo
-- forzamos explícitamente. Quitamos "options" porque guarda settings locales
-- que pueden generar conflictos al abrir el mismo archivo en otra config.
vim.opt.viewoptions = { "folds", "cursor", "curdir" }

-- =======================================================================================
-- Visualización de whitespace
-- =======================================================================================
-- LazyVim activa `list` con `listchars` mostrando `tab:> `, `trail:-`, `nbsp:+`.
-- Las "rayitas" que aparecían en líneas indentadas vacías y al final de línea
-- son `trail` y `lead`. Las desactivamos todas (cleanest visualmente).
-- Si en el futuro quieres detectar tabs/nbsp accidentales en lugar de apagar
-- todo, comenta la línea `list = false` y descomenta el bloque de abajo.
vim.opt.list = false

-- Alternativa: dejar list ON pero solo mostrar lo realmente útil (tab + nbsp),
-- sin las "rayitas" molestas de trailing/leading whitespace. Descomentar si lo
-- prefieres así.
-- vim.opt.list = true
-- vim.opt.listchars = { tab = "» ", nbsp = "␣" }

-- =======================================================================================
-- Indentación: 4 espacios globalmente (LazyVim trae 2 por defecto).
-- =======================================================================================
-- Esto hace que la indentación mientras editas coincida con lo que escriben
-- los formatters al guardar (csharpier, gofumpt, rustfmt, google-java-format
-- todos usan 4 por defecto). Así no hay "saltos" visuales en :w.
vim.opt.tabstop = 4 -- Cuántos espacios "vale" un tab visualmente
vim.opt.shiftwidth = 4 -- Cuánto indenta >> / << / autoindent
vim.opt.softtabstop = 4 -- Cuántos espacios inserta <Tab> en modo insert
vim.opt.expandtab = true -- <Tab> inserta espacios, no caracteres tab
vim.opt.smarttab = true -- <Tab> al inicio de línea respeta shiftwidth

-- Overrides por filetype donde la convención de la comunidad es 2:
--   - JS/TS/JSON/HTML/CSS/YAML/Lua → 2 espacios (prettier/stylua defaults)
--   - Go → tabs reales (gofumpt usa tabs, no espacios; mantenemos expandtab=false)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("indent_overrides", { clear = true }),
  pattern = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "html",
    "css",
    "scss",
    "yaml",
    "lua",
  },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = "indent_overrides",
  pattern = { "go", "gomod", "gowork", "gosum", "templ", "make", "makefile" },
  callback = function()
    -- Go y Makefiles requieren tabs reales
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 0
    vim.bo.expandtab = false
  end,
})

-- Preservar la indentación de líneas vacías al mover el cursor con flechas.
-- Sin esto, Vim borra automáticamente la indentación auto-insertada de cualquier
-- línea vacía por la que pase el cursor con <Up>/<Down>, dejándolas al margen
-- izquierdo. Con `cpoptions+=I`, Vim mantiene la indentación intacta.
-- Ver `:h cpo-I` para detalles.
vim.opt.cpoptions:append("I")

-- Bonus: evita que InsertLeave (Esc al salir del modo insert) recorte espacios
-- en blanco al final de la línea actual. Esto previene perder la indentación
-- de la línea donde estabas escribiendo si sales sin teclear contenido.
-- (LazyVim no recorta por defecto, pero por si acaso algún plugin lo hace.)
vim.api.nvim_create_autocmd("InsertLeavePre", {
  callback = function()
    -- No-op intencional: solo nos aseguramos de no tener ningún autocmd previo
    -- borrando whitespace. Si en el futuro instalas algo tipo `mini.trailspace`
    -- con auto-trim, configúralo con `only_modified = true` o quita ese plugin.
  end,
})

--vim.lsp.handlers["textDocument/inlayHint"] = function() end
