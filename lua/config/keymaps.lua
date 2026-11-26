-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Prefijos propios (los grupos de which-key están en plugins/which-key-groups.lua):
--   <leader>G  Gradle        <leader>m  Maven         <leader>T  Terminales
--   <leader>;  .NET          <leader>F  Flutter       <leader>A  AWS
--   <leader>M  SSHFS         <leader>j  Java/JDTLS    <leader>Q  Database
--   <leader>gv Diffview      <leader>1-3 terminales numeradas
-- Los grupos de LazyVim (<leader>c code, d debug, g git, s search, t test, u ui,
-- x diagnostics…) se dejan intactos. Referencia completa: docs/keymaps.md

local map = vim.keymap.set

-- =======================================================================================
-- Gradle (Spring Boot) — <leader>G*
-- =======================================================================================
-- Antes vivían en <leader>g* y pisaban el grupo git de LazyVim (<leader>gb = Git Blame).
local gradlew = "./gradlew"
map("n", "<leader>Gr", ":term " .. gradlew .. " bootRun<CR>", { desc = "Gradle: bootRun" })
map("n", "<leader>Gd", ":term " .. gradlew .. " bootRun --debug-jvm<CR>", { desc = "Gradle: bootRun --debug-jvm (:5005)" })
map("n", "<leader>Gh", ":split term://" .. gradlew .. " bootRun<CR>", { desc = "Gradle: bootRun (hsplit)" })
map("n", "<leader>GH", ":split term://" .. gradlew .. " bootRun --debug-jvm<CR>", { desc = "Gradle: bootRun --debug-jvm (hsplit)" })
map("n", "<leader>Gv", ":vsplit term://" .. gradlew .. " bootRun<CR>", { desc = "Gradle: bootRun (vsplit)" })
map("n", "<leader>Gb", ":term " .. gradlew .. " build<CR>", { desc = "Gradle: build" })
map("n", "<leader>Gc", ":term " .. gradlew .. " clean<CR>", { desc = "Gradle: clean" })
map("n", "<leader>Gt", ":term " .. gradlew .. " test<CR>", { desc = "Gradle: test" })

