@echo off
rem ===============================================
rem merge_env_dev.bat
rem
rem 各ページフォルダ (adv, list_products, product,
rem vul, vulnerabilities) の download bat と setup bat を実行し、
rem jp.ricoh.com フォルダを env_dev にマージします。
rem
rem 実行後 env_dev フォルダを VSCode で開き、
rem jp.ricoh.com\security\products\vulnerabilities.html
rem を Live Server で起動してください。
rem   http://127.0.0.1:5500/security/products/vulnerabilities.html
rem ===============================================

rem -------- パスの設定 (必要に応じて変更) --------
set BASE=%~dp0
set SRC_ADV=%BASE%adv\jp.ricoh.com
set SRC_LIST_PRODUCTS=%BASE%list_products\jp.ricoh.com
set SRC_PRODUCT=%BASE%product\jp.ricoh.com
set SRC_VUL=%BASE%vul\jp.ricoh.com
set SRC_VULNERABILITIES=%BASE%vulnerabilities\jp.ricoh.com
set ENV_DEV_ROOT=%BASE%env_dev
set DEST=%ENV_DEV_ROOT%\jp.ricoh.com
rem ------------------------------------------------

echo ======================================
echo  [1/5] adv : ダウンロード
echo ======================================
if exist "%BASE%adv\download_jp_ricoh_com_filter_adv.bat" (
    pushd "%BASE%adv"
    call download_jp_ricoh_com_filter_adv.bat
    popd
) else (
    echo [スキップ] adv\download_jp_ricoh_com_filter_adv.bat が見つかりません
)

echo ======================================
echo  [2/5] adv : セットアップ (JS パッチ)
echo ======================================
if exist "%BASE%adv\setup_jp_ricoh_com_adv.bat" (
    pushd "%BASE%adv"
    call setup_jp_ricoh_com_adv.bat
    popd
) else (
    echo [スキップ] adv\setup_jp_ricoh_com_adv.bat が見つかりません
)

echo ======================================
echo  [3/10] list_products : ダウンロード
echo ======================================
if exist "%BASE%list_products\download_jp_ricoh_com_list_products.bat" (
    pushd "%BASE%list_products"
    call download_jp_ricoh_com_list_products.bat
    popd
) else (
    echo [スキップ] list_products\download_jp_ricoh_com_list_products.bat が見つかりません
)

echo ======================================
echo  [4/10] list_products : セットアップ (JS パッチ)
echo ======================================
if exist "%BASE%list_products\setup_jp_ricoh_com_list_products.bat" (
    pushd "%BASE%list_products"
    call setup_jp_ricoh_com_list_products.bat
    popd
) else (
    echo [スキップ] list_products\setup_jp_ricoh_com_list_products.bat が見つかりません
)

echo ======================================
echo  [5/10] product : ダウンロード
echo ======================================
if exist "%BASE%product\download_jp_ricoh_com_filter_product.bat" (
    pushd "%BASE%product"
    call download_jp_ricoh_com_filter_product.bat
    popd
) else (
    echo [スキップ] product\download_jp_ricoh_com_filter_product.bat が見つかりません
)

echo ======================================
echo  [6/10] product : セットアップ (JS パッチ)
echo ======================================
if exist "%BASE%product\setup_jp_ricoh_com_product.bat" (
    pushd "%BASE%product"
    call setup_jp_ricoh_com_product.bat
    popd
) else (
    echo [スキップ] product\setup_jp_ricoh_com_product.bat が見つかりません
)

echo ======================================
echo  [7/10] vul : ダウンロード
echo ======================================
if exist "%BASE%vul\download_jp_ricoh_com_vul.bat" (
    pushd "%BASE%vul"
    call download_jp_ricoh_com_vul.bat
    popd
) else (
    echo [スキップ] vul\download_jp_ricoh_com_vul.bat が見つかりません
)

echo ======================================
echo  [8/10] vul : セットアップ (JS パッチ)
echo ======================================
if exist "%BASE%vul\setup_jp_ricoh_com_vul.bat" (
    pushd "%BASE%vul"
    call setup_jp_ricoh_com_vul.bat
    popd
) else (
    echo [スキップ] vul\setup_jp_ricoh_com_vul.bat が見つかりません
)

echo ======================================
echo  [9/10] vulnerabilities : ダウンロード
echo ======================================
if exist "%BASE%vulnerabilities\download_jp_ricoh_com_vulnerabilities.bat" (
    pushd "%BASE%vulnerabilities"
    call download_jp_ricoh_com_vulnerabilities.bat
    popd
) else (
    echo [スキップ] vulnerabilities\download_jp_ricoh_com_vulnerabilities.bat が見つかりません
)

echo ======================================
echo  [10/10] vulnerabilities : セットアップ (JS パッチ)
echo ======================================
if exist "%BASE%vulnerabilities\setup_jp_ricoh_com_vulnerabilities.bat" (
    pushd "%BASE%vulnerabilities"
    call setup_jp_ricoh_com_vulnerabilities.bat
    popd
) else (
    echo [スキップ] vulnerabilities\setup_jp_ricoh_com_vulnerabilities.bat が見つかりません
)

echo.
echo ======================================
echo  env_dev へマージ開始
echo ======================================

rem env_dev を一度削除して作り直す (常に最新化)
if exist "%ENV_DEV_ROOT%" rmdir /s /q "%ENV_DEV_ROOT%"
mkdir "%DEST%"

rem マージ: 上書き (vulnerabilities > vul > product > list_products > adv の順)
rem JS ファイルは各ページ固有なので競合しない。
rem 共通 CSS/画像等は同一内容のため上書きしても問題ない。
call :merge_one "vulnerabilities" "%SRC_VULNERABILITIES%"
call :merge_one "vul"             "%SRC_VUL%"
call :merge_one "product"         "%SRC_PRODUCT%"
call :merge_one "list_products"   "%SRC_LIST_PRODUCTS%"
call :merge_one "adv"             "%SRC_ADV%"

rem .vscode/settings.json を env_dev 直下に配置
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
echo  マージ完了: %DEST%
echo ======================================
echo  次の手順:
echo    1. VSCode で env_dev フォルダを開く
echo    2. jp.ricoh.com\security\products\vulnerabilities.html
echo       を右クリック → Open with Live Server
echo    3. http://127.0.0.1:5500/security/products/vulnerabilities.html
echo ======================================
goto :end

:merge_one
set _NAME=%~1
set _SRC=%~2
if exist "%_SRC%" (
    echo --- %_NAME% をマージ中 ---
    robocopy "%_SRC%" "%DEST%" /E /NFL /NDL /NJH /NJS
) else (
    echo [スキップ] %_NAME% のコピー元が見つかりません: %_SRC%
)
exit /b

:end
pause
