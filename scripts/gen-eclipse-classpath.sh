#!/usr/bin/env bash
# ============================================================================
# gen-eclipse-classpath.sh
# ============================================================================
# Genera .classpath + .project (metadata Eclipse) para que JDTLS (Neovim/
# nvim-jdtls) entienda proyectos Java legacy de IntelliJ IDEA que NO usan
# Maven ni Gradle. Sin estos archivos, JDTLS no sabe el source root ni el
# classpath, y marca todos los imports/paquetes como "cannot be resolved".
#
# USO:
#   ./gen-eclipse-classpath.sh [ruta-proyecto] [java-version]
#     ruta-proyecto: default = directorio actual
#     java-version:  opcional, fuerza el JRE (ej. "17", "11", "JavaSE-17").
#                    Útil cuando hay error "StringConcatFactory cannot be
#                    resolved": un jar compilado en Java 9+ en un proyecto
#                    Java 8. Fuerza a JavaSE-17 para resolver (los javax.* los
#                    provee lib/, no se rompen). Ej:
#                       gen-eclipse-classpath.sh . 17
#
# QUÉ HACE:
#   1. Detecta source root(s): lee <sourceFolder> del .iml; fallback a src/
#   2. Detecta versión de Java: arg 2 > .mise.toml / .tool-versions > JavaSE-17
#   3. Lista todos los .jar bajo lib/ (recursivo)
#   4. Genera .classpath + .project
#   5. Los añade al .gitignore (para no ensuciar el repo de IntelliJ)
#   6. Limpia el workspace de jdtls del proyecto (fuerza re-indexado)
#
# Compatible con el bash 3.2 de macOS (sin mapfile).
# ============================================================================

set -eo pipefail

PROJECT_DIR="${1:-$(pwd)}"
if [ ! -d "$PROJECT_DIR" ]; then
  echo "✗ No existe el directorio: $PROJECT_DIR" >&2
  exit 1
fi
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
cd "$PROJECT_DIR"

echo "▸ Proyecto: $PROJECT_NAME"
echo "  $PROJECT_DIR"

# ── 1. Source roots ─────────────────────────────────────────────────────────
SRC_ROOTS=""
IML_FILE="$(find . -maxdepth 1 -name '*.iml' 2>/dev/null | head -1)"
if [ -n "$IML_FILE" ]; then
  # Extrae paths de <sourceFolder url="file://$MODULE_DIR$/XXX" ...> (sin tests)
  while IFS= read -r line; do
    path="$(printf '%s' "$line" | sed -E 's|.*\$MODULE_DIR\$/([^"]*)".*|\1|')"
    if [ -n "$path" ] && [ -d "$path" ]; then
      SRC_ROOTS="$SRC_ROOTS$path
"
    fi
  done < <(grep 'sourceFolder' "$IML_FILE" 2>/dev/null | grep -v 'isTestSource="true"' || true)
fi
# Fallback: src/ si el .iml no dio nada
if [ -z "$SRC_ROOTS" ] && [ -d src ]; then
  SRC_ROOTS="src
"
fi
if [ -z "$SRC_ROOTS" ]; then
  echo "✗ No se encontró source root (ni en .iml ni src/). Aborto." >&2
  exit 1
fi
echo "▸ Source roots:"
printf '%s' "$SRC_ROOTS" | sed 's/^/    /'

# ── 2. Versión de Java ──────────────────────────────────────────────────────
# Prioridad: override (arg 2) > .mise.toml/.tool-versions > JavaSE-17
JAVA_VER="JavaSE-17"
JAVA_SRC="default"
OVERRIDE="${2:-}"
if [ -n "$OVERRIDE" ]; then
  case "$OVERRIDE" in
    JavaSE-*) JAVA_VER="$OVERRIDE" ;;
    1.8|8)    JAVA_VER="JavaSE-1.8" ;;
    11)       JAVA_VER="JavaSE-11" ;;
    17)       JAVA_VER="JavaSE-17" ;;
    21)       JAVA_VER="JavaSE-21" ;;
    *)        JAVA_VER="JavaSE-$OVERRIDE" ;;
  esac
  JAVA_SRC="override (arg)"
