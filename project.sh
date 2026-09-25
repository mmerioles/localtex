#!/usr/bin/env bash
# Everyday commands for your LaTeX projects (each one is a folder in projects/).
#
#   ./project.sh new <name>      start a new project from the template
#   ./project.sh build <name>    build projects/<name>/main.tex into a PDF
#   ./project.sh export <name>   zip it for Overleaf -> exports/<name>.zip
#   ./project.sh clean <name>    delete LaTeX's temporary files (keeps the PDF)
#   ./project.sh list            show your projects
set -euo pipefail
cd "$(dirname "$0")"

for d in "$HOME/Library/TinyTeX/bin/"* "$HOME/.TinyTeX/bin/"*; do
  [ -x "$d/latexmk" ] && export PATH="$d:$PATH" && break
done

usage() { sed -n '4,8p' "$0" | sed 's/^# *//'; exit 1; }
CMD="${1:-}"; NAME="${2:-}"; DIR="projects/$NAME"

need_project() {
  [ -n "$NAME" ] || usage
  [ -d "$DIR" ] || { echo "No project called '$NAME'. Run ./project.sh list to see them."; exit 1; }
}
need_latex() {
  command -v latexmk >/dev/null || { echo "LaTeX not found - run ./setup.sh first."; exit 1; }
}

case "$CMD" in
  new)
    [ -n "$NAME" ] || usage
    [ -e "$DIR" ] && { echo "'$DIR' already exists."; exit 1; }
    cp -R template "$DIR"
    echo "Created $DIR - open $DIR/main.tex in VS Code and start writing."
    ;;
  build)
    need_project; need_latex
    cd "$DIR" && latexmk -pdf -synctex=1 -interaction=nonstopmode -file-line-error main.tex
    ;;
  clean)
    need_project; need_latex
    cd "$DIR" && latexmk -quiet -c >/dev/null
    rm -f ./*.synctex.gz ./*.bbl ./*.run.xml
    echo "Cleaned $DIR"
    ;;
  export)
    need_project
    mkdir -p exports
    rm -f "exports/$NAME.zip"
    # Leave out build junk, the built PDF, and hidden files - Overleaf rebuilds it all.
    (cd "$DIR" && zip -rq "../../exports/$NAME.zip" . -x \
      '*.aux' '*.log' '*.out' '*.toc' '*.fls' '*.fdb_latexmk' '*.synctex.gz' \
      '*.bbl' '*.blg' '*.bcf' '*.run.xml' '*.lof' '*.lot' 'main.pdf' '.*' '*/.*')
    echo "Made exports/$NAME.zip - in Overleaf: New Project -> Upload Project -> pick that file."
    ;;
  list)
    ls -1 projects
    ;;
  *)
    usage
    ;;
esac
