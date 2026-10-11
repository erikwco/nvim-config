# Trabajar con Elixir

## Preparar el entorno

1. Instala Elixir y una versión compatible de Erlang/OTP. En macOS: `brew install elixir`.
2. Ejecuta `mix local.hex --force` y `mix local.rebar --force` para instalar las herramientas de dependencias.
3. Abre Neovim. Lazy instala `neotest-elixir`, Mason instala `elixir-ls` y Treesitter instala `elixir`, `heex` y `eex`.
4. Desde la raíz de tu proyecto, ejecuta `mix deps.get` y abre un archivo `.ex` o `.exs` en Neovim.
5. Ejecuta `:checkhealth vim.lsp` y comprueba que `elixirls` está conectado al buffer.

La primera apertura puede tardar mientras ElixirLS compila el proyecto y prepara Dialyzer.
Las versiones fijadas por cada proyecto deben ser compatibles entre sí y estar disponibles en el `PATH` de Neovim.
Consulta la [tabla de compatibilidad de ElixirLS](https://github.com/elixir-lsp/elixir-ls#supported-elixir-and-otp-versions).

## Editar y ejecutar tests

- `gd`: ir a definición. `K`: documentación. `<leader>ca`: acciones de código.
- `<leader>cf`: formato con `mix format`. El formato al guardar sigue el ajuste general de LazyVim.
- `<leader>tn`: test bajo el cursor. `<leader>tf`: tests del archivo.
- `<leader>ts`: panel de tests. `<leader>to`: salida del test.
- Para ejecutar toda la suite: `:lua require("neotest").run.run(vim.fn.getcwd())` o `mix test` desde la raíz.
- `<leader>db`: breakpoint. `<leader>dc`: selecciona `mix test` o `mix run` para depurar.

Abre Neovim desde la carpeta que contiene `mix.exs` para que las configuraciones de depuración usen la raíz correcta.
La configuración está en [`lua/plugins/elixir.lua`](../lua/plugins/elixir.lua).

## Phoenix y HEEx

El resaltado incluye HEEx y EEx. Para formatear HEEx, el proyecto debe tener `phoenix_live_view`
y `Phoenix.LiveView.HTMLFormatter` en `plugins` dentro de `.formatter.exs`.
Phoenix, Credo y las conexiones a bases de datos se configuran en cada proyecto.

## Verificar la instalación

Ejecuta `sh ~/.config/nvim/scripts/check-elixir.sh` para comprobar LSP, formato,
tests y un breakpoint real en un proyecto temporal que se elimina al terminar.
La primera ejecución puede descargar y compilar dependencias de ElixirLS.

Para comprobar las herramientas por separado:

```sh
elixir --version
mix hex.info
mix new /tmp/elixir_check
cd /tmp/elixir_check
mix test
nvim lib/elixir_check.ex
```

En Neovim, `:ConformInfo` muestra `mix` como formatter disponible.
Si falta ElixirLS, ejecuta `:MasonInstall elixir-ls`.
Si falta el resaltado, ejecuta `:TSInstall elixir heex eex`.
