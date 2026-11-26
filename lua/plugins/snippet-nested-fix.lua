-- En Neovim 0.12 `vim.snippet.stop()` borra los extmarks de todas las sesiones
-- del buffer. Si aceptas un completado sin placeholders (p. ej. `Println()`)
-- dentro de un snippet activo, el snippet exterior queda sin extmarks, pero
-- `LazyVim.cmp.expand` lo restaura igual como sesión activa. El siguiente
-- snippet reutiliza sus ids y cada tecla lanza
-- "snippet.lua:114: attempt to index a nil value" desde TextChanged.
-- Aquí se descarta la sesión restaurada cuando ya no tiene extmarks.
-- Borrar este archivo cuando Neovim traiga sesiones anidadas (ya en master).

local ns = vim.api.nvim_create_namespace("nvim.snippet")
local expand = LazyVim.cmp.expand

LazyVim.cmp.expand = function(snippet)
  expand(snippet)
  local session = vim.snippet._session
  if
    session and #vim.api.nvim_buf_get_extmark_by_id(session.bufnr, ns, session.current_tabstop.extmark_id, {}) == 0
  then
    vim.snippet._session = nil
  end
end

return {}
