#!/usr/bin/env bash
# Delete LaTeX's temporary files (.aux, .log, ...). Keeps your PDFs.
# Usage: ./clean.sh        -> also pass --all to delete the PDFs too
set -euo pipefail
cd "$(dirname "$0")"
for d in "$HOME/Library/TinyTeX/bin/"* "$HOME/.TinyTeX/bin/"*; do
  [ -x "$d/latexmk" ] && export PATH="$d:$PATH" && break
done
FLAG="-c"; [ "${1:-}" = "--all" ] && FLAG="-C"
latexmk -quiet $FLAG >/dev/null
rm -f ./*.synctex.gz ./*.bbl ./*.run.xml
echo "Cleaned."
