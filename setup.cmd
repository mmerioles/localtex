@echo off
rem One-time setup for Windows: installs TinyTeX (a small LaTeX distribution),
rem the LaTeX packages listed in packages.txt, and the VS Code LaTeX extension.
rem Safe to re-run any time (e.g. after adding a package to packages.txt).
setlocal EnableDelayedExpansion
cd /d "%~dp0"

rem --- 1. Find (or install) TinyTeX -------------------------------------------
call :findtex
if defined TEXBIN (
  echo ==^> TinyTeX already installed at !TEXBIN!
) else (
  echo ==^> Installing TinyTeX ^(takes a few minutes^)...
  curl.exe -fsSL -o "%TEMP%\install-tinytex.bat" https://yihui.org/tinytex/install-bin-windows.bat || goto :fail
  call "%TEMP%\install-tinytex.bat"
  cd /d "%~dp0"
  call :findtex
  if not defined TEXBIN goto :fail
)
set "PATH=!TEXBIN!;!PATH!"

rem Make sure LaTeX is on your PATH so VS Code can find it.
call tlmgr path add >nul 2>nul

rem --- 2. LaTeX packages --------------------------------------------------------
echo ==^> Updating the package manager...
call tlmgr update --self

set "PKGS="
for /f "usebackq eol=# tokens=*" %%L in ("packages.txt") do set "PKGS=!PKGS! %%L"
if defined PKGS (
  echo ==^> Installing LaTeX packages from packages.txt...
  call tlmgr install !PKGS!
)

rem --- 3. VS Code extension ----------------------------------------------------
set "CODE="
where code >nul 2>nul && set "CODE=code"
if not defined CODE if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" set "CODE=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd"
if not defined CODE if exist "%ProgramFiles%\Microsoft VS Code\bin\code.cmd" set "CODE=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
if defined CODE (
  echo ==^> Installing the LaTeX Workshop extension for VS Code...
  call "!CODE!" --install-extension James-Yu.latex-workshop --force
) else (
  echo !! Couldn't find VS Code's 'code' command.
  echo    Install the 'LaTeX Workshop' extension from the VS Code Extensions tab instead.
)

rem --- 4. Smoke test -----------------------------------------------------------
rem --- build a throwaway copy of the template
echo ==^> Test build...
set "TEST_DIR=%TEMP%\localtex-test"
if exist "%TEST_DIR%" rd /s /q "%TEST_DIR%"
xcopy /e /i /q "template" "%TEST_DIR%" >nul
pushd "%TEST_DIR%"
latexmk -pdf -interaction=nonstopmode main.tex >nul || (popd & echo !! Test build failed - see %TEST_DIR%\main.log & exit /b 1)
popd
rd /s /q "%TEST_DIR%"
echo ==^> All good! Now fully quit and reopen VS Code.
exit /b 0

:findtex
set "TEXBIN="
if exist "%APPDATA%\TinyTeX\bin\windows\tlmgr.bat" set "TEXBIN=%APPDATA%\TinyTeX\bin\windows"
if not defined TEXBIN if exist "%ProgramData%\TinyTeX\bin\windows\tlmgr.bat" set "TEXBIN=%ProgramData%\TinyTeX\bin\windows"
exit /b 0

:fail
echo !! Something went wrong. Scroll up for the error.
exit /b 1
