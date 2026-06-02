return -- lazy.nvim
{
  "GustavEikaas/easy-dotnet.nvim",
  -- 'nvim-telescope/telescope.nvim' or 'ibhagwan/fzf-lua' or 'folke/snacks.nvim'
  -- are highly recommended for a better experience
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  -- Solo cargar si `dotnet` está disponible. En máquinas sin .NET instalado
  -- (ej. un Linux donde solo editas web), easy-dotnet intentaría arrancar su
  -- servidor RPC y falla con "Vim:E475: 'dotnet' is not executable".
  -- Con esto, simplemente no se carga ahí (Mac/Linux con .NET cargan normal).
  cond = function()
    return vim.fn.executable("dotnet") == 1
  end,
  -- Carga al arrancar nvim para que :Dotnet, :Secrets, etc estén disponibles desde el inicio.
  -- Sin esto, el plugin queda lazy y el primer :Dotnet falla con E492.
  event = "VeryLazy",
  cmd = { "Dotnet", "Secrets" },
  config = function()
    local function get_secret_path(secret_guid)
      local path = ""
      local home_dir = vim.fn.expand("~")
      if require("easy-dotnet.extensions").isWindows() then
        local secret_path = home_dir
          .. "\\AppData\\Roaming\\Microsoft\\UserSecrets\\"
          .. secret_guid
          .. "\\secrets.json"
        path = secret_path
      else
        local secret_path = home_dir .. "/.microsoft/usersecrets/" .. secret_guid .. "/secrets.json"
        path = secret_path
      end
      return path
    end

    local dotnet = require("easy-dotnet")
    -- Options are not required
    dotnet.setup({
      --Optional function to return the path for the dotnet sdk (e.g C:/ProgramFiles/dotnet/sdk/8.0.0)
      -- easy-dotnet will resolve the path automatically if this argument is omitted, for a performance improvement you can add a function that returns a hardcoded string
      -- You should define this function to return a hardcoded path for a performance improvement 🚀
      test_runner = {
        ---@type "split" | "float" | "buf"
        viewmode = "float",
        enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
        noBuild = true,
        noRestore = true,
        icons = {
          passed = "",
          skipped = "",
          failed = "",
          success = "",
          reload = "",
          test = "",
          sln = "󰘐",
          project = "󰘐",
          dir = "",
          package = "",
        },
        mappings = {
          run_test_from_buffer = { lhs = "<leader>r", desc = "run test from buffer" },
          filter_failed_tests = { lhs = "<leader>fe", desc = "filter failed tests" },
          debug_test = { lhs = "<leader>d", desc = "debug test" },
          go_to_file = { lhs = "g", desc = "got to file" },
          run_all = { lhs = "<leader>R", desc = "run all tests" },
          run = { lhs = "<leader>r", desc = "run test" },
          peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
          expand = { lhs = "o", desc = "expand" },
          expand_node = { lhs = "E", desc = "expand node" },
          expand_all = { lhs = "-", desc = "expand all" },
          collapse_all = { lhs = "W", desc = "collapse all" },
          close = { lhs = "q", desc = "close testrunner" },
          refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
        },
        --- Optional table of extra args e.g "--blame crash"
        additional_args = {},
      },
      ---@param action "test" | "restore" | "build" | "run"
      terminal = function(path, action, args)
        local commands = {
          run = function()
            return string.format("dotnet run --project %s %s", path, args)
          end,
          test = function()
            return string.format("dotnet test %s %s", path, args)
          end,
          restore = function()
            return string.format("dotnet restore %s %s", path, args)
          end,
          build = function()
            return string.format("dotnet build %s %s", path, args)
          end,
          watch = function()
            return string.format("dotnet watch --project %s %s", path, args)
          end,
        }

        local command = commands[action]() .. "\r"
        vim.cmd("vsplit")
        vim.cmd("term " .. command)
      end,
      secrets = {
        path = get_secret_path,
      },
      csproj_mappings = true,
      fsproj_mappings = true,
      auto_bootstrap_namespace = {
        --block_scoped, file_scoped
        type = "block_scoped",
        enabled = true,
      },
      -- choose which picker to use with the plugin
      -- possible values are "telescope" | "fzf" | "snacks" | "basic"
      -- if no picker is specified, the plugin will determine
      -- the available one automatically with this priority:
      -- telescope -> fzf -> snacks ->  basic
      picker = "telescope",
      -- Desactivar el cliente Roslyn que easy-dotnet arranca internamente:
      -- usamos seblyng/roslyn.nvim (configurado en dotnet-roslyn.lua) y tener
      -- los dos atachados al mismo buffer .cs causa duplicación de:
      --   * referencias (codelens "3 references / 3 references")
      --   * items en el menú de completion
      --   * code actions
      -- projx_lsp se queda activo porque sirve para .csproj/.sln (otro filetype).
      lsp = {
        enabled = false,
      },
    })

    -- Example command
    vim.api.nvim_create_user_command("Secrets", function()
      dotnet.secrets()
    end, {})

    -- Nota: <leader>cR (Run Project) está definido en dotnet-keymaps.lua.
    -- Se quitó <C-p> porque colisiona con "previous completion item" de cmp/blink.
  end,
}
