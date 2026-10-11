-- Motor de completion AI: Copilot NES xor Supermaven.
-- Activar uno apaga el otro. Los dos pueden estar apagados.
-- Una sola preferencia persistida: "nes", "supermaven" u "off".

local M = {}

local path = vim.fn.stdpath("state") .. "/ai-engine.json"

-- Se lee desde options.lua, antes de cargar los plugins.
function M.load()
  local file = io.open(path, "r")
  if not file then
    return "nes"
  end
  local raw = file:read("*a")
  file:close()
  local ok, engine = pcall(vim.json.decode, raw)
  if ok and (engine == "nes" or engine == "supermaven" or engine == "off") then
    return engine
  end
  return "nes"
end

local function persist()
  -- Reemplazo atómico para que otra instancia no lea un archivo incompleto.
  local temp = path .. "." .. vim.fn.getpid() .. ".tmp"
  local ok, err = pcall(function()
    vim.fn.mkdir(vim.fn.stdpath("state"), "p")
    vim.fn.writefile({ vim.json.encode(vim.g.ai_engine) }, temp)
    assert(vim.uv.fs_rename(temp, path))
  end)
  if not ok then
    vim.fn.delete(temp)
    vim.notify("No se pudo guardar el motor AI: " .. tostring(err), vim.log.levels.WARN)
  end
end

local function nes_mod()
  local ok, nes = pcall(require, "sidekick.nes")
  if not ok then
    return nil
  end
  return nes
end

local function supermaven_api(load)
  if not load and not package.loaded["supermaven-nvim.api"] then
    return nil
  end
  local ok, api = pcall(require, "supermaven-nvim.api")
  if not ok then
    return nil
  end
  return api
end

local function supermaven_aux_maps(on)
  if not on and not package.loaded["supermaven-nvim.completion_preview"] then
    pcall(vim.keymap.del, "i", "<C-j>")
    pcall(vim.keymap.del, "i", "<C-]>")
    return
  end
  local preview_ok, preview = pcall(require, "supermaven-nvim.completion_preview")
  if not preview_ok then
    return
  end
  if on then
    vim.keymap.set("i", "<C-j>", preview.on_accept_suggestion_word, {
      noremap = true,
      silent = true,
      desc = "Supermaven accept word",
    })
    vim.keymap.set("i", "<C-]>", preview.on_dispose_inlay, {
      noremap = true,
      silent = true,
      desc = "Supermaven clear",
    })
  else
    pcall(vim.keymap.del, "i", "<C-j>")
    pcall(vim.keymap.del, "i", "<C-]>")
  end
end

local function set_nes_only(on)
  -- Deshabilitar el LSP también detiene sus procesos y evita nuevos arranques.
  vim.lsp.enable("copilot", on)
  local nes = nes_mod()
  if not nes then
    return
  end
  nes.enable(on)
end

local function set_supermaven_only(on)
  local api = supermaven_api(on)
  if not api then
    supermaven_aux_maps(false)
    return
  end
  if on then
    if not api.is_running() then
      api.start()
    end
    supermaven_aux_maps(true)
  else
    if api.is_running() then
      api.stop()
    end
    supermaven_aux_maps(false)
  end
end

local function apply(engine)
  -- Supermaven consulta esta preferencia durante su carga diferida.
  vim.g.ai_engine = engine
  if engine == "nes" then
    set_supermaven_only(false)
    set_nes_only(true)
  else
    set_nes_only(false)
    set_supermaven_only(engine == "supermaven")
  end
end

function M.restore()
  apply(vim.g.ai_engine)
end

local function set(engine, on)
  if not on then
    engine = vim.g.ai_engine == engine and "off" or vim.g.ai_engine
  end
  apply(engine)
  persist()
end

function M.nes_enabled()
  local nes = nes_mod()
  if not nes then
    return false
  end
  local enabled = nes.enabled
  if type(enabled) == "function" then
    return enabled() and true or false
  end
  return enabled and true or false
end

function M.supermaven_running()
  if not package.loaded["supermaven-nvim.api"] then
    return false
  end
  local api = supermaven_api()
  return api and api.is_running() or false
end

function M.set_nes(on)
  set("nes", on)
end

function M.set_supermaven(on)
  set("supermaven", on)
end

function M.switch()
  if M.nes_enabled() then
    M.set_supermaven(true)
    vim.notify("AI completion: Supermaven (NES off)", vim.log.levels.INFO)
  else
    M.set_nes(true)
    vim.notify("AI completion: Copilot NES (Supermaven off)", vim.log.levels.INFO)
  end
end

return M