-- =======================================================================================
-- Maven (Spring Boot) — <leader>m*
-- =======================================================================================
-- <leader>mr  → spring-boot:run
-- <leader>md  → spring-boot:run con JDWP escuchando en :5005 (attach con DAP "Attach to remote JVM")
-- <leader>mh  → spring-boot:run en split horizontal
-- <leader>mb  → package
-- <leader>mt  → test
-- <leader>mc  → clean
-- <leader>mi  → clean install -DskipTests   (antes <leader>mci: chocaba con <leader>mc)
-- <leader>mp  → spring-boot:run en un módulo específico (multi-módulo)
local mvn = "./mvnw"
map("n", "<leader>mr", ":term " .. mvn .. " spring-boot:run<CR>", { desc = "Maven: spring-boot:run" })
map(
  "n",
  "<leader>md",
  ":term "
    .. mvn
    .. [[ spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"<CR>]],
  { desc = "Maven: spring-boot:run + JDWP :5005" }
)
map("n", "<leader>mh", ":split term://" .. mvn .. " spring-boot:run<CR>", { desc = "Maven: spring-boot:run (hsplit)" })
map("n", "<leader>mb", ":term " .. mvn .. " package<CR>", { desc = "Maven: package" })
map("n", "<leader>mt", ":term " .. mvn .. " test<CR>", { desc = "Maven: test" })
map("n", "<leader>mc", ":term " .. mvn .. " clean<CR>", { desc = "Maven: clean" })
map("n", "<leader>mi", ":term " .. mvn .. " clean install -DskipTests<CR>", { desc = "Maven: clean install -DskipTests" })
map("n", "<leader>mp", function()
  vim.ui.input({ prompt = "Módulo (-pl): " }, function(mod)
    if mod and #mod > 0 then
      vim.cmd("term " .. mvn .. " -pl " .. mod .. " spring-boot:run -am")
    end
  end)
end, { desc = "Maven: spring-boot:run en módulo" })

-- =======================================================================================
-- Tests: los atajos <leader>t* los pone el extra `test.core` de LazyVim
-- (tr nearest, tt archivo, tT todos, tl último, ts summary, to output, td debug nearest…)
-- =======================================================================================

-- =======================================================================================
-- Diagnósticos: toggle temporal SOLO del buffer actual (<leader>ud es el global de LazyVim)
-- =======================================================================================
Snacks.toggle({
  name = "Diagnostics (buffer)",
  get = function()
    return vim.diagnostic.is_enabled({ bufnr = 0 })
  end,
  set = function(state)
    vim.diagnostic.enable(state, { bufnr = 0 })
  end,
}):map("<leader>ux")

-- =======================================================================================
-- DAP: teclas de función estilo IDE (los <leader>d* los pone el extra dap.core)
-- =======================================================================================
map("n", "<F5>", "<cmd>DapContinue<cr>", { desc = "Debug: Continue" })
map("n", "<F9>", "<cmd>DapToggleBreakpoint<cr>", { desc = "Debug: Toggle breakpoint" })
map("n", "<F10>", "<cmd>DapStepOver<cr>", { desc = "Debug: Step over" })
map("n", "<F11>", "<cmd>DapStepInto<cr>", { desc = "Debug: Step into" })
map("n", "<S-F11>", "<cmd>DapStepOut<cr>", { desc = "Debug: Step out" })

-- =======================================================================================
-- Ventanas: redimensionar con Ctrl+Shift+h/j/k/l
-- =======================================================================================
-- Los <C-flechas> de LazyVim nunca llegan a Neovim en macOS (Mission Control se los
-- queda). Ghostty distingue Ctrl+Shift+letra (protocolo kitty). Se mapean también en
-- modo terminal (<cmd> no sale del modo), así funcionan dentro de Sidekick o una
-- terminal mientras escribes. Sin Shift (<C-hjkl>) te mueves; con Shift redimensionas.
-- Alternativa sin remapeo: <C-w><space> (modo hydra) y luego > < + - repetidos.
for key, cmd in pairs({ h = "vertical resize -3", l = "vertical resize +3", j = "resize -3", k = "resize +3" }) do
  map({ "n", "t" }, "<C-S-" .. key .. ">", "<cmd>" .. cmd .. "<cr>", { desc = "Ventana: " .. cmd })
end

-- =======================================================================================
-- Terminales (Snacks.terminal) — <leader>1/2/3 y <leader>T*
-- =======================================================================================
-- Snacks identifica cada terminal por cmd + cwd + env + count (NO por posición), así que:
--   <leader>1 / 2 / 3 → terminales numeradas abajo, en la raíz del proyecto.
--                       Son las mismas que 1<C-/>, 2<C-/>, 3<C-/> de LazyVim.
--   <leader>Ts        → terminal lateral (instancia propia, identificada por env).
--   <leader>Tl / Tv   → enviar la línea actual / la selección a la terminal 1 (REPLs).
-- Dentro de una terminal: <Esc><Esc> vuelve a modo normal, q la oculta.
local function root_terminal(n)
  return function()
    Snacks.terminal.toggle(nil, {
      cwd = LazyVim.root(),
      count = n,
      win = { position = "bottom", height = 0.3, title = "terminal " .. n, title_pos = "center" },
    })
  end
end
map("n", "<leader>1", root_terminal(1), { desc = "Terminal 1 (root)" })
map("n", "<leader>2", root_terminal(2), { desc = "Terminal 2 (root)" })
map("n", "<leader>3", root_terminal(3), { desc = "Terminal 3 (root)" })

map("n", "<leader>Ts", function()
  Snacks.terminal.toggle(nil, {
    cwd = LazyVim.root(),
    env = { NVIM_TERMINAL = "side" }, -- la distingue de las numeradas
    win = { position = "right", width = 0.4, title = "side-terminal", title_pos = "center" },
  })
end, { desc = "Terminal lateral" })

local function send_to_terminal_1(text)
  local term = Snacks.terminal.get(nil, {
    cwd = LazyVim.root(),
    count = 1,
    win = { position = "bottom", height = 0.3, title = "terminal 1", title_pos = "center" },
  })
  local chan = term and vim.bo[term.buf].channel or 0
  if chan == 0 then
    vim.notify("La terminal 1 no tiene un canal activo", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_chan_send(chan, text .. "\n")
end
map("n", "<leader>Tl", function()
  send_to_terminal_1(vim.api.nvim_get_current_line())
end, { desc = "Enviar línea a terminal 1" })
map("x", "<leader>Tv", function()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  send_to_terminal_1(table.concat(lines, "\n"))
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Enviar selección a terminal 1" })

-- =======================================================================================
-- Encoding / charset — ver, reabrir y convertir archivos (legacy cp1252/latin1)
-- =======================================================================================
-- El encoding vive siempre visible en la statusline (ver plugins/lualine.lua).
--   :Reopen <enc>  → re-lee el MISMO archivo con otro charset (NO lo modifica,
--                    solo cómo se interpreta) — para arreglar "mojibake"/basura.
--   <leader>ce     → picker para reabrir con un charset de la lista.
--   <leader>c8     → convierte el archivo a UTF-8 y lo guarda.
local common_encodings = { "utf-8", "cp1252", "latin1", "utf-16le", "utf-16", "cp850", "iso-8859-1" }

-- :Reopen cp1252   (autocompleta con <Tab>)
vim.api.nvim_create_user_command("Reopen", function(o)
  vim.cmd("edit ++enc=" .. o.args)
end, {
  nargs = 1,
  complete = function(lead)
    return vim.tbl_filter(function(e)
      return e:find(lead, 1, true) == 1
    end, common_encodings)
  end,
  desc = "Reabrir el archivo actual con un encoding específico",
})

-- <leader>ce → elegir encoding de un picker y reabrir con él
map("n", "<leader>ce", function()
  vim.ui.select(common_encodings, { prompt = "Reabrir con encoding:" }, function(enc)
    if enc then
      vim.cmd("edit ++enc=" .. enc)
    end
  end)
end, { desc = "Encoding: reabrir con…" })

-- <leader>c8 → convertir el archivo a UTF-8 y guardarlo
map("n", "<leader>c8", function()
  vim.cmd("setlocal fileencoding=utf-8")
  vim.cmd("write")
  vim.notify("Guardado como UTF-8", vim.log.levels.INFO)
end, { desc = "Encoding: convertir a UTF-8 y guardar" })

-- =======================================================================================
-- SSHFS (fuse-t) — montar carpetas remotas por SSH. Helper propio compatible
-- con fuse-t (el plugin sshfs.nvim no lo soporta; ver lua/util/sshfs.lua).
-- Keymaps: <leader>Mm montar, <leader>Me explorar, <leader>Mf files,
--          <leader>Mu desmontar, <leader>MU desmontar todo, <leader>Mc config.
-- =======================================================================================
require("util.sshfs").setup()
