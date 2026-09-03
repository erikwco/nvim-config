return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    dim = {},
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        vim.schedule(function()
          require("util.toggle_persist").setup()
        end)
      end,
    })
  end,
}
