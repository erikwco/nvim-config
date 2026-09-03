return {
  -- 1) LSP, DAP, formatters via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "rust-analyzer", -- LSP
        "codelldb", -- Debugger
      })
    end,
  },

  -- 2) Treesitter for Rust/TOML/RON
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "rust", "toml", "ron", "lua", "json" },
    },
  },

  -- 3) crates.nvim: versiones, features y actions en Cargo.toml.
  -- Completion/hover/actions van por LSP in-process (blink.cmp lo consume).
  -- No declarar completion.cmp ni null_ls: esas claves están deprecadas y
  -- avisan aunque estén en false.
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        crates = { enabled = true },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },

  -- 4) Rust UX: rustaceanvim (uses rust-analyzer under the hood)
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- latest major
    ft = { "rust" },
    init = function()
      -- Global settings consumed by the plugin
      vim.g.rustaceanvim = {
        tools = {
          float_win_config = { border = "rounded" },
          hover_actions = { replace_builtin_hover = true },
          runnables = { use_telescope = true },
          executor = "termopen", -- or "toggleterm"
        },
        server = {
          on_attach = function(client, bufnr)
            -- Use clippy on save
            -- vim.api.nvim_create_autocmd("BufWritePost", {
            --   buffer = bufnr,
            --   callback = function()
            --     vim.cmd("silent! RustLsp clippy --all-targets --all-features")
            --   end,
            -- })
          end,
          default_settings = {
            -- Schema actual de rust-analyzer (checkOnSave ya no es un objeto).
            -- --all-targets / --all-features los inyecta RA por default; no van en extraArgs.
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = true,
              check = { command = "clippy" },
              diagnostics = { enable = true },
              completion = { postfix = { enable = true } },
            },
          },
        },
        dap = {
          adapter = function()
            local mason = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
            local codelldb_path = mason .. "adapter/codelldb"
            local liblldb_path = mason .. "lldb/lib/liblldb.dylib" -- macOS
            if vim.fn.has("linux") == 1 then
              liblldb_path = mason .. "lldb/lib/liblldb.so"
            end
            return require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path)
          end,
        },
      }
    end,
  },

  -- 5) Evita que LazyVim arranque rust_analyzer por lspconfig.
  --    rustaceanvim ya levanta su propio cliente; tener los dos causa
  --    diagnósticos duplicados y races al guardar.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = { enabled = false },
      },
      setup = {
        rust_analyzer = function()
          return true -- no llamar a lspconfig.setup; lo hace rustaceanvim
        end,
      },
    },
  },

  -- 6) Autoformat con rustfmt vía conform
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
      },
    },
  },
}
