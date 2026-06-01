-- JDTLS (Java) con Lombok + bundles de debug y test.
-- Los bundles de java-debug-adapter y java-test son los que permiten:
--   * DAP real con breakpoints en Java/Spring Boot
--   * Correr JUnit desde Neovim (vía nvim-jdtls o neotest-java)
-- Sin esos bundles, dap.continue() en Java NO funciona.

return {
  -- 1) Asegurar que Mason instale los bundles
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "jdtls",
        "java-debug-adapter",
        "java-test",
        "google-java-format",
      })
    end,
  },

  -- 2) JDTLS
  {
    "mfussenegger/nvim-jdtls",
    dependencies = {
      "folke/which-key.nvim",
      "mfussenegger/nvim-dap",
    },
    ft = "java",
    opts = function()
      local home = os.getenv("HOME")
      local mason_path = vim.fn.glob(home .. "/.local/share/nvim/mason/")
      local jdtls_path = mason_path .. "packages/jdtls/"

      -- ============================================================
      -- Java runtimes (instalados vía mise)
      -- ============================================================
      -- IMPORTANTE: JDTLS DEBE arrancarse con un Java >= 17. Si usamos el
      -- `java` del PATH, mise puede resolverlo a la versión que pinea el
      -- proyecto (p.ej. un legacy con Java 8), y JDTLS crashea con
      -- "Unrecognized option: --add-modules=ALL-SYSTEM".
      -- Por eso fijamos un launcher explícito (temurin-21).
      local mise_java = home .. "/.local/share/mise/installs/java/"
      local function java_home(name)
        local p = mise_java .. name
        return (vim.uv or vim.loop).fs_stat(p) and p or nil
      end

      -- Launcher de JDTLS: primer Java >= 17 que exista.
      local launcher_home = java_home("temurin-21") or java_home("oracle-17")
      local java_bin = launcher_home and (launcher_home .. "/bin/java") or "java"

      -- Runtimes que JDTLS ofrece a los proyectos (compilación/ejecución).
      -- Cada proyecto usa el que corresponda a su sourceCompatibility.
      local runtimes = {}
      local runtime_map = {
        { name = "JavaSE-21", dir = "temurin-21" },
        { name = "JavaSE-17", dir = "oracle-17" },
        { name = "JavaSE-11", dir = "zulu-11" },
        { name = "JavaSE-1.8", dir = "zulu-8" },
      }
      for _, rt in ipairs(runtime_map) do
        local h = java_home(rt.dir)
        if h then
          table.insert(runtimes, { name = rt.name, path = h })
        end
      end

      local root_markers = {
        ".git",
        "mvnw",
        "gradlew",
        "pom.xml",
        "build.gradle",
        "build.gradle.kts",
      }
      local root_dir = require("jdtls.setup").find_root(root_markers)
      local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
      local workspace_dir = home .. "/.cache/jdtls-workspace/" .. project_name

      -- Detectar config de SO automáticamente (mac arm / mac intel / linux / win)
      local config_dir = "config_linux"
      if vim.fn.has("mac") == 1 then
        if vim.fn.has("macunix") == 1 and vim.fn.system("uname -m"):match("arm64") then
          config_dir = "config_mac_arm"
        else
          config_dir = "config_mac"
        end
      elseif vim.fn.has("win32") == 1 then
        config_dir = "config_win"
      end

      -- Bundles: debug + test
      local bundles = {}
      -- java-debug-adapter
      local jd_path = mason_path .. "packages/java-debug-adapter/extension/server/"
      vim.list_extend(bundles, vim.split(vim.fn.glob(jd_path .. "com.microsoft.java.debug.plugin-*.jar", 1), "\n", { trimempty = true }))
      -- java-test (varios jars en server/)
      local jt_path = mason_path .. "packages/java-test/extension/server/"
      vim.list_extend(bundles, vim.split(vim.fn.glob(jt_path .. "*.jar", 1), "\n", { trimempty = true }))

      local config = {
        cmd = {
          java_bin, -- Java >= 17 fijo (temurin-21), no el del PATH/mise del proyecto
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xms1g",
          "-javaagent:" .. jdtls_path .. "lombok.jar",
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
          "-jar",
          vim.fn.glob(jdtls_path .. "plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration",
          jdtls_path .. config_dir,
          "-data",
          workspace_dir,
        },
        root_dir = root_dir,
        settings = {
          java = {
            configuration = {
              runtimes = runtimes, -- 8/11/17/21 detectados desde mise
            },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" }, -- decompiler
            completion = {
              favoriteStaticMembers = {
                "org.hamcrest.MatcherAssert.assertThat",
                "org.hamcrest.Matchers.*",
                "org.hamcrest.CoreMatchers.*",
                "org.junit.jupiter.api.Assertions.*",
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
                "org.mockito.Mockito.*",
              },
              importOrder = { "java", "javax", "com", "org" },
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            codeGeneration = {
              toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
              },
              useBlocks = true,
            },
            references = { includeDecompiledSources = true },
            inlayHints = { parameterNames = { enabled = "all" } },
          },
        },
        init_options = {
          bundles = bundles,
        },
        -- on_attach: arrancar DAP con autodiscovery de main classes y tests
        on_attach = function(client, bufnr)
          local jdtls = require("jdtls")
          jdtls.setup_dap({ hotcodereplace = "auto" })

          -- Descubre las clases con main() y registra dap.configurations.java
          require("jdtls.dap").setup_dap_main_class_configs()

          -- Keymaps específicos de JDTLS (buffer-local)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
          end
          map("<leader>jo", jdtls.organize_imports, "JDTLS: Organize Imports")
          map("<leader>jv", jdtls.extract_variable, "JDTLS: Extract Variable")
          map("<leader>jc", jdtls.extract_constant, "JDTLS: Extract Constant")
          map("<leader>jm", jdtls.extract_method, "JDTLS: Extract Method")
          map("<leader>jtc", function() jdtls.test_class() end, "JDTLS: Test Class")
          map("<leader>jtm", function() jdtls.test_nearest_method() end, "JDTLS: Test Nearest Method")
          map("<leader>juc", function() jdtls.update_project_config() end, "JDTLS: Update Project Config")

          vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end, { buffer = bufnr, desc = "JDTLS: Extract Variable (visual)" })
          vim.keymap.set("v", "<leader>jc", function() jdtls.extract_constant(true) end, { buffer = bufnr, desc = "JDTLS: Extract Constant (visual)" })
          vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end, { buffer = bufnr, desc = "JDTLS: Extract Method (visual)" })
        end,
      }
      return config
    end,
    config = function(_, opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          require("jdtls").start_or_attach(opts)
        end,
      })
    end,
  },
}
