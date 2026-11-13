@echo off
echo === setup_www_ricoh_com_vulnerabilities ===

if not exist "%~dp0patch_www_ricoh_com_vulnerabilities.py" (
    echo ERROR: patch_www_ricoh_com_vulnerabilities.py not found.
    pause
    exit /b 1
)

if not exist "%~dp0vulinfo_search.patch.js" (
    echo ERROR: vulinfo_search.patch.js not found.
    pause
    exit /b 1
)

if not exist "%~dp0template.patch.js" (
    echo ERROR: template.patch.js not found.
    pause
    exit /b 1
)

cd /d "%~dp0"

py --version >nul 2>&1
if not errorlevel 1 (
    py patch_www_ricoh_com_vulnerabilities.py
    goto :check
)

python --version >nul 2>&1
if not errorlevel 1 (
    python patch_www_ricoh_com_vulnerabilities.py
    goto :check
)

echo ERROR: Python not found. Please install Python and try again.
pause
exit /b 1

:check
if errorlevel 1 (
    echo ERROR: patch script failed.
    pause
    exit /b 1
)

echo.
echo Setup complete.
pause
