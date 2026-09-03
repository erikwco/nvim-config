-- Motor de completion AI: Copilot NES xor Supermaven.
-- Activar uno apaga el otro. Los dos pueden estar apagados.
-- Default (vim.g.ai_engine): "nes".

local M = {}

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
  local nes = nes_mod()
  if not nes then
    return
  end
  nes.enable(on)
end

local function set_supermaven_only(on)
  if on then
    vim.g.ai_engine = "supermaven"
  elseif vim.g.ai_engine == "supermaven" then
    vim.g.ai_engine = "off"
  end

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
  set_nes_only(on)
  if on then
    vim.g.ai_engine = "nes"
    set_supermaven_only(false)
  elseif vim.g.ai_engine == "nes" then
    vim.g.ai_engine = "off"
  end
end

function M.set_supermaven(on)
  if on then
    set_nes_only(false)
  end
  set_supermaven_only(on)
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
