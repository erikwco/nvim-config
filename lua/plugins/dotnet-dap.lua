-- Debug de .NET Core / .NET con netcoredbg.
-- Autodiscovery del .csproj / .dll en lugar de pedir el path a mano.
-- LazyVim ya registra el adapter `netcoredbg` desde el extra lang.dotnet;
-- aquí sobreescribimos las configurations con autodiscovery.

local function pick_csproj(callback)
  local cwd = vim.fn.getcwd()
  local csprojs = vim.fn.glob(cwd .. "/**/*.csproj", false, true)
  if #csprojs == 0 then
    vim.notify("No se encontró ningún .csproj en " .. cwd, vim.log.levels.ERROR)
    return
  end
  if #csprojs == 1 then
    callback(csprojs[1])
    return
  end
  vim.ui.select(csprojs, {
    prompt = "Selecciona proyecto .csproj:",
    format_item = function(p)
      return vim.fn.fnamemodify(p, ":~:.")
    end,
  }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end

local function find_dll(csproj, config)
  config = config or "Debug"
  local proj_dir = vim.fn.fnamemodify(csproj, ":h")
  local proj_name = vim.fn.fnamemodify(csproj, ":t:r")
  -- bin/<Config>/<tfm>/<Project>.dll
  local pattern = proj_dir .. "/bin/" .. config .. "/**/" .. proj_name .. ".dll"
  local dlls = vim.fn.glob(pattern, false, true)
  return dlls[1]
end

local function build_and_get_dll(csproj, config)
  config = config or "Debug"
  vim.notify("Compilando " .. vim.fn.fnamemodify(csproj, ":t") .. " (" .. config .. ")...", vim.log.levels.INFO)
  local out = vim.fn.system({ "dotnet", "build", csproj, "-c", config, "--nologo" })
  if vim.v.shell_error ~= 0 then
    vim.notify("Build falló:\n" .. out, vim.log.levels.ERROR)
    return nil
  end
  local dll = find_dll(csproj, config)
  if not dll then
    vim.notify("No se encontró el .dll después del build en bin/" .. config, vim.log.levels.ERROR)
  end
  return dll
end

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      -- Asegurar adapter (LazyVim ya lo registra, pero por defensa)
      if not dap.adapters["netcoredbg"] then
        dap.adapters["netcoredbg"] = {
          type = "executable",
          command = vim.fn.exepath("netcoredbg"),
          args = { "--interpreter=vscode" },
          options = { detached = false },
        }
      end

      local launch_auto = {
        type = "netcoredbg",
        name = "Launch (autodiscover .csproj)",
        request = "launch",
        program = function()
          local result_dll
          local done = false
          pick_csproj(function(csproj)
            result_dll = build_and_get_dll(csproj, "Debug")
            done = true
          end)
          -- Espera la selección (vim.ui.select es síncrono con telescope/snacks por defecto)
          vim.wait(60000, function()
            return done
          end, 100)
          return result_dll or vim.fn.input("Path al .dll: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = false,
        env = {
          ASPNETCORE_ENVIRONMENT = "Development",
          DOTNET_ENVIRONMENT = "Development",
        },
        console = "integratedTerminal",
      }

      local attach_pid = {
        type = "netcoredbg",
        name = "Attach to process",
        request = "attach",
        processId = function()
          return require("dap.utils").pick_process({ filter = "dotnet" })
        end,
      }

      for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
        -- Reemplazamos las configurations por las nuevas (sobreescribe la default de LazyVim)
        dap.configurations[lang] = {
          launch_auto,
          attach_pid,
        }
      end
    end,
  },
}
