@echo off
echo === setup_jp_ricoh_com_vulnerabilities ===
echo.

rem このbatファイルと同じフォルダにpyファイルがあることを確認
if not exist "%~dp0patch_jp_ricoh_com_vulnerabilities.py" (
    echo ERROR: patch_jp_ricoh_com_vulnerabilities.py が見つかりません
    echo        このbatファイルと同じフォルダに置いてください
    pause
    exit /b 1
)

rem Pythonが使えるか確認
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: python が見つかりません
    echo        Python をインストールするか、PATH を通してください
    pause
    exit /b 1
)

rem パッチ適用
cd /d "%~dp0"
python patch_jp_ricoh_com_vulnerabilities.py
if errorlevel 1 (
    echo.
    echo ERROR: スクリプトがエラーで終了しました
    pause
    exit /b 1
)

echo.
echo done
pause
