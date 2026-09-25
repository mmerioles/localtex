# localtex

Overleaf, but on your own computer. Write LaTeX in VS Code and the PDF updates next to your code as you type. Works on **Mac and Windows**. No giant 5 GB install and no admin password.

Each document is its own folder, and you can upload any of them to Overleaf whenever you want.

## What you need first

- **A Mac or a Windows PC** (Windows 10 or 11). Linux works too.
- **VS Code**, which you already have.
- **An internet connection** for the first setup. It downloads about 250 MB.

That's it. The setup script installs everything else.

## Set it up (once)

1. Open this folder in VS Code (**File → Open Folder…**).
2. Open the terminal inside VS Code: **Terminal → New Terminal**.
3. Run the setup for your computer:

   | Mac | Windows |
   |---|---|
   | `./setup.sh` | `.\setup.cmd` |

4. Wait a few minutes. When you see `All good!`, **fully quit VS Code and open it again**. This lets it find LaTeX.

> Mac: if it says `permission denied`, run `bash setup.sh` instead.

**What just happened?** The script installed [TinyTeX](https://yihui.org/tinytex/), a small LaTeX distribution, into your user folder. It also installed a few common LaTeX packages and the **LaTeX Workshop** extension for VS Code, and added LaTeX to your PATH.

## How it's organized

```
template/         ← the starting point for every new document (don't write in here)
projects/
  example/        ← one folder = one document
    main.tex
    refs.bib
  my-essay/       ← your own projects go here, next to it
exports/          ← zip files for Overleaf end up here
```

Each project folder has everything it needs, so you can copy it, zip it, email it, or upload it to Overleaf as is.

## Start a new document

In the VS Code terminal:

| Mac | Windows |
|---|---|
| `./project.sh new my-essay` | `.\project.cmd new my-essay` |

This makes `projects/my-essay/` as a copy of `template/`. You can also just copy the `template` folder into `projects/` yourself and rename it. That works exactly the same.

> Use names without spaces, like `my-essay` or `thesis_ch1`.

## Writing (Overleaf-style)

1. Open `projects/my-essay/main.tex` in VS Code.
2. Click the **View LaTeX PDF** button in the top-right of the editor (or press `Cmd+Option+V` on Mac, `Ctrl+Alt+V` on Windows). The PDF opens side by side, to the right of your code.
3. Just type. About a second after you stop, the file saves itself, rebuilds, and the PDF refreshes.

Put images in a `figures` folder inside your project and use `\includegraphics{name}`. Put references in `refs.bib`.

Handy: `Cmd+click` (Windows: `Ctrl+click`) in the PDF jumps to that spot in your code.

Too many rebuilds? Change `files.autoSaveDelay` in `.vscode/settings.json` (it's in milliseconds). Or delete the two `files.autoSave` lines to rebuild only when you press Save.

## Send a project to Overleaf

| Mac | Windows |
|---|---|
| `./project.sh export my-essay` | `.\project.cmd export my-essay` |

This creates `exports/my-essay.zip` with just your source files (no build junk). In Overleaf: **New Project → Upload Project** and pick that zip.

**Going the other way:** in Overleaf, **Menu → Download → Source** gives you a zip. Unzip it into `projects/` and it's a project here too.

## All the commands

| What | Mac | Windows |
|---|---|---|
| New project | `./project.sh new NAME` | `.\project.cmd new NAME` |
| Build the PDF (without VS Code) | `./project.sh build NAME` | `.\project.cmd build NAME` |
| Zip for Overleaf | `./project.sh export NAME` | `.\project.cmd export NAME` |
| Delete temp files (.aux, .log…) | `./project.sh clean NAME` | `.\project.cmd clean NAME` |
| List projects | `./project.sh list` | `.\project.cmd list` |

## "File `something.sty' not found"

That means your document uses a LaTeX package that isn't installed yet. Fix:

1. Add the package name to `packages.txt`. It's usually the `.sty` name without the extension. One exception: TikZ is called `pgf`.
2. Run the setup again (`./setup.sh` or `.\setup.cmd`). It only installs what's new.

Not sure what the package is called? Run `tlmgr search --global --file something.sty` and it'll tell you.

## Something's not working?

- **"LaTeX not found", or VS Code says it can't find `latexmk`:** you probably didn't fully quit and reopen VS Code after setup. On Mac use **Cmd+Q**, not just closing the window.
- **Errors in your document:** look at the **Problems** tab at the bottom of VS Code. It shows the line number.

## Uninstall

- **Mac:** delete `~/Library/TinyTeX`, and remove the line marked `# added by localtex setup` from `~/.zshrc` and `~/.bash_profile`.
- **Windows:** run `tlmgr path remove` first, then delete `%APPDATA%\TinyTeX`.

Then uninstall the LaTeX Workshop extension in VS Code.