else
  RAW=""
  if [ -f .mise.toml ]; then
    RAW="$(grep -E '^[[:space:]]*java[[:space:]]*=' .mise.toml 2>/dev/null | head -1)"
  elif [ -f .tool-versions ]; then
    RAW="$(grep -E '^java ' .tool-versions 2>/dev/null | head -1)"
  fi
  case "$RAW" in
    *1.8*|*-8*|*8.9*|*zulu-8*) JAVA_VER="JavaSE-1.8" ;;
    *-11*|*11.*)               JAVA_VER="JavaSE-11" ;;
    *-17*|*17.*)               JAVA_VER="JavaSE-17" ;;
    *-21*|*21.*)               JAVA_VER="JavaSE-21" ;;
  esac
  JAVA_SRC="${RAW:-'default, sin .mise.toml/.tool-versions'}"
fi
echo "▸ Java: $JAVA_VER  (de: $JAVA_SRC)"

# ── 3. Contar jars ──────────────────────────────────────────────────────────
JAR_COUNT="$(find lib -name '*.jar' 2>/dev/null | wc -l | tr -d ' ')"
echo "▸ Jars bajo lib/: $JAR_COUNT"

# ── 4. Generar .classpath ───────────────────────────────────────────────────
{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<classpath>'
  printf '%s' "$SRC_ROOTS" | while IFS= read -r src; do
    [ -n "$src" ] && printf '\t<classpathentry kind="src" path="%s"/>\n' "$src"
  done
  printf '\t<classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/%s"/>\n' "$JAVA_VER"
  find lib -name '*.jar' 2>/dev/null | sort | while IFS= read -r jar; do
    printf '\t<classpathentry kind="lib" path="%s"/>\n' "$jar"
  done
  printf '\t<classpathentry kind="output" path="bin"/>\n'
  echo '</classpath>'
} > .classpath
echo "✓ .classpath generado ($JAR_COUNT jars + $(printf '%s' "$SRC_ROOTS" | grep -c . ) src root(s) + $JAVA_VER)"

# ── 5. Generar .project ─────────────────────────────────────────────────────
cat > .project <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<projectDescription>
	<name>${PROJECT_NAME}</name>
	<comment>Eclipse metadata para JDTLS/Neovim (proyecto IntelliJ legacy)</comment>
	<projects>
	</projects>
	<buildSpec>
		<buildCommand>
			<name>org.eclipse.jdt.core.javabuilder</name>
			<arguments>
			</arguments>
		</buildCommand>
	</buildSpec>
	<natures>
		<nature>org.eclipse.jdt.core.javanature</nature>
	</natures>
</projectDescription>
EOF
echo "✓ .project generado"

# ── 6. .gitignore ───────────────────────────────────────────────────────────
if [ -f .gitignore ] && grep -qxF '.classpath' .gitignore; then
  echo "  .gitignore ya ignora la metadata Eclipse"
else
  printf '\n# Neovim/JDTLS (Eclipse metadata) — no versionar\n.classpath\n.project\n.settings/\nbin/\n' >> .gitignore
  echo "✓ .gitignore actualizado (ignora .classpath/.project/.settings/bin)"
fi

# ── 7. Limpiar workspace de jdtls ───────────────────────────────────────────
WS="$HOME/.cache/jdtls-workspace/$PROJECT_NAME"
if [ -d "$WS" ]; then
  rm -rf "$WS"
  echo "✓ Workspace jdtls limpiado ($PROJECT_NAME) → re-indexará al reabrir"
fi

echo ""
echo "✅ Listo. Cierra y reabre el proyecto en Neovim; JDTLS re-indexará con la"
echo "   nueva metadata (puede tardar según cantidad de jars/código)."
