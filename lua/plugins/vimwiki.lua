return {
  "vimwiki/vimwiki",
  init = function()
    vim.g.vimwiki_list = {
      {
        path = "~/Projects/notes/vimwiki/",
        syntax = "markdown",
        ext = ".md",
      },
    }
    vim.g.vimwiki_global_ext = 0
  end,
  keys = {
    { "<leader>vw", "<cmd>VimwikiIndex<CR>", desc = "Open VimWiki Index" },
    { "<leader>vt", "<cmd>VimwikiTabIndex<CR>", desc = "Open VimWiki Index in new tab" },
  },
  event = "BufEnter *.md",
}
