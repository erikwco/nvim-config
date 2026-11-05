-- neotest-java: adapter de Neotest para JUnit (5/4) y TestNG.
-- Requiere los bundles de java-debug-adapter y java-test (ver jdtls-lombok.lua).
-- Atajos <leader>t* del extra test.core (tr nearest, tt archivo, td debug…).
return {
  {
    "nvim-neotest/neotest",
    dependencies = { "rcasia/neotest-java" },
    opts = {
      adapters = {
        ["neotest-java"] = {
          ignore_wrapper = false,
          incremental_build = true,
        },
      },
    },
  },
}
