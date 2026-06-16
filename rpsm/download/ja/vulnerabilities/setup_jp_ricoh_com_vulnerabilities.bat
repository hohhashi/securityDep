@echo off
rem ==============================================
rem 1. patch vulinfo_search.js
rem ==============================================
python patch_jp_ricoh_com_vulnerabilities.py

rem ==============================================
rem 2. generate .vscode/settings.json
rem ==============================================
if not exist ".vscode" mkdir ".vscode"
(
echo {
echo     "liveServer.settings.root": "/jp.ricoh.com",
echo     "files.autoGuessEncoding": true
echo }
) > .vscode\settings.json
echo generated .vscode\settings.json

echo done
