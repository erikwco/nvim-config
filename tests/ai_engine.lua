-- Run: nvim --headless -u NONE -i NONE -l tests/ai_engine.lua
-- Uses installed plugins with isolated state and local substitutes for AI servers.
local script = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")
local root = vim.fn.fnamemodify(script, ":h:h")

local function child()
  local plugins = vim.env.AI_TEST_PLUGINS
  vim.opt.rtp:prepend(root)
  vim.opt.rtp:prepend(plugins .. "/lazy.nvim")
  vim.opt.rtp:append(plugins .. "/nvim-lspconfig")
  vim.o.loadplugins = true
  vim.g.mapleader = " "
  LazyVim = { cmp = { actions = {} } }

  local copilot_starts = 0
  vim.lsp.config("copilot", {
    filetypes = { "ai_test" },
    root_dir = function(_, on_dir)
      on_dir(root)
    end,
    -- Exercise Neovim's actual client lifecycle without credentials or network.
    cmd = function(dispatchers)
      assert(vim.g.ai_engine == "nes", "Copilot started while NES was disabled")
      assert(not require("util.ai_engine").supermaven_running(), "Supermaven must stop before Copilot starts")
      copilot_starts = copilot_starts + 1
      local closing, request_id = false, 0
      local function close()
        if closing then
          return
        end
        closing = true
        vim.schedule(function()
          dispatchers.on_exit(0, 0)
        end)
      end
      return {
        request = function(method, _, callback)
          request_id = request_id + 1
          vim.schedule(function()
            callback(nil, method == "initialize" and { capabilities = {} } or nil)
          end)
          return true, request_id
        end,
        notify = function(method)
          if method == "exit" then
            close()
          end
          return true
        end,
        is_closing = function()
          return closing
        end,
        terminate = close,
      }
    end,
  })

  package.preload["supermaven-nvim.binary.binary_handler"] = function()
    return {
      running = false,
      is_running = function(self)
        return self.running
      end,
      start_binary = function(self)
        assert(not require("sidekick.nes").enabled, "NES must stop before Supermaven starts")
        assert(not vim.lsp.is_enabled("copilot"), "Copilot must be disabled before Supermaven starts")
        self.running = true
      end,
      stop_binary = function(self)
        self.running = false
      end,
      on_update = function() end,
    }
  end

  dofile(root .. "/lua/config/options.lua")
  local sidekick, lspconfig
  for _, spec in ipairs(dofile(root .. "/lua/plugins/sidekick.lua")) do
    if spec[1] == "folke/sidekick.nvim" then
      sidekick = spec
    elseif spec[1] == "neovim/nvim-lspconfig" then
      lspconfig = spec
    end
  end
  local lsp_opts = {}
  lspconfig.opts(nil, lsp_opts)
  assert(lsp_opts.setup.copilot("copilot", lsp_opts.servers.copilot), "Mason must not auto-enable Copilot")
  local supermaven = dofile(root .. "/lua/plugins/go-supermaven.lua")[1]
  require("lazy").setup({
    { dir = plugins .. "/snacks.nvim", opts = { toggle = { notify = false, which_key = false } } },
    sidekick,
    supermaven,
  }, {
    root = plugins,
    defaults = { lazy = false },
    lockfile = vim.fn.stdpath("state") .. "/test-lock.json",
    install = { missing = false },
    checker = { enabled = false },
    change_detection = { enabled = false },
  })
  require("lazy").load({ plugins = { "sidekick.nvim" } })
  vim.cmd("setfiletype ai_test")
  -- Flush Sidekick's scheduled initialization and the config's restore callback.
  vim.wait(100, function()
    return false
  end)
  require("util.toggle_persist").setup()

  local engine = require("util.ai_engine")
  local function check(expected)
    assert(vim.g.ai_engine == expected, "expected " .. expected .. ", got " .. tostring(vim.g.ai_engine))
    assert(engine.nes_enabled() == (expected == "nes"), "incorrect NES state")
    assert(engine.supermaven_running() == (expected == "supermaven"), "incorrect Supermaven state")
    assert(vim.lsp.is_enabled("copilot") == (expected == "nes"), "incorrect Copilot autostart state")
    assert(
      vim.wait(1000, function()
        local clients = vim.lsp.get_clients({ name = "copilot" })
        if expected == "nes" then
          return #clients == 1 and clients[1].initialized and vim.lsp.buf_is_attached(0, clients[1].id)
        end
        return #clients == 0
      end, 10),
      "incorrect Copilot client lifecycle"
    )
    assert((vim.fn.maparg("<C-j>", "i") ~= "") == (expected == "supermaven"), "incorrect accept-word mapping")
    assert((vim.fn.maparg("<C-]>", "i") ~= "") == (expected == "supermaven"), "incorrect dismiss mapping")
  end
  check(vim.env.AI_TEST_BEFORE)
  assert(copilot_starts == (vim.env.AI_TEST_BEFORE == "nes" and 1 or 0), "unexpected Copilot startup")
  if vim.env.AI_TEST_KEY then
    local mapping = vim.fn.maparg(" " .. vim.env.AI_TEST_KEY, "n", false, true)
    assert(type(mapping.callback) == "function", "missing toggle mapping")
    mapping.callback()
    check(vim.env.AI_TEST_AFTER)
    local saved = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("state") .. "/ai-engine.json"), "\n"))
    assert(saved == vim.env.AI_TEST_AFTER, "choice was not saved")
  end
  -- Restoring the same choice and opening another buffer must not start a second server.
  local starts = copilot_starts
  engine.restore()
  vim.cmd.enew()
  vim.cmd("setfiletype ai_test")
  check(vim.env.AI_TEST_AFTER)
  assert(copilot_starts == starts, "Copilot restarted unnecessarily")
  -- The generic boolean toggles must not overwrite the engine preference.
  local ui_state = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("state") .. "/ui-toggles.json"), "\n"))
  assert(ui_state.sidekick_nes == nil and ui_state.supermaven == nil, "AI state has two owners")
  assert(vim.v.errmsg == "", vim.v.errmsg)
  vim.lsp.enable("copilot", false)
