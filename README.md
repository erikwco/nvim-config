# 💤 Neovim config — polyglot dev (C# · Go · Java · React/TS · Rust)

A [LazyVim](https://github.com/LazyVim/LazyVim)-based Neovim setup tuned for
**full-stack, multi-language development** with first-class LSP, debugging (DAP),
testing, formatting, and a few quality-of-life extras (REST client, DB browser,
persistent folds).

Built and refined for real day-to-day work across **.NET Core, Go, Java/Spring,
React (TypeScript), and Rust**, with lighter support for Oracle/PL-SQL and HTTP
APIs. Runs on **macOS and Linux**.

> 📓 A full, day-to-day **cheatsheet** lives in
> [`docs/dotnet-cheatsheet.md`](docs/dotnet-cheatsheet.md) — keymaps, workflows,
> and troubleshooting for every language and tool below.

---

## ✨ What's inside

### Languages

| Language | LSP | Debug (DAP) | Test | Format |
|---|---|---|---|---|
| **C# / .NET** | Roslyn (`seblyng/roslyn.nvim`) — real autoimport | netcoredbg, autodiscovers `.dll` | neotest-vstest + easy-dotnet | csharpier |
| **Go** | gopls (staticcheck, gofumpt) | nvim-dap-go (delve) | neotest-go | goimports + gofumpt |
| **Java** | JDTLS + Lombok, multi-JDK (8/11/17/21) | java-debug + vscode-java-test | neotest-java | google-java-format |
| **React / TS / JS** | vtsls | js-debug (Node, Jest, Vitest, Chrome) | — | prettier + eslint |
| **Rust** | rustaceanvim (rust-analyzer + clippy) | codelldb | — | rustfmt |
| **Groovy / Gradle** | treesitter (highlight) | — | — | — |
| **Templ / HTMX** | templ LSP | — | — | templ fmt |

### Tooling & QoL

- **easy-dotnet** — run/build/test/publish/secrets with a project picker, plus a
  tabbed terminal panel. Multi-platform `dotnet publish` (osx-arm64, win-x64) and
  `.pubxml` profile support (like Rider).
- **kulala.nvim** — REST client with `.http` files (Postman-style, versioned in git).
- **vim-dadbod-ui** — SQL client / DB browser (PostgreSQL, Oracle, MySQL, SQLite).
- **nvim-ufo** — smarter folds (LSP-aware) with **persistence across sessions**.
- **Supermaven** — AI inline completion.
- **diagnostics-loud** — high-visibility diagnostics (severity-colored virtual
  text + signs + auto-float on hover).
- Sensible defaults: 4-space indent (2 for JS/TS/JSON/YAML, tabs for Go),
  preserved blank-line indentation, persistent folds + cursor position.

### LazyVim extras enabled

`lang.dotnet` · `lang.typescript` · `lang.json` · `lang.docker` · `lang.markdown`
· `lang.tailwind` · `lang.sql` · `util.rest` · `formatting.prettier` ·
`linting.eslint`

---

## 📦 Requirements

- **Neovim ≥ 0.10** (developed on 0.12.x)
- **git**, **curl/wget**, **ripgrep**, **fd**, a **C compiler** (for treesitter), **unzip**
- A **Nerd Font** (e.g. JetBrainsMono Nerd Font) for icons
- Per-language toolchains you actually use (install only what you need):
  - **.NET 8 SDK** + `dotnet tool install --global EasyDotnet`
  - **Go**, **JDK 21** (+ others via [mise](https://mise.jdx.dev) if multi-JDK), **Node/Bun**, **Rust** (rustup)
  - **psql** for the DB browser (PostgreSQL); Oracle Instant Client for Oracle

---

## 🚀 Installation

> ⚠️ Back up any existing config first: `mv ~/.config/nvim ~/.config/nvim.bak`

```bash
git clone https://github.com/<YOUR_USERNAME>/<REPO>.git ~/.config/nvim
nvim
```

On first launch LazyVim bootstraps lazy.nvim and installs all plugins. Then:

```vim
:MasonUpdate
" C# (Roslyn lives in a community registry, already configured):
:MasonInstall roslyn
" JS/TS/CSS LSPs, etc. are installed automatically by their extras
```

### macOS / Linux system deps (quick reference)

**macOS (Homebrew):**
```bash
brew install neovim ripgrep fd fzf
brew install --cask font-jetbrains-mono-nerd-font
```

**Ubuntu/Debian:**
```bash
sudo apt install -y neovim git curl ripgrep fd-find build-essential unzip nodejs npm
# If apt's neovim is < 0.10:
sudo add-apt-repository ppa:neovim-ppa/unstable -y && sudo apt update && sudo apt install -y neovim
```

---

## ⌨️ Keymap conventions

Leader is `<Space>`. Prefixes are namespaced to avoid collisions:

| Prefix | Area |
|---|---|
| `<leader>c*` | LazyVim code actions (rename, format, diagnostics) |
| `<leader>cp*` | .NET publish (multi-platform) |
| `<leader>;*` | **Dotnet** (easy-dotnet: run/build/test/secrets/publish) |
| `<leader>d*` | **Debug** (DAP — all languages) |
| `<leader>D` | Side terminal panel |
| `<leader>t*` | **Test** (neotest) + terminal splits |
| `<leader>j*` | **Java** (JDTLS refactors) |
| `<leader>m*` | **Maven** · `<leader>g*` Gradle/Git |
| `<leader>R*` | **REST** client (kulala, in `.http`) |
| `<leader>Q*` | **Query** / Database (vim-dadbod-ui) |
| `<leader>x*` | Diagnostics / quickfix (Trouble) |

Fold/debug/test keymaps and the full reference are in the
[**cheatsheet**](docs/dotnet-cheatsheet.md).

---

## 🗂️ Structure

```
.
├── init.lua
├── lazyvim.json            # enabled LazyVim extras
├── lazy-lock.json          # pinned plugin versions (committed on purpose)
├── lua/
│   ├── config/             # options, keymaps, autocmds, lazy bootstrap
│   └── plugins/            # one file per concern (per-language + tooling)
└── docs/
    ├── dotnet-cheatsheet.md
    └── examples/sap-example.http
```

> Note: several plugin files are prefixed `go-*` for historical reasons — many
> configure cross-language tooling (treesitter, telescope, conform, etc.), not
> just Go.

---

## 📝 Notes

- `lazy-lock.json` **is committed** — it pins plugin versions so clones are
  reproducible. Run `:Lazy update` to bump.
- Java uses [mise](https://mise.jdx.dev)-managed JDKs (8/11/17/21). JDTLS launches
  on a fixed JDK 21 regardless of a project's pinned version (avoids legacy-Java
  crashes). Adjust paths in
  [`lua/plugins/jdtls-lombok.lua`](lua/plugins/jdtls-lombok.lua) if you don't use mise.
- The Roslyn package is pulled from the
  [Crashdummyy mason registry](https://github.com/Crashdummyy/mason-registry)
  (configured in [`lua/plugins/dotnet-roslyn.lua`](lua/plugins/dotnet-roslyn.lua)).

---

## 📄 License

See [LICENSE](LICENSE). Configuration shared as-is — fork it, adapt it, make it yours.
