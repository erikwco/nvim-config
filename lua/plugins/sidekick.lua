-- Sidekick: NES de Copilot + chat lateral con Codex, Claude o Grok.
-- <leader>ac abre Codex CLI; usa la sesión de `codex login`.
-- <leader>aC abre Claude Code; usa su propia sesión de autenticación.
-- Extra LazyVim `ai.sidekick` instala el plugin; aquí solo lo afinamos.
-- No activar `ai.copilot` (copilot.lua): apaga el LSP oficial que NES necesita.

-- Con el foco en el chat, un clic en una pestaña de bufferline o un `:e`
-- abren el archivo en la ventana del chat y tapan la CLI. Aquí el archivo se
-- pasa a una ventana de edición y la CLI vuelve a la suya. Solo se mueven
-- buffers de archivo: el scrollback de sidekick usa esa misma ventana.
---@param terminal sidekick.cli.Terminal
local function keep_cli_in_its_window(terminal)
  local function intruder()
    if not (terminal:win_valid() and terminal:buf_valid()) then
      return
    end
    local buf = vim.api.nvim_win_get_buf(terminal.win)
    if buf ~= terminal.buf and vim.bo[buf].buftype == "" then
      return buf
    end
  end

  local function is_editor(win)
    return win ~= terminal.win
      and vim.api.nvim_win_get_config(win).zindex == nil
      and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
  end

  local function move_out()
    local buf = intruder()
    if not buf then
      return
    end
    -- La última ventana usada primero: con varios splits es la esperada.
    local wins = vim.api.nvim_tabpage_list_wins(0)
    table.insert(wins, 1, vim.fn.win_getid(vim.fn.winnr("#")))
    local editor = vim.tbl_filter(is_editor, wins)[1]

    vim.api.nvim_win_set_buf(terminal.win, terminal.buf)
    terminal:wo()
    if editor then
      vim.api.nvim_win_set_buf(editor, buf)
      vim.api.nvim_set_current_win(editor)
    else
      vim.api.nvim_open_win(buf, true, { split = "left", win = -1 })
    end
    vim.cmd.stopinsert()
    -- Sidekick anotó "modo normal" al salir del chat: al volver, se escribe.
    terminal.normal_mode = false
  end

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = terminal.group,
    callback = function()
      -- `:buffer` sigue tocando la ventana y el foco después de este evento:
      -- el intercambio se hace cuando el comando ya terminó.
      if intruder() then
        vim.schedule(move_out)
      end
    end,
  })
end

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
        config = keep_cli_in_its_window,
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
    -- <tab> (NES jump/apply) y <leader>uN los mapea el extra; <leader>uM/uN se
    -- redefinen arriba como Snacks.toggle para que NES y Supermaven no convivan.
    keys = {
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
        "<leader>ue",
        function()
          require("util.ai_engine").switch()
        end,
        desc = "Switch NES / Supermaven",
      },
    },
  },
}
