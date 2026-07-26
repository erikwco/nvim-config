-- ============================================================================
-- Helper propio de SSHFS compatible con fuse-t
-- ============================================================================
-- El plugin sshfs.nvim solo detecta mounts tipo "sshfs"/"macfuse", pero fuse-t
-- monta como NFS (`fuse-t:/... on /ruta (nfs, ...)`), así que no los reconoce.
-- Este helper hace lo mismo (montar host del ssh config, explorar, desmontar)
-- pero entiende los mounts de fuse-t. Sin depender de macFUSE.
--
-- Uso: require("util.sshfs").setup()  (se llama desde config/keymaps.lua)
-- Keymaps bajo <leader>S* (evita el <leader>m* de Maven).

local M = {}

local base_dir = vim.fn.expand("~/mnt")

-- Rutas remotas predefinidas por host (para no escribirlas cada vez).
-- Se cargan desde un archivo LOCAL gitignoreado (util/sshfs_hosts.lua) para no
-- publicar rutas internas en el repo público. Formato de ese archivo:
--   return {
--     ["mi-host"]  = "/ruta/unica",                 -- una ruta → monta directo
--     ["otro"]     = { "/ruta/a", "/ruta/b" },       -- varias → picker
--   }
local host_paths = {}
do
  local ok, presets = pcall(require, "util.sshfs_hosts")
  if ok and type(presets) == "table" then
    host_paths = presets
  end
end

-- Elige la ruta remota: preset único → directo; varias → picker; ninguno → input
local function choose_path(host, cb)
  local preset = host_paths[host]
  if preset == nil then
    vim.ui.input({ prompt = "Ruta remota (default = home): ", default = "." }, function(p)
      if p then
        cb(p == "" and "." or p)
      end
    end)
    return
  end
  if type(preset) == "string" then
    cb(preset) -- ruta única definida → sin prompt
    return
  end
  -- varias rutas → picker (+ opción de escribir otra)
  local items = vim.deepcopy(preset)
  table.insert(items, "✎ otra ruta…")
  vim.ui.select(items, { prompt = "Ruta en " .. host .. ":" }, function(choice)
    if not choice then
      return
    end
    if choice == "✎ otra ruta…" then
      vim.ui.input({ prompt = "Ruta remota: ", default = "." }, function(p)
        if p then
          cb(p == "" and "." or p)
        end
      end)
    else
      cb(choice)
    end
  end)
end

-- Ruta al binario sshfs (fuse-t). exepath respeta el PATH de nvim; si no está,
-- caemos a la ruta conocida de fuse-t-sshfs.
local function sshfs_bin()
  local p = vim.fn.exepath("sshfs")
  if p ~= "" then
    return p
  end
  return "/usr/local/bin/sshfs"
end

-- Socket de ControlMaster por host (~/.ssh/sockets/<host>.sock)
local socket_dir = vim.fn.expand("~/.ssh/sockets")
local function socket_for(host)
  return socket_dir .. "/" .. host:gsub("[^%w_.-]", "_") .. ".sock"
end

-- ── Leer hosts del ~/.ssh/config ────────────────────────────────────────────
local function ssh_hosts()
  local hosts = {}
  local path = vim.fn.expand("~/.ssh/config")
  local f = io.open(path, "r")
  if not f then
    return hosts
  end
  for line in f:lines() do
    local h = line:match("^%s*[Hh]ost%s+(.+)$")
    if h then
      for host in h:gmatch("%S+") do
        if not host:match("[*?]") then -- ignora wildcards (Host *)
          table.insert(hosts, host)
        end
      end
    end
  end
  f:close()
  return hosts
end

-- ── Mounts activos bajo ~/mnt (parseando `mount`, formato fuse-t/nfs) ────────
local function active_mounts()
  local result = vim.fn.system("mount")
  local mounts = {}
  for line in result:gmatch("[^\r\n]+") do
    -- fuse-t: "fuse-t:/remoto on /Users/erik/mnt/host (nfs, ...)"
    local src, path = line:match("^(%S+)%s+on%s+(.-)%s+%(")
    if path and path:find(base_dir, 1, true) == 1 then
      table.insert(mounts, { path = path, src = src })
    end
  end
  return mounts
