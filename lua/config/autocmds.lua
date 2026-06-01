-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--

-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client and client.name == "jdtls" and client.config.root_dir == nil then
--       vim.schedule(function()
--         vim.lsp.stop_client(client.id, true)
--       end)
--     end
--   end,
-- })

local orig_start = vim.lsp.start
vim.lsp.start = function(config, ...)
  if
    config
    and config.name == "jdtls"
    and not config.root_dir
    and config.cmd
    and type(config.cmd) == "table"
    and #config.cmd == 1
  then
    return nil
  end
  return orig_start(config, ...)
end

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
