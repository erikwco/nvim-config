return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- Set xmllint as the formatter for xml filetype
      opts.formatters_by_ft.xml = { "xmllint" }
      opts.formatters = opts.formatters or {}
      opts.formatters.xmllint = {
        -- Command to use for formatting. The dash ("-") tells xmllint to read from stdin.
        command = "xmllint",
        args = { "--format", "-" },
        -- Optionally, you can add extra parameters (for example, to control empty line handling)
      }
      return opts
    end,
  },
}
