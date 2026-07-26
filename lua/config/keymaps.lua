-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- =======================================================================================
-- Gradle execution
-- =======================================================================================
vim.keymap.set("n", "<leader>gr", ":term ./gradlew bootRun<CR>", { desc = "Run Gradle SpringBoot Project" })
vim.keymap.set(
  "n",
  "<leader>dgr",
  ":term ./gradlew bootRun --debug-jvm<CR>",
  { desc = "Run Gradle SpringBoot Project" }
)
vim.keymap.set(
  "n",
  "<leader>hgr",
  ":split term://./gradlew bootRun<CR>",
  { desc = "Run Gradle SpringBoot Project Horizontally splitted" }
)
vim.keymap.set(
  "n",
  "<leader>hgrd",
  ":split term://./gradlew bootRun --debug-jvm<CR>",
  { desc = "Run Gradle SpringBoot Project Horizontally splitted" }
)
vim.keymap.set(
  "n",
  "<leader>vgr",
  ":vsplit term://./gradlew bootRun<CR>",
  { desc = "Run Gradle SpringBoot Project Vertically splitted" }
)

-- =======================================================================================
-- Gradle build, test and clean
-- =======================================================================================
vim.keymap.set("n", "<leader>gb", ":term ./gradlew build<CR>", { desc = "Build Gradle SpringBoot Project" })
vim.keymap.set("n", "<leader>gc", ":term ./gradlew clean<CR>", { desc = "Clean Gradle SpringBoot Project" })
vim.keymap.set("n", "<leader>gt", ":term ./gradlew test<CR>", { desc = "Test Gradle SpringBoot Project" })

-- =======================================================================================
-- Maven execution (Spring Boot)
-- =======================================================================================
-- <leader>mr  → spring-boot:run
-- <leader>mdr → spring-boot:run con JDWP escuchando en :5005 (attach con DAP "Attach to remote JVM")
-- <leader>mb  → package
-- <leader>mt  → test
-- <leader>mc  → clean
-- <leader>mci → clean install -DskipTests
-- <leader>mp  → spring-boot:run en un módulo específico (multi-módulo)
local mvn = "./mvnw"
vim.keymap.set("n", "<leader>mr", ":term " .. mvn .. " spring-boot:run<CR>", { desc = "Maven: spring-boot:run" })
vim.keymap.set(
  "n",
  "<leader>mdr",
  ":term " .. mvn .. [[ spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"<CR>]],
  { desc = "Maven: spring-boot:run + JDWP :5005" }
)
vim.keymap.set("n", "<leader>mb", ":term " .. mvn .. " package<CR>", { desc = "Maven: package" })
vim.keymap.set("n", "<leader>mt", ":term " .. mvn .. " test<CR>", { desc = "Maven: test" })
vim.keymap.set("n", "<leader>mc", ":term " .. mvn .. " clean<CR>", { desc = "Maven: clean" })
vim.keymap.set(
  "n",
  "<leader>mci",
  ":term " .. mvn .. " clean install -DskipTests<CR>",
  { desc = "Maven: clean install" }
)
vim.keymap.set("n", "<leader>mp", function()
  vim.ui.input({ prompt = "Módulo (-pl): " }, function(mod)
    if mod and #mod > 0 then
      vim.cmd("term " .. mvn .. " -pl " .. mod .. " spring-boot:run -am")
    end
  end)
end, { desc = "Maven: spring-boot:run en módulo" })
vim.keymap.set(
  "n",
  "<leader>hmr",
  ":split term://" .. mvn .. " spring-boot:run<CR>",
  { desc = "Maven run (hsplit)" }
)

-- Mapeos para Neotest
vim.keymap.set("n", "<leader>tn", function()
  require("neotest").run.run() -- test "nearest" (bajo el cursor)
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%")) -- todos los tests del archivo actual
end, { desc = "Run file tests" })

vim.keymap.set("n", "<leader>ta", function()
  require("neotest").run.run("./...") -- todos los tests del módulo/proyecto
end, { desc = "Run all tests" })

vim.keymap.set("n", "<leader>ts", function()
  require("neotest").summary.toggle() -- abre/cierra panel de resumen
end, { desc = "Toggle test summary" })

vim.keymap.set("n", "<leader>to", function()
  require("neotest").output.open({ enter = true }) -- abre salida del test seleccionado
end, { desc = "Open test output" })

-- =======================================================================================
-- locales
-- =======================================================================================
local map = vim.keymap.set

-- LSP
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Go to Def" })
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "Refs" })
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "Hover" })
map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })

-- Format (Conform)
map("n", "<leader>cf", function()
  require("conform").format({ async = true })
end, { desc = "Format file" })

-- Lint
map("n", "<leader>cl", function()
  require("lint").try_lint()
end, { desc = "Run Linter" })

-- DAP
map("n", "<F5>", "<cmd>DapContinue<cr>", { desc = "Debug Continue" })
map("n", "<F9>", "<cmd>DapToggleBreakpoint<cr>", { desc = "Toggle BP" })
map("n", "<F10>", "<cmd>DapStepOver<cr>", { desc = "Step Over" })
map("n", "<F11>", "<cmd>DapStepInto<cr>", { desc = "Step Into" })
map("n", "<S-F11>", "<cmd>DapStepOut<cr>", { desc = "Step Out" })
map("n", "<leader>dt", function()
  require("dap-go").debug_test()
end, { desc = "Debug Test" })

-- terminal
-- <leader>th → terminal horizontal abajo (30% de altura)
map("n", "<leader>th", function()
  Snacks.terminal.toggle(nil, {
    win = {
      position = "bottom",
      height = 0.3,
      border = "rounded",
      title = "dev-terminal",
      title_pos = "center",
    },
  })
end, { desc = "Terminal (bottom)" })

-- <leader>D → terminal lateral (split vertical a la derecha, 40% de ancho)
-- Recreado: era un default de LazyVim/Snacks que se perdió en algún update.
map("n", "<leader>D", function()
  Snacks.terminal.toggle(nil, {
    win = {
      position = "right",
      width = 0.4,
      border = "rounded",
      title = "side-terminal",
      title_pos = "center",
    },
  })
end, { desc = "Terminal (side panel)" })

-- <leader>tv → alias semántico de <leader>D (Terminal Vertical, por consistencia)
map("n", "<leader>tv", function()
  Snacks.terminal.toggle(nil, {
    win = {
      position = "right",
      width = 0.4,
      border = "rounded",
      title = "side-terminal",
      title_pos = "center",
    },
  })
end, { desc = "Terminal (vertical side)" })

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
-- Keymaps: <leader>Sm montar, <leader>Se explorar, <leader>Sf files,
--          <leader>Su desmontar, <leader>SU desmontar todo, <leader>Sc config.
-- =======================================================================================
require("util.sshfs").setup()