end

-- ── Desmontar una ruta ──────────────────────────────────────────────────────
local function do_unmount(path, silent)
  vim.fn.system({ "umount", path })
  if vim.v.shell_error ~= 0 then
    -- fuse-t monta como NFS → diskutil suele funcionar mejor
    vim.fn.system({ "diskutil", "unmount", "force", path })
  end
  -- Cerrar la conexión maestra de ese host (el mount es ~/mnt/<host>)
  local host = path:match("/mnt/([^/]+)$")
  if host then
    local socket = socket_for(host)
    if vim.uv.fs_stat(socket) then
      vim.fn.system({ "ssh", "-S", socket, "-O", "exit", host })
    end
  end
  pcall(vim.fn.delete, path, "d") -- borra la carpeta vacía del mount
  if not silent then
    vim.notify("Desmontado: " .. path, vim.log.levels.INFO)
  end
end

-- ── Montar ──────────────────────────────────────────────────────────────────
-- Estrategia ControlMaster (robusta con fuse-t):
--   1. Abrir la conexión SSH MAESTRA en un terminal (ahí escribes el password).
--      Se va a background con -f → persiste independiente de nvim (no se muere
--      al cerrar el terminal, a diferencia de correr sshfs directo).
--   2. Montar sshfs REUSANDO ese socket → sin password, sin TTY → se detacha
--      limpio y el mount sobrevive el cierre del terminal.
function M.mount()
  local hosts = ssh_hosts()
  if #hosts == 0 then
    vim.notify("No hay hosts en ~/.ssh/config", vim.log.levels.WARN)
    return
  end
  vim.fn.mkdir(socket_dir, "p")
  vim.ui.select(hosts, { prompt = "SSHFS — elige host:" }, function(host)
    if not host then
      return
    end
    choose_path(host, function(remote_path)
      if not remote_path then
        return
      end
      local mnt = base_dir .. "/" .. host
      vim.fn.mkdir(mnt, "p") -- la carpeta debe pre-existir
      local socket = socket_for(host)

      -- Paso 2: montar reusando el socket maestro (sin password, se detacha bien)
      local function do_sshfs()
        local cmd = {
          sshfs_bin(),
          host .. ":" .. remote_path,
          mnt,
          "-o",
          "reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,compression=yes,ssh_command=ssh -S "
            .. socket,
        }
        local out = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
          vim.notify("sshfs falló:\n" .. out, vim.log.levels.ERROR)
          pcall(vim.fn.delete, mnt, "d")
          return
        end
        vim.notify("✓ Montado en " .. mnt, vim.log.levels.INFO)
        M.explore_path(mnt)
      end

      -- ¿Ya hay conexión maestra viva? → montar directo (sin re-pedir password)
      vim.fn.system({ "ssh", "-S", socket, "-O", "check", host })
      if vim.v.shell_error == 0 then
        do_sshfs()
        return
      end

      -- Paso 1: abrir la conexión maestra en terminal (password interactivo)
      vim.notify("Conectando a " .. host .. " — escribe el password si lo pide", vim.log.levels.INFO)
      vim.cmd("botright 12new")
      local term_win = vim.api.nvim_get_current_win()
      vim.fn.jobstart(
        { "ssh", "-M", "-S", socket, "-o", "ControlPersist=600", "-N", "-f", host },
        {
          term = true,
          on_exit = function(_, code)
            vim.schedule(function()
              if vim.api.nvim_win_is_valid(term_win) then
                vim.api.nvim_win_close(term_win, true)
              end
              if code == 0 then
                do_sshfs()
              else
                vim.notify(
                  "SSH falló (código " .. code .. "). Revisa el password o la conexión (¿VPN?).",
                  vim.log.levels.WARN
                )
                pcall(vim.fn.delete, mnt, "d")
              end
            end)
          end,
        }
      )
      vim.cmd("startinsert") -- para teclear el password
    end)
  end)
