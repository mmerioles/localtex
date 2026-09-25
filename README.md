# localtex

Write LaTeX in VS Code, get a PDF. No Overleaf, no giant 5 GB install, no admin password.

## What you need first

- **A Mac** (Linux works too).
- **VS Code** — you've got it.
- **An internet connection** for the first setup (downloads about 250 MB).

That's it. The setup script installs everything else.

## Set it up (once)

1. Open this folder in VS Code (**File → Open Folder…**).
2. Open the terminal inside VS Code: **Terminal → New Terminal**.
3. Run:

   ```bash
   ./setup.sh
   ```

4. Wait a few minutes. When you see `All good! main.pdf was built.`, you're done.

> If it says `permission denied`, run `bash setup.sh` instead.

**What just happened?** The script installed [TinyTeX](https://yihui.org/tinytex/) (a small LaTeX distribution) into your home folder (`~/Library/TinyTeX`), a few common LaTeX packages, and the **LaTeX Workshop** extension for VS Code. If it couldn't find VS Code's `code` command, it'll tell you — just install "LaTeX Workshop" from the Extensions tab yourself.

## Everyday use (Overleaf-style)

1. Open `main.tex` (or any `.tex` file) in VS Code.
2. Click the **View LaTeX PDF** button in the top-right of the editor (or press `Cmd+Option+V`). The PDF opens side by side, to the right of your code.
3. Just type. About a second after you stop, the file saves itself, rebuilds, and the PDF refreshes.

You only need to open the PDF once. VS Code remembers the layout next time you open the folder.

Handy: `Cmd+click` in the PDF jumps to that spot in your code. From your code, `Cmd+Option+J` jumps to that spot in the PDF.

Too many rebuilds? Change `files.autoSaveDelay` in `.vscode/settings.json` (it's in milliseconds), or delete the two `files.autoSave` lines to go back to rebuilding only when you press `Cmd+S`.

Prefer the terminal? These work too:

```bash
./build.sh             # builds main.tex -> main.pdf
./build.sh other.tex   # builds a different file
./clean.sh             # deletes the junk files (.aux, .log, ...), keeps the PDF
./clean.sh --all       # deletes the PDFs too
```

## "File `something.sty' not found"

That means you're using a LaTeX package that isn't installed yet. Fix:

1. Add the package name to `packages.txt` (e.g. `tikz` → add `pgf`; usually the name is just the `.sty` name).
2. Run `./setup.sh` again. It only installs what's new.

Not sure what the package is called? Run this and it'll tell you:

```bash
~/Library/TinyTeX/bin/*/tlmgr search --global --file something.sty
```

## What's in here

| File | What it's for |
|---|---|
| `setup.sh` | One-time install. Safe to re-run. |
| `build.sh` | Turns a `.tex` into a `.pdf`. |
| `clean.sh` | Removes LaTeX's temporary files. |
| `packages.txt` | Extra LaTeX packages to install. |
| `main.tex` | A starter document. Replace with your own. |
| `.vscode/` | Makes VS Code build on save using `build.sh`. |

## Uninstall

Delete `~/Library/TinyTeX` (on Linux: `~/.TinyTeX`) and uninstall the LaTeX Workshop extension. Nothing else was touched.
