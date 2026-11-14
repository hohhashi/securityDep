@echo off
rem ===============================================
rem merge_env_dev_ja.bat
rem
rem Runs download/setup bats for each page folder
rem (adv, list_products, product, vul, vulnerabilities),
rem then merges jp.ricoh.com into env_dev.
rem
rem After running, open env_dev in VSCode and
rem launch vulnerabilities.html with Live Server:
rem   http://127.0.0.1:5500/security/products/vulnerabilities.html
rem ===============================================

rem -------- Path settings --------
set BASE=%~dp0
set SRC_ADV=%BASE%adv\jp.ricoh.com
set SRC_LIST_PRODUCTS=%BASE%list_products\jp.ricoh.com
set SRC_PRODUCT=%BASE%product\jp.ricoh.com
set SRC_VUL=%BASE%vul\jp.ricoh.com
set SRC_VULNERABILITIES=%BASE%vulnerabilities\jp.ricoh.com
set ENV_DEV_ROOT=%BASE%env_dev
set DEST=%ENV_DEV_ROOT%\jp.ricoh.com
rem --------------------------------

echo ======================================
echo  [1/10] adv : download
echo ======================================
if exist "%BASE%adv\download_jp_ricoh_com_adv.bat" (
    pushd "%BASE%adv"
    call download_jp_ricoh_com_adv.bat
    popd
) else (
    echo [skip] adv\download_jp_ricoh_com_adv.bat not found
)

echo ======================================
echo  [2/10] adv : setup (JS patch)
echo ======================================
if exist "%BASE%adv\setup_jp_ricoh_com_adv.bat" (
    pushd "%BASE%adv"
    call setup_jp_ricoh_com_adv.bat
    popd
) else (
    echo [skip] adv\setup_jp_ricoh_com_adv.bat not found
)

echo ======================================
echo  [3/10] list_products : download
echo ======================================
if exist "%BASE%list_products\download_jp_ricoh_com_list_products.bat" (
    pushd "%BASE%list_products"
    call download_jp_ricoh_com_list_products.bat
    popd
) else (
    echo [skip] list_products\download_jp_ricoh_com_list_products.bat not found
)

echo ======================================
echo  [4/10] list_products : setup (JS patch)
echo ======================================
if exist "%BASE%list_products\setup_jp_ricoh_com_list_products.bat" (
    pushd "%BASE%list_products"
    call setup_jp_ricoh_com_list_products.bat
    popd
) else (
    echo [skip] list_products\setup_jp_ricoh_com_list_products.bat not found
)

echo ======================================
echo  [5/10] product : download
echo ======================================
if exist "%BASE%product\download_jp_ricoh_com_product.bat" (
    pushd "%BASE%product"
    call download_jp_ricoh_com_product.bat
    popd
) else (
    echo [skip] product\download_jp_ricoh_com_product.bat not found
)

echo ======================================
echo  [6/10] product : setup (JS patch)
echo ======================================
if exist "%BASE%product\setup_jp_ricoh_com_product.bat" (
    pushd "%BASE%product"
    call setup_jp_ricoh_com_product.bat
    popd
) else (
    echo [skip] product\setup_jp_ricoh_com_product.bat not found
)

echo ======================================
echo  [7/10] vul : download
echo ======================================
if exist "%BASE%vul\download_jp_ricoh_com_vul.bat" (
    pushd "%BASE%vul"
    call download_jp_ricoh_com_vul.bat
    popd
) else (
    echo [skip] vul\download_jp_ricoh_com_vul.bat not found
)

echo ======================================
echo  [8/10] vul : setup (JS patch)
echo ======================================
if exist "%BASE%vul\setup_jp_ricoh_com_vul.bat" (
    pushd "%BASE%vul"
    call setup_jp_ricoh_com_vul.bat
    popd
) else (
    echo [skip] vul\setup_jp_ricoh_com_vul.bat not found
)

echo ======================================
echo  [9/10] vulnerabilities : download
echo ======================================
if exist "%BASE%vulnerabilities\download_jp_ricoh_com_vulnerabilities.bat" (
    pushd "%BASE%vulnerabilities"
    call download_jp_ricoh_com_vulnerabilities.bat
    popd
) else (
    echo [skip] vulnerabilities\download_jp_ricoh_com_vulnerabilities.bat not found
)

echo ======================================
echo  [10/10] vulnerabilities : setup (JS patch)
echo ======================================
if exist "%BASE%vulnerabilities\setup_jp_ricoh_com_vulnerabilities.bat" (
    pushd "%BASE%vulnerabilities"
    call setup_jp_ricoh_com_vulnerabilities.bat
    popd
) else (
    echo [skip] vulnerabilities\setup_jp_ricoh_com_vulnerabilities.bat not found
)

echo.
echo ======================================
echo  Merging into env_dev...
echo ======================================

rem Remove and recreate env_dev (always fresh)
if exist "%ENV_DEV_ROOT%" rmdir /s /q "%ENV_DEV_ROOT%"
mkdir "%DEST%"

rem Merge order: vulnerabilities > vul > product > list_products > adv
rem JS files are page-specific so they don't collide.
call :merge_one "vulnerabilities" "%SRC_VULNERABILITIES%"
call :merge_one "vul"             "%SRC_VUL%"
call :merge_one "product"         "%SRC_PRODUCT%"
call :merge_one "list_products"   "%SRC_LIST_PRODUCTS%"
call :merge_one "adv"             "%SRC_ADV%"

rem Write .vscode/settings.json into env_dev
if not exist "%ENV_DEV_ROOT%\.vscode" mkdir "%ENV_DEV_ROOT%\.vscode"
(
    echo {
    echo     "liveServer.settings.root": "/jp.ricoh.com",
    echo     "files.autoGuessEncoding": true
    echo }
) > "%ENV_DEV_ROOT%\.vscode\settings.json"
echo OK: .vscode\settings.json

echo.
echo ======================================
echo  Merge complete: %DEST%
echo ======================================
echo  Next steps:
echo    1. Open env_dev folder in VSCode
echo    2. Right-click jp.ricoh.com\security\products\vulnerabilities.html
echo       and select "Open with Live Server"
echo    3. http://127.0.0.1:5500/security/products/vulnerabilities.html
echo ======================================
goto :end

:merge_one
set _NAME=%~1
set _SRC=%~2
if exist "%_SRC%" (
    echo --- merging %_NAME% ---
    robocopy "%_SRC%" "%DEST%" /E /NFL /NDL /NJH /NJS
) else (
    echo [skip] %_NAME% source not found: %_SRC%
)
exit /b

:end
pause
