@echo off
rem ===============================================
rem clean_env_dev_ja.bat
rem
rem 各ページフォルダ (adv, list_products, product,
rem vul, vulnerabilities) の jp.ricoh.com フォルダと
rem .vscode フォルダ、および
rem env_dev フォルダを削除してクリーンな状態に戻します。
rem ===============================================

set BASE=%~dp0

echo ======================================
echo  クリーン処理を開始します
echo  削除対象:
echo    adv\jp.ricoh.com
echo    adv\.vscode
echo    list_products\jp.ricoh.com
echo    list_products\.vscode
echo    product\jp.ricoh.com
echo    product\.vscode
echo    vul\jp.ricoh.com
echo    vul\.vscode
echo    vulnerabilities\jp.ricoh.com
echo    vulnerabilities\.vscode
echo    env_dev
echo    .vscode
echo ======================================
echo.
set /p CONFIRM=本当に削除しますか？ (y/N): 
if /i not "%CONFIRM%"=="y" (
    echo キャンセルしました。
    pause
    exit /b 0
)

call :clean_dir "%BASE%adv\jp.ricoh.com"             "adv\jp.ricoh.com"
call :clean_dir "%BASE%adv\.vscode"                  "adv\.vscode"
call :clean_dir "%BASE%list_products\jp.ricoh.com"   "list_products\jp.ricoh.com"
call :clean_dir "%BASE%list_products\.vscode"        "list_products\.vscode"
call :clean_dir "%BASE%product\jp.ricoh.com"         "product\jp.ricoh.com"
call :clean_dir "%BASE%product\.vscode"              "product\.vscode"
call :clean_dir "%BASE%vul\jp.ricoh.com"             "vul\jp.ricoh.com"
call :clean_dir "%BASE%vul\.vscode"                  "vul\.vscode"
call :clean_dir "%BASE%vulnerabilities\jp.ricoh.com" "vulnerabilities\jp.ricoh.com"
call :clean_dir "%BASE%vulnerabilities\.vscode"      "vulnerabilities\.vscode"
call :clean_dir "%BASE%env_dev"                       "env_dev"
call :clean_dir "%BASE%.vscode"                       ".vscode"

echo.
echo ======================================
echo  クリーン完了
echo ======================================
pause
exit /b 0

:clean_dir
set _TARGET=%~1
set _LABEL=%~2
if exist "%_TARGET%" (
    rmdir /s /q "%_TARGET%"
    echo 削除: %_LABEL%
) else (
    echo [スキップ] %_LABEL% は存在しません
)
exit /b