end

if vim.env.AI_TEST_CHILD == "1" then
  child()
  return
end

local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")
local plugins = vim.fn.stdpath("data") .. "/lazy"
local function session(before, key, after)
  local result = vim
    .system({ vim.v.progpath, "--headless", "-u", "NONE", "-i", "NONE", "-l", script }, {
      cwd = root,
      text = true,
      env = {
        AI_TEST_CHILD = "1",
        AI_TEST_PLUGINS = plugins,
        AI_TEST_BEFORE = before,
        AI_TEST_KEY = key or "",
        AI_TEST_AFTER = after or before,
        XDG_STATE_HOME = temp .. "/state",
        XDG_CACHE_HOME = temp .. "/cache",
        NVIM_LOG_FILE = temp .. "/nvim.log",
      },
    })
    :wait(10000)
  assert(result.code == 0, result.stdout .. result.stderr)
  print("PASS: restart as " .. before .. (key and (", " .. key .. " -> " .. after) or ""))
end

local ok, err = pcall(function()
  session("nes")
  session("nes", "uM", "supermaven")
  session("supermaven", "uM", "off")
  session("off", "uN", "nes")
  session("nes", "uN", "off")
  session("off", "ue", "nes")
  session("nes", "ue", "supermaven")
  session("supermaven", "ue", "nes")
  session("nes", "uM", "supermaven")
  session("supermaven", "uN", "nes")
  session("nes")

  local state = temp .. "/state/" .. (vim.env.NVIM_APPNAME or "nvim") .. "/ai-engine.json"
  for _, invalid in ipairs({ "invalid json", '"unknown"', "{}", "null", "true" }) do
    vim.fn.writefile({ invalid }, state)
    session("nes")
  end
end)
vim.fn.delete(temp, "rf")
assert(ok, err)
print("AI engine persistence and Copilot lifecycle checks passed")
