-- Explorer de snacks: "peek" del nombre completo del archivo/carpeta bajo el cursor.
-- Tecla: K (en la lista del explorer). Se cierra solo al mover el cursor o salir de la ventana.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          actions = {
            peek_name = function(picker, item)
              item = item or picker:current()
              if not item or not item.file then
                return
              end
              -- Ruta relativa al cwd; cambia ":~:." por ":t" si solo quieres el nombre
              local text = vim.fn.fnamemodify(item.file, ":~:.")
              local buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " " .. text .. " " })
              local win = vim.api.nvim_open_win(buf, false, {
                relative = "cursor",
                row = 1,
                col = 0,
                width = vim.fn.strdisplaywidth(text) + 2,
                height = 1,
                style = "minimal",
                border = "rounded",
                focusable = false,
                zindex = 200,
              })
              vim.api.nvim_create_autocmd({ "CursorMoved", "WinLeave", "BufLeave" }, {
                buffer = picker.list.win.buf,
                once = true,
                callback = function()
                  if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                  end
                end,
              })
            end,
          },
          win = {
            list = {
              keys = {
                ["K"] = "peek_name",
              },
            },
          },
        },
      },
    },
  },
}
