# Neovim · Atajos de teclado

Referencia completa de mi config LazyVim: defaults de LazyVim/snacks, extras activos y atajos propios.
`<leader>` = **Espacio**. Con which-key, pulsa `<leader>` y espera para ver el mapa; `<leader>sk` busca cualquier atajo por descripción; `<leader>?` lista los del buffer actual.
Generado el 2026-11-05 (rama `refactor/config-cleanup`).

Prefijos propios: `G` Gradle · `m` Maven · `;` .NET · `F` Flutter · `A` AWS · `M` SSHFS · `j` Java · `Q` Base de datos · `T` Terminales · `gv` Diffview · `v` VimWiki.

## Básico y ventanas

| Tecla | Acción |
|---|---|
| `<C-h/j/k/l>` | Ir a la ventana izq/abajo/arriba/der |
| `<C-↑/↓/←/→>` | Redimensionar ventana |
| `<leader>-` / `<leader>\|` | Split horizontal / vertical |
| `<leader>wd` | Cerrar ventana |
| `<leader>wm` / `<leader>uZ` | Maximizar ventana (toggle zoom) |
| `<C-w><space>` | Modo "hydra" de ventanas (which-key) |
| `<A-j>` / `<A-k>` | Mover línea/selección abajo/arriba |
| `<C-s>` | Guardar |
| `<Esc>` | Limpiar búsqueda resaltada |
| `<leader>ur` | Redibujar / limpiar hlsearch / actualizar diff |
| `<leader>fn` | Archivo nuevo |
| `<leader>l` / `<leader>L` | Lazy (plugins) / changelog de LazyVim |
| `<leader>qq` | Salir de todo |
| `<leader>qs` / `ql` / `qS` / `qd` | Sesión: restaurar / última / elegir / no guardar |
| `<leader>K` | `keywordprg` (man/help de la palabra) |
| `<leader>.` / `<leader>S` | Scratch buffer: toggle / elegir |
| `<leader>n` / `<leader>un` | Historial de notificaciones / descartar todas |
| `<leader>w` | Abrir archivo con la app del sistema |
| `gco` / `gcO` / `gcc` | Comentario abajo / arriba / toggle línea |
| `<C-space>` | Selección incremental (treesitter) |

## Buffers y tabs

| Tecla | Acción |
|---|---|
| `<S-h>` / `<S-l>` · `[b` / `]b` | Buffer anterior / siguiente |
| `[B` / `]B` | Mover el buffer en la bufferline |
| `<leader>bb` / `` <leader>` `` | Alternar con el buffer anterior |
| `<leader>,` / `<leader>fb` / `<leader>fB` | Picker de buffers (todos) |
| `<leader>bd` / `<leader>bD` | Cerrar buffer / buffer y ventana |
| `<leader>bo` / `bl` / `br` / `bi` | Cerrar otros / a la izquierda / a la derecha / invisibles |
| `<leader>bp` / `<leader>bP` | Fijar buffer / cerrar los no fijados |
| `<leader>bj` | Elegir buffer (pick) |
| `<leader><tab><tab>` / `d` / `o` | Tab nueva / cerrar / cerrar otras |
| `<leader><tab>[` / `]` / `f` / `l` | Tab anterior / siguiente / primera / última |

## Moverse: flash y surround

| Tecla | Acción |
|---|---|
| `s` + chars | Flash: saltar a cualquier texto en pantalla |
| `S` | Flash treesitter (seleccionar nodo) |
| `r` / `R` (operador) | Remote flash / búsqueda treesitter |
| `<C-s>` (en `/`) | Activar flash dentro de la búsqueda |
| `ys{motion}{char}` | nvim-surround: rodear (`ysiw"`) |
| `ds{char}` / `cs{old}{new}` | Quitar / cambiar el envoltorio |
| `S{char}` (visual) | Rodear la selección |

## Buscar y abrir (pickers de snacks)

