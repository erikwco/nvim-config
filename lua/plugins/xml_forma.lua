-- conform ya trae el formatter `xmllint` (xmllint --format -); solo lo asignamos.
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        xml = { "xmllint" },
      },
    },
  },
}
