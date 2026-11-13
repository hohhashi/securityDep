@echo off
rem ===============================================
rem clean_env_dev_ja.bat
rem
rem Deletes jp.ricoh.com folders and .vscode folders
rem under each page folder (adv, list_products, product,
rem vul, vulnerabilities), plus env_dev and .vscode,
rem returning the workspace to a clean state.
rem ===============================================

set BASE=%~dp0

echo ======================================
echo  Clean start
echo  Targets:
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
set /p CONFIRM=Delete all of the above? (y/N):
if /i not "%CONFIRM%"=="y" (
    echo Cancelled.
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
call :clean_dir "%BASE%env_dev"                      "env_dev"
call :clean_dir "%BASE%.vscode"                      ".vscode"

echo.
echo ======================================
echo  Clean done
echo ======================================
pause
exit /b 0

:clean_dir
set _TARGET=%~1
set _LABEL=%~2
if exist "%_TARGET%" (
    rmdir /s /q "%_TARGET%"
    echo deleted: %_LABEL%
) else (
    echo [skip] %_LABEL% not found
)
exit /b
