-- Sidekick: NES de Copilot + chat lateral con Codex, Claude o Grok.
-- <leader>ac abre Codex CLI; usa la sesión de `codex login`.
-- <leader>aC abre Claude Code; usa su propia sesión de autenticación.
-- Extra LazyVim `ai.sidekick` instala el plugin; aquí solo lo afinamos.
-- No activar `ai.copilot` (copilot.lua): apaga el LSP oficial que NES necesita.

return {
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "copilot-language-server" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Copilot LSP oficial (nvim-lspconfig). :LspCopilotSignIn es buffer-local
      -- y lo registra el on_attach de lspconfig cuando el server se attacha.
      local v = vim.version()
      local version = string.format("%d.%d.%d", v.major, v.minor, v.patch)
      opts.servers = opts.servers or {}
      opts.servers.copilot = vim.tbl_deep_extend("force", opts.servers.copilot or {}, {
        exit_timeout = 1000,
        init_options = {
          editorInfo = { name = "Neovim", version = version },
          editorPluginInfo = { name = "nvim-lspconfig", version = version },
        },
      })
      opts.setup = opts.setup or {}
      opts.setup.copilot = function(server, server_opts)
        vim.lsp.config(server, server_opts)
        vim.lsp.enable(server, vim.g.ai_engine == "nes")
        return true -- Excluir el autoarranque de Mason; lo controla el motor AI.
      end
    end,
  },

  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      -- NES primero: si hay overlay teal, Tab lo aplica; si no, snippet/completion.
      opts.keymap = opts.keymap or {}
      opts.keymap["<Tab>"] = {
        LazyVim.cmp.map({ "ai_nes", "snippet_forward", "ai_accept" }),
        "fallback",
      }
      return opts
    end,
  },

  {
    "folke/sidekick.nvim",
    opts = function(_, opts)
      -- Esc no debe borrar el overlay NES: si no, no llegas a aplicar con Tab.
      opts.nes = vim.tbl_deep_extend("force", opts.nes or {}, {
        clear = { esc = false },
      })
      if vim.g.ai_engine ~= "nes" then
        opts.nes.enabled = false
      end

      opts.cli = opts.cli or {}
      opts.cli.win = vim.tbl_deep_extend("force", opts.cli.win or {}, {
        layout = "right",
      })
      opts.cli.prompts = vim.tbl_extend("force", opts.cli.prompts or {}, {
        explain_error = table.concat({
          "I'm learning. Explain the diagnostics in {file} in simple terms",
          "and show the corrected snippet.",
          "",
          "{diagnostics}",
          "",
          "Cursor is at {position}.",
        }, "\n"),
      })

      -- <Tab> en insert: snippet → NES → (si hay) ghost de Supermaven.
      LazyVim.cmp.actions.ai_accept = function()
        if not package.loaded["supermaven-nvim.completion_preview"] then
          return
        end
        local suggestion = require("supermaven-nvim.completion_preview")
        if suggestion.has_suggestion() then
          LazyVim.create_undo()
          vim.schedule(function()
            suggestion.on_accept_suggestion()
          end)
          return true
        end
      end

      -- Re-mapear toggles del extra para que NES y Supermaven no convivan.
      vim.schedule(function()
        Snacks.toggle({
          name = "Sidekick NES",
          get = function()
            return require("util.ai_engine").nes_enabled()
          end,
          set = function(state)
            require("util.ai_engine").set_nes(state)
          end,
        }):map("<leader>uN")

        Snacks.toggle({
          name = "Supermaven",
          get = function()
            return require("util.ai_engine").supermaven_running()
          end,
          set = function(state)
            require("util.ai_engine").set_supermaven(state)
          end,
        }):map("<leader>uM")
      end)

      return opts
    end,
    config = function(_, opts)
      require("sidekick").setup(opts)
      -- Sidekick inicializa NES con vim.schedule; restaurar después evita
      -- que ese arranque vuelva a encenderlo sobre la elección guardada.
      vim.schedule(function()
        require("util.ai_engine").restore()
      end)
    end,
    keys = {
      {
        "<tab>",
        function()
          if require("sidekick").nes_jump_or_apply() then
            return ""
          end
          return "<Tab>"
        end,
        mode = { "n" },
        expr = true,
        silent = true,
        desc = "NES jump / apply",
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "codex", focus = true })
        end,
        desc = "Sidekick Codex",
        mode = { "n", "v" },
      },
      {
        "<leader>aC",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Sidekick Claude",
        mode = { "n", "v" },
      },
      {
        "<leader>ag",
        function()
          require("sidekick.cli").toggle({ name = "grok", focus = true })
        end,
        desc = "Sidekick Grok",
        mode = { "n", "v" },
      },
      {
        "<leader>uM",
        function()
          local engine = require("util.ai_engine")
          engine.set_supermaven(not engine.supermaven_running())
        end,
        desc = "Toggle Supermaven",
      },
      {
        "<leader>ue",
        function()
          require("util.ai_engine").switch()
        end,
        desc = "Switch NES / Supermaven",
      },
    },
  },
}