end

-- ── Abrir una ruta en el explorador (snacks) ────────────────────────────────
function M.explore_path(path)
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.explorer then
    snacks.explorer({ cwd = path })
  else
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end
end

-- ── Explorar un mount activo ────────────────────────────────────────────────
function M.explore()
  local mounts = active_mounts()
  if #mounts == 0 then
    vim.notify("No hay mounts SSHFS activos", vim.log.levels.WARN)
    return
  end
  if #mounts == 1 then
    M.explore_path(mounts[1].path)
    return
  end
  vim.ui.select(mounts, {
    prompt = "Explorar mount:",
    format_item = function(m)
      return m.path .. "  (" .. m.src .. ")"
    end,
  }, function(choice)
    if choice then
      M.explore_path(choice.path)
    end
  end)
end

-- ── Find files en un mount (snacks picker) ──────────────────────────────────
function M.find_files()
  local mounts = active_mounts()
  if #mounts == 0 then
    vim.notify("No hay mounts SSHFS activos", vim.log.levels.WARN)
    return
  end
  local function pick(path)
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then
      snacks.picker.files({ cwd = path })
    else
      vim.cmd("edit " .. vim.fn.fnameescape(path))
    end
  end
  if #mounts == 1 then
    pick(mounts[1].path)
    return
  end
  vim.ui.select(mounts, {
    prompt = "Buscar en mount:",
    format_item = function(m)
      return m.path
    end,
  }, function(choice)
    if choice then
      pick(choice.path)
    end
  end)
end

-- ── Desmontar (uno) ─────────────────────────────────────────────────────────
function M.unmount()
  local mounts = active_mounts()
  if #mounts == 0 then
    vim.notify("No hay mounts SSHFS activos", vim.log.levels.WARN)
    return
  end
  vim.ui.select(mounts, {
    prompt = "Desmontar:",
    format_item = function(m)
      return m.path .. "  (" .. m.src .. ")"
    end,
  }, function(choice)
    if choice then
      do_unmount(choice.path)
    end
  end)
end

-- ── Desmontar todos ─────────────────────────────────────────────────────────
function M.unmount_all(silent)
  local mounts = active_mounts()
  if #mounts == 0 then
    if not silent then
      vim.notify("No hay mounts SSHFS activos", vim.log.levels.INFO)
    end
    return
  end
  for _, m in ipairs(mounts) do
    do_unmount(m.path, true)
  end
  if not silent then
    vim.notify("Desmontados " .. #mounts .. " mount(s)", vim.log.levels.INFO)
  end
end

-- ── Setup: keymaps + auto-unmount al salir ──────────────────────────────────
function M.setup()
  local map = vim.keymap.set
  map("n", "<leader>Sm", M.mount, { desc = "SSHFS: montar host" })
  map("n", "<leader>Se", M.explore, { desc = "SSHFS: explorar mount" })
  map("n", "<leader>Sf", M.find_files, { desc = "SSHFS: buscar archivos" })
  map("n", "<leader>Su", M.unmount, { desc = "SSHFS: desmontar" })
  map("n", "<leader>SU", function()
    M.unmount_all(false)
  end, { desc = "SSHFS: desmontar todo" })
  map("n", "<leader>Sc", "<cmd>edit ~/.ssh/config<cr>", { desc = "SSHFS: editar ssh config" })

  -- Desmontar todo al salir de nvim (evita mounts colgados)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("sshfs_auto_unmount", { clear = true }),
    callback = function()
      M.unmount_all(true)
    end,
  })

  -- Comandos user por si prefieres :Sshfs*
  vim.api.nvim_create_user_command("SshfsMount", M.mount, {})
  vim.api.nvim_create_user_command("SshfsExplore", M.explore, {})
  vim.api.nvim_create_user_command("SshfsUnmount", M.unmount, {})
  vim.api.nvim_create_user_command("SshfsUnmountAll", function()
    M.unmount_all(false)
  end, {})
end

return M
