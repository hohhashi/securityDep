@echo off
echo === setup_jp_ricoh_com_vul ===
echo.
if not exist "%~dp0patch_jp_ricoh_com_vul.py" (
    echo ERROR: patch_jp_ricoh_com_vul.py not found
    pause
    exit /b 1
)
cd /d "%~dp0"
py --version >nul 2>&1
if not errorlevel 1 (
    py patch_jp_ricoh_com_vul.py
    goto :check
)
echo ERROR: py not found
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