| Tecla | Acción |
|---|---|
| `<leader><space>` / `<leader>ff` / `fF` | Archivos (raíz del proyecto / cwd) |
| `<leader>fg` | Archivos del git |
| `<leader>fr` / `<leader>fR` | Recientes (raíz / cwd) |
| `<leader>fc` | Archivos de la config de nvim |
| `<leader>fp` | Proyectos |
| `<leader>e` / `<leader>E` | Explorer (raíz / cwd) · `<leader>fe` / `fE` igual |
| `<leader>/` / `<leader>sg` / `sG` | Grep en el proyecto (raíz / cwd) |
| `<leader>sw` / `sW` | Grep de la palabra o selección (raíz / cwd) |
| `<leader>sb` / `<leader>sB` | Líneas del buffer / grep en buffers abiertos |
| `<leader>ss` / `<leader>sS` | Símbolos LSP del archivo / del workspace |
| `<leader>sd` / `<leader>sD` | Diagnósticos (todos / buffer) |
| `<leader>sr` | Buscar y reemplazar (grug-far) |
| `<leader>sh` / `sM` / `sk` / `sC` | Help / man / **keymaps** / comandos |
| `<leader>sm` / `sj` / `s"` / `su` | Marcas / jumps / registros / undotree |
| `<leader>sl` / `sq` | Location list / quickfix |
| `<leader>sa` / `sc` / `s/` | Autocmds / historial de comandos / de búsqueda |
| `<leader>st` / `<leader>sT` | TODOs / solo TODO·FIX·FIXME |
| `<leader>sR` | Reanudar el último picker |
| `<leader>sp` | Buscar spec de plugin |
| `<leader>si` / `<leader>sH` | Iconos / highlights |
| `<leader>sn*` | Noice: `a` todo, `h` historial, `l` último, `d` descartar |
| `<leader>:` | Historial de comandos |
| `<leader>uC` | Elegir colorscheme |

**Dentro de un picker:** `<C-j>/<C-k>` mover · `<CR>` abrir · `<C-s>` split · `<C-v>` vsplit · `<C-t>` tab · `<Tab>` marcar · `<C-a>` marcar todo · `<C-q>` a quickfix · `<a-i>` ignorados · `<a-h>` ocultos · `<a-p>` preview · `<a-m>` maximizar · `<a-w>` cambiar ventana · `<C-r><C-w>` insertar palabra · `?` ayuda · `/` alternar input/lista.

**Dentro del explorer:** `l`/`h` abrir/cerrar · `<BS>` subir · `.` enfocar carpeta · `a` crear · `d` borrar · `r` renombrar · `c` copiar · `m` mover · `y`/`p` yank/pegar · `o` abrir con el sistema · `P` preview · `K` **ver nombre completo (propio)** · `<a-m>` maximizar · `<leader>/` grep en la carpeta · `<C-t>` terminal ahí · `u` actualizar · `I`/`H` ignorados/ocultos · `Z` cerrar todo · `]g`/`[g` git · `]d`/`[d` diagnósticos.

## Código y LSP (`<leader>c*`, `g*`)

| Tecla | Acción |
|---|---|
| `gd` / `gr` / `gI` / `gy` / `gD` | Definición / referencias / implementación / tipo / declaración (pickers) |
| `K` | Hover (con border; `K` dos veces entra al float) |
| `gK` / `<C-k>` (insert) | Signature help |
| `]]` / `[[` · `<a-n>` / `<a-p>` | Siguiente / anterior referencia de la palabra |
| `<leader>ca` / `<leader>cA` | Code action / source action |
| `<leader>cr` / `<leader>cR` | Renombrar símbolo / renombrar archivo |
| `<leader>co` | Organizar imports |
| `<leader>cf` / `<leader>cF` | Formatear (buffer o selección) / solo lenguajes inyectados |
| `<leader>cc` / `<leader>cC` | Ejecutar codelens / refrescar codelens |
| `<leader>cd` | Diagnósticos de la línea (float) |
| `<leader>cl` | Info de LSP |
| `<leader>cm` | Mason |
| `<leader>cs` / `<leader>cS` | Símbolos / referencias LSP en Trouble |
| `<leader>ce` / `<leader>c8` | Encoding: reabrir con… / convertir a UTF-8 y guardar (`:Reopen cp1252`) |
| `<leader>cM` / `cD` / `cV` (TS) | Añadir imports faltantes / arreglar diagnósticos / versión de TS |
| `<leader>cp` (markdown) / `<leader>um` | Preview de markdown / toggle render |
| `<leader>uh` | Toggle inlay hints |

**Completado (blink):** `<C-n>`/`<C-p>` o `<C-j>`/`<C-k>` mover · `<CR>` aceptar · `<C-e>` cerrar · `<C-space>` abrir docs · `<Tab>`: aplica NES de Copilot → avanza snippet → acepta ghost de Supermaven.

## Diagnósticos y quickfix (`<leader>x*`)

