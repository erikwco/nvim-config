-- Nombres de grupo para los prefijos propios, así <leader> muestra el mapa completo
-- en which-key en lugar de "+prefix". Los grupos de LazyVim (c, d, f, g, s, u, x…)
-- ya vienen definidos; <leader>A (AWS) está en plugins/aws.lua.
return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>G", group = "gradle", icon = "" },
        { "<leader>m", group = "maven", icon = "" },
        { "<leader>;", group = "dotnet", icon = "󰪮" },
        { "<leader>cp", group = "dotnet publish", icon = "󰪮" },
        { "<leader>F", group = "flutter", icon = "" },
        { "<leader>M", group = "sshfs", icon = "󰒍" },
        { "<leader>j", group = "java (jdtls)", icon = "" },
        { "<leader>Q", group = "database", icon = "" },
        { "<leader>gv", group = "diffview", icon = "" },
        { "<leader>T", group = "terminal", icon = "" },
        { "<leader>v", group = "vimwiki", icon = "" },
        { "<leader>1", desc = "Terminal 1 (root)", icon = "" },
        { "<leader>2", desc = "Terminal 2 (root)", icon = "" },
        { "<leader>3", desc = "Terminal 3 (root)", icon = "" },
      },
    },
  },
}
