return {
  "BibekBhusal0/nvim-shadcn",

  cmd = {
    "ShadcnAdd",
    "ShadcnRemove",
    "ShadcnCreate",
    "ShadcnInit",
    "ShadcnDoc",
    "ShadcnAddImportant",
  },

  -- Dependencias
  dependencies = { "nvim-telescope/telescope.nvim" },

  opts = {
    default_installer = "bun", -- Antes tenías 'npm'

    format = {
      doc = "https://ui.shadcn.com/docs/components/%s",
      npm = "npx shadcn@latest add %s",
      pnpm = "pnpm dlx shadcn@latest add %s",
      yarn = "npx shadcn@latest add %s",
      bun = "bunx --bun shadcn@latest add %s",
    },

    verbose = false,
    important = { "button", "card", "checkbox", "tooltip" },

    keys = { -- para telescope
      i = { doc = "<C-o>" },
      n = { doc = "<C-o>" },
    },

    init_command = {
      commands = {
        npm = "npx shadcn@latest init",
        pnpm = "pnpm dlx shadcn@latest init",
        yarn = "npx shadcn@latest init",
        bun = "bunx --bun shadcn@latest init",
      },
      flags = { defaults = false, force = false },
      default_color = "Gray", -- Correcto, debe ir con mayúscula
    },

    telescope_config = {
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
      },
      prompt_title = "Shadcn UI components",
    },
  },
}
