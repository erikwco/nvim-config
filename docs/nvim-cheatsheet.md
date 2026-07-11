# Neovim Dev Cheatsheet — C# · Go · Java · React/TS · Rust · Flutter

> Referencia de mi config LazyVim: LSP, debug, tests, folds, terminales, REST,
> DB, Flutter y más. Setup base: Roslyn/gopls/JDTLS/dartls/rust-analyzer +
> easy-dotnet + kulala + vim-dadbod + nvim-ufo.
> Última actualización: 2026-07-11.

---

## 📑 Índice

1. [Navegación de código (LSP)](#-navegación-de-código-lsp)
2. [Autocompletion](#-autocompletion)
3. [Diagnósticos / errores](#-diagnósticos--errores)
4. [Folds (plegado de código)](#-folds-plegado-de-código)
5. [Terminales](#-terminales)
6. [REST Client (kulala — .http files)](#-rest-client-kulala--http-files)
7. [Database (vim-dadbod-ui)](#️-database-vim-dadbod-ui)
8. [Flutter / Dart](#-flutter--dart)
9. [Build / Run / Test / Watch](#️-build--run--test--watch)
10. [Publish multi-plataforma](#-publish-multi-plataforma)
11. [Debug (DAP + netcoredbg)](#-debug-dap--netcoredbg)
12. [Tests](#-tests)
13. [Operaciones de proyecto y paquetes NuGet](#-operaciones-de-proyecto-y-paquetes-nuget)
14. [Comandos de Roslyn LSP](#-comandos-de-roslyn-lsp)
15. [User Secrets](#-user-secrets)
16. [Formato (csharpier)](#-formato-csharpier)
17. [Workflows típicos](#-workflows-típicos)
18. [Troubleshooting](#-troubleshooting)
19. [Convenciones de teclas](#️-convenciones-de-teclas)
20. [Archivos de configuración](#-archivos-de-configuración)

---

## 🧭 Navegación de código (LSP)

| Tecla | Acción |
|---|---|
| `gd` | Ir a definición |
| `gr` | Referencias |
| `gI` | Implementaciones |
| `gy` | Type definition |
| `K` | Hover (documentación, tipo del símbolo) |
| `<leader>rn` | Rename símbolo (renombra en todo el proyecto) |
| `<leader>ca` | Code actions (autoimport, quick fixes, refactors) |
| `<leader>cs` | Document symbols (outline) |
| `<leader>cS` | Workspace symbols (busca en todo el proyecto) |
| `<C-o>` / `<C-i>` | Volver atrás / adelante en la pila de saltos |
| `gx` | Abrir URL bajo el cursor |

> **Tip**: para ver la documentación de un método externo (ej. del SDK), pon el cursor sobre el nombre y presiona `K` dos veces (la segunda vez te lleva DENTRO del float para hacer scroll).

---

## ✨ Autocompletion

Provider: **blink.cmp** + **Roslyn LSP**.

### Cómo se ve

| Ícono | Tipo |
|---|---|
| `M f` | Método / función |
| `P` | Propiedad |
| `F` | Field |
| `C ` | Clase |
| `S ` | Struct |
| `I` | Interface |
| `E` | Enum |
| `K` | Keyword |
| `abc` | **⚠️ Buffer source** (texto literal — significa que LSP no respondió, ver troubleshooting) |

### Atajos en el menú de completion

| Tecla | Acción |
|---|---|
| `<C-Space>` | Abrir / forzar el menú de completion manualmente |
| `<C-n>` / `<C-p>` | Siguiente / anterior |
| `<CR>` | Aceptar |
| `<C-e>` | Cerrar / cancelar |
| `<C-x><C-o>` | Forzar **solo** completion del LSP (omnicomplete nativo de Vim) |
| `<Tab>` | Aceptar sugerencia inline de **Supermaven** (AI) — distinto del menú |

### Autoimport

Cuando uses una clase no importada:
- **Si está en `<ImplicitUsings>enable</ImplicitUsings>`**: Roslyn la conoce y la sugiere directamente — `<CR>` la inserta sin tocar usings.
- **Si NO está**: aparece en el menú con la nota "(en `Namespace.X`)". Al aceptar, Roslyn **añade el `using` automáticamente** arriba.
- **Si no aparece**: `<leader>ca` → te lista las acciones "Using …" / "Add reference".

### Implicit usings (.NET 6+)

Con `<ImplicitUsings>enable</ImplicitUsings>` en el `.csproj`, el SDK inyecta `using`s comunes según el tipo de proyecto:

| SDK | Usings implícitos típicos |
|---|---|
| `Microsoft.NET.Sdk` (console/lib) | `System`, `System.IO`, `System.Linq`, `System.Threading.Tasks` |
| `Microsoft.NET.Sdk.Web` | Lo de arriba + `Microsoft.AspNetCore.*`, `Microsoft.Extensions.*` |
| `Microsoft.NET.Sdk.Worker` | Lo de arriba + `System.Net.Http`, `Microsoft.Extensions.Hosting/Logging/DependencyInjection/Configuration` |

Por eso `Program.cs` puede no tener `using`s explícitos arriba y aun así compilar.

---

## ⚠️ Diagnósticos / errores

Setup: virtual text + signs + undercurl + auto-float en CursorHold (500ms).

### Tonos de color

| Severidad | Sign | Undercurl | Mensaje inline |
|---|---|---|---|
| **Error** | ` ` rojo `#FF5555` bold | rojo brillante | rojo bold italic |
| **Warning** | ` ` naranja `#E5A05C` | naranja apagado | naranja italic |
| **Info** | ` ` cyan `#7AC5D8` | cyan suave | cyan italic |
| **Hint** | ` ` verde menta `#6FAE91` | verde apagado | gris italic (discreto) |

### Atajos

| Tecla | Acción |
|---|---|
| `]d` / `[d` | Siguiente / anterior diagnóstico |
| `]e` / `[e` | Siguiente / anterior **error** (ignora warns) |
| `<leader>cd` | Mostrar diagnóstico de la línea (float manual) |
| `<leader>xx` | Trouble: diagnósticos de todo el proyecto |
| `<leader>xX` | Trouble: solo del buffer actual |
| `<leader>xL` | Trouble: location list |
| `<leader>xQ` | Trouble: quickfix |

### Códigos de error útiles de Roslyn

| Código | Significa | Solución típica |
|---|---|---|
| `CS0246` | Tipo/namespace no encontrado | Falta `using` o `PackageReference` |
| `CS1061` | Tipo no contiene método/propiedad X | Falta paquete NuGet (extension method) o typeo |
| `CS0103` | Nombre X no existe en contexto | Variable mal escrita o falta scope |
| `CS8618` | Non-nullable no inicializada | `<Nullable>enable</Nullable>` activado, inicializa o usa `?` |
| `CS8602` | Possible null reference | Mismo, añade null-check o `!` (null-forgiving) |

---

## 📁 Folds (plegado de código)

> Aunque no es .NET-específico, está aquí para tenerlo al alcance.
> Setup: **nvim-ufo** (provider LSP/treesitter) + autocmd `auto_view` para persistencia entre sesiones.

### Atajos básicos (nativos de Vim, sin cambios)

| Tecla | Acción |
|---|---|
| `zc` | **Cerrar** fold bajo cursor |
| `zo` | **Abrir** fold bajo cursor |
| `za` | **Toggle** fold bajo cursor (abre si cerrado, cierra si abierto) |
| `zC` | Cerrar fold + todos los anidados dentro (recursivo) |
| `zO` | Abrir fold + todos los anidados (recursivo) |
| `zA` | Toggle recursivo |
| `zj` | Saltar al **siguiente** fold |
| `zk` | Saltar al fold **anterior** |
| `[z` | Ir al inicio del fold actual |
| `]z` | Ir al final del fold actual |

### Atajos globales

| Tecla | Acción |
|---|---|
| `zM` | **Cerrar TODOS** los folds del archivo (acelerado por UFO) |
| `zR` | **Abrir TODOS** los folds del archivo (acelerado por UFO) |
| `zN` | Activar foldenable (mostrar folds) |
| `zn` | Desactivar foldenable (no mostrar folds — todo expandido) |
| `zi` | Toggle foldenable on/off |

### UFO bonus

| Tecla | Acción |
|---|---|
| `zK` | **Peek**: ver el contenido del fold cerrado en un float sin abrirlo. Si no hay fold bajo cursor, hace fallback a `K` (LSP hover) |

### Indicadores visuales

- **Columna de fold** a la izquierda del número de línea muestra triángulos `▾` (abierto) y `▸` (cerrado) — para apagarla: `:set foldcolumn=0`
- **Folds cerrados** muestran resumen tipo: `public void Foo() { ... }  󰁂 12 lines` (sumario con líneas plegadas)

### Persistencia

Los folds, posición del cursor y scroll **se persisten automáticamente** entre sesiones:
- Se guardan en `~/.local/state/nvim/view/` cada vez que sales del buffer, guardas el archivo o cierras nvim
- Se restauran automáticamente al reabrir el archivo
- Implementado vía autocmd `auto_view` en [config/autocmds.lua](../lua/config/autocmds.lua)

Para **resetear** los folds guardados de TODOS los archivos:
```vim
:!rm -rf ~/.local/state/nvim/view/*
```

### Estado inicial de archivos nuevos

Configurado en [config/options.lua](../lua/config/options.lua):
```lua
vim.opt.foldlevelstart = 99  -- archivos nuevos abren con todo expandido
```
Cambia a `0` si prefieres que se abran con todo cerrado por defecto (los archivos con view persistido respetan su estado guardado, no este default).

### Crear folds manuales (sin treesitter / LSP)

A veces quieres plegar un rango arbitrario:

| Tecla | Acción |
|---|---|
| `zf{motion}` | Crear fold del rango (ej. `zf3j` pliega 3 líneas hacia abajo, `zfap` pliega un párrafo) |
| `zf` (visual) | Crear fold de la selección visual |
| `zd` | Borrar fold bajo cursor (solo si es manual) |
| `zD` | Borrar fold recursivo |
| `zE` | Eliminar TODOS los folds manuales del buffer |

> Estos comandos solo funcionan si `foldmethod=manual`. UFO no es manual por default — si quieres folds manuales para un buffer concreto, hazlo `:setlocal foldmethod=manual` antes.

---

## 🖥️ Terminales

Tienes varios sistemas de terminal, cada uno con un propósito distinto.

### Terminales generales (Snacks)

| Tecla | Acción | Posición |
|---|---|---|
| `<leader>D` | Toggle terminal lateral | Split vertical **derecha**, 40% ancho |
| `<leader>tv` | Alias de `<leader>D` (Terminal Vertical) | Igual |
| `<leader>th` | Toggle terminal abajo | Split horizontal **abajo**, 30% alto |

> Todos son **toggle**: presionar una vez abre, presionar de nuevo cierra. La sesión del shell sigue viva entre toggles (no se mata, queda hibernando).

### Terminales numeradas (toggleterm)

| Tecla | Acción |
|---|---|
| `<leader>1` | Terminal #1 (en raíz del repo) |
| `<leader>2` | Terminal #2 (en raíz del repo) |
| `<leader>3` | Terminal #3 (en raíz del repo) |
| `<leader>sl` | Enviar línea actual → Terminal #1 (útil para REPLs) |
| `<leader>sv` | Enviar selección visual → Terminal #1 |

> Cada terminal numerada es **independiente** — pueden correr cosas distintas simultáneamente. Útil cuando tienes `dotnet watch` corriendo en una y necesitas otra para `git`.

### Panel de easy-dotnet (con pestañas)

| Tecla | Acción |
|---|---|
| `<leader>;p` | Toggle del panel de easy-dotnet (con pestañas por cada run/build/test) |
| `<leader>;P` | Mostrar panel (sin toggle) |
| `<leader>;X` | Cerrar TODAS las pestañas del panel |

> Este panel guarda automáticamente la salida de cada `<leader>;r` / `<leader>;b` / `<leader>;t` en una pestaña separada. Útil para revisar runs anteriores.

### Dentro de cualquier terminal

| Tecla | Acción |
|---|---|
| `<C-\><C-n>` | Salir de modo terminal (entrar a modo normal para hacer scroll, yank, etc.) |
| `<Esc><Esc>` | Mismo que arriba (LazyVim default) |
| `jk` | (en toggleterm) Salir a modo normal |
| `i` o `a` | Entrar de vuelta a modo terminal-insert |
| `<C-h/j/k/l>` | Navegar entre splits sin salir del terminal |
| `q` (normal) | Cerrar la ventana del terminal (la sesión queda viva — reábrela con el mismo atajo) |
| `:q` o `<C-w>q` | Igual que arriba |

### Comandos one-shot sin abrir terminal

Si solo quieres ejecutar UN comando rápido sin tener un terminal interactivo:

| Comando | Cuándo usar |
|---|---|
| `:!comando` | Ejecuta y muestra output abajo, espera ENTER para volver |
| `:!comando &` | Ejecuta en background, no bloquea nvim |
| `:r !comando` | Ejecuta y **pega la salida** en el buffer actual |

Ej. para añadir un paquete NuGet sin abrir terminal:
```vim
:!dotnet add package Microsoft.Extensions.Http --version 8.0.1
```

---

## 🌐 REST Client (kulala — .http files)

Cliente HTTP **dentro de nvim**, estilo Postman pero con archivos `.http` que viven en tu repo. Ideal para versionar tus pruebas de API con git.

Provisto por la extra `lazyvim.plugins.extras.util.rest` que instala [kulala.nvim](https://github.com/mistweaverco/kulala.nvim).

### Anatomía de un archivo `.http`

```http
@base = http://localhost:5000

###
GET {{base}}/health

###
POST {{base}}/AvdOperations/v1/Ping
Content-Type: application/json

{
  "Usuario": "test",
  "Mensaje": "hello"
}
```

- `###` separa peticiones
- `@var = valor` declara variables (referencia con `{{var}}`)
- Headers van entre la línea `METHOD url` y el body
- El body va separado por **una línea en blanco**
- Ver ejemplo completo en [`docs/examples/sap-example.http`](examples/sap-example.http)

### Atajos (en buffers `.http`)

| Tecla | Acción |
|---|---|
| `<leader>R` | Prefix (which-key muestra el resto) |
| `<leader>Rs` | **Send** la request bajo el cursor |
| `<leader>Rr` | **Replay** la última request |
| `<leader>Rn` | Saltar a la **siguiente** request |
| `<leader>Rp` | Saltar a la **anterior** request |
| `<leader>Re` | Cambiar **entorno** (Dev / QA / Prod) |
| `<leader>Rc` | **Copy** request como cURL (al portapapeles) |
| `<leader>RC` | **Paste** desde cURL (lo convierte a .http) |
| `<leader>Rb` | Abrir **scratchpad** (request rápida sin guardar archivo) |
| `<leader>Ri` | **Inspect** la request actual (debug) |
| `<leader>Rt` | **Toggle** view: headers vs body de la respuesta |
| `<leader>RS` | Mostrar **stats** (tiempo, status, tamaño) |
| `<leader>Rq` | **Cerrar** ventana de respuesta |
| `<leader>Rg` | Descargar schema **GraphQL** |

### Entornos (Dev / QA / Prod)

Crea `http-client.env.json` al lado de tus `.http`:

```json
{
  "Dev": {
    "BASE_URL": "http://sap-qa.example.com:8005",
    "USER": "u_qa",
    "PASS": "p_qa"
  },
  "QA": {
    "BASE_URL": "https://sap-qa-2.example.com",
    "USER": "u_qa",
    "PASS": "p_qa"
  },
  "Prod": {
    "BASE_URL": "https://sap-prod.example.com",
    "USER": "u_prod",
    "PASS": "p_prod"
  }
}
```

Y en el `.http`:
```http
GET {{BASE_URL}}/api/endpoint
Authorization: Basic {{$base64 USER:PASS}}
```

Para cambiar entorno: `<leader>Re` → te muestra picker → eliges Dev/QA/Prod → todas las requests del archivo usan esas variables.

> 🔒 **Importante**: añade `http-client.env.json` a tu `.gitignore` si contiene secrets reales. Para versionar la estructura sin secrets, usa `http-client.private.env.json` (kulala lo busca también y debería estar gitignored).

### Encadenamiento de requests (response chaining)

Para usar el resultado de una request en la siguiente:

```http
# @name login
POST http://api.example.com/auth
Content-Type: application/json

{ "user": "x", "pass": "y" }

###
GET http://api.example.com/profile
Authorization: Bearer {{login.response.body.access_token}}
```

Ejecutas `<leader>Rs` sobre `login` primero, luego sobre la segunda — el token se reutiliza automáticamente.

### Funciones built-in útiles

| Función | Qué hace |
|---|---|
| `{{$base64 USER:PASS}}` | Encoda en base64 (para Basic auth) |
| `{{$timestamp}}` | Unix timestamp actual |
| `{{$randomInt}}` | Entero aleatorio |
| `{{$uuid}}` | UUID v4 |
| `{{$dotenv VAR}}` | Lee variable de `.env` del proyecto |
| `{{$processEnv VAR}}` | Lee variable de entorno del sistema |

### Workflow típico con .NET

1. En tu proyecto `.NET Sdk.Web` ya viene un archivo `WeatherForecast.http` por defecto. **Esto es kulala-compatible**.
2. Añade tus propias requests al archivo (o crea más, ej. `Sap.http`, `Auth.http`)
3. Crea `http-client.env.json` con tus entornos
4. Arranca tu API (`<leader>;r` o `<leader>cw` para watch)
5. Abre el `.http`, cursor en una request, `<leader>Rs` → response en un split
6. Itera

---

## 🗄️ Database (vim-dadbod-ui)

Cliente SQL "tipo Toad/DBeaver" dentro de nvim. Browse de schemas/tablas/procs, ejecutar queries, múltiples conexiones, autocompletion de columnas y tablas.

Provisto por la extra `lazyvim.plugins.extras.lang.sql` con override en [dadbod.lua](../lua/plugins/dadbod.lua) (cambia `<leader>D` → `<leader>Q` porque `D` ya es terminal lateral).

### Requisitos

- **psql** (PostgreSQL client) instalado vía `brew install libpq`
- **sqlplus** (Oracle Instant Client) — opcional, solo si vas a conectar a Oracle
- **mysql** client — opcional, solo si vas a conectar a MySQL

### Atajos

| Tecla | Acción |
|---|---|
| `<leader>Q` | **Toggle DBUI** (panel lateral con árbol) |
| `<leader>Qa` | Añadir conexión nueva (interactivo) |
| `<leader>Qf` | Find buffer (buscar query abierta) |
| `<leader>Qr` | Renombrar buffer/query |
| `<leader>Ql` | Info de la última query ejecutada |

### Dentro del panel DBUI (árbol) — atajos reales

| Tecla | Acción |
|---|---|
| `o` / `<CR>` | **Expandir / colapsar** nodo, o abrir item |
| `S` | Open en vertical split |
| `R` | **Redraw** (refresh — útil tras cambios en la DB) |
| `d` | **Delete** conexión guardada (con confirmación) |
| `A` | Add connection |
| `H` | Toggle details (verbose) |
| `r` | Rename buffer/connection |
| `q` | **Quit** (cerrar panel DBUI) |
| `K` / `J` | Hermano anterior / siguiente |
| `<C-k>` / `<C-j>` | Primer / último hermano |
| `<C-p>` | Nodo padre |
| `<C-n>` | Nodo hijo |
| `?` | Help completo |

### Sobre "cerrar conexiones"

vim-dadbod es **stateless**: cada query abre `psql`, ejecuta y cierra. No hay socket persistente que cerrar. Pero puedes:

| Si quieres... | Haz esto |
|---|---|
| **Esconder visualmente** una conexión expandida | Cursor sobre el nombre → `o` (colapsa) |
| **Cerrar el panel** entero | `q` en el panel, o `<leader>Q` (toggle) |
| **Borrar permanentemente** la conexión guardada | Cursor sobre ella → `d` → confirma |
| **Matar un `psql` colgado** (raro) | Desde otra terminal: `ps aux \| grep psql` + `kill <PID>` |

> Si la conexión viene de `vim.g.dbs` (en [dadbod.lua](../lua/plugins/dadbod.lua) o `.lazy.lua` del proyecto), `d` en el árbol no la quita — tienes que editar ese archivo.

### Dentro de un buffer SQL (cualquier `.sql`)

| Tecla | Acción |
|---|---|
| `<leader>S` | **Ejecutar query** bajo cursor (o selección visual) |
| `<C-Space>` | Autocompletion de nombres de tablas, columnas, funciones |

### Estructura del árbol

```
▼ pg_local
  ▼ Tables
    ├ users    → Enter abre SELECT * FROM users LIMIT 200
    ├ orders
  ▼ Views
  ▼ Procedures   (Oracle/Postgres con CREATE PROCEDURE)
  ▼ Functions
  ▼ Packages     (Oracle PL/SQL)
  ▼ Triggers
  ▼ Sequences
  ▼ Saved Queries   → tus .sql guardados
  ▼ History         → queries ejecutadas
```

### Configurar conexiones

3 formas, de menos a más segura:

**A) Hardcodeadas en [`dadbod.lua`](../lua/plugins/dadbod.lua)** (mala práctica si hay password):
```lua
vim.g.dbs = {
  pg_local = "postgres://erik@localhost:5432/mydb",
}
```

**B) Variables de entorno** (recomendado):
```bash
# En ~/.zshrc
export PG_DEV_URL="postgres://user:pass@host:5432/db"
export PG_PROD_URL="postgres://user:pass@host:5432/db"
```
```lua
vim.g.dbs = {
  pg_dev  = os.getenv("PG_DEV_URL"),
  pg_prod = os.getenv("PG_PROD_URL"),
}
```

**C) Por proyecto en `.lazy.lua`** (gitignored, ideal para repos compartidos):
En la raíz de tu repo, crea `.lazy.lua`:
```lua
vim.g.dbs = {
  proyecto_x = "postgres://...",
}
return {}
```
Y añade `.lazy.lua` a tu `.gitignore`.

**D) Desde la UI** (más fácil para empezar):
- `<leader>Q` para abrir DBUI
- `A` (mayúscula) sobre el árbol → te pide nombre + URL
- Se guarda en `~/.local/share/nvim/dadbod_ui/connections.json`

### Formatos de URL más comunes

```
postgres://user:pass@host:5432/dbname
postgresql://user:pass@host:5432/dbname?sslmode=require
mysql://user:pass@host:3306/dbname
sqlite:/path/to/file.db
oracle://user:pass@host:1521/SERVICE_NAME
```

### Linter + formatter de SQL

La extra de LazyVim también instala `sqlfluff` (vía Mason) que da:
- Diagnósticos de SQL malformado o con malas prácticas
- Format on save (`<leader>cf` manual)

### Tips de uso

1. **Para una exploración rápida**: `<leader>Q` → expandes `Tables` → Enter sobre la tabla → genera y ejecuta `SELECT * FROM <tabla> LIMIT 200`. Resultado en split.

2. **Para queries personalizadas**: dentro de DBUI, vas a "New Query" o creas un `.sql` cualquiera. Conexión activa = última seleccionada en el árbol.

3. **Guardar queries**: las que pones en el árbol bajo "Saved Queries" se versionan en `~/.local/share/nvim/dadbod_ui/<connection>/`. Si las quieres en tu repo, configura `vim.g.db_ui_save_location` a una ruta dentro del repo.

4. **Ver el SQL de un procedure/package** (Oracle, PostgreSQL functions): expandes el nodo del árbol y Enter sobre el objeto — te muestra el source.

5. **Cambiar de conexión sin reiniciar**: en el árbol, doble-click (o Enter) sobre otra conexión, te pasa a esa.

---

## 📱 Flutter / Dart

Desarrollo Flutter dentro de Neovim vía **flutter-tools.nvim** (maneja el Dart LSP,
hot reload, devices, dev log, outline de widgets). SDK en `~/Apps/flutter`.

Provisto por [flutter.lua](../lua/plugins/flutter.lua). Prefix: `<leader>F*` (Flutter).
Los atajos solo activan en buffers `.dart`.

### Requisitos

- **Flutter SDK** en `~/Apps/flutter` (incluye Dart + el LSP; no se instala por Mason)
- Según target: Xcode (iOS/macOS), Android Studio + SDK (Android), Chrome (web)
- **NO** activar el extra `lang.dart` de LazyVim → duplicaría el LSP

### Atajos (`<leader>F*`, en `.dart`)

| Tecla | Comando | Acción |
|---|---|---|
| `<leader>Fr` | `:FlutterRun` | **Run** la app (elige device) |
| `<leader>Fl` | `:FlutterReload` | **Hot Reload** |
| `<leader>FR` | `:FlutterRestart` | **Hot Restart** |
| `<leader>Fq` | `:FlutterQuit` | Detener la app |
| `<leader>Fd` | `:FlutterDevices` | Elegir device (iOS/Android/Chrome/macOS) |
| `<leader>Fe` | `:FlutterEmulators` | Elegir/lanzar emulador |
| `<leader>Fa` | `:FlutterAttach` | Attach a una app ya corriendo |
| `<leader>Fp` | `:FlutterLogToggle` | **Mostrar/ocultar el panel de dev log** (recuperarlo si lo cerraste) |
| `<leader>Fc` | `:FlutterLogClear` | Limpiar el dev log |
| `<leader>Fo` | `:FlutterOutlineToggle` | Árbol de widgets (outline) |
| `<leader>FD` | `:FlutterDevTools` | Abrir DevTools |
| `<leader>Fg` | `:FlutterPubGet` | `flutter pub get` |
| `<leader>Fu` | `:FlutterPubUpgrade` | `flutter pub upgrade` |
| `<leader>Fs` | `:FlutterSuper` | Ir a la superclass |
| `<leader>Fb` | `:FlutterToggleBrightness` | Toggle light/dark en el device |

### Comandos útiles sin keymap (`:Flutter*`)

| Comando | Acción |
|---|---|
| `:FlutterDebug` | Correr con el debugger (DAP) adjunto |
| `:FlutterRename` | Renombrar símbolo/archivo (con imports) |
| `:FlutterInspectWidget` | Inspeccionar el widget bajo el cursor |
| `:FlutterVisualDebug` | Toggle overlay de debug visual (bordes de widgets) |
| `:FlutterChangeTargetPlatform` | Cambiar plataforma target |
| `:FlutterLspRestart` | Reiniciar el Dart LSP (si algo se traba) |
| `:FlutterReanalyze` | Forzar re-análisis del proyecto |

### El panel de dev log

Al hacer `<leader>Fr`, se abre un split abajo con la salida de `flutter run`
(prints, errores, estado del hot reload). Si lo cierras (`:q` o `<C-w>c`), **la app
sigue corriendo** — solo ocultaste la ventana. Para recuperarlo:

```vim
:FlutterLogToggle     " o <leader>Fp
```

### Flujo típico

1. `nvim` en tu proyecto Flutter (con `pubspec.yaml`)
2. Abre `lib/main.dart` → el LSP indexa (unos segundos)
3. `<leader>Fd` → elige device (Chrome = lo más rápido para probar)
4. `<leader>Fr` → corre la app; se abre el dev log abajo
5. Editas + guardas → **hot reload automático**
6. `<leader>FR` si necesitas hot restart (cambios de estado/main)
7. `<leader>Fq` para detener

### Indentación y otros

- Dart usa **2 espacios** (configurado; `dart format` lo confirma al guardar)
- Autocompletado, hover, diagnósticos vía el Dart LSP (integrado con blink.cmp)
- Formato al guardar vía dartls

---

## 🛠️ Build / Run / Test / Watch

### Atajos rápidos vía easy-dotnet (prefix `<leader>;*`)

> Prefix `<leader>;*` (punto y coma) porque todos los prefijos "lógicos" están tomados:
> - `<leader>c*` → LazyVim code actions (rename, format, action)
> - `<leader>d*` → DAP debug (toggle bp, continue, step over, etc)
> - `<leader>D*` → Snacks/LazyVim panel lateral del terminal
> - `<leader>n*` → LazyVim notifications/noice
>
> `<leader>;` es único, sin conflictos, y se teclea rápido con la mano derecha.

| Tecla | Comando equivalente | Acción |
|---|---|---|
| `<leader>;r` | `:Dotnet run` | Run con picker (1ª vez); reutiliza default después |
| `<leader>;d` | `:Dotnet debug` | Debug con picker |
| `<leader>;t` | `:Dotnet testrunner` | Abrir UI del test runner |
| `<leader>;b` | `:Dotnet build` | Build con picker |
| `<leader>;R` | `:Dotnet restore` | Restore paquetes (R mayúscula) |
| `<leader>;c` | `:Dotnet clean` | Clean (borra bin/obj) |
| `<leader>;w` | `:Dotnet watch` | Watch run (hot reload) |
| `<leader>;n` | `:Dotnet new` | Picker de plantillas |
| `<leader>;s` | `:Dotnet secrets` | User Secrets |
| `<leader>;o` | `:Dotnet outdated` | Paquetes desactualizados |
| `<leader>;a` | `:Dotnet add` | Add package / reference |
| `<leader>;p` | `:Dotnet terminal toggle` | **Toggle panel de terminal** (ver salida de runs anteriores) |
| `<leader>;P` | `:Dotnet terminal show` | Mostrar panel de terminal (P mayúscula) |
| `<leader>;X` | (custom) | **Cerrar TODAS** las pestañas del panel (limpia histórico) |

> 💡 **Panel de terminal**: easy-dotnet mantiene un panel inferior con pestañas que guarda toda la salida de tus runs, builds, tests, etc. — incluso después de que el proceso termina. El panel se oculta automáticamente al terminar el comando, pero los buffers siguen vivos. Reábrelo con `<leader>;p` para revisar la salida.
>
> **Dentro del panel** (cuando estás enfocado en él):
> - `<Tab>` / `<S-Tab>` — siguiente / anterior pestaña (cada run/test/build tiene su propia)
> - `+` — nueva pestaña de terminal (libre, para tus comandos)
> - `X` — cerrar pestaña **actual** (mayúscula)
> - `q` — ocultar el panel (sin perder buffers)
>
> **Para cerrar todas de una vez** (sin tener que ir una por una con `X`): `<leader>;X` desde cualquier buffer. Te avisa cuántas cerró.
>
> ⚠️ **Sobre el contador "Terminal 89"**: el número que ves en la etiqueta de la pestaña es un **contador acumulativo** que jamás se reinicia mientras nvim esté abierto. "Terminal 89" significa "la 89ª terminal creada en esta sesión de nvim", **no** "hay 89 terminales abiertas ahora mismo". Para saber cuántas tienes realmente, cuenta las pestañas visibles en la tabline arriba del panel.
>
> ⚠️ **Por qué al cerrar la última pestaña con `X` aparece una nueva**: easy-dotnet auto-crea una terminal cuando el panel se quedaría vacío (lo considera un "feature" para que el panel siempre tenga algo). El `<leader>;X` que tienes mapeado **evita ese auto-spawn** anulando primero el `active_id` y ocultando el panel, así que sí limpia todo de verdad.

> **Cómo teclearlo**: Space → `;` → letra. Ej. `<leader>;r` = `Space` `;` `r`. Las versiones con mayúscula (`R`, `T`) requieren Shift en la última letra.

### Atajos custom (split en terminal, picker propio de .csproj)

| Tecla | Acción |
|---|---|
| `<leader>cb` | `dotnet build` en split |
| `<leader>ct` | `dotnet test` en split |
| `<leader>cr` | `dotnet restore` en split |
| `<leader>cw` | `dotnet watch run` (hot reload) en split |

> Los custom (`<leader>cb/ct/cr/cw`) están en [dotnet-keymaps.lua](../lua/plugins/dotnet-keymaps.lua) y abren un split horizontal abajo (solo activos en buffers `.cs`). Los de easy-dotnet (`<leader>;*`) muestran un picker visual y manejan la sesión de manera más sofisticada (notifications, jobs, etc).

---

## 🚀 Publish multi-plataforma

Tienes **dos modos** de publicar: con `.pubxml` (lo que hace Rider/VS) o con flags directos.

### Modo A: Publish con `.pubxml` (recomendado si ya tienes profiles)

Si tu proyecto tiene archivos en `Properties/PublishProfiles/*.pubxml` (como los que creaste antes en Rider/VS), úsalos directamente. El profile encapsula RID + Configuration + SelfContained + Trim + R2R + lo que sea, en un solo XML versionable.

| Tecla | Acción |
|---|---|
| `<leader>cpp` | **Publish usando .pubxml** (te lista los profiles del proyecto, eliges uno) |

Equivale a:
```bash
dotnet publish <Project>.csproj -p:PublishProfile=<nombre>
```

Donde `<nombre>` es el nombre del archivo sin `.pubxml`. Por ejemplo, `win-x64.pubxml` → `-p:PublishProfile=win-x64`.

> 💡 Si solo hay 1 profile, va directo sin picker. Si no hay ninguno, te avisa que uses los flags directos.

#### Anatomía de un `.pubxml`

```xml
<Project>
  <PropertyGroup>
    <Configuration>Release</Configuration>
    <Platform>Any CPU</Platform>
    <PublishDir>bin\Release\net8.0\publish\win-x64\</PublishDir>
    <PublishProtocol>FileSystem</PublishProtocol>
    <TargetFramework>net8.0</TargetFramework>
    <RuntimeIdentifier>win-x64</RuntimeIdentifier>
    <SelfContained>true</SelfContained>
    <PublishSingleFile>false</PublishSingleFile>
    <PublishReadyToRun>false</PublishReadyToRun>
    <PublishTrimmed>false</PublishTrimmed>
  </PropertyGroup>
</Project>
```

Cada propiedad equivale a un flag de CLI:
- `<RuntimeIdentifier>` = `-r`
- `<Configuration>` = `-c`
- `<SelfContained>` = `--self-contained`
- `<PublishSingleFile>` = `-p:PublishSingleFile=true`
- `<PublishTrimmed>` = `-p:PublishTrimmed=true`
- `<PublishReadyToRun>` = `-p:PublishReadyToRun=true`

> **Versiona los `.pubxml` en git**. Son la "única verdad" del publish y todo el equipo (incluidos los que usan Rider/VS) usa los mismos.

### Modo B: Publish con flags directos (sin .pubxml)

Todos van a `bin/Release/<rid>/publish/`.

| Tecla | Acción | Self-contained |
|---|---|---|
| `<leader>cpm` | macOS arm64 (`osx-arm64`) | ✅ Sí |
| `<leader>cpw` | Windows x64 (`win-x64`) | ✅ Sí |
| `<leader>cpa` | Ambos: macOS arm64 + Windows x64 | ✅ Sí |
| `<leader>cpM` | macOS arm64 | ❌ Framework-dependent |
| `<leader>cpW` | Windows x64 | ❌ Framework-dependent |

> **Self-contained**: incluye el .NET runtime en el output, el ejecutable corre sin nada instalado en la máquina destino. Más pesado.
> **Framework-dependent**: solo tu app, la máquina destino necesita el runtime instalado. Más liviano.

### Publish para otros RIDs (manualmente)

Si necesitas Linux, otros archs, etc:
```vim
:!dotnet publish -c Release -r linux-x64 --self-contained
:!dotnet publish -c Release -r linux-arm64 --self-contained
:!dotnet publish -c Release -r osx-x64 --self-contained
:!dotnet publish -c Release -r win-arm64 --self-contained
```

O crea un `.pubxml` nuevo para esos targets:

```bash
# Crea Properties/PublishProfiles/linux-arm64.pubxml manualmente,
# o desde Rider/VS (Publish → New Profile → Folder), o copia uno existente y ajusta.
```

### ¿Cuándo usar cuál?

| Caso | Modo |
|---|---|
| Tu proyecto ya tiene `.pubxml` (de Rider/VS) | **A** (`<leader>cpp`) |
| Build de release "oficial" para distribución | **A** (`.pubxml` versionado) |
| Quick test "compilar para Windows a ver si pasa" | **B** (`<leader>cpw`) |
| Target que aún no tienes profile creado | **B** |
| Trabajo en equipo con Rider/VS y nvim mezclados | **A** (consistencia) |

---

## 🐞 Debug (DAP + netcoredbg)

### Control de sesión

| Tecla | Acción |
|---|---|
| `<F5>` / `<leader>dc` | Continue (lanza la sesión si no hay; sino sigue) |
| `<F9>` / `<leader>db` | Toggle breakpoint en la línea |
| `<leader>dB` | Breakpoint condicional (pide expresión) |
| `<leader>dl` | Logpoint (printea mensaje sin parar) |
| `<F10>` / `<leader>do` | Step over |
| `<F11>` / `<leader>di` | Step into |
| `<S-F11>` / `<leader>dO` | Step out |
| `<leader>dt` | Terminate sesión |
| `<leader>dq` | Quit sesión |
| `<leader>du` | Toggle DAP UI completa |
| `<leader>duc` | Cerrar DAP UI |

### Inspección

| Tecla | Acción |
|---|---|
| `<leader>de` | Evaluar expresión |
| `<leader>dh` | Hover sobre variable bajo cursor |
| `<leader>dp` | Preview |
| `<leader>dw` | Widget flotante con scopes |
| `<leader>dr` | Toggle REPL |
| `<leader>duf` | Float DAP UI element |

### Configuraciones disponibles (al pulsar `<F5>` te ofrece)

1. **Launch (autodiscover .csproj)** — busca el `.csproj`, hace `dotnet build`, encuentra el `.dll` en `bin/Debug/<tfm>/<Project>.dll` y lo lanza. Si hay varios proyectos, picker.
2. **Attach to process** — selecciona un proceso `dotnet*` ya corriendo (útil para servicios de Windows con `--launch-profile`, etc).

### Variables de entorno por defecto

El launch automático setea:
- `ASPNETCORE_ENVIRONMENT=Development`
- `DOTNET_ENVIRONMENT=Development`

Para cambiar al vuelo, edita [dotnet-dap.lua](../lua/plugins/dotnet-dap.lua).

---

## 🧪 Tests

### Neotest (genérico, multi-lenguaje)

| Tecla | Acción |
|---|---|
| `<leader>tn` | Test bajo el cursor (nearest) |
| `<leader>tf` | Tests del archivo actual |
| `<leader>ta` | Todos los tests del proyecto |
| `<leader>ts` | Toggle panel de resumen |
| `<leader>to` | Abrir output del test seleccionado |

### Test runner de easy-dotnet (`:Dotnet testrunner` o `<leader>;t`)

Dentro del buffer del runner:

| Tecla | Acción |
|---|---|
| `<leader>r` | Run test bajo cursor |
| `<leader>R` | Run todos |
| `<leader>d` | **Debug** test bajo cursor |
| `<leader>p` | Peek stacktrace del test fallado |
| `<leader>fe` | Filtrar solo tests fallados |
| `g` | Go to file (del test) |
| `o` | Expand nodo |
| `E` | Expand un nivel |
| `-` | Expand all |
| `W` | Collapse all |
| `<C-r>` | Refresh testrunner |
| `q` | Cerrar |

---

## 📦 Operaciones de proyecto y paquetes NuGet

Tienes **dos formas** de operar:

1. **Comando `:Dotnet *`** de easy-dotnet — con picker, notifications, integración con el plugin
2. **Bang `:!dotnet *`** — pasa directo al CLI; útil si necesitas args muy específicos

### Subcomandos de `:Dotnet *` disponibles

```
add  build  clean  createfile  debug  diagnostic  ef  lsp  new  outdated
pack  push  remove  reset  restore  run  secrets  solution  terminal
test  testrunner  watch
```

Sin argumentos (`:Dotnet`) → abre un picker de subcomandos.

### Paquetes NuGet

```vim
" easy-dotnet (con picker de proyectos)
:Dotnet add package <nombre>
:Dotnet add reference                                  " añade referencia entre proyectos
:Dotnet remove                                         " remover (paquete o referencia)
:Dotnet outdated                                       " ver desactualizados

" CLI directo (control fino)
:!dotnet add package <nombre>
:!dotnet add package <nombre> --version 8.0.1          " versión específica (recomendado para .NET 8 LTS)
:!dotnet remove package <nombre>
:!dotnet list package
:!dotnet list package --outdated
:!dotnet list package --vulnerable
:!dotnet restore
```

> **⚠️ Importante**: `dotnet add package` (sin `--version`) instala la **última versión estable** independientemente de tu `TargetFramework`. Para mantener consistencia con tu .NET 8 LTS, fija manualmente la versión con `--version 8.0.x` (mismo major que `Microsoft.Extensions.Hosting`, etc).

### Plantillas nuevas

```vim
" Con picker visual
:Dotnet new                                            " elige template + nombre

" CLI directo
:!dotnet new list                                      " listar templates
:!dotnet new webapi -n MiApi                           " API
:!dotnet new console -n MiCli                          " Console
:!dotnet new worker -n MiWorker                        " Worker service
:!dotnet new classlib -n MiLib                         " Class library
:!dotnet new sln -n MiSolution                         " Solution file
:!dotnet sln add MiProyecto/MiProyecto.csproj          " añadir proyecto a sln
```

### Entity Framework Core

```vim
" easy-dotnet (atajos cortos)
:Dotnet ef migrations add NombreMigration
:Dotnet ef database update

" CLI directo
:!dotnet ef migrations add NombreMigration
:!dotnet ef migrations remove
:!dotnet ef migrations list
:!dotnet ef database update
:!dotnet ef database drop
:!dotnet ef dbcontext info
:!dotnet ef dbcontext scaffold "<connstr>" Microsoft.EntityFrameworkCore.SqlServer -o Models
```

### Build / Pack / Push (NuGet packaging)

```vim
:Dotnet pack                                           " genera .nupkg
:Dotnet push                                           " sube a feed NuGet
:Dotnet clean                                          " limpia bin/obj
:Dotnet build                                          " build con picker
:!dotnet build -c Release                              " build release directo
:!dotnet clean
```

### Diagnóstico y solución

```vim
:Dotnet diagnostic                                     " info de la sesión actual
:Dotnet solution                                       " manejar el .sln
:Dotnet lsp                                            " info / control del LSP
:Dotnet reset                                          " reset state de easy-dotnet
:Dotnet terminal                                       " abre terminal con dotnet en CWD del proyecto
```

### Tools

```vim
:!dotnet tool install -g <nombre>
:!dotnet tool update -g <nombre>
:!dotnet tool list -g
```

### SDK / Info

```vim
:!dotnet --version                                     # versión activa
:!dotnet --list-sdks                                   # SDKs instalados
:!dotnet --list-runtimes                               # runtimes instalados
:!dotnet --info                                        # info completa
```

---

## 🔬 Comandos de Roslyn LSP

| Comando | Acción |
|---|---|
| `:Roslyn target` | Cambiar qué `.sln` / `.csproj` escanea Roslyn (cuando hay varios) |
| `:Roslyn stop` | Detener el servidor |
| `:Roslyn restart` | Reiniciar el servidor (útil después de cambios estructurales) |
| `:LspRestart roslyn` | Alternativa para reiniciar |
| `:LspInfo` | Ver qué clientes LSP están atachados al buffer actual |
| `:checkhealth vim.lsp` | Diagnóstico completo de LSP |

---

## 🔐 User Secrets

User Secrets de .NET viven en:
- **macOS / Linux**: `~/.microsoft/usersecrets/<UserSecretsId>/secrets.json`
- **Windows**: `%APPDATA%\Microsoft\UserSecrets\<UserSecretsId>\secrets.json`

| Comando | Acción |
|---|---|
| `:Secrets` o `<leader>;s` o `:Dotnet secrets` | Abrir `secrets.json` del proyecto actual |
| `:!dotnet user-secrets init` | Inicializar User Secrets en el proyecto |
| `:!dotnet user-secrets set "Sap:Username" "valor"` | Setear un secret |
| `:!dotnet user-secrets list` | Listar |
| `:!dotnet user-secrets remove "Sap:Username"` | Eliminar |

---

## ✂️ Formato (csharpier)

Formatter: **csharpier** (configurado por conform.nvim, incluido en el extra `lang.dotnet` de LazyVim).

| Tecla | Acción |
|---|---|
| `<leader>cf` | Formatear el archivo actual |
| Auto al guardar | Sí, si el archivo es menor a 100KB |

### Configurar csharpier por proyecto

Crea `.csharpierrc.json` en la raíz del repo:
```json
{
  "printWidth": 120,
  "useTabs": false,
  "tabWidth": 4,
  "endOfLine": "lf"
}
```

### Excluir archivos

`.csharpierignore` (estilo `.gitignore`):
```
Migrations/
**/*.Generated.cs
```

---

## 🔄 Workflows típicos

### Run / Debug / Test rápido (día a día)

| Quiero... | Keymap |
|---|---|
| Correr el proyecto (picker la 1ª vez) | `<leader>;r` |
| Debug del proyecto (picker) | `<leader>;d` |
| Abrir test runner UI | `<leader>;t` |
| Hot reload | `<leader>;w` |
| Build | `<leader>;b` |
| Editar User Secrets | `<leader>;s` |
| Añadir paquete NuGet | `<leader>;a` |

### Crear y arrancar un proyecto nuevo

```bash
dotnet new worker -n MyWorker
cd MyWorker
nvim .
```
1. Roslyn arranca (10-30s primera vez)
2. Edita `Program.cs` / `Worker.cs`
3. `<F9>` en la línea donde quieres parar
4. `<F5>` o `<leader>dc` → "Launch (autodiscover)" → compila y arranca debugger
   (alternativa: `<leader>;d` para el picker de easy-dotnet)

### Trabajar en un Worker Service que llama a SAP / API externa

`.csproj` mínimo:
```xml
<Project Sdk="Microsoft.NET.Sdk.Worker">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <UserSecretsId>...</UserSecretsId>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.Extensions.Hosting" Version="8.0.1" />
    <PackageReference Include="Microsoft.Extensions.Hosting.WindowsServices" Version="8.0.1" />
    <PackageReference Include="Microsoft.Extensions.Http" Version="8.0.1" /> <!-- para AddHttpClient<T> -->
  </ItemGroup>
</Project>
```

`Program.cs`:
```cs
var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddHttpClient<SapService>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["Sap:BaseUrl"]!);
    client.Timeout = TimeSpan.FromSeconds(30);

    var user = builder.Configuration["Sap:Username"];
    var pass = builder.Configuration["Sap:Password"];
    var basic = Convert.ToBase64String(
        System.Text.Encoding.UTF8.GetBytes($"{user}:{pass}"));
    client.DefaultRequestHeaders.Authorization =
        new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", basic);
});

builder.Services.AddHostedService<Worker>();

var host = builder.Build();
host.Run();
```

### Crear un release de Windows para distribuir desde un Mac

```vim
<leader>cpw
```
Output: `bin/Release/net8.0/win-x64/publish/MyApp.exe` (self-contained, ~70 MB).
Cópialo al Windows target — no necesita instalar .NET.

### Hot reload mientras desarrollas

```vim
<leader>cw
```
Edita código, guarda, el watch recompila y reinicia automáticamente.

### Attach a un proceso ya corriendo

1. Lanza tu app desde otra terminal: `dotnet run`
2. En nvim: `<F5>` → elige "Attach to process"
3. Busca el proceso por nombre (filtra "dotnet")
4. Ya estás dentro, pon breakpoints

### Pipeline de release multi-target

```vim
<leader>cpa
```
Genera ambos targets en cadena. Output en `bin/Release/net8.0/osx-arm64/publish/` y `bin/Release/net8.0/win-x64/publish/`.

---

## 🩺 Troubleshooting

### "Solo me da completion de buffer (`abc`), no de Roslyn"

**Síntoma**: al escribir `obj.` te aparecen palabras random del archivo en vez de métodos del tipo.

**Diagnóstico**:
1. Verifica que Roslyn está atachado: `:LspInfo`
2. Mira el tipo del símbolo: pon cursor sobre la variable y presiona `K`
   - Si dice `(parameter) ? variable` o nada → tipo no inferido
   - Si dice `(parameter) Foo variable` → tipo OK, problema en otra parte
3. Mira los diagnósticos: `:Trouble diagnostics`

**Causas típicas**:
| Causa | Solución |
|---|---|
| Falta `PackageReference` (ej. `Microsoft.Extensions.Http` para `AddHttpClient<T>`) | `:!dotnet add package <X> --version 8.0.1` |
| Roslyn aún indexando (primera apertura) | Esperar 20-60s |
| Errores de sintaxis en el archivo rompen inferencia | Limpiar el archivo, `:w`, `:Roslyn restart` |
| Roslyn apunta a otra solución | `:Roslyn target` para elegir manualmente |
| Solo está blink con fuente buffer | `:lua print(pcall(require,"blink.cmp"), pcall(require,"cmp"))` — debe ser blink=true, cmp=false |

### "Roslyn no arranca"

```vim
:Mason            # Verifica que `roslyn` esté installed (no solo "available")
:MasonUpdate
:MasonInstall roslyn
```

Si Mason no lo encuentra: el package vive en el registry de Crashdummyy, que ya tienes configurado en [dotnet-roslyn.lua](../lua/plugins/dotnet-roslyn.lua). Si por alguna razón no carga el registry:
```vim
:lua require("mason-registry").refresh()
```

Fallback: instalar a mano (no depende de Mason):
```bash
dotnet tool install -g roslyn-language-server --prerelease \
  --source https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json
```

### "El debug no encuentra el .dll"

Probablemente compilaste en Release o el output está en una ruta inusual. Verifica:
```vim
:!ls bin/Debug/net*/
```
Si no hay `.dll` ahí: `:!dotnet build` primero, luego `<F5>`.

### "AddHttpClient subrayado en rojo (CS1061)"

Te falta el paquete. La extensión vive en `Microsoft.Extensions.Http`:
```vim
:!dotnet add package Microsoft.Extensions.Http --version 8.0.1
:!dotnet restore
:Roslyn restart
```

### "Demasiados hints inline molestos"

Los hints en gris ya son discretos, pero si los quieres ocultar completamente del inline (siguen apareciendo en la columna de signs y en Trouble):

Edita [diagnostics-loud.lua](../lua/plugins/diagnostics-loud.lua) y dentro de `virtual_text`:
```lua
virtual_text = {
  -- ...
  severity = { min = vim.diagnostic.severity.INFO }, -- oculta hints inline
}
```

### "Quiero desactivar una regla específica de Roslyn"

Crea `.editorconfig` en la raíz del repo:
```ini
root = true

[*.cs]
# Apagar "expression value is never used" (IDE0058)
dotnet_diagnostic.IDE0058.severity = none

# Bajar severidad de "use pattern matching" (IDE0083)
dotnet_diagnostic.IDE0083.severity = silent
```

Recarga: `:Roslyn restart`.

### "Cambié el .csproj y Roslyn no se entera"

```vim
:Roslyn restart
```

Si todavía no detecta cambios, el cache de Roslyn en `~/.cache/Roslyn/` puede estar corrupto. Bórralo y reinicia nvim.

---

## ⌨️ Convenciones de teclas

- `<leader>` = `Space` (LazyVim default)
- Prefijos:
  - `<leader>c*` → **C**ode actions de LazyVim (rename, format, action, diagnostics) — globales de LazyVim, **no tocar**
  - `<leader>cp*` → **P**ublish multi-plataforma .NET (`cpm/cpw/cpa/cpM/cpW`)
  - `<leader>cb/ct/cr/cw` → build/test/restore/watch .NET en split (custom, solo en `.cs`)
  - `<leader>d*` → **D**ebug (DAP genérico — todos los lenguajes)
  - `<leader>D*` → panel lateral del terminal (LazyVim/Snacks) — no usar
  - `<leader>n*` → **N**otifications (LazyVim/noice) — no usar
  - `<leader>;*` → **D**otnet (easy-dotnet user commands) ← prefix dedicado
  - `<leader>t*` → **T**est (neotest) + **t**erminal split (`tv`/`th`)
  - `<leader>D` → terminal lateral (panel a la derecha vía Snacks)
  - `<leader>R*` → **R**EST client (kulala, en `.http`)
  - `<leader>Q*` → **Q**uery / Database (vim-dadbod-ui)
  - `<leader>F*` → **F**lutter (flutter-tools, en `.dart`)
  - `<leader>x*` → diagnósticos / quickfix (Trouble)
  - `<leader>j*` → **J**ava (JDTLS)
  - `<leader>m*` → **M**aven
  - `<leader>g*` → **G**radle / **G**it

> 💡 **Cómo leer las notaciones**:
> - `<leader>;r` significa **secuencia**: Space → `;` → `r`. NO simultáneo. Sueltas cada tecla antes de la siguiente.
> - `<leader>;R` significa: Space → `;` → Shift+r (R mayúscula = Shift+r en la última tecla).
> - `<C-x>` significa Ctrl + x (la X en mayúscula es solo convención, no implica Shift).
> - `<S-Tab>` significa Shift + Tab.
> - `<CR>` = Enter, `<Esc>` = Escape, `<Space>` = barra espaciadora.

---

## 📂 Archivos de configuración

| Archivo | Qué define |
|---|---|
| [`lua/plugins/dotnet-roslyn.lua`](../lua/plugins/dotnet-roslyn.lua) | Roslyn LSP, inlay hints, code lens, registry de Crashdummyy en Mason |
| [`lua/plugins/dotnet-dap.lua`](../lua/plugins/dotnet-dap.lua) | netcoredbg con autodiscovery del `.dll` |
| [`lua/plugins/dotnet-keymaps.lua`](../lua/plugins/dotnet-keymaps.lua) | `<leader>c*` para build/test/run/watch/publish |
| [`lua/plugins/easy-dotnet.lua`](../lua/plugins/easy-dotnet.lua) | Project/sln picker, test runner, `:Secrets`; deshabilita su Roslyn interno |
| [`lua/plugins/debug.lua`](../lua/plugins/debug.lua) | DAP genérico (signs, highlights, UI layout) |
| [`lua/plugins/diagnostics-loud.lua`](../lua/plugins/diagnostics-loud.lua) | Virtual text + signs + colores + auto-float |
| [`lua/plugins/ufo.lua`](../lua/plugins/ufo.lua) | nvim-ufo: folds con info LSP + peek (`zK`) |
| [`lua/plugins/flutter.lua`](../lua/plugins/flutter.lua) | flutter-tools: Dart LSP + run/hot-reload/devices/dev-log |
| [`lua/plugins/signature.lua`](../lua/plugins/signature.lua) | Signature help compacto (blink) que no tapa el texto |
| [`lua/plugins/noice-quiet.lua`](../lua/plugins/noice-quiet.lua) | Silencia el spam de progreso LSP (jdtls) |
| [`lua/config/autocmds.lua`](../lua/config/autocmds.lua) | `preserve_blank_indent` + `auto_view` (folds/cursor) + spell off en docs |
| [`lua/config/options.lua`](../lua/config/options.lua) | Indentación (Dart=2), folds, listchars, NormalFloat bg sólido |
| [`scripts/gen-eclipse-classpath.sh`](../scripts/gen-eclipse-classpath.sh) | Genera `.classpath`/`.project` para proyectos IntelliJ legacy (JDTLS) |
| LazyVim extra `lang.dotnet` | csharpier, netcoredbg adapter base, treesitter c_sharp, neotest-vstest |

---

## 🔗 Recursos externos

- [Roslyn LSP (seblyng/roslyn.nvim)](https://github.com/seblyng/roslyn.nvim)
- [easy-dotnet](https://github.com/GustavEikaas/easy-dotnet.nvim)
- [netcoredbg](https://github.com/Samsung/netcoredbg)
- [nvim-ufo (folds)](https://github.com/kevinhwang91/nvim-ufo)
- [kulala.nvim (REST client)](https://github.com/mistweaverco/kulala.nvim) — [Docs oficiales](https://kulala.mwco.app/)
- [.NET 8 LTS support timeline](https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core)
- [Implicit usings reference](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/overview#implicit-using-directives)
- [Códigos de error CS de Roslyn](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-messages/)
