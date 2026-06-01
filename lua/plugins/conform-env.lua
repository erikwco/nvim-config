-- lua/config/autocmds.lua
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.env", "*.env.*", ".env.*", ".env" },
  callback = function()
    vim.b.autoformat = false
  end,
})

return {}
