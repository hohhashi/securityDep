@echo off
rem HAR from curl command list
rem www.ricoh.com/products/security/vulnerabilities/vul - 2026/11/10
rem URL path structure is recreated as folder
rem Run: download_www_ricoh_com_vul.bat

set UA=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/148.0.0.0 Safari/537.36
set REF=https://www.ricoh.com/

if not exist "www.ricoh.com\products\security\vulnerabilities" mkdir "www.ricoh.com\products\security\vulnerabilities"
curl -L -o "www.ricoh.com\products\security\vulnerabilities\vul.html" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/products/security/vulnerabilities/vul?id=ricoh-2026-000004"

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

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\consent\018f841e-98e2-7a7e-9a33-21788e58a08e" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\consent\018f841e-98e2-7a7e-9a33-21788e58a08e"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\consent\018f841e-98e2-7a7e-9a33-21788e58a08e\OtAutoBlock.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/consent/018f841e-98e2-7a7e-9a33-21788e58a08e/OtAutoBlock.js"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\otSDKStub.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/otSDKStub.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\css" mkdir "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\css"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\css\vul.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Sites/com/products/security/vulnerabilities/css/vul.css?250926"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\logo\logo.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/logo/logo.svg"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\globe.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/globe.svg"

if not exist "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\img" mkdir "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\img"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\img\ic_important.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Sites/com/products/security/vulnerabilities/img/ic_important.svg"

if not exist "www.ricoh.com\cdn.jsdelivr.net\npm\dayjs@1" mkdir "www.ricoh.com\cdn.jsdelivr.net\npm\dayjs@1"
curl -L -o "www.ricoh.com\cdn.jsdelivr.net\npm\dayjs@1\dayjs.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdn.jsdelivr.net/npm/dayjs@1/dayjs.min.js"

if not exist "www.ricoh.com\cdnjs.cloudflare.com\ajax\libs\jquery-easing\1.4.1" mkdir "www.ricoh.com\cdnjs.cloudflare.com\ajax\libs\jquery-easing\1.4.1"
curl -L -o "www.ricoh.com\cdnjs.cloudflare.com\ajax\libs\jquery-easing\1.4.1\jquery.easing.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdnjs.cloudflare.com/ajax/libs/jquery-easing/1.4.1/jquery.easing.min.js"

if not exist "www.ricoh.com\www.promisejs.org\polyfills" mkdir "www.ricoh.com\www.promisejs.org\polyfills"
curl -L -o "www.ricoh.com\www.promisejs.org\polyfills\promise-6.1.0.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.promisejs.org/polyfills/promise-6.1.0.min.js"

if not exist "www.ricoh.com\cdn.jsdelivr.net\npm\axios\dist" mkdir "www.ricoh.com\cdn.jsdelivr.net\npm\axios\dist"
curl -L -o "www.ricoh.com\cdn.jsdelivr.net\npm\axios\dist\axios.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"

if not exist "www.ricoh.com\cdn.jsdelivr.net\npm\vue\dist" mkdir "www.ricoh.com\cdn.jsdelivr.net\npm\vue\dist"
curl -L -o "www.ricoh.com\cdn.jsdelivr.net\npm\vue\dist\vue.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdn.jsdelivr.net/npm/vue/dist/vue.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\js" mkdir "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Sites\com\products\security\vulnerabilities\js\vul.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Sites/com/products/security/vulnerabilities/js/vul.js"

if not exist "www.ricoh.com\cdn.jsdelivr.net\npm\vue\dist" mkdir "www.ricoh.com\cdn.jsdelivr.net\npm\vue\dist"
curl -L -o "www.ricoh.com\cdn.jsdelivr.net\npm\vue\dist\vue.min.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cdn.jsdelivr.net/npm/vue/dist/vue.min.js"

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

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\consent\018f841e-98e2-7a7e-9a33-21788e58a08e" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\consent\018f841e-98e2-7a7e-9a33-21788e58a08e"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\consent\018f841e-98e2-7a7e-9a33-21788e58a08e\018f841e-98e2-7a7e-9a33-21788e58a08e.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/consent/018f841e-98e2-7a7e-9a33-21788e58a08e/018f841e-98e2-7a7e-9a33-21788e58a08e.json"

if not exist "www.ricoh.com\geolocation.onetrust.com\cookieconsentpub\v1\geo" mkdir "www.ricoh.com\geolocation.onetrust.com\cookieconsentpub\v1\geo"
curl -L -o "www.ricoh.com\geolocation.onetrust.com\cookieconsentpub\v1\geo\location.html" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://geolocation.onetrust.com/cookieconsentpub/v1/geo/location"

