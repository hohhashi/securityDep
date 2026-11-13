@echo off
echo === setup_www_ricoh_com_list_products ===
echo.

rem check that patch_www_ricoh_com_list_products.py exists in the same folder
if not exist "%~dp0patch_www_ricoh_com_list_products.py" (
    echo ERROR: patch_www_ricoh_com_list_products.py not found
    echo        place it in the same folder as this bat file
    pause
    exit /b 1
)

if not exist "%~dp0list_products.patch.js" (
    echo ERROR: list_products.patch.js not found.
    echo        place it in the same folder as this bat file
    pause
    exit /b 1
)

if not exist "%~dp0template.patch.js" (
    echo ERROR: template.patch.js not found.
    echo        place it in the same folder as this bat file
    pause
    exit /b 1
)

rem cd /d to the folder of this bat file
cd /d "%~dp0"

rem use py (Windows Python Launcher) if available
py --version >nul 2>&1
if not errorlevel 1 (
    py patch_www_ricoh_com_list_products.py
    goto :check
)
echo ERROR: py not found
echo        install Python from https://www.python.org/
pause
exit /b 1

:check
if errorlevel 1 (
    echo.
    echo ERROR: script finished with error
    pause
    exit /b 1
)
echo.
echo done
pause
