# Config minimalista para servers (solo edición)

`init.lua` autocontenido para editar archivos en un server Linux por SSH.
**Sin LazyVim, sin Mason, sin LSP, sin toolchains** — arranque <1s, cero errores
en un server pelado. Solo: telescope + neo-tree + treesitter + catppuccin + QoL.

> Para desarrollo real (LSP, debug, etc.) usa la config completa de la raíz del
> repo, no esta.

---

## Requisitos en el server

| Paquete | ¿Obligatorio? | Para qué |
|---|---|---|
| **neovim ≥ 0.10** (tarball oficial) | ✅ Sí | El editor. **NO uses apt/snap** (LuaJIT viejo → rompe plugins) |
| **git** | ✅ Sí | lazy.nvim clona los plugins por git |
| **build-essential** (gcc) | ✅ Sí | Compilar los parsers de treesitter |
| **ripgrep** (`rg`) | ⭐ Recomendado | `<leader>fg` (grep en el proyecto) |
| **fd** (`fd-find`) | Opcional | Búsqueda de archivos más rápida |

> No necesitas `unzip` (no hay Mason) ni Nerd Font en el server (los iconos los
> renderiza tu terminal local, ej. Ghostty en tu Mac).

---

## Instalación paso a paso

### 1. Dependencias

```bash
sudo apt update
sudo apt install -y git ripgrep fd-find build-essential
# alias fd (Ubuntu instala el binario como 'fdfind')
mkdir -p ~/.local/bin && ln -sf "$(which fdfind)" ~/.local/bin/fd
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc   # o ~/.zshrc
```

### 2. Neovim (tarball oficial — NO apt/snap)

```bash
uname -m    # x86_64 o aarch64
```

**x86_64:**
```bash
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

**aarch64 (ARM):** cambia `x86_64` por `arm64` en las 3 líneas.

Verifica:
```bash
hash -r
nvim --version | head -1            # v0.12.x
ldd "$(which nvim)" | grep -i luajit # debe salir VACÍO (LuaJIT embebido)
```

### 3. La config (un solo archivo)

```bash
mkdir -p ~/.config/nvim
curl -fLo ~/.config/nvim/init.lua \
  https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/server/init.lua
```

### 4. Abrir

```bash
nvim
```
lazy.nvim se bootstrappea, instala ~10 plugins ligeros y compila parsers. Listo.

---

## Keymaps

`<leader>` = `Space`.

| Tecla | Acción |
|---|---|
| `<leader>e` | Toggle árbol (neo-tree) |
| `<leader>o` | Focus en el árbol |
| `<leader>ff` · `<leader><space>` | Buscar archivos |
| `<leader>fg` | Grep (texto en el proyecto) |
| `<leader>fb` | Buffers |
| `<leader>fr` | Archivos recientes |
| `<leader>/` | Buscar en el buffer actual |
| `<leader>w` · `<leader>q` | Guardar · cerrar |
| `<C-h/j/k/l>` | Moverse entre splits |
| `<A-j>` · `<A-k>` | Mover línea abajo/arriba |

---

## Notas

- **Clipboard SSH (OSC52)**: al hacer `yank`, el texto llega al portapapeles de
  tu máquina local (si el terminal lo soporta, ej. Ghostty). Solo se activa en SSH.
- **Dotfiles visibles**: el árbol muestra `.bashrc`, `.env`, etc. (en server los quieres ver).
- **Sin auto-update**: lazy no molesta con chequeos de versión.
- Para actualizar la config en el server: repite el `curl` del paso 3.