| Tecla | Acción |
|---|---|
| `]d` / `[d` · `]e` / `[e` · `]w` / `[w` | Siguiente/anterior diagnóstico · error · warning |
| `<leader>xx` / `<leader>xX` | Trouble: diagnósticos (proyecto / buffer) |
| `<leader>xl` / `xq` · `<leader>xL` / `xQ` | Location list / quickfix (nativo · Trouble) |
| `]q` / `[q` | Siguiente / anterior item de quickfix o Trouble |
| `<leader>xt` / `<leader>xT` · `]t` / `[t` | TODOs en Trouble · saltar entre TODOs |
| `<leader>ud` / `<leader>ux` | Toggle diagnósticos global / **solo este buffer** |
| (automático) | Al reposar 500 ms sobre una línea con error se abre el float |

## Git

| Tecla | Acción |
|---|---|
| `<leader>gg` / `<leader>gG` | Lazygit (raíz / cwd) |
| `<leader>gs` / `<leader>gS` | Git status / stash (picker) |
| `<leader>gd` / `<leader>gD` | Diff por hunks / diff contra origin |
| `<leader>gl` / `<leader>gL` / `<leader>gf` | Log / log cwd / historial del archivo |
| `<leader>gb` | Blame de la línea |
| `<leader>gB` / `<leader>gY` | Abrir en GitHub / copiar URL |
| `<leader>gi` / `gI` · `<leader>gp` / `gP` | Issues (abiertos / todos) · PRs (abiertos / todos) |
| `]h` / `[h` · `]H` / `[H` | Siguiente / anterior hunk · último / primero |
| `<leader>ghs` / `ghr` / `ghu` | Stage / reset / deshacer stage del hunk (también visual) |
| `<leader>ghS` / `<leader>ghR` | Stage / reset del buffer |
| `<leader>ghp` · `ghb` / `ghB` | Preview del hunk · blame línea / buffer |
| `<leader>ghd` / `<leader>ghD` | Diff this / diff this ~ |
| `ih` (text object) | Seleccionar hunk |
| `<leader>uG` | Toggle gitsigns |
| **Diffview** `<leader>gvv` | Toggle Diffview |
| `<leader>gvo` / `<leader>gvc` | Abrir (working tree vs index) / cerrar |
| `<leader>gvh` / `<leader>gvH` / `<leader>gvl` | Historial del archivo / del repo / de la línea (visual: selección) |
| `<leader>gvm` / `<leader>gvp` | Diff vs main·master / rango de PR vs origin/main |
| (en Diffview) `g?` | Ayuda de los atajos internos |

## Debug (DAP) — extra `dap.core`

| Tecla | Acción |
|---|---|
| `F5` · `<leader>dc` | Continuar / iniciar |
| `F9` · `<leader>db` / `<leader>dB` | Breakpoint / breakpoint condicional |
| `F10` · `<leader>dO` | Step over |
| `F11` · `<leader>di` | Step into |
| `S-F11` · `<leader>do` | Step out |
| `<leader>dC` / `<leader>dg` | Correr hasta el cursor / ir a línea sin ejecutar |
| `<leader>da` / `<leader>dl` | Correr con argumentos / repetir la última |
| `<leader>dj` / `<leader>dk` | Bajar / subir en el stack |
| `<leader>dP` / `<leader>dt` | Pausar / terminar |
| `<leader>dr` / `<leader>ds` | REPL / sesión (en Rust: debuggables) |
| `<leader>de` (n/v) / `<leader>dw` | Evaluar expresión / hover de variables |
| `<leader>dv` / `<leader>df` | Scopes en float / elemento de dap-ui en float (propios) |
| `<leader>du` | Toggle dap-ui (se abre y cierra solo con la sesión) |
| `<leader>td` | Debug del test más cercano (neotest) |
| `<leader>dpp` / `dph` / `dps` | Profiler de snacks |

Configs disponibles al continuar: **.NET** "Launch (autodiscover .csproj)" y "Attach to process"; **JS/TS** Launch file, Attach, tsx, Jest, Vitest, Chrome 3000/5173; **Java** main classes detectadas por JDTLS + "Attach to remote JVM :5005" (`<leader>md` o `<leader>Gd`); **Go** vía neotest-golang; **Elixir** `mix test` / `mix run`.

## Tests — extra `test.core`

| Tecla | Acción |
|---|---|
| `<leader>tr` / `<leader>tt` / `<leader>tT` | Test más cercano / archivo / todos |
| `<leader>tl` / `<leader>tS` | Repetir último / detener |
| `<leader>ts` / `<leader>to` / `<leader>tO` | Resumen / salida / panel de salida |
| `<leader>tw` / `<leader>ta` / `<leader>td` | Watch del archivo / attach / debug |
| `<leader>;t` | Test runner de easy-dotnet (`<leader>r` correr, `R` todos, `d` debug, `p` stacktrace, `o` expandir, `E` nodo, `-`/`W` expandir/colapsar todo, `<C-r>` refrescar, `q` cerrar) |

