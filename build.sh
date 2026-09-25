#!/usr/bin/env bash
# Build a .tex file into a PDF.  Usage: ./build.sh [file.tex]   (default: main.tex)
set -euo pipefail

for d in "$HOME/Library/TinyTeX/bin/"* "$HOME/.TinyTeX/bin/"*; do
  [ -x "$d/latexmk" ] && export PATH="$d:$PATH" && break
done
command -v latexmk >/dev/null || { echo "LaTeX not found - run ./setup.sh first."; exit 1; }

FILE="${1:-main.tex}"
cd "$(dirname "$FILE")"
latexmk -pdf -synctex=1 -interaction=nonstopmode -file-line-error "$(basename "$FILE")"
