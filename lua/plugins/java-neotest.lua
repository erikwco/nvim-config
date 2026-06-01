-- neotest-java: adapter de Neotest para JUnit (5/4) y TestNG.
-- Requiere los bundles de java-debug-adapter y java-test (ver jdtls-lombok.lua).
-- Atajos genéricos de neotest (<leader>tn/tf/ta/ts/to) ya están en config/keymaps.lua.

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "rcasia/neotest-java",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(
        opts.adapters,
        require("neotest-java")({
          ignore_wrapper = false,
          incremental_build = true,
        })
      )
    end,
  },
}