## Terminales

| Tecla | Acción |
|---|---|
| `<C-/>` · `<leader>ft` / `<leader>fT` | Terminal flotante en la raíz / cwd (`2<C-/>` = terminal 2) |
| `<leader>1` / `2` / `3` | Terminales numeradas abajo (mismas que `n<C-/>`) |
| `<leader>Ts` | Terminal lateral derecha (instancia propia) |
| `<leader>Tl` / `<leader>Tv` (visual) | Enviar la línea / la selección a la terminal 1 (REPLs) |
| `<Esc><Esc>` · `q` · `<C-/>` | En terminal: modo normal · ocultar · ocultar |
| `<leader>Gh` / `GH` / `Gv` · `<leader>mh` | Gradle run en split h / debug / v · Maven run en split h |

## UI (`<leader>u*`)

| Tecla | Acción |
|---|---|
| `<leader>uf` / `<leader>uF` | Autoformat (global / buffer) |
| `<leader>us` / `uw` / `ul` / `uL` | Spell / wrap / números / números relativos |
| `<leader>ud` / `<leader>ux` | Diagnósticos (global / buffer) |
| `<leader>uh` / `uc` / `uT` | Inlay hints / conceal / treesitter highlight |
| `<leader>ub` / `uC` | Fondo oscuro-claro / colorscheme |
| `<leader>uD` / `ua` / `ug` / `uS` | Dim / animaciones / guías de indentación / smooth scroll |
| `<leader>uz` / `uZ` / `uA` | Zen / zoom / tabline |
| `<leader>uG` / `um` | Gitsigns / render de markdown |
| `<leader>ui` / `<leader>uI` | Inspeccionar posición / árbol treesitter |
| `<leader>uN` / `uM` / `ue` | IA: toggle NES de Copilot / toggle Supermaven / cambiar motor (excluyentes; se recuerda) |
| (persistente) | Los toggles se guardan entre sesiones (`util/toggle_persist.lua`) |

## IA — Sidekick (Copilot NES + CLIs)

| Tecla | Acción |
|---|---|
| `<Tab>` (normal) | Saltar al / aplicar el siguiente edit sugerido (NES) |
| `<Tab>` (insert) | NES → snippet → Supermaven |
| `<C-.>` / `<leader>aa` | Toggle del chat CLI |
| `<leader>ac` / `<leader>aC` / `<leader>ag` | Abrir Codex / Claude Code / Grok (n/v) |
| `<leader>as` / `<leader>ad` | Elegir CLI / desconectar sesión |
| `<leader>at` / `<leader>av` / `<leader>af` | Enviar esto / la selección / el archivo |
| `<leader>ap` | Elegir prompt (incluye `explain_error`) |

## .NET / C# (`<leader>;*`, `<leader>cp*`)

| Tecla | Acción |
|---|---|
| `<leader>;r` / `;d` / `;b` / `;t` | Run / debug / build / test runner (picker de proyecto) |
| `<leader>;R` / `;c` / `;w` | Restore / clean / watch run |
| `<leader>;n` / `;a` / `;o` / `;s` | New (plantillas) / add paquete o referencia / outdated / user secrets (`:Secrets`) |
| `<leader>;p` / `;P` / `;X` | Panel de terminales: toggle / mostrar / cerrar todas (`<Tab>`/`<S-Tab>` pestañas, `+` nueva, `X` cerrar) |
| `<leader>cpm` / `cpw` / `cpa` (.cs) | Publish self-contained: macOS arm64 / Windows x64 / ambos |
| `<leader>cpM` / `cpW` | Publish framework-dependent: macOS / Windows |
| `<leader>cpp` (.cs, .xml) | Publish con un `.pubxml` (picker si hay varios) |
| `:Dotnet …` | Todos los comandos de easy-dotnet (Roslyn LSP vía roslyn.nvim) |

## Java / Spring Boot

| Tecla | Acción |
|---|---|
| `<leader>jo` | Organizar imports (JDTLS) |
| `<leader>jv` / `jc` / `jm` (n y visual) | Extraer variable / constante / método |
| `<leader>jtc` / `<leader>jtm` | Test de la clase / del método (JDTLS) |
| `<leader>juc` | Actualizar config del proyecto |
| `<leader>mr` / `<leader>md` / `<leader>mh` | Maven: spring-boot:run / con JDWP :5005 / en split |
| `<leader>mb` / `mt` / `mc` / `mi` | Maven: package / test / clean / clean install -DskipTests |
| `<leader>mp` | Maven: run en un módulo (`-pl`) |
| `<leader>Gr` / `<leader>Gd` | Gradle: bootRun / bootRun --debug-jvm |
| `<leader>Gb` / `Gc` / `Gt` | Gradle: build / clean / test |

