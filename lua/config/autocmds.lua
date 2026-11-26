-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--

-- Refrescar el fondo al volver a Neovim, incluso si la terminal no notificó
-- el cambio de tema. nvim_ui_send (0.12+) solo escribe a UIs con un TTY.
if vim.api.nvim_ui_send then
  vim.api.nvim_create_autocmd("FocusGained", {
    group = vim.api.nvim_create_augroup("terminal_background", { clear = true }),
    desc = "Refresh terminal background color",
    callback = function()
      vim.api.nvim_ui_send("\027]11;?\007")
    end,
  })
end

-- ── Desactivar spell check en markdown/docs ─────────────────────────────────
-- LazyVim activa `spell` (en inglés) para markdown/text/gitcommit. En docs
-- técnicos en español que mezclan nombres de productos (Traefik, CrowdSec...),
-- el corrector marca casi todo en rojo y estorba más de lo que ayuda.
-- Se mantiene `wrap` (útil para prosa), solo se apaga `spell`.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("disable_spell_docs", { clear = true }),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- ── No continuar comentarios automáticamente ────────────────────────────────
-- Quita los flags `r` y `o` de formatoptions:
--   r → insertaba el comment leader (#, //) al dar <CR> en insert mode
--   o → lo insertaba al dar `o`/`O` en normal mode
-- LazyVim los trae en su default ("jcroqlnt") y cada ftplugin los re-aplica,
-- por eso hay que quitarlos en un FileType autocmd (corre DESPUÉS del ftplugin).
-- Se conservan `j` (quita el leader al unir líneas con J) y `c` (autowrap en
-- comentarios largos), que sí son útiles.
--
-- Cuando SÍ quieras continuar un comentario, usa `gco` / `gcO` (añade línea
-- comentada abajo/arriba) o escribe el `#` a mano.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_auto_comment", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

-- jdtls lo arranca nvim-jdtls (plugins/jdtls-lombok.lua). Para que mason-lspconfig
-- no levante un segundo cliente con la config genérica de lspconfig, el server
-- se excluye con `setup.jdtls = function() return true end` en ese mismo archivo
-- (es lo que hace el extra lang.java de LazyVim).

-- =======================================================================================
-- Preservar la indentación de líneas vacías al presionar Enter o mover el cursor.
-- =======================================================================================
-- Vim por defecto borra la indentación auto-insertada cuando:
--   (a) presionas <CR> en una línea que solo tiene whitespace (al dejarla)
--   (b) mueves el cursor con flechas dejando una línea con solo whitespace
--
-- `cpoptions+=I` cubre el caso (b). Este autocmd cubre el caso (a) y refuerza el (b)
-- detectando cuando la línea anterior tenía whitespace y ahora está vacía,
-- y restaurando el whitespace exacto.
--
-- Funciona con múltiples Enters consecutivos, no toca el mapeo de <CR>, y no
-- interfiere con mini.pairs, supermaven, blink.cmp ni nada que mapee Enter.
local preserve_indent_group = vim.api.nvim_create_augroup("preserve_blank_indent", { clear = true })
local last_line, last_content = nil, nil

vim.api.nvim_create_autocmd("InsertEnter", {
  group = preserve_indent_group,
  callback = function()
    last_line = vim.fn.line(".")
    last_content = vim.api.nvim_get_current_line()
  end,
})

vim.api.nvim_create_autocmd("CursorMovedI", {
  group = preserve_indent_group,
  callback = function()
    local cur_line = vim.fn.line(".")

    if last_line and last_content and last_line ~= cur_line and last_line > 0 then
      local line_count = vim.api.nvim_buf_line_count(0)
      if last_line <= line_count then
        local current_text_at_last = vim.fn.getline(last_line)
        -- Restaurar solo si: la línea anterior era SOLO whitespace
        -- y ahora está completamente vacía (Vim la stripeó).
        if last_content:match("^%s+$") and current_text_at_last == "" then
          vim.fn.setline(last_line, last_content)
        end
      end
    end

    last_line = cur_line
    last_content = vim.api.nvim_get_current_line()
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = preserve_indent_group,
  callback = function()
    last_line = nil
    last_content = nil
  end,
})

-- =======================================================================================
-- Persistir folds (y cursor, scroll, etc.) entre sesiones — pattern view_activated
-- =======================================================================================
-- Usa `mkview` / `loadview` nativos de Vim, pero con el truco del flag
-- `view_activated` para cargar el view UNA SOLA VEZ por buffer (no en cada
-- BufWinEnter, lo que provocaba que se sobrescribiera el estado).
--
-- Con nvim-ufo (ver lua/plugins/ufo.lua) los folds son `manual`, así que mkview
-- los persiste de forma confiable (con `foldmethod=expr` de treesitter sí daba
-- problemas porque se recomputaban al cargar).
local auto_view_group = vim.api.nvim_create_augroup("auto_view", { clear = true })

local ignore_filetypes = {
  "gitcommit",
  "gitrebase",
  "svn",
  "hgcommit",
  "help",
  "qf",
  "alpha",
  "dashboard",
  "lazy",
  "mason",
  "TelescopePrompt",
  "neo-tree",
  "snacks_picker_input",
  "snacks_picker_list",
}

local function should_save_view(bufnr)
  if vim.bo[bufnr].buftype ~= "" then
    return false
  end
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    return false
  end
  if fname:match("^/tmp/") or fname:match("COMMIT_EDITMSG$") or fname:match("MERGE_MSG$") then
    return false
  end
  local ft = vim.bo[bufnr].filetype
  if vim.tbl_contains(ignore_filetypes, ft) then
    return false
  end
  return true
end

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost", "WinLeave", "VimLeavePre" }, {
  group = auto_view_group,
  desc = "Guardar view (folds, cursor, scroll) con mkview",
  callback = function(args)
    if vim.b[args.buf].view_activated and should_save_view(args.buf) then
      pcall(vim.cmd.mkview, { mods = { emsg_silent = true, silent = true } })
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = auto_view_group,
  desc = "Cargar view UNA VEZ por buffer",
  callback = function(args)
    -- view_activated evita recargar en cada BufWinEnter (split, refocus, etc.)
    -- que era lo que sobrescribía el estado de folds restaurado.
    if vim.b[args.buf].view_activated then
      return
    end
    if not should_save_view(args.buf) then
      return
    end
    vim.b[args.buf].view_activated = true
    -- Defer para dar tiempo a UFO/treesitter a inicializar los providers.
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(args.buf) and vim.api.nvim_get_current_buf() == args.buf then
        pcall(vim.cmd.loadview, { mods = { emsg_silent = true, silent = true } })
      end
    end, 100)
  end,
})

