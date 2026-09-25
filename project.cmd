@echo off
rem Everyday commands for your LaTeX projects (each one is a folder in projects\).
rem
rem   project new <name>      start a new project from the template
rem   project build <name>    build projects\<name>\main.tex into a PDF
rem   project export <name>   zip it for Overleaf -> exports\<name>.zip
rem   project clean <name>    delete LaTeX's temporary files (keeps the PDF)
rem   project list            show your projects
setlocal
cd /d "%~dp0"

if exist "%APPDATA%\TinyTeX\bin\windows\latexmk.exe" set "PATH=%APPDATA%\TinyTeX\bin\windows;%PATH%"
if exist "%ProgramData%\TinyTeX\bin\windows\latexmk.exe" set "PATH=%ProgramData%\TinyTeX\bin\windows;%PATH%"

set "CMD=%~1"
set "NAME=%~2"
if /i "%CMD%"=="new"    goto :new
if /i "%CMD%"=="build"  goto :build
if /i "%CMD%"=="clean"  goto :clean
if /i "%CMD%"=="export" goto :export
if /i "%CMD%"=="list"   goto :list

:usage
echo   project new ^<name^>      start a new project from the template
echo   project build ^<name^>    build projects\^<name^>\main.tex into a PDF
echo   project export ^<name^>   zip it for Overleaf -^> exports\^<name^>.zip
echo   project clean ^<name^>    delete LaTeX's temporary files (keeps the PDF)
echo   project list            show your projects
exit /b 1

:new
if "%NAME%"=="" goto :usage
if exist "projects\%NAME%" (echo 'projects\%NAME%' already exists. & exit /b 1)
xcopy /e /i /q "template" "projects\%NAME%" >nul
echo Created projects\%NAME% - open projects\%NAME%\main.tex in VS Code and start writing.
exit /b 0

:build
call :need_project || exit /b 1
call :need_latex || exit /b 1
cd /d "projects\%NAME%"
latexmk -pdf -synctex=1 -interaction=nonstopmode -file-line-error main.tex
exit /b %errorlevel%

:clean
call :need_project || exit /b 1
call :need_latex || exit /b 1
cd /d "projects\%NAME%"
latexmk -quiet -c >nul
del /q *.synctex.gz *.bbl *.run.xml 2>nul
echo Cleaned projects\%NAME%
exit /b 0

:export
call :need_project || exit /b 1
if not exist exports mkdir exports
if exist "exports\%NAME%.zip" del "exports\%NAME%.zip"
rem Copy everything except build junk, the built PDF and hidden files, then zip it.
set "STAGE=%TEMP%\localtex-export-%NAME%"
if exist "%STAGE%" rd /s /q "%STAGE%"
robocopy "projects\%NAME%" "%STAGE%" /e /xd ".*" /xf *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.synctex.gz *.bbl *.blg *.bcf *.run.xml *.lof *.lot main.pdf ".*" >nul
powershell -NoProfile -Command "Compress-Archive -Path '%STAGE%\*' -DestinationPath 'exports\%NAME%.zip'"
rd /s /q "%STAGE%"
echo Made exports\%NAME%.zip - in Overleaf: New Project -^> Upload Project -^> pick that file.
exit /b 0

:list
dir /b /ad projects
exit /b 0

:need_project
if "%NAME%"=="" goto :usage
if not exist "projects\%NAME%\" (echo No project called '%NAME%'. Run: project list & exit /b 1)
exit /b 0

:need_latex
where latexmk >nul 2>nul || (echo LaTeX not found - run setup.cmd first. & exit /b 1)
exit /b 0