## Go · Rust · Flutter · Elixir

| Tecla | Acción |
|---|---|
| Go `<leader>cc` | Codelens (tests, generate, tidy, govulncheck…) |
| Go `<leader>tr` / `<leader>td` | Test / debug del test (neotest-golang + delve) |
| Rust `<leader>cR` / `<leader>dr` | Code action de RustLsp / debuggables |
| Rust `:RustLsp …` | runnables, expandMacro, openCargo, explainError… |
| Cargo.toml | crates.nvim: hover, completado y acciones de versión |
| `<leader>Fr` / `Fq` / `Fa` | Flutter: run / quit / attach |
| `<leader>Fl` / `<leader>FR` | Hot reload / hot restart |
| `<leader>Fd` / `Fe` / `FD` | Devices / emuladores / DevTools |
| `<leader>Fo` / `Fp` / `Fc` | Outline de widgets / panel de log / limpiar log |
| `<leader>Fs` / `Fg` / `Fu` / `Fb` | Ir a superclase / pub get / pub upgrade / brightness |
| Elixir `<leader>tr` / DAP | neotest-elixir / `mix test` y `mix run` |

## REST (kulala, `.http`) — `<leader>R*`

| Tecla | Acción |
|---|---|
| `<leader>Rs` / `<leader>Rr` | Enviar request / repetir la última |
| `<leader>Rt` / `<leader>Ri` | Alternar headers·body / inspeccionar request |
| `<leader>Rc` / `<leader>RC` | Copiar como cURL / pegar desde cURL |
| `<leader>Re` / `<leader>Rb` | Elegir entorno / scratchpad |
| `<leader>Rn` / `<leader>Rp` / `<leader>Rq` | Request siguiente / anterior / cerrar |
| `<leader>Rg` / `<leader>RS` | Descargar schema GraphQL / estadísticas |

## Base de datos (dadbod-ui) — `<leader>Q*`

| Tecla | Acción |
|---|---|
| `<leader>Qq` | Toggle DBUI |
| `<leader>Qa` / `<leader>Qf` | Añadir conexión / buscar buffer |
| `<leader>Qr` / `<leader>Ql` | Renombrar buffer / info de la última query |
| (en DBUI) `<CR>`/`o` · `R` · `A` | Abrir / refrescar / añadir conexión |
| (en query) `<leader>S` | Ejecutar la query (o la selección) |

## AWS (`<leader>A*`) · SSHFS (`<leader>M*`) · VimWiki

| Tecla | Acción |
|---|---|
| `<leader>Ap` | Picker de servicios AWS |
| `<leader>Al` / `As` / `Aw` / `Af` | Lambda / S3 / CloudWatch / CloudFormation |
| `<leader>Ag` / `Ad` / `Ai` / `Am` / `Ae` / `Av` | API Gateway / DynamoDB / IAM / Secrets / ECS / VPC |
| (en explorador AWS) `<CR>` · `F` · `R` | Detalle · filtrar · refrescar (borrar desactivado) |
| `<leader>Mm` / `<leader>Me` / `<leader>Mf` | SSHFS: montar host / explorar mount / buscar archivos |
| `<leader>Mu` / `<leader>MU` / `<leader>Mc` | Desmontar / desmontar todo / editar `~/.ssh/config` |
| `<leader>vw` / `<leader>vt` | VimWiki: índice / índice en tab nueva |

## Folds (nvim-ufo)

| Tecla | Acción |
|---|---|
| `za` / `zc` / `zo` | Toggle / cerrar / abrir fold bajo el cursor |
| `zC` / `zO` | Cerrar / abrir recursivamente |
| `zM` / `zR` | Cerrar / abrir todos (acelerados por ufo) |
| `zj` / `zk` | Siguiente / anterior fold |
| `zK` | Peek del contenido del fold (o hover LSP si no hay fold) |
| (persistente) | Folds, cursor y scroll se guardan por archivo (`mkview`) |

## Comandos útiles

`:Lazy` sync/clean/profile · `:LazyExtras` · `:LazyHealth` · `:checkhealth which-key` (atajos que se solapan) · `:Mason` · `:Reopen <enc>` · `:Dotnet` · `:Secrets` · `:RustLsp` · `:Flutter*` · `:DiffviewOpen origin/main...HEAD` · `:Sshfs*` · `:TSUpdate`
