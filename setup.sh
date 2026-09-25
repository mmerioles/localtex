#!/usr/bin/env bash
# One-time setup: installs TinyTeX (a small LaTeX distribution), the LaTeX
# packages listed in packages.txt, and the VS Code LaTeX extension.
# Safe to re-run any time (e.g. after adding a package to packages.txt).
set -euo pipefail
cd "$(dirname "$0")"

# --- 1. Find (or install) TinyTeX -------------------------------------------
find_tex_bin() {
  for d in "$HOME/Library/TinyTeX/bin/"* "$HOME/.TinyTeX/bin/"*; do
    [ -x "$d/tlmgr" ] && { echo "$d"; return 0; }
  done
  return 1
}

if TEX_BIN="$(find_tex_bin)"; then
  echo "==> TinyTeX already installed at $TEX_BIN"
else
  echo "==> Installing TinyTeX (takes a few minutes, no admin password needed)..."
  # --no-path: skip TinyTeX's own PATH setup (on a Mac it asks for an admin
  # password); we add it to your shell profile ourselves below.
  curl -fsSL "https://yihui.org/tinytex/install-bin-unix.sh" | sh -s - --no-path
  TEX_BIN="$(find_tex_bin)" || { echo "!! TinyTeX install failed"; exit 1; }
fi
export PATH="$TEX_BIN:$PATH"

# Put LaTeX on your PATH so VS Code (and your terminal) can find it.
LINE="export PATH=\"$TEX_BIN:\$PATH\"  # added by localtex setup"
if [ "$(uname)" = Darwin ]; then RCS=".zshrc .bash_profile"; else RCS=".bashrc .zshrc"; fi
for f in $RCS; do
  rc="$HOME/$f"
  if ! grep -qF "# added by localtex setup" "$rc" 2>/dev/null; then
    echo "==> Adding LaTeX to your PATH in $rc"
    printf '\n%s\n' "$LINE" >> "$rc"
  fi
done

# --- 2. LaTeX packages --------------------------------------------------------
echo "==> Updating the package manager..."
tlmgr update --self || true

PKGS=$(grep -v '^\s*#' packages.txt | tr -s ' \n' ' ')
if [ -n "${PKGS// /}" ]; then
  echo "==> Installing LaTeX packages from packages.txt..."
  # shellcheck disable=SC2086
  tlmgr install $PKGS
fi

# --- 3. VS Code extension ----------------------------------------------------
CODE_BIN="$(command -v code || true)"
MAC_CODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
[ -z "$CODE_BIN" ] && [ -x "$MAC_CODE" ] && CODE_BIN="$MAC_CODE"

if [ -n "$CODE_BIN" ]; then
  echo "==> Installing the LaTeX Workshop extension for VS Code..."
  "$CODE_BIN" --install-extension James-Yu.latex-workshop --force
else
  echo "!! Couldn't find VS Code's 'code' command."
  echo "   Install the 'LaTeX Workshop' extension from the VS Code Extensions tab instead."
fi

# --- 4. Smoke test: build a throwaway copy of the template ------------------
echo "==> Test build..."
TEST_DIR="$(mktemp -d)"
cp -R template/. "$TEST_DIR"
(cd "$TEST_DIR" && latexmk -pdf -interaction=nonstopmode main.tex >/dev/null) \
  || { echo "!! Test build failed - see $TEST_DIR/main.log"; exit 1; }
rm -rf "$TEST_DIR"
echo "==> All good! Now fully quit and reopen VS Code."
