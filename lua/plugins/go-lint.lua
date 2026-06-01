return {
  "mfussenegger/nvim-lint",
  event = "LazyFile", -- o BufReadPost si no usas LazyVim events
  opts = function(_, opts)
    local lint = require("lint")

    -- Asegura el mapping por filetype
    opts.linters_by_ft = opts.linters_by_ft or {}
    opts.linters_by_ft.go = { "golangcilint" }

    -- Toma el linter base: puede ser función (factory) o tabla.
    local goci = lint.linters.golangcilint
    if type(goci) == "function" then
      goci = goci() -- obtenemos la tabla con name/cmd/parser ya definidos
    end
    if type(goci) ~= "table" then
      -- fallback ultra-defensivo (poco probable que lo necesites)
      goci = { name = "golangci-lint", cmd = "golangci-lint", parser = lint.parsers.golangci_lint }
    end

    -- Detecta v2 rápidamente (si no quieres autodetección, fija directamente args de v2)
    local is_v2 = false
    do
      local ok, res = pcall(function()
        if vim.system then
          return vim.system({ "golangci-lint", "version" }, { text = true }):wait()
        end
        local h = io.popen("golangci-lint version 2>/dev/null")
        local out = h and h:read("*a") or ""
        if h then
          h:close()
        end
        return { code = 0, stdout = out }
      end)
      if ok and res and res.code == 0 and res.stdout:match("has version 2") then
        is_v2 = true
      end
    end

    -- Ajusta flags según versión (tú usas v2.5.0 → rama v2)
    goci.args = is_v2 and { "run", "--output.json.path=stdout", "--show-stats=false", "--issues-exit-code", "0" }
      or { "run", "--out-format", "json", "--show-stats=false", "--issues-exit-code=0" }

    -- Silencia el warning del exit code en el editor (mantiene diagnósticos)
    goci.ignore_exitcode = true

    -- Vuelve a registrar el linter modificado
    lint.linters.golangcilint = goci
  end,
}