if not exist "www.ricoh.com\vuls.ricoh.com\en\vulinfo\2026" mkdir "www.ricoh.com\vuls.ricoh.com\en\vulinfo\2026"
curl -L -o "www.ricoh.com\vuls.ricoh.com\en\vulinfo\2026\ricoh-2026-000004.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://vuls.ricoh.com/en/vulinfo/2026/ricoh-2026-000004.json?202611109"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\otBannerSdk.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/202505.2.0/otBannerSdk.js"

if not exist "www.ricoh.com\layouts\system" mkdir "www.ricoh.com\layouts\system"
curl -L -o "www.ricoh.com\layouts\system\VisitorIdentificationCSS.aspx" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/layouts/system/VisitorIdentificationCSS.aspx?tstamp=1794274200614"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\js\templateBase.html" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/js/templateBase"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_g_header_footer\img\icon\search.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_g_header_footer/img/icon/search.svg"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\consent\018f841e-98e2-7a7e-9a33-21788e58a08e\019593c6-6f53-7b83-93b9-f9b00b22f437" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\consent\018f841e-98e2-7a7e-9a33-21788e58a08e\019593c6-6f53-7b83-93b9-f9b00b22f437"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\consent\018f841e-98e2-7a7e-9a33-21788e58a08e\019593c6-6f53-7b83-93b9-f9b00b22f437\en.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/consent/018f841e-98e2-7a7e-9a33-21788e58a08e/019593c6-6f53-7b83-93b9-f9b00b22f437/en.json"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\assets" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\assets"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\assets\otFlat.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/202505.2.0/assets/otFlat.json"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\assets\v2" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\assets\v2"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\assets\v2\otPcCenter.json" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/202505.2.0/assets/v2/otPcCenter.json"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\assets" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\assets"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\scripttemplates\202505.2.0\assets\otCommonStyles.css" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/scripttemplates/202505.2.0/assets/otCommonStyles.css"

if not exist "www.ricoh.com\-\media\ScAssets\System\Images" mkdir "www.ricoh.com\-\media\ScAssets\System\Images"
curl -L -o "www.ricoh.com\-\media\ScAssets\System\Images\favicon.ico" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/media/ScAssets/System/Images/favicon.ico?rev=88442a4d923a4ee98543f6eb4b4a7286&sc_lang=ja-JP"

if not exist "www.ricoh.com\www.youtube.com" mkdir "www.ricoh.com\www.youtube.com"
curl -L -o "www.ricoh.com\www.youtube.com\iframe_api.html" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.youtube.com/iframe_api"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\logos\static" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\logos\static"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\logos\static\ot_close.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/logos/static/ot_close.svg"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\logos\static" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\logos\static"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\logos\static\ot_guard_logo.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/logos/static/ot_guard_logo.svg"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\logos\b68d8172-566e-4cb6-8189-dc0031d2ae7a\018f80df-3071-7bd6-a392-ddd32a21517b\a0ec1df9-a5f5-4350-bb05-1e92c79947f1" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\logos\b68d8172-566e-4cb6-8189-dc0031d2ae7a\018f80df-3071-7bd6-a392-ddd32a21517b\a0ec1df9-a5f5-4350-bb05-1e92c79947f1"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\logos\b68d8172-566e-4cb6-8189-dc0031d2ae7a\018f80df-3071-7bd6-a392-ddd32a21517b\a0ec1df9-a5f5-4350-bb05-1e92c79947f1\Lockup_Logo_RGB_0.6x.png" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/logos/b68d8172-566e-4cb6-8189-dc0031d2ae7a/018f80df-3071-7bd6-a392-ddd32a21517b/a0ec1df9-a5f5-4350-bb05-1e92c79947f1/Lockup_Logo_RGB_0.6x.png"

if not exist "www.ricoh.com\cookie-cdn.cookiepro.com\logos\static" mkdir "www.ricoh.com\cookie-cdn.cookiepro.com\logos\static"
curl -L -o "www.ricoh.com\cookie-cdn.cookiepro.com\logos\static\powered_by_logo.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://cookie-cdn.cookiepro.com/logos/static/powered_by_logo.svg"

if not exist "www.ricoh.com\www.youtube.com\s\player\a5c2aafe\www-widgetapi.vflset" mkdir "www.ricoh.com\www.youtube.com\s\player\a5c2aafe\www-widgetapi.vflset"
curl -L -o "www.ricoh.com\www.youtube.com\s\player\a5c2aafe\www-widgetapi.vflset\www-widgetapi.js" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.youtube.com/s/player/a5c2aafe/www-widgetapi.vflset/www-widgetapi.js"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg\blank-primary-color.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/svg/blank-primary-color.svg"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\svg\arrow-right-primary-color.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/svg/arrow-right-primary-color.svg"

