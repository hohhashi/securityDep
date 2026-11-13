@echo off
echo === setup_jp_ricoh_com_product ===
echo.

rem Check that patch_jp_ricoh_com_product.py exists in the same folder as this bat file
if not exist "%~dp0patch_jp_ricoh_com_product.py" (
    echo ERROR: patch_jp_ricoh_com_product.py not found
    echo        Place it in the same folder as this bat file
    pause
    exit /b 1
)

rem Move to the folder where this bat file is located
cd /d "%~dp0"

rem Use py (Windows Python Launcher) if available
py --version >nul 2>&1
if not errorlevel 1 (
    py patch_jp_ricoh_com_product.py
    goto :check
)
echo ERROR: py not found
echo        Install Python from https://www.python.org/
pause
exit /b 1

:check
if errorlevel 1 (
    echo.
    echo ERROR: Script finished with an error
    pause
    exit /b 1
)
echo.
echo done
pause
