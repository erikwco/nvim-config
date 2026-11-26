-- Persiste el estado de Snacks.toggle (<leader>u) entre reinicios.
-- LazyVim no lo guarda: cada toggle es solo de la sesión.

local M = {}

local path = vim.fn.stdpath("state") .. "/ui-toggles.json"

local skip = {
  background = true, -- Lo detecta Neovim desde la terminal en cada sesión.
  zen = true,
  zoom = true,
  profiler = true,
  profiler_highlights = true,
  -- util.ai_engine guarda ambos como una sola elección en ai-engine.json.
  sidekick_nes = true,
  supermaven = true,
}

local restoring = false

local function read()
  local f = io.open(path, "r")
  if not f then
    return {}
  end
  local raw = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, raw)
  if ok and type(data) == "table" then
    return data
  end
  return {}
end

local function write(data)
  vim.fn.mkdir(vim.fn.stdpath("state"), "p")
  local f = io.open(path, "w")
  if not f then
    return
  end
  f:write(vim.json.encode(data))
  f:close()
end

local function persist(id, state)
  if restoring or not id or skip[id] then
    return
  end
  local data = read()
  data[id] = state and true or false
  write(data)
end

function M.setup()
  if vim.g.ui_toggle_persist then
    return
  end
  vim.g.ui_toggle_persist = true

  local sample = Snacks.toggle.dim()
  local Toggle = getmetatable(sample)
  if not Toggle or Toggle._ui_persist then
    return
  end
  Toggle._ui_persist = true

  local orig_set = Toggle.set
  function Toggle:set(state)
    orig_set(self, state)
    persist(self.opts and self.opts.id, state)
  end

  local orig_toggle = Toggle.toggle
  function Toggle:toggle()
    orig_toggle(self)
    persist(self.opts and self.opts.id, self:get())
  end

  local data = read()
  -- Dimming on por defecto si nunca se ha guardado (es lo que activabas a mano).
  if data.dim == nil then
    data.dim = true
  end

  restoring = true
  for id, state in pairs(data) do
    if not skip[id] then
      local t = Snacks.toggle.get(id)
      if t and t:get() ~= state then
        t:set(state)
      end
    end
  end
  restoring = false
  write(data)
end

return M