if not exist "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img" mkdir "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img"
curl -L -o "www.ricoh.com\-\Media\Ricoh\Common\cmn_v3\img\icon_anchor_top.svg" -H "User-Agent: %UA%" -H "Referer: %REF%" "https://www.ricoh.com/-/Media/Ricoh/Common/cmn_v3/img/icon_anchor_top.svg"

rem [SKIP-TRACKING] https://cdn.fonts.net/kit/3c059441-5218-4b9b-974d-a8185a3bd584/3c059441-5218-4b9b-974d-a8185a3bd584_enhanced.css
rem [SKIP-TRACKING] https://cdn.fonts.net/kit/3c059441-5218-4b9b-974d-a8185a3bd584/3c059441-5218-4b9b-974d-a8185a3bd584_enhanced.js
rem [SKIP-TRACKING] https://cdn.fonts.net/kit/3c059441-5218-4b9b-974d-a8185a3bd584/3c059441-5218-4b9b-974d-a8185a3bd584_enhanced.css
rem [SKIP-TRACKING] https://cdn.fonts.net/t/trackingCode.js
rem [SKIP-TRACKING] https://cdn.fonts.net/kit/3c059441-5218-4b9b-974d-a8185a3bd584/Frutiger/FrutigerLTPro_normal_normal_700.woff2
rem [SKIP-TRACKING] https://cdn.fonts.net/kit/3c059441-5218-4b9b-974d-a8185a3bd584/Frutiger/FrutigerLTPro_normal_normal_400.woff2
rem [SKIP-TRACKING] https://cdn.fonts.net/t/1.css?apiType=css&projectid=3c059441-5218-4b9b-974d-a8185a3bd584
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-P7GM9L
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-M3X5GT6
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-P7HDTZ2&gtm=4e6b61
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-PF8J5L9&gtm=4e6b61
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtm.js?id=GTM-W56ZXWXH&gtm=4e6b61
rem [SKIP-TRACKING] https://www.googletagmanager.com/gtag/js?id=G-V4PCRFJHL9&cx=c&gtm=4e6b61
rem [SKIP-TRACKING] https://snap.licdn.com/li.lms-analytics/insight.min.js
rem [SKIP-TRACKING] https://bzrcdn.openai.com/sdk/oaiq.min.js
rem [SKIP-TRACKING] https://bzrcdn.openai.com/pixel-config/v1/U1dXKkeAPqeBGzmWasp9NE.json
rem [SKIP-TRACKING] https://px.ads.linkedin.com/collect?v=2&fmt=js&pid=8909972&time=1794274201351&li_adsId=e7b3074d-e70e-4c38-aacc-11b23bc2d
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-V4PCRFJHL9&gtm=45je6b61v888055240za20ozb895782797zd863735788xf1&_p=
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-V4PCRFJHL9&gtm=45je6b61v888055240z8895782797za20gzb895782797zd86373
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-V4PCRFJHL9&gtm=45je6b61v888055240z8895782797za20gzb895782797zd86373
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-V4PCRFJHL9&gtm=45je6b61v888055240z8895782797za20gzb895782797zd86373
rem [SKIP-POST] https://www.google-analytics.com/g/collect?v=2&tid=G-V4PCRFJHL9&gtm=45je6b61v888055240z8895782797za20gzb895782797zd86373
rem [SKIP-TRACKING] https://px.ads.linkedin.com/collect?v=2&fmt=js&pid=8909972&time=1794274201351&li_adsId=e7b3074d-e70e-4c38-aacc-11b23bc2d
rem [SKIP-TRACKING] https://www.linkedin.com/px/li_sync?redirect=https%3A%2F%2Fpx.ads.linkedin.com%2Fcollect%3Fv%3D2%26fmt%3Djs%26pid%3D8909
rem [SKIP-TRACKING] https://px.ads.linkedin.com/collect?v=2&fmt=js&pid=8909972&time=1794274201351&li_adsId=e7b3074d-e70e-4c38-aacc-11b23bc2d
rem [SKIP-POST] https://px.ads.linkedin.com/wa/?medium=fetch&fmt=g
rem [SKIP-POST] https://bzr.openai.com/v1/sdk/events?pid=U1dXKkeAPqeBGzmWasp9NE&st=oaiq-web&sv=0.1.100&t=1794274202598&ec=2
rem [SKIP-POST] https://px.ads.linkedin.com/wa/?medium=fetch&fmt=g

echo Done.
