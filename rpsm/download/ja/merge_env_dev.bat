@echo off
rem ===============================================
rem merge_env_dev.bat
rem
rem ja フォルダ配下に存在する 5 つの独立した
rem jp.ricoh.com ルート（adv, list_products, product,
rem vul, vulnerabilities）を、1 つの統合フォルダ
rem (env_dev) にマージします。
rem
rem マージ後は env_dev\jp.ricoh.com を Live Server の
rem ルートにすることで、以下のすべてのページが
rem 同一ポート（同一オリジン）で動作するようになります。
rem
rem   security/products/vulnerabilities.html
rem   security/products/vulnerabilities/vul.html?id=...
rem   security/products/vulnerabilities/adv?id=...
rem   security/products/vulnerabilities/list_products
rem   security/products/vulnerabilities/product?id=...
rem ===============================================

rem ↓↓↓ 必要に応じてパスを変更してください ↓↓↓
set BASE=%~dp0
set SRC_ADV=%BASE%adv\jp.ricoh.com
set SRC_LIST_PRODUCTS=%BASE%list_products\jp.ricoh.com
set SRC_PRODUCT=%BASE%product\jp.ricoh.com
set SRC_VUL=%BASE%vul\jp.ricoh.com
set SRC_VULNERABILITIES=%BASE%vulnerabilities\jp.ricoh.com
set ENV_DEV_ROOT=%BASE%env_dev
set DEST=%ENV_DEV_ROOT%\jp.ricoh.com
rem ↑↑↑ 必要に応じてパスを変更してください ↑↑↑

echo ======================================
echo  jp.ricoh.com フォルダのマージを開始します
echo ======================================
echo  コピー先: %DEST%
echo.

rem 既存の env_dev を完全に削除してから作り直す（常に最新化）
if exist "%ENV_DEV_ROOT%" rmdir /s /q "%ENV_DEV_ROOT%"
mkdir "%DEST%"

call :merge_one "adv"              "%SRC_ADV%"
call :merge_one "list_products"    "%SRC_LIST_PRODUCTS%"
call :merge_one "product"          "%SRC_PRODUCT%"
call :merge_one "vul"              "%SRC_VUL%"
call :merge_one "vulnerabilities"  "%SRC_VULNERABILITIES%"

echo.
echo ======================================
echo  マージ完了: %DEST%
echo ======================================
echo  この後、VSCode で env_dev フォルダを開き、
echo  jp.ricoh.com\security\products\vulnerabilities.html
echo  を Live Server で起動してください。
echo ======================================
goto :end

:merge_one
set NAME=%~1
set SRC=%~2
if exist "%SRC%" (
    echo --- %NAME% をマージ中 ---
    robocopy "%SRC%" "%DEST%" /E /NFL /NDL /NJH /NJS
) else (
    echo [スキップ] %NAME% のコピー元が見つかりません: %SRC%
)
exit /b

:end
pause
