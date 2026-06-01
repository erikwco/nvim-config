-- Keymaps para .NET: publish multi-plataforma (osx-arm64, win-x64) + build/test atajos.
-- Autodescubre el .csproj; si hay varios, deja elegir.

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

local function run_in_split(cmd)
  vim.cmd("botright split | resize 15 | terminal " .. cmd)
end

local function publish(rid, self_contained)
  pick_csproj(function(csproj)
    local sc = self_contained and " --self-contained true" or " --self-contained false"
    local cmd = string.format("dotnet publish %q -c Release -r %s%s", csproj, rid, sc)
    vim.notify("Publishing → " .. rid, vim.log.levels.INFO)
    run_in_split(cmd)
  end)
end

local function publish_all(rids, self_contained)
  pick_csproj(function(csproj)
    local sc = self_contained and " --self-contained true" or " --self-contained false"
    local parts = {}
    for _, rid in ipairs(rids) do
      table.insert(parts, string.format("dotnet publish %q -c Release -r %s%s", csproj, rid, sc))
    end
    local cmd = table.concat(parts, " && ")
    vim.notify("Publishing → " .. table.concat(rids, ", "), vim.log.levels.INFO)
    run_in_split(cmd)
  end)
end

-- Busca Properties/PublishProfiles/*.pubxml en el directorio del .csproj.
-- Devuelve lista de { name = "win-x64", path = "/full/path/..." }.
local function find_pubxml_profiles(csproj)
  local proj_dir = vim.fn.fnamemodify(csproj, ":h")
  local pubxmls = vim.fn.glob(proj_dir .. "/Properties/PublishProfiles/*.pubxml", false, true)
  local profiles = {}
  for _, p in ipairs(pubxmls) do
    table.insert(profiles, {
      name = vim.fn.fnamemodify(p, ":t:r"), -- nombre sin .pubxml
      path = p,
    })
  end
  return profiles
end

-- Publish usando un .pubxml (lo que hace Rider/Visual Studio).
-- Si hay varios profiles → picker. Si hay 0 → te avisa y sugiere flags.
local function publish_with_pubxml(csproj)
  local profiles = find_pubxml_profiles(csproj)
  if #profiles == 0 then
    vim.notify(
      "No se encontraron .pubxml en Properties/PublishProfiles/.\nUsa <leader>cpm/cpw para publish con flags directos.",
      vim.log.levels.WARN
    )
    return
  end

  local function run_profile(profile)
    local cmd = string.format("dotnet publish %q -p:PublishProfile=%s", csproj, profile.name)
    vim.notify("Publishing con profile → " .. profile.name, vim.log.levels.INFO)
    run_in_split(cmd)
  end

  if #profiles == 1 then
    run_profile(profiles[1])
    return
  end
  vim.ui.select(profiles, {
    prompt = "Selecciona PublishProfile:",
    format_item = function(p)
      return p.name .. "  (" .. vim.fn.fnamemodify(p.path, ":~:.") .. ")"
    end,
  }, function(choice)
    if choice then
      run_profile(choice)
    end
  end)
end

return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    keys = {
      -- Publish multi-plataforma (self-contained por defecto, ideal para distribución)
      {
        "<leader>cpm",
        function()
          publish("osx-arm64", true)
        end,
        desc = "dotnet publish: macOS arm64 (self-contained)",
        ft = "cs",
      },
      {
        "<leader>cpw",
        function()
          publish("win-x64", true)
        end,
        desc = "dotnet publish: Windows x64 (self-contained)",
        ft = "cs",
      },
      {
        "<leader>cpa",
        function()
          publish_all({ "osx-arm64", "win-x64" }, true)
        end,
        desc = "dotnet publish: todos los targets",
        ft = "cs",
      },
      -- Variantes framework-dependent (más livianas, requieren runtime instalado)
      {
        "<leader>cpM",
        function()
          publish("osx-arm64", false)
        end,
        desc = "dotnet publish: macOS arm64 (framework-dep)",
        ft = "cs",
      },
      {
        "<leader>cpW",
        function()
          publish("win-x64", false)
        end,
        desc = "dotnet publish: Windows x64 (framework-dep)",
        ft = "cs",
      },
      -- Publish usando un .pubxml profile (Properties/PublishProfiles/*.pubxml).
      -- Es lo que Rider y Visual Studio usan por debajo. Si tienes varios, picker.
      {
        "<leader>cpp",
        function()
          pick_csproj(publish_with_pubxml)
        end,
        desc = "dotnet publish: usar .pubxml profile (picker)",
        ft = "cs",
      },
      -- También útil en .csproj y archivos .pubxml mismos
      {
        "<leader>cpp",
        function()
          pick_csproj(publish_with_pubxml)
        end,
        desc = "dotnet publish: usar .pubxml profile",
        ft = { "xml" },
      },
      -- Atajos para build/test/restore/clean rápidos sin entrar a easy-dotnet
      {
        "<leader>cb",
        function()
          pick_csproj(function(p)
            run_in_split("dotnet build " .. vim.fn.shellescape(p))
          end)
        end,
        desc = "dotnet build",
        ft = "cs",
      },
      {
        "<leader>ct",
        function()
          pick_csproj(function(p)
            run_in_split("dotnet test " .. vim.fn.shellescape(p))
          end)
        end,
        desc = "dotnet test",
        ft = "cs",
      },
      {
        "<leader>cr",
        function()
          pick_csproj(function(p)
            run_in_split("dotnet restore " .. vim.fn.shellescape(p))
          end)
        end,
        desc = "dotnet restore",
        ft = "cs",
      },
      {
        "<leader>cw",
        function()
          pick_csproj(function(p)
            run_in_split("dotnet watch run --project " .. vim.fn.shellescape(p))
          end)
        end,
        desc = "dotnet watch run",
        ft = "cs",
      },
      -- ===== Comandos easy-dotnet bajo prefix <leader>;* (punto y coma) =====
      -- Prefijos ya ocupados que NO podemos usar:
      --   <leader>c*  → LazyVim code actions (rename, format, action)
      --   <leader>d*  → DAP debug (toggle bp, continue, step over, etc)
      --   <leader>D*  → Snacks/LazyVim panel lateral del terminal
      --   <leader>n*  → LazyVim notifications/noice
      -- <leader>;* es único, sin conflictos, fácil de teclear (mano derecha).
      { "<leader>;r", "<cmd>Dotnet run<CR>", desc = "Dotnet: Run (picker)" },
      { "<leader>;d", "<cmd>Dotnet debug<CR>", desc = "Dotnet: Debug (picker)" },
      { "<leader>;t", "<cmd>Dotnet testrunner<CR>", desc = "Dotnet: Test runner UI" },
      { "<leader>;b", "<cmd>Dotnet build<CR>", desc = "Dotnet: Build (picker)" },
      { "<leader>;R", "<cmd>Dotnet restore<CR>", desc = "Dotnet: Restore" },
      { "<leader>;c", "<cmd>Dotnet clean<CR>", desc = "Dotnet: Clean" },
      { "<leader>;w", "<cmd>Dotnet watch<CR>", desc = "Dotnet: Watch run" },
      { "<leader>;n", "<cmd>Dotnet new<CR>", desc = "Dotnet: New (templates)" },
      { "<leader>;s", "<cmd>Dotnet secrets<CR>", desc = "Dotnet: User Secrets" },
      { "<leader>;o", "<cmd>Dotnet outdated<CR>", desc = "Dotnet: Outdated packages" },
      { "<leader>;a", "<cmd>Dotnet add<CR>", desc = "Dotnet: Add (package/reference)" },
      -- Panel de terminal con pestañas (mantiene la salida de runs anteriores).
      -- Dentro del panel: <Tab>/<S-Tab> cambiar pestaña, `+` nueva, `X` cerrar pestaña, `q` ocultar.
      { "<leader>;p", "<cmd>Dotnet terminal toggle<CR>", desc = "Dotnet: Toggle terminal panel" },
      { "<leader>;P", "<cmd>Dotnet terminal show<CR>", desc = "Dotnet: Show terminal panel" },
      -- Cerrar TODAS las pestañas (limpia el histórico de runs)
      -- Truco: easy-dotnet auto-crea una nueva si borras la "activa" y queda
      -- el panel vacío. Para evitarlo:
      --   1. Ocultamos el panel
      --   2. Ponemos active_id = nil ANTES de empezar a borrar
      --   3. Borramos todas las pestañas
      {
        "<leader>;X",
        function()
          local term = require("easy-dotnet.terminal")
          local mgr = require("easy-dotnet.terminal.manager")

          -- 1) Oculta el panel para que no se redibuje durante el cleanup
          pcall(term.hide)

          -- 2) Anula la pestaña activa para evitar el spawn automático
          mgr.active_id = nil

          -- 3) Recolecta IDs y bórralos
          local ids = {}
          for _, tab in ipairs(mgr.get_all()) do
            table.insert(ids, tab.id)
          end
          if #ids == 0 then
            vim.notify("No hay terminales abiertas", vim.log.levels.INFO)
            return
          end
          for _, id in ipairs(ids) do
            pcall(mgr.remove, id)
          end
          vim.notify("Cerradas " .. #ids .. " pestañas del panel", vim.log.levels.INFO)
        end,
        desc = "Dotnet: Cerrar TODAS las terminales (sin auto-spawn)",
      },
    },
  },
}
