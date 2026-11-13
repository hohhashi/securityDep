@echo off
if exist ".vscode" rmdir /s /q ".vscode"
if exist "www.ricoh.com" rmdir /s /q "www.ricoh.com"

set UA=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36
set REF=https://www.ricoh.com/

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\icon_anchor_top.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/icon_anchor_top.svg"

if not exist "www.ricoh.com\products\security" mkdir "www.ricoh.com\products\security"
curl -L -o "www.ricoh.com\products\security\vulnerabilities.html" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/products/security/vulnerabilities"

if not exist "www.ricoh.com\layouts\system" mkdir "www.ricoh.com\layouts\system"
curl -L -o "www.ricoh.com\layouts\system\VisitorIdentification.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/layouts/system/VisitorIdentification.js"

if not exist "www.ricoh.com\-\Media\ScAssets\System\CSS" mkdir "www.ricoh.com\-\Media\ScAssets\System\CSS"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\CSS\sc_common_us.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/ScAssets/System/CSS/sc_common_us.css"

if not exist "www.ricoh.com\-\Media\ScAssets\System\Lib" mkdir "www.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\Lib\jquery.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/ScAssets/System/Lib/jquery.min.js?cacheDate=202610161518"

if not exist "www.ricoh.com\-\Media\ScAssets\System\Lib" mkdir "www.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\Lib\jquery.bxslider.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/ScAssets/System/Lib/jquery.bxslider.min.js?cacheDate=202610161518"

if not exist "www.ricoh.com\-\Media\ScAssets\System\Lib\bxslider" mkdir "www.ricoh.com\-\Media\ScAssets\System\Lib\bxslider"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\Lib\bxslider\jquery.bxslider.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/ScAssets/System/Lib/bxslider/jquery.bxslider.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\jquery-match-height.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/jquery-match-height.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\solution-product-template.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/solution-product-template.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\template.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/template.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\init.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/init.js"

if not exist "www.ricoh.com\Scripts\dist\lib" mkdir "www.ricoh.com\Scripts\dist\lib"
curl -L -o "www.ricoh.com\Scripts\dist\lib\vendor.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/Scripts/dist/lib/vendor.js?cacheDate=202610161518"

if not exist "www.ricoh.com\-\Media\ScAssets\System\JS" mkdir "www.ricoh.com\-\Media\ScAssets\System\JS"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\JS\common.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/ScAssets/System/JS/common.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\import.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/import.css?cacheDate=202610161518"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\solution-product-template.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/solution-product-template.css?cacheDate=202610161518"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\globalnavi.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/globalnavi.js?cacheDate=202610161518"

if not exist "www.ricoh.com\-\Media\ScAssets\System\Lib" mkdir "www.ricoh.com\-\Media\ScAssets\System\Lib"
curl -L -o "www.ricoh.com\-\Media\ScAssets\System\Lib\jquery.tile.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/ScAssets/System/Lib/jquery.tile.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.magnific-popup.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.magnific-popup.min.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video\jquery.modal-for-video.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/modal-for-video/jquery.modal-for-video.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video\youtube_modal_setting.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/modal-for-video/youtube_modal_setting.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video" mkdir "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\modal-for-video\magnific-popup.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/modal-for-video/magnific-popup.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\css\template.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/css/template.css?cacheDate=202610161518"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\js\common.vanilla.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/js/common.vanilla.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v1\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v1\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v1\css\component.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v1/css/component.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\css" mkdir "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\css\vulinfo_search.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Sites/com/products/security/vulnerabilities/css/vulinfo_search.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\template-global-addition2024.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/template-global-addition2024.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo\logo.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/logo/logo.svg"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\globe.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/globe.svg"

if not exist "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\img" mkdir "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\img"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\img\icons-rss.png" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Sites/com/products/security/vulnerabilities/img/icons-rss.png"

if not exist "www.ricoh.com\cdnjs.cloudflare.com\ajax\libs\jquery-easing\1.4.1" mkdir "www.ricoh.com\cdnjs.cloudflare.com\ajax\libs\jquery-easing\1.4.1"
curl -L -o "www.ricoh.com\cdnjs.cloudflare.com\ajax\libs\jquery-easing\1.4.1\jquery.easing.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdnjs.cloudflare.com/ajax/libs/jquery-easing/1.4.1/jquery.easing.min.js"

if not exist "www.ricoh.com\www.promisejs.org\polyfills" mkdir "www.ricoh.com\www.promisejs.org\polyfills"
curl -L -o "www.ricoh.com\www.promisejs.org\polyfills\promise-6.1.0.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.promisejs.org/polyfills/promise-6.1.0.min.js"

if not exist "www.ricoh.com\cdn.jsdelivr.net\npm\axios\dist" mkdir "www.ricoh.com\cdn.jsdelivr.net\npm\axios\dist"
curl -L -o "www.ricoh.com\cdn.jsdelivr.net\npm\axios\dist\axios.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"

if not exist "www.ricoh.com\cdn.jsdelivr.net\npm\vue\dist" mkdir "www.ricoh.com\cdn.jsdelivr.net\npm\vue\dist"
curl -L -o "www.ricoh.com\cdn.jsdelivr.net\npm\vue\dist\vue.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdn.jsdelivr.net/npm/vue/dist/vue.min.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\js" mkdir "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\js\vulinfo_search.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Sites/com/products/security/vulnerabilities/js/vulinfo_search.js"

if not exist "www.ricoh.com\ce.mf.marsflag.com\v2\js" mkdir "www.ricoh.com\ce.mf.marsflag.com\v2\js"
curl -L -o "www.ricoh.com\ce.mf.marsflag.com\v2\js\mf-search.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://ce.mf.marsflag.com/v2/js/mf-search.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\initBase.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/initBase.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\sc_reset.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/sc_reset.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\reset.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/reset.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\print.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/print.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\gl_header.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/gl_header.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\gl_footer.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/gl_footer.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\option.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/option.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\common.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/common.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\css\sc_common.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/css/sc_common.css"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cookie-management\css" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cookie-management\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cookie-management\css\common.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cookie-management/css/common.css"

if not exist "www.ricoh.com\layouts\system" mkdir "www.ricoh.com\layouts\system"
curl -L -o "www.ricoh.com\layouts\system\VisitorIdentificationCSS.aspx" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/layouts/system/VisitorIdentificationCSS.aspx?tstamp=1793782878625"

if not exist "www.ricoh.com\vuls.ricoh.com\en" mkdir "www.ricoh.com\vuls.ricoh.com\en"
curl -L -o "www.ricoh.com\vuls.ricoh.com\en\vulinfolist.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://vuls.ricoh.com/en/vulinfolist.json?20261145"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\templateBase" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\templateBase.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\search.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/search.svg"

if not exist "www.ricoh.com\-\media\ScAssets\System\Images" mkdir "www.ricoh.com\-\media\ScAssets\System\Images"
curl -L -o "www.ricoh.com\-\media\ScAssets\System\Images\favicon.ico" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/media/ScAssets/System/Images/favicon.ico?rev=88442a4d923a4ee98543f6eb4b4a7286&sc_lang=ja-JP"

echo done
pause
