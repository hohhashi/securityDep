@echo off
echo === setup_www_ricoh_com_vul ===
echo.

rem Check that patch script exists in same folder as this bat file
if not exist "%~dp0patch_www_ricoh_com_vul.py" (
    echo ERROR: patch_www_ricoh_com_vul.py not found
    echo        Place it in the same folder as this bat file
    pause
    exit /b 1
)

rem Move to the folder containing this bat file
cd /d "%~dp0"

rem Use py (Windows Python Launcher) if available
py --version >nul 2>&1
if not errorlevel 1 (
    py patch_www_ricoh_com_vul.py
    goto :check
)
echo ERROR: py not found
echo        Install Python from https://www.python.org/
pause
exit /b 1

:check
if errorlevel 1 (
    echo.
    echo ERROR: Script exited with an error
    pause
    exit /b 1
)
echo.
echo done
pause
