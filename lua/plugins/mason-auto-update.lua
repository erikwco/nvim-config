-- Mason solo actualiza cuando se lo pides en `:Mason`, y un binario viejo falla
-- sin explicación cuando el toolchain avanza (golangci-lint compilado con Go
-- 1.26 contra un go.mod en 1.27 sale con código 3). Cada vez que Mason se carga,
-- se actualiza todo lo instalado que quedó detrás del registro. El registro se
-- descarga como mucho una vez al día (`registry_cache` de Mason).
--
-- A veces el registro anuncia una versión cuyo archivo de descarga no existe
-- (omnisharp v2.0.0 renombró sus assets). Ese paquete falla siempre, así que se
-- recuerda la entrada del registro que falló y no se reintenta hasta que cambie.
-- `U` en `:Mason` sigue forzando el intento.

local state_path = vim.fn.stdpath("state") .. "/mason-auto-update.json"

---@return table<string, string> huella de la entrada del registro que falló, por paquete
local function read_failed()
  local file = io.open(state_path, "r")
  if not file then
    return {}
  end
  local raw = file:read("*a")
  file:close()
  local ok, failed = pcall(vim.json.decode, raw)
  return ok and type(failed) == "table" and failed or {}
end

local function write_failed(failed)
  -- Reemplazo atómico para que otra instancia no lea un archivo incompleto.
  local temp = state_path .. "." .. vim.fn.getpid() .. ".tmp"
  local ok = pcall(function()
    vim.fn.writefile({ vim.json.encode(failed) }, temp)
    assert(vim.uv.fs_rename(temp, state_path))
  end)
  if not ok then
    vim.fn.delete(temp)
  end
end

-- vim.inspect ordena las claves: la huella es igual entre sesiones.
local function fingerprint(pkg)
  return vim.fn.sha256(vim.inspect(pkg.spec.source))
end

local function update_outdated()
  local registry = require("mason-registry")
  registry.refresh(vim.schedule_wrap(function(refreshed)
    if not refreshed then
      return
    end

    local known = read_failed()
    local failed, pending = {}, 0
    local updated_lines, failed_lines = {}, {}

    local function finish()
      if not vim.deep_equal(known, failed) then
        write_failed(failed)
      end
      if #updated_lines > 0 then
        vim.notify("Actualizados:\n" .. table.concat(updated_lines, "\n"), vim.log.levels.INFO, { title = "Mason" })
      end
      if #failed_lines > 0 then
        vim.notify(
          "No se pudo actualizar:\n"
            .. table.concat(failed_lines, "\n")
            .. "\nNo se reintenta hasta que cambie el registro. `U` en :Mason lo fuerza.",
          vim.log.levels.WARN,
          { title = "Mason" }
        )
      end
    end

    for _, pkg in ipairs(registry.get_installed_packages()) do
      local installed, latest = pkg:get_installed_version(), pkg:get_latest_version()
      if installed ~= latest and pkg:is_installable({ version = latest }) and not pkg:is_installing() then
        local mark = fingerprint(pkg)
        if known[pkg.name] == mark then
          failed[pkg.name] = mark
        else
          pending = pending + 1
          pkg:install({ version = latest }, function(success)
            vim.schedule(function()
              -- Salir a mitad de una descarga la aborta: no es un fallo del paquete.
              if vim.v.exiting ~= vim.NIL then
                return
              end
              local line = ("%s %s → %s"):format(pkg.name, installed, latest)
              if success then
                table.insert(updated_lines, line)
              else
                table.insert(failed_lines, line)
                failed[pkg.name] = mark
              end
              pending = pending - 1
              if pending == 0 then
                finish()
              end
            end)
          end)
        end
      end
    end

    if pending == 0 then
      finish()
    end
  end))
end

return {
  "mason-org/mason.nvim",
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data ~= "mason.nvim" then
          return
        end
        -- Sin UI (scripts, `nvim --headless ... +qa`) el proceso termina antes
        -- de que acaben las instalaciones.
        if #vim.api.nvim_list_uis() > 0 then
          update_outdated()
        end
        return true
      end,
    })
  end,
}