-- =======================================================================================
-- Diagnósticos "loud" (ver plugins/diagnostics-loud.lua para vim.diagnostic.config)
-- =======================================================================================
-- Auto-abrir el float de diagnósticos al reposar 500 ms (updatetime) sobre una
-- línea con errores. Respeta el toggle por buffer (<leader>ux) y no abre si ya
-- hay otro float visible.
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("diag_float_on_hold", { clear = true }),
  callback = function()
    if not vim.diagnostic.is_enabled({ bufnr = 0 }) then
      return
    end
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    if #vim.diagnostic.get(0, { lnum = line }) == 0 then
      return
    end
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= "" then
        return
      end
    end
    vim.diagnostic.open_float(nil, { focus = false, scope = "line", border = "rounded", source = "if_many" })
  end,
})

-- Énfasis de diagnósticos con los colores del tema activo (undercurl, negrita en
-- errores). Se aplica ahora (el tema ya cargó) y en cada cambio de colorscheme.
local function loud_diagnostic_hl()
  for _, severity in ipairs({ "Error", "Warn", "Info", "Hint" }) do
    local color = vim.api.nvim_get_hl(0, { name = "Diagnostic" .. severity, link = false }).fg
    local bold = severity == "Error"
    vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. severity, { undercurl = true, sp = color })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. severity, { fg = color, bold = bold, italic = true })
    vim.api.nvim_set_hl(0, "DiagnosticSign" .. severity, { fg = color, bold = bold })
    vim.api.nvim_set_hl(0, "DiagnosticFloating" .. severity, { fg = color, bold = bold })
  end
end
loud_diagnostic_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("diag_hl_loud", { clear = true }),
  callback = loud_diagnostic_hl,
})

-- =======================================================================================
-- No autoformatear archivos .env (antes vivía en plugins/conform-env.lua)
-- =======================================================================================
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("no_autoformat_env", { clear = true }),
  pattern = { "*.env", "*.env.*", ".env.*", ".env" },
  callback = function()
    vim.b.autoformat = false
  end,
})
