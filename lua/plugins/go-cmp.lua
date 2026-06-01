return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    opts.mapping = vim.tbl_extend("force", opts.mapping, {
      ["<C-n>"] = cmp.mapping.select_next_item(), -- siguiente sugerencia
      ["<C-p>"] = cmp.mapping.select_prev_item(), -- sugerencia anterior
      ["<CR>"] = cmp.mapping.confirm({ select = true }), -- aceptar con Enter
    })
  end,
}
