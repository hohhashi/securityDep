@echo off
echo === setup_jp_ricoh_com_product ===
echo.

rem batファイルと同じフォルダにpyファイルが存在することを確認
if not exist "%~dp0patch_jp_ricoh_com_product.py" (
    echo ERROR: patch_jp_ricoh_com_product.py が見つかりません
    echo        このbatファイルと同じフォルダに置いてください
    pause
    exit /b 1
)

rem cd /d で bat のあるフォルダに移動
cd /d "%~dp0"

rem py (Windows Python Launcher) を優先して使用
py --version >nul 2>&1
if not errorlevel 1 (
    py patch_jp_ricoh_com_product.py
    goto :check
)
echo ERROR: py が見つかりません
echo        https://www.python.org/ から Python をインストールしてください
pause
exit /b 1

:check
if errorlevel 1 (
    echo.
    echo ERROR: スクリプトがエラーで終了しました
    pause
    exit /b 1
)
echo.
echo done
pause
